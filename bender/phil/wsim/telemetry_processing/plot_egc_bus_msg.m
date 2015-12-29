%close all,clear all

%% Define Excel Source file and Matlab Data file
excelFile = 'egc_bus_msg.csv';     % Excel file name
Sheet     = 'egc_bus_msg';         % Sheet
matFile   = 'egc_bus_msg.mat';     % Mat file name

%% Read the data
if strncmp(computer,'PCWIN',5)
    [data , txt, raw] = xlsread(excelFile, Sheet);
else
    data = csvread(excelFile,1,0);
end
rows=size(data,1);
cols=size(data,2);

%% Parse the data
egc_bus_msg.time                  =data(:,1);
egc_bus_msg.throttle              =data(:,3);
egc_bus_msg.landed_inhibit        =data(:,4);
egc_bus_msg.pressure_valid        =data(:,5);
egc_bus_msg.desired_thrust        =data(:,6);
if cols==7
  egc_bus_msg.percent_cmd_corrected =data(:,7);
end

%%
dt = 0.1;
t  = [0:dt:(rows-1)*dt]';

%% plot throttle position

figure,plot(t,egc_bus_msg.throttle),grid
cf=gcf;if exist('figs','var'),figs=[figs cf.Number];else figs=cf.Number;end

title('EGC Throttle Position','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','EGC Throttle Position')
%% plot desired thrust

figure,plot(t,egc_bus_msg.desired_thrust),grid
cf=gcf;figs=[figs cf.Number];

title('EGC Desired Thrust','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','EGC Desired Thrust')

%% plot percent command corrected

if cols==7
  figure,plot(t,egc_bus_msg.percent_cmd_corrected),grid
  cf=gcf;figs=[figs cf.Number];

  title('EGC Weight Offload Percentage','fontsize',14)
  xlabel('time (sec)','fontsize',14)
  set(gcf,'Name','EGC Weight Offload Percentage')
end

%%
link_fig_axes(figs)

if exist('start','var')&&exist('stop','var')
  xlim([floor(dt*start/5)*5   ceil(dt*stop/5)*5]);
end

%% Create data file
%save(matFile,'egc_bus_msg');
