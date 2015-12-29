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
% sim_set_kfl_error_state_init.m                                          %
%                                                                         %
% script to initialize filter state at terminla descent start             %
% 07/26/12                                                                %
%-------------------------------------------------------------------------%


    if est_j2000_or_topo == 0
        % assume landed: know initial position precisely
        pos_noise_val = 0;
        vel_noise_val = 0;
    elseif est_j2000_or_topo  == 1
        % noise values at start of terminal
        pos_noise_val = 50;
        vel_noise_val = 2;
    elseif est_j2000_or_topo  == 2
        % noise values at start of braking
        pos_noise_val = 2000;
        vel_noise_val = 2;
    elseif est_j2000_or_topo  == 3
        % noise values at start of deorbit
        pos_noise_val = 200;
        vel_noise_val = 0.10;
    else
        pos_noise_val = 0;
        vel_noise_val = 0;
    end
    
kfl_velocity_init = ini_velocity_v' + (-vel_noise_val + rand(3,1)*2*vel_noise_val) ;
% Slightly bias initial position update by about one FSW time cycle (0.1
% sec) since FSW takes about 1 cycle to begin propagation.  This ensures closer match to truth so that statistical variation is
% truer to pos_noise_val intentions
kfl_position_init = ini_position_v' + (-pos_noise_val + rand(3,1)*2*pos_noise_val) ;

kfl_state_init = [ kfl_position_init ; kfl_velocity_init ; kfl_acc_bias_init ;  kfl_gibbs_init ;  kfl_gyro_bias_init];

kfl_star_tracker_transverse_noise = 1*9; % arc seconds


