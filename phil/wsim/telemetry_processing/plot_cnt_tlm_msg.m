%close all,clear all

%% Define Excel Source file and Matlab Data file
excelFile = 'cnt_tlm_msg.csv';     % Excel file name
Sheet     = 'cnt_tlm_msg';         % Sheet
matFile   = 'cnt_tlm_msg.mat';     % Mat file name

%% Read the data
if strncmp(computer,'PCWIN',5)
    [data , txt, raw] = xlsread(excelFile, Sheet);
else
    data = csvread(excelFile,1,0);
end
rows=size(data,1);

%% Parse the data
cnt_tlm_msg.time                    =data(:,1);
cnt_tlm_msg.coarse_acs_trq          =data(:,3:5);
cnt_tlm_msg.vernier_acs_trq         =data(:,6:8);
cnt_tlm_msg.quat_err                =data(:,9:12);
cnt_tlm_msg.quat_des                =data(:,17:20);

%%
dt = 0.1;
t  = [0:dt:(rows-1)*dt]';

%% plot coarse ACS torque command

figure,plot(t,cnt_tlm_msg.coarse_acs_trq),grid
cf=gcf;if exist('figs','var'),figs=[figs cf.Number];else figs=cf.Number;end
ylim([-1.1 1.1]);

legend_cell = {'X','Y','Z'};
legend(legend_cell,'Location','NorthWest','fontsize',8)
title('Coarse ACS Torque Command','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','Coarse ACS Torque Command')

%% plot vernier ACS torque command

figure,plot(t,cnt_tlm_msg.vernier_acs_trq),grid
cf=gcf;figs=[figs cf.Number];
ylim([-1.1 1.1]);

legend_cell = {'X','Y','Z'};
legend(legend_cell,'Location','NorthWest','fontsize',8)
title('Vernier ACS Torque Command','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','Vernier ACS Torque Command')

%% plot pointing error Euler angles

euler=zeros(rows,3);
for i=1:rows
    euler(i,:)=quat2euler(cnt_tlm_msg.quat_err(i,:))';
end
figure,plot(t,euler*180/pi),grid
cf=gcf;figs=[figs cf.Number];

legend_cell = {'X','Y','Z'};
legend(legend_cell,'Location','NorthWest','fontsize',8)
title('Attitude Error Euler Angles','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('deg','fontsize',14)
set(gcf,'Name','Attitude Error Euler Angles')

%% plot commanded Euler angles

euler=zeros(rows,3);
for i=1:rows
    euler(i,:)=quat2euler(cnt_tlm_msg.quat_des(i,:))';
end
figure,plot(t,euler*180/pi),grid
cf=gcf;figs=[figs cf.Number];

legend_cell = {'X','Y','Z'};
legend(legend_cell,'Location','NorthWest','fontsize',8)
title('Commanded Inertial to Body Euler Angles','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('deg','fontsize',14)
set(gcf,'Name','Commanded Inertial to Body Euler Angles')

%%
link_fig_axes(figs)

if exist('start','var')&&exist('stop','var')
  xlim([floor(dt*start/5)*5   floor(dt*stop/5)*5]);
else
  takeoff=min(find(abs(cnt_tlm_msg.coarse_acs_trq(:,1))>0.001));
  landed =max(find(abs(cnt_tlm_msg.coarse_acs_trq(:,1))>0.001));

  start=max(1,takeoff-50);
  stop =min(rows,landed+50);

  xlim([floor(dt*start/5)*5   ceil(dt*stop/5)*5]);
end

%% Create data file
%save(matFile,'cnt_tlm_msg');
