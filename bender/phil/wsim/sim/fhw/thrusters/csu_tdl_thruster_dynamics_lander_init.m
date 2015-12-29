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
% thruster force is from DIY 480 lbf Monoprop
tdl_main_mono_thrust = 2135.1463776;

    tdl_main_mono_noise_mean = 0; %(Newton)
    tdl_main_mono_noise_std_percent  = 2/3; %(Newton, 1sigma) % 2% total variability, transformed to 1signma. %made it up, escrane 30 April 2014
    tdl_main_mono_noise_enable = 0;

 % thruster force is from DIY 500 lbf Biprop
tdl_main_biprop_thrust = 2224.11081;
 % thruster force is from MX-Micro 450 N Biprop
tdl_main_biprop_thrust = 450;

    tdl_main_biprop_noise_mean = 0; %(Newton)
    tdl_main_biprop_noise_std_percent  = 2/3; %(Newton, 1sigma) % 3% total variability, transformed to 1signma. %made it up, escrane 30 April 2014
    tdl_main_biprop_noise_enable = 0;

% acs thruster data DIY Configuration 10 lbf Coarse
tdl_coarse_acs_thrust = 44.48;

    tdl_coarse_acs_noise_mean = 0; %(Newton)
    tdl_coarse_acs_noise_std_percent  = 10/3; %(percentage, 1sigma) %prop test data from 22 April 2014, 10% total excursion
    tdl_coarse_acs_noise_enable = 0;

% acs thruster data DIY Configuration 0.1 N fine
tdl_vernier_acs_thrust = 0.1;

    tdl_vernier_acs_noise_mean = 0; %(Newton)
    tdl_vernier_acs_noise_std_percent  = 2/3; %(Newton, 1sigma) % 2% total variability, transformed to 1signma. %made it up, escrane 30 April 2014
    tdl_vernier_acs_noise_enable = 0;
    
% act on commands if more than 1ms has passed
tdl_active_time = 0.9/1000;

% time from electrical signal to valve opening
tdl_valve_delay = 25 / 1000;

% time delays for MC analysis
tdl_main_engine_start_delay = 0 / 1000;
tdl_main_engine_stop_delay  = 0 / 1000;

%%%%%%%%%%%%%%% END SCRIPT %%%%%%%%%%%%%%%
