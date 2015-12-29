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

%
% Pulse width modulation parameters for the acceleration
%

ltg_pwpf_accel_integ_tm = ltg_pwpf_tm_over_dt * csc_gdn_dt;

ltg_pwpf_reference_mass = sum([emp_mass_fillfrac_100 emp_mass_fillfrac_0].*[(1-ltg_pwpf_reference_prop_ratio) ltg_pwpf_reference_prop_ratio]);
ltg_pwpf_reference_min_delta_v = ltg_pwpf_accel_integ_tm * lac_main_mono_thrust_available / ltg_pwpf_reference_mass; % i think this is the same as it used to be....
ltg_pwpf_reference_min_delta_v = ltg_pwpf_accel_integ_tm * lac_main_biprop_thrust_available / ltg_pwpf_reference_mass; % i think this is the same as it used to be....

ltg_pwpf_trigger_on_alpha = ltg_pwpf_reference_min_delta_v + 1;
ltg_pwpf_trigger_off_alpha = min( 2,ltg_pwpf_reference_min_delta_v );

