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
% csc_sta_star_tracker_init.m                                             %
%                                                                         %
% 03/28/13                                                                %
%-------------------------------------------------------------------------%

sta_body_to_head1_rotz = 90*pi/180;
sta_body_to_head1_roty =  0*pi/180;
sta_body_to_head1_rotx =  0*pi/180;


% simple error model parameters
sta_angle_std = 0.8 / 1000;
sta_angle_bias = 0;
sta_angle_seed = 987;

% rate (in head frame) past which tracker cannot return
% ESC: increasing to 8 deg/sec to make sure scn98 can estimate attitude, 
% but not necessarily realistic
sta_rate_max = 8*pi/180;


sta_att_update_time = 0.25; %4hz update rate
sta_imu_update_time = 0.10; %10hz update rate




%%%%%%%%%%%%%%% END SCRIPT %%%%%%%%%%%%%%%
