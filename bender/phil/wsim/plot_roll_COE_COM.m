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

% Plot Roll Pointing Accuracy to Nadir and to Earth Vector

clear minus_moon_radius_in_minus_z_body roll_tgt_eci_in_body
% Inertial nadir vector just before touchdown
% t = truth.sim_rtk_pos_eci.Time;
i_start = 60001;
i_stop  = 80001;
i_start = 1;
i_stop  = size(truth.sim_rtk_pos_eci.Time,1);
t = truth.sim_rtk_pos_eci.Time(i_start:i_stop);

rtk_pos_eci_unit = -truth.sim_rtk_pos_eci.Data(end,:)/sqrt(truth.sim_rtk_pos_eci.Data(end,1)^2+truth.sim_rtk_pos_eci.Data(end,2)^2+truth.sim_rtk_pos_eci.Data(end,3)^2);

% Inertial earth vector from lander just before touchdown - specified in
% csc_gdn_pwpf_init.m
% csc_gdn_roll_inertial_target_vector

csc_gdn_inertial_ptg_tgt_vector = [0.238145521 0.909481949 0.340777488];

% Transform from inertial to lander body frame
% for i =1:size(truth.sim_rrk_q_body_from_eci.Data,1)
for i =i_start:i_stop
    minus_moon_radius_in_minus_z_body(i-(i_start-1),:) = quatrotate([truth.sim_rrk_q_body_from_eci.Data(i,4) truth.sim_rrk_q_body_from_eci.Data(i,1:3)],rtk_pos_eci_unit)/norm(quatrotate([truth.sim_rrk_q_body_from_eci.Data(i,4) truth.sim_rrk_q_body_from_eci.Data(i,1:3)],rtk_pos_eci_unit));
    roll_tgt_eci_in_body(i-(i_start-1),:) = quatrotate([truth.sim_rrk_q_body_from_eci.Data(i,4) truth.sim_rrk_q_body_from_eci.Data(i,1:3)],csc_gdn_roll_inertial_target_vector)/norm(quatrotate([truth.sim_rrk_q_body_from_eci.Data(i,4) truth.sim_rrk_q_body_from_eci.Data(i,1:3)],csc_gdn_roll_inertial_target_vector));
    inertial_ptg_tgt(i-(i_start-1),:) = quatrotate([truth.sim_rrk_q_body_from_eci.Data(i,4) truth.sim_rrk_q_body_from_eci.Data(i,1:3)],csc_gdn_inertial_ptg_tgt_vector)/norm(quatrotate([truth.sim_rrk_q_body_from_eci.Data(i,4) truth.sim_rrk_q_body_from_eci.Data(i,1:3)],csc_gdn_inertial_ptg_tgt_vector));
    topo_x_in_body(i-(i_start-1),:) = quatrotate([truth.sim_sim_q_topo_to_body.Data(i,4) truth.sim_sim_q_topo_to_body.Data(i,1:3)],[1 0 0]);
    topo_y_in_body(i-(i_start-1),:) = quatrotate([truth.sim_sim_q_topo_to_body.Data(i,4) truth.sim_sim_q_topo_to_body.Data(i,1:3)],[0 1 0]);
    topo_z_in_body(i-(i_start-1),:) = quatrotate([truth.sim_sim_q_topo_to_body.Data(i,4) truth.sim_sim_q_topo_to_body.Data(i,1:3)],[0 0 1]);

end

figure;plot(t,minus_moon_radius_in_minus_z_body(:,1:3),'linewidth',2);grid on;title('Center of Moon in Body Frame Unit Vector','fontsize',14);xlabel('Time (sec)','fontsize',14);ylabel('Unit Vector Components','fontsize',14);
legend('COM Lander X-Component','COM Lander Y-Component','COM Lander Z-Component')
saveas(gcf,'COMvec.png');saveas(gcf,'COMvec.fig')

figure;plot(t,acosd(minus_moon_radius_in_minus_z_body(:,1:3)),'linewidth',2);grid on;title('Center of Moon Angles to Body Frame Unit Vector','fontsize',14);xlabel('Time (sec)','fontsize',14);ylabel('Angle From Inertial Vector','fontsize',14);
legend('COM Angle to Lander X','COM Angle to Lander Y','COM Angle to Lander Z')
saveas(gcf,'COMang.png');saveas(gcf,'COMang.fig')

figure;plot(t,roll_tgt_eci_in_body(:,1:3),'linewidth',2);grid on;title('Roll Target in Body Frame Unit Vector','fontsize',14);xlabel('Time (sec)','fontsize',14);ylabel('Unit Vector Components','fontsize',14);
legend('Roll Target Lander X-Component','Roll Target Lander Y-Component','Roll Target Lander Z-Component')
saveas(gcf,'RollTgtvec.png');saveas(gcf,'RollTgtvec.fig')

figure;plot(t,acosd(roll_tgt_eci_in_body(:,1:3)),'linewidth',2);grid on;title('Roll Target Angles to Body Frame Unit Vector','fontsize',14);xlabel('Time (sec)','fontsize',14);ylabel('Angle From Inertial Vector','fontsize',14);
legend('Roll Target Angle to Lander X','Roll Target Angle to Lander Y','Roll Target Angle to Lander Z')
saveas(gcf,'RollTgtang.png');saveas(gcf,'RollTgtang.fig')

figure;plot(t,inertial_ptg_tgt(:,1:3),'linewidth',2);grid on;title('Inertial Pointing Target in Body Frame Unit Vector','fontsize',14);xlabel('Time (sec)','fontsize',14);ylabel('Unit Vector Components','fontsize',14);
legend('Ptg Tgt Lander X-Component','Ptg Tgt Lander Y-Component','Ptg Tgt Lander Z-Component')
saveas(gcf,'PtgTgtvec.png');saveas(gcf,'PtgTgtvec.fig')

figure;plot(t,acosd(inertial_ptg_tgt(:,1:3)),'linewidth',2);grid on;title('Inertial Pointing Target Angles to Body Frame Unit Vector','fontsize',14);xlabel('Time (sec)','fontsize',14);ylabel('Unit Vector Components','fontsize',14);
legend('Ptg Tgt Angle to Lander X','Ptg Tgt Angle to Lander Y','Ptg Tgt Angle to Lander Z')
saveas(gcf,'PtgTgtang.png');saveas(gcf,'PtgTgtang.fig')

figure;plot(t,topo_x_in_body(:,1:3),'linewidth',2);grid on;title('Topocentric X-Component in Body Frame Unit Vector','fontsize',14);xlabel('Time (sec)','fontsize',14);ylabel('Unit Vector Components','fontsize',14);
legend('Topocentric X in Lander X-Component','Topocentric X in Lander Y-Component','Topocentric X in Lander Z-Component')
saveas(gcf,'TopoXvec.png');saveas(gcf,'TopoXvec.fig')

figure;plot(t,topo_y_in_body(:,1:3),'linewidth',2);grid on;title('Topocentric Y-Component in Body Frame Unit Vector','fontsize',14);xlabel('Time (sec)','fontsize',14);ylabel('Unit Vector Components','fontsize',14);
legend('Topocentric Y in Lander X-Component','Topocentric Y in Lander Y-Component','Topocentric Y in Lander Z-Component')
saveas(gcf,'TopoYvec.png');saveas(gcf,'TopoYvec.fig')

figure;plot(t,topo_z_in_body(:,1:3),'linewidth',2);grid on;title('Topocentric Z-Component in Body Frame Unit Vector','fontsize',14);xlabel('Time (sec)','fontsize',14);ylabel('Unit Vector Components','fontsize',14);
legend('Topocentric Z in Lander X-Component','Topocentric Z in Lander Y-Component','Topocentric Z in Lander Z-Component')
saveas(gcf,'TopoZvec.png');saveas(gcf,'TopoZvec.fig')

figure;plot(t,acosd(topo_x_in_body(:,1:3)),'linewidth',2);grid on;title('Topocentric X Angles to Body Frame Unit Vector','fontsize',14);xlabel('Time (sec)','fontsize',14);ylabel('Angle From Inertial Vector','fontsize',14);
legend('Topo-X Angle to Lander X','Topo-X Angle to Lander Y','Topo-X Angle to Lander Z')
saveas(gcf,'TopoXang.png');saveas(gcf,'TopoXang.fig')






