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
% csu_flr_lidar_noise_model_init.m                                        %
%                                                                         %
% 11/12/13                                                                %
%-------------------------------------------------------------------------%

% lidar model types
flr_15k  = 2;
flr_100m = 1;

% rate properties
% lidar running at 5hz : same model for 2k and micro right now
flr_15k_update_time  = 0.2;
flr_100m_update_time = 0.2;

%-------------------------------------------------------------------------%
% 15K MODEL
flr_15k_percent_error = 1/1000; % from flir spec sheet, 1meter (3sig) at 1km, jim requesting more info on degradation w/ alt
flr_15k_percent_error = 0/1000; % from flir spec sheet, 1meter (3sig) at 1km, jim requesting more info on degradation w/ alt
flr_15k_1sig_noise = 1; % Boomer 4/15/2016
flr_15k_resolution = 0.2;

flr_15k_range_min = 25;
flr_15k_range_max = 15000;

%-------------------------------------------------------------------------%
% 100M MODEL
flr_100m_percent_error = 1/1000;
flr_100m_percent_error = 0/1000;
flr_100m_1sig_noise = 0.02;               % 100m Boomer 4/15/2016
flr_100m_resolution = 0.01;

flr_100m_range_min = 0;
flr_100m_range_max = 100;
