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

%     mem_msg_hrn_initialization_script
%     gps_msg_hrn_initialization_script
%     
%     cmp_mtv_msg_hrn_initialization_script
%     act_mtv_msg_hrn_initialization_script
%     egc_bus_msg_hrn_initialization_script
%     
%     tcs_bus_msg_hrn_initialization_script
%     converted_pressures_t_hrn_initialization_script
%     converted_temperatures_t_hrn_initialization_script

% %% MEM MSG INIT
% 
% mem1_accel_samples_in.time               = t;
% mem1_accel_samples_in.signals.values     = int16( reshape(telem.mem.mem1_accel_samples.Data(n_telem_start:n_telem_end,:)', 10, 3, n_telem) );
% mem1_accel_samples_in.signals.dimensions = [ 10 3 ];
% 
% mem1_temp_samples_in.time               = t;
% mem1_temp_samples_in.signals.values     = zeros(n, 10, 'int16');
% mem1_temp_samples_in.signals.dimensions = [ 10 ];
% 
% mem1_gyro_samples_in.time               = t;
% mem1_gyro_samples_in.signals.values     = int16( reshape(telem.mem.mem1_gyro_samples.Data(n_telem_start:n_telem_end,:)', 10, 3, n_telem) );
% mem1_gyro_samples_in.signals.dimensions = [ 10 3 ];
% 
% mem1_num_samples_in.time               = t;
% mem1_num_samples_in.signals.values     = zeros(n, 10, 'uint8');
% mem1_num_samples_in.signals.dimensions = [ 10 ];
% 
% mem2_accel_samples_in.time               = t;
% mem2_accel_samples_in.signals.values     = int16( reshape(telem.mem.mem2_accel_samples.Data(n_telem_start:n_telem_end,:)', 10, 3, n_telem) );
% mem2_accel_samples_in.signals.dimensions = [ 10 3 ];
% 
% mem2_temp_samples_in.time               = t;
% mem2_temp_samples_in.signals.values     = zeros(n, 10, 'int16');
% mem2_temp_samples_in.signals.dimensions = [ 10 ];
% 
% mem2_gyro_samples_in.time               = t;
% mem2_gyro_samples_in.signals.values     = int16( reshape(telem.mem.mem2_gyro_samples.Data(n_telem_start:n_telem_end,:)', 10, 3, n_telem) );
% mem2_gyro_samples_in.signals.dimensions = [ 10 3 ];
% 
% mem2_num_samples_in.time               = t;
% mem2_num_samples_in.signals.values     = zeros(n, 10, 'uint8');
% mem2_num_samples_in.signals.dimensions = [ 10 ];
% 
% mem3_accel_samples_in.time               = t;
% mem3_accel_samples_in.signals.values     = int16( reshape(telem.mem.mem3_accel_samples.Data(n_telem_start:n_telem_end,:)', 10, 3, n_telem) );
% mem3_accel_samples_in.signals.dimensions = [ 10 3 ];
% 
% mem3_temp_samples_in.time               = t;
% mem3_temp_samples_in.signals.values     = zeros(n, 10, 'int16');
% mem3_temp_samples_in.signals.dimensions = [ 10 ];
% 
% mem3_gyro_samples_in.time               = t;
% mem3_gyro_samples_in.signals.values     = int16( reshape(telem.mem.mem3_gyro_samples.Data(n_telem_start:n_telem_end,:)', 10, 3, n_telem) );
% mem3_gyro_samples_in.signals.dimensions = [ 10 3 ];
% 
% mem3_num_samples_in.time               = t;
% mem3_num_samples_in.signals.values     = zeros(n, 10, 'uint8');
% mem3_num_samples_in.signals.dimensions = [ 10 ];
% 
% valid_in.time               = t;
% valid_in.signals.values     = uint8( telem.mem.valid.Data(n_telem_start:n_telem_end,:) );
% valid_in.signals.dimensions = [ 1 ];

%% IMU MSG INIT

gyro_in.time               = t;
gyro_in.signals.values     = int32( reshape(telem.imu.gyro.Data(n_telem_start:n_telem_end,:,:)',10,3,n_telem_end-n_telem_start+1) );
gyro_in.signals.dimensions = [  10 3];

accel_in.time               = t;
accel_in.signals.values     = int32( reshape(telem.imu.accel.Data(n_telem_start:n_telem_end,:,:)',10,3,n_telem_end-n_telem_start+1) );
accel_in.signals.dimensions = [  10 3];

incline_in.time               = t;
incline_in.signals.values     = int32( reshape(telem.imu.incline.Data(n_telem_start:n_telem_end,:,:)',10,3,n_telem_end-n_telem_start+1) );
incline_in.signals.dimensions = [  10 3];

gyro_status_in.time               = t;
gyro_status_in.signals.values     = uint8( reshape(telem.imu.gyro_status.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,10) );
gyro_status_in.signals.dimensions = [  10];

accel_status_in.time               = t;
accel_status_in.signals.values     = uint8( reshape(telem.imu.accel_status.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,10) );
accel_status_in.signals.dimensions = [  10];

incline_status_in.time               = t;
incline_status_in.signals.values     = uint8( reshape(telem.imu.incline_status.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,10) );
incline_status_in.signals.dimensions = [  10];

imu_valid_in.time               = t;
imu_valid_in.signals.values     = uint16( reshape(telem.imu.valid.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
imu_valid_in.signals.dimensions = [  1];

active_in.time               = t;
active_in.signals.values     = uint8( reshape(telem.imu.active.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
active_in.signals.dimensions = [  1];

mcu_fault_in.time               = t;
mcu_fault_in.signals.values     = uint8( reshape(telem.imu.mcu_fault.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
mcu_fault_in.signals.dimensions = [  1];


%% GPS MSG INIT

tow_ecef_in.time               = t;
tow_ecef_in.signals.values     = uint32( reshape(telem.gps.tow_ecef.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
tow_ecef_in.signals.dimensions = [  1];

x_in.time               = t;
x_in.signals.values     = double( reshape(telem.gps.x.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
x_in.signals.dimensions = [  1];

y_in.time               = t;
y_in.signals.values     = double( reshape(telem.gps.y.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
y_in.signals.dimensions = [  1];

z_in.time               = t;
z_in.signals.values     = double( reshape(telem.gps.z.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
z_in.signals.dimensions = [  1];

accuracy_in.time               = t;
accuracy_in.signals.values     = uint16( reshape(telem.gps.accuracy.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
accuracy_in.signals.dimensions = [  1];

n_sats_ecef_in.time               = t;
n_sats_ecef_in.signals.values     = uint8( reshape(telem.gps.n_sats_ecef.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
n_sats_ecef_in.signals.dimensions = [  1];

flags_ecef_in.time               = t;
flags_ecef_in.signals.values     = uint8( reshape(telem.gps.flags_ecef.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
flags_ecef_in.signals.dimensions = [  1];

iar_in.time               = t;
iar_in.signals.values     = uint32( reshape(telem.gps.iar.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
iar_in.signals.dimensions = [  1];

tow_ned_in.time               = t;
tow_ned_in.signals.values     = uint32( reshape(telem.gps.tow_ned.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
tow_ned_in.signals.dimensions = [  1];

n_in.time               = t;
n_in.signals.values     = int32( reshape(telem.gps.n.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
n_in.signals.dimensions = [  1];

e_in.time               = t;
e_in.signals.values     = int32( reshape(telem.gps.e.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
e_in.signals.dimensions = [  1];

d_in.time               = t;
d_in.signals.values     = int32( reshape(telem.gps.d.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
d_in.signals.dimensions = [  1];

h_accuracy_in.time               = t;
h_accuracy_in.signals.values     = uint16( reshape(telem.gps.h_accuracy.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
h_accuracy_in.signals.dimensions = [  1];

v_accuracy_in.time               = t;
v_accuracy_in.signals.values     = uint16( reshape(telem.gps.v_accuracy.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
v_accuracy_in.signals.dimensions = [  1];

n_sats_ned_in.time               = t;
n_sats_ned_in.signals.values     = uint8( reshape(telem.gps.n_sats_ned.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
n_sats_ned_in.signals.dimensions = [  1];

flags_ned_in.time               = t;
flags_ned_in.signals.values     = uint8( reshape(telem.gps.flags_ned.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
flags_ned_in.signals.dimensions = [  1];

tow_vel_in.time               = t;
tow_vel_in.signals.values     = uint32( reshape(telem.gps.tow_vel.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
tow_vel_in.signals.dimensions = [  1];

n_vel_in.time               = t;
n_vel_in.signals.values     = int32( reshape(telem.gps.n_vel.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
n_vel_in.signals.dimensions = [  1];

e_vel_in.time               = t;
e_vel_in.signals.values     = int32( reshape(telem.gps.e_vel.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
e_vel_in.signals.dimensions = [  1];

d_vel_in.time               = t;
d_vel_in.signals.values     = int32( reshape(telem.gps.d_vel.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
d_vel_in.signals.dimensions = [  1];

h_accuracy_vel_in.time               = t;
h_accuracy_vel_in.signals.values     = uint16( reshape(telem.gps.h_accuracy_vel.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
h_accuracy_vel_in.signals.dimensions = [  1];

v_accuracy_vel_in.time               = t;
v_accuracy_vel_in.signals.values     = uint16( reshape(telem.gps.v_accuracy_vel.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
v_accuracy_vel_in.signals.dimensions = [  1];

n_sats_vel_in.time               = t;
n_sats_vel_in.signals.values     = uint8( reshape(telem.gps.n_sats_vel.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
n_sats_vel_in.signals.dimensions = [  1];

flags_vel_in.time               = t;
flags_vel_in.signals.values     = uint8( reshape(telem.gps.flags_vel.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
flags_vel_in.signals.dimensions = [  1];

fault_count_in.time               = t;
fault_count_in.signals.values     = uint8( reshape(telem.gps.fault_count.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
fault_count_in.signals.dimensions = [  1];

valid_in.time               = t;
valid_in.signals.values     = uint8( reshape(telem.gps.valid.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
valid_in.signals.dimensions = [  1];

%% CMP MTV MSG INIT

mode_in.time               = t;
mode_in.signals.values     = uint8( reshape(telem.cmp.mode.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
mode_in.signals.dimensions = [  1];

submode_in.time               = t;
submode_in.signals.values     = uint8( reshape(telem.cmp.submode.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
submode_in.signals.dimensions = [  1];

hover_enable_in.time               = t;
hover_enable_in.signals.values     = uint8( reshape(telem.cmp.hover_enable.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
hover_enable_in.signals.dimensions = [  1];

takeoff_enable_in.time               = t;
takeoff_enable_in.signals.values     = uint8( reshape(telem.cmp.takeoff_enable.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
takeoff_enable_in.signals.dimensions = [  1];

inertial_primary_pointing_cmd_in.time               = t;
inertial_primary_pointing_cmd_in.signals.values     = double( reshape(telem.cmp.inertial_primary_pointing_cmd.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,3) );
inertial_primary_pointing_cmd_in.signals.dimensions = [  3];

inertial_secondary_pointing_cmd_in.time               = t;
inertial_secondary_pointing_cmd_in.signals.values     = double( reshape(telem.cmp.inertial_secondary_pointing_cmd.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,3) );
inertial_secondary_pointing_cmd_in.signals.dimensions = [  3];

body_secondary_pointing_vector_in.time               = t;
body_secondary_pointing_vector_in.signals.values     = double( reshape(telem.cmp.body_secondary_pointing_vector.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,3) );
body_secondary_pointing_vector_in.signals.dimensions = [  3];

body_primary_pointing_vector_in.time               = t;
body_primary_pointing_vector_in.signals.values     = double( reshape(telem.cmp.body_primary_pointing_vector.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,3) );
body_primary_pointing_vector_in.signals.dimensions = [  3];

thruster_dv_cmd_in.time               = t;
thruster_dv_cmd_in.signals.values     = double( reshape(telem.cmp.thruster_dv_cmd.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
thruster_dv_cmd_in.signals.dimensions = [  1];

thruster_dur_cmd_in.time               = t;
thruster_dur_cmd_in.signals.values     = single( reshape(telem.cmp.thruster_dur_cmd.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
thruster_dur_cmd_in.signals.dimensions = [  1];

mode_change_counter_in.time               = t;
mode_change_counter_in.signals.values     = uint16( reshape(telem.cmp.mode_change_counter.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
mode_change_counter_in.signals.dimensions = [  1];

mode_change_errors_in.time               = t;
mode_change_errors_in.signals.values     = uint16( reshape(telem.cmp.mode_change_errors.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
mode_change_errors_in.signals.dimensions = [  1];

process_cmds_counter_in.time               = t;
process_cmds_counter_in.signals.values     = uint16( reshape(telem.cmp.process_cmds_counter.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
process_cmds_counter_in.signals.dimensions = [  1];

process_cmds_errors_in.time               = t;
process_cmds_errors_in.signals.values     = uint16( reshape(telem.cmp.process_cmds_errors.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
process_cmds_errors_in.signals.dimensions = [  1];

burn_type_cmd_in.time               = t;
burn_type_cmd_in.signals.values     = uint8( reshape(telem.cmp.burn_type_cmd.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
burn_type_cmd_in.signals.dimensions = [  1];

start_burn_in.time               = t;
start_burn_in.signals.values     = uint8( reshape(telem.cmp.start_burn.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
start_burn_in.signals.dimensions = [  1];

est_ref_frame_in.time               = t;
est_ref_frame_in.signals.values     = uint8( reshape(telem.cmp.est_ref_frame.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
est_ref_frame_in.signals.dimensions = [  1];

acs_thruster_set_in.time               = t;
acs_thruster_set_in.signals.values     = uint8( reshape(telem.cmp.acs_thruster_set.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
acs_thruster_set_in.signals.dimensions = [  1];

cnt_active_controller_disable_in.time               = t;
cnt_active_controller_disable_in.signals.values     = uint32( reshape(telem.cmp.cnt_active_controller_disable.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
cnt_active_controller_disable_in.signals.dimensions = [  1];

act_manual_thruster_firing_in.time               = t;
act_manual_thruster_firing_in.signals.values     = uint32( reshape(telem.cmp.act_manual_thruster_firing.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,12) );
act_manual_thruster_firing_in.signals.dimensions = [  12];

act_arm_thruster_set_durations_in.time               = t;
act_arm_thruster_set_durations_in.signals.values     = uint32( reshape(telem.cmp.act_arm_thruster_set_durations.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,4) );
act_arm_thruster_set_durations_in.signals.dimensions = [  4];

act_reset_accumulated_ontime_in.time               = t;
act_reset_accumulated_ontime_in.signals.values     = uint8( reshape(telem.cmp.act_reset_accumulated_ontime.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
act_reset_accumulated_ontime_in.signals.dimensions = [  1];

command_id_in.time               = t;
command_id_in.signals.values     = uint8( reshape(telem.cmp.command_id.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
command_id_in.signals.dimensions = [  1];

egc_fire_in.time               = t;
egc_fire_in.signals.values     = uint8( reshape(telem.cmp.egc_fire.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
egc_fire_in.signals.dimensions = [  1];

est_mtv_reset_topo_position_in.time               = t;
est_mtv_reset_topo_position_in.signals.values     = uint8( reshape(telem.cmp.est_mtv_reset_topo_position.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
est_mtv_reset_topo_position_in.signals.dimensions = [  1];

est_mtv_propellant_mass_update_in.time               = t;
est_mtv_propellant_mass_update_in.signals.values     = double( reshape(telem.cmp.est_mtv_propellant_mass_update.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
est_mtv_propellant_mass_update_in.signals.dimensions = [  1];

egc_weight_offload_percent_in.time               = t;
egc_weight_offload_percent_in.signals.values     = double( reshape(telem.cmp.egc_weight_offload_percent.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
egc_weight_offload_percent_in.signals.dimensions = [  1];

est_thrust_accel_bias_in.time               = t;
est_thrust_accel_bias_in.signals.values     = double( reshape(telem.cmp.est_thrust_accel_bias.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,3) );
est_thrust_accel_bias_in.signals.dimensions = [  3];

egc_controller_disable_in.time               = t;
egc_controller_disable_in.signals.values     = uint32( reshape(telem.cmp.egc_controller_disable.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
egc_controller_disable_in.signals.dimensions = [  1];

est_integrator_override_in.time               = t;
est_integrator_override_in.signals.values     = uint32( reshape(telem.cmp.est_integrator_override.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
est_integrator_override_in.signals.dimensions = [  1];

egc_manual_throttle_cmd_in.time               = t;
egc_manual_throttle_cmd_in.signals.values     = uint16( reshape(telem.cmp.egc_manual_throttle_cmd.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
egc_manual_throttle_cmd_in.signals.dimensions = [  1];

act_mtv_valve_cmd_enable_in.time               = t;
act_mtv_valve_cmd_enable_in.signals.values     = uint8( reshape(telem.cmp.act_mtv_valve_cmd_enable.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
act_mtv_valve_cmd_enable_in.signals.dimensions = [  1];

act_htp_tank_press_valve_in.time               = t;
act_htp_tank_press_valve_in.signals.values     = uint8( reshape(telem.cmp.act_htp_tank_press_valve.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
act_htp_tank_press_valve_in.signals.dimensions = [  1];

act_htp_tank_press_vent_valve_in.time               = t;
act_htp_tank_press_vent_valve_in.signals.values     = uint8( reshape(telem.cmp.act_htp_tank_press_vent_valve.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
act_htp_tank_press_vent_valve_in.signals.dimensions = [  1];

act_htp_main_feed_valve_in.time               = t;
act_htp_main_feed_valve_in.signals.values     = uint8( reshape(telem.cmp.act_htp_main_feed_valve.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
act_htp_main_feed_valve_in.signals.dimensions = [  1];

act_htp_main_purge_valve_in.time               = t;
act_htp_main_purge_valve_in.signals.values     = uint8( reshape(telem.cmp.act_htp_main_purge_valve.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
act_htp_main_purge_valve_in.signals.dimensions = [  1];

egc_closed_loop_pressure_in.time               = t;
egc_closed_loop_pressure_in.signals.values     = uint8( reshape(telem.cmp.egc_closed_loop_pressure.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
egc_closed_loop_pressure_in.signals.dimensions = [  1];

est_on_launchstand_in.time               = t;
est_on_launchstand_in.signals.values     = uint8( reshape(telem.cmp.est_on_launchstand.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
est_on_launchstand_in.signals.dimensions = [  1];

est_bias_calc_cycle_in.time               = t;
est_bias_calc_cycle_in.signals.values     = uint8( reshape(telem.cmp.est_bias_calc_cycle.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
est_bias_calc_cycle_in.signals.dimensions = [  1];

egc_velocity_feedback_in.time               = t;
egc_velocity_feedback_in.signals.values     = uint8( reshape(telem.cmp.egc_velocity_feedback.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
egc_velocity_feedback_in.signals.dimensions = [  1];


%% ACT MTV MSG INIT

coarse1_time_in.time               = t;
coarse1_time_in.signals.values     = uint8( telem.act.coarse1_time.Data(n_telem_start:n_telem_end,:) );
coarse1_time_in.signals.dimensions = [ 1 ];

coarse2_time_in.time               = t;
coarse2_time_in.signals.values     = uint8( telem.act.coarse2_time.Data(n_telem_start:n_telem_end,:) );
coarse2_time_in.signals.dimensions = [ 1 ];

coarse3_time_in.time               = t;
coarse3_time_in.signals.values     = uint8( telem.act.coarse3_time.Data(n_telem_start:n_telem_end,:) );
coarse3_time_in.signals.dimensions = [ 1 ];

coarse4_time_in.time               = t;
coarse4_time_in.signals.values     = uint8( telem.act.coarse4_time.Data(n_telem_start:n_telem_end,:) );
coarse4_time_in.signals.dimensions = [ 1 ];

coarse5_time_in.time               = t;
coarse5_time_in.signals.values     = uint8( telem.act.coarse5_time.Data(n_telem_start:n_telem_end,:) );
coarse5_time_in.signals.dimensions = [ 1 ];

coarse6_time_in.time               = t;
coarse6_time_in.signals.values     = uint8( telem.act.coarse6_time.Data(n_telem_start:n_telem_end,:) );
coarse6_time_in.signals.dimensions = [ 1 ];

coarse7_time_in.time               = t;
coarse7_time_in.signals.values     = uint8( telem.act.coarse7_time.Data(n_telem_start:n_telem_end,:) );
coarse7_time_in.signals.dimensions = [ 1 ];

coarse8_time_in.time               = t;
coarse8_time_in.signals.values     = uint8( telem.act.coarse8_time.Data(n_telem_start:n_telem_end,:) );
coarse8_time_in.signals.dimensions = [ 1 ];

coarse9_time_in.time               = t;
coarse9_time_in.signals.values     = uint8( telem.act.coarse9_time.Data(n_telem_start:n_telem_end,:) );
coarse9_time_in.signals.dimensions = [ 1 ];

coarse10_time_in.time               = t;
coarse10_time_in.signals.values     = uint8( telem.act.coarse10_time.Data(n_telem_start:n_telem_end,:) );
coarse10_time_in.signals.dimensions = [ 1 ];

coarse11_time_in.time               = t;
coarse11_time_in.signals.values     = uint8( telem.act.coarse11_time.Data(n_telem_start:n_telem_end,:) );
coarse11_time_in.signals.dimensions = [ 1 ];

coarse12_time_in.time               = t;
coarse12_time_in.signals.values     = uint8( telem.act.coarse12_time.Data(n_telem_start:n_telem_end,:) );
coarse12_time_in.signals.dimensions = [ 1 ];

coarse1_delay_in.time               = t;
coarse1_delay_in.signals.values     = uint8( telem.act.coarse1_delay.Data(n_telem_start:n_telem_end,:) );
coarse1_delay_in.signals.dimensions = [ 1 ];

coarse2_delay_in.time               = t;
coarse2_delay_in.signals.values     = uint8( telem.act.coarse2_delay.Data(n_telem_start:n_telem_end,:) );
coarse2_delay_in.signals.dimensions = [ 1 ];

coarse3_delay_in.time               = t;
coarse3_delay_in.signals.values     = uint8( telem.act.coarse3_delay.Data(n_telem_start:n_telem_end,:) );
coarse3_delay_in.signals.dimensions = [ 1 ];

coarse4_delay_in.time               = t;
coarse4_delay_in.signals.values     = uint8( telem.act.coarse4_delay.Data(n_telem_start:n_telem_end,:) );
coarse4_delay_in.signals.dimensions = [ 1 ];

coarse5_delay_in.time               = t;
coarse5_delay_in.signals.values     = uint8( telem.act.coarse5_delay.Data(n_telem_start:n_telem_end,:) );
coarse5_delay_in.signals.dimensions = [ 1 ];

coarse6_delay_in.time               = t;
coarse6_delay_in.signals.values     = uint8( telem.act.coarse6_delay.Data(n_telem_start:n_telem_end,:) );
coarse6_delay_in.signals.dimensions = [ 1 ];

coarse7_delay_in.time               = t;
coarse7_delay_in.signals.values     = uint8( telem.act.coarse7_delay.Data(n_telem_start:n_telem_end,:) );
coarse7_delay_in.signals.dimensions = [ 1 ];

coarse8_delay_in.time               = t;
coarse8_delay_in.signals.values     = uint8( telem.act.coarse8_delay.Data(n_telem_start:n_telem_end,:) );
coarse8_delay_in.signals.dimensions = [ 1 ];

coarse9_delay_in.time               = t;
coarse9_delay_in.signals.values     = uint8( telem.act.coarse9_delay.Data(n_telem_start:n_telem_end,:) );
coarse9_delay_in.signals.dimensions = [ 1 ];

coarse10_delay_in.time               = t;
coarse10_delay_in.signals.values     = uint8( telem.act.coarse10_delay.Data(n_telem_start:n_telem_end,:) );
coarse10_delay_in.signals.dimensions = [ 1 ];

coarse11_delay_in.time               = t;
coarse11_delay_in.signals.values     = uint8( telem.act.coarse11_delay.Data(n_telem_start:n_telem_end,:) );
coarse11_delay_in.signals.dimensions = [ 1 ];

coarse12_delay_in.time               = t;
coarse12_delay_in.signals.values     = uint8( telem.act.coarse12_delay.Data(n_telem_start:n_telem_end,:) );
coarse12_delay_in.signals.dimensions = [ 1 ];

valve1_htp_tank_pressurant_time_in.time               = t;
valve1_htp_tank_pressurant_time_in.signals.values     = uint8( telem.act.valve1_htp_tank_pressurant_time.Data(n_telem_start:n_telem_end,:) );
valve1_htp_tank_pressurant_time_in.signals.dimensions = [ 1 ];

valve2_htp_tank_pressurant_vent_time_in.time               = t;
valve2_htp_tank_pressurant_vent_time_in.signals.values     = uint8( telem.act.valve2_htp_tank_pressurant_vent_time.Data(n_telem_start:n_telem_end,:) );
valve2_htp_tank_pressurant_vent_time_in.signals.dimensions = [ 1 ];

valve3_htp_tank_outlet_time_in.time               = t;
valve3_htp_tank_outlet_time_in.signals.values     = uint8( telem.act.valve3_htp_tank_outlet_time.Data(n_telem_start:n_telem_end,:) );
valve3_htp_tank_outlet_time_in.signals.dimensions = [ 1 ];

valve4_htp_main_engine_feed_time_in.time               = t;
valve4_htp_main_engine_feed_time_in.signals.values     = uint8( telem.act.valve4_htp_main_engine_feed_time.Data(n_telem_start:n_telem_end,:) );
valve4_htp_main_engine_feed_time_in.signals.dimensions = [ 1 ];

valve5_htp_main_engine_purge_time_in.time               = t;
valve5_htp_main_engine_purge_time_in.signals.values     = uint8( telem.act.valve5_htp_main_engine_purge_time.Data(n_telem_start:n_telem_end,:) );
valve5_htp_main_engine_purge_time_in.signals.dimensions = [ 1 ];

valve6_rp_tank_pressurant_time_in.time               = t;
valve6_rp_tank_pressurant_time_in.signals.values     = uint8( telem.act.valve6_rp_tank_pressurant_time.Data(n_telem_start:n_telem_end,:) );
valve6_rp_tank_pressurant_time_in.signals.dimensions = [ 1 ];

valve7_rp_tank_pressurant_vent_time_in.time               = t;
valve7_rp_tank_pressurant_vent_time_in.signals.values     = uint8( telem.act.valve7_rp_tank_pressurant_vent_time.Data(n_telem_start:n_telem_end,:) );
valve7_rp_tank_pressurant_vent_time_in.signals.dimensions = [ 1 ];

valve8_rp_tank_outlet_time_in.time               = t;
valve8_rp_tank_outlet_time_in.signals.values     = uint8( telem.act.valve8_rp_tank_outlet_time.Data(n_telem_start:n_telem_end,:) );
valve8_rp_tank_outlet_time_in.signals.dimensions = [ 1 ];

valve9_rp_main_engine_feed_time_in.time               = t;
valve9_rp_main_engine_feed_time_in.signals.values     = uint8( telem.act.valve9_rp_main_engine_feed_time.Data(n_telem_start:n_telem_end,:) );
valve9_rp_main_engine_feed_time_in.signals.dimensions = [ 1 ];

valve10_rp_main_engine_purge_time_in.time               = t;
valve10_rp_main_engine_purge_time_in.signals.values     = uint8( telem.act.valve10_rp_main_engine_purge_time.Data(n_telem_start:n_telem_end,:) );
valve10_rp_main_engine_purge_time_in.signals.dimensions = [ 1 ];

valve1_htp_tank_pressurant_delay_in.time               = t;
valve1_htp_tank_pressurant_delay_in.signals.values     = uint8( telem.act.valve1_htp_tank_pressurant_delay.Data(n_telem_start:n_telem_end,:) );
valve1_htp_tank_pressurant_delay_in.signals.dimensions = [ 1 ];

valve2_htp_tank_pressurant_vent_delay_in.time               = t;
valve2_htp_tank_pressurant_vent_delay_in.signals.values     = uint8( telem.act.valve2_htp_tank_pressurant_vent_delay.Data(n_telem_start:n_telem_end,:) );
valve2_htp_tank_pressurant_vent_delay_in.signals.dimensions = [ 1 ];

valve3_htp_tank_outlet_delay_in.time               = t;
valve3_htp_tank_outlet_delay_in.signals.values     = uint8( telem.act.valve3_htp_tank_outlet_delay.Data(n_telem_start:n_telem_end,:) );
valve3_htp_tank_outlet_delay_in.signals.dimensions = [ 1 ];

valve4_htp_main_engine_feed_delay_in.time               = t;
valve4_htp_main_engine_feed_delay_in.signals.values     = uint8( telem.act.valve4_htp_main_engine_feed_delay.Data(n_telem_start:n_telem_end,:) );
valve4_htp_main_engine_feed_delay_in.signals.dimensions = [ 1 ];

valve5_htp_main_engine_purge_delay_in.time               = t;
valve5_htp_main_engine_purge_delay_in.signals.values     = uint8( telem.act.valve5_htp_main_engine_purge_delay.Data(n_telem_start:n_telem_end,:) );
valve5_htp_main_engine_purge_delay_in.signals.dimensions = [ 1 ];

valve6_rp_tank_pressurant_delay_in.time               = t;
valve6_rp_tank_pressurant_delay_in.signals.values     = uint8( telem.act.valve6_rp_tank_pressurant_delay.Data(n_telem_start:n_telem_end,:) );
valve6_rp_tank_pressurant_delay_in.signals.dimensions = [ 1 ];

valve7_rp_tank_pressurant_vent_delay_in.time               = t;
valve7_rp_tank_pressurant_vent_delay_in.signals.values     = uint8( telem.act.valve7_rp_tank_pressurant_vent_delay.Data(n_telem_start:n_telem_end,:) );
valve7_rp_tank_pressurant_vent_delay_in.signals.dimensions = [ 1 ];

valve8_rp_tank_outlet_delay_in.time               = t;
valve8_rp_tank_outlet_delay_in.signals.values     = uint8( telem.act.valve8_rp_tank_outlet_delay.Data(n_telem_start:n_telem_end,:) );
valve8_rp_tank_outlet_delay_in.signals.dimensions = [ 1 ];

valve9_rp_main_engine_feed_delay_in.time               = t;
valve9_rp_main_engine_feed_delay_in.signals.values     = uint8( telem.act.valve9_rp_main_engine_feed_delay.Data(n_telem_start:n_telem_end,:) );
valve9_rp_main_engine_feed_delay_in.signals.dimensions = [ 1 ];

valve10_rp_main_engine_purge_delay_in.time               = t;
valve10_rp_main_engine_purge_delay_in.signals.values     = uint8( telem.act.valve10_rp_main_engine_purge_delay.Data(n_telem_start:n_telem_end,:) );
valve10_rp_main_engine_purge_delay_in.signals.dimensions = [ 1 ];

coarse_ontime_in.time               = t;
coarse_ontime_in.signals.values     = uint32( telem.act.coarse_ontime.Data(n_telem_start:n_telem_end,:) );
coarse_ontime_in.signals.dimensions = [ 12 ];

coarse_arm_in.time               = t;
coarse_arm_in.signals.values     = uint32( telem.act.coarse_arm.Data(n_telem_start:n_telem_end,:) );
coarse_arm_in.signals.dimensions = [ 12 ];

%% EGC MSG

throttle_in.time               = t;
throttle_in.signals.values     = uint16( reshape(telem.egc.throttle.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
throttle_in.signals.dimensions = [  1];

landed_inhibit_in.time               = t;
landed_inhibit_in.signals.values     = uint8( reshape(telem.egc.landed_inhibit.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
landed_inhibit_in.signals.dimensions = [  1];

pressure_valid_in.time               = t;
pressure_valid_in.signals.values     = uint8( reshape(telem.egc.pressure_valid.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
pressure_valid_in.signals.dimensions = [  1];

desired_thrust_in.time               = t;
desired_thrust_in.signals.values     = double( reshape(telem.egc.desired_thrust.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
desired_thrust_in.signals.dimensions = [  1];

percent_cmd_corrected_in.time               = t;
percent_cmd_corrected_in.signals.values     = double( reshape(telem.egc.percent_cmd_corrected.Data(n_telem_start:n_telem_end,:)',n_telem_end-n_telem_start+1,1) );
percent_cmd_corrected_in.signals.dimensions = [  1];


%% TCS BUS MSG

press_h2o2_tank_in.time               = t;
press_h2o2_tank_in.signals.values     = double( telem.tcs.press_h2o2_tank.Data(n_telem_start:n_telem_end,:) );
press_h2o2_tank_in.signals.dimensions = [ 1 ];

press_pre_tank_in.time               = t;
press_pre_tank_in.signals.values     = double( telem.tcs.press_pre_tank.Data(n_telem_start:n_telem_end,:) );
press_pre_tank_in.signals.dimensions = [ 1 ];

press_n2_in.time               = t;
press_n2_in.signals.values     = double( telem.tcs.press_n2.Data(n_telem_start:n_telem_end,:) );
press_n2_in.signals.dimensions = [ 1 ];

press_acs_in.time               = t;
press_acs_in.signals.values     = double( telem.tcs.press_acs.Data(n_telem_start:n_telem_end,:) );
press_acs_in.signals.dimensions = [ 1 ];

press_chamber_in.time               = t;
press_chamber_in.signals.values     = double( telem.tcs.press_chamber.Data(n_telem_start:n_telem_end,1) );
press_chamber_in.signals.dimensions = [ 1 ];

press_prop_spare_in.time               = t;
press_prop_spare_in.signals.values     =  double( telem.tcs.press_chamber.Data(n_telem_start:n_telem_end,2) );
press_prop_spare_in.signals.dimensions = [ 1 ];

temp_htp_manifold_in.time               = t;
temp_htp_manifold_in.signals.values     = double( telem.tcs.temp_htp_manifold.Data(n_telem_start:n_telem_end,:) );
temp_htp_manifold_in.signals.dimensions = [ 1 ];

temp_htp_tank_4_in.time               = t;
temp_htp_tank_4_in.signals.values     = double( telem.tcs.temp_htp_tank.Data(n_telem_start:n_telem_end,4) );
temp_htp_tank_4_in.signals.dimensions = [ 1 ];

temp_beaglebone_reg_in.time               = t;
temp_beaglebone_reg_in.signals.values     = double( telem.tcs.temp_beaglebone_reg.Data(n_telem_start:n_telem_end,:) );
temp_beaglebone_reg_in.signals.dimensions = [ 1 ];

temp_pod_inlet_in.time               = t;
temp_pod_inlet_in.signals.values     = double( telem.tcs.temp_pod_inlet.Data(n_telem_start:n_telem_end,:) );
temp_pod_inlet_in.signals.dimensions = [ 1 ];

temp_htp_tank_3_in.time               = t;
temp_htp_tank_3_in.signals.values     = double( telem.tcs.temp_htp_tank.Data(n_telem_start:n_telem_end,3) );
temp_htp_tank_3_in.signals.dimensions = [ 1 ];

temp_microcab_in.time               = t;
temp_microcab_in.signals.values     = double( telem.tcs.temp_microcab.Data(n_telem_start:n_telem_end,:) );
temp_microcab_in.signals.dimensions = [ 1 ];

temp_gn2_tank_in.time               = t;
temp_gn2_tank_in.signals.values     = double( telem.tcs.temp_gn2_tank.Data(n_telem_start:n_telem_end,:) );
temp_gn2_tank_in.signals.dimensions = [ 1 ];

temp_htp_tank_1_in.time               = t;
temp_htp_tank_1_in.signals.values     = double( telem.tcs.temp_htp_tank.Data(n_telem_start:n_telem_end,1) );
temp_htp_tank_1_in.signals.dimensions = [ 1 ];

temp_mcu_reg_in.time               = t;
temp_mcu_reg_in.signals.values     = double( telem.tcs.temp_mcu_reg.Data(n_telem_start:n_telem_end,:) );
temp_mcu_reg_in.signals.dimensions = [ 1 ];

temp_thrust_plate_in.time               = t;
temp_thrust_plate_in.signals.values     = double( telem.tcs.temp_thrust_plate.Data(n_telem_start:n_telem_end,:) );
temp_thrust_plate_in.signals.dimensions = [ 1 ];

temp_htp_tank_2_in.time               = t;
temp_htp_tank_2_in.signals.values     = double( telem.tcs.temp_htp_tank.Data(n_telem_start:n_telem_end,2) );
temp_htp_tank_2_in.signals.dimensions = [ 1 ];

temp_battery_1_in.time               = t;
temp_battery_1_in.signals.values     = double( telem.tcs.temp_battery.Data(n_telem_start:n_telem_end,1) );
temp_battery_1_in.signals.dimensions = [ 1 ];

temp_battery_2_in.time               = t;
temp_battery_2_in.signals.values     = double( telem.tcs.temp_battery.Data(n_telem_start:n_telem_end,2) );
temp_battery_2_in.signals.dimensions = [ 1 ];

temp_battery_3_in.time               = t;
temp_battery_3_in.signals.values     = double( telem.tcs.temp_battery.Data(n_telem_start:n_telem_end,3) );
temp_battery_3_in.signals.dimensions = [ 1 ];

temp_battery_4_in.time               = t;
temp_battery_4_in.signals.values     = double( telem.tcs.temp_battery.Data(n_telem_start:n_telem_end,4) );
temp_battery_4_in.signals.dimensions = [ 1 ];

temp_battery_5_in.time               = t;
temp_battery_5_in.signals.values     = double( telem.tcs.temp_battery.Data(n_telem_start:n_telem_end,5) );
temp_battery_5_in.signals.dimensions = [ 1 ];

temp_battery_6_in.time               = t;
temp_battery_6_in.signals.values     = double( telem.tcs.temp_battery.Data(n_telem_start:n_telem_end,6) );
temp_battery_6_in.signals.dimensions = [ 1 ];

temp_battery_7_in.time               = t;
temp_battery_7_in.signals.values     = double( telem.tcs.temp_battery.Data(n_telem_start:n_telem_end,7) );
temp_battery_7_in.signals.dimensions = [ 1 ];



