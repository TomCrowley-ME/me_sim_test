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
% run_scn84_1x_new_range_throw.m                                         %
%                                                                         %
% 04/23/14                                                                %
%-------------------------------------------------------------------------%

close all;
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
sim_stop_time = 40;
sim_stop_time = 200;

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% simulation init (sets initial conditions and calls FSW init files)
ini_j2000_or_topo = 0; % initialize to Topo  == 0
est_j2000_or_topo = 0; % initialize to Landed Phase Estimation Error

mtv1_sim_init;

%-----------------------------------------------------------------------%
% Load the scenario
load_scenario('scenario_84','schooner');

scn84_guidance_tables;

sensor_parameters;

% Set wind speeds to zero
Winds.Speed.Lateral  = zeros(length(Winds.Altitude),1);
Winds.Speed.Vertical = zeros(length(Winds.Altitude),1);

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
plot_data;
