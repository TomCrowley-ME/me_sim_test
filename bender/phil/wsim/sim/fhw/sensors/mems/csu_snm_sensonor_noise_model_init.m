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
% csu_snm_mems_noise_model_init.m                                         %
%                                                                         %
% 08/15/14                                                                %
%-------------------------------------------------------------------------%

% accuracy and update parameters %% fix this sensitivity so it makes sense
% in an int16
snm_accel_range = 10*9.81;   % 10 g's in m/s^2
snm_gyro_range = 400*pi/180; % 400 deg/s in rad/s

% don't have miru values for these, using old ln200 value
snm_correlation_time = 100; % sec
snm_dt = sim_time_step_size;

%-------------------------------------------------------------------------%
% rate

 % ESC: reducing noise on gyro since differential accel model is not in there yet
    snm_gyro_noise_spec = 50*0.15; %deg/sqrt(hr), 
    snm_gyro_bias_spec =  0.5; %deg/hr (don't know correlation time), 
    snm_gyro_SF = 500/1e6;  

    % snm_gyro_g_sensitive = 0.05; % arsec/sec/g
    % snm_gyro_vibe_sensitive = 0.1; %arcsecond/second/g^2

    % DO NOT HAVE MIRU NUMBERS FOR THIS
    snm_gyro_g_sensitive = 2.471e-08 * [1 1 1]'; % rad/sec / (m/s^2)
    snm_gyro_vibe_sensitive = 5.04e-09 * [1 1 1]'; % rad/sec / (m/s^2)
    
    snm_gyro_bias_v = pi/180 * [-0.2, 0.12, 0.08];
    snm_gyro_bias_bias_v = [0, 0, 0];

    snm_thrust_gyro_noise_factor = 15;
%-------------------------------------------------------------------------%
% accel

    snm_accel_noise_spec = 200*400e-6;  % 30 microG/sqrt(hz)
    snm_accel_bias_spec =  0.7/9.8; % 0.7 m/s/hour
    snm_accel_SF = 300/1e6; 
    
    snm_accel_bias_v = [0.1, -0.06, -0.05];
    snm_accel_bias_bias_v = [0, 0, 0];

    snm_thrust_accel_noise_factor = 15;
    
    snm_thrust_accel_bias = 0*[0.003 -0.002 -0.95];

%-------------------------------------------------------------------------%
% Noise settings 
    snm_accel_noise_on = 1;  % 1 - ON, 0 - OFF 
    snm_gyro_noise_on  = 1;  % 1 - ON, 0 - OFF

    snm_accel_bias_noise_on = 1;  % 1 - ON, 0 - OFF   
    snm_gyro_bias_noise_on   = 1;  % 1 - ON, 0 - OFF
        

