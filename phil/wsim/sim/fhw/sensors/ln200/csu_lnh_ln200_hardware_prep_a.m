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

%% Begin lnh prep file
%
% Dependencies:
%   csu_lnh_ln200_hardware_init_a.m
%   
%
% Sources:
%   csu_lnh_ln200_hardware_req.html
%
%%  
%

lnh_gyro_noise_spec = (lnh_gyro_noise_spec*pi/180)/sqrt(3600); %rad/sqrt(sec)
lnh_gyro_noise_sigma = lnh_gyro_noise_spec / sqrt(sim_time_step_size);


lnh_gyro_bias_spec = (lnh_gyro_bias_spec*(pi/180)/3600); % rad/sec
lnh_gyro_bias_noise_source = sqrt(2/(sim_time_step_size* lnh_correlation_time)) * lnh_gyro_bias_spec ;

lnh_accel_noise_spec = (lnh_accel_noise_spec*9.8); %m/s^2sqrt(1/sec)
lnh_acel_noise_sigma = lnh_accel_noise_spec / sqrt(sim_time_step_size);

lnh_accel_bias_spec = (lnh_accel_bias_spec*9.8); % m/sec^2
lnh_accel_bias_noise_source = sqrt(2/(sim_time_step_size*lnh_correlation_time)) * lnh_accel_bias_spec;


lnh_accel_noise_v = lnh_acel_noise_sigma*[1 1 1]; %(50 uG)
lnh_gyro_noise_v = lnh_gyro_noise_sigma*[1 1 1];   %.07 deg/sqrt(hr)

lnh_accel_bias_noise_v = lnh_accel_bias_noise_source*[1 1 1]; 
lnh_gyro_bias_noise_v = lnh_gyro_bias_noise_source*[1 1 1];
