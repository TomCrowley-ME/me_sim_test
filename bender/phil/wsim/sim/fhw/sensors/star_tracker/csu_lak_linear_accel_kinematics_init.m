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
% csu_lak_linear_accel_kinematics_init.m                                  %
%                                                                         %
% 08/05/14                                                                %
%-------------------------------------------------------------------------%

% ESC: put in more realistic locations!

lak_miru_chu_location_body = 0*[0.1 0.1 0.4];


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% ACCEL 1 : X & Z

    lak_acc1_position_in_chu = 0*[ +5 -5 0 ] / 100;

    lak_acc1_direction_1_in_chu = [ -1  0   0 ];
    lak_acc1_direction_2_in_chu = [  0  0  +1 ];

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% ACCEL 2 : Y & Z

    lak_acc2_position_in_chu = 0*[ +5 +5 0 ] / 100;

    lak_acc2_direction_1_in_chu = [  0 +1   0 ];
    lak_acc2_direction_2_in_chu = [  0  0  +1 ];


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% ACCEL 3 : X & Z

    lak_acc3_position_in_chu = 0*[ -5 +5 0 ] / 100;

    lak_acc3_direction_1_in_chu = [  0  0  +1 ];
    lak_acc3_direction_2_in_chu = [ +1  0   0 ];


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% ACCEL 4 : Y & Z

    lak_acc4_position_in_chu = 0*[ -5 -5 0 ] / 100;

    lak_acc4_direction_1_in_chu = [  0  -1   0 ];
    lak_acc4_direction_2_in_chu = [  0   0  +1 ];