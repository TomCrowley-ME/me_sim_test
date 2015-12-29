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


csc_lc_limit_check_prep
csc_sc_wsim_stored_command_prep;

csc_cmp_command_mode_process_prep;

csc_cnt_attitude_control_prep;
csc_gdn_guidance_prep;

csc_kfl_kalman_filter_prep;
csc_emp_est_mass_props_prep;
csc_tup_time_update_prep
csu_mkf_multiplicative_update_prep
csc_fcv_filter_convergence_prep
csu_fec_filter_error_check_prep

csu_taf_thruster_arm_fire_prep
