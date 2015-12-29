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
% create_inertial_fsw_initial_conditions.m                                %
%                                                                         %
% inputs: [degrees degrees meters]                                        %
% inputs: geodetic latitdue, longitude, altitude wrt WGS84 ellipsoid      %
%                                                                         %
% outputs:                                                                %
% 10/17/14                                                                %
%-------------------------------------------------------------------------%

function [ mtv_eci_state ] = create_inertial_fsw_initial_conditions(planet, utc_time_vec, latitude, longitude, altitude, attitude_vec)

global gbl_param


% move UTC time to seconds since epoch
time_in_seconds = date2seconds( utc_time_vec );


switch planet
    case 'earth'
        
        % create ECEF position of lander
        [ mtv_ecef_position_init ] = earth_lla_to_ecef( latitude, longitude, altitude );

        rotation_rate = gbl_param.earth_rotation_rate;
        
        % create inertial position of lander
        % compute tranform for earth at UTC time
        q_j2000_to_ecef = quat_inv( quaternion_inertial_to_earthfixed(time_in_seconds) );

        
    case 'moon'
        
        % create MCMF position of lander
        [ mtv_ecef_position_init ] = moon_lla_to_mcmf( latitude, longitude, altitude );

        rotation_rate = gbl_param.moon_rotation_rate;
        
        %create inertial position of lander
        % compute tranform for earth at UTC time
        q_j2000_to_ecef = quat_inv( quaternion_inertial_to_moonfixed(time_in_seconds, gbl_param.moon_rotation_rate) );

    otherwise
        error('not a planet....')
end


mtv_eci_state.position = vector_frame_transformation( mtv_ecef_position_init, q_j2000_to_ecef);

% create inertial velocity of lander
% script ONLY WORKS FOR stationary lander on earth surface 
mtv_ecef_velocity_init = [0 0 0];

mtv_eci_state.velocity = vector_frame_transformation( mtv_ecef_velocity_init, q_j2000_to_ecef) + ...
                         cross( vector_frame_transformation( rotation_rate, q_j2000_to_ecef), mtv_eci_state.position);

% create body/eci initial quaternion ***
z_rotation = attitude_vec(1)*pi/180;
y_rotation = attitude_vec(2)*pi/180;
x_rotation = attitude_vec(3)*pi/180;

quat_topo_to_body =[cos(z_rotation/2)*cos(y_rotation/2)*sin(x_rotation/2)-sin(z_rotation/2)*sin(y_rotation/2)*cos(x_rotation/2),...
                    cos(z_rotation/2)*sin(y_rotation/2)*cos(x_rotation/2)+sin(z_rotation/2)*cos(y_rotation/2)*sin(x_rotation/2),...
                    sin(z_rotation/2)*cos(y_rotation/2)*cos(x_rotation/2)-cos(z_rotation/2)*sin(y_rotation/2)*sin(x_rotation/2),...
                    cos(z_rotation/2)*cos(y_rotation/2)*cos(x_rotation/2)+sin(z_rotation/2)*sin(y_rotation/2)*sin(x_rotation/2)];
                                    
dcm_ecef_to_topo = [ -sind(longitude)                 cosd(longitude)                0              ;...
                     -sind(latitude)*cosd(longitude) -sind(latitude)*sind(longitude) cosd(latitude) ;...
                      cosd(latitude)*cosd(longitude)  cosd(latitude)*sind(longitude) sind(latitude) ];

                
q_ecef_to_topo = dcm_to_quat(dcm_ecef_to_topo);

q_j2000_to_topo = quat_mult(q_j2000_to_ecef, q_ecef_to_topo);

mtv_eci_state.quat_eci_to_body = quat_mult(q_j2000_to_topo, quat_topo_to_body);