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

function create_event_log(raw_event_log, epoch_seconds, filename)

% In the WSIM every event that occurs during the same step has the *exact*
% same timestamp, so we need to bias the times to recreate the run order
% TODO: Make this less hacky. Also, CSC_EGC is bleeding over from MTV
app_time_biases = containers.Map({'CSC_SIM', 'CSC_LC', 'CSC_SC', 'CSC_CMP', 'CSC_EST', 'CSC_GDN', 'CSC_CNT', 'CSC_ACT', 'CSC_EGC'}, ...
                                 {   0.0000,   0.0001,   0.0002,    0.0003,    0.0004,    0.0005,    0.0006,    0.0007,   0.0008 });

short_event_severities = containers.Map({'CFE_EVS_DEBUG', 'CFE_EVS_INFORMATION', 'CFE_EVS_ERROR', 'CFE_EVS_CRITICAL'}, ...
                                        {        'DEBUG',                'INFO',         'ERROR',         'CRITICAL'});

% TODO: Assign unique names to entries with duplicate names. We currently
% just fail, probably.
logged_signal_names = unique(raw_event_log.getElementNames());

% Grab all of the flags for the events, which we'll look at to figure out
% what happened when
event_flags = logged_signal_names(~cellfun('isempty', regexp(logged_signal_names, '_flag$', 'once')));

event_log = cell(1,1);
event_times = zeros(1,1);

total_num_events = 0;

for i=1:length(event_flags)
    flag_info = raw_event_log.getElement(event_flags{i});
    if length(flag_info) > 1
        % Despite this being a "warning" we'll probably immediately fail
        warning(['Unhandled duplicate signal with flag name ' event_flags{i}]);
    end
    
    % Whenever the flag is not 0, an event happened
    curr_event_occurrences = find(flag_info.Values.Data);
    
    if ~isempty(curr_event_occurrences)
        % Use the block path of the flag to figure out the name of the cFE
        % Event block, and interrogate it for its event parameters
        source_block = get_param(flag_info.BlockPath.getBlock(1),'Parent');
        rtwdata = get_param(source_block, 'RTWData');
        
        curr_event_format_string = ['''' rtwdata.message ''''];
        curr_event_id = rtwdata.id;
        curr_event_severity = rtwdata.severity;
        
        % Grab the filter mask if enabled
        if str2double(rtwdata.filtered)
            curr_event_mask = str2double(rtwdata.mask);
        else
            curr_event_mask = 1;
        end
        
        % Select only the events that pass filtering
        filtered_event_occurrences = curr_event_occurrences(1:curr_event_mask:end);
        
        % Further process the parent block path to determine the TLA of the
        % source application
        app_tla = regexp(source_block, 'csci_\w+/csc_([^_]+)', 'tokens', 'once');
        app_name = ['CSC_' upper(app_tla{1})];
        
        % Determine the root name of the signal, which we use to look up
        % any associate data
        signal_root_name = regexprep(event_flags{i}, '_flag$', '');
        
        curr_event_data_names = logged_signal_names(~cellfun('isempty', regexp(logged_signal_names, [signal_root_name '_data'], 'once')));
        curr_event_num_data = length(curr_event_data_names);
        
        data_values = cell(curr_event_num_data);
        
        % Grab the value of each associated piece of data at each timestep
        % when the event triggered
        for j=1:curr_event_num_data
            data_info = raw_event_log.getElement(curr_event_data_names{j});
            data_values{j} = data_info.Values.Data(filtered_event_occurrences);
        end
        
        % Grab the times for each event occurrence, and bias it by the
        % source application's run order so we can properly sort the final
        % consolidated log
        unbiased_event_times = flag_info.Values.Time(filtered_event_occurrences);
        curr_event_times = unbiased_event_times + app_time_biases(app_name);
        
        % Determine the order of magnitude of the end time of the
        % simulation, to make the log as compact as we can
        max_time_magnitude = fix(log10(flag_info.Values.Time(end)));
        
        % Grab the enumerated types for each data signal
        enum_types = strsplit(rtwdata.enum_types, '|', 'CollapseDelimiters', 0);
        
        % Rebuild what the message should have been for every occurrence of
        % the event
        for j=1:length(filtered_event_occurrences)
            format_cmd = ['sprintf(' curr_event_format_string];
            for k=1:curr_event_num_data
                if ~isempty(enum_types{k})
                    [enum_values, enum_strings] = enumeration(enum_types{k});
                    enum_index = find(enum_values == data_values{k}(j));
                    if isempty(enum_index)
                        enum_string = 'ENUM_INVALID';
                    else
                        enum_string = upper(enum_strings{enum_index});
                    end
                    format_cmd = [format_cmd ',''' enum_string ''''];
                else
                    format_cmd = [format_cmd ',' num2str(data_values{k}(j))];
                end
            end
            
            format_cmd = [format_cmd ')'];
            
            % Construct the message and log entry!
            event_message = eval(format_cmd);
            
            event_text = sprintf(['%s (%0' num2str(max_time_magnitude+4) '.2f)  %-8s %3s  %-8s   %-122s'], ...
                seconds2datestr(curr_event_times(j) + epoch_seconds), ...
                curr_event_times(j), ...
                app_name, curr_event_id, ...
                short_event_severities(curr_event_severity), ...
                event_message);
            
            % Now that we've completed an entry, shove it out into the
            % overall log
            total_num_events = total_num_events + 1;
            event_times(total_num_events) = curr_event_times(j);
            event_log{total_num_events} = event_text;
            
            % Also put it into the event plot data
            event_plot_data(total_num_events).time = unbiased_event_times(j);
            event_plot_data(total_num_events).app = app_name;
            event_plot_data(total_num_events).message = event_message;
        end
    end
    
end

% Use the event times to sort the event log
[~, sorted_indices] = sort(event_times);
event_log = event_log(sorted_indices);
event_plot_data = event_plot_data(sorted_indices);

% And finally save it off!
fid = fopen(filename, 'w+');

file_dir = fileparts(filename);

save([file_dir filesep 'event_plot_data'], 'event_plot_data');

for i=1:length(event_log)
    fprintf(fid, [event_log{i} '\n']);
end

fclose(fid);

end