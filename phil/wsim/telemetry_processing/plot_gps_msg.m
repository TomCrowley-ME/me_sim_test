%close all,clear all

%% Define Excel Source file and Matlab Data file
excelFile = 'gps_msg.csv';     % Excel file name
Sheet     = 'gps_msg';         % Sheet
matFile   = 'gps_msg.mat';     % Mat file name

%% Read the data
if strncmp(computer,'PCWIN',5)
    [data , txt, raw] = xlsread(excelFile, Sheet);
else
    data = csvread(excelFile,1,0);
end
rows=size(data,1);

%% Parse the data
gps_msg.time        =data(:,1);
gps_msg.xyz         =data(:,4:6);
gps_msg.n_sats_ecef =data(:,8);
gps_msg.iar         =data(:,10);
gps_msg.tow_ned     =data(:,11);
gps_msg.n_sats_ned  =data(:,17);

%%
dt = 0.1;
t  = [0:dt:(rows-1)*dt]';

%% plot n satellites ecef

figure,plot(t,gps_msg.n_sats_ecef),grid
cf=gcf;if exist('figs','var'),figs=[figs cf.Number];else figs=cf.Number;end

title('N Satellites ECEF','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','N Satellites ECEF')

%% plot n satellites ned

figure,plot(t,gps_msg.n_sats_ned),grid
cf=gcf;figs=[figs cf.Number];

title('N Satellites NED','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','N Satellites NED')

%% plot iar

figure,plot(t,gps_msg.iar),grid
cf=gcf;figs=[figs cf.Number];

title('IAR','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','IAR')

%% plot tow_ned

figure,plot(t,gps_msg.tow_ned),grid
cf=gcf;figs=[figs cf.Number];

title('TOW\_NED','fontsize',14)
xlabel('time (sec)','fontsize',14)
set(gcf,'Name','TOW_NED')

%% plot xyz

figure,plot(t,gps_msg.xyz),grid
cf=gcf;figs=[figs cf.Number];

legend_cell = {'X','Y','Z'};
legend(legend_cell,'Location','SouthEast','fontsize',8)
title('XYZ','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('meters','fontsize',14)
set(gcf,'Name','XYZ')

%%
link_fig_axes(figs)

if exist('start','var')&&exist('stop','var')
  xlim([floor(dt*start/5)*5   ceil(dt*stop/5)*5]);
end

%% Create data file
%save(matFile,'gps_msg');
