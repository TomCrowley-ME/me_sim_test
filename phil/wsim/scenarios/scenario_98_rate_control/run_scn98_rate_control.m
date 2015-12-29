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
% run_scn3_deorbit_to_landing.m                                          %
%                                                                         %
% 06/06/13                                                                %
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
sim_stop_time = 60*10;

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% simulation init (sets initial conditions and calls FSW init files)
ini_j2000_or_topo = 1; % initialize to J2000 == 1
est_j2000_or_topo = 3; % initialize to deorbit state position, velocity knowledge errors

nimbus_sim_init;

%-----------------------------------------------------------------------%
% Load the scenario
load_scenario('scenario_98','nimbus');


sensor_parameters; %delete later

%-------------------------------------------------------------------------%
% simulation prep (acts on scenario speecific initial conditions )
nimbus_sim_prep;

    %- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - - -%
    % set error state on Kalman filter state wrt true position, in inertial frame
    sim_set_kfl_error_state_init
    sim_set_kfl_error_state_prep
    %- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - - -%

%--------------------------------------------------------------------%
% run simulation

set_param('nimbus','SimulationMode','normal')
sim('nimbus');

%-------------------------------------------------------------------------%
% construct event log from signal data
create_event_log(raw_event_logs, ini_epoch_seconds, fullfile(scenario_data_dir, 'event_log.txt'));

%-------------------------------------------------------------------------%
% plot data

process_test_data(scenario_data_dir);
