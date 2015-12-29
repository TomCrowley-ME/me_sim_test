%close all,clear all

%% Define Excel Source file and Matlab Data file
excelFile = 'pcs_bus_msg.csv';     % Excel file name
Sheet     = 'pcs_bus_msg';         % Sheet
matFile   = 'pcs_bus_msg.mat';     % Mat file name

%% Read the data
if strncmp(computer,'PCWIN',5)
    [data , txt, raw] = xlsread(excelFile, Sheet);
else
    data = csvread(excelFile,1,0);
end
rows=size(data,1);

%% Parse the data
pcs_bus_msg.time                     =data(:,1);
pcs_bus_msg.volts_4v                 =data(:,4);
pcs_bus_msg.volts_12v                =data(:,5);
pcs_bus_msg.volts_5v_beaglebone      =data(:,6);
pcs_bus_msg.volts_28v                =data(:,7);
pcs_bus_msg.volts_28v_haz            =data(:,8);
pcs_bus_msg.volts_zero_curr_vref     =data(:,9);
pcs_bus_msg.volts_3v3                =data(:,10);
pcs_bus_msg.volts_test_point         =data(:,11);
pcs_bus_msg.volts_test_point_2       =data(:,12);
pcs_bus_msg.curr_sa_4v_4_5           =data(:,13);
pcs_bus_msg.curr_sa_12v_4            =data(:,14);
pcs_bus_msg.curr_sa_12v_5            =data(:,15);
pcs_bus_msg.curr_sa_4v_3             =data(:,16);
pcs_bus_msg.curr_sa_12v_3            =data(:,17);
pcs_bus_msg.curr_sa_4v_1_2           =data(:,18);
pcs_bus_msg.curr_sa_12v_1            =data(:,19);
pcs_bus_msg.curr_sa_12v_2            =data(:,20);
pcs_bus_msg.curr_pod1_daq_28v        =data(:,21);
pcs_bus_msg.curr_pod1_28v_haz        =data(:,22);
pcs_bus_msg.curr_pod1_daq_12v        =data(:,23);
pcs_bus_msg.curr_pod2_28v_haz        =data(:,24);
pcs_bus_msg.curr_pod3_28v_haz        =data(:,25);
pcs_bus_msg.curr_pod3_daq_12v        =data(:,26);
pcs_bus_msg.curr_pod4_28v_haz        =data(:,27);
pcs_bus_msg.curr_nadir_cams_4v       =data(:,28);
pcs_bus_msg.curr_nadir_sensors_2_12v =data(:,29);
pcs_bus_msg.curr_nadir_sensor_cams_startrack_htrs =data(:,30);
pcs_bus_msg.curr_nadir_sensors_1_12v =data(:,31);
pcs_bus_msg.curr_batt_28v            =data(:,32);
pcs_bus_msg.curr_prop_egc_3v3        =data(:,33);
pcs_bus_msg.curr_payload_2_4v        =data(:,34);
pcs_bus_msg.curr_ilox_12v            =data(:,35);
pcs_bus_msg.curr_payload_2_12v       =data(:,36);
pcs_bus_msg.curr_ilox_4v             =data(:,37);
pcs_bus_msg.curr_xtend_radio_4v      =data(:,38);
pcs_bus_msg.curr_lidar2              =data(:,39);
pcs_bus_msg.curr_mems_3              =data(:,40);
pcs_bus_msg.curr_prop_deck_xducer_28v=data(:,41);
pcs_bus_msg.curr_flash3              =data(:,42);
pcs_bus_msg.curr_mems_2              =data(:,43);
pcs_bus_msg.curr_wifi_24v            =data(:,44);
pcs_bus_msg.curr_lidar1              =data(:,45);
pcs_bus_msg.curr_4v_batt             =data(:,46);
pcs_bus_msg.curr_beaglebone_5v       =data(:,47);
pcs_bus_msg.curr_pod3_daq_28v        =data(:,48);
pcs_bus_msg.curr_fpga_3v3            =data(:,49);
pcs_bus_msg.curr_mcu_3v3             =data(:,50);
pcs_bus_msg.curr_prop_egc_28v        =data(:,51);
pcs_bus_msg.curr_star_tracker_28v    =data(:,52);
pcs_bus_msg.curr_12v_batt            =data(:,53);
pcs_bus_msg.curr_mems_1              =data(:,54);
pcs_bus_msg.curr_trans_star_tracker  =data(:,55);
pcs_bus_msg.curr_sa_28v_4            =data(:,56);
pcs_bus_msg.curr_sa_28v_1_2          =data(:,57);
pcs_bus_msg.curr_sa_28v_3            =data(:,58);

%%
dt = 0.1;
t  = [0:dt:(rows-1)*dt]';

%%
figure,plot(t,pcs_bus_msg.volts_4v ),grid
cf=gcf;if exist('figs','var'),figs=[figs cf.Number];else figs=cf.Number;end

title('4V Bus','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Volts','fontsize',14)
set(gcf,'Name','4V Bus')

%%
figure,plot(t,pcs_bus_msg.volts_12v ),grid
cf=gcf;figs=[figs cf.Number];

title('12V Bus','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Volts','fontsize',14)
set(gcf,'Name','12V Bus')

%%
figure,plot(t,pcs_bus_msg.volts_5v_beaglebone),grid
cf=gcf;figs=[figs cf.Number];

title('5V Bus','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Volts','fontsize',14)
set(gcf,'Name','5V Bus')

%%
figure,plot(t,pcs_bus_msg.volts_28v),grid
cf=gcf;figs=[figs cf.Number];

title('28V Bus','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Volts','fontsize',14)
set(gcf,'Name','28V Bus')

%%
figure,plot(t,pcs_bus_msg.volts_28v_haz),grid
cf=gcf;figs=[figs cf.Number];

title('28V Hazard Bus','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Volts','fontsize',14)
set(gcf,'Name','28V Hazard Bus')

%%
figure,plot(t,pcs_bus_msg.volts_zero_curr_vref),grid
cf=gcf;figs=[figs cf.Number];

title('Zero Current Voltage Ref','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Volts','fontsize',14)
set(gcf,'Name','Zero Current Voltage Reference')

%%
figure,plot(t,pcs_bus_msg.volts_3v3),grid
cf=gcf;figs=[figs cf.Number];

title('3V3 Voltage','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Volts','fontsize',14)
set(gcf,'Name','3V3 Voltage')

%%
figure,plot(t,pcs_bus_msg.volts_test_point),grid
cf=gcf;figs=[figs cf.Number];

title('Test Point #1 Voltage','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Counts','fontsize',14)
set(gcf,'Name','Test Point #1 Voltage')

%%
figure,plot(t,pcs_bus_msg.volts_test_point_2),grid
cf=gcf;figs=[figs cf.Number];

title('Test Point #2 Voltage','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Counts','fontsize',14)
set(gcf,'Name','Test Point #2 Voltage')

%%
figure,plot(t,pcs_bus_msg.curr_pod1_daq_28v),grid
cf=gcf;figs=[figs cf.Number];

title('Pod1 28V DAQ Current','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Amps','fontsize',14)
set(gcf,'Name','Pod1 DAQ 28V Current')

%%
figure,plot(t,pcs_bus_msg.curr_pod1_28v_haz),grid
cf=gcf;figs=[figs cf.Number];

title('Pod1 28V Hazard Current','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Amps','fontsize',14)
set(gcf,'Name','Pod1 28V Hazard Current')

%%
figure,plot(t,pcs_bus_msg.curr_pod1_daq_12v),grid
cf=gcf;figs=[figs cf.Number];

title('Pod1 12V DAQ Current','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Amps','fontsize',14)
set(gcf,'Name','Pod1 28V DAQ Current')

%%
figure,plot(t,pcs_bus_msg.curr_pod2_28v_haz),grid
cf=gcf;figs=[figs cf.Number];

title('Pod2 28V Hazard Current','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Amps','fontsize',14)
set(gcf,'Name','Pod2 28V Hazard Current')

%%
figure,plot(t,pcs_bus_msg.curr_pod3_28v_haz),grid
cf=gcf;figs=[figs cf.Number];

title('Pod3 28V Hazard Current','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Amps','fontsize',14)
set(gcf,'Name','Pod3 28V Hazard Current')

%%
figure,plot(t,pcs_bus_msg.curr_pod3_daq_12v),grid
cf=gcf;figs=[figs cf.Number];

title('Pod3 12V DAQ Current','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Amps','fontsize',14)
set(gcf,'Name','Pod3 28V DAQ Current')

%%
figure,plot(t,pcs_bus_msg.curr_pod4_28v_haz),grid
cf=gcf;figs=[figs cf.Number];

title('Pod4 28V Hazard Current','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Amps','fontsize',14)
set(gcf,'Name','Pod4 28V Hazard Current')

%%
figure,plot(t,pcs_bus_msg.curr_batt_28v),grid
cf=gcf;figs=[figs cf.Number];

title('28V Battery Current','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Amps','fontsize',14)
set(gcf,'Name','28V Battery Current')

%%
figure,plot(t,pcs_bus_msg.curr_4v_batt),grid
cf=gcf;figs=[figs cf.Number];

title('4V Battery Current','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Amps','fontsize',14)
set(gcf,'Name','4V Battery Current')

%%
figure,plot(t,pcs_bus_msg.curr_beaglebone_5v),grid
cf=gcf;figs=[figs cf.Number];

title('5V Beaglebone Current','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Amps','fontsize',14)
set(gcf,'Name','5V Beaglebone Current')

%%
figure,plot(t,pcs_bus_msg.curr_prop_egc_28v),grid
cf=gcf;figs=[figs cf.Number];

title('28V EGC Current','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Amps','fontsize',14)
set(gcf,'Name','28V EGC Current')

%%
figure,plot(t,pcs_bus_msg.curr_12v_batt),grid
cf=gcf;figs=[figs cf.Number];

title('12V Battery Current','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('Amps','fontsize',14)
set(gcf,'Name','12V Battery Current')

%%
link_fig_axes(figs)

if exist('start','var')&&exist('stop','var')
  xlim([floor(dt*start/5)*5   ceil(dt*stop/5)*5]);
end

%% Create data file
%save(matFile,'pcs_bus_msg');
