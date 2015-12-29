%close all,clear all

%% Define Excel Source file and Matlab Data file
excelFile = 'gdn_bus_msg.csv';     % Excel file name
Sheet     = 'gdn_bus_msg';         % Sheet
matFile   = 'gdn_bus_msg.mat';     % Mat file name

%% Read the data
if strncmp(computer,'PCWIN',5)
    [data , txt, raw] = xlsread(excelFile, Sheet);
else
    data = csvread(excelFile,1,0);
end
rows=size(data,1);

%% Parse the data
gdn_bus_msg.time                      =data(:,1);
gdn_bus_msg.hold_complete             =data(:,3);
gdn_bus_msg.targeting_complete        =data(:,4);
gdn_bus_msg.coarse_thr_descent        =data(:,5);
gdn_bus_msg.cmd_quat_inertial_to_body =data(:,8:11);
gdn_bus_msg.cmd_body_rate             =data(:,12:14);
gdn_bus_msg.desired_thrust            =data(:,15);
gdn_bus_msg.commanded_position        =data(:,16:18);
gdn_bus_msg.commanded_velocity        =data(:,19:21);

%%
dt = 0.1;
t  = [0:dt:(rows-1)*dt]';

%% plot commanded euler angles

cmd_euler=zeros(rows,3);
for i=1:rows
    cmd_euler(i,:)=quat2euler(gdn_bus_msg.cmd_quat_inertial_to_body(i,:))';
end
figure,plot(t,cmd_euler*180/pi),grid
cf=gcf;if exist('figs','var'),figs=[figs cf.Number];else figs=cf.Number;end

legend_cell = {'X','Y','Z'};
legend(legend_cell,'Location','NorthEast','fontsize',8)
title('Commanded Euler Angles','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('deg','fontsize',14)
set(gcf,'Name','Commanded Euler Angles')

%% plot commanded body rates

figure,plot(t,gdn_bus_msg.cmd_body_rate),grid
cf=gcf;figs=[figs cf.Number];

legend_cell = {'X','Y','Z'};
legend(legend_cell,'Location','NorthEast','fontsize',8)
title('Commanded Body Rates','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('deg/sec','fontsize',14)
set(gcf,'Name','Commanded Body Rates')

%% plot desired thrust

figure,plot(t,gdn_bus_msg.desired_thrust),grid
cf=gcf;figs=[figs cf.Number];

title('Desired Thrust','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Newtons','fontsize',14)
set(gcf,'Name','Desired Thrust')

%% plot commanded position

figure,plot(t,gdn_bus_msg.commanded_position),grid
cf=gcf;figs=[figs cf.Number];
ylim([-.1 2.1]);

legend_cell = {'X','Y','Z'};
legend(legend_cell,'Location','NorthEast','fontsize',8)
title('Commanded Position','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('meters','fontsize',14)
set(gcf,'Name','Commanded Position')

%% plot commanded velocity

figure,plot(t,gdn_bus_msg.commanded_velocity),grid
cf=gcf;figs=[figs cf.Number];
ylim([-.6 .4]);

legend_cell = {'X','Y','Z'};
legend(legend_cell,'Location','NorthEast','fontsize',8)
title('Commanded Velocity','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('meters/sec','fontsize',14)
set(gcf,'Name','Commanded Velocity')

%%
link_fig_axes(figs)

end_takeoff=max(find(gdn_bus_msg.commanded_velocity(:,3)>eps));
end_hover  =min(find(gdn_bus_msg.commanded_velocity(:,3)<-eps));

if end_takeoff>end_hover,end_takeoff=[];end

if exist('start','var')&&exist('stop','var')
  xlim([floor(dt*start/5)*5   ceil(dt*stop/5)*5]);
end

%% Create data file
%save(matFile,'gdn_bus_msg');
