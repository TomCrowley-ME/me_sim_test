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

vac_gim_x_act_c1 = 0.1;
vac_gim_x_act_c2 = 0.2;
vac_gim_x_act_lx1c = 0.3; % lx1c must always be greater than c1
vac_gim_x_act_lz1c = 0.4;

vac_gim_y_act_c1 = 0.1;
vac_gim_y_act_c2 = 0.2;
vac_gim_y_act_ly1c = 0.3; % lx1c must always be greater than c1
vac_gim_y_act_lz1c = 0.4;

vac_gim_kp = -0.05;
vac_gim_ki =  0.0;
vac_gim_kd = -0.5;

vac_gim_cmd_limit = 0.1;   % [meter]  gimbal command length limit
vac_gim_cmd_bits  = 16;    %          gimbal command analog-to-digital bits

