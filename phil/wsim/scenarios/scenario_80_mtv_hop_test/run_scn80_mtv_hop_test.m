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
% run_scn80_mtv_hop_test.m                                                %
%                                                                         %
% 01/24/14                                                                %
%-------------------------------------------------------------------------%

clear all;

load_model mtv1;

%-------------------------------------------------------------------------%
% define nonvirtual buses and command/type maps
mtv_bus_all;
mtv_commands_all;

%-------------------------------------------------------------------------%
% initialize global parameters & set planet
gbl_global_parameters_init;
central_body_name = 'earth';
set_central_body;

%-------------------------------------------------------------------------%
% set the stop time of the simulation
sim_stop_time = 80;

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% simulation init (sets initial conditions and calls FSW init files)
ini_j2000_or_topo = 0; % initialize to Topo  == 0
est_j2000_or_topo = 0; % initialize to Landed Phase Estimation Error

mtv1_sim_init;

%-----------------------------------------------------------------------%
% Load the scenario
load_scenario('scenario_80','mtv');

    %- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - - -%
%   Vertical Throw Profile
%   Time   PosTopoX PosTopoY PosTopoZ VelTopoX VelTopoY VelTopoZ  Kpx  Kpy  Kpz  Kix  Kiy  Kiz  Kdx  Kdy  Kdz
% tlt_takeoff_hover_translate_table =...
%     [0.00     0.0      0.0     0.0      0.0     0.0      0.0      1.0  1.0  1.0  0.0  0.0  0.0  0.0  0.0  0.0;...
%      0.02     0.0      0.0     0.0      0.0     0.0  10000.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
%      2.00     0.0      0.0     0.0      0.0     0.0  10000.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
%      4.00     0.0      0.0     0.0      0.0     0.0  10000.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
%      6.00     0.0      0.0     0.0      0.0     0.0  10000.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
%      8.00     0.0      0.0     0.0      0.0     0.0  10000.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
%     16.00     0.0      0.0     0.0      0.0     0.0  10000.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
%     35.00     0.0      0.0     0.0      0.0     0.0  10000.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
%     45.00     0.0      0.0     0.0      0.0     0.0  10000.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
%     50.00     0.0      0.0     0.0      0.0     0.0  10000.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
%     ];
%  Throw Down Range Case
%   Time   PosTopoX PosTopoY PosTopoZ VelTopoX VelTopoY VelTopoZ  Kpx  Kpy  Kpz  Kix  Kiy  Kiz  Kdx  Kdy  Kdz
% tlt_takeoff_hover_translate_table =...
%     [0.00     0.0      0.0     0.0      0.0     0.0      0.0      1.0  1.0  1.0  0.0  0.0  0.0  0.0  0.0  0.0;...
%      0.10     0.0      0.0     0.0   1000.0     0.0   1300.0      0.0  0.0  0.0  0.0  0.0  0.0  15.  1.2  15.;...
% %      2.00     0.0      0.0     0.0 300000.0     0.0      5.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
% %      4.00     0.0      0.0     0.0   1000.0     0.0    100.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
% %      6.00     0.0      0.0     0.0   1000.0     0.0    100.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
% %      8.00     0.0      0.0     0.0   1000.0     0.0    100.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
% %     16.00     0.0      0.0     0.0   1000.0     0.0    100.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
% %     35.00     0.0      0.0     0.0   1000.0     0.0    100.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
% %     45.00     0.0      0.0     0.0   1000.0     0.0    100.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
% %     50.00     0.0      0.0     0.0   1000.0     0.0    100.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
%     ];

%   Takeoff Profile
%   Time   PosTopoX PosTopoY PosTopoZ VelTopoX VelTopoY VelTopoZ Kpx   Kpy   Kpz   Kix    Kiy    Kiz   Kdx    Kdy    Kdz
tlt_takeoff_hover_translate_table =...
    [0.00    0.0      0.0      0.0      0.0     0.0      0.0     2.00   2.00  1.0   0.0    0.0    0.0  10.0   10.0    0.0;...
     5.00    0.0      0.0      0.0      0.0     0.0      3.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0   15.0;...
     7.00    0.0      0.0     30.0      0.0     0.0      3.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0   15.0;...
    16.00    0.0      0.0     30.0      0.0     0.0      3.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0   15.0;...
    17.50    0.0      0.0     30.0      0.0     0.0      0.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0    5.0;...
    28.00    0.0      0.0     30.0      0.0     0.0      0.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0    5.0;...
    30.00    0.0      0.0     30.0      0.0     0.0      0.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0    5.0;...
    35.00    0.0      0.0     30.0      0.0     0.0      0.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0    5.0;...
    39.00    0.0      0.0     30.0      0.0     0.0      0.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0    5.0;...
    ];
%   Descent Profile
%   Alt(m) PosTopoX PosTopoY PosTopoZ VelTopoX VelTopoY VelTopoZ Kpx   Kpy   Kpz   Kix    Kiy    Kiz   Kdx    Kdy    Kdz
tlt_descent_translate_table_descending = ...
 [3000.00    0.000   0.000     0.0      0.0     0.0    -70.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0   0.10;...
  2500.00    0.000   0.000     0.0      0.0     0.0    -70.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0   1.10;...
   500.00    0.000   0.000     0.0      0.0     0.0    -40.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0   1.10;...
   100.00    0.000   0.000     0.0      0.0     0.0    -10.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0   1.10;...
    90.00    0.000   0.000     0.0      0.0     0.0     -9.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0   1.10;...
    80.00    0.000   0.000     0.0      0.0     0.0     -8.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0   1.10;...
    70.00    0.000   0.000     0.0      0.0     0.0     -7.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0   1.10;...
    60.00    0.000   0.000     0.0      0.0     0.0     -6.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0   1.10;...
    50.00    0.000   0.000     0.0      0.0     0.0     -3.7     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0   1.00;...
    40.00    0.000   0.000     0.0      0.0     0.0     -4.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0   1.00;...
    30.00    0.000   0.000     0.0      0.0     0.0     -3.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0   1.00;...
    20.00    0.000   0.000     0.0      0.0     0.0     -2.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0   1.00;...
    10.00    0.000   0.000     0.0      0.0     0.0     -1.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0   1.00;...
     0.00    0.000   0.000     0.0      0.0     0.0     -1.0     2.00   2.00  0.0   0.0    0.0    0.0  10.0   10.0   1.00;...
    ];
tlt_terminal_vertical_vel_zero_mean_bias =  0.0;  % Approach in flight


sensor_parameters;

%-------------------------------------------------------------------------%
% simulation prep (acts on scenario speecific initial conditions )
mtv1_sim_prep;

    %- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - - -%
    % set error state on Kalman filter state wrt true position, in inertial frame
    sim_set_kfl_error_state_init
    sim_set_kfl_error_state_prep

%--------------------------------------------------------------------%
% run siumulation
% use_cam = 0;

sim('mtv1');

%-------------------------------------------------------------------------%
% construct event log from signal data
create_event_log(raw_event_logs, ini_epoch_seconds, fullfile(scenario_data_dir, 'event_log.txt'));

%-------------------------------------------------------------------------%
% plot data

process_test_data(scenario_data_dir);
