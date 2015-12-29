if strncmp(computer,'PCWIN',5)
    sep = '\';
elseif strncmp(computer,'GLNX',4)
    sep = '/';
elseif strncmp(computer,'MACI64',6)
    sep = '/';
end

%%
load(cat(2,'scn84_wsim_data',sep,'sim_tlm_msg.mat'))
x=size(data.pos_topo.Time,1);
n=2000+min(find(data.pos_topo.Data(2000:end,3)==data.pos_topo.Data(2000-1:end-1,3)));
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
axis([15 40 get(gca,'ylim')])

figure
plot(sqrt(data.pos_topo.Data(:,1).^2+data.pos_topo.Data(:,2).^2),data.pos_topo.Data(:,3),'LineWidth',3),grid
xlabel('Distance, m'),ylabel('Altitude, m')
title('Trajectory')
set(gcf,'Name','Trajectory')
fprintf('max range = %7.2f\n',r)
fprintf('max alt   = %7.2f\n',max(data.pos_topo.Data(:,3)))
% fprintf('takeoff   = %7.2f\n',data.pos_topo.Time(min(find(FlightPath.Vtrue.Data(1:2000)>1e-4))))
fprintf('landing   = %7.2f\n',data.pos_topo.Time(n))
% fprintf('flight dt = %7.2f\n',data.pos_topo.Time(n)-data.pos_topo.Time(min(find(FlightPath.Vtrue.Data(1:2000)>1e-4))))

%%
load(cat(2,'scn84_wsim_data',sep,'sim_data_bus_msg.mat'))
figure
plot(data.mass_props_msg.mass,'LineWidth',3),grid
xlabel('Time, sec'),ylabel('Mass, kg')
title('Vehicle Mass')
set(gcf,'Name','Vehicle Mass')
fprintf('fuel used = %7.2f\n',max(data.mass_props_msg.mass)-min(data.mass_props_msg.mass))

%%
% FlightPath.Alpha.Data(n:end)=FlightPath.Alpha.Data(n)*ones(x-n+1,1);
% 
% j=min(find(FlightPath.Alpha.Time>16.1));
% FlightPath.Alpha.Data(1:j-1)=FlightPath.Alpha.Data(j)*ones(j-1,1);
% 
% figure
% plot(FlightPath.Alpha.Time,FlightPath.Alpha.Data*180/pi,'LineWidth',3),grid
% xlabel('Time, sec'),ylabel('Angle, deg')
% title('Angle of Attack')
% set(gcf,'Name','Angle of Attack')
% axis([15 40 get(gca,'ylim')])

%%
% figure
% plot(FlightPath.Vtrue,'LineWidth',3),grid
% xlabel('Time, sec'),ylabel('Velocity, m/s')
% title('True Airspeed')
% set(gcf,'Name','True Airspeed')
% axis([15 40 get(gca,'ylim')])

%%
% Drag=abs(AeroForces.Data(:,3).*cosd(FlightPath.Alpha.Data)-AeroForces.Data(:,1).*sind(FlightPath.Alpha.Data));
% Lift=AeroForces.Data(:,3).*sind(FlightPath.Alpha.Data)+AeroForces.Data(:,1).*cosd(FlightPath.Alpha.Data);
% figure
% plot(AeroForces.Time,Lift,AeroForces.Time,Drag,'LineWidth',3),grid
% xlabel('Time, sec'),ylabel('Force, N')
% title('Aerodynamic Lift and Drag')
% set(gcf,'Name','Aerodynamic Lift and Drag')
% legend('Lift','Drag','Location','NorthWest')
% axis([15 40 get(gca,'ylim')])
% 
% figure
% plot(AeroMoments.Time,AeroMoments.Data,'LineWidth',3),grid
% xlabel('Time, sec'),ylabel('Torque, Nm')
% title('Aerodynamic Moments')
% set(gcf,'Name','Aerodynamic Moments')
% legend('Roll','Pitch','Yaw','Location','NorthEast')
% axis([15 40 get(gca,'ylim')])
% 
% figure
% plot(AeroForces.Time,AeroForces.Data,'LineWidth',3),grid
% xlabel('Time, sec'),ylabel('Force, N')
% title('Aerodynamic Forces')
% set(gcf,'Name','Aerodynamic Forces')
% legend('X','Y','Z','Location','NorthEast')
% axis([15 40 get(gca,'ylim')])

%%
% figure
% plot(ThrusterTorques,'LineWidth',3),grid
% xlabel('Time, sec'),ylabel('Torque, Nm')
% title('Thruster Torques')
% set(gcf,'Name','Thruster Torques')
% legend('Roll','Pitch','Yaw','Location','NorthEast')
% axis([15 40 get(gca,'ylim')])
% 
% figure
% plot(ThrusterForces,'LineWidth',3),grid
% xlabel('Time, sec'),ylabel('Force, N')
% title('Thruster Forces')
% set(gcf,'Name','Thruster Forces')
% legend('X','Y','Z','Location','NorthEast')
% axis([15 40 get(gca,'ylim')])

