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

% Lander prep files 

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sim
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

csu_ini_initial_conditions_prep;

csu_gsh_gravity_spherical_harmonic_prep;
csu_mpl_mass_properties_lander_prep;

csu_tdl_thruster_dynamics_lander_prep;
csu_tpl_thruster_propellant_lander_prep;
csu_tfl_thruster_forces_lander_prep;

csu_imk_imu_kinematics_prep;
csu_mnm_mems_noise_model_prep
csc_mum_mems_unit_model_prep

csc_ldr_flir_lidar_prep
csu_flr_lidar_noise_model_prep

csc_cam_camera_system_prep

csc_sta_star_tracker_prep
csu_lak_linear_accel_kinematics_prep
csu_gyk_gyro_kinematics_prep
csu_mhn_miru_hardware_noise_prep

csu_eph_spice_prep
csu_prb_orbit_perturbations_prep

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Flight softwre
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
csci_fsw_prep;

% end of script
