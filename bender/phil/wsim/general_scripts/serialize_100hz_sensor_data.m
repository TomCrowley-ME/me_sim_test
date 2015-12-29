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
% serialize_100hz_sensor_data.m                                           %
%                                                                         %
% Transforms 100Hz  sensor data from its 10Hz most-recent-first format    %
% into a new 100Hz timeseries                                             %
% 02/04/15                                                                %
%-------------------------------------------------------------------------%

function new_ts = serialize_100hz_sensor_data(sensor_data)

n_elements = length(sensor_data.Time);

% The incoming data set is Tx(10*N), where T is the number of 10Hz samples
% and N is the number of axes on the sensor. We first need to transform it
% into Tx10xN format, and then horizontally flip it to get the latest
% samples last
mr_last_data = fliplr(reshape(sensor_data.Data, n_elements, 10, []));

% Now that things are in order, we can reshape again to (T*10)xN, with the
% end result being serialized 100Hz data separated into the sensor axes
serialized_data = reshape(mr_last_data, n_elements*10, []);

% Construct the time vector by interpolating the 10Hz time samples into
% 100Hz samples
time = reshape(bsxfun(@minus, repmat(sensor_data.Time, 1, 10), 0.09:-0.01:0), [], 1);

% Finally, put the two together to make a time series
new_ts = timeseries(serialized_data, time);