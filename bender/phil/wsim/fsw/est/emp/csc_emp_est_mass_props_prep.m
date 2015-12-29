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
% csc_emp_est_mass_props_prep.m                                           %
%                                                                         %
% 01/16/14                                                                %
%-------------------------------------------------------------------------%


% Lander CG Location
emp_cg_wet_dry_x = [emp_cgx_location_fillfrac_0, emp_cgx_location_fillfrac_100];
emp_cg_wet_dry_y = [emp_cgy_location_fillfrac_0, emp_cgy_location_fillfrac_100];
emp_cg_wet_dry_z = [emp_cgz_location_fillfrac_0, emp_cgz_location_fillfrac_100];

% Lander Mass
emp_mass_wet_dry = [emp_mass_fillfrac_0, emp_mass_fillfrac_100];

    
% convert ontime command in milliseconds to thruster force
emp_time_to_coarse_thrust = psp_coarse_acs_thrust / emp_cnt_millisecond_cmd;
emp_time_to_fine_thrust   = psp_vernier_acs_thrust / emp_cnt_millisecond_cmd;
emp_time_to_mono_thrust   = psp_main_mono_thrust / emp_cnt_millisecond_cmd;
emp_time_to_biprop_thrust = psp_main_biprop_thrust / emp_cnt_millisecond_cmd;


emp_coarse_gISP_inverse = 1 ./ (psp_coarse_acs_isp*emp_earth_grav);
emp_fine_gISP_inverse   = 1 ./ (psp_vernier_acs_isp*emp_earth_grav);
emp_mono_gISP_inverse   = 1 ./ (psp_main_monoprop_isp*emp_earth_grav);
emp_biprop_gISP_inverse = 1 ./ (psp_main_biprop_isp*emp_earth_grav);


% Lander Inertia Tensor
emp_inertia_fillfrac_100 = [emp_Ixx_fillfrac_100, emp_Iyy_fillfrac_100, emp_Izz_fillfrac_100, -emp_Ixy_fillfrac_100, -emp_Iyz_fillfrac_100, -emp_Ixz_fillfrac_100]';
emp_inertia_fillfrac_0   = [emp_Ixx_fillfrac_0,   emp_Iyy_fillfrac_0,   emp_Izz_fillfrac_0,   -emp_Ixy_fillfrac_0,   -emp_Iyz_fillfrac_0,   -emp_Ixz_fillfrac_0]';

emp_inertia_wet_dry = [emp_inertia_fillfrac_0, emp_inertia_fillfrac_100];

emp_initial_fuel_load = emp_mass_fillfrac_100 - emp_mass_fillfrac_0;
