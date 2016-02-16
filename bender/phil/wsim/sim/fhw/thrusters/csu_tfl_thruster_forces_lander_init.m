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

% MTV-1 and MX Baseline positions and MTV-1X after
% Thruster 1 Geometry
tfl_thruster1_position    =  [0.6668,-0.0699,0.3378];
tfl_thruster1_position    =  [0.6668,-0.0699,-0.22];
tfl_thruster1_orientation =  [0,0.259,0.966];

% Thruster 2 Geometry
tfl_thruster2_position    =  [0.6668,0,0.3378];
tfl_thruster2_position    =  [0.6668,0,-0.22];
tfl_thruster2_position    =  [0.6668,0,-1.5];  % 3rd stage plus micro lander
tfl_thruster2_position    =  [0.6668,0,-0.50]; % MX-micro
tfl_thruster2_orientation =  [0,0,1];

% Thruster 3 Geometry
tfl_thruster3_position    =  [0.6668,0.0699,0.3378];
tfl_thruster3_position    =  [0.6668,0.0699,-0.22];
tfl_thruster3_orientation =  [0,-0.259,0.966];

% Thruster 4 Geometry
tfl_thruster4_position    =  [0.0699,0.6668,0.3378];
tfl_thruster4_position    =  [0.0699,0.6668,-0.22];
tfl_thruster4_orientation =  [-0.259,0,0.966];

% Thruster 5 Geometry
tfl_thruster5_position    =  [0,0.6668,0.3378];
tfl_thruster5_position    =  [0,0.6668,-1.5];  % 3rd stage plus micro lander
tfl_thruster5_position    =  [0,0.6668,-0.5];  % micro lander
tfl_thruster5_orientation =  [0,0,1];

% Thruster 6 Geometry
tfl_thruster6_position    =  [-0.0699,0.6668,0.3378];
tfl_thruster6_position    =  [-0.0699,0.6668,-0.22];
tfl_thruster6_orientation =  [0.259,0,0.966];

% Thruster 7 Geometry
tfl_thruster7_position    =  [-0.6668,0.0699,0.3378];
tfl_thruster7_position    =  [-0.6668,0.0699,-0.22];
tfl_thruster7_orientation =  [0,0.259,0.966];

% Thruster 8 Geometry
tfl_thruster8_position    =  [-0.6668,0,0.3378];
tfl_thruster8_position    =  [-0.6668,0,-1.5];  % 3rd stage plus micro lander
tfl_thruster8_position    =  [-0.6668,0,-0.5];  % micro lander
tfl_thruster8_orientation =  [0,0,1];

% Thruster 9 Geometry
tfl_thruster9_position    =  [-0.6668,-0.0699,0.3378];
tfl_thruster9_position    =  [-0.6668,-0.0699,-0.22];
tfl_thruster9_orientation =  [0,-0.259,0.966];

% Thruster 10 Geometry
tfl_thruster10_position    =  [-0.0699,-0.6668,0.3378];
tfl_thruster10_position    =  [-0.0699,-0.6668,-0.22];
tfl_thruster10_orientation =  [0.259,0,0.966];

% Thruster 11 Geometry
tfl_thruster11_position    =  [0,-0.6668,0.3378];
tfl_thruster11_position    =  [0,-0.6668,-1.5];  % 3rd stage plus micro lander
tfl_thruster11_position    =  [0,-0.6668,-0.5];  % micro lander
tfl_thruster11_orientation =  [0,0,1];

% Thruster 12 Geometry
tfl_thruster12_position    =  [0.0699,-0.6668,0.3378];
tfl_thruster12_position    =  [0.0699,-0.6668,-0.22];
tfl_thruster12_orientation =  [-0.259,0,0.966];

% Vernier Thrusters

% Thruster 13 Geometry
tfl_thruster13_position    =  [0.6731,0,0.3378];
tfl_thruster13_orientation =  [0,0,-1];

% Thruster 14 Geometry
tfl_thruster14_position    =  [0.6731,0,0.3378];
tfl_thruster14_orientation =  [0,-1,0];

% Thruster 15 Geometry
tfl_thruster15_position    =  [0.6731,0,0.3378];
tfl_thruster15_orientation =  [0,0,1];

% Thruster 16 Geometry
tfl_thruster16_position    =  [0,0.6731,0.3378];
tfl_thruster16_orientation =  [0,0,-1];

% Thruster 17 Geometry
tfl_thruster17_position    =  [0,0.6731,0.3378];
tfl_thruster17_orientation =  [-1,0,0];

% Thruster 18 Geometry
tfl_thruster18_position    =  [0,0.6731,0.3378];
tfl_thruster18_orientation =  [0,0,1];

% Thruster 19 Geometry
tfl_thruster19_position    =  [-0.6731,0,0.3378];
tfl_thruster19_orientation =  [0,0,-1];

% Thruster 20 Geometry
tfl_thruster20_position    =  [-0.6731,0,0.3378];
tfl_thruster20_orientation =  [0,1,0];

% Thruster 21 Geometry
tfl_thruster21_position    =  [-0.6731,0,0.3378];
tfl_thruster21_orientation =  [0,0,1];

% Thruster 22 Geometry
tfl_thruster22_position    =  [0,-0.6731,0.3378];
tfl_thruster22_orientation =  [0,0,-1];

% Thruster 23 Geometry
tfl_thruster23_position    =  [0,-0.6731,0.3378];
tfl_thruster23_orientation =  [1,0,0];

% Thruster 24 Geometry
tfl_thruster24_position    =  [0,-0.6731,0.3378];
tfl_thruster24_orientation =  [0,0,1];

% main thruster

% Thruster 25 Geometry
tfl_thruster25_position    =  [0,0,0.508];
tfl_thruster25_position    =  [0,0,-1.5];   % 3rd stage plus micro lander
tfl_thruster25_position    =  [0,0,-0.508]; % micro lander only
tfl_thruster25_orientation =  [0,0,1.0];

thruster_list = [   tfl_thruster1_orientation/norm(tfl_thruster1_orientation);...
                    tfl_thruster2_orientation/norm(tfl_thruster2_orientation);...
                    tfl_thruster3_orientation/norm(tfl_thruster3_orientation);...
                    tfl_thruster4_orientation/norm(tfl_thruster4_orientation);...
                    tfl_thruster5_orientation/norm(tfl_thruster5_orientation);...
                    tfl_thruster6_orientation/norm(tfl_thruster6_orientation);...
                    tfl_thruster7_orientation/norm(tfl_thruster7_orientation);...
                    tfl_thruster8_orientation/norm(tfl_thruster8_orientation);...
                    tfl_thruster9_orientation/norm(tfl_thruster9_orientation);...
                    tfl_thruster10_orientation/norm(tfl_thruster10_orientation);...
                    tfl_thruster11_orientation/norm(tfl_thruster11_orientation);...
                    tfl_thruster12_orientation/norm(tfl_thruster12_orientation);...
                    tfl_thruster13_orientation/norm(tfl_thruster13_orientation);...
                    tfl_thruster14_orientation/norm(tfl_thruster14_orientation);...
                    tfl_thruster15_orientation/norm(tfl_thruster15_orientation);...
                    tfl_thruster16_orientation/norm(tfl_thruster16_orientation);...
                    tfl_thruster17_orientation/norm(tfl_thruster17_orientation);...
                    tfl_thruster18_orientation/norm(tfl_thruster18_orientation);...
                    tfl_thruster19_orientation/norm(tfl_thruster19_orientation);...
                    tfl_thruster20_orientation/norm(tfl_thruster20_orientation);...
                    tfl_thruster21_orientation/norm(tfl_thruster21_orientation);...
                    tfl_thruster22_orientation/norm(tfl_thruster22_orientation);...
                    tfl_thruster23_orientation/norm(tfl_thruster23_orientation);...
                    tfl_thruster24_orientation/norm(tfl_thruster24_orientation);...
                    tfl_thruster25_orientation/norm(tfl_thruster25_orientation)];
                
tfl_thruster1_orientation = thruster_list(1,:);
tfl_thruster2_orientation = thruster_list(2,:);
tfl_thruster3_orientation = thruster_list(3,:);
tfl_thruster4_orientation = thruster_list(4,:);
tfl_thruster5_orientation = thruster_list(5,:);
tfl_thruster6_orientation = thruster_list(6,:);
tfl_thruster7_orientation = thruster_list(7,:);
tfl_thruster8_orientation = thruster_list(8,:);
tfl_thruster9_orientation = thruster_list(9,:);
tfl_thruster10_orientation = thruster_list(10,:);
tfl_thruster11_orientation = thruster_list(11,:);
tfl_thruster12_orientation = thruster_list(12,:);
tfl_thruster13_orientation = thruster_list(13,:);
tfl_thruster14_orientation = thruster_list(14,:);
tfl_thruster15_orientation = thruster_list(15,:);
tfl_thruster16_orientation = thruster_list(16,:);
tfl_thruster17_orientation = thruster_list(17,:);
tfl_thruster18_orientation = thruster_list(18,:);
tfl_thruster19_orientation = thruster_list(19,:);
tfl_thruster20_orientation = thruster_list(20,:);
tfl_thruster21_orientation = thruster_list(21,:);
tfl_thruster22_orientation = thruster_list(22,:);
tfl_thruster23_orientation = thruster_list(23,:);
tfl_thruster24_orientation = thruster_list(24,:);

if exist('tfl_thruster_egc_orientation')
    tfl_thruster_egc_orientation =thruster_list(25,:);
else
    tfl_thruster25_orientation = thruster_list(25,:);
end
 

%%%%%%%%%%%%%% END SCRIPT %%%%%%%%%%%%%%%
