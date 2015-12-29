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
% csc_sei_sensonor_external_imu_init.m                                    %
%                                                                         %
% 01/25/15                                                               %
%-------------------------------------------------------------------------%


%-------------------------------------------------------------------------%
% SEI

% position of LN200 in body coordinates
sei_imu_x =  0.0;
sei_imu_y =  0.0;
sei_imu_z =  0.0;

% from IMU frame to body (order of rotation is x, y, z)
sei_imu_rotx = 0.0;
sei_imu_roty = 0.0;
sei_imu_rotz = 90*pi/180;