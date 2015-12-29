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
% overlay_events.m                                                        %
%                                                                         %
% Overlays event information over plots                                   %
% 12/11/14                                                                %
%-------------------------------------------------------------------------%

function overlay_events(varargin)

remove_events = false;
if nargin == 0
    % Assume the first plotted line
    line = 1;
elseif nargin == 1
    if strcmp(varargin{1}, 'off')
        remove_events = true;
    else
        line = varargin{1};
    end
else
    error('Usage: overlay_events([figure list, [line numbers]]');
end

fig = gcf;
fig_children = get(fig, 'Children');
axes = fig_children(strcmp(get(fig_children, 'Type'), 'axes'));
data = get(axes, 'Children');

% Clear out any existing event data
for i=1:length(data)
    if strcmp(get(data(i), 'Tag'), 'events')
        delete(data(i));
        data = get(axes, 'Children');
        break;
    end
end

% If events are requested off, we can stop here
if remove_events
    return;
end

% Load the event plot data
try
    event_plot_data = evalin('base', 'event_plot_data');
catch
    error('No event plot data in the base workspace');
end

% Calculate concurrent events
merged_event_times = unique([event_plot_data.time]', 'stable');

% Data objects are most-recent-first, we're plotting most-recent-last
data_lines = data(~strcmp(get(data, 'Type'), 'patch'));
if line > 0
    line = length(data_lines) - line + 1;
else
    line = -line;
end

% Ascertain line data
xdata = get(data_lines(line), 'XData');
ydata = get(data_lines(line), 'YData');

% Map event times onto the line's indices
[~, target_indices] = arrayfun(@(x) min(abs(xdata-x)), merged_event_times);

% Use those indices to find the line's values at those times
target_values = ydata(target_indices);

% Plot the events over the line
hold on;
h = plot(merged_event_times, target_values, 'rp');
set(h, 'Tag', 'events');

% Update the data cursor callback to ours
dcm = datacursormode(fig);
set(dcm, 'UpdateFcn', @event_dcm_callback);

% Also update already existing data cursors...
for oh=findall(fig, 'type', 'hggroup')
    if isprop(oh, 'UpdateFcn')
        set(oh, 'UpdateFcn', @event_dcm_callback);
        set(oh, 'Visible', 'off');
        set(oh, 'Visible', 'on');
    end
end

end