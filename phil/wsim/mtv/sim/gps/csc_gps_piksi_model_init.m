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
% csc_gps_piksi_model_init.m                                              %
%                                                                         %
% 11/02/14                                                                %
%-------------------------------------------------------------------------%

% making noise/walk worse than current piece of NED test data...
gps_rate_to_noise_std = 20/1000;

gps_noise_seed_number = [89 90 91];
gps_noise_on = 1;

gps_walk_noise_meters_std = 40/1000 * [1 1 1];
gps_walk_bias_meters = 0;
gps_walk_noise_seed_number = [189 190 191];
gps_walk_noise_on = 1;

gps_delay_counts = 5; % delay 50ms, no idea what it really is


gps_base_station_topocentric = [5 10 2];

gps_enu_to_ned_dcm = [  0  1  0 ; ...
                        1  0  0 ; ...
                        0  0 -1 ];

gps_jump_seed = 793;
gps_normal_rv_jump_limit = 30;