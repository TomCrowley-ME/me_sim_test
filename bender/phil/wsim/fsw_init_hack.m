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
% fsw_init_hack.m                                                         %
%                                                                         %
% Temporary initialization hack for code generation                       %
%                                                                         %
%-------------------------------------------------------------------------%
load_model nimbus;

%-------------------------------------------------------------------------%
% define nonvirtual buses and command/type maps
nimbus_bus_all;
nimbus_commands_all;

%-------------------------------------------------------------------------%
% initialize global parameters & set planet
gbl_global_parameters_init;
central_body_name = 'moon';
set_central_body;

%-------------------------------------------------------------------------%
% set the stop time of the simulation
sim_stop_time = 90;

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% simulation init (sets initial conditions and calls FSW init files)
ini_j2000_or_topo = 0; % initialize to Topo  == 0
est_j2000_or_topo = 0; % initialize to Landed Phase Estimation Error

nimbus_sim_init;

%-----------------------------------------------------------------------%
% Load the scenario
load_scenario('scenario_4','nimbus');
%%
%   Time   PosTopoX PosTopoY PosTopoZ VelTopoX VelTopoY VelTopoZ  Kpx  Kpy  Kpz  Kix    Kiy    Kiz   Kdx    Kdy    Kdz
tlt_takeoff_hover_translate_table =...
    [0.00    0.000   0.000     0.0      0.0     0.0      0.0      0.0  0.0  1.0  0.0    0.0    0.0   0.0    0.0    0.0;...
     5.00    0.000   0.000     0.0      0.0     0.0      3.0      0.0  0.0  0.0  0.0    0.0    0.0   1.0    0.1    5.0;...
     8.00    0.000   0.000    30.0      2.0     0.0      3.0      0.0  0.0  0.0  0.0    0.0    0.0   1.0    0.1    5.0;...
    14.00    0.000   0.000    30.0      2.0     0.0      0.0      0.0  0.0  0.0  0.0    0.0    0.0   1.0    0.1   15.0;...
    23.00    0.000   0.000    30.0      2.0     0.0      0.0      0.0  0.0  1.0  0.0    0.0    0.0   1.0    0.1   15.0;...
    28.00    0.000   0.000    30.0      0.0     0.0      0.0      0.0  0.0  1.0  0.0    0.0    0.0   1.0    0.1   11.0;...
    30.00    0.000   0.000    30.0      0.0     0.0      0.0      0.0  0.0  1.0  0.0    0.0    0.0   1.0    0.1   11.0;...
    35.00    0.000   0.000    30.0      0.0     0.0      0.0      0.0  0.0  0.0  0.0    0.0    0.0   1.5    1.5   10.0;...
    39.00    0.000   0.000    30.0      0.0     0.0      0.0      0.0  0.0  0.0  0.0    0.0    0.0   1.5    1.5   15.0;...
    ];
%   Alt(m) PosTopoX PosTopoY PosTopoZ VelTopoX VelTopoY VelTopoZ  Kpx  Kpy  Kpz  Kix    Kiy    Kiz   Kdx    Kdy    Kdz
tlt_descent_translate_table_descending = ...
 [4000.00    0.000   0.000     0.0      0.0     0.0      0.0      0.0  0.0  0.0  0.0    0.0    0.0   0.0    0.0   0.00;...
  3000.00    0.000   0.000     0.0      0.0     0.0    -70.0      0.0  0.0  0.0  0.0    0.0    0.0   1.2    1.2   0.10;...
  2500.00    0.000   0.000     0.0      0.0     0.0    -70.0      0.0  0.0  0.0  0.0    0.0    0.0   1.2    1.2   1.10;...
   500.00    0.000   0.000     0.0      0.0     0.0    -40.0      0.0  0.0  0.0  0.0    0.0    0.0   1.2    1.2   1.10;...
   100.00    0.000   0.000     0.0      0.0     0.0    -10.0      0.0  0.0  0.0  0.0    0.0    0.0   1.2    1.2   1.10;...
    90.00    0.000   0.000     0.0      0.0     0.0     -9.0      0.0  0.0  0.0  0.0    0.0    0.0   1.2    1.2   1.10;...
    80.00    0.000   0.000     0.0      0.0     0.0     -8.0      0.0  0.0  0.0  0.0    0.0    0.0   1.2    1.2   1.10;...
    70.00    0.000   0.000     0.0      0.0     0.0     -7.0      0.0  0.0  0.0  0.0    0.0    0.0   1.2    1.2   1.10;...
    60.00    0.000   0.000     0.0      0.0     0.0     -6.0      0.0  0.0  0.0  0.0    0.0    0.0   1.2    1.2   1.10;...
    50.00    0.000   0.000     0.0      0.0     0.0     -3.7      0.0  0.0  0.0  0.0    0.0    0.0   1.2    1.2   5.00;...
    40.00    0.000   0.000     0.0      0.0     0.0     -3.7      0.0  0.0  0.0  0.0    0.0    0.0   1.2    1.2   5.00;...
    30.00    0.000   0.000     0.0      0.0     0.0     -3.7      0.0  0.0  0.0  0.0    0.0    0.0   1.2    1.2   5.00;...
    20.00    0.000   0.000     0.0      0.0     0.0     -3.7      0.0  0.0  0.0  0.0    0.0    0.0   1.2    1.2   5.00;...
    10.00    0.000   0.000     0.0      0.0     0.0     -2.0      0.0  0.0  0.0  0.0    0.0    0.0   1.2    1.2   5.00;...
     4.00    0.000   0.000     0.0      0.0     0.0     -1.0      0.0  0.0  0.0  0.0    0.0    0.0   1.2    1.2   5.00;...
     0.00    0.000   0.000     0.0      0.0     0.0     -1.0      0.0  0.0  0.0  0.0    0.0    0.0   1.2    1.2   5.00;...
    ];
tlt_terminal_vertical_vel_zero_mean_bias =  0.00;  % Approach in flight


sensor_parameters;

%-------------------------------------------------------------------------%
% simulation prep (acts on scenario speecific initial conditions )
nimbus_sim_prep;

    %- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - - -%
    % set error state on Kalman filter state wrt true position, in inertial frame
    sim_set_kfl_error_state_init
    sim_set_kfl_error_state_prep
    %- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - - -%
