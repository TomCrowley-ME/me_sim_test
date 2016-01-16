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
% csc_snp_sensor_prep_init.m                                              %
%                                                                         %
% 09/28/11                                                                %
%-------------------------------------------------------------------------%


snp_zero_index = zeros(1,kfl_n_meas);

snp_imu_index = [1 2 3 4 5 6];
snp_imu_zero_index = [0 0 0 0 0 0];

snp_rdr_index = [1];
snp_rdr_zero_index = [0];

snp_stg_index = [4 5 6];
snp_stg_zero_index = [0 0 0];

snp_fsp_index = [ 2 3 ];
snp_fsp_zero_index = [ 0 0 ]; 

snp_combustion_delay = 4;

hmg_img1_delay_cnts = round(0.1 / est_time_step);

snp_zero_meas = zeros(kfl_n_meas,1);

% altitude-dependent measurements
snp_meas_noise_alt      = 8000.0;           % [m]
snp_meas_noise_alt_gain = [0.2    1000  1000];
snp_R_lower_limit_alt   = [0.0001   10    10];

% nadir angular rate-dependent measurements
snp_dtheta_filter_order    = 1;
snp_dtheta_filter_freq     = 0.1;
snp_dtheta_filter_coeffs   = fir1(snp_dtheta_filter_order,snp_dtheta_filter_freq);
snp_meas_noise_dtheta      = 4.0;           % [deg/sec]
snp_meas_noise_dtheta_gain = 0.0;
snp_meas_noise_dtheta_exp  = 11;
snp_R_lower_limit_dtheta   = 0.0001;

% nadir angle-dependent measurements
snp_meas_noise_angle      = 10.0;           % [deg]
snp_meas_noise_angle_gain = 1.0;
snp_meas_noise_angle_exp  = 10;
snp_R_lower_limit_angle   = 0.0001;

% NON altitude-dependent measurements
snp_meas_noise_indep = [ 9e-4 9e-4 9e-4];

fsp_camera_alt_cutoff = 5; %stop camera updates at 5m altitude

hmg_nadir_cam_id = uint8( 1 );
hmg_side_cam_id  = uint8( 2 );

% will pick up either earth or moon
egm_mu_central_body = central_body_gravity_mu; %m/(kg*s^2);
