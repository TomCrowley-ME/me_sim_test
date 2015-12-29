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
% gbl_global_parameters_init.m                                            %
%                                                                         %
% only variables that are physical properties of the universe belong here %
%                                                                         %
% 03/27/14                                                                %
%-------------------------------------------------------------------------%

global gbl_param

%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - - -%
% %                         MOON PARAMETERS                          % %
 
gbl_param.moon_radius = 1737400; %meters 

gbl_param.moon_rotation_rate = [0 0 2*pi/(86400*27.32166155)]; % rad/sec (13.1763582292088 deg/day)  

gbl_param.moon_rotation_derivative = 86400*(180/pi)*gbl_param.moon_rotation_rate(3);

gbl_param.moon_gravity_mu = 4.902801076e12; % m^3 / s^2

cb = CentralBodyMoon_init;
gbl_param.moon_flattening = cb.flatten;  % set to 0.0012 with call to CentralBodyMoon_init with Equatorial Radius == 1738140 and Polar Radius == 1735970.  Allows both MC and single runs to be consistent
gbl_param.moon_flattening = 0.000; % none, set to 0.0012 for oblate, or zero for spherical body

gbl_param.moon_rotation_matrix = 0; 

%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - - -%
% %                        EARTH PARAMETERS                          % %

gbl_param.earth_radius =6378137; %meters 

gbl_param.earth_rotation_rate = [0 0 1.000000001*7.292115e-5]; % Earth rate 7.292115e-5 rad/sec

gbl_param.earth_rotation_derivative = 86400*(180/pi)*gbl_param.earth_rotation_rate(3);

gbl_param.earth_gravity_mu = 3.986004418e14; % m^3 / s^2

gbl_param.earth_flattening = 1/298.257223563; % none

gbl_param.earth_rotation_matrix = 1; 

%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - - -%
% %                         SUN PARAMETERS                           % %

gbl_param.sun_radius = 695500000; %meters 
          
gbl_param.sun_gravity_mu = 1.32712440018e20; % m^3 / s^2      
          

%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - - -%
% %                      TIME/EPOCH PARAMETERS                       % %

gbl_param.epoch_date_string = '2000-1-12:00:00';

gbl_param.epoch_julian_date = date2jd( gbl_param.epoch_date_string ); % julian date at epoch

gbl_param.epoch_seconds = date2seconds(gbl_param.epoch_date_string);
