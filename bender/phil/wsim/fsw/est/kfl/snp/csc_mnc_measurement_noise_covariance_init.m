%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2010 - 2016 Moon Express, Inc.
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
% csc_mnc_measurement_noise_covariance_init.m                             %
%                                                                         %
% 01/19/16                                                                %
%-------------------------------------------------------------------------%

% altitude-dependent measurements
mnc_meas_noise_alt      = 8000.0;                        % [m]
mnc_meas_noise_alt_gain = [0.2    0.2     1000   1000];
mnc_R_lower_limit_alt   = [0.0001 0.0001  10     10];

% lidar angular rate-dependent measurements
mnc_dtheta_filter_order    = [1      1];
mnc_dtheta_filter_freq     = [0.1    0.1];
mnc_dtheta_filter_coeffs   = [fir1(mnc_dtheta_filter_order(1),mnc_dtheta_filter_freq(1));,...
                              fir1(mnc_dtheta_filter_order(2),mnc_dtheta_filter_freq(2))];
mnc_meas_noise_dtheta      = [4.0    4.0];               % [deg/sec]
mnc_meas_noise_dtheta_gain = [0.0    0.0];
mnc_meas_noise_dtheta_exp  = [11     11];
mnc_R_lower_limit_dtheta   = [0.0001 0.0001];

% lidar parameter switching altitude
mnc_noise_switch_alt          = [9700  10250];           % [m]

% expected nadir angle
mnc_nadir_angle_high          = [70.0  32.0];            % [deg]
mnc_nadir_angle_low           = [ 0.0  65.0];            % [deg]

% lidar angle-dependent measurements
mnc_meas_noise_angle_high     = [180.0 180.0];           % [deg]
mnc_meas_noise_angle_low      = [10.0    0.0];           % [deg]
mnc_meas_noise_angle_gain     = [1.0     1.0];
mnc_meas_noise_angle_exp      = [10      10];
mnc_R_lower_limit_angle       = [0.0001 0.0001];

% NON altitude-dependent measurements
mnc_meas_noise_indep = [ 9e-4 9e-4 9e-4];
