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

csc_egc_dt = fsw_dt;

egc_pc_proportional_gain = 0.5;
egc_pc_derivative_gain = 0.0;
egc_pc_integral_gain = 2;

% egc_vel_error_gain = [0.0 0.0 0.0 0.0 0.0];

% turning on velocity error feedback using gains from Mark's analysis
% (gnc_status_update_020215 ver2.pptx)
egc_vel_error_gain = 10.0*[0.0338  0.2401  0.4521  0.2401  0.0338];


% % replace with non-truth data at some point
load EGC_Throttle_Data;
load EGC_Test_Data_12112014
% EGC_Thrust = 4.44822162*EGC_Thrust;
% EGC_Mdot = 0.45359237*EGC_Mdot;
% 
% egc_throttle_to_thrust = [flipud(EGC_Test_Data_12112014(:,1)) flipud(EGC_Test_Data_12112014(:,3))];
% egc_throttle_to_mdot = [flipud(EGC_Test_Data_12112014(:,1)) flipud(EGC_Test_Data_12112014(:,4))];
% 
% 
% 
egc_chamber_pressure_to_thrust = [ EGC_Pc' EGC_Thrust'];



clear ACS_CatLoad ACS_Isp ACS_Mdot ACS_Pc ACS_Tc ACS_Thrust
clear EGC_CatLoad EGC_Cf EGC_Isp EGC_Mdot EGC_Pc EGC_Tc EGC_ThrottleRatio EGC_Thrust EGC_Test_Data_12112014

egc_throttle_to_mdot = [ ...  
                          0.0   0.0
                          0.2	1.124884 ; ...
                          0.25	1.265788 ; ...
                          0.3	1.385295 ; ...
                          0.35	1.48604  ; ...
                          0.4	1.570657 ; ...
                          0.45	1.641783 ; ...
                          0.5	1.702053 ; ...
                          0.55	1.754102 ; ...
                          0.6	1.800565 ; ...
                          0.65  1.844079 ; ...
                          0.7	1.887277 ; ...
                          0.75	1.932797 ; ...
                          0.8	1.983273 ; ...
                          0.85	2.04134  ; ...
                          0.9	2.109634 ; ...
                          0.95	2.19079  ; ...
                          1		2.287444 ];
