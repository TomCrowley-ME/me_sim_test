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
% wsim_telemetry_synchronization.m                                        %
%                                                                         %
% syncs data...cause its already totally synced                           %
% 04/17/14                                                                %
%-------------------------------------------------------------------------%

function [telem truth] = wsim_telemetry_synchronization(telem, truth)



% use indices of whole thing

i_start_telem = 1;
i_start_truth = 1;

i_end_telem = telem.cnt_bus_msg.Length;
i_end_truth = truth.sim_tlm_msg.Length;

fprintf(1, 'Resizing telemetry to select indices [%d : %d]\n', i_start_telem, i_end_telem)
fprintf(1, 'Resizing truth to select indices [%d : %d]\n', i_start_truth, i_end_truth)

telem = resize_ts_struct(telem, i_start_telem, i_end_telem);
truth = resize_ts_struct(truth, i_start_truth, i_end_truth);

%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -%
% telem = resize_ts_struct(telem, i_start_telem, i_end_telem)             %
%                                                                         %
% resizes structure of tscollection to all have consistent times/lengths  %
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -%
function telem = resize_ts_struct(telem, i_start_telem, i_end_telem)
% extract struct names
message_names = fieldnames(telem);
n_messages = length(message_names);

for ii = 1 : n_messages
    
    % cut all messages down to the desired length
    prefix = message_names{ii}(1:3);
    
    % determine message member names
    member_names  =  telem.(message_names{ii}).fieldnames;
    n_members = length(member_names);
    
    % check if telem already has a member called by this prefix
    new_message_names = fieldnames(telem);
    
    if ~any(strcmpi(new_message_names,prefix))
        
        if ~strcmpi(prefix, 'pcs') && ~strcmpi(prefix, 'tcs')
            % create new time vector of appropriate length using cfe header
            time_vec = telem.(message_names{ii}).cfe_tlm_header_align.Time(i_start_telem:i_end_telem);
        else
            % use old time vector for 1hz apps
            time_vec = telem.(message_names{ii}).cfe_tlm_header_align.Time;
        end
        
        % create a temporary tscollection using this time
        temp_ts = tscollection(time_vec);
        
    else
        % add new members to existing tscollection for this app
        temp_ts = telem.(prefix);
        
    end
    
    for jj = 1 : n_members
        
        try
            if ~strcmpi(prefix, 'pcs') && ~strcmpi(prefix, 'tcs')
                % shorten each member down to the new length
                eval( sprintf('temp_ts.%s =  getsamples(telem.%s.%s, [i_start_telem : i_end_telem]);', member_names{jj}, message_names{ii}, member_names{jj}) ) ;
            else
                % use standard data for 1hz apps
                eval( sprintf('temp_ts.%s =  telem.%s.%s;', member_names{jj}, message_names{ii}, member_names{jj}) ) ;
            end
        catch
            % some members like 'length' and 'name' are not actually ts objecs
            switch member_names{jj}
                case {'Name','Length','Time','TimeInfo'}
                    % no action needed, as these are standard
                otherwise
                    % if its something else, we might have a problem
                    fprintf(1,'Member %s is not a ts\n',member_names{jj})
            end
            
        end
    end
    
    % reassign the new ts to the current message name
    telem.(prefix) = temp_ts;
    telem = rmfield( telem, message_names{ii} );
    clear temp_ts
    
end

