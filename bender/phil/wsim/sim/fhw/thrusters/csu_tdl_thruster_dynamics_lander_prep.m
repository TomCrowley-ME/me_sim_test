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

%% Begin tdl prep file 
% Dependencies: 
% csu_mpl_mass_properties_init
% csu_tdl_thruster_dynamics_init
%
%
%%


tdl_valve_delay_cycles             = max( floor(tdl_valve_delay / sim_time_step_size), 1 );
tdl_main_engine_start_delay_cycles = max( floor(tdl_main_engine_start_delay / sim_time_step_size), 1 );
tdl_main_engine_stop_delay_cycles  = max( floor(tdl_main_engine_stop_delay / sim_time_step_size), 1 );

% %-------------------------------------------------------------------------%
% % Set up vectors for interpolating thrust and mdot
% tdl_biprop_main_prep_full_mass_to_thrust = [tdl_biprop_main_mass_to_thrust(:,1)+mpl_mass_dry, tdl_biprop_main_mass_to_thrust(:,2)];
% tdl_main_prep_full_mass_to_thrust = [tdl_main_mass_to_thrust(:,1)+mpl_mass_dry, tdl_main_mass_to_thrust(:,2)];
% tdl_coarse_acs_prep_full_mass_to_thrust = [tdl_coarse_acs_mass_to_thrust(:,1)+mpl_mass_dry, tdl_coarse_acs_mass_to_thrust(:,2)];
% tdl_vernier_acs_prep_full_mass_to_thrust = [tdl_vernier_acs_mass_to_thrust(:,1)+mpl_mass_dry, tdl_vernier_acs_mass_to_thrust(:,2)];

%-------------------------------------------------------------------------%
% create lookup tables for each thruster type (bulk models for now)
% % coarse ACS
tdl_coarse_acs_rising_lookup_time = [-1 0 1 3 5]/1000;
tdl_coarse_acs_rising_lookup_thrust = [0 0 tdl_coarse_acs_thrust tdl_coarse_acs_thrust tdl_coarse_acs_thrust];

tdl_coarse_acs_falling_lookup_time = [-1 0 9 10 ]/1000;
tdl_coarse_acs_falling_lookup_thrust = [tdl_coarse_acs_thrust tdl_coarse_acs_thrust tdl_coarse_acs_thrust 0];

tdl_coarse_acs_noise_std  = (tdl_coarse_acs_noise_std_percent/100)*tdl_coarse_acs_thrust; %(Newton, 1sigma) 

% % vernier ACS
tdl_vernier_acs_rising_lookup_time = [-1 0 1 3 5]/1000;
tdl_vernier_acs_rising_lookup_thrust = [0 0 tdl_vernier_acs_thrust tdl_vernier_acs_thrust tdl_vernier_acs_thrust];

tdl_vernier_acs_falling_lookup_time = [-1 0 9 10 ]/1000;
tdl_vernier_acs_falling_lookup_thrust = [tdl_vernier_acs_thrust tdl_vernier_acs_thrust tdl_vernier_acs_thrust 0];

tdl_vernier_acs_noise_std  = (tdl_vernier_acs_noise_std_percent/100)*tdl_vernier_acs_thrust; %(Newton, 1sigma) 

% % mono-prop main
tdl_main_mono_rising_lookup_time = [-1 0 1 5]/1000;
tdl_main_mono_rising_lookup_thrust = [0 0 tdl_main_mono_thrust tdl_main_mono_thrust];

tdl_main_mono_falling_lookup_time = [-1 0 1 5 ]/1000;
tdl_main_mono_falling_lookup_thrust = [tdl_main_mono_thrust tdl_main_mono_thrust 0 0];

tdl_main_mono_noise_mean = 0; %(Newton)
tdl_main_mono_noise_std  = (tdl_main_mono_noise_std_percent/100)*tdl_vernier_acs_thrust; %(Newton, 1sigma) 
tdl_main_mono_noise_enable = 0;

% % bi-prop main
tdl_main_biprop_rising_lookup_time = [-1 0 1 5]/1000;
tdl_main_biprop_rising_lookup_thrust = [0 0 tdl_main_biprop_thrust tdl_main_biprop_thrust];

tdl_main_biprop_falling_lookup_time = [-1 0 1 5 ]/1000;
tdl_main_biprop_falling_lookup_thrust = [tdl_main_biprop_thrust tdl_main_biprop_thrust 0 0];

tdl_main_biprop_noise_std  = (tdl_main_biprop_noise_std_percent/100)*tdl_vernier_acs_thrust; %(Newton, 1sigma)

%-------------------------------------------------------------------------%
% assign each thruster a lookup table
%
% Mapping:  1 : 12 = coarse acs
%          13 : 24 = vernier acs
%               25 = main monoprop
%               26 = biprop switch for main

%Thruster 25 : Main Monoprop
tdl_thruster25_rising_lookup_time = tdl_main_mono_rising_lookup_time;
tdl_thruster25_rising_lookup_thrust = tdl_main_mono_rising_lookup_thrust;

tdl_thruster25_falling_lookup_time = tdl_main_mono_falling_lookup_time;
tdl_thruster25_falling_lookup_thrust = tdl_main_mono_falling_lookup_thrust;

tdl_thruster25_thrust_noise_mean = tdl_main_mono_noise_mean;
tdl_thruster25_thrust_noise_std  = tdl_main_mono_noise_std;
tdl_thruster25_thrust_noise_seed = 25;
tdl_thruster25_thrust_noise_enable = tdl_main_mono_noise_enable;

%Thruster 25 : Main mono vs biprop switch
tdl_thruster26_rising_lookup_time = tdl_main_biprop_rising_lookup_time;
tdl_thruster26_rising_lookup_thrust = tdl_main_biprop_rising_lookup_thrust;

tdl_thruster26_falling_lookup_time = tdl_main_biprop_falling_lookup_time;
tdl_thruster26_falling_lookup_thrust = tdl_main_biprop_falling_lookup_thrust;

tdl_thruster26_thrust_noise_mean = tdl_main_biprop_noise_mean;
tdl_thruster26_thrust_noise_std  = tdl_main_biprop_noise_std;
tdl_thruster26_thrust_noise_seed = 26;
tdl_thruster26_thrust_noise_enable = tdl_main_biprop_noise_enable;

%Thruster 1 : Coarse ACS
tdl_thruster1_rising_lookup_time = tdl_coarse_acs_rising_lookup_time;
tdl_thruster1_rising_lookup_thrust = tdl_coarse_acs_rising_lookup_thrust;

tdl_thruster1_falling_lookup_time = tdl_coarse_acs_falling_lookup_time;
tdl_thruster1_falling_lookup_thrust = tdl_coarse_acs_falling_lookup_thrust;

tdl_thruster1_thrust_noise_mean = tdl_coarse_acs_noise_mean;
tdl_thruster1_thrust_noise_std  = tdl_coarse_acs_noise_std;
tdl_thruster1_thrust_noise_seed = 1;
tdl_thruster1_thrust_noise_enable = tdl_coarse_acs_noise_enable;

%Thruster 2 : Coarse ACS
tdl_thruster2_rising_lookup_time = tdl_coarse_acs_rising_lookup_time;
tdl_thruster2_rising_lookup_thrust = tdl_coarse_acs_rising_lookup_thrust;

tdl_thruster2_falling_lookup_time = tdl_coarse_acs_falling_lookup_time;
tdl_thruster2_falling_lookup_thrust = tdl_coarse_acs_falling_lookup_thrust;

tdl_thruster2_thrust_noise_mean = tdl_coarse_acs_noise_mean;
tdl_thruster2_thrust_noise_std  = tdl_coarse_acs_noise_std;
tdl_thruster2_thrust_noise_seed = 2;
tdl_thruster2_thrust_noise_enable = tdl_coarse_acs_noise_enable;

%Thruster 3 : Coarse ACS
tdl_thruster3_rising_lookup_time = tdl_coarse_acs_rising_lookup_time;
tdl_thruster3_rising_lookup_thrust = tdl_coarse_acs_rising_lookup_thrust;

tdl_thruster3_falling_lookup_time = tdl_coarse_acs_falling_lookup_time;
tdl_thruster3_falling_lookup_thrust = tdl_coarse_acs_falling_lookup_thrust;

tdl_thruster3_thrust_noise_mean = tdl_coarse_acs_noise_mean;
tdl_thruster3_thrust_noise_std  = tdl_coarse_acs_noise_std;
tdl_thruster3_thrust_noise_seed = 3;
tdl_thruster3_thrust_noise_enable = tdl_coarse_acs_noise_enable;

%Thruster 4 : Coarse ACS
tdl_thruster4_rising_lookup_time = tdl_coarse_acs_rising_lookup_time;
tdl_thruster4_rising_lookup_thrust = tdl_coarse_acs_rising_lookup_thrust;

tdl_thruster4_falling_lookup_time = tdl_coarse_acs_falling_lookup_time;
tdl_thruster4_falling_lookup_thrust = tdl_coarse_acs_falling_lookup_thrust;

tdl_thruster4_thrust_noise_mean = tdl_coarse_acs_noise_mean;
tdl_thruster4_thrust_noise_std  = tdl_coarse_acs_noise_std;
tdl_thruster4_thrust_noise_seed = 4;
tdl_thruster4_thrust_noise_enable = tdl_coarse_acs_noise_enable;

%Thruster 5 : Coarse ACS
tdl_thruster5_rising_lookup_time = tdl_coarse_acs_rising_lookup_time;
tdl_thruster5_rising_lookup_thrust = tdl_coarse_acs_rising_lookup_thrust;

tdl_thruster5_falling_lookup_time = tdl_coarse_acs_falling_lookup_time;
tdl_thruster5_falling_lookup_thrust = tdl_coarse_acs_falling_lookup_thrust;

tdl_thruster5_thrust_noise_mean = tdl_coarse_acs_noise_mean;
tdl_thruster5_thrust_noise_std  = tdl_coarse_acs_noise_std;
tdl_thruster5_thrust_noise_seed = 5;
tdl_thruster5_thrust_noise_enable = tdl_coarse_acs_noise_enable;

%Thruster 6 : Coarse ACS
tdl_thruster6_rising_lookup_time = tdl_coarse_acs_rising_lookup_time;
tdl_thruster6_rising_lookup_thrust = tdl_coarse_acs_rising_lookup_thrust;

tdl_thruster6_falling_lookup_time = tdl_coarse_acs_falling_lookup_time;
tdl_thruster6_falling_lookup_thrust = tdl_coarse_acs_falling_lookup_thrust;

tdl_thruster6_thrust_noise_mean = tdl_coarse_acs_noise_mean;
tdl_thruster6_thrust_noise_std  = tdl_coarse_acs_noise_std;
tdl_thruster6_thrust_noise_seed = 6;
tdl_thruster6_thrust_noise_enable = tdl_coarse_acs_noise_enable;

%Thruster 7 : Coarse ACS
tdl_thruster7_rising_lookup_time = tdl_coarse_acs_rising_lookup_time;
tdl_thruster7_rising_lookup_thrust = tdl_coarse_acs_rising_lookup_thrust;

tdl_thruster7_falling_lookup_time = tdl_coarse_acs_falling_lookup_time;
tdl_thruster7_falling_lookup_thrust = tdl_coarse_acs_falling_lookup_thrust;

tdl_thruster7_thrust_noise_mean = tdl_coarse_acs_noise_mean;
tdl_thruster7_thrust_noise_std  = tdl_coarse_acs_noise_std;
tdl_thruster7_thrust_noise_seed = 7;
tdl_thruster7_thrust_noise_enable = tdl_coarse_acs_noise_enable;

%Thruster 8 : Coarse ACS
tdl_thruster8_rising_lookup_time = tdl_coarse_acs_rising_lookup_time;
tdl_thruster8_rising_lookup_thrust = tdl_coarse_acs_rising_lookup_thrust;

tdl_thruster8_falling_lookup_time = tdl_coarse_acs_falling_lookup_time;
tdl_thruster8_falling_lookup_thrust = tdl_coarse_acs_falling_lookup_thrust;

tdl_thruster8_thrust_noise_mean = tdl_coarse_acs_noise_mean;
tdl_thruster8_thrust_noise_std  = tdl_coarse_acs_noise_std;
tdl_thruster8_thrust_noise_seed = 8;
tdl_thruster8_thrust_noise_enable = tdl_coarse_acs_noise_enable;

%Thruster 9 : Coarse ACS
tdl_thruster9_rising_lookup_time = tdl_coarse_acs_rising_lookup_time;
tdl_thruster9_rising_lookup_thrust = tdl_coarse_acs_rising_lookup_thrust;

tdl_thruster9_falling_lookup_time = tdl_coarse_acs_falling_lookup_time;
tdl_thruster9_falling_lookup_thrust = tdl_coarse_acs_falling_lookup_thrust;

tdl_thruster9_thrust_noise_mean = tdl_coarse_acs_noise_mean;
tdl_thruster9_thrust_noise_std  = tdl_coarse_acs_noise_std;
tdl_thruster9_thrust_noise_seed = 9;
tdl_thruster9_thrust_noise_enable = tdl_coarse_acs_noise_enable;

%Thruster 10 : Coarse ACS
tdl_thruster10_rising_lookup_time = tdl_coarse_acs_rising_lookup_time;
tdl_thruster10_rising_lookup_thrust = tdl_coarse_acs_rising_lookup_thrust;

tdl_thruster10_falling_lookup_time = tdl_coarse_acs_falling_lookup_time;
tdl_thruster10_falling_lookup_thrust = tdl_coarse_acs_falling_lookup_thrust;

tdl_thruster10_thrust_noise_mean = tdl_coarse_acs_noise_mean;
tdl_thruster10_thrust_noise_std  = tdl_coarse_acs_noise_std;
tdl_thruster10_thrust_noise_seed = 1;
tdl_thruster10_thrust_noise_enable = tdl_coarse_acs_noise_enable;

%Thruster 11 : Coarse ACS
tdl_thruster11_rising_lookup_time = tdl_coarse_acs_rising_lookup_time;
tdl_thruster11_rising_lookup_thrust = tdl_coarse_acs_rising_lookup_thrust;

tdl_thruster11_falling_lookup_time = tdl_coarse_acs_falling_lookup_time;
tdl_thruster11_falling_lookup_thrust = tdl_coarse_acs_falling_lookup_thrust;

tdl_thruster11_thrust_noise_mean = tdl_coarse_acs_noise_mean;
tdl_thruster11_thrust_noise_std  = tdl_coarse_acs_noise_std;
tdl_thruster11_thrust_noise_seed = 11;
tdl_thruster11_thrust_noise_enable = tdl_coarse_acs_noise_enable;

%Thruster 12 : Coarse ACS
tdl_thruster12_rising_lookup_time = tdl_coarse_acs_rising_lookup_time;
tdl_thruster12_rising_lookup_thrust = tdl_coarse_acs_rising_lookup_thrust;

tdl_thruster12_falling_lookup_time = tdl_coarse_acs_falling_lookup_time;
tdl_thruster12_falling_lookup_thrust = tdl_coarse_acs_falling_lookup_thrust;

tdl_thruster12_thrust_noise_mean = tdl_coarse_acs_noise_mean;
tdl_thruster12_thrust_noise_std  = tdl_coarse_acs_noise_std;
tdl_thruster12_thrust_noise_seed = 12;
tdl_thruster12_thrust_noise_enable = tdl_coarse_acs_noise_enable;

%Thruster 13 : Vernier ACS
tdl_thruster13_rising_lookup_time = tdl_vernier_acs_rising_lookup_time;
tdl_thruster13_rising_lookup_thrust = tdl_vernier_acs_rising_lookup_thrust;

tdl_thruster13_falling_lookup_time = tdl_vernier_acs_falling_lookup_time;
tdl_thruster13_falling_lookup_thrust = tdl_vernier_acs_falling_lookup_thrust;

tdl_thruster13_thrust_noise_mean = tdl_vernier_acs_noise_mean;
tdl_thruster13_thrust_noise_std  = tdl_vernier_acs_noise_std;
tdl_thruster13_thrust_noise_seed = 13;
tdl_thruster13_thrust_noise_enable = tdl_vernier_acs_noise_enable;

%Thruster 14 : Vernier ACS
tdl_thruster14_rising_lookup_time = tdl_vernier_acs_rising_lookup_time;
tdl_thruster14_rising_lookup_thrust = tdl_vernier_acs_rising_lookup_thrust;

tdl_thruster14_falling_lookup_time = tdl_vernier_acs_falling_lookup_time;
tdl_thruster14_falling_lookup_thrust = tdl_vernier_acs_falling_lookup_thrust;

tdl_thruster14_thrust_noise_mean = tdl_vernier_acs_noise_mean;
tdl_thruster14_thrust_noise_std  = tdl_vernier_acs_noise_std;
tdl_thruster14_thrust_noise_seed = 14;
tdl_thruster14_thrust_noise_enable = tdl_vernier_acs_noise_enable;

%Thruster 15 : Vernier ACS
tdl_thruster15_rising_lookup_time = tdl_vernier_acs_rising_lookup_time;
tdl_thruster15_rising_lookup_thrust = tdl_vernier_acs_rising_lookup_thrust;

tdl_thruster15_falling_lookup_time = tdl_vernier_acs_falling_lookup_time;
tdl_thruster15_falling_lookup_thrust = tdl_vernier_acs_falling_lookup_thrust;

tdl_thruster15_thrust_noise_mean = tdl_vernier_acs_noise_mean;
tdl_thruster15_thrust_noise_std  = tdl_vernier_acs_noise_std;
tdl_thruster15_thrust_noise_seed = 15;
tdl_thruster15_thrust_noise_enable = tdl_vernier_acs_noise_enable;

%Thruster 16 : Vernier ACS
tdl_thruster16_rising_lookup_time = tdl_vernier_acs_rising_lookup_time;
tdl_thruster16_rising_lookup_thrust = tdl_vernier_acs_rising_lookup_thrust;

tdl_thruster16_falling_lookup_time = tdl_vernier_acs_falling_lookup_time;
tdl_thruster16_falling_lookup_thrust = tdl_vernier_acs_falling_lookup_thrust;

tdl_thruster16_thrust_noise_mean = tdl_vernier_acs_noise_mean;
tdl_thruster16_thrust_noise_std  = tdl_vernier_acs_noise_std;
tdl_thruster16_thrust_noise_seed = 16;
tdl_thruster16_thrust_noise_enable = tdl_vernier_acs_noise_enable;

%Thruster 17 : Vernier ACS
tdl_thruster17_rising_lookup_time = tdl_vernier_acs_rising_lookup_time;
tdl_thruster17_rising_lookup_thrust = tdl_vernier_acs_rising_lookup_thrust;

tdl_thruster17_falling_lookup_time = tdl_vernier_acs_falling_lookup_time;
tdl_thruster17_falling_lookup_thrust = tdl_vernier_acs_falling_lookup_thrust;

tdl_thruster17_thrust_noise_mean = tdl_vernier_acs_noise_mean;
tdl_thruster17_thrust_noise_std  = tdl_vernier_acs_noise_std;
tdl_thruster17_thrust_noise_seed = 17;
tdl_thruster17_thrust_noise_enable = tdl_vernier_acs_noise_enable;

%Thruster 18 : Vernier ACS
tdl_thruster18_rising_lookup_time = tdl_vernier_acs_rising_lookup_time;
tdl_thruster18_rising_lookup_thrust = tdl_vernier_acs_rising_lookup_thrust;

tdl_thruster18_falling_lookup_time = tdl_vernier_acs_falling_lookup_time;
tdl_thruster18_falling_lookup_thrust = tdl_vernier_acs_falling_lookup_thrust;

tdl_thruster18_thrust_noise_mean = tdl_vernier_acs_noise_mean;
tdl_thruster18_thrust_noise_std  = tdl_vernier_acs_noise_std;
tdl_thruster18_thrust_noise_seed = 18;
tdl_thruster18_thrust_noise_enable = tdl_vernier_acs_noise_enable;

%Thruster 19 : Vernier ACS
tdl_thruster19_rising_lookup_time = tdl_vernier_acs_rising_lookup_time;
tdl_thruster19_rising_lookup_thrust = tdl_vernier_acs_rising_lookup_thrust;

tdl_thruster19_falling_lookup_time = tdl_vernier_acs_falling_lookup_time;
tdl_thruster19_falling_lookup_thrust = tdl_vernier_acs_falling_lookup_thrust;

tdl_thruster19_thrust_noise_mean = tdl_vernier_acs_noise_mean;
tdl_thruster19_thrust_noise_std  = tdl_vernier_acs_noise_std;
tdl_thruster19_thrust_noise_seed = 19;
tdl_thruster19_thrust_noise_enable = tdl_vernier_acs_noise_enable;

%Thruster 20 : Vernier ACS
tdl_thruster20_rising_lookup_time = tdl_vernier_acs_rising_lookup_time;
tdl_thruster20_rising_lookup_thrust = tdl_vernier_acs_rising_lookup_thrust;

tdl_thruster20_falling_lookup_time = tdl_vernier_acs_falling_lookup_time;
tdl_thruster20_falling_lookup_thrust = tdl_vernier_acs_falling_lookup_thrust;

tdl_thruster20_thrust_noise_mean = tdl_vernier_acs_noise_mean;
tdl_thruster20_thrust_noise_std  = tdl_vernier_acs_noise_std;
tdl_thruster20_thrust_noise_seed = 20;
tdl_thruster20_thrust_noise_enable = tdl_vernier_acs_noise_enable;

%Thruster 21 : Vernier ACS
tdl_thruster21_rising_lookup_time = tdl_vernier_acs_rising_lookup_time;
tdl_thruster21_rising_lookup_thrust = tdl_vernier_acs_rising_lookup_thrust;

tdl_thruster21_falling_lookup_time = tdl_vernier_acs_falling_lookup_time;
tdl_thruster21_falling_lookup_thrust = tdl_vernier_acs_falling_lookup_thrust;

tdl_thruster21_thrust_noise_mean = tdl_vernier_acs_noise_mean;
tdl_thruster21_thrust_noise_std  = tdl_vernier_acs_noise_std;
tdl_thruster21_thrust_noise_seed = 21;
tdl_thruster21_thrust_noise_enable = tdl_vernier_acs_noise_enable;

%Thruster 22 : Vernier ACS
tdl_thruster22_rising_lookup_time = tdl_vernier_acs_rising_lookup_time;
tdl_thruster22_rising_lookup_thrust = tdl_vernier_acs_rising_lookup_thrust;

tdl_thruster22_falling_lookup_time = tdl_vernier_acs_falling_lookup_time;
tdl_thruster22_falling_lookup_thrust = tdl_vernier_acs_falling_lookup_thrust;

tdl_thruster22_thrust_noise_mean = tdl_vernier_acs_noise_mean;
tdl_thruster22_thrust_noise_std  = tdl_vernier_acs_noise_std;
tdl_thruster22_thrust_noise_seed = 22;
tdl_thruster22_thrust_noise_enable = tdl_vernier_acs_noise_enable;

%Thruster 23 : Vernier ACS
tdl_thruster23_rising_lookup_time = tdl_vernier_acs_rising_lookup_time;
tdl_thruster23_rising_lookup_thrust = tdl_vernier_acs_rising_lookup_thrust;

tdl_thruster23_falling_lookup_time = tdl_vernier_acs_falling_lookup_time;
tdl_thruster23_falling_lookup_thrust = tdl_vernier_acs_falling_lookup_thrust;

tdl_thruster23_thrust_noise_mean = tdl_vernier_acs_noise_mean;
tdl_thruster23_thrust_noise_std  = tdl_vernier_acs_noise_std;
tdl_thruster23_thrust_noise_seed = 23;
tdl_thruster23_thrust_noise_enable = tdl_vernier_acs_noise_enable;

%Thruster 24 : Vernier ACS
tdl_thruster24_rising_lookup_time = tdl_vernier_acs_rising_lookup_time;
tdl_thruster24_rising_lookup_thrust = tdl_vernier_acs_rising_lookup_thrust;

tdl_thruster24_falling_lookup_time = tdl_vernier_acs_falling_lookup_time;
tdl_thruster24_falling_lookup_thrust = tdl_vernier_acs_falling_lookup_thrust;

tdl_thruster24_thrust_noise_mean = tdl_vernier_acs_noise_mean;
tdl_thruster24_thrust_noise_std  = tdl_vernier_acs_noise_std;
tdl_thruster24_thrust_noise_seed = 24;
tdl_thruster24_thrust_noise_enable = tdl_vernier_acs_noise_enable;

%%%%%%%%%%%%%%% END SCRIPT %%%%%%%%%%%%%%%