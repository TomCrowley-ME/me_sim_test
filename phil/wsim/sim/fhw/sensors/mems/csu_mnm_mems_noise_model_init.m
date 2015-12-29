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
% csu_mnm_mems_noise_model_init.m                                         %
%                                                                         %
% 08/15/14                                                                %
%-------------------------------------------------------------------------%

% accuracy and update parameters %% fix this sensitivity so it makes sense
% in an int16
mnm_accel_range = 16*9.81;   % 2 g's in m/s^2
mnm_gyro_range = 250*pi/180;  %250 deg/s in rad/s

% don't have miru values for these, using old ln200 value
mnm_correlation_time = 100; % sec
mnm_dt = sim_time_step_size;

%-------------------------------------------------------------------------%
% rate

 % ESC: reducing noise on gyro since differential accel model is not in there yet
    mnm_gyro_noise_spec = 0.15; %deg/sqrt(sec), don't know if this is tied to attitude performance
    mnm_gyro_bias_spec =  8; %deg/hr (don't know correlation time), don't know if this is tied to attitude performance
    mnm_gyro_SF = 100/1e6;  % don't know this for MIRU

    % mnm_gyro_g_sensitive = 0.05; % arsec/sec/g
    % mnm_gyro_vibe_sensitive = 0.1; %arcsecond/second/g^2

    % DO NOT HAVE MIRU NUMBERS FOR THIS
    mnm_gyro_g_sensitive = 2.471e-08 * [1 1 1]'; % rad/sec / (m/s^2)
    mnm_gyro_vibe_sensitive = 5.04e-09 * [1 1 1]'; % rad/sec / (m/s^2)
    
    mnm_gyro_bias_v = pi/180 * [-0.2, 0.12, 0.08];
    mnm_gyro_bias_bias_v = [0, 0, 0];

    mnm_thrust_gyro_noise_factor = 25;
%-------------------------------------------------------------------------%
% accel

    mnm_accel_noise_spec = 5*400e-6;  % 30 microG/sqrt(hz)
    mnm_accel_bias_spec =  0.7/9.8; % 0.7 m/s/hour
    mnm_accel_SF = 0*300/1e6; % don't know this for MIRU
    
    mnm_accel_bias_v = [0.1, -0.06, -0.05];
    mnm_accel_bias_bias_v = [0, 0, 0];

    mnm_thrust_accel_noise_factor = 25;
    
    mnm_thrust_accel_bias = [0.003 -0.002 -3.05];

%-------------------------------------------------------------------------%
% Noise settings 
    mnm_accel_noise_on = 1;  % 1 - ON, 0 - OFF 
    mnm_gyro_noise_on  = 1;  % 1 - ON, 0 - OFF

    mnm_accel_bias_noise_on = 1;  % 1 - ON, 0 - OFF   
    mnm_gyro_bias_noise_on   = 1;  % 1 - ON, 0 - OFF
        

