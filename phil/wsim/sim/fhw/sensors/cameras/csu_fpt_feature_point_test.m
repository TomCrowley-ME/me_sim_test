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
% csu_fpt_feature_point_test.m                                            %
%                                                                         %
% unit test                                                               %
% 07/26/12                                                                %
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% init/prep

csc_cam_camera_system_init
csu_fpt_feature_point_init

csc_cam_camera_system_prep


%-------------------------------------------------------------------------%
% set spacecraft pose

lander.T_cam = [0 0 0]';
lander.RS2C = quat2dcm(angle2quat(0,pi,0,'zyx'));

pos = [1 1 10]';
quat = [1 0 0 0];

RW2S = quat2dcm( quat );

T = pos + ( RW2S' * lander.T_cam ) ; % vector to camera, in W
RW2C = RW2S *  lander.RS2C;

camera_pose_C = [ RW2C , - RW2C * T ] ;



%-------------------------------------------------------------------------%
% sim

sim('csu_fpt_feature_point_hrn')


%-------------------------------------------------------------------------%
% process data

