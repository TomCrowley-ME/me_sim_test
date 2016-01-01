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

vac_alpha_gain = 1/10;
vac_alpha_gain = 0.2;
% vac_alpha_gain = 20.0;
vac_rotx_deadband_minus = 1*pi/180;
vac_rotx_deadband = 1*pi/180;

vac_roty_deadband_minus = 1*pi/180;
vac_roty_deadband = 1*pi/180;

vac_rotz_deadband_minus = 1*pi/180;
vac_rotz_deadband = 1*pi/180;

% Vernier ACS
% +x torque given by: 18,22
% -x torque given by: 16,24
% +y torque given by: 13,21
% -y torque given by: 15,19
% +z torque given by: 17,23
% -z torque given by: 14,20

vac_thruster_alloc_vernier_x_plus  = [18,22];
vac_thruster_alloc_vernier_x_minus = [16,24];
vac_thruster_alloc_vernier_y_plus  = [13,21];
vac_thruster_alloc_vernier_y_minus = [15,19];
vac_thruster_alloc_vernier_z_plus  = [17,23];
vac_thruster_alloc_vernier_z_minus = [14,20];

vac_thruster_id_offset = 12;