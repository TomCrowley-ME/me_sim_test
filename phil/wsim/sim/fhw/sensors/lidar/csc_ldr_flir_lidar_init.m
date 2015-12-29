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
% csc_ldr_flir_lidar_init.m                                               %
%                                                                         %
% 11/12/13                                                                %
%-------------------------------------------------------------------------%

%radar location, relative to origin of body coords
ldr_pos_x = 0.549 * cos(pi/4);    
ldr_pos_y = 0.549 * sin(pi/4);
ldr_pos_z = -0.4451;

% % lidar : nadir pointing % %
ldr_lander_rotx = 0;
ldr_lander_roty = pi;
ldr_lander_rotz = 0;

ldr_use_meme_flag = 0;

flr_2k_model = 2;
flr_100m_model = 1;

% %-------------------------------------------------------------------------%
% % % %                           2K LIDARS                             % % %
% %-------------------------------------------------------------------------%
%     
%     %  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -%
%     % % % unit 1 % % %
%     ldr1_pos_x = 0*0.549 * cos(pi/4);    %reference drawing by Earl Daley 
%     ldr1_pos_y = 0*0.549 * sin(pi/4);
%     ldr1_pos_z = 0*-0.4451;
% 
%     ldr1_lander_rotx = 0;
%     ldr1_lander_roty = pi;
%     ldr1_lander_rotz = 0;
%     
%     %  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -%
%     % % % unit 2 % % %
%     ldr2_pos_x = 0*0.549 * cos(pi/4);    %reference drawing by Earl Daley 
%     ldr2_pos_y = 0*0.549 * sin(pi/4);
%     ldr2_pos_z = 0*-0.4451;
% 
%     ldr2_lander_rotx = 0;
%     ldr2_lander_roty = pi;
%     ldr2_lander_rotz = 0;
%     %  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -%
%     
% %-------------------------------------------------------------------------%
% % % %                         100m LIDARS                             % % %
% %-------------------------------------------------------------------------%
%     
%     %  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -%
%     % % % unit 3 % % %
%     ldr3_pos_x = 0*0.549 * cos(pi/4);    %reference drawing by Earl Daley 
%     ldr3_pos_y = 0*0.549 * sin(pi/4);
%     ldr3_pos_z = 0*-0.4451;
% 
%     ldr3_lander_rotx = 0;
%     ldr3_lander_roty = pi;
%     ldr3_lander_rotz = 0;
%     
%     %  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -%
%     % % % unit 4 % % %
%     ldr4_pos_x = 0*0.549 * cos(pi/4);    %reference drawing by Earl Daley 
%     ldr4_pos_y = 0*0.549 * sin(pi/4);
%     ldr4_pos_z = 0*-0.4451;
% 
%     ldr4_lander_rotx = 0;
%     ldr4_lander_roty = pi;
%     ldr4_lander_rotz = 0;
%     %  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -%



ldr_null_meas = -100;




%%%%%%%%%%%%%%% END SCRIPT %%%%%%%%%%%%%%%
