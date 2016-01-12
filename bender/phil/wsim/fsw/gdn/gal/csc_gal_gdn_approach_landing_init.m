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

% These are used in both csu_lat and csc_ltg, so I put them in here

% Altitude above surface to cut off thrust and ACS
gdn_altitude_transition_free_drift_takeoff = -1.0; % Set to 0.0 meter when taking off  % RENAME ME: Used in ltg_lat, and the CNT
gdn_altitude_transition_free_drift_landing =  0.75; % Set to 0.5 meter with 10 cm accuracy altimeter
gdn_altitude_transition_free_drift_landing =  1.00; % Set to 1.00 meter for approach and landing

csu_lpc_landing_pre_coast_init
csu_lic_landing_inter_coast_init;
csc_ltg_landing_terminal_guidance_init;
csc_lac_landing_acceleration_command_init;
csc_tlt_takeoff_landing_table_guidance_init;
