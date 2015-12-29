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
% csc_stg_tracker_sensor_prep_init.m                                      %
%                                                                         %
% 08/08/14                                                                %
%-------------------------------------------------------------------------%

stg_body_to_head1 = [ 0   0   0.707106781186547   0.707106781186548 ];

stg_body_to_head1_dcm = [ 0.0000    1.0000         0 ;
                         -1.0000    0.0000         0 ;
                               0         0    1.0000 ];

stg_miru_gyro_to_body_dcm = [ 0.0000   -1.0000         0 ;
                              1.0000    0.0000         0 ;
                                   0         0    1.0000 ];