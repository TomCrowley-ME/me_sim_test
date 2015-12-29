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

% Always set these in table?


% Old stuff from csc_gdn_pwpf_init

%csc_gdn_roll_body_pointing_vector = [ 0 -1 0]; % keep -Ybody rolled as close to inertial target as possible during descent
%csc_gdn_roll_body_pointing_vector = [0.497 -0.868 0]; % keep body vector rolled as close to inertial target as possible during descent
%csc_gdn_roll_inertial_target_vector = [0.5553 -0.752 -0.3552]; % Align this inertial vector along -Xtopo at epoch.  When landed -Ybody is aligned along -Xtopo.
%csc_gdn_roll_body_pointing_vector = [1 0 0]; % keep body vector rolled as close to inertial target as possible during descent
%csc_gdn_roll_inertial_target_vector = [-0.4848   -0.2695    0.8321]; % Negative lunar inertial radius unit vector for roll guidance alignment with +Xbody during pitched back descent phase
% csc_gdn_roll_body_pointing_vector(1) = 0.0;
% csc_gdn_roll_body_pointing_vector(2) = cosd(atand(ini_tgt_landing_mcmf_pos(3)/norm(ini_tgt_landing_mcmf_pos(1:2))));
% csc_gdn_roll_body_pointing_vector(3) = sind(atand(ini_tgt_landing_mcmf_pos(3)/norm(ini_tgt_landing_mcmf_pos(1:2))));
%csc_gdn_roll_body_pointing_vector = [0 -1 0]; % keep body vector rolled as close to inertial target as possible during descent
%csc_gdn_roll_body_pointing_vector = [-1 0 0]; % keep body vector rolled as close to inertial target as possible during descent
% csc_gdn_roll_inertial_target_vector = cross(ini_position_v,ini_velocity_v)/norm(cross(ini_position_v,ini_velocity_v))
% csc_gdn_aimpoint_body_vector = [0 1 0]; % Body vector for primary aimpoint target


% csc_gdn_roll_body_pointing_vector = [-cosd(60) -sind(60) 0]; % Bias the earth pointing body vector by the amount of the latitude (-60 deg) in body frame
% csc_gdn_roll_inertial_target_vector = [0.9774   -0.2057   -0.0482]; % Earth vector for roll guidance alignment with +Ybody aligned with -Ytopo at landing
% csc_gdn_aimpoint_body_vector = [0 0 1]; % Body vector for primary aimpoint target

arg_roll_body_pointing_vector = [-cosd(60) -sind(60) 0]; % Bias the earth pointing body vector by the amount of the latitude (-60 deg) in body frame
arg_roll_inertial_target_vector = [0.9774   -0.2057   -0.0482]; % Earth vector for roll guidance alignment with +Ybody aligned with -Ytopo at landing
arg_aimpoint_body_vector = [0 0 1]; % Body vector for primary aimpoint target
