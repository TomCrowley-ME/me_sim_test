%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2010 - 2015 Moon Express, Inc.
% All Rights Reserved.
%
% PROPRIETARY DATA NOTICE:
% The data herein include Proprietary Data and are restricted under the
% Data Rights provisions of Lunar CATALYST Space Act Agreement
% No. SAAM ID# 18251 and Reimbursable Space Act Agreement No.SAA2-402930.
% All information contained herein is and remains proprietary to and the
% property of Moon Express, Inc. Dissemination of this information or
% reproduction of this material is strictly forbidden unless prior
% written permission is obtained from Moon Express, Inc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-------------------------------------------------------------------------%
% load_wsim_test_data.m                                                   %
%                                                                         %
% loads csv file of test data and creates structure of variables          %
% Inputs: 1. relative or absolute path to dir containing test csv file    %
%         2. name of csv file in folder to load                           %
% **if no input argument provided, current directory is attempted         %
%                                                                         %
% 05/13/11                                                                %
% eleanorcrane@moonexpress.com                                            %
%-------------------------------------------------------------------------%

% create array of field names from telemetry_data matrix from
% csc_ttc_telem_msg bus, env_metrics bus, and fhw_spacecraft_forces bus
telem_bus_names={'sim_tlm_msg'; ...
                 };
telem_bus_cnt = length(telem_bus_names);    % calc number of bus names in array

k=1;  % intialize telem_fname index
for h=1:telem_bus_cnt
    localBus = evalin('base',telem_bus_names{h,1});
    n_fields = length(localBus.Elements);    % calc number of fields in the bus object
    for i=1:n_fields
        dims = localBus.Elements(i).Dimensions;       % calc number of dimensions in case the field is a vector
        for j=1:dims
            if dims > 1
                telem_fname{k,1} = sprintf('%s[%d]',localBus.Elements(i).Name,j); % set the name of the field with index
            else
                telem_fname{k,1} = localBus.Elements(i).Name;       % set the name of the field
            end
            k=k+1;
        end
    end
end 
%%

test_data.data = telemetry_data.signals.values;
test_data.names = telem_fname;

%extract the data into variables
telem.time = wsim_data_extraction(lower('BTS_TIME_SECS'),test_data.names,test_data.data);

%-------------------------------------------------------------------------%
% STATE EST                                                               %
%-------------------------------------------------------------------------%
    telem.kfl_pos       = wsim_data_extraction(lower('KFL_POS'),test_data.names,test_data.data);
    telem.kfl_quat      = wsim_data_extraction(lower('KFL_Q'),test_data.names,test_data.data);
    telem.kfl_euler_deg = wsim_data_extraction(lower('KFL_THETA'),test_data.names,test_data.data*180/pi);
    telem.kfl_rate      = wsim_data_extraction(lower('KFL_RATE'),test_data.names,test_data.data);
    telem.kfl_vel       = wsim_data_extraction(lower('KFL_VEL'),test_data.names,test_data.data);
    telem.kfl_acc       = wsim_data_extraction(lower('KFL_ACC'),test_data.names,test_data.data);

    telem.lnp_rate  = wsim_data_extraction(lower('LNP_IMU_VEH_RATE'),test_data.names,test_data.data);
    telem.lnp_acc   = wsim_data_extraction(lower('lnp_imu_veh_accel'),test_data.names,test_data.data);

    telem.vzp_pos   = wsim_data_extraction(lower('VZP_VIZ_POS'),test_data.names,test_data.data);
    telem.vzp_quat  = wsim_data_extraction(lower('VZP_VIZ_QUATERNION'),test_data.names,test_data.data);
    telem.vzp_rot   = wsim_data_extraction(lower('VZP_VIZ_EULER'),test_data.names,test_data.data);
    
    telem.viz_quat  = wsim_data_extraction(lower('VIZ_QUATERNIONS'),test_data.names,test_data.data);
    telem.viz_pos   = wsim_data_extraction(lower('VIZ_POSITION'),test_data.names,test_data.data);

%-------------------------------------------------------------------------%
% ACS                                                                     %
%-------------------------------------------------------------------------%
    telem.gui_cmd   = wsim_data_extraction(lower('GUI_THRUSTER'),test_data.names,test_data.data);
    telem.gui_quat  = wsim_data_extraction(lower('GUI_QUAT'),test_data.names,test_data.data);

%-------------------------------------------------------------------------%
% VHM                                                                     %
%-------------------------------------------------------------------------%

    telem.vhm_shutdown = wsim_data_extraction(lower('VSC_VHM_SHUTDOWN'),test_data.names,test_data.data);

%-------------------------------------------------------------------------%
% CMP                                                                     %
%-------------------------------------------------------------------------%
    telem.cmp_enbl  = wsim_data_extraction(lower('CMP_THRUSTER_CMDS_ENABLED'),test_data.names,test_data.data);
    telem.cmp_mode  = wsim_data_extraction(lower('CMP_CLOSED_LOOP_MODE'),test_data.names,test_data.data);
    telem.cmp_reset = wsim_data_extraction(lower('CMP_RESET_CONTROL'),test_data.names,test_data.data);  
    telem.cmp_arm   = wsim_data_extraction(lower('THRUSTERS_ARMED'),test_data.names,test_data.data);

    telem.thruster_cmds = wsim_data_extraction(lower('CLT_THRUSTER'),test_data.names,test_data.data);
    
%-------------------------------------------------------------------------%
% RRK                                                                     %
%-------------------------------------------------------------------------%

    truth.alpha = wsim_data_extraction('rrd_alpha',test_data.names,test_data.data);
    truth.rate  = wsim_data_extraction('rrk_rate',test_data.names,test_data.data);
    truth.quat  = wsim_data_extraction('rrk_q',test_data.names,test_data.data);
    truth.accel = wsim_data_extraction('rtd_acc',test_data.names,test_data.data);
    truth.vel   = wsim_data_extraction('rtk_vel',test_data.names,test_data.data);
    truth.pos   = wsim_data_extraction('rtk_pos',test_data.names,test_data.data);
    
    truth.grav  = wsim_data_extraction('grv_gravity',test_data.names,test_data.data);
    
%convert eulers

for i=1:size(telem.gui_quat,1)
    telem.gui_eul(i,:) = quat2euler(telem.gui_quat(i,:)')*180/pi;
    telem.viz_eul(i,:) = quat2euler(telem.viz_quat(i,:)')*180/pi;
    telem.kfl_euler_deg(i,:) = quat2euler(telem.kfl_quat(i,:)')*180/pi;
    
    truth.euler_deg(i,:)=quat2euler(truth.quat(i,:)')*180/pi;
    
    inertial_imu(i,:) = quat_rotate(telem.lnp_acc(i,:), (truth.quat(i,:)));
    inertial_imu_kfl(i,:) = quat_rotate(telem.lnp_acc(i,:), (telem.kfl_quat(i,:)));
end


telem.names = test_data.names;


