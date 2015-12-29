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

%% Begin ini init file 
% Dependencies: 
% csu_ini_initial_conditions_init_a
%
% Source: 
%
%%

ini_Tmat_MCMF_to_Topocentric = [ -sind(ini_topocentric_longitude)                                 cosd(ini_topocentric_longitude)                                0                             ;...
                                 -sind(ini_topocentric_latitude)*cosd(ini_topocentric_longitude) -sind(ini_topocentric_latitude)*sind(ini_topocentric_longitude) cosd(ini_topocentric_latitude);...
                                  cosd(ini_topocentric_latitude)*cosd(ini_topocentric_longitude)  cosd(ini_topocentric_latitude)*sind(ini_topocentric_longitude) sind(ini_topocentric_latitude)];

ini_quat_mcmf_to_topo = dcm_to_quat(ini_Tmat_MCMF_to_Topocentric);

% Compute Landing Site Position Vector from Lat/Lon/Alt
% ini_tgt_landing_mcmf_pos = (central_body_radius+ini_alt_wrt_meanrad)*[ cosd(ini_topocentric_latitude)*cosd(ini_topocentric_longitude)...
%                                                                        cosd(ini_topocentric_latitude)*sind(ini_topocentric_longitude)...
%                                                                        sind(ini_topocentric_latitude) ];

switch central_body_name
    case 'moon'        
        ini_tgt_landing_mcmf_pos = moon_lla_to_mcmf( ini_topocentric_latitude, ini_topocentric_longitude, ini_alt_wrt_meanrad );
 
    case 'earth'
        ini_tgt_landing_mcmf_pos = earth_lla_to_ecef( ini_topocentric_latitude, ini_topocentric_longitude, ini_alt_wrt_meanrad );
        
    otherwise
        
end

ini_quaternion_v = compute_scenario_initial_quatnerion(ini_j2000_or_topo, ini_rotx, ini_roty, ini_rotz, ini_epoch_seconds, ini_moon_rotation_rate, ini_Tmat_MCMF_to_Topocentric, ini_hour, ini_minute, ini_seconds, earth_moon_rotation_matrix_select);


%%%%%%%%%%%%%%% END SCRIPT %%%%%%%%%%%%%%%
