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
% csci_fsw_mtv_init.m                                                     %
%                                                                         %
% sofware initialization files (create data structures)                   %
% 07/26/12                                                                %
%-------------------------------------------------------------------------%

fsw_dt = 0.1;

%-------------------------------------------------------------------------%
% cFE TIME init
csu_cfe_cfe_time_init;

%-------------------------------------------------------------------------%
% CI/SC (stored command wsim hackery)
csc_sc_wsim_stored_command_init;
csc_lc_limit_check_init

%-------------------------------------------------------------------------%
% CMP (command and mode processor)
csc_cmp_command_mode_process_init;
csu_cml_command_latch_mtv_init;

% generic prop system paramter init used by all GNC apps
csu_psp_propulstion_system_parameters_mtv_init;

%-------------------------------------------------------------------------%
% GDN (guidance)
csc_gdn_guidance_init;
csu_waypoint_hover_guidance_init;
csc_cac_coarse_acs_cntrl_mtv_init;

%-------------------------------------------------------------------------%
% CNT (attitude control)
csc_cnt_attitude_control_init;

%-------------------------------------------------------------------------%
% EST (navigation)

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

%-------------------------------------------------------------------------%
% ACT (thruster management)
csc_act_actuator_manager_init

%-------------------------------------------------------------------------%
% EGC (earth gravity cancelling)
csc_egc_earth_grv_cancel_init;

%-------------------------------------------------------------------------%
% TCS (thermal control)
csc_tcs_thermal_control_system_mtv_init

