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

% [data,header] = read_data('MTV Time with Altitude Range AoA.txt');
% 
% figure
% plot(data(:,1),data(:,3),data(:,1),data(:,2),'LineWidth',3),grid
% xlabel('Time, sec'),ylabel('Distance, m')
% legend('Altitude','Range','Location','NorthWest')
% title('Altitude and Range')
% 
% figure
% plot(data(:,2),data(:,3),'LineWidth',3),grid
% xlabel('Time, sec'),ylabel('Distance, m')
% xlabel('Range, m'),ylabel('Altitude, deg')
% title('Range Throw Trajectory')
% axis([10 317 10 90])
% 
% figure
% plot(data(:,1),data(:,4),'LineWidth',3),grid
% xlabel('Time, sec'),ylabel('Angle, deg')
% title('Angle of Attack')

%%
load('scn82_wsim_data\sim_tlm_msg.mat')
x=size(data.pos_topo.Time,1);
n=2000+min(find(data.pos_topo.Data(2000:end,3)<0));
data.pos_topo.Data(n:end,1)=data.pos_topo.Data(n,1)*ones(x-n+1,1);
data.pos_topo.Data(n:end,2)=data.pos_topo.Data(n,2)*ones(x-n+1,1);
data.pos_topo.Data(n:end,3)=data.pos_topo.Data(n,3)*ones(x-n+1,1);
r=norm(data.pos_topo.Data(n,:));

figure
plot(data.pos_topo.Time,data.pos_topo.Data(:,3),data.pos_topo.Time,sqrt(data.pos_topo.Data(:,1).^2+data.pos_topo.Data(:,2).^2),'LineWidth',3),grid
xlabel('Time, sec'),ylabel('Distance, m')
legend('Altitude','Range','Location','NorthWest')
title('Altitude and Range')
set(gcf,'Name','Altitude and Range')
axis([10 30 get(gca,'ylim')])

figure
plot(sqrt(data.pos_topo.Data(:,1).^2+data.pos_topo.Data(:,2).^2),data.pos_topo.Data(:,3),'LineWidth',3),grid
xlabel('Distance, m'),ylabel('Altitude, m')
% text(r/2,120,sprintf('max = %4.1f',r))
% text(r/2,70,sprintf('flight time = %4.1f',data.pos_topo.Time(n)))
title('Trajectory')
set(gcf,'Name','Trajectory')

%%
load('scn82_wsim_data\sim_data_bus_msg.mat')
figure
plot(data.mass_props_msg.mass,'LineWidth',3),grid
xlabel('Time, sec'),ylabel('Mass, kg')
title('Vehicle Mass')
set(gcf,'Name','Vehicle Mass')
% text(35,215,sprintf('fuel used = %4.1f',260-min(data.mass_props_msg.mass)))

%%
FlightPath.Alpha.Data(n:end)=FlightPath.Alpha.Data(n)*ones(x-n+1,1);

figure
plot(FlightPath.Alpha.Time,FlightPath.Alpha.Data*180/pi,'LineWidth',3),grid
xlabel('Time, sec'),ylabel('Angle, deg')
title('Angle of Attack')
set(gcf,'Name','Angle of Attack')
axis([10 60 get(gca,'ylim')])

%%
figure
plot(FlightPath.Vtrue,'LineWidth',3),grid
xlabel('Time, sec'),ylabel('Velocity, m/s')
title('True Airspeed')
set(gcf,'Name','True Airspeed')
axis([10 60 get(gca,'ylim')])

%%
Drag=abs(AeroForces.Data(:,3).*cosd(FlightPath.Alpha.Data)-AeroForces.Data(:,1).*sind(FlightPath.Alpha.Data));
Lift=AeroForces.Data(:,3).*sind(FlightPath.Alpha.Data)+AeroForces.Data(:,1).*cosd(FlightPath.Alpha.Data);
figure
plot(AeroForces.Time,Lift,AeroForces.Time,Drag,'LineWidth',3),grid
xlabel('Time, sec'),ylabel('Force, N')
title('Aerodynamic Lift and Drag')
set(gcf,'Name','Aerodynamic Lift and Drag')
legend('Lift','Drag','Location','NorthWest')
axis([10 60 get(gca,'ylim')])

figure
plot(AeroMoments.Time,AeroMoments.Data,'LineWidth',3),grid
xlabel('Time, sec'),ylabel('Torque, Nm')
title('Aerodynamic Moments')
set(gcf,'Name','Aerodynamic Moments')
legend('Roll','Pitch','Yaw','Location','NorthEast')
axis([10 60 get(gca,'ylim')])

figure
plot(AeroForces.Time,AeroForces.Data,'LineWidth',3),grid
xlabel('Time, sec'),ylabel('Force, N')
title('Aerodynamic Forces')
set(gcf,'Name','Aerodynamic Forces')
legend('X','Y','Z','Location','NorthEast')
axis([10 60 get(gca,'ylim')])

%%
figure
plot(ThrusterTorques,'LineWidth',3),grid
xlabel('Time, sec'),ylabel('Torque, Nm')
title('Thruster Torques')
set(gcf,'Name','Thruster Torques')
legend('Roll','Pitch','Yaw','Location','NorthEast')
axis([10 60 get(gca,'ylim')])

figure
plot(ThrusterForces,'LineWidth',3),grid
xlabel('Time, sec'),ylabel('Force, N')
title('Thruster Forces')
set(gcf,'Name','Thruster Forces')
legend('Roll','Pitch','Yaw','Location','NorthEast')
axis([10 70 get(gca,'ylim')])

