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
% scn81_guidance_tables.m                                                 %
%                                                                         %
% 11/05/14                                                                %
%-------------------------------------------------------------------------%
%   Takeoff Profile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Alt(m) PosTopoX PosTopoY PosTopoZ VelTopoX VelTopoY VelTopoZ  Kpx   Kpy  Kpz  Kix    Kiy    Kiz   Kdx    Kdy    Kdz
% time-based table
% tlt_takeoff_hover_translate_table = ...
%     [ 0.00   0.000     0.0      0.0      0.0     0.0      0.0      0.030 0.030 0.0  0.0    0.0    0.0  0.020 0.020 0.0;...
%      19.10   0.000     0.000    0.0      0.0     0.0      0.3      0.300 0.300 0.0  0.0    0.0    0.0  1.000 1.000 25.50;...
%      20.20   0.000     0.000    1.0      0.0     0.0      0.3      0.300 0.300 3.0  0.0    0.0    0.0  1.000 1.000 25.50;...
%      20.80   0.000     0.000    1.0      0.0     0.0      0.00     0.300 0.300 0.7  0.0    0.0    0.0  1.000 1.000 25.50;...
%      22.20   0.000     0.000    1.0      0.0     0.0      0.00     0.300 0.300 0.7  0.0    0.0    0.0  1.000 1.000 25.50;...
%     ];
%


% alt-based table
lKp = 0.03; %0.01
lKd = 0.1; %0.03
lKi = 0.02;

%   Alt(m)  PosTopoX   PosTopoY  PosTopoZ VelTopoX VelTopoY VelTopoZ  Kpx    Kpy    Kpz   Kix   Kiy    Kiz   Kdx    Kdy    Kdz
tlt_takeoff_hover_translate_table = ...
    [ 0.00   0.000     0.000     1.5      0.0      0.0      0.2       lKp    lKp    15.0  lKi   lKi    0.0   lKd    lKd    5.0;...
      1.00   0.000     0.000     1.5      0.0      0.0      0.00      lKp    lKp    0.7   lKi   lKi    0.0   lKd    lKd    25.50;...
      3.00   0.000     0.000     1.5      0.0      0.0      0.00      lKp    lKp    0.7   lKi   lKi    0.0   lKd    lKd    25.50;...
      ];
%
%   Descent Profile
%   Alt(m) PosTopoX PosTopoY PosTopoZ VelTopoX VelTopoY VelTopoZ  Kpx   Kpy  Kpz  Kix    Kiy    Kiz   Kdx    Kdy    Kdz
tlt_descent_translate_table_descending = ...
 [3000.00    0.000   0.000     0.0      0.0     0.0    -70.0      0.0   0.0   0.0  0.0    0.0    0.0  10.0   10.0   0.10;...
  2500.00    0.000   0.000     0.0      0.0     0.0    -70.0      0.0   0.0   0.0  0.0    0.0    0.0  10.0   10.0   1.10;...
   500.00    0.000   0.000     0.0      0.0     0.0    -40.0      0.0   0.0   0.0  0.0    0.0    0.0  10.0   10.0   1.10;...
   100.00    0.000   0.000     0.0      0.0     0.0    -10.0      0.0   0.0   0.0  0.0    0.0    0.0  10.0   10.0   1.10;...
    90.00    0.000   0.000     0.0      0.0     0.0     -9.0      0.0   0.0   0.0  0.0    0.0    0.0  10.0   10.0   1.10;...
    80.00    0.000   0.000     0.0      0.0     0.0     -8.0      0.0   0.0   0.0  0.0    0.0    0.0  10.0   10.0   1.10;...
    70.00    0.000   0.000     0.0      0.0     0.0     -7.0      0.0   0.0   0.0  0.0    0.0    0.0  10.0   10.0   1.10;...
    60.00    0.000   0.000     0.0      0.0     0.0     -6.0      0.0   0.0   0.0  0.0    0.0    0.0  10.0   10.0   1.10;...
    50.00    0.000   0.000     0.0      0.0     0.0     -3.7      0.0   0.0   0.0  0.0    0.0    0.0  10.0   10.0   1.10;...
    40.00    0.000   0.000     0.0      0.0     0.0     -4.0      0.0   0.0   0.0  0.0    0.0    0.0  10.0   10.0   1.10;...
    20.00    0.000   0.000     0.0      0.0     0.0     -2.0      lKp   lKp   0.0  lKi    lKi    0.0  lKd    lKd    1.30;...
    2.000    0.000   0.000     0.0      0.0     0.0     -0.5      lKp   lKp   0.0  lKi    lKi    0.0  lKd    lKd    10.30;...
    1.000    0.000   0.000     0.0      0.0     0.0     -0.5      lKp   lKp   0.0  lKi    lKi    0.0  lKd    lKd    25.50;...
    0.000    0.000   0.000     0.0      0.0     0.0     -0.1      lKp   lKp   0.0  lKi    lKi    0.0  lKd    lKd    25.50;...
    ];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
