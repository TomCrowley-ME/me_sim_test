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

%% Begin lnh init file 
% Dependencies: 
% 
% Source: 
%  ln200 spec sheet
%
%%
%ln200 response numbers
lnh_accel_response_num=[.37057435 .37057435];
lnh_accel_response_den=[1.0 -.258851298];

lnh_gyro_response_num=[.37057435 .37057435];
lnh_gyro_response_den=[1.0 -.258851298];

%ln200 accuracy and update parameters
lnh_accel_sensitivity=.00098;  %100 uG  converted to m/s^2
lnh_gyro_sensitivity = .1/3600*pi/180;  %.1 deg per hour converted to rad/s
lnh_accel_range = 40*9.8;   % 40 g's in m/s^2
lnh_gyro_range = 1000*pi/180;  %1000 deg/s in rad/s

lnh_correlation_time = 100; % sec
lnh_dt = sim_time_step_size;

%-------------------------------------------------------------------------%
% rate

lnh_gyro_noise_spec = 0.07; %deg/sqrt(hr)
lnh_gyro_bias_spec = 1; %deg/hr
lnh_gyro_SF = 100/1e6;

%lnh_gyro_g_sensitive = 0.05; % arsec/sec/g
%lnh_gyro_vibe_sensitive = 0.1; %arcsecond/second/g^2

lnh_gyro_g_sensitive = 2.471e-08 * [1 1 1]'; % rad/sec / (m/s^2)
lnh_gyro_vibe_sensitive = 5.04e-09 * [1 1 1]'; % rad/sec / (m/s^2)

%-------------------------------------------------------------------------%
% accel

lnh_accel_noise_spec = 50e-6;  % 50 microG/sqrt(hz)
lnh_accel_bias_spec = 50e-6;  % 50 microG
lnh_accel_SF = 300/1e6;

%Noise parameters 
lnh_accel_noise_on = 1;  % 1 - ON, 0 - OFF 
lnh_gyro_noise_on   =1;  % 1 - ON, 0 - OFF

lnh_accel_bias_v = [0, 0, 0];
lnh_gyro_bias_v = [0, 0, 0];
lnh_accel_seed_v = [20, 30, 40];
lnh_gyro_seed_v = [4, 60, 600];

lnh_accel_bias_noise_on = 1;  % 1 - ON, 0 - OFF 
lnh_gyro_bias_noise_on   =1;  % 1 - ON, 0 - OFF
lnh_accel_bias_bias_v = [0, 0, 0];
lnh_gyro_bias_bias_v = [0, 0, 0];
lnh_accel_bias_seed_v = [20, 30, 40];
lnh_gyro_bias_seed_v = [4, 60, 600];