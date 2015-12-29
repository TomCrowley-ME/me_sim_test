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
% csc_fps_feature_sensor_prep_test.m                                      %
%                                                                         %
% unit test                                                               %
% 08/09/12                                                                %
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% init/prep




%-------------------------------------------------------------------------%
% test inputs

load fsp_test_data.mat
t = [0 : length(data.matches)-1]';
n = length(t);

pix_in.time = t;
pix_in.signals.values = randi([0 640],15,2,n);
pix_in.signals.dimensions = [15 2];

match_in.time = t;
match_in.signals.values = data.matches;
match_in.signals.dimensions = [15];

feature_id_in.time = t;
feature_id_in.signals.values = data.ground_point_id;
feature_id_in.signals.dimensions = [15];

ground_points_in.time = t;
ground_points_in.signals.values = cat(2,data.ground_points, zeros(15,1,n));
ground_points_in.signals.dimensions = [15 3];


%-------------------------------------------------------------------------%
% sim

sim('csc_fps_feature_sensor_prep_hrn')


%-------------------------------------------------------------------------%
% process data

