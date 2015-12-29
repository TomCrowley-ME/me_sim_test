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


tdl_valve_delay_cycles = max( floor(tdl_valve_delay / sim_time_step_size), 1 );

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



%-------------------------------------------------------------------------%
% assign each thruster a lookup table
%
% Mapping:  1 : 12 = coarse acs
%          13 : 24 = vernier acs
%               25 = main monoprop
%               26 = biprop switch for main


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
