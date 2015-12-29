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
% run_scn1_approach_to_landing.m                                          %
%                                                                         %
% 02/12/2014                                                              %
%-------------------------------------------------------------------------%

clear all;

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
sim_stop_time = 200;

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% simulation init (sets initial conditions and calls FSW init files)
ini_j2000_or_topo = 0; % initialize sim topocentric phasse ( 1 for inertial )
est_j2000_or_topo = 1; % initialize to Approach Phase Estimation Error
est_j2000_or_topo = 0; % initialize to Approach Phase Estimation Error

nimbus_sim_init;

%-------------------------------------------------------------------------%
% Load the scenario
load_scenario('scenario_1','nimbus');
scn1_guidance_tables;

sensor_parameters;

%-------------------------------------------------------------------------%
% simulation prep (acts on scenario speecific initial conditions )
nimbus_sim_prep;

    %- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - - %
    % set error state on Kalman filter state wrt true position, in inertial frame
    sim_set_kfl_error_state_init
    sim_set_kfl_error_state_prep
    %- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - - %

imh_accel_noise_on      =1;  % 1 - ON, 0 - OFF
imh_gyro_noise_on       =1;  % 1 - ON, 0 - OFF
imh_accel_bias_noise_on =1;  % 1 - ON, 0 - OFF
imh_gyro_bias_noise_on  =1;  % 1 - ON, 0 - OFF

% set_param('nimbus','SimulationMode','RapidAccelerator')

%-------------------------------------------------------------------------%
% run simulation
sim('nimbus');

%-------------------------------------------------------------------------%
% construct event log from signal data
create_event_log(raw_event_logs, ini_epoch_seconds, fullfile(scenario_data_dir, 'event_log.txt'));

%-------------------------------------------------------------------------%
% plot data

process_test_data(scenario_data_dir);
