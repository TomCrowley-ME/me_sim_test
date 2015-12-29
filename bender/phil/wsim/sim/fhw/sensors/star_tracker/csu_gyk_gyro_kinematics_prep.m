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
% csu_gyk_gyro_kinematics_prep.m                                          %
%                                                                         %
% 08/05/14                                                                %
%-------------------------------------------------------------------------%

gyk_position= [gyk_x, gyk_y, gyk_z];

gyk_miru_gyro_dcm_in_chu = rot_angles_to_dcm( [gyk_rotz gyk_roty gyk_rotx] );

gyk_miru_gyro_dcm = sta_body_to_head1_dcm * gyk_miru_gyro_dcm_in_chu;

%%%%%%%%%%%%%%% END SCRIPT %%%%%%%%%%%%%%%