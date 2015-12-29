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
% event_dcm_callback.m                                                    %
%                                                                         %
% Data cursor update callback for displaying event data                   %
% 12/11/14                                                                %
%-------------------------------------------------------------------------%

function txt = event_dcm_callback(~, event_obj)

pos = get(event_obj, 'Position');
event_plot_data = evalin('base', 'event_plot_data');

% X info is the same always
txt{1} = ['X: ' num2str(pos(1), 4)];

% Check for the 'events' tag
if strcmp(get(event_obj.Target, 'Tag'), 'events')
    % Find all events for the current time and write them out
    current_events = find(abs([event_plot_data.time] - pos(1)) < 0.005);

    for i=1:length(current_events)
        event_idx = current_events(i);
        txt{i+1} = [event_plot_data(event_idx).app ': ' event_plot_data(event_idx).message];
    end
else
    % Data cursor isn't on event data, fall back to default
    txt{2} = ['Y: ' num2str(pos(2), 4)];
end