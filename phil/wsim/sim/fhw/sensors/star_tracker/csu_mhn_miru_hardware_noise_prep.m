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
% csu_mhn_miru_hardware_noise_prep.m                                      %
%                                                                         %
% 08/05/14                                                                %
%-------------------------------------------------------------------------%

mhn_gyro_noise_sigma = (mhn_gyro_noise_spec*pi/180) / sqrt(mhn_dt);

mhn_gyro_bias_noise_source = sqrt(2/(mhn_dt* mhn_correlation_time)) * (mhn_gyro_bias_spec*(pi/180)/3600) ;

mhn_acel_noise_sigma = (mhn_accel_noise_spec*9.8) / sqrt(mhn_dt);

mhn_accel_bias_noise_source = sqrt(2/(mhn_dt*mhn_correlation_time)) * (mhn_accel_bias_spec*9.8/3600);


mhn_accel_noise_v = mhn_acel_noise_sigma*[1 1 1 1 1 1 1 1]; 
mhn_gyro_noise_v = mhn_gyro_noise_sigma*[1 1 1];  

mhn_accel_bias_noise_v = mhn_accel_bias_noise_source*[1 1 1 1 1 1 1 1]; 
mhn_gyro_bias_noise_v  = mhn_gyro_bias_noise_source*[1 1 1];
