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


%    Acc_t   Decc_t   Tot_t  WayptTopoX  WayptTopoY  WayptTopoZ   dwell_t
tlt_waypoint_hover_translate_table = ...
    [ 4      2       6       0.00        0.00        1.60        3.0;...
      3      3       6       0.00        0.00        0.0         1e12;...
      ];

[tlt_waypoint_hover_translate_table_length, ~] = size(tlt_waypoint_hover_translate_table); 

kp_egc = 1;
kd_egc = 1;
ki_egc = 1;
init_int_egc = .3;

kp_acs = 6.32;
kd_acs = 5.03;
ki_acs = 0;

kp_attitude = 14.2;
kd_attitude = 5.3;
ki_attitude = 15;
attitude_limit = 0.1745;

kp_lateral = .8;
kd_lateral = 1;
ki_lateral = 0;

lateral_control_angle_max = 0.1047;

