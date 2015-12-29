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

%% Begin rdr init file
%
% Dependencies:
%   
%
% Sources:
%   eleanor's good time fun model...until we get real data from Tomas.
%
%% 

%radar location, relative to origin of body coords
radar_x = 0.549 * cos(pi/4);    %reference drawing by Earl Daley 
radar_y = 0.549 * sin(pi/4);
radar_z = -0.4451;

%rate properties
% radar running at 10hz right now

rdr_percent_error = 0.5 / 100;
rdr_bin_minimum = -0.5;
rdr_bin_maximum = 0.5;

rdr_update_time = 0.1; %10hz update rate

rdr_range_min = 5;
rdr_range_max = 5000;

rdr_null_meas = -100;




%%%%%%%%%%%%%%% END SCRIPT %%%%%%%%%%%%%%%
