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
% scn83_guidance_tables.m                                                 %
%                                                                         %
% 08/27/14                                                                %
%-------------------------------------------------------------------------%
%   Takeoff Profile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tlt_takeoff_hover_translate_table =...
    [0.00     0.0      0.0     0.0      0.0     0.0      0.0      1.0  1.0  1.0  0.0  0.0  0.0  0.0  0.0  0.0;...
     0.10     0.0      0.0     0.0    100.0     0.0     10.0      0.0  0.0  0.0  0.0  0.0  0.0  1.0  1.0  1.0;...
     1.00     0.0      0.0     0.0     40.0     0.0     10.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
     4.00     0.0      0.0     0.0     20.0     0.0     10.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
     6.00     0.0      0.0     0.0     10.0     0.0     30.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
     8.00     0.0      0.0     0.0      5.0     0.0     60.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
    12.00     0.0      0.0     0.0      5.0     0.0     60.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
    16.00     0.0      0.0     0.0      5.0     0.0     80.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
    20.00     0.0      0.0     0.0     30.0     0.0    100.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
    24.00     0.0      0.0     0.0     60.0     0.0    120.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
    28.00     0.0      0.0     0.0     90.0     0.0    140.0      0.0  0.0  0.0  0.0  0.0  0.0  1.2  1.2  15.;...
    ];
%   Descent Profile
%   Alt(m) PosTopoX PosTopoY PosTopoZ VelTopoX VelTopoY VelTopoZ  Kpx  Kpy  Kpz  Kix    Kiy    Kiz   Kdx    Kdy    Kdz
tlt_descent_translate_table_descending = ...
 [3000.00    0.000   0.000     0.0      0.0     0.0    -70.0      0.0  0.0  0.0  0.0    0.0    0.0   0.0    0.0   0.10;...
  2500.00    0.000   0.000     0.0      0.0     0.0    -70.0      0.0  0.0  0.0  0.0    0.0    0.0   0.0    0.0   1.10;...
   500.00    0.000   0.000     0.0      0.0     0.0    -40.0      0.0  0.0  0.0  0.0    0.0    0.0   0.0    0.0   1.10;...
   100.00    0.000   0.000     0.0      0.0     0.0    -10.0      0.0  0.0  0.0  0.0    0.0    0.0   0.0    0.0   1.10;...
    90.00    0.000   0.000     0.0      0.0     0.0     -9.0      0.0  0.0  0.0  0.0    0.0    0.0   0.0    0.0   1.10;...
    80.00    0.000   0.000     0.0      0.0     0.0     -8.0      0.0  0.0  0.0  0.0    0.0    0.0   0.0    0.0   1.10;...
    70.00    0.000   0.000     0.0      0.0     0.0     -7.0      0.0  0.0  0.0  0.0    0.0    0.0   0.1    0.1   1.10;...
    60.00    0.000   0.000     0.0      0.0     0.0     -6.0      0.0  0.0  0.0  0.0    0.0    0.0   0.1    0.1   1.10;...
    50.00    0.000   0.000     0.0      0.0     0.0     -3.7      0.0  0.0  0.0  0.0    0.0    0.0   0.1    0.1   1.00;...
    40.00    0.000   0.000     0.0      0.0     0.0     -4.0      0.0  0.0  0.0  0.0    0.0    0.0   0.1    0.1   1.00;...
    30.00    0.000   0.000     0.0      0.0     0.0     -3.0      0.0  0.0  0.0  0.0    0.0    0.0   0.1    0.1   1.00;...
    20.00    0.000   0.000     0.0      0.0     0.0     -2.0      0.0  0.0  0.0  0.0    0.0    0.0   0.1    0.1   1.00;...
    10.00    0.000   0.000     0.0      0.0     0.0     -1.0      0.0  0.0  0.0  0.0    0.0    0.0   0.1    0.1   1.00;...
    ];
tlt_terminal_vertical_vel_zero_mean_bias =  0.2;  % Approach in flight
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%