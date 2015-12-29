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
% csc_est_state_estimation_test.m                                         %
%                                                                         %
% To run: save off telem structure (from process_test_data) and save to   %
% someplace on wsim path.                                                 %
%                                                                         %
% Replace line 108:     load your_telem_file_name.mat                     %
% with the real name of a file                                            %
%                                                                         %
% If bus messages change, regenerate using test_bus_input_generate        %
% 12/06/14                                                                %
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% % Call test init files 
mtv_bus_all;
gbl_global_parameters_init;

central_body_name = 'earth';
set_central_body;


	% define time step parameters (if applicable)
    fsw_dt = 0.1;
    sim_time_step_size = 0.01;

	% call init files for block in question

	% call supporting init files which are also required
    
    kfl_topocentric_latitude =   28.635925;
	kfl_topocentric_longitude = -80.708611;

    csc_spc_sensor_processing_mtv_init
    
    csc_kfl_kalman_filter_mtv_init
    
    csu_elk_est_landed_kinematics_mtv_init
    csu_esf_est_switch_frame_init
    csc_emp_est_mass_props_mtv_init
    csc_snp_sensor_prep_mtv_init
    csc_stg_tracker_sensor_prep_init
    csc_ekf_nonlinear_filter_init
    csc_tup_time_update_init
    csu_mup_measurement_update_mtv_init
    csu_mkf_multiplicative_update_init
    csc_fcv_filter_convergence_init
    csu_fec_filter_error_check_init
    
    csu_imk_imu_kinematics_init
    csc_sei_sensonor_external_imu_init
    csu_snm_sensonor_noise_model_init
    csu_mnm_mems_noise_model_init
    csc_mum_mems_unit_model_init
    
    csu_psp_propulstion_system_parameters_mtv_init
    csu_cml_command_latch_mtv_init
    
    csu_cfe_cfe_time_init
    
    csc_egt_egc_thruster_init
    csu_tpl_thruster_propellant_mtv_init
    csu_gsh_gravity_spherical_harmonic_init
    util_frame_rotation_init
    csc_ldr_flir_lidar_init
    csc_cam_camera_system_init
    csc_gps_piksi_model_init
    csu_ini_initial_conditions_init

%-------------------------------------------------------------------------%
% % Call test prep files

	% call prep files for block in question (if applicable)

	% call supporting prep files which are also required
    csc_kfl_kalman_filter_prep;
    csc_emp_est_mass_props_prep;
    csc_tup_time_update_prep
    csu_mkf_multiplicative_update_prep
    csc_fcv_filter_convergence_prep
    csu_fec_filter_error_check_prep

    
    csu_imk_imu_kinematics_prep
    csc_sei_sensonor_external_imu_prep
    csu_snm_sensonor_noise_model_prep
    csu_mnm_mems_noise_model_prep
    csc_mum_mems_unit_model_prep
    
    csu_gsh_gravity_spherical_harmonic_prep
    csu_tpl_thruster_propellant_mtv_prep
    csc_ldr_flir_lidar_prep
    csc_cam_camera_system_prep
    
 
%-------------------------------------------------------------------------%
% % load in test data to use as input
    
    load your_telem_file_name.mat
    
    n_telem_start = 1;
    n_telem_end   = length(telem.est.time);
    
%-------------------------------------------------------------------------%
% % Set test parameters

	sim_dt = fsw_dt;

	t0 = 0;
	tFinal = (n_telem_end-n_telem_start)*0.1;

	% create time vector for comparison/plotting
	t = [t0 : sim_dt : tFinal]';
	n = length(t);
    
    n_telem = n;

%-------------------------------------------------------------------------%
% % assign values to test inputs

	% % use struct input specification
	% variable_structure_in.time = t;
	% variable_structure_in.signals.values = typecast( rand(n,4), [0 255]);
	% variable_structure_in.signals.dimensions = [ 4 ];

    cfe_initial_utc_time = telem.cmp.ccsds_time.Data(1);
    
    kfl_ic = create_inertial_fsw_initial_conditions('earth', seconds2datestr(cfe_initial_utc_time), kfl_topocentric_latitude, kfl_topocentric_longitude, 9.056, [0 0 0]);

    kfl_velocity_init = kfl_ic.velocity' ;
    kfl_position_init = kfl_ic.position' ;

    kfl_state_init = [ kfl_position_init ; kfl_velocity_init ; kfl_acc_bias_init ;  kfl_gibbs_init ;  kfl_gyro_bias_init];

    kfl_quat_init = kfl_ic.quat_eci_to_body;
    

    csc_est_state_estimation_test_init
    
    % % COMMENT OUT FOR COMPLETE HIL/PIL RUNS    
    % force EST to land and rezero
    est_ref_frame_in.signals.values(1:10) = uint8(1);
    est_mtv_reset_topo_position_in.signals.values(21:30) = uint8(1);
    
    % hold off on integration for a few
    est_integrator_override_in.signals.values(:) = uint32(1);
    est_integrator_override_in.signals.values(1:489) = uint32(0);
    est_integrator_override_in.signals.values(788:end) = uint32(0);
    
    % calculate static biases
    est_bias_calc_cycle_in.signals.values(31:210) = uint8(1);

%-------------------------------------------------------------------------%
% % create test comparison outputs

	% % as necessary


%-------------------------------------------------------------------------%
% run test harness

sim('csc_est_state_estimation_hrn')


%-------------------------------------------------------------------------%n
% % parse output data

[ lander_euler_xyz ] = quat2euler(q_out);
lander_euler_xyz = lander_euler_xyz*180/pi;

figure(1); clf
plot(pos_out); grid on;
ylim([-10 10])

figure(2); clf
plot(vel_out); grid on;
ylim([-5 5])

figure(3); clf
plot(mean_accel_out); grid on

figure(4); clf
plot(mean_rate_out); grid on

figure(5); clf
plot(lander_euler_xyz); grid on

link_fig_axes([1:5])



%-------------------------------------------------------------------------%
% % apply tests


%-------------------------------------------------------------------------%
% % report test results


