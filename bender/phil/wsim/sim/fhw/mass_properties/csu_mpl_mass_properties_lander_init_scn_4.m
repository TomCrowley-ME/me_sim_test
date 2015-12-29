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

% Source: SSPO-MLL-BL-20070427-REV0.3.pdf (copied by Ian 4/12/11)

%dry and wet masses
mpl_mass_dry = 104.6;
mpl_mass_wet = mpl_mass_dry +  26.3;    % propellant mass

% Source: Dry Lander Mass Props 11192012.pdf from EJ Sabbathia
mpl_lander_mass_dry = 151.6082;
mpl_lander_mass_dry = 144.7; % Updated from MEL (Tom Gardner 12/20/2012
mpl_lander_mass_wet = mpl_lander_mass_dry +  33.8718;
mpl_lander_mass_wet = mpl_lander_mass_dry +  39.3; % Updated from MEL (Tom Gardner 12/20/2012
mpl_mass_dry = mpl_lander_mass_dry;
mpl_mass_wet = mpl_lander_mass_wet;
mpl_mass_dry = 123.9;                   % Dry mass DIY single stage (Tom Gardner 05/30/2013)
mpl_mass_wet = mpl_mass_dry +  22.1;    % Wet mass DIY single stage at post Braking Burn 
mpl_mass_wet = mpl_mass_dry +  135;     % Wet mass DIY single stage at pre Braking Burn 

% Source: Common Bus Mass Properties slides by Owen 1/18/08
%Lander dry and wet cg locations (wrt vehicle frame)
mpl_cgx_location_dry =   0; %-0.00335;
mpl_cgy_location_dry =   0; %-0.00296;
mpl_cgz_location_dry =   0.3204 -.477;

% Source: Dry Lander Mass Props 11192012.pdf from EJ Sabbathia
mpl_cgx_location_dry =   -0.0143;
mpl_cgy_location_dry =   -0.0054;
mpl_cgz_location_dry =   -0.2947;

mpl_cgx_location_wet =   0; %0.00456;
mpl_cgy_location_wet =   0; %0.00489;
mpl_cgz_location_wet =   0.3242-.477;

% Source: Wet Lander Mass Props 11192012.pdf from EJ Sabbathia
mpl_cgx_location_wet =   -0.0029;
mpl_cgy_location_wet =    0.0025;
mpl_cgz_location_wet =   -0.3415;

% Source: Dry Lander Mass Props - Envelope Test
mpl_cgx_location_dry =   0.0; %+0.0085;
mpl_cgy_location_dry =   0.0; %+0.0085;
mpl_cgz_location_dry =   -0.2947;

% Source: Wet Lander Mass Props - Envelope Test
mpl_cgx_location_wet =   0.0; %-0.0085;
mpl_cgy_location_wet =   0.0; %-0.0085;
mpl_cgz_location_wet =   -0.3415;

%Lander dry and wet inertias
mpl_Ixx_dry = 6.4101;
mpl_Iyy_dry = 7.7955;
mpl_Izz_dry = 10.1401;
mpl_Ixy_dry = -.9035;
mpl_Iyz_dry = -.9123;
mpl_Ixz_dry = -.6221;

% Source: Dry Lander Mass Props 11192012.pdf from EJ Sabbathia
mpl_Ixx_dry = 31.6417;
mpl_Iyy_dry = 30.4707;
mpl_Izz_dry = 25.0504;
mpl_Ixy_dry = -0.4445;
mpl_Iyz_dry =  0.0232;
mpl_Ixz_dry =  0.1418;

mpl_Ixx_wet = 14.3607;
mpl_Iyy_wet = 15.7463;
mpl_Izz_wet = 11.0443;
mpl_Ixy_wet = -.9016;
mpl_Iyz_wet = -1.0355;
mpl_Ixz_wet = -.7379;

% Source: Wet Lander Mass Props 11192012.pdf from EJ Sabbathia
mpl_Ixx_wet = 44.1997;
mpl_Iyy_wet = 45.3217;
mpl_Izz_wet = 30.8488;
mpl_Ixy_wet = -0.5389;
mpl_Iyz_wet = -0.1414;
mpl_Ixz_wet =  0.0531;

% Source: Wet Lander Mass Props educated guess JT Kaidy 06/10/2013
mpl_Ixx_wet = 80;
mpl_Iyy_wet = 80;
mpl_Izz_wet = 80;
mpl_Ixy_wet = -0.5389;
mpl_Iyz_wet = -0.1414;
mpl_Ixz_wet =  0.0531;

mpl_footpad_plane_to_origin = 0.988;
