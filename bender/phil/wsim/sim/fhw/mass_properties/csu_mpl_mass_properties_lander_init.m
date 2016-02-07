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

%% Begin mpl init file
% Dependencies:
%
% Source: see below for specifics
%
%%

% 100 percent fill fraction
mpl_mass_fillfrac_100 = 260.0;   % MTV-1
mpl_mass_fillfrac_100 = 572.9;   % Updated 01/16/2014 per Matt
mpl_mass_fillfrac_100 = 222.38;  % MXmicro lander plus 3rd stage

% 0 percent fill fraction
% mpl_mass_fillfrac_0 = 177.3;   % Updated 01/16/2014 per Matt
mpl_mass_fillfrac_0 = 175.8;   % Tom's number 12/06/2013
mpl_mass_fillfrac_0 = 189.04;  % Bud's number 1/2016

% % Source: Thruster Sheet (metric) new coordinates 07232013
% mpl_cgx_location_fillfrac_0 = -0.015;
% mpl_cgy_location_fillfrac_0 = -0.068;
% mpl_cgz_location_fillfrac_0 =  0.320;

% % Source: Thruster Sheet (metric) new coordinates 07232013
% mpl_cgx_location_fillfrac_100 = -0.004;
% mpl_cgy_location_fillfrac_100 = -0.017;
% mpl_cgz_location_fillfrac_100 =  0.312;

% Source: Thruster Sheet (metric) new coordinates (Benign contrived)
mpl_cgx_location_fillfrac_0 =  0.000;
mpl_cgy_location_fillfrac_0 =  0.000;
mpl_cgz_location_fillfrac_0 =  0.320;

% Source: Thruster Sheet (metric) new coordinates (Benign Contrived)
mpl_cgx_location_fillfrac_100 =  0.000;
mpl_cgy_location_fillfrac_100 =  0.000;
mpl_cgz_location_fillfrac_100 =  0.312;

% Source: Thruster Sheet (metric) new coordinates 07232013
% known issue: update as of 1/16/14 raises wet mass but has not updated the inertia to match
mpl_Ixx_fillfrac_0 = 26.787;
mpl_Iyy_fillfrac_0 = 26.340;
mpl_Izz_fillfrac_0 = 21.166;
mpl_Ixy_fillfrac_0 = 0.757;
mpl_Iyz_fillfrac_0 = -2.712;
mpl_Ixz_fillfrac_0 = -0.918;

% Source: Thruster Sheet (metric) new coordinates 07232013
% known issue: update as of 1/16/14 raises wet mass but has not updated the inertia to match
mpl_Ixx_fillfrac_100 = 91.641;
mpl_Iyy_fillfrac_100 = 91.194;
mpl_Izz_fillfrac_100 = 79.911;
mpl_Ixy_fillfrac_100 = 0.757;
mpl_Iyz_fillfrac_100 = -2.712;
mpl_Ixz_fillfrac_100 = -0.918;

% zeroed out for origin of coordinates on bottom plane of lander 06/26/14
mpl_footpad_plane_to_origin = 0.0;
mpl_launchstand_height = 0.0;


%% initial HTP mass properties

% dimensions, m
mpl_htp_tank_minor_radius = 0.370/2;
mpl_htp_tank_major_radius = 0.762/2; 

% masses, kg
mpl_htp_mass_initial      = 317.68;

% center of tank locations, m
mpl_htp_tank_center = [  0.0  0.0  0.4];

% min/max fluid mass
mpl_htp_mass_fillfrac_0   =  0.0;
mpl_htp_mass_fillfrac_100 = 352.98;

% fluid CG locations, from center of tank
mpl_htp_cg_fillfrac_0     = [0.0 0.0 -mpl_htp_tank_minor_radius];
mpl_htp_cg_fillfrac_100   = [0.0 0.0 0.0];

%% initial RP1 mass properties

% dimensions, m
mpl_rp1_tank_minor_radius = 0.10/2;
mpl_rp1_tank_major_radius = 0.762/2; 

% masses, kg
mpl_rp1_mass_initial      = 79.42;

% center of tank locations, m
mpl_rp1_tank_center = [  0.0  0.0  0.1];

% min/max fluid mass
mpl_rp1_mass_fillfrac_0   =  0.0;
mpl_rp1_mass_fillfrac_100 = 88.24;

% fluid CG locations, from center of tank
mpl_rp1_cg_fillfrac_0     = [0.0 0.0 -mpl_rp1_tank_minor_radius];
mpl_rp1_cg_fillfrac_100   = [0.0 0.0 0.0];

%% initial N2 mass properties

% dimensions, m
mpl_gn2_tank_radius =  3.065*.0254; 
mpl_gn2_tank_length = 16.394*.0254; 

% masses, kg
mpl_gn2_mass_initial       = [];     % set to initialize all tanks to mass_initial/4
mpl_gn2_mass_initial_tank1 = 0.5;
mpl_gn2_mass_initial_tank2 = 0.5;
mpl_gn2_mass_initial_tank3 = 0.5;
mpl_gn2_mass_initial_tank4 = 0.5;

% center of tank locations, m
mpl_gn2_center_tank1 = [  0.4   0.0   0.2];
mpl_gn2_center_tank2 = [  0.0   0.4   0.2];
mpl_gn2_center_tank3 = [ -0.4   0.0   0.2];
mpl_gn2_center_tank4 = [  0.0  -0.4   0.2];

% min/max fluid mass
mpl_gn2_mass_fillfrac_0   = 0.0;
mpl_gn2_mass_fillfrac_100 = 5.644;

% fluid CG locations, from center of tank
mpl_gn2_cg_fillfrac_0     = [0.0 0.0 0.0];
mpl_gn2_cg_fillfrac_100   = [0.0 0.0 0.0];

% tank drain efficiencies
mpl_gn2_drain_efficiency_tank1 = 1.0;
mpl_gn2_drain_efficiency_tank2 = 1.0;
mpl_gn2_drain_efficiency_tank3 = 1.0;
mpl_gn2_drain_efficiency_tank4 = 1.0;

