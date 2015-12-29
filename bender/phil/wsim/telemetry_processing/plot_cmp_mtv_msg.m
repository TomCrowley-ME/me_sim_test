%close all,clear all

%% Define Excel Source file and Matlab Data file
excelFile = 'cmp_mtv_msg.csv';     % Excel file name
Sheet     = 'cmp_mtv_msg';         % Sheet
matFile   = 'cmp_mtv_msg.mat';     % Mat file name

%% Read the data
if strncmp(computer,'PCWIN',5)
    [data , txt, raw] = xlsread(excelFile, Sheet);
else
    data = csvread(excelFile,1,0);
end
rows=size(data,1);

%% Parse the data
cmp_mtv_msg.time                     =data(:,1);
cmp_mtv_msg.mode                     =data(:,3);
cmp_mtv_msg.submode                  =data(:,4);
cmp_mtv_msg.hover_enable             =data(:,5);
cmp_mtv_msg.takeoff_enable           =data(:,6);
cmp_mtv_msg.est_ref_frame            =data(:,27);
cmp_mtv_msg.acs_thruster_set         =data(:,28);
cmp_mtv_msg.egc_fire                 =data(:,48);
cmp_mtv_msg.egc_weight_offload       =data(:,51);
cmp_mtv_msg.est_thrust_accel_bias    =data(:,52:54);
cmp_mtv_msg.egc_manual_throttle      =data(:,57);
cmp_mtv_msg.htp_tank_press_valve     =data(:,59);
cmp_mtv_msg.htp_tank_vent_valve      =data(:,60);
cmp_mtv_msg.htp_main_feed_valve      =data(:,61);
cmp_mtv_msg.htp_main_purge_valve     =data(:,62);
cmp_mtv_msg.egc_closed_loop_pressure =data(:,63);
cmp_mtv_msg.on_launchstand           =data(:,64);
cmp_mtv_msg.egc_velocity_feedback    =data(:,64);

%% define enumerated y-labels
mode    ={'STARTUP' 'SAFE' 'POINTING' 'DELTAV' 'DEORBIT' 'BRAKING' 'LANDING' 'SURFACE' 'SURFACE\_SAFE'};
submode ={'NONE' 'ACTIVE' 'COAST' 'HOLD' 'TARTGETING' 'TERMINAL'};

%%
dt = 0.1;
t  = [0:dt:(rows-1)*dt]';

%% plot mode
figure,plot(t,cmp_mtv_msg.mode),grid
cf=gcf;if exist('figs','var'),figs=[figs cf.Number];else figs=cf.Number;end
ylim([0 10]);

title('Mode','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','Mode')
set(gca,'YTick',1:9,'YTickLabel',mode)

%% plot submode
figure,plot(t,cmp_mtv_msg.submode),grid
cf=gcf;figs=[figs cf.Number];
ylim([0 7]);

title('Submode','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','Submode')
set(gca,'YTick',1:6,'YTickLabel',submode)

%% plot hover enable
figure,plot(t,cmp_mtv_msg.hover_enable),grid
cf=gcf;figs=[figs cf.Number];
ylim([-.1 1.1]);

title('Hover Enable','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','Hover Enable')

%% plot takeoff enable
figure,plot(t,cmp_mtv_msg.takeoff_enable),grid
cf=gcf;figs=[figs cf.Number];
ylim([-.1 2.1]);

title('Takeoff Enable','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','Takeoff Enable')

%% plot acs thruster set
figure,plot(t,cmp_mtv_msg.acs_thruster_set),grid
cf=gcf;figs=[figs cf.Number];

title('ACS Thruster Set','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','ACS Thruster Set')

%% plot egc fire
figure,plot(t,cmp_mtv_msg.egc_fire),grid
cf=gcf;figs=[figs cf.Number];
ylim([-.1 1.1]);

title('EGC Fire','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','EGC Fire')

%% plot egc weight offload percent
figure,plot(t,cmp_mtv_msg.egc_weight_offload),grid
cf=gcf;figs=[figs cf.Number];

title('EGC Weight Offload','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('percentage','fontsize',14)
set(gcf,'Name','EGC Weight Offload')

%% plot thruster acceleration bias estimate
figure,plot(t,cmp_mtv_msg.est_thrust_accel_bias),grid
cf=gcf;figs=[figs cf.Number];

legend_cell = {'X','Y','Z'};
legend(legend_cell,'Location','NorthWest','fontsize',8)
title('Thrust Acceleration Bias Estimates','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('m/s^2','fontsize',14)
set(gcf,'Name','Thrust Acceleration Bias Estimates')

%% plot HTP tank press valve
figure,plot(t,cmp_mtv_msg.htp_tank_press_valve),grid
cf=gcf;figs=[figs cf.Number];
ylim([-.1 1.1]);

title('HTP Tank Press Valve','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','HTP Tank Press Valve')

%% plot HTP tank vent valve
figure,plot(t,cmp_mtv_msg.htp_tank_vent_valve),grid
cf=gcf;figs=[figs cf.Number];
ylim([-.1 1.1]);

title('HTP Tank Vent Valve','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','HTP Tank Vent Valve')

%% plot HTP main feed valve
figure,plot(t,cmp_mtv_msg.htp_main_feed_valve),grid
cf=gcf;figs=[figs cf.Number];
ylim([-.1 1.1]);

title('HTP Main Feed Valve','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','HTP Main Feed Valve')

%% plot HTP main purge valve
figure,plot(t,cmp_mtv_msg.htp_main_purge_valve),grid
cf=gcf;figs=[figs cf.Number];
ylim([-.1 1.1]);

title('HTP Main Purge Valve','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','HTP Main Purge Valve')

%% plot on_launchstand
figure,plot(t,cmp_mtv_msg.on_launchstand),grid
cf=gcf;figs=[figs cf.Number];
ylim([-.1 1.1]);

title('On Launch Stand','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','On Launch Stand')

%% plot velocity feedback enable
figure,plot(t,cmp_mtv_msg.egc_velocity_feedback),grid
cf=gcf;figs=[figs cf.Number];
ylim([-.1 1.1]);

title('EGC Velocity Feedback','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','EGC Velocity Feedback')

%%
link_fig_axes(figs)

egc_on =min(find(cmp_mtv_msg.egc_fire==1));
egc_off=max(find(cmp_mtv_msg.egc_fire==1));
descent=max(find(cmp_mtv_msg.hover_enable==1));

if ~exist('landed','var')
  landed=max(find(cmp_mtv_msg.mode==7));
end

if exist('start','var')&&exist('stop','var')
  xlim([floor(dt*start/5)*5   floor(dt*stop/5)*5]);
else
  if ~isempty(egc_on)&&~isempty(egc_off)
    start=max(1,egc_on-50);
    stop =min(rows,egc_off+50);

    xlim([floor(dt*start/5)*5   ceil(dt*stop/5)*5]);
  end
end

%% Create data file
%save(matFile,'cmp_mtv_msg');
