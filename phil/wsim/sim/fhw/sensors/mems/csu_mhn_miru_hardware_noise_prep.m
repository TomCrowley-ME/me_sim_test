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
% csu_mnm_mems_noise_model_prep.m                                         %
%                                                                         %
% 08/15/14                                                                %
%-------------------------------------------------------------------------%

mnm_gyro_noise_sigma = (mnm_gyro_noise_spec*pi/180) / sqrt(mnm_dt);

mnm_gyro_bias_noise_source = sqrt(2/(mnm_dt* mnm_correlation_time)) * (mnm_gyro_bias_spec*(pi/180)/3600) ;

mnm_acel_noise_sigma = (mnm_accel_noise_spec*9.8) / sqrt(mnm_dt);

mnm_accel_bias_noise_source = sqrt(2/(mnm_dt*mnm_correlation_time)) * (mnm_accel_bias_spec*9.8/3600);


mnm_accel_noise_v = mnm_acel_noise_sigma*[1 1 1 1 1 1 1 1]; 
mnm_gyro_noise_v = mnm_gyro_noise_sigma*[1 1 1];  

mnm_accel_bias_noise_v = mnm_accel_bias_noise_source*[1 1 1 1 1 1 1 1]; 
mnm_gyro_bias_noise_v  = mnm_gyro_bias_noise_source*[1 1 1];
