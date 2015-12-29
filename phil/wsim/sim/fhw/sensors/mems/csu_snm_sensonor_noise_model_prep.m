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
% csu_snm_sensonor_noise_model_prep.m                                     %
%                                                                         %
% 01/25/15                                                                %
%-------------------------------------------------------------------------%

snm_gyro_noise_sigma = (snm_gyro_noise_spec*pi/180)/sqrt(3600) / sqrt(snm_dt);

snm_gyro_bias_noise_source = sqrt(2/(snm_dt* snm_correlation_time)) * (snm_gyro_bias_spec*(pi/180)/3600) ;

snm_acel_noise_sigma = (snm_accel_noise_spec/sqrt(3600)) / sqrt(snm_dt);

snm_accel_bias_noise_source = sqrt(2/(snm_dt*snm_correlation_time)) * (snm_accel_bias_spec*9.8/3600);


snm_accel_noise_v = snm_acel_noise_sigma*[1 1 1]; 
snm_gyro_noise_v = snm_gyro_noise_sigma*[1 1 1];  

snm_accel_bias_noise_v = snm_accel_bias_noise_source*[1 1 1]; 
snm_gyro_bias_noise_v  = snm_gyro_bias_noise_source*[1 1 1];

snm_accel_sensitivity = snm_accel_range/32767;
snm_gyro_sensitivity  = snm_gyro_range /32767;

snm_accel_bias_seed_v = [1 2 3];
snm_accel_noise_seed_v = [4 5 6];


snm_gyro_bias_seed_v = [1 2 3];
snm_gyro_noise_seed_v = [4 5 6];

