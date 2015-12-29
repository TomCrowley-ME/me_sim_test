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

%% Begin tdl init file 
% Dependencies: 
%
% Source: ?
%
%%

% % DIY configuration thruster forces

% acs thruster data MTV1X Configuration 5 lbf Coarse
% measured at closer to 5.75 lbf
tdl_coarse_acs_thrust = 25.5772743; 

    tdl_coarse_acs_noise_mean = 0; %(Newton)
    tdl_coarse_acs_noise_std_percent  = 10/3; %(percentage, 1sigma) %prop test data from 22 April 2014, 10% total excursion
    tdl_coarse_acs_noise_enable = 0;

    
% act on commands if more than 1ms has passed
tdl_active_time = 0.9/1000;

% time from electrical signal to valve opening
tdl_valve_delay = 25 / 1000;


%%%%%%%%%%%%%%% END SCRIPT %%%%%%%%%%%%%%%
