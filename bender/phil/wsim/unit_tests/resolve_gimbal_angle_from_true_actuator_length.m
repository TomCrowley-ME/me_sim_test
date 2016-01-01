%x=((y-R*(1-1/(1+(tan(w)+c/d)^2)))^0.5)^2+((z+R/((1+(tan(w)+c/d)^2))^0.5)^2)^0.5

% gim_y_act_c1 = 0.1;
% gim_y_act_c2 = 0.2;
% gim_y_act_ly1c = 0.3; % lx1c must always be greater than c1
% gim_y_act_lz1c = 0.4;
% gim_x_act_c1 = 0.1;
% gim_x_act_c2 = 0.2;
% gim_x_act_lx1c =  0.3; % lx1c must always be greater than c1
% gim_x_act_lz1c = 0.4;
% % c1 = gim_y_act_c1;
% % c2 = gim_y_act_c2;
% % lx1c = gim_y_act_ly1c;
% % lz1c = gim_y_act_lz1c;
% 
% Rmount = sqrt(gim_y_act_c1^2 + gim_y_act_c2^2);
% 
% % x = gim_y_act_ly1c;
% % z = gim_y_act_lz1c;
% 
% % A = gim_y_act_c1;
% % B = gim_y_act_c2;
% % R= sqrt(A^2+B^2);
% 
% % Lcmd = ((lx1c - Rmount*(1 - 1/(1+(tan(alpha_rad_cmd) + c1/c2)^2))^0.5)^2 + (lz1c + Rmount/(1+(tan(alpha_rad_cmd)+c1/c2)^2)^0.5)^2)^0.5
% % 
% % Lnull = ((gim_y_act_ly1c-gim_y_act_c1)^2 + (gim_y_act_lz1c+gim_y_act_c2)^2)^0.5
% % 
% % Lerr = Lcmd - Lnull % from flight software command
% % 
% alpha_rad_resolve = (-15*pi/180:0.03*pi/180:15*pi/180);
% % 
% for i=1:1001
%     Lerr_y_table(i) = ((gim_y_act_ly1c - Rmount*(1 - 1/(1+(tan(alpha_rad_resolve(i)) + gim_y_act_c1/gim_y_act_c2)^2))^0.5)^2 + (gim_y_act_lz1c + Rmount/(1+(tan(alpha_rad_resolve(i))+gim_y_act_c1/gim_y_act_c2)^2)^0.5)^2)^0.5 - Lnull;
%     Lerr_x_table(i) = ((gim_x_act_lx1c - Rmount*(1 - 1/(1+(tan(alpha_rad_resolve(i)) + gim_x_act_c1/gim_x_act_c2)^2))^0.5)^2 + (gim_x_act_lz1c + Rmount/(1+(tan(alpha_rad_resolve(i))+gim_x_act_c1/gim_x_act_c2)^2)^0.5)^2)^0.5 - Lnull;
% end
% 
% % Lerr_resolve = Lerr
% % alpha_rad_resolve_1 = interp1(Lerr_table,alpha_rad_resolve,Lerr_resolve)
% % alpha_deg_resolve_1 = alpha_rad_resolve_1*180/pi
% 
% tpl_x_gimbal_actuator_to_angle = [alpha_rad_resolve;Lerr_x_table]';
% tpl_y_gimbal_actuator_to_angle = [alpha_rad_resolve;Lerr_y_table]';

% Kp = 0.1;
% Ki = 0;
% Kd = 1;
% N = 15;

Km = 0.01;
Jm = 0.01;
Bm = 0.1;
Ke = 0.01;
Kt = 0.01;
Lm = 0.5;
Rm = 1;
nb = 2e-2/(2*pi);
Kl = 500;
Kl = 5000;


% Lresolved = ((lx1c - Rmount*(1 - 1/(1+(tan(alpha_rad_cmd) + c1/c2)^2))^0.5)^2 + (lz1c + Rmount/(1+(tan(alpha_rad_cmd)+c1/c2)^2)^0.5)^2)^0.5
% Lerr = Lresolved - Lnull % from the resolved L
