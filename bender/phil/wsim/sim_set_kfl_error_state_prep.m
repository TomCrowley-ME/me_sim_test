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
% sim_set_kfl_error_state_prep.m                                          %
%                                                                         %
% script to initialize filter state at terminla descent start             %
% 07/26/12                                                                %
%-------------------------------------------------------------------------%

kfl_star_tracker_boresight_noise  = kfl_star_tracker_transverse_noise * 10;
kfl_star_tracker_err = (sqrt(2*kfl_star_tracker_transverse_noise^2 + kfl_star_tracker_boresight_noise^2)/3600) / 3; % Start with 1 sigma 90 asec in each axis Comptech MST (DTU transverse 1 sigma 1 asec and roll 8 asec)

random_vec = rand(1,3);
random_unit_vec = random_vec/norm(random_vec);
kfl_noise_quaternion = [ random_unit_vec(1)*sind(kfl_star_tracker_err/2) random_unit_vec(2)*sind(kfl_star_tracker_err/2) ...
                         random_unit_vec(3)*sind(kfl_star_tracker_err/2) cosd(kfl_star_tracker_err)];

kfl_quat_init = quat_mult( ini_quaternion_v, kfl_noise_quaternion )';


kfl_topo_z_to_alt = 0;
kfl_topo_to_site_rel = [0 0 0];

clear random_vec random_unit_vec


