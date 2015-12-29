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
% csc_kfl_kalman_filter_prep.m                                            %
%                                                                         %
% 06/20/13                                                                %
%-------------------------------------------------------------------------%

kfl_state_init = [ kfl_position_init ; kfl_velocity_init ; kfl_acc_bias_init ;  kfl_gibbs_init ;  kfl_gyro_bias_init];



% Compute Landing Site Position Vector from Lat/Lon/Alt
% kfl_target_site_planet_fixed = (kfl_central_body_radius+kfl_alt_wrt_meanrad)* ...
%                                 [ cosd(kfl_topocentric_latitude)*cosd(kfl_topocentric_longitude)...
%                                   cosd(kfl_topocentric_latitude)*sind(kfl_topocentric_longitude)...
%                                   sind(kfl_topocentric_latitude) ];

switch central_body_name
    case 'moon'
        kfl_target_site_planet_fixed = moon_lla_to_mcmf(kfl_topocentric_latitude, kfl_topocentric_longitude, kfl_alt_wrt_meanrad)    ;
    case 'earth'
        kfl_target_site_planet_fixed = earth_lla_to_ecef(kfl_topocentric_latitude, kfl_topocentric_longitude, kfl_alt_wrt_meanrad)    ;
    otherwise
end
kfl_Tmat_MCMF_to_Topocentric = [ -sind(kfl_topocentric_longitude)                                 cosd(kfl_topocentric_longitude)                                0                             ;...
                                 -sind(kfl_topocentric_latitude)*cosd(kfl_topocentric_longitude) -sind(kfl_topocentric_latitude)*sind(kfl_topocentric_longitude) cosd(kfl_topocentric_latitude);...
                                  cosd(kfl_topocentric_latitude)*cosd(kfl_topocentric_longitude)  cosd(kfl_topocentric_latitude)*sind(kfl_topocentric_longitude) sind(kfl_topocentric_latitude)];

kfl_quat_mcmf_to_topo = dcm_to_quat(kfl_Tmat_MCMF_to_Topocentric);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
%                            Frame Paramters                              %
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %

kfl_topo_z_to_alt = 0;
kfl_topo_to_site_rel = [0 0 norm(0)];