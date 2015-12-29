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
% csc_emp_est_mass_props_mtv_init.m                                       %
%                                                                         %
% 11/10/2014                                                              %
%-------------------------------------------------------------------------%


emp_initial_fuel_used = 0;

% 100 percent fill fraction
emp_mass_fillfrac_100 = 212.339;   

% 0 percent fill fraction
emp_mass_fillfrac_0 = 159.077;   

% Source: Thruster Sheet (metric) new coordinates (Benign contrived)
emp_cgx_location_fillfrac_0 =  0.000;
emp_cgy_location_fillfrac_0 =  0.000;
emp_cgz_location_fillfrac_0 =  0.097;

% Source: Thruster Sheet (metric) new coordinates (Benign Contrived)
emp_cgx_location_fillfrac_100 =  0.000;
emp_cgy_location_fillfrac_100 =  0.000;
emp_cgz_location_fillfrac_100 =  0.08954;

emp_cg_wet_dry_range_x = [-0.010:0.001:0.010];
emp_cg_wet_dry_range_y = [-0.010:0.001:0.010];

% Source: Thruster Sheet (metric) new coordinates 07232013
% known issue: update as of 1/16/14 raises wet mass but has not updated the inertia to match

% MTV
emp_Ixx_fillfrac_0 = 17.575;
emp_Iyy_fillfrac_0 = 17.365;
emp_Izz_fillfrac_0 = 24.026;
emp_Ixy_fillfrac_0 =  0.006;
emp_Iyz_fillfrac_0 = -0.075;
emp_Ixz_fillfrac_0 =  0.057;

% MTV
emp_Ixx_fillfrac_100 = 22.6327;
emp_Iyy_fillfrac_100 = 22.4227;
emp_Izz_fillfrac_100 = 35.8756;
emp_Ixy_fillfrac_100 =  0.006;
emp_Iyz_fillfrac_100 = -0.075;
emp_Ixz_fillfrac_100 =  0.057;

emp_cnt_millisecond_cmd = 100;
emp_earth_grav = 9.81;

% set saturation limits on fuel expended (for numerical stability)
emp_max_fuel_used = emp_mass_fillfrac_100 - emp_mass_fillfrac_0;
emp_min_fuel_used = 0;
