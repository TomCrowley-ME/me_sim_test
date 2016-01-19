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
% csc_ldr_flir_lidar_prep.m                                               %
%                                                                         %
% 11/12/13                                                                %
%-------------------------------------------------------------------------%

ldr1_lander_pos = [ldr1_pos_x ldr1_pos_y ldr1_pos_z];
ldr2_lander_pos = [ldr2_pos_x ldr2_pos_y ldr2_pos_z];

ldr1_lander_dcm = rot_angles_to_dcm( [ldr1_lander_rotz ldr1_lander_roty ldr1_lander_rotx] );
ldr2_lander_dcm = rot_angles_to_dcm( [ldr2_lander_rotz ldr2_lander_roty ldr2_lander_rotx] );
