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
% csc_pwr_power_system_sim_init.m                                         %
%                                                                         %
% 07/15/14                                                                %
%-------------------------------------------------------------------------%

% % use "on_state" to control whether or not power switching is enforced
% % (for use durnig power control system development, 07/17/14)
% on_state = 0 : device is always active, even if powered off
% on_state = 1 : device must be powered on to respond

% DPU poiwer switch
pwr_sta_on_state = 0;

% LIDAR Pair A switch
pwr_ldr_on_state = 0;

% LIDAR Pair B switch not modeled
