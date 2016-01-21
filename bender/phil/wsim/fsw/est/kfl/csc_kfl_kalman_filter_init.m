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
% csc_kfl_kalman_filter_init.m                                            %
%                                                                         %
% 09/28/11                                                                %
%-------------------------------------------------------------------------%

est_time_step = fsw_dt;

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
%                            State Sizes                                  %
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %

kfl_n_state = 15;
kfl_n_meas  = 7;
kfl_n_sense = 3;

kfl_pos_index       = [1 2 3];
kfl_vel_index       = [4 5 6];
kfl_acc_bias_index  = [7 8 9];
kfl_gibbs_index     = [10 11 12];
kfl_gyro_bias_index = [13 14 15];

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
%                        Measurement Parameters                           %
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %

kfl_use_imu          = 1;
kfl_use_mems         = 0;
kfl_use_range_meas   = 1;
kfl_use_camera_meas  = 1;
kfl_use_tracker_meas = 1;


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
%                            Initital States                              %
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
kfl_position_init  = [0 0 0]' ;
kfl_velocity_init  = [0 0 0]';
kfl_acc_bias_init  = [0 0 0]';
kfl_gibbs_init     = [0 0 0]';
kfl_gyro_bias_init = [0 0 0]'; 

kfl_quat_init  = [0 0 0 1]';
kfl_accel_init = [0 0 0]';
kfl_rate_init  = [ 0 0 0]';

kfl_landed_init = 0;
kfl_convergence_init = 2; % initializing
kfl_altitude_init = 0;

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
%                            Frame Paramters                              %
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %

kfl_central_body_rotation_rate = central_body_rotation_rate;
kfl_central_body_radius = central_body_radius;
kfl_alt_wrt_meanrad = 0;
