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

%te_current_inertial_north.m                                      %
%                                                                         %
% inputs: [degrees degrees meters]                                        %
% inputs: geodetic latitdue, longitude, altitude wrt WGS84 ellipsoid      %
%                                                                         %
% outputs:                                                                %
% 10/17/14                                                                %
%-------------------------------------------------------------------------%

function [ north_eci ] = calculate_current_inertial_north(utc_time_vec, latitude, longitude)

% move UTC time to seconds since epoch
time_in_seconds = date2seconds( utc_time_vec );

% create inertial position of lander
    % compute tranform for earth at UTC time
    q_j2000_to_ecef = quat_inv( quaternion_inertial_to_earthfixed(time_in_seconds) );

dcm_ecef_to_topo = [ -sind(longitude)                 cosd(longitude)                0              ;...
                     -sind(latitude)*cosd(longitude) -sind(latitude)*sind(longitude) cosd(latitude) ;...
                      cosd(latitude)*cosd(longitude)  cosd(latitude)*sind(longitude) sind(latitude) ];

north_topo = [0 1 0]';
    
north_eci = vector_frame_transformation((dcm_ecef_to_topo'*north_topo)', q_j2000_to_ecef);

