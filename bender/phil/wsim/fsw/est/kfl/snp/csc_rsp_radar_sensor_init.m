%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2010 - 2016 Moon Express, Inc.
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
% csc_rsp_radar_sensor_init.m                                             %
%                                                                         %
% 01/19/16                                                                %
%-------------------------------------------------------------------------%

% lidar1 location
rsp_ldr1_pos_x = 0.549 * cos(pi/4);    
rsp_ldr1_pos_y = 0.549 * sin(pi/4);
rsp_ldr1_pos_z = -0.4451;

% lidar1 orientation : nadir pointing
rsp_ldr1_lander_rotx = 0;
rsp_ldr1_lander_roty = pi;
rsp_ldr1_lander_rotz = 0;

% lidar2 location
rsp_ldr2_pos_x = 0.549 * cos(pi/4);    
rsp_ldr2_pos_y = 0.549 * sin(pi/4);
rsp_ldr2_pos_z = -0.4451;

% lidar2 orientation : canted from nadir
rsp_ldr2_lander_rotx = 0;
rsp_ldr2_lander_roty = pi*(180-65)/180;     % 65deg off-nadir
rsp_ldr2_lander_rotz = 0;
