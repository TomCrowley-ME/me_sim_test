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
% csu_taf_thruster_arm_fire.m                                             %
%                                                                         %
% 07/03/14                                                                %
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% % Call test init files 

nimbus_bus_all;
gbl_global_parameters_init;


	% call init files for block in question

	% call supporting init files which are also required
    csc_act_actuator_manager_init

	% define time step parameters (if applicable)
    fsw_dt = 0.1;
   
%-------------------------------------------------------------------------%
% % Call test prep files

	% call prep files for block in question (if applicable)
    csu_taf_thruster_arm_fire_prep
    
	% call supporting prep files which are also required
	

%-------------------------------------------------------------------------%
% % Set test parameters

	sim_dt = fsw_dt;

	t0 = 0;
	tFinal = 100;

	% create time vector for comparison/plotting
	t = [t0 : sim_dt : tFinal]';
	n = length(t);
    

    
%-------------------------------------------------------------------------%
% % load in test data to use as input

%-------------------------------------------------------------------------%
% % assign values to test inputs

	% % use struct input specification
	% variable_structure_in.time = t;
	% variable_structure_in.signals.values = typecast( rand(n,4), [0 255]);
	% variable_structure_in.signals.dimensions = [ 4 ];

	% % ESC: checkout typed/nonfinite inputs
    
    mode_signal = randi(10,n,1);
    
    controller_signal = randi(400,n,1);
    controller_signal( controller_signal < 250 ) = 0;
    
    arm_signal = randi(800,n,4);
    
    mode_in.time               = t;
    mode_in.signals.values     = uint8( mode_signal);
    mode_in.signals.dimensions = [ 1 ];
    
    cnt_active_controller_disable_in.time               = t;
    cnt_active_controller_disable_in.signals.values     = uint32(controller_signal);
    cnt_active_controller_disable_in.signals.dimensions = [ 1 ];

    act_arm_thruster_set_durations_in.time               = t;
    act_arm_thruster_set_durations_in.signals.values     = uint32(arm_signal);
    act_arm_thruster_set_durations_in.signals.dimensions = [ 4 ];

    act_manual_thruster_firing_in.time               = t;
    act_manual_thruster_firing_in.signals.values     = zeros(n, 26, 'uint32');
    act_manual_thruster_firing_in.signals.dimensions = [ 26 ];
    
    act_reset_accumulated_ontime_in.time               = t;
    act_reset_accumulated_ontime_in.signals.values     = zeros(n, 1, 'uint8');
    act_reset_accumulated_ontime_in.signals.dimensions = [ 1 ];

        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
        % not needed for requirements verification, but full bus
        submode_in.time               = t;
        submode_in.signals.values     = zeros(n, 1, 'uint8');
        submode_in.signals.dimensions = [ 1 ];

        hover_enable_in.time               = t;
        hover_enable_in.signals.values     = zeros(n, 1, 'uint8');
        hover_enable_in.signals.dimensions = [ 1 ];

        takeoff_enable_in.time               = t;
        takeoff_enable_in.signals.values     = zeros(n, 1, 'uint8');
        takeoff_enable_in.signals.dimensions = [ 1 ];

        inertial_primary_pointing_cmd_in.time               = t;
        inertial_primary_pointing_cmd_in.signals.values     = zeros(n, 3, 'double');
        inertial_primary_pointing_cmd_in.signals.dimensions = [ 3 ];

        inertial_secondary_pointing_cmd_in.time               = t;
        inertial_secondary_pointing_cmd_in.signals.values     = zeros(n, 3, 'double');
        inertial_secondary_pointing_cmd_in.signals.dimensions = [ 3 ];

        body_secondary_pointing_vector_in.time               = t;
        body_secondary_pointing_vector_in.signals.values     = zeros(n, 3, 'double');
        body_secondary_pointing_vector_in.signals.dimensions = [ 3 ];

        body_primary_pointing_vector_in.time               = t;
        body_primary_pointing_vector_in.signals.values     = zeros(n, 3, 'double');
        body_primary_pointing_vector_in.signals.dimensions = [ 3 ];

        thruster_dv_cmd_in.time               = t;
        thruster_dv_cmd_in.signals.values     = zeros(n, 1, 'double');
        thruster_dv_cmd_in.signals.dimensions = [ 1 ];

        thruster_dur_cmd_in.time               = t;
        thruster_dur_cmd_in.signals.values     = zeros(n, 1, 'single');
        thruster_dur_cmd_in.signals.dimensions = [ 1 ];

        mode_change_counter_in.time               = t;
        mode_change_counter_in.signals.values     = zeros(n, 1, 'uint16');
        mode_change_counter_in.signals.dimensions = [ 1 ];

        mode_change_errors_in.time               = t;
        mode_change_errors_in.signals.values     = zeros(n, 1, 'uint16');
        mode_change_errors_in.signals.dimensions = [ 1 ];

        process_cmds_counter_in.time               = t;
        process_cmds_counter_in.signals.values     = zeros(n, 1, 'uint16');
        process_cmds_counter_in.signals.dimensions = [ 1 ];

        process_cmds_errors_in.time               = t;
        process_cmds_errors_in.signals.values     = zeros(n, 1, 'uint16');
        process_cmds_errors_in.signals.dimensions = [ 1 ];

        burn_type_cmd_in.time               = t;
        burn_type_cmd_in.signals.values     = zeros(n, 1, 'uint8');
        burn_type_cmd_in.signals.dimensions = [ 1 ];

        start_burn_in.time               = t;
        start_burn_in.signals.values     = zeros(n, 1, 'uint8');
        start_burn_in.signals.dimensions = [ 1 ];

        est_ref_frame_in.time               = t;
        est_ref_frame_in.signals.values     = zeros(n, 1, 'uint8');
        est_ref_frame_in.signals.dimensions = [ 1 ];

        acs_thruster_set_in.time               = t;
        acs_thruster_set_in.signals.values     = zeros(n, 1, 'uint8');
        acs_thruster_set_in.signals.dimensions = [ 1 ];

        command_id_in.time               = t;
        command_id_in.signals.values     = zeros(n, 1, 'uint8');
        command_id_in.signals.dimensions = [ 1 ];
    

    
%-------------------------------------------------------------------------%
% % create test comparison outputs

	% all ACS thrusters
    all_acs_armed = [taf_coarse_armed' taf_fine_armed' taf_main_mono_disarmed' taf_main_biprop_disarmed'];
    
    % all thrusters
    all_thrusters_armed = [taf_coarse_armed' taf_fine_armed' taf_main_mono_armed' taf_main_biprop_armed'];
    
    % all ACS thrusters
    all_disarmed = [taf_coarse_disarmed' taf_fine_disarmed' taf_main_mono_disarmed' taf_main_biprop_disarmed'];
    
    % manual 
    expected_manual_arm = [ repmat( act_arm_thruster_set_durations_in.signals.values(:,1), 1, 12) ...
                            repmat( act_arm_thruster_set_durations_in.signals.values(:,2), 1, 12) ...
                            repmat( act_arm_thruster_set_durations_in.signals.values(:,3), 1, 1 ) ...
                            repmat( act_arm_thruster_set_durations_in.signals.values(:,4), 1, 1 ) ];
    


%-------------------------------------------------------------------------%
% run test harness

sim('csu_taf_thruster_arm_fire_hrn')


%-------------------------------------------------------------------------%
% % parse output data

% indices for reqt1 : pointing mode
index1 = find(cnt_active_controller_disable_in.signals.values == 0 & mode_in.signals.values == enum_mode.pointing);
n_index1 = length(index1);

% indices for reqt2 : deltav mode
index2 = find(cnt_active_controller_disable_in.signals.values == 0 & mode_in.signals.values == enum_mode.deltav);
n_index2 = length(index2);

% indices for reqt3 : deorbit mode
index3 = find(cnt_active_controller_disable_in.signals.values == 0 & mode_in.signals.values == enum_mode.deorbit);
n_index3 = length(index3);

% indices for reqt4 : braking mode
index4 = find(cnt_active_controller_disable_in.signals.values == 0 & mode_in.signals.values == enum_mode.braking);
n_index4 = length(index4);

% indices for reqt5 : landing mode
index5 = find(cnt_active_controller_disable_in.signals.values == 0 & mode_in.signals.values == enum_mode.landing);
n_index5 = length(index5);

% indices for reqt6 : safe mode
index6 = find(cnt_active_controller_disable_in.signals.values == 0 & mode_in.signals.values == enum_mode.safe);
n_index6 = length(index6);

% indices for reqt7 : startup mode
index7 = find(cnt_active_controller_disable_in.signals.values == 0 & mode_in.signals.values == enum_mode.startup);
n_index7 = length(index7);

% indices for reqt8 : surface mode
index8 = find(cnt_active_controller_disable_in.signals.values == 0 & mode_in.signals.values == enum_mode.surface);
n_index8 = length(index8);

% indices for reqt9 : safesurface mode
index9 = find(cnt_active_controller_disable_in.signals.values == 0 & mode_in.signals.values == enum_mode.safesurface);
n_index9 = length(index9);

% indices for reqt10
index10 = find(cnt_active_controller_disable_in.signals.values > 0);


%-------------------------------------------------------------------------%
% % apply tests

test1 = all( all( arm_out.Data(index1,:) == repmat(all_acs_armed, n_index1, 1) ) );

test2 = all( all( arm_out.Data(index2,:) == repmat(all_thrusters_armed, n_index2, 1) ) );

test3 = all( all( arm_out.Data(index3,:) == repmat(all_thrusters_armed, n_index3, 1) ) );

test4 = all( all( arm_out.Data(index4,:) == repmat(all_thrusters_armed, n_index4, 1) ) );

test5 = all( all( arm_out.Data(index5,:) == repmat(all_thrusters_armed, n_index5, 1) ) );

test6 = all( all( arm_out.Data(index6,:) == repmat(all_acs_armed, n_index6, 1) ) );

test7 = all( all( arm_out.Data(index7,:) == repmat(all_disarmed, n_index7, 1) ) );

test8 = all( all( arm_out.Data(index8,:) == repmat(all_disarmed, n_index8, 1) ) );

test9 = all( all( arm_out.Data(index9,:) == repmat(all_disarmed, n_index9, 1) ) );

test10 = all( all( arm_out.Data(index10,:) == expected_manual_arm(index10,:) ) );


%-------------------------------------------------------------------------%
% % report/record test results

if test1 
    unit_test_record('pass', 1, 'Pointing thruster arm test passed')
else
    unit_test_record('fail', 1, 'Pointing thruster arm test failed')
end

if test2 
    unit_test_record('pass', 2, 'Deltav thruster arm test passed')
else
    unit_test_record('fail', 2, 'Deltav thruster arm test failed')
end

if test3 
    unit_test_record('pass', 3, 'Deorbit thruster arm test passed')
else
    unit_test_record('fail', 3, 'Deorbit thruster arm test failed')
end

if test4 
    unit_test_record('pass', 4, 'Braking thruster arm test passed')
else
    unit_test_record('fail', 4, 'Braking thruster arm test failed')
end

if test5
    unit_test_record('pass', 5, 'Landing thruster arm test passed')
else
    unit_test_record('fail', 5, 'Landing thruster arm test failed')
end

if test6 
    unit_test_record('pass', 6, 'Safe thruster arm test passed')
else
    unit_test_record('fail', 6, 'Safe thruster arm test failed')
end

if test7 
    unit_test_record('pass', 7, 'Startup thruster arm test passed')
else
    unit_test_record('fail', 7, 'Startup thruster arm test failed')
end

if test8 
    unit_test_record('pass', 8, 'Surface thruster arm test passed')
else
    unit_test_record('fail', 8, 'Surface thruster arm test failed')
end

if test9 
    unit_test_record('pass', 9, 'Safesurface thruster arm test passed')
else
    unit_test_record('fail', 9, 'Safesurface thruster arm test failed')
end

if test10 
    unit_test_record('pass', 10, 'Manual thruster arm test passed')
else
    unit_test_record('fail', 10, 'Manual thruster arm test failed')
end
