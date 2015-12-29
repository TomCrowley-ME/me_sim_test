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

% ACS Thrusters
Fa=25.5773;     %BOL
coarse_thr_on_bias = 0.5;

% ECG Thrusters
Fd=2100;   %BOL

%cg
cg=[0, 0, .0967]';   %BOL

%Thrust and Torque
F1 = tfl_thruster1_orientation' * Fa; F2 = tfl_thruster2_orientation' * Fa; F3 = tfl_thruster3_orientation' * Fa;
F4 = tfl_thruster4_orientation' * Fa; F5 = tfl_thruster5_orientation' * Fa; F6 = tfl_thruster6_orientation' * Fa;
F7 = tfl_thruster7_orientation' * Fa; F8 = tfl_thruster8_orientation' * Fa; F9 = tfl_thruster9_orientation' * Fa;
F10 = tfl_thruster10_orientation' * Fa; F11 = tfl_thruster11_orientation' * Fa; F12 = tfl_thruster12_orientation' * Fa;

R1 = tfl_thruster1_position' - cg;R2 = tfl_thruster2_position' - cg;R3 = tfl_thruster3_position' - cg;
R4 = tfl_thruster4_position' - cg;R5 = tfl_thruster5_position' - cg;R6 = tfl_thruster6_position' - cg;
R7 = tfl_thruster7_position' - cg;R8 = tfl_thruster8_position' - cg;R9 = tfl_thruster9_position' - cg;
R10 = tfl_thruster10_position' - cg;R11 = tfl_thruster11_position' - cg;R12 = tfl_thruster12_position' - cg;

T1 = cross(R1,F1);T2 = cross(R2,F2);T3 = cross(R3,F3);   
T4 = cross(R4,F4);T5 = cross(R5,F5);T6 = cross(R6,F6); 
T7 = cross(R7,F7);T8 = cross(R8,F8);T9 = cross(R9,F9); 
T10 = cross(R10,F10);T11 = cross(R11,F11);T12 = cross(R12,F12); 

Tq_mat=[T1 T2 T3 T4 T5 T6 T7 T8 T9 T10 T11 T12]';
Fc_mat=[F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12]';

Thr2TqF = [Tq_mat';
           Fc_mat'];
TqF2Thr = pinv(Thr2TqF);

%Force Application combinations
force_1_to_12 = F1+F2+F3+F4+F5+F6+F7+F8+F9+F10+F11+F12;
force_4_5_6_10_11_12 = F4+F5+F6+F10+F11+F12;
force_1_2_3_7_8_9 = F1+F2+F3+F7+F8+F9;
force_2_8 = F2+F8;
force_5_11 = F5+F11;




