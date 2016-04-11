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


%2nd order butter(2,0.01) -3 dB cutoff at 0.01 of sample nyquist frequency (0.5 hz of 50 hz (nyquist of 100 hz sample rate)
imh_accel_response_num=[0.000241359049041961      0.000482718098083923      0.000241359049041961]; 
imh_accel_response_den=[1         -1.95557824031504         0.956543676511203];

imh_gyro_response_num=[0.000241359049041961      0.000482718098083923      0.000241359049041961];
imh_gyro_response_den=[1         -1.95557824031504         0.956543676511203];

%2nd order butter(2,0.1) -3 dB cutoff at 0.1 of sample nyquist frequency (5.0 hz of 50 hz (nyquist of 100 hz sample rate)
imh_accel_response_num=[0.0200833655642113        0.0401667311284225        0.0200833655642113]; 
imh_accel_response_den=[1         -1.56101807580072         0.641351538057563];

imh_gyro_response_num=[0.0200833655642113        0.0401667311284225        0.0200833655642113];
imh_gyro_response_den=[1         -1.56101807580072         0.641351538057563];

%2nd order butter(2,0.90) -3 dB cutoff at 0.90 of sample nyquist frequency (45.0 hz of 50 hz (nyquist of 100 hz sample rate)
imh_accel_response_num=[0.80059240346457          1.60118480692914          0.80059240346457]; 
imh_accel_response_den=[1          1.56101807580072         0.641351538057563];

imh_gyro_response_num=[0.80059240346457          1.60118480692914          0.80059240346457];
imh_gyro_response_den=[1          1.56101807580072         0.641351538057563];

%2nd order butter(2,0.80) -3 dB cutoff at 0.80 of sample nyquist frequency (40.0 hz of 50 hz (nyquist of 100 hz sample rate)
imh_accel_response_num=[0.638945525159022          1.27789105031804         0.638945525159022]; 
imh_accel_response_den=[1           1.1429805025399         0.412801598096189];

imh_gyro_response_num=[0.638945525159022          1.27789105031804         0.638945525159022];
imh_gyro_response_den=[1           1.1429805025399         0.412801598096189];

%2nd order butter(2,0.0.95) -3 dB cutoff at 0.95 of sample nyquist frequency (47.5 hz of 50 hz (nyquist of 100 hz sample rate)
imh_accel_response_num=[0.894858606122573          1.78971721224515         0.894858606122573]; 
imh_accel_response_den=[1          1.77863177782458         0.800802646665708];

imh_gyro_response_num=[0.894858606122573          1.78971721224515         0.894858606122573];
imh_gyro_response_den=[1          1.77863177782458         0.800802646665708];

%2nd order butter(2,0.80) -3 dB cutoff at 0.80 of sample nyquist frequency (40.0 hz of 50 hz (nyquist of 100 hz sample rate)
imh_accel_response_num=[0.638945525159022          1.27789105031804         0.638945525159022]; 
imh_accel_response_den=[1           1.1429805025399         0.412801598096189];

imh_gyro_response_num=[0.638945525159022          1.27789105031804         0.638945525159022];
imh_gyro_response_den=[1           1.1429805025399         0.412801598096189];

%2nd order butter(2,0.0.20) -3 dB cutoff at 0.20 of sample nyquist frequency (10.0 hz of 50 hz (nyquist of 100 hz sample rate)
imh_accel_response_num=[0.0674552738890719         0.134910547778144        0.0674552738890719]; 
imh_accel_response_den=[1          -1.1429805025399         0.412801598096189];

imh_gyro_response_num=[0.0674552738890719         0.134910547778144        0.0674552738890719];
imh_gyro_response_den=[1          -1.1429805025399         0.412801598096189];

%2nd order butter(2,0.0.60) -3 dB cutoff at 0.60 of sample nyquist frequency (30.0 hz of 50 hz (nyquist of 100 hz sample rate)
imh_accel_response_num=[0.391335772501769         0.782671545003537         0.391335772501769]; 
imh_accel_response_den=[1         0.369527377351241         0.195815712655833];

imh_gyro_response_num=[0.391335772501769         0.782671545003537         0.391335772501769];
imh_gyro_response_den=[1         0.369527377351241         0.195815712655833];

% Turn off filter
imh_accel_response_num = 1;
imh_gyro_response_num = 1;
imh_accel_response_den = 1;
imh_gyro_response_den = 1;

mhn_three_axis_index = [1 3 2];

% accuracy and update parameters %% fix this sensitivity so it makes sense
% in an int16
mhn_accel_sensitivity= (2.77e-4 * 9.81);  %2.77e-4 G  converted to m/s^2
mhn_gyro_sensitivity =  (8.75e-3)*pi/180;  %8.75e-3 deg per sec converted to rad/s
mhn_accel_range = 2*9.81;   % 2 g's in m/s^2
mhn_accel_range = 3*9.81;   % 3 g's in m/s^2 - 01/22/2016 based on 40 kg lander with 1112 N biprop (250 lbf)
mhn_accel_range = 4*9.81;   % 4 g's in m/s^2 - 03/10/2016 based on 40 kg lander with 1334 N biprop (300 lbf)
mhn_gyro_range = 250*pi/180;  %250 deg/s in rad/s

% don't have miru values for these, using old ln200 value
mhn_correlation_time = 100; % sec
mhn_dt = sim_time_step_size;

%-------------------------------------------------------------------------%
% rate

 % ESC: reducing noise on gyro since differential accel model is not in there yet
    mhn_gyro_noise_spec = 0.03; %deg/sqrt(sec), SDI500
    mhn_gyro_noise_spec = 0.5*(30e-3); %deg/sqrt(sec), MIRU 
    mhn_gyro_noise_spec = 0.15/60; %deg/sqrt(sec), STIM-300 0.15 deg/sqrt(hr)

    mhn_gyro_bias_spec =  10; %deg/hr SDI500
    mhn_gyro_bias_spec =  4; %deg/hr MIRU
    mhn_gyro_bias_spec =  0.5; %deg/hr STIM-300

    mhn_gyro_SF = 500/1e6;  % STIM-300 +/-500 ppm

    % mhn_gyro_g_sensitive = 0.05; % arsec/sec/g
    % mhn_gyro_vibe_sensitive = 0.1; %arcsecond/second/g^2

    % DO NOT HAVE MIRU NUMBERS FOR THIS
    mhn_gyro_g_sensitive = 1*(pi/180)*(1/9.8) * [1 1 1]'; % STIM-300 (1 deg/g) rad/sec / (m/s^2)
    mhn_gyro_vibe_sensitive = 0.12*(pi/180) * [1 1 1]'; % STIM-300 (0.12 deg/hr/ g^2rms at 2000 hz) rad/sec / (m/s^2)^2
    mhn_gyro_g_sensitive = 2.471e-08 * [1 1 1]'; % rad/sec / (m/s^2)
    mhn_gyro_vibe_sensitive = 5.04e-09 * [1 1 1]'; % rad/sec / (m/s^2)
    
    mhn_gyro_bias_v = [0, 0, 0];
    mhn_gyro_seed_v = [4, 60, 600];
    mhn_gyro_bias_bias_v = [0, 0, 0];
    mhn_gyro_bias_seed_v = [4, 60, 600];

%-------------------------------------------------------------------------%
% accel

    mhn_accel_noise_spec = 200e-6;  % g/sqrt(hz) SDI500
    mhn_accel_noise_spec = 30e-6;  % g/sqrt(hz) MIRU
    mhn_accel_noise_spec = (0.07/3600)/9.8;  % g/sqrt(hz) STIM-300

    mhn_accel_bias_spec =  0.36/9.8; % 0.36 m/s/hour SDI500
    mhn_accel_bias_spec =  0.7/9.8; % 0.7 m/s/hour MIRU
    mhn_accel_bias_spec =  0.05e-3*9.8; % 0.05 (mg over hour)  m/s/hour STIM-300

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
        

