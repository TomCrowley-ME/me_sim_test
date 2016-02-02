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


cac_alpha_gain_biprop_fire = 0.1; % Works for zero CM offset
cac_alpha_gain_coarse_only = 0.5; % Works for zero CM offset

cac_acs_time_gain_x = 20.0;
cac_acs_time_gain_y = 20.0;
cac_acs_time_gain_z = 20.0;

cac_coarse_desired_thrust_gain = 1.0;

cac_max_thrust_to_weight_ratio = 1.05;

cac_rotx_deadband_minus = 0.5*pi/180;
cac_rotx_deadband = 0.5*pi/180;

cac_roty_deadband_minus = 0.5*pi/180;
cac_roty_deadband = 0.5*pi/180;

cac_rotz_deadband_minus = 0.5*pi/180;
cac_rotz_deadband = 0.5*pi/180;

cac_phase_plane_att_limit  = 5*pi/180;
cac_phase_plane_rate_limit = 3*pi/180;

cac_cg_offset_gain_compensation_x = 1*[51 26 23 18 17 14 11 1000 1000 780 0 780 1000 1000 11 14 17 18 23 26 51];
cac_cg_offset_gain_compensation_y = 1*[51 26 23 18 17 14 11 1000 1000 780 0 780 1000 1000 11 14 17 18 23 26 51];

cac_cg_offset_gain_compensation_x = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
cac_cg_offset_gain_compensation_y = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];


cac_delta_factor_all  = [ 0.00 -1.04  3.86;...
                          0.00 -2.00  0.00;...
                          0.00 -1.04 -3.86;...
                          1.04  0.00  3.86;...
                          2.00  0.00  0.00;...
                          1.04  0.00 -3.86;...
                          0.00  1.04  3.86;...
                          0.00  2.00  0.00;...
                          0.00  1.04 -3.86;...
                         -1.04  0.00  3.86;...
                         -2.00  0.00  0.00;...
                         -1.04  0.00 -3.86];  
                     
cac_acs_torque_gain = 0.2; 
cac_acs_minimum_coarse_thruster_ontime = 30; % milliseconds

% Coarse ACS
% +x torque given by: 5    %4,6
% -x torque given by: 11   %10,12
% +y torque given by: 7,8,9
% -y torque given by: 1,2,3
% +z torque given by: 4,10
% -z torque given by: 6,12



% Works for zero CM offset
cac_thruster_alloc_coarse_x_plus  = [4,5,6];
cac_thruster_alloc_coarse_x_minus = [10,11,12];
cac_thruster_alloc_coarse_y_plus  = [7,8,9];
cac_thruster_alloc_coarse_y_minus = [1,2,3];
cac_thruster_alloc_coarse_z_plus  = [1,4,7,10];
cac_thruster_alloc_coarse_z_minus = [3,6,9,12];

cac_thruster_alloc_coarse_x_plus  = [5];
cac_thruster_alloc_coarse_x_minus = [11];
cac_thruster_alloc_coarse_y_plus  = [8];
cac_thruster_alloc_coarse_y_minus = [2];
cac_thruster_alloc_coarse_z_plus  = [4,10];
cac_thruster_alloc_coarse_z_minus = [6,12];

% Works for pure coast on coarse thrusters

cac_thruster_alloc_pad_coarse_x_plus  = [0,0,0,1,1,1,0,0,0,0,0,0];
cac_thruster_alloc_pad_coarse_x_minus = [0,0,0,0,0,0,0,0,0,1,1,1];
cac_thruster_alloc_pad_coarse_y_plus  = [0,0,0,0,0,0,1,1,1,0,0,0];
cac_thruster_alloc_pad_coarse_y_minus = [1,1,1,0,0,0,0,0,0,0,0,0];
cac_thruster_alloc_pad_coarse_z_plus  = [1,0,0,1,0,0,1,0,0,1,0,0];
cac_thruster_alloc_pad_coarse_z_minus = [0,0,1,0,0,1,0,0,1,0,0,1];

cac_thruster_alloc_pad_coarse_x_plus  = [0,0,0,0,1,0,0,0,0,0,0,0];
cac_thruster_alloc_pad_coarse_x_minus = [0,0,0,0,0,0,0,0,0,0,1,0];
cac_thruster_alloc_pad_coarse_y_plus  = [0,0,0,0,0,0,0,1,0,0,0,0];
cac_thruster_alloc_pad_coarse_y_minus = [0,1,0,0,0,0,0,0,0,0,0,0];
cac_thruster_alloc_pad_coarse_z_plus  = [0,0,0,1,0,0,0,0,0,1,0,0];
cac_thruster_alloc_pad_coarse_z_minus = [0,0,0,0,0,1,0,0,0,0,0,1];

% Position enable

cac_thruster_alloc_variable_thrusters_12 = [ 1,1,1,1,1,1,1,1,1,1,1,1];
cac_thruster_alloc_variable_thrusters_10 = [ 1,1,1,1,0,1,1,1,1,1,0,1];
cac_thruster_alloc_variable_thrusters_8  = [ 1,1,1,0,1,0,1,1,1,0,1,0];
cac_thruster_alloc_variable_thrusters_6  = [ 1,0,1,0,1,0,1,0,1,0,1,0];
cac_thruster_alloc_full_on_thrusters_6   = [ 0,1,0,1,0,1,0,1,0,1,0,1];
cac_thruster_alloc_full_on_thrusters_4   = [ 0,0,0,1,0,1,0,0,0,1,0,1];
cac_thruster_alloc_full_on_thrusters_2   = [ 0,1,0,0,0,0,0,1,0,0,0,0];

% New Selection Logic - Adrian Adamson 06/14/2014

cac_thruster_alloc_pad_coarse_x_tq_full_on(1,:) = [0 0 0 0 0 0 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_x_tq_full_on(2,:) = [0 0 0 0 0 0 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_x_tq_full_on(3,:) = [0 0 0 0 1 0 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_x_tq_full_on(4,:) = [0 0 0 0 1 0 0 0 0 0 1 0];
cac_thruster_alloc_pad_coarse_x_tq_full_on(5,:) = [0 0 0 0 0 0 0 0 0 0 1 0];
cac_thruster_alloc_pad_coarse_x_tq_full_on(6,:) = [0 0 0 0 0 0 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_x_tq_full_on(7,:) = [0 0 0 1 0 1 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_x_tq_full_on(8,:) = [0 0 0 0 0 0 0 0 0 1 0 1];
cac_thruster_alloc_pad_coarse_x_tq_full_on(9,:) = [0 0 0 0 0 0 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_x_tq_full_on(10,:)= [0 0 0 0 0 0 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_x_tq_full_on(11,:)= [0 0 0 0 1 0 0 0 0 0 1 0];
cac_thruster_alloc_pad_coarse_x_tq_full_on(12,:)= [0 0 0 1 0 1 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_x_tq_full_on(13,:)= [0 0 0 1 0 1 0 0 0 0 1 0];
cac_thruster_alloc_pad_coarse_x_tq_full_on(14,:)= [0 0 0 0 1 0 0 0 0 1 0 1];
cac_thruster_alloc_pad_coarse_x_tq_full_on(15,:)= [0 0 0 0 0 0 0 0 0 1 0 1];
cac_thruster_alloc_pad_coarse_x_tq_full_on(16,:)= [0 0 0 0 0 0 0 0 0 0 1 0];
cac_thruster_alloc_pad_coarse_x_tq_full_on(17,:)= [0 0 0 0 0 0 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_x_tq_full_on(18,:)= [0 0 0 0 0 0 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_x_tq_full_on(19,:)= [0 0 0 1 0 1 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_x_tq_full_on(20,:)= [0 0 0 1 0 1 0 0 0 1 0 1];
cac_thruster_alloc_pad_coarse_x_tq_full_on(21,:)= [0 0 0 0 0 0 0 0 0 1 0 1];

cac_thruster_alloc_pad_coarse_y_tq_full_on(1,:) = [0 0 0 0 0 0 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_full_on(2,:) = [0 0 0 0 0 0 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_full_on(3,:) = [0 0 0 0 0 0 0 1 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_full_on(4,:) = [0 1 0 0 0 0 0 1 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_full_on(5,:) = [0 1 0 0 0 0 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_full_on(6,:) = [0 0 0 0 0 0 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_full_on(7,:) = [0 0 0 0 0 0 1 0 1 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_full_on(8,:) = [1 0 1 0 0 0 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_full_on(9,:) = [0 0 0 0 0 0 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_full_on(10,:)= [0 0 0 0 0 0 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_full_on(11,:)= [0 0 0 0 0 0 0 1 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_full_on(12,:)= [0 0 0 0 0 0 1 0 1 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_full_on(13,:)= [0 1 0 0 0 0 1 0 1 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_full_on(14,:)= [1 0 1 0 0 0 0 1 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_full_on(15,:)= [1 0 1 0 0 0 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_full_on(16,:)= [0 1 0 0 0 0 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_full_on(17,:)= [0 0 0 0 0 0 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_full_on(18,:)= [0 0 0 0 0 0 0 0 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_full_on(19,:)= [0 0 0 0 0 0 1 0 1 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_full_on(20,:)= [1 0 1 0 0 0 1 0 1 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_full_on(21,:)= [1 0 1 0 0 0 0 0 0 0 0 0];

cac_thruster_alloc_pad_coarse_x_tq_variable(1,:) = [0 0 0 1 1 1 0 0 0 1 1 1];
cac_thruster_alloc_pad_coarse_x_tq_variable(2,:) = [0 0 0 1 0 1 0 0 0 1 0 1];
cac_thruster_alloc_pad_coarse_x_tq_variable(3,:) = [0 0 0 1 0 1 0 0 0 1 0 1];
cac_thruster_alloc_pad_coarse_x_tq_variable(4,:) = [0 0 0 1 0 1 0 0 0 1 0 1];
cac_thruster_alloc_pad_coarse_x_tq_variable(5,:) = [0 0 0 1 0 1 0 0 0 1 0 1];
cac_thruster_alloc_pad_coarse_x_tq_variable(6,:) = [0 0 0 1 1 1 0 0 0 0 1 0];
cac_thruster_alloc_pad_coarse_x_tq_variable(7,:) = [0 0 0 0 1 0 0 0 0 1 1 1];
cac_thruster_alloc_pad_coarse_x_tq_variable(8,:) = [0 0 0 1 1 1 0 0 0 0 1 0];
cac_thruster_alloc_pad_coarse_x_tq_variable(9,:) = [0 0 0 0 1 0 0 0 0 1 1 1];
cac_thruster_alloc_pad_coarse_x_tq_variable(10,:)= [0 0 0 1 0 1 0 0 0 0 1 0];
cac_thruster_alloc_pad_coarse_x_tq_variable(11,:)= [0 0 0 1 0 1 0 0 0 0 1 0];
cac_thruster_alloc_pad_coarse_x_tq_variable(12,:)= [0 0 0 0 1 0 0 0 0 1 0 1];
cac_thruster_alloc_pad_coarse_x_tq_variable(13,:)= [0 0 0 0 1 0 0 0 0 1 0 1];
cac_thruster_alloc_pad_coarse_x_tq_variable(14,:)= [0 0 0 1 0 1 0 0 0 0 1 0];
cac_thruster_alloc_pad_coarse_x_tq_variable(15,:)= [0 0 0 1 0 1 0 0 0 0 1 0];
cac_thruster_alloc_pad_coarse_x_tq_variable(16,:)= [0 0 0 0 1 0 0 0 0 1 0 1];
cac_thruster_alloc_pad_coarse_x_tq_variable(17,:)= [0 0 0 0 1 0 0 0 0 1 0 1];
cac_thruster_alloc_pad_coarse_x_tq_variable(18,:)= [0 0 0 0 1 0 0 0 0 0 1 0];
cac_thruster_alloc_pad_coarse_x_tq_variable(19,:)= [0 0 0 0 1 0 0 0 0 0 1 0];
cac_thruster_alloc_pad_coarse_x_tq_variable(20,:)= [0 0 0 0 1 0 0 0 0 0 1 0];
cac_thruster_alloc_pad_coarse_x_tq_variable(21,:)= [0 0 0 0 1 0 0 0 0 0 1 0];

cac_thruster_alloc_pad_coarse_y_tq_variable(1,:) = [1 1 1 0 0 0 1 1 1 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_variable(2,:) = [1 0 1 0 0 0 1 0 1 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_variable(3,:) = [1 0 1 0 0 0 1 0 1 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_variable(4,:) = [1 0 1 0 0 0 1 0 1 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_variable(5,:) = [1 0 1 0 0 0 1 0 1 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_variable(6,:) = [0 1 0 0 0 0 1 1 1 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_variable(7,:) = [1 1 1 0 0 0 0 1 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_variable(8,:) = [0 1 0 0 0 0 1 1 1 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_variable(9,:) = [1 1 1 0 0 0 0 1 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_variable(10,:)= [0 1 0 0 0 0 1 0 1 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_variable(11,:)= [0 1 0 0 0 0 1 0 1 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_variable(12,:)= [1 0 1 0 0 0 0 1 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_variable(13,:)= [1 0 1 0 0 0 0 1 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_variable(14,:)= [0 1 0 0 0 0 1 0 1 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_variable(15,:)= [0 1 0 0 0 0 1 0 1 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_variable(16,:)= [1 0 1 0 0 0 0 1 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_variable(17,:)= [1 0 1 0 0 0 0 1 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_variable(18,:)= [0 1 0 0 0 0 0 1 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_variable(19,:)= [0 1 0 0 0 0 0 1 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_variable(20,:)= [0 1 0 0 0 0 0 1 0 0 0 0];
cac_thruster_alloc_pad_coarse_y_tq_variable(21,:)= [0 1 0 0 0 0 0 1 0 0 0 0];

% Thrust mpulse in milliseconds for 100 ms minor frame at 50 ms duty cycle 
% and added to any 100 ms full on thrusters
cac_thr_control(1) = 300; % 6 thrusters at 50 ms 
cac_thr_control(2) = 200; % 4 thrusters at 50 ms 
cac_thr_control(3) = 300; % 4 thrusters at 50 ms and 1 thruster at full 100 ms
cac_thr_control(4) = 400; % 
cac_thr_control(5) = 300; % 
cac_thr_control(6) = 200; % 
cac_thr_control(7) = 400; % 
cac_thr_control(8) = 400; % 
cac_thr_control(9) = 200; % 
cac_thr_control(10)= 150; % 
cac_thr_control(11)= 250; % 
cac_thr_control(12)= 350; % 
cac_thr_control(13)= 450; % 
cac_thr_control(14)= 450; % 
cac_thr_control(15)= 350; % 
cac_thr_control(16)= 250; % 
cac_thr_control(17)= 150; % 
cac_thr_control(18)= 100; % 
cac_thr_control(19)= 300; % 
cac_thr_control(20)= 500; % 
cac_thr_control(21)= 300; % 

% Torque Impulse in milliseconds
cac_trq_control(1)  = 0;
cac_trq_control(2)  = 0;
cac_trq_control(3)  = 100;
cac_trq_control(4)  = 0;
cac_trq_control(5)  =-100;
cac_trq_control(6)  = 100;
cac_trq_control(7)  = 100;
cac_trq_control(8)  =-100;
cac_trq_control(9)  =-100;
cac_trq_control(10) = 50;
cac_trq_control(11) = 150;
cac_trq_control(12) = 150;
cac_trq_control(13) = 50;
cac_trq_control(14) =-50;
cac_trq_control(15) =-150;
cac_trq_control(16) =-150;
cac_trq_control(17) =-50;
cac_trq_control(18) = 0;
cac_trq_control(19) = 200;
cac_trq_control(20) = 0;
cac_trq_control(21) =-200;
cac_num_variable(1)     = 6;
cac_num_variable(2:9)   = 4;
cac_num_variable(10:17) = 3;
cac_num_variable(18:21) = 2;









