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

%% Aerodynamics model
load AeroData.mat;
afm_cg_enable      = 1;      % 0=use CG at origin, 1=use computed CG
afm_forces_enable  = 1;      % Turn ON Aero Forces
afm_moments_enable = 1;      % Turn ON Aero Moments

%% Wind model
load Winds.mat;
afm_winds_enable   = 1;      % Turn ON Winds

%% Discrete gust model
afm_gust_magnitude = 0.0;    % peak gust speed, m/s
afm_gust_start     = 0.0;    % gust start time, sec
afm_gust_length    = 1.0;    % gust length, sec
afm_gust_direction = 0.0;    % gust direction relative to wind, deg
afm_gust_number    = 1;      % number of gusts

%% Dryden gust model
afm_linear_gusts_enable     = 0;   % Turn ON linear gusts, [u v w]
afm_rotational_gusts_enable = 0;   % Turn ON rotational gusts, [p q r]
afm_gust_intensity          = 0;   % Wind at 6m, sets the low altitude gust intensity, m/s




