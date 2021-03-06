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


% set feed pressure for sim here, will get picked up downstream to get fed
% into telemetry

egt_feed_pressure = 700;


load EGC_Throttle_Data;
load EGC_Test_Data_12112014

EGC_Thrust = 4.44822162*EGC_Thrust;
EGC_Mdot = 0.45359237*EGC_Mdot;

% tpl_egc_throttle_to_thrust = [ EGC_ThrottleRatio' EGC_Thrust'];
% tpl_egc_throttle_to_mdot   = [ EGC_ThrottleRatio' EGC_Mdot'];

% tpl_egc_throttle_to_thrust = [EGC_Test_Data_12112014(end:-1:1,1) EGC_Test_Data_12112014(end:-1:1,3)];
% tpl_egc_throttle_to_mdot   = [EGC_Test_Data_12112014(end:-1:1,1) EGC_Test_Data_12112014(end:-1:1,4)];

% tpl_egc_throttle_to_thrust = [0 0; tpl_egc_throttle_to_thrust];
tpl_egc_throttle_to_thrust = [ ...
                                0.0     0        ; ...
                                0.2     1323.761 ; ...
                                0.25	1489.577 ; ...
                                0.3     1630.213 ; ...
                                0.35	1748.769 ; ...
                                0.4     1848.346 ; ...
                                0.45	1932.047 ; ...
                                0.5     2002.973 ; ...
                                0.55	2064.224 ; ...
                                0.6     2118.902 ; ...
                                0.65	2170.108 ; ...
                                0.7     2220.944 ; ...
                                0.75	2274.512 ; ...
                                0.8     2333.911 ; ...
                                0.85	2402.245 ; ...
                                0.9     2482.613 ; ...
                                0.95	2578.118 ; ...
                                1       2691.86  ];

tpl_egc_throttle_to_mdot = [ ...  
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


tpl_egc_chamber_pressure_to_thrust = [ EGC_Pc' EGC_Thrust'];

tpl_egc_throttle_to_thrust_gain = 1.0;
tpl_egc_throttle_to_mdot_gain   = 1.0;

egt_pc_to_thrust_slope = 1.32839171615;
egt_pc_to_thrust_offset = 37.1976248356;

egt_g_times_isp = 120*9.80665;

clear ACS_CatLoad ACS_Isp ACS_Mdot ACS_Pc ACS_Tc ACS_Thrust
clear EGC_CatLoad EGC_Cf EGC_Isp EGC_Mdot EGC_Pc EGC_Tc EGC_ThrottleRatio EGC_Thrust EGC_Test_Data_12112014