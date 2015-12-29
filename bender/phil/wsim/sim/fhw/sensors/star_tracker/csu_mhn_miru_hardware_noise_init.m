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
% csu_mhn_miru_hardware_noise_init.m                                      %
%                                                                         %
% 08/05/14                                                                %
%-------------------------------------------------------------------------%

mhn_three_axis_index = [1 3 2];

% accuracy and update parameters %% fix this sensitivity so it makes sense
% in an int16
mhn_accel_sensitivity= (2.77e-4 * 9.81);  %2.77e-4 G  converted to m/s^2
mhn_gyro_sensitivity =  (8.75e-3)*pi/180;  %8.75e-3 deg per sec converted to rad/s
mhn_accel_range = 2*9.81;   % 2 g's in m/s^2
mhn_gyro_range = 250*pi/180;  %250 deg/s in rad/s

% don't have miru values for these, using old ln200 value
mhn_correlation_time = 100; % sec
mhn_dt = sim_time_step_size;

%-------------------------------------------------------------------------%
% rate

 % ESC: reducing noise on gyro since differential accel model is not in there yet
    mhn_gyro_noise_spec = 0.5*(30e-3); %deg/sqrt(sec), don't know if this is tied to attitude performance
    mhn_gyro_bias_spec =  4; %deg/hr (don't know correlation time), don't know if this is tied to attitude performance
    mhn_gyro_SF = 100/1e6;  % don't know this for MIRU

    % mhn_gyro_g_sensitive = 0.05; % arsec/sec/g
    % mhn_gyro_vibe_sensitive = 0.1; %arcsecond/second/g^2

    % DO NOT HAVE MIRU NUMBERS FOR THIS
    mhn_gyro_g_sensitive = 2.471e-08 * [1 1 1]'; % rad/sec / (m/s^2)
    mhn_gyro_vibe_sensitive = 5.04e-09 * [1 1 1]'; % rad/sec / (m/s^2)
    
    mhn_gyro_bias_v = [0, 0, 0];
    mhn_gyro_seed_v = [4, 60, 600];
    mhn_gyro_bias_bias_v = [0, 0, 0];
    mhn_gyro_bias_seed_v = [4, 60, 600];

%-------------------------------------------------------------------------%
% accel

    mhn_accel_noise_spec = 30e-6;  % 30 microG/sqrt(hz)
    mhn_accel_bias_spec =  0.7/9.8; % 0.7 m/s/hour
    mhn_accel_SF = 300/1e6; % don't know this for MIRU
    
    mhn_accel_bias_v = [0, 0, 0, 0, 0, 0, 0, 0];
    mhn_accel_seed_v = [20, 30, 40, 50, 60, 70, 80, 90];
    mhn_accel_bias_bias_v = [0, 0, 0, 0, 0, 0, 0, 0];
    mhn_accel_bias_seed_v = [21, 31, 41, 51, 61, 71, 81, 91];


%-------------------------------------------------------------------------%
% Noise settings 
    mhn_accel_noise_on = 1;  % 1 - ON, 0 - OFF 
    mhn_gyro_noise_on  = 1;  % 1 - ON, 0 - OFF

    mhn_accel_bias_noise_on = 1;  % 1 - ON, 0 - OFF   
    mhn_gyro_bias_noise_on   = 1;  % 1 - ON, 0 - OFF
        

