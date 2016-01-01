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

% Rate of guidance block
csc_gdn_dt = fsw_dt;

csu_arg_aimpoint_roll_guidance_init;
csc_gal_gdn_approach_landing_init;
csc_peg_powered_explicit_guidance_init;

gdn_landing_targeting_max_alt = 500.0;    % [m] max altitude to set hold complete flag (starts approach targeting)
gdn_landing_terminal_max_alt  = 300.0;     % [m] max altitude to set targeting complete flag (starts terminal descent)

