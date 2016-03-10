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

% Thruster geometry specification for baseline nimbus lander
% Author: Nilesh V Kulkarni 7/31/13
% 
% ACS Thrusters

%-------------------------------------------------------------------------%
% THRUST PARAMETERS

    % thruster force is from DIY 480 lbf Monoprop
    psp_main_mono_thrust = 2135.1463776;
    psp_main_monoprop_isp = 160;
    
     % thruster force is from DIY 500 lbf Biprop
    psp_main_biprop_thrust = 2224.11081;
    psp_main_biprop_isp   = 310;
    
     % thruster force is from MX-Micro Biprop
    psp_main_biprop_thrust = 1112;
    psp_main_biprop_isp   = 310;

     % thruster force is from MX-Micro Biprop
    psp_main_biprop_thrust = 450;
    psp_main_biprop_isp   = 310;

    % acs thruster data DIY Configuration 10 lbf Coarse
    psp_coarse_acs_thrust = 44.48;
    psp_coarse_acs_isp    = 160;
    psp_coarse_acs_isp    = 280;
    
    % acs HTP monoprop MX-Micro Configuration 6 lbf Coarse
    psp_coarse_acs_thrust = 26.69;
    psp_coarse_acs_isp    = 160;
    
    % acs thruster data DIY Configuration 0.1 N fine
    psp_vernier_acs_thrust = 0.1;
    psp_vernier_acs_isp   = 100;
    

%-------------------------------------------------------------------------%
% SYSTEM GEOMETRY

    % Coarse ACS
    % Thruster 1 Geometry
    psp_thruster1_position    =  [0.6668,-0.0699,0.3378];
    psp_thruster1_orientation =  [0,0.259,0.966];

    % Thruster 2 Geometry
    psp_thruster2_position    =  [0.6668,0,0.3378];
    psp_thruster2_orientation =  [0,0,1];

    % Thruster 3 Geometry
    psp_thruster3_position    =  [0.6668,0.0699,0.3378];
    psp_thruster3_orientation =  [0,-0.259,0.966];

    % Thruster 4 Geometry
    psp_thruster4_position    =  [0.0699,0.6668,0.3378];
    psp_thruster4_orientation =  [-0.259,0,0.966];

    % Thruster 5 Geometry
    psp_thruster5_position    =  [0,0.6668,0.3378];
    psp_thruster5_orientation =  [0,0,1];

    % Thruster 6 Geometry
    psp_thruster6_position    =  [-0.0699,0.6668,0.3378];
    psp_thruster6_orientation =  [0.259,0,0.966];

    % Thruster 7 Geometry
    psp_thruster7_position    =  [-0.6668,0.0699,0.3378];
    psp_thruster7_orientation =  [0,-0.259,0.966];

    % Thruster 8 Geometry
    psp_thruster8_position    =  [-0.6668,0,0.3378];
    psp_thruster8_orientation =  [0,0,1];

    % Thruster 9 Geometry
    psp_thruster9_position    =  [-0.6668,-0.0699,0.3378];
    psp_thruster9_orientation =  [0,0.259,0.966];

    % Thruster 10 Geometry
    psp_thruster10_position    =  [-0.0699,-0.6668,0.3378];
    psp_thruster10_orientation =  [0.259,0,0.966];

    % Thruster 11 Geometry
    psp_thruster11_position    =  [0,-0.6668,0.3378];
    psp_thruster11_orientation =  [0,0,1];

    % Thruster 12 Geometry
    psp_thruster12_position    =  [0.0699,-0.6668,0.3378];
    psp_thruster12_orientation =  [-0.259,0,0.966];

    % Vernier Thrusters

    % Thruster 13 Geometry
    psp_thruster13_position    =  [0.6731,0,0.3378];
    psp_thruster13_orientation =  [0,0,-1];

    % Thruster 14 Geometry
    psp_thruster14_position    =  [0.6731,0,0.3378];
    psp_thruster14_orientation =  [0,-1,0];

    % Thruster 15 Geometry
    psp_thruster15_position    =  [0.6731,0,0.3378];
    psp_thruster15_orientation =  [0,0,1];

    % Thruster 16 Geometry
    psp_thruster16_position    =  [0,0.6731,0.3378];
    psp_thruster16_orientation =  [0,0,-1];

    % Thruster 17 Geometry
    psp_thruster17_position    =  [0,0.6731,0.3378];
    psp_thruster17_orientation =  [-1,0,0];

    % Thruster 18 Geometry
    psp_thruster18_position    =  [0,0.6731,0.3378];
    psp_thruster18_orientation =  [0,0,1];

    % Thruster 19 Geometry
    psp_thruster19_position    =  [-0.6731,0,0.3378];
    psp_thruster19_orientation =  [0,0,-1];

    % Thruster 20 Geometry
    psp_thruster20_position    =  [-0.6731,0,0.3378];
    psp_thruster20_orientation =  [0,1,0];

    % Thruster 21 Geometry
    psp_thruster21_position    =  [-0.6731,0,0.3378];
    psp_thruster21_orientation =  [0,0,1];

    % Thruster 22 Geometry
    psp_thruster22_position    =  [0,-0.6731,0.3378];
    psp_thruster22_orientation =  [0,0,-1];

    % Thruster 23 Geometry
    psp_thruster23_position    =  [0,-0.6731,0.3378];
    psp_thruster23_orientation =  [1,0,0];

    % Thruster 24 Geometry
    psp_thruster24_position    =  [0,-0.6731,0.3378];
    psp_thruster24_orientation =  [0,0,1];

    % main thruster

    % Thruster 25 Geometry
    psp_thruster25_position    =  [0,0,0.508];
    psp_thruster25_orientation =  [0,0,1.0];



%%%%%%%%%%%%%% END SCRIPT %%%%%%%%%%%%%%%
