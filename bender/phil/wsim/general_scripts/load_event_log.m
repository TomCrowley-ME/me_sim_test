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
% load_event_log.m                                                        %
%                                                                         %
% loads events from directory, either phil or wsim                        %
% 09/23/14                                                                %
%-------------------------------------------------------------------------%

function load_event_log(dir)

event_data = {};
event_types = {'DEBUG', 'INFO', 'ERROR', 'CRITICAL'};

wsim_event_filename = fullfile(dir, 'event_log.txt');
hil_fsw_event_filename = fullfile(dir, 'CFE_EVS_Packet_t.csv');
hil_sim_event_filename = fullfile(dir, 'sim_CFE_EVS_Packet_t.csv');

% If there are no logs, silently exit
if ~exist(wsim_event_filename, 'file') && ~exist(hil_fsw_event_filename, 'file') && ~exist(hil_sim_event_filename, 'file')
    return;
end

fprintf(1, 'Loading event log\n');

if exist(wsim_event_filename, 'file')
    % WSIM is easy and already formatted for us, just echo the log
    type(wsim_event_filename);
    
    % And load the plot data if it's there
    event_plot_file = fullfile(dir, 'event_plot_data.mat');
    if exist(event_plot_file, 'file')
        load(event_plot_file);
        assignin('base', 'event_plot_data', event_plot_data);
    end
else
    % Use textscan to load in archive-reader produced event packet CSV
    fid = fopen(hil_fsw_event_filename,'r');
    if fid ~= -1
        event_data = textscan(fid, '%f%u%q%u%u%u%u%q', 'delimiter', ',', 'HeaderLines', 1);
        fclose(fid);
    end

    % Also load in the sim event packets....
    fid = fopen(hil_sim_event_filename,'r');
    if fid ~= -1
        sim_event_data = textscan(fid, '%f%u%q%u%u%u%u%q', 'delimiter', ',', 'HeaderLines', 1);
        
        if ~isempty(sim_event_data)
            % Tack on a SIM indicator so we know who's saying what
            for i=1:length(sim_event_data{3})
                sim_event_data{3}{i} = ['SIM: ' sim_event_data{3}{i}];
            end
        
            if ~isempty(event_data)
                % If there's FSW events, add these in
                event_data = cellfun(@vertcat, event_data, sim_event_data, 'UniformOutput', false);
            elseif ~isempty(sim_event_data)
                % otherwise roll with just this
                event_data = sim_event_data;
            end
        end
        fclose(fid);
    end

    % If we didn't get any events at all, just echo a newline and exit
    if isempty(event_data)
        fprintf(1,'\n');
        return;
    end

    % Sort the events by getting sorted indices of the timestamps
    [~,sorted_indices] = sort(event_data{1});
    event_data = cellfun(@(a) a(sorted_indices), event_data, 'UniformOutput', false);
    
    % Check for a plotting time zero in the workspace
    try
        plotting_time_zero_seconds = evalin('base', 'plotting_time_zero_seconds');
    catch
        warning('No plotting_time_zero_seconds found in workspace, assuming first event is t=0');
        plotting_time_zero_seconds = event_data{1}(1);
    end
    max_time_magnitude = fix(log10(event_data{1}(end)-plotting_time_zero_seconds));

    % Echo out the events in a format similar to what the WSIM produces
    fprintf(1,'\n');
    
    num_plottable_events = 0;
    for i=1:length(event_data{1})
        fprintf(1,['%s (%0' num2str(max_time_magnitude+4) '.2f)  %-10s %3u  %-8s   %-122s\n'], seconds2datestr(event_data{1}(i)), event_data{1}(i)-plotting_time_zero_seconds, event_data{3}{i}, event_data{4}(i), event_types{event_data{5}(i)}, event_data{8}{i});
        event_plot_time = round(event_data{1}(i)-plotting_time_zero_seconds, 2);
        if event_plot_time >= 0
            num_plottable_events = num_plottable_events + 1;
            event_plot_data(num_plottable_events).time = event_plot_time;
            event_plot_data(num_plottable_events).app = event_data{3}{i};
            event_plot_data(num_plottable_events).message = event_data{8}{i};
        end
    end
    
    assignin('base', 'event_plot_data', event_plot_data);
end

fprintf(1,'\n');

end