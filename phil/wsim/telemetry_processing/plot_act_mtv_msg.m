%close all,clear all

%% Define Excel Source file and Matlab Data file
excelFile = 'act_mtv_msg.csv';     % Excel file name
Sheet     = 'act_mtv_msg';         % Sheet
matFile   = 'act_mtv_msg.mat';     % Mat file name

%% Read the data
if strncmp(computer,'PCWIN',5)
    [data , txt, raw] = xlsread(excelFile, Sheet);
else
    data = csvread(excelFile,1,0);
end
rows=size(data,1);

%% Parse the data
act_mtv_msg.time                     =data(:,1);
act_mtv_msg.coarse_ontime            =data(:,3:14);
act_mtv_msg.coarse_cumulative_ontime =data(:,47:58);

%%
dt = 0.1;
t  = [0:dt:(rows-1)*dt]';

%% plot thruster on times

figs=[];
for i=1:12
  figure,plot(t,act_mtv_msg.coarse_ontime(:,i)),grid
  cf=gcf;if exist('figs','var'),figs=[figs cf.Number];else figs=cf.Number;end

  title(sprintf('Thruster %d On-Time',i),'fontsize',14)
  xlabel('time (sec)','fontsize',14)
  ylabel('msec','fontsize',14)
  set(gcf,'Name',sprintf('Thruster %d Time',i))

end

%% plot thruster cumulative ontimes

for i=1:12
  figure,plot(t,act_mtv_msg.coarse_cumulative_ontime(:,i)),grid
  cf=gcf;figs=[figs cf.Number];

  title(sprintf('Thruster %d Cumulative On-Time',i),'fontsize',14)
  xlabel('time (sec)','fontsize',14)
  ylabel('msec','fontsize',14)
  set(gcf,'Name',sprintf('Thruster %d Cumulative On-Time',i))

end

%%
link_fig_axes(figs)

if exist('start','var')&&exist('stop','var')
  xlim([floor(dt*start/5)*5   floor(dt*stop/5)*5]);
else
  for i=1:12
    start(i)=min(find(act_mtv_msg.coarse_ontime(:,i)>0));
    stop(i) =max(find(act_mtv_msg.coarse_ontime(:,i)>0));
  end
  touchdown=max(stop);
  takeoff  =min(start);
  start=max(1,takeoff-50);
  stop =min(rows,touchdown+50);

  xlim([floor(dt*start/5)*5   ceil(dt*stop/5)*5]);
end

%% Create data file
%save(matFile,'act_mtv_msg');
