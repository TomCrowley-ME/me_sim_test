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

%% Begin imh init file 
% Dependencies: 
% 
% Source: 
%  ln200 spec sheet
%
%%

% %ln200 response numbers
% imh_accel_response_num=[.37057435 .37057435];
% imh_accel_response_den=[1.0 -.258851298];
%  
% imh_gyro_response_num=[.37057435 .37057435];
% imh_gyro_response_den=[1.0 -.258851298];

% miru spec accuracy and update parameters
imh_accel_sensitivity= (2.77e-4 * 9.81);  %2.77e-4 G  converted to m/s^2
imh_gyro_sensitivity = (8.75e-3)*pi/180;  %8.75e-3 deg per sec converted to rad/s
imh_accel_range = 2*9.81;   % 2 g's in m/s^2
imh_gyro_range = 250*pi/180;  %250 deg/s in rad/s

% don't have miru values for these, using old ln200 value
imh_correlation_time = 100; % sec
imh_dt = sim_time_step_size;

%-------------------------------------------------------------------------%
% rate

imh_gyro_noise_spec = (30e-3); %deg/sqrt(sec), don't know if this is tied to attitude performance
imh_gyro_bias_spec = 4; %deg/hr (don't know correlation time), don't know if this is tied to attitude performance
imh_gyro_SF = 100/1e6; % don't know this for MIRU

%imh_gyro_g_sensitive = 0.05; % arsec/sec/g
%imh_gyro_vibe_sensitive = 0.1; %arcsecond/second/g^2

imh_gyro_g_sensitive = 2.471e-08 * [1 1 1]'; % rad/sec / (m/s^2)
imh_gyro_vibe_sensitive = 5.04e-09 * [1 1 1]'; % rad/sec / (m/s^2)

%-------------------------------------------------------------------------%
% accel

% MIRU
imh_accel_noise_spec = 30e-6;  % 30 microG/sqrt(hz)
imh_accel_bias_spec = 277e-6;  % 2.77e-4 G
imh_accel_SF = 300/1e6; % don't konw this for MIRU

%Noise parameters 
imh_accel_noise_on = 1;  % 1 - ON, 0 - OFF 
imh_gyro_noise_on  = 1;  % 1 - ON, 0 - OFF

imh_accel_bias_v = [0, 0, 0];
imh_gyro_bias_v = [0, 0, 0];
imh_accel_seed_v = [20, 30, 40];
imh_gyro_seed_v = [4, 60, 600];

imh_accel_bias_noise_on = 1;  % 1 - ON, 0 - OFF 
imh_gyro_bias_noise_on   =1;  % 1 - ON, 0 - OFF
imh_accel_bias_bias_v = [0, 0, 0];
imh_gyro_bias_bias_v = [0, 0, 0];
imh_accel_bias_seed_v = [20, 30, 40];
imh_gyro_bias_seed_v = [4, 60, 600];
