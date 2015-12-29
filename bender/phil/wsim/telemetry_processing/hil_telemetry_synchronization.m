%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2010 - 2015 Moon Express, Inc.
% All Rights Reserved.
%
% PROPRIETARY DATA NOTICE:
% The data herein include Proprietary Data and are restricted under the
% Data Rights provisions of Lunar CATALYST Space Act Agreement
% No. SAAM ID# 18251 and Reimbursable Space Act Agreement No.SAA2-402930.
% All information contained herein is and remains proprietary to and the
% property of Moon Express, Inc. Dissemination of this information or
% reproduction of this material is strictly forbidden unless prior
% written permission is obtained from Moon Express, Inc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-------------------------------------------------------------------------%
% hil_telemetry_synchronization.m                                         %
%                                                                         %
% syncs data between the two HIL processors                               %
% 04/16/14                                                                %
%-------------------------------------------------------------------------%

function [telem truth] = hil_telemetry_synchronization(telem, truth, directory)

% parent function has already ensured that the initial scenario time exists in the workspace
try
    scenario_start_time_seconds = evalin('base','ini_epoch_seconds');
catch
    scenario_start_time_seconds = 0;
end

% look  for time set and remove data....or make new time stamp...
hil_fsw_event_filename = fullfile(directory, 'CFE_EVS_Packet_t.csv');

% If there are no logs, silently exit
if exist(hil_fsw_event_filename, 'file')
    
    % Use textscan to load in archive-reader produced event packet CSV
    fid = fopen(hil_fsw_event_filename,'r');
    if fid ~= -1
        event_data = textscan(fid, '%f%u%q%u%u%u%u%q', 'delimiter', ',', 'HeaderLines', 1);
        fclose(fid);
    end
    
    % find events from CFE_TIME
    time_ids = find(strcmp(event_data{:,3}, 'CFE_TIME'));
    for jj = 1 : length(time_ids)
        time_text = event_data{8}{time_ids(jj)};
        time_string = regexp(time_text, '(?<== ).*(.*?),','match');
        if ~isempty(time_string)
            comma_index = regexp(time_string{1}, ',');
            secs = str2double(time_string{1}(1:comma_index(1)-1));
            
            if secs > scenario_start_time_seconds
                scenario_start_time_seconds = secs;
            end
        end
    end
    
end

%-------------------------------------------------------------------------%
% resample telem if needed

message_names = fieldnames(telem);


hk_id = find( cell2mat( cellfun(@isempty ,strfind(message_names, 'hk'),'UniformOutput',0)) == 0);

if ~isempty(hk_id)
    
    message = telem.(message_names{hk_id});
    
    % assume that all hk telem is at 1hz for now
    % assume that we want hk data at 10hz for now
    % just use cmp timestamp for this (...for now)
    
    message_10hz = resample(message, telem.cmp_mtv_msg.Time);
    
    telem.(message_names{hk_id}) = message_10hz;
    
end



%-------------------------------------------------------------------------%
% walk telem

n_messages = length(message_names);

telem_start_time  = NaN(n_messages,1);

for ii = 1 : n_messages
    % ESC: allow escape hatch for messages that are not always extant
    telem_start_time(ii)  = telem.(message_names{ii}).Time( find( telem.(message_names{ii}).Time >= scenario_start_time_seconds,1) );
end

%-------------------------------------------------------------------------%
% walk truth
if ~isempty(truth)
    message_names_truth = fieldnames(truth);
    n_messages_truth = length(message_names_truth);
    
    truth_start_time  = NaN(n_messages_truth,1);
    
    for ii = 1 : n_messages_truth
        truth_start_time(ii) = truth.(message_names_truth{ii}).Time( find( truth.(message_names_truth{ii}).Time >= scenario_start_time_seconds, 1 ) );
    end
else
    truth_start_time  = NaN;
end
    

%-------------------------------------------------------------------------%
% find max time
[ max_telem_time ] = max(telem_start_time);
[ max_truth_time ] = max(truth_start_time);

% create new var which holds the actual start time for this data set 
data_start_time_seconds = max(max_telem_time, max_truth_time);

% get all messages within telem structure to be of constent size 
fprintf(1, 'Telemetry synced to start at %i seconds, %s UTC\n', uint32(data_start_time_seconds), seconds2datestr(data_start_time_seconds))
[ telem_start_index, telem_end_index ] = determine_valid_indices(telem, data_start_time_seconds);

% get all messages within truth structure to be of constent size, if it exists
if ~isnan(truth_start_time)
    [ truth_start_index, truth_end_index ] = determine_valid_indices(truth, data_start_time_seconds);
end

% resize the ts collections actually have that size
telem = resize_ts_struct(telem, telem_start_index, telem_end_index, data_start_time_seconds);
if ~isnan(truth_start_time)
    truth = resize_ts_struct(truth, truth_start_index, truth_end_index, data_start_time_seconds);
end

assignin('base','plotting_time_zero_seconds', data_start_time_seconds)

%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -%
function [ start_index, end_index ] = determine_valid_indices(telem, start_time)

% extract struct names
message_names = fieldnames(telem);
n_messages = length(message_names);

start_index = NaN(n_messages,1);
end_index   = NaN(n_messages,1);


for ii = 1 : n_messages
    
    % find first telemetry index which is larger than start time
    start_index(ii) = find( telem.(message_names{ii}).Time >= start_time,1);
    
    delta_time = telem.(message_names{ii}).Time(start_index(ii))-start_time;
    if delta_time > 1
        fprintf(2,'Times are not synced for %s!\n', message_names{ii})
    end
    
    telem_length  = telem.(message_names{ii}).Length;
    
    % find last valid packet in each message (time greater than initial...)
    i_too_early = find( telem.(message_names{ii}).Time( start_index(ii) : end ) < start_time, 1 );
    if ~isempty(i_too_early)
        end_index(ii) = i_too_early;
    else
        end_index(ii) = telem_length;
    end
    
end

% make everything a conistent length 
% use the shortest message to set length of all messages
message_length = end_index - start_index;
min_length = min(message_length);

end_index = start_index + min_length;


%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -%
% telem = resize_ts_struct(telem, i_start_telem, i_end_telem)             %
%                                                                         %
% resizes structure of tscollection to all have consistent times/lengths  %
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -%
function telem = resize_ts_struct(telem, i_start_telem, i_end_telem, start_time)
% extract struct names
message_names = fieldnames(telem);
n_messages = length(message_names);

for ii = 1 : n_messages
    
    fprintf(1, 'Resizing %s to select indices [%d : %d]\n', message_names{ii}, i_start_telem(ii), i_end_telem(ii))

    % cut all messages down to the desired length
    prefix = message_names{ii}(1:3);
    
    % determine message member names
    member_names  =  telem.(message_names{ii}).fieldnames;
    n_members = length(member_names);
    
    % check if telem already has a member called by this prefix
    new_message_names = fieldnames(telem);

    if ~any(strcmpi(new_message_names,prefix))
        
        % create new time vector of appropriate length using cfe header
        try
            time_vec = telem.(message_names{ii}).cfe_tlm_header_align.Time(i_start_telem(ii):i_end_telem(ii)) - start_time;
        catch
            time_vec = telem.(message_names{ii}).Time(i_start_telem(ii):i_end_telem(ii)) - start_time;
        end
        
        % create a temporary tscollection using this time
        temp_ts = tscollection(time_vec);
        new_msg = 1;
    else
        % add new members to existing tscollection for this app
        temp_ts = telem.(prefix);
        new_msg = 0;
    end
    
    for jj = 1 : n_members
        
        if new_msg
            try
                % shorten each member down to the new length
               eval( sprintf('temp_ts.%s =  timeseries( getdatasamples(telem.%s.%s, [i_start_telem(ii) : i_end_telem(ii)]), temp_ts.Time,''Name'', ''%s'' );', member_names{jj}, message_names{ii}, member_names{jj}, member_names{jj}) ) ;
                
            catch err
                % some members like 'length' and 'name' are not actually ts objecs
                switch member_names{jj}
                    case {'Name','Length','Time','TimeInfo'}
                        % no action needed, as these are standard
                    otherwise
                        % if its something else, we might have a problem
                        rethrow(err)
                end
            end
            
        else
            try
                % shorten each member down to the new length
               eval( sprintf('temp_ts.%s =  timeseries( getdatasamples(telem.%s.%s, [i_start_telem(ii) : i_end_telem(ii)]), temp_ts.Time,''Name'', ''%s'' );', member_names{jj}, message_names{ii}, member_names{jj}, member_names{jj}) ) ;
            catch err
                % some members like 'length' and 'name' are not actually ts objecs
                switch member_names{jj}
                    case {'Name','Length','Time','TimeInfo'}
                        % no action needed, as these are standard
                    otherwise
                        % if its something else, we might have a problem
                        rethrow(err)
                end
            end
        end
        
    end
    
    % reassign the new ts to the current message name
    telem.(prefix) = temp_ts;
    telem = rmfield( telem, message_names{ii} );
    clear temp_ts
    
end


