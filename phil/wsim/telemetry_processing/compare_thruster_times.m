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
% compare_thruster_times.m                                                %
%                                                                         %
% brings in two data sets into workspace for line by line comparison      %
% 05/01/14                                                                %
%-------------------------------------------------------------------------%

function compare_thruster_times(varargin)

if nargin > 1
    error('compare_thruster_times takes 0 or 1 arguments');
elseif nargin == 1
    % Only argument if present is a list of thrusters to show
    thrusters = varargin{1};
else
    % See if fine thrusters exist -- if not, only do 1-12
    try
        evalin('base','telem.act.fine1_time');
        thrusters = 1:24;
    catch
        thrusters = 1:12;
    end
end

% For data structure purposes we'll assume the full thing -- this will get
% downselected later
num_thrusters = 24;

% Pull our needed information out of the workspace
filtered_transitions = evalin('base', 'truth.thr.transition.Data');
transition_times = evalin('base', 'truth.thr.transition_time.Data');
truth_time = evalin('base', 'truth.thr.Time');
telem_time = evalin('base', 'telem.act.Time');

[num_samples, ~] = size(filtered_transitions);

% Filter out multiple rising transitions, and pulses overlapping with the
% beginning or end of the data
for i=thrusters
    prev_transition = 0;
    prev_index = 0;
    
    for j=1:num_samples
        t = filtered_transitions(j, i);
        if t == 2 && prev_transition == 2
            warning(['Filtering out double rising transition on thruster ' num2str(i)]);
            filtered_transitions(j, i) = 0;
        elseif t == 1 && prev_transition == 1
            warning(['Filtering out double falling transition on thruster ' num2str(i)]);
            filtered_transitions(j, i) = 0;
        elseif t ~= 0 && ~(t == 1 && prev_transition == 0)
            % Ignore falling transitions at the beginning of data
            prev_transition = t;
            prev_index = j;
        end
    end
    
    % Ignore rising transitions at the end of the data
    if prev_transition == 2
        filtered_transitions(prev_index, i) = 0;
    end
end

rising_times = cell(1,num_thrusters);
falling_times = cell(1,num_thrusters);
start_indices = cell(1,num_thrusters);

% Find the rising and falling times for each thruster, and save the index
% of the rising time to mark the start of the pulse
for i=thrusters
    start_indices{i} = find(filtered_transitions(:,i) == 2);
    rising_times{i} = transition_times(start_indices{i}, i);
    falling_times{i} = transition_times(filtered_transitions(:,i) == 1, i);
end

% Calculate on times for each thruster
on_times = cellfun(@minus, falling_times, rising_times, 'UniformOutput', false);

% Build up an on-time timeseries
on_time_data = zeros(num_samples, num_thrusters);
for i=1:num_thrusters
    for j=1:length(on_times{i})
        on_time_data(start_indices{i}(j), i) = on_times{i}(j) * 1000;
    end
end

actual_on_times = timeseries(on_time_data(:,thrusters), truth_time);

% Now build up a similar timeseries for the ACT data
[num_samples, ~] = size(telem_time);
commanded_data = zeros(num_samples, num_thrusters);

for i=thrusters
    if i > 12
        thr_times = evalin('base', sprintf('telem.act.fine%u_time.Data', i-12));
    else
        thr_times = evalin('base', sprintf('telem.act.coarse%u_time.Data', i));
    end
    start_index = 1;
    prev_time = 0;
    
    for j=1:length(thr_times)
        if thr_times(j) ~= 0
            if prev_time == 120
                % If the last cycle was commanded 120, add either the
                % commanded time or 100 (if 120 is commanded again)
                commanded_data(start_index, i) = commanded_data(start_index, i) + min(thr_times(j), 100);
            else
                if thr_times(j) == 120
                    % This pulse might extend more than one cycle, mark its
                    % start
                    start_index = j;
                end
                % Assign the commanded ontime or start the potential
                % accumulated ontime
                commanded_data(j, i) = min(thr_times(j), 100);
            end
        end
         
        prev_time = thr_times(j);
    end
end

commanded_on_times = timeseries(commanded_data(:,thrusters), telem_time);

% Do plotting
selected_coarse_thrusters = find(thrusters <= 12);
selected_fine_thrusters = find(thrusters > 12);

if ~isempty(selected_coarse_thrusters)
    figure('Position', [100 100 700 700]);
    subplot(2,1,1); stem(commanded_on_times.Time, commanded_on_times.Data(:, selected_coarse_thrusters)); 
    title('Commanded Coarse On-Times'); grid on;
    legend(strcat({'Coarse '}, cellfun(@num2str, num2cell(thrusters(selected_coarse_thrusters)), 'UniformOutput', false)),'Location','NorthEastOutside')
    ylabel('duration (msec)','FontName','Courier','FontSize',14)
    xlabel('time (sec)','FontName','Courier','FontSize',14)
    subplot(2,1,2); stem(actual_on_times.Time, actual_on_times.Data(:, selected_coarse_thrusters)); 
    title('Actual Coarse On-Times'); grid on;
    legend(strcat({'Coarse '}, cellfun(@num2str, num2cell(thrusters(selected_coarse_thrusters)), 'UniformOutput', false)),'Location','NorthEastOutside')
    ylabel('duration (msec)','FontName','Courier','FontSize',14)
    xlabel('time (sec)','FontName','Courier','FontSize',14)
    link_fig_axes(gcf, 'xy');
end
if ~isempty(selected_fine_thrusters)
    figure('Position', [100 200 700 800]); 
    subplot(2,1,1); stem(commanded_on_times.Time, commanded_on_times.Data(selected_fine_thrusters)); 
    title('Commanded Fine On-Times'); grid on;
    subplot(2,1,2); stem(actual_on_times.Time, actual_on_times.Data(selected_fine_thrusters));
    legend(strcat({'Fine '}, cellfun(@num2str, num2cell(thrusters(selected_fine_thrusters)), 'UniformOutput', false)),'Location','NorthEastOutside')
    ylabel('duration (msec)','FontName','Courier','FontSize',14)
    xlabel('time (sec)','FontName','Courier','FontSize',14)
    title('Actual Fine On-Times'); grid on;
    legend(strcat({'Fine '}, cellfun(@num2str, num2cell(thrusters(selected_fine_thrusters)), 'UniformOutput', false)),'Location','NorthEastOutside')
    ylabel('duration (msec)','FontName','Courier','FontSize',14)
    xlabel('time (sec)','FontName','Courier','FontSize',14)
    link_fig_axes(gcf, 'xy');
end

assignin('base', 'commanded_on_times', commanded_on_times);
assignin('base', 'actual_on_times', actual_on_times);

end