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
% mtv1_sim_init.m                                                         %
%                                                                         %
% simulation (GSSE) and software (OFSW) initialization files              %
% 11/13/12                                                                %
%-------------------------------------------------------------------------%



sim_time_step_size = 1/100;    % sets simulation step size in model config params


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sim
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
csu_ini_initial_conditions_init;

csu_int_integrator_init;
csu_mpl_mass_properties_mtv_init;

csu_tpl_thruster_propellant_mtv_init;
csu_tfl_thruster_forces_mtv_init;
csu_tdl_thruster_dynamics_mtv_init;

csc_egt_egc_thruster_init;

csc_pwr_power_system_sim_init
csc_swm_switch_state_model_init

csu_grs_gravity_r_squared_init;
csu_gsh_gravity_spherical_harmonic_init;

csu_imk_imu_kinematics_init
csu_mnm_mems_noise_model_init
csc_mum_mems_unit_model_init

csc_sei_sensonor_external_imu_init
csu_snm_sensonor_noise_model_init

csc_ldr_flir_lidar_init
csu_flr_lidar_noise_model_init

csc_gps_piksi_model_init

csc_cam_camera_system_init
csu_fpt_feature_point_init

csc_sta_star_tracker_init
csu_lak_linear_accel_kinematics_init
csu_gyk_gyro_kinematics_init
csu_mhn_miru_hardware_noise_init

csu_eph_spice_init
csu_prb_orbit_perturbations_init

csu_afm_aerodynamics_init;
csu_slh_slosh_init;
csu_tfm_tether_model_init;

csc_thm_thermal_system_sim_init
csc_stm_simplified_temperature_model_init
csc_prs_pressure_system_sim_init

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Flight softwre
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
csci_fsw_mtv_init;

