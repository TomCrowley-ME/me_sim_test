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
% earth_lla_to_ecef.m                                                     %
%                                                                         %
% inputs: [degrees degrees meters]                                        %
% inputs: geodetic latitdue, longitude, altitude wrt WGS84 ellipsoid      %
%                                                                         %
% outputs: ECEF position in meters                                        %
% 10/17/14                                                                %
%-------------------------------------------------------------------------%

function [ pos_ecef ] = earth_lla_to_ecef( lat, long, alt )

global gbl_param

% transform flattening parameter into ellipsoid eccentricity
e_squared =  gbl_param.earth_flattening * (2-gbl_param.earth_flattening) ;

% find ellipsoid radius at current latitude
R = gbl_param.earth_radius ./ ( 1 - (e_squared) * sind(lat).^2 ).^0.5;

% convert to ECEF using ellipsoid model
pos_ecef(:,1) = (R + alt) .* cosd(lat) .* cosd(long);
pos_ecef(:,2) = (R + alt) .* cosd(lat) .* sind(long);
pos_ecef(:,3) = ( (1-e_squared) .* R + alt) .* sind(lat);