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
% Dependencies: none
%
% Source: see below for specifics
%

%% move origin to new location
mpl_origin_trans   = [0.0 0.0 0.0];

%% Vehicle dry mass properties
% Source: MTV-1X Mass Properties as of 14-09-12

% vehicle mass, kg
mpl_mass_dry = 172.270;

% CG location, m
mpl_cgx_dry =  0.000;
mpl_cgy_dry =  0.000;
mpl_cgz_dry =  0.107;

% vehicle inertia at origin, kg-m^2
mpl_Ixx_dry = 16.812;
mpl_Iyy_dry = 17.124;
mpl_Izz_dry = 25.417;
mpl_Ixy_dry = -0.115;
mpl_Ixz_dry =  0.139;
mpl_Iyz_dry =  0.020;
mpl_inertia_dry = [ mpl_Ixx_dry -mpl_Ixy_dry -mpl_Ixz_dry;...
                   -mpl_Ixy_dry  mpl_Iyy_dry -mpl_Iyz_dry;...
                   -mpl_Ixz_dry -mpl_Iyz_dry  mpl_Izz_dry];

% translate CG and inertia if origin is moved
mpl_cg_dry      = [ mpl_cgx_dry  mpl_cgy_dry  mpl_cgz_dry]+mpl_origin_trans;
mpl_inertia_dry = mpl_inertia_dry + mpl_mass_dry*buildParallelAxisMatrix( mpl_origin_trans );

%% initial HTP mass properties

% dimensions, m
mpl_htp_tank_radius = 4.833997*.0254; 

% masses, kg
mpl_htp_mass_initial       = [];     % set to initialize all tanks to mass_initial/4
mpl_htp_mass_initial_tank1 = 8.155;
mpl_htp_mass_initial_tank2 = 8.155;
mpl_htp_mass_initial_tank3 = 8.155;
mpl_htp_mass_initial_tank4 = 8.155;

% center of tank locations, m
mpl_htp_center_tank1 = [  0.126  0.126  0.062]+mpl_origin_trans;
mpl_htp_center_tank2 = [ -0.126  0.126  0.062]+mpl_origin_trans;
mpl_htp_center_tank3 = [ -0.126 -0.126  0.062]+mpl_origin_trans;
mpl_htp_center_tank4 = [  0.126 -0.126  0.062]+mpl_origin_trans;

% min/max fluid mass
mpl_htp_mass_fillfrac_0   =  0.0;
mpl_htp_mass_fillfrac_100 = 9.061;

% fluid CG locations, from center of tank
mpl_htp_cg_fillfrac_0     = [0.0 0.0 -mpl_htp_tank_radius];
mpl_htp_cg_fillfrac_100   = [0.0 0.0 0.0];

% tank drain rate efficiencies
mpl_htp_drain_efficiency_tank1 = 1.0;
mpl_htp_drain_efficiency_tank2 = 1.0;
mpl_htp_drain_efficiency_tank3 = 1.0;
mpl_htp_drain_efficiency_tank4 = 1.0;

%% initial N2 mass properties

% dimensions, m
mpl_gn2_tank_radius =  3.065*.0254; 
mpl_gn2_tank_length = 16.394*.0254; 

% masses, kg
mpl_gn2_mass_initial       = [];     % set to initialize all tanks to mass_initial/4
mpl_gn2_mass_initial_tank1 = 2.822;
mpl_gn2_mass_initial_tank2 = 2.822;
mpl_gn2_mass_initial_tank3 = 2.822;
mpl_gn2_mass_initial_tank4 = 2.822;
mpl_gn2_mass_initial_tank5 = 0.0;
mpl_gn2_mass_initial_tank6 = 0.0;

% center of tank locations, m
mpl_gn2_center_tank1 = [  0.400   0.0     0.090]+mpl_origin_trans;
mpl_gn2_center_tank2 = [  0.0     0.400   0.090]+mpl_origin_trans;
mpl_gn2_center_tank3 = [ -0.400   0.0     0.090]+mpl_origin_trans;
mpl_gn2_center_tank4 = [  0.0    -0.400   0.090]+mpl_origin_trans;
mpl_gn2_center_tank5 = [  0.256  -0.256  -0.086]+mpl_origin_trans;
mpl_gn2_center_tank6 = [ -0.256   0.256  -0.086]+mpl_origin_trans;

% min/max fluid mass
mpl_gn2_mass_fillfrac_0   = 0.0;
mpl_gn2_mass_fillfrac_100 = 2.822;

% fluid CG locations, from center of tank
mpl_gn2_cg_fillfrac_0     = [0.0 0.0 0.0];
mpl_gn2_cg_fillfrac_100   = [0.0 0.0 0.0];

% tank drain efficiencies
mpl_gn2_drain_efficiency_tank1 = 1.0;
mpl_gn2_drain_efficiency_tank2 = 1.0;
mpl_gn2_drain_efficiency_tank3 = 1.0;
mpl_gn2_drain_efficiency_tank4 = 1.0;
mpl_gn2_drain_efficiency_tank5 = 1.0;
mpl_gn2_drain_efficiency_tank6 = 1.0;

%% zeroed out for origin of coordinates on bottom plane of lander 06/26/14
mpl_footpad_plane_to_origin = 0.25;
mpl_launchstand_height = 0.744;



