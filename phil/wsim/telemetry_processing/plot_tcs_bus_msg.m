%close all,clear all

%% Define Excel Source file and Matlab Data file
excelFile = 'tcs_bus_msg.csv';     % Excel file name
Sheet     = 'tcs_bus_msg';         % Sheet
matFile   = 'tcs_bus_msg.mat';     % Mat file name

%% Read the data
if strncmp(computer,'PCWIN',5)
    [data , txt, raw] = xlsread(excelFile, Sheet);
else
    data = csvread(excelFile,1,0);
end
rows=size(data,1);

%% Parse the data
tcs_bus_msg.time=data(:,1);
tcs_bus_msg.temp_htp_manifold   =data(:,4);
tcs_bus_msg.temp_htp_tank       =data(:,[11 14 8 5]);
tcs_bus_msg.temp_beaglebone_reg =data(:,6);
tcs_bus_msg.temp_pod_inlet      =data(:,7);
tcs_bus_msg.temp_microcab       =data(:,9);
tcs_bus_msg.temp_gn2_tank       =data(:,10);
tcs_bus_msg.temp_mcu_reg        =data(:,12);
tcs_bus_msg.temp_thrust_plate   =data(:,13);
tcs_bus_msg.temp_battery        =data(:,15:21);
tcs_bus_msg.press_h2o2_tank     =data(:,22);
tcs_bus_msg.press_pre_tank      =data(:,23);
tcs_bus_msg.press_n2            =data(:,24);
tcs_bus_msg.press_acs           =data(:,25);
tcs_bus_msg.press_chamber       =data(:,26);

%%
dt = 0.1;
t  = [0:dt:(rows-1)*dt]';

%% plot HTP manifold temperature

figure,plot(t,tcs_bus_msg.temp_htp_manifold),grid
cf=gcf;if exist('figs','var'),figs=[figs cf.Number];else figs=cf.Number;end

title('HTP Manifold Temperature','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('degC','fontsize',14)
set(gcf,'Name','HTP Manifold Temperatures')

%% plot HTP tank temperatures

figure,plot(t,tcs_bus_msg.temp_htp_tank),grid
cf=gcf;figs=[figs cf.Number];

legend_cell = {'1','2','3','4'};
legend(legend_cell,'Location','NorthWest','fontsize',8)
title('HTP Tank Temperatures','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('degC','fontsize',14)
set(gcf,'Name','HTP Tank Temperatures')

%% plot GN2 tank temperature

figure,plot(t,tcs_bus_msg.temp_gn2_tank),grid
cf=gcf;figs=[figs cf.Number];

title('GN2 Tank Temperature','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('degC','fontsize',14)
set(gcf,'Name','GN2 Tank Temperature')

%% plot battery temperatures

figure,plot(t,tcs_bus_msg.temp_battery),grid
cf=gcf;figs=[figs cf.Number];

legend_cell = {'1','2','3','4','5','6','7'};
legend(legend_cell,'Location','NorthWest','fontsize',8)
title('Battery Temperatures','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('degC','fontsize',14)
set(gcf,'Name','Battery Temperatures')

%% plot Micro CAB temperature

figure,plot(t,tcs_bus_msg.temp_microcab),grid
cf=gcf;figs=[figs cf.Number];

title('Micro CAB Temperature','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('degC','fontsize',14)
set(gcf,'Name','Micro CAB Temperature')

%% plot thrust plate temperature

figure,plot(t,tcs_bus_msg.temp_microcab),grid
cf=gcf;figs=[figs cf.Number];

title('Thrust Plate Temperature','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('degC','fontsize',14)
set(gcf,'Name','Thrust Plate Temperature')

%% plot chamber pressure

figure,plot(t,tcs_bus_msg.press_chamber),grid
cf=gcf;figs=[figs cf.Number];

title('Chamber Pressure','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('psi','fontsize',14)
set(gcf,'Name','Chamber Pressure')

%% plot HTP pressure

figure,plot(t,tcs_bus_msg.press_h2o2_tank),grid
cf=gcf;figs=[figs cf.Number];

title('HTP Pressure','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('psi','fontsize',14)
set(gcf,'Name','HTP Pressure')

%% plot pretank pressure

figure,plot(t,tcs_bus_msg.press_pre_tank),grid
cf=gcf;figs=[figs cf.Number];

title('PreTank Pressure','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('psi','fontsize',14)
set(gcf,'Name','PreTank Pressure')

%% plot GN2 pressure

figure,plot(t,tcs_bus_msg.press_n2),grid
cf=gcf;figs=[figs cf.Number];

title('GN2 Pressure','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('psi','fontsize',14)
set(gcf,'Name','GN2 Pressure')

%% plot ACS pressure

figure,plot(t,tcs_bus_msg.press_acs),grid
cf=gcf;figs=[figs cf.Number];

title('ACS Pressure','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('psi','fontsize',14)
set(gcf,'Name','ACS Pressure')

%%
link_fig_axes(figs)

if exist('start','var')&&exist('stop','var')
  xlim([floor(dt*start/5)*5   ceil(dt*stop/5)*5]);
end

%% Create data file
%save(matFile,'tcs_bus_msg');
