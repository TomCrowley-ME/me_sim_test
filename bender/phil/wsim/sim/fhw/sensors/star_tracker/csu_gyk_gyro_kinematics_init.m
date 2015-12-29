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
% csu_gyk_gyro_kinematics_init.m                                          %
%                                                                         %
% 08/05/14                                                                %
%-------------------------------------------------------------------------%


% position of mIRU gyro in body frame
gyk_x =  0.0;
gyk_y =  0.0;
gyk_z =  0.0;

%rotation of mIRU gyro with respect to MIRU frame (order of rotation is x, y, z)
gyk_rotx = 0;
gyk_roty = 0.0;
gyk_rotz = 0*-135*pi/180;

