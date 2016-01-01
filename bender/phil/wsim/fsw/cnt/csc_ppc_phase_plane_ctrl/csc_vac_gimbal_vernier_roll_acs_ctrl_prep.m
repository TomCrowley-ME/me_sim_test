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

vac_gim_rmount_x = sqrt(vac_gim_x_act_c1^2 + vac_gim_x_act_c2^2);
vac_gim_rmount_y = sqrt(vac_gim_y_act_c1^2 + vac_gim_y_act_c2^2);

vac_gim_null_ang_x = ((vac_gim_x_act_lx1c-vac_gim_x_act_c1)^2 + (vac_gim_x_act_lz1c+vac_gim_x_act_c2)^2)^0.5;
vac_gim_null_ang_y = ((vac_gim_y_act_ly1c-vac_gim_y_act_c1)^2 + (vac_gim_y_act_lz1c+vac_gim_y_act_c2)^2)^0.5;

alpha_rad_resolve = (-15*pi/180:0.03*pi/180:15*pi/180);
% 
for i=1:1001
   Lerr_x_table(i) = ((vac_gim_x_act_lx1c - vac_gim_rmount_x*(1 - 1/(1+(tan(alpha_rad_resolve(i)) + vac_gim_x_act_c1/vac_gim_x_act_c2)^2))^0.5)^2 +...
       (vac_gim_x_act_lz1c + vac_gim_rmount_x/(1+(tan(alpha_rad_resolve(i))+vac_gim_x_act_c1/vac_gim_x_act_c2)^2)^0.5)^2)^0.5 - vac_gim_null_ang_x;
   Lerr_y_table(i) = ((vac_gim_y_act_ly1c - vac_gim_rmount_y*(1 - 1/(1+(tan(alpha_rad_resolve(i)) + vac_gim_y_act_c1/vac_gim_y_act_c2)^2))^0.5)^2 +...
       (vac_gim_y_act_lz1c + vac_gim_rmount_x/(1+(tan(alpha_rad_resolve(i))+vac_gim_y_act_c1/vac_gim_y_act_c2)^2)^0.5)^2)^0.5 - vac_gim_null_ang_y;
end

tpl_x_gimbal_actuator_to_angle = [alpha_rad_resolve;Lerr_x_table]';
tpl_y_gimbal_actuator_to_angle = [alpha_rad_resolve;Lerr_y_table]';

Kp = vac_gim_kp;
Ki = vac_gim_ki;
Kd = vac_gim_kd;

