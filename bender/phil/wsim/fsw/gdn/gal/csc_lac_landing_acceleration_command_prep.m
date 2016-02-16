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


lac_main_mono_thrust_available = psp_main_mono_thrust;
lac_main_biprop_thrust_available = psp_main_biprop_thrust;
lac_coarse_acs_thrust_available = psp_coarse_acs_thrust*4 + psp_coarse_acs_thrust*8*cosd(15); % 12 coarse thrusters MX-1
lac_coarse_acs_thrust_available = psp_coarse_acs_thrust*4; % 4 coarse thrusters MX-micro

