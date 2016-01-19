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
% csc_rsp_radar_sensor_prep.m                                             %
%                                                                         %
% 01/19/16                                                                %
%-------------------------------------------------------------------------%

rsp_ldr1_lander_pos = [rsp_ldr1_pos_x rsp_ldr1_pos_y rsp_ldr1_pos_z];
rsp_ldr2_lander_pos = [rsp_ldr2_pos_x rsp_ldr2_pos_y rsp_ldr2_pos_z];

rsp_ldr1_lander_dcm = rot_angles_to_dcm( [rsp_ldr1_lander_rotz rsp_ldr1_lander_roty rsp_ldr1_lander_rotx] );
rsp_ldr2_lander_dcm = rot_angles_to_dcm( [rsp_ldr2_lander_rotz rsp_ldr2_lander_roty rsp_ldr2_lander_rotx] );
