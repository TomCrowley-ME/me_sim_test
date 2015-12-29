%close all,clear all

%% Define Excel Source file and Matlab Data file
excelFile = 'est_mtv_msg.csv';     % Excel file name
Sheet     = 'est_mtv_msg';         % Sheet
matFile   = 'est_mtv_msg.mat';     % Mat file name

%% Read the data
if strncmp(computer,'PCWIN',5)
    [data , txt, raw] = xlsread(excelFile, Sheet);
else
    data = csvread(excelFile,1,0);
end
rows=size(data,1);

%% Parse the data
est_mtv_msg.time                    =data(:,1);
est_mtv_msg.landed                  =data(:,3);
est_mtv_msg.integrating             =data(:,4);
est_mtv_msg.gps_valid               =data(:,5);
est_mtv_msg.samples_since_valid_imu =data(:,6);
est_mtv_msg.convergence             =data(:,7);
est_mtv_msg.pos                     =data(:,8:10);
est_mtv_msg.alt                     =data(:,11);
est_mtv_msg.vel                     =data(:,12:14);
est_mtv_msg.acc                     =data(:,15:17);
est_mtv_msg.rate                    =data(:,18:20);
est_mtv_msg.quat                    =data(:,21:24);
est_mtv_msg.mass                    =data(:,25);
est_mtv_msg.thrust_weight           =data(:,43);
est_mtv_msg.angle_off_vert          =data(:,44);
est_mtv_msg.imu_accel               =data(:,45:47);
est_mtv_msg.imu_rates               =data(:,48:50);
est_mtv_msg.gps_pos                 =data(:,57:59);

%%
dt = 0.1;
t  = [0:dt:(rows-1)*dt]';

%% plot inertial positions

figure,plot(t,est_mtv_msg.pos),grid
cf=gcf;if exist('figs','var'),figs=[figs cf.Number];else figs=cf.Number;end
ylim([-5 10]);

legend_cell = {'X','Y','Z'};
legend(legend_cell,'Location','NorthWest','fontsize',8)
title('Position Estimates','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('meters','fontsize',14)
set(gcf,'Name','Position Estimates')

%% plot inertial velocities

figure,plot(t,est_mtv_msg.vel),grid
cf=gcf;figs=[figs cf.Number];
ylim([-10 5]);

legend_cell = {'X','Y','Z'};
legend(legend_cell,'Location','NorthWest','fontsize',8)
title('Velocity Estimates','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('meters/sec','fontsize',14)
set(gcf,'Name','Velocity Estimates')

%% plot acelerations

figure,plot(t,est_mtv_msg.acc),grid
cf=gcf;figs=[figs cf.Number];

legend_cell = {'X','Y','Z'};
legend(legend_cell,'Location','NorthWest','fontsize',8)
title('Acceleration Estimates','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('m/s^2','fontsize',14)
set(gcf,'Name','Acceleration Estimates')

%% plot body rates

figure,plot(t,est_mtv_msg.rate),grid
cf=gcf;figs=[figs cf.Number];

legend_cell = {'X','Y','Z'};
legend(legend_cell,'Location','NorthWest','fontsize',8)
title('Body Rate Estimates','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('deg/sec','fontsize',14)
set(gcf,'Name','Body Rate Estimates')

%% plot altitude

figure,plot(t,est_mtv_msg.alt),grid
cf=gcf;figs=[figs cf.Number];
ylim([-5 10]);

title('Altitude Estimate','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('meters','fontsize',14)
set(gcf,'Name','Altitude Estimate')

%% plot vehicle mass

figure,plot(t,est_mtv_msg.mass),grid
cf=gcf;figs=[figs cf.Number];

title('Vehicle Mass Estimate','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('kg','fontsize',14)
set(gcf,'Name','Vehicle Mass Estimate')

%% plot landed flag

figure,plot(t,est_mtv_msg.landed),grid
cf=gcf;figs=[figs cf.Number];
ylim([-.1 1.1]);

title('Landed Flag','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','Landed Flag')

%% plot integrating flag

figure,plot(t,est_mtv_msg.integrating),grid
cf=gcf;figs=[figs cf.Number];
ylim([-.1 1.1]);

title('Integrating Flag','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','Integrating Flag')

%% plot GPS valid flag

figure,plot(t,est_mtv_msg.gps_valid),grid
cf=gcf;figs=[figs cf.Number];
ylim([-.1 1.1]);

title('GPS Valid Flag','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','GPS Valid Flag')

%% plot samples since valid imu

figure,plot(t,est_mtv_msg.samples_since_valid_imu),grid
cf=gcf;figs=[figs cf.Number];

title('Samples Since Valid IMU','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','Samples Since Valid IMU')

%% plot convergence flag

figure,plot(t,est_mtv_msg.convergence),grid
cf=gcf;figs=[figs cf.Number];

title('Convergence Flag','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','Convergence Flag')

%% plot thrust over weight

figure,plot(t,est_mtv_msg.thrust_weight),grid
cf=gcf;figs=[figs cf.Number];

title('Thrust Over Weight','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','Thrust Over Weight')

%% plot angle off vertical

figure,plot(t,est_mtv_msg.angle_off_vert),grid
cf=gcf;figs=[figs cf.Number];
ylim([-5 40]);

title('Angle Off Vertical','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('degrees','fontsize',14)
set(gcf,'Name','Angle Off Vertical')

%% plot 10hz body acelerations

figure,plot(t,est_mtv_msg.imu_accel),grid
cf=gcf;figs=[figs cf.Number];

legend_cell = {'X','Y','Z'};
legend(legend_cell,'Location','NorthWest','fontsize',8)
title('10hz Body Accels','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('m/s^2','fontsize',14)
set(gcf,'Name','10hz Body Accels')

%% plot 10hz body rates

figure,plot(t,est_mtv_msg.imu_rates),grid
cf=gcf;figs=[figs cf.Number];

legend_cell = {'X','Y','Z'};
legend(legend_cell,'Location','NorthWest','fontsize',8)
title('10hz Body Rates','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('deg/sec','fontsize',14)
set(gcf,'Name','10hz Body Rates')

%% plot gps positions

figure,plot(t,est_mtv_msg.gps_pos),grid
cf=gcf;figs=[figs cf.Number];

legend_cell = {'X','Y','Z'};
legend(legend_cell,'Location','NorthWest','fontsize',8)
title('GPS Position','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('meters','fontsize',14)
set(gcf,'Name','GPS Position')

%% plot Euler angles

euler=zeros(rows,3);
for i=1:rows
    euler(i,:)=quat2euler(est_mtv_msg.quat(i,:))';
end
figure,plot(t,euler*180/pi),grid
cf=gcf;figs=[figs cf.Number];

legend_cell = {'X','Y','Z'};
legend(legend_cell,'Location','NorthWest','fontsize',8)
title('Euler Angles','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('deg','fontsize',14)
set(gcf,'Name','Euler Angles')

%%
link_fig_axes(figs)

takeoff=min(find(est_mtv_msg.landed==0));
landed =max(find(est_mtv_msg.landed==0));

if landed==length(est_mtv_msg.landed),landed=[];end

if exist('start','var')&&exist('stop','var')
  xlim([floor(dt*start/5)*5   floor(dt*stop/5)*5]);
else

  if ~isempty(takeoff)&&~isempty(landed)
    start=max(1,takeoff-50);
    stop =min(rows,landed+50);

    xlim([floor(dt*start/5)*5   ceil(dt*stop/5)*5]);
  else
    if isempty(takeoff),clear takeoff,end
    if isempty(landed), clear landed, end
    return
  end
end

%% plot x phase plane

figure,plot(euler(start:stop,1)*180/pi,est_mtv_msg.rate(start:stop,1)),grid

title('X-Axis Phase Plane','fontsize',14)
xlabel('Angle, deg','fontsize',14)
ylabel('Rate, deg/sec','fontsize',14)
set(gcf,'Name','X-Axis Phase Plane')

%% plot y phase plane

figure,plot(euler(start:stop,2)*180/pi,est_mtv_msg.rate(start:stop,2)),grid

title('Y-Axis Phase Plane','fontsize',14)
xlabel('Angle, deg','fontsize',14)
ylabel('Rate, deg/sec','fontsize',14)
set(gcf,'Name','Y-Axis Phase Plane')

%% plot z phase plane

figure,plot(euler(start:stop,3)*180/pi,est_mtv_msg.rate(start:stop,3)),grid

title('Z-Axis Phase Plane','fontsize',14)
xlabel('Angle, deg','fontsize',14)
ylabel('Rate, deg/sec','fontsize',14)
set(gcf,'Name','Z-Axis Phase Plane')

%% Create data file
%save(matFile,'est_mtv_msg');
