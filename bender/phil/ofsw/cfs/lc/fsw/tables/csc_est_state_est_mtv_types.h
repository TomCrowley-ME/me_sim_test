/**************************************************************************
* Copyright 2010 - 2015 Moon Express, Inc.
* All Rights Reserved.
*
* PROPRIETARY DATA NOTICE:
* The data herein include Proprietary Data and are restricted under the
* Data Rights provisions of Lunar CATALYST Space Act Agreement
* No. SAAM ID# 18251 and Reimbursable Space Act Agreement No.SAA2-402930.
* All information contained herein is and remains proprietary to and the
* property of Moon Express, Inc. Dissemination of this information or
* reproduction of this material is strictly forbidden unless prior
* written permission is obtained from Moon Express, Inc.
**************************************************************************/
/*
 * File: csc_est_state_est_mtv_types.h
 *
 * Code generated for Simulink model 'csc_est_state_est_mtv'.
 *
 * Model version                  : 1.2132
 * Simulink Coder version         : 8.7 (R2014b) 08-Sep-2014
 * C/C++ source code generated on : Tue Nov 11 17:45:19 2014
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: 32-bit Generic
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef RTW_HEADER_csc_est_state_est_mtv_types_h_
#define RTW_HEADER_csc_est_state_est_mtv_types_h_
#include "rtwtypes.h"
#ifndef _DEFINED_TYPEDEF_FOR_mem_msg_
#define _DEFINED_TYPEDEF_FOR_mem_msg_

/* HWIO message for the MEMS */
typedef struct {
  uint8_T cfe_tlm_header_align[4];
  int16_T mem1_accel_samples[30];
  int16_T mem1_temp_samples[10];
  int16_T mem1_gyro_samples[30];
  uint8_T mem1_num_samples[10];
  int16_T mem2_accel_samples[30];
  int16_T mem2_temp_samples[10];
  int16_T mem2_gyro_samples[30];
  uint8_T mem2_num_samples[10];
  int16_T mem3_accel_samples[30];
  int16_T mem3_temp_samples[10];
  int16_T mem3_gyro_samples[30];
  uint8_T mem3_num_samples[10];
  uint8_T valid;
  uint8_T spare;
} mem_msg;

#endif

#ifndef _DEFINED_TYPEDEF_FOR_sta_msg_
#define _DEFINED_TYPEDEF_FOR_sta_msg_

/* HWIO message for the Star Tracker. */
typedef struct {
  uint8_T cfe_tlm_header_align[4];
  uint8_T q_valid;
  uint8_T pad1[3];
  real_T q_eci_to_head[4];
  real_T acc_meas[80];
  real_T rate_meas[30];
} sta_msg;

#endif

#ifndef _DEFINED_TYPEDEF_FOR_ldr_msg_
#define _DEFINED_TYPEDEF_FOR_ldr_msg_

/* HWIO message for the lidar. */
typedef struct {
  uint8_T cfe_tlm_header_align[4];
  uint8_T pad1[4];
  real_T range_2k_a;
  real_T range_100m_a;
} ldr_msg;

#endif

#ifndef _DEFINED_TYPEDEF_FOR_cfp_msg_
#define _DEFINED_TYPEDEF_FOR_cfp_msg_

/* Feature points from the two descent cameras */
typedef struct {
  uint8_T cfe_tlm_header_align[4];
  uint8_T pad1[4];
  real_T nadir_pixels_1[32];
  real_T nadir_pixels_2[32];
} cfp_msg;

#endif

#ifndef _DEFINED_TYPEDEF_FOR_gps_msg_
#define _DEFINED_TYPEDEF_FOR_gps_msg_

/* GPS measurement message */
typedef struct {
  uint8_T cfe_tlm_header_align[4];
  uint32_T tow;
  int32_T n;
  int32_T e;
  int32_T d;
  uint16_T h_accuracy;
  uint16_T v_accuracy;
  uint8_T flags;
} gps_msg;

#endif

#ifndef _DEFINED_TYPEDEF_FOR_cfe_time_msg_
#define _DEFINED_TYPEDEF_FOR_cfe_time_msg_

/* Current cFE time -- when autocoded, provided by the SIL. */
typedef struct {
  uint32_T utc_seconds;
  uint16_T utc_mseconds;
} cfe_time_msg;

#endif

#ifndef _DEFINED_TYPEDEF_FOR_cmp_mtv_msg_
#define _DEFINED_TYPEDEF_FOR_cmp_mtv_msg_

/* CMP bus containing latched commands for other apps, for MTV implementation */
typedef struct {
  uint8_T cfe_tlm_header_align[4];
  uint8_T mode;
  uint8_T submode;
  uint8_T hover_enable;
  uint8_T takeoff_enable;
  real_T inertial_primary_pointing_cmd[3];
  real_T inertial_secondary_pointing_cmd[3];
  real_T body_secondary_pointing_vector[3];
  real_T body_primary_pointing_vector[3];
  real_T thruster_dv_cmd;
  real32_T thruster_dur_cmd;
  uint16_T mode_change_counter;
  uint16_T mode_change_errors;
  uint16_T process_cmds_counter;
  uint16_T process_cmds_errors;
  uint8_T burn_type_cmd;
  uint8_T start_burn;
  uint8_T est_ref_frame;
  uint8_T acs_thruster_set;
  uint32_T cnt_active_controller_disable;
  uint32_T act_manual_thruster_firing[12];
  uint32_T act_arm_thruster_set_durations[4];
  uint8_T act_reset_accumulated_ontime;
  uint8_T command_id;
  uint8_T egc_fire;
  uint8_T est_mtv_reset_topo_position;
  real_T est_mtv_propellant_mass_update;
  real_T egc_weight_offload_percent;
  uint32_T egc_controller_disable;
  uint32_T est_integrator_override;
  uint16_T egc_manual_throttle_cmd;
  uint8_T act_mtv_valve_cmd_enable;
  uint8_T act_htp_tank_press_valve;
  uint8_T act_htp_tank_press_vent_valve;
  uint8_T act_htp_main_feed_valve;
  uint8_T act_htp_main_purge_valve;
  uint8_T egc_closed_loop_pressure;
  uint8_T est_on_launchstand;
  uint8_T pad[3];
} cmp_mtv_msg;

#endif

#ifndef _DEFINED_TYPEDEF_FOR_act_mtv_msg_
#define _DEFINED_TYPEDEF_FOR_act_mtv_msg_

/* ACT thruster commands and telemetry for MTV only */
typedef struct {
  uint8_T cfe_tlm_header_align[4];
  uint8_T coarse1_time;
  uint8_T coarse2_time;
  uint8_T coarse3_time;
  uint8_T coarse4_time;
  uint8_T coarse5_time;
  uint8_T coarse6_time;
  uint8_T coarse7_time;
  uint8_T coarse8_time;
  uint8_T coarse9_time;
  uint8_T coarse10_time;
  uint8_T coarse11_time;
  uint8_T coarse12_time;
  uint8_T coarse1_delay;
  uint8_T coarse2_delay;
  uint8_T coarse3_delay;
  uint8_T coarse4_delay;
  uint8_T coarse5_delay;
  uint8_T coarse6_delay;
  uint8_T coarse7_delay;
  uint8_T coarse8_delay;
  uint8_T coarse9_delay;
  uint8_T coarse10_delay;
  uint8_T coarse11_delay;
  uint8_T coarse12_delay;
  uint8_T valve1_htp_tank_pressurant_time;
  uint8_T valve2_htp_tank_pressurant_vent_time;
  uint8_T valve3_htp_tank_outlet_time;
  uint8_T valve4_htp_main_engine_feed_time;
  uint8_T valve5_htp_main_engine_purge_time;
  uint8_T valve6_rp_tank_pressurant_time;
  uint8_T valve7_rp_tank_pressurant_vent_time;
  uint8_T valve8_rp_tank_outlet_time;
  uint8_T valve9_rp_main_engine_feed_time;
  uint8_T valve10_rp_main_engine_purge_time;
  uint8_T valve1_htp_tank_pressurant_delay;
  uint8_T valve2_htp_tank_pressurant_vent_delay;
  uint8_T valve3_htp_tank_outlet_delay;
  uint8_T valve4_htp_main_engine_feed_delay;
  uint8_T valve5_htp_main_engine_purge_delay;
  uint8_T valve6_rp_tank_pressurant_delay;
  uint8_T valve7_rp_tank_pressurant_vent_delay;
  uint8_T valve8_rp_tank_outlet_delay;
  uint8_T valve9_rp_main_engine_feed_delay;
  uint8_T valve10_rp_main_engine_purge_delay;
  uint32_T coarse_ontime[12];
  uint32_T coarse_arm[12];
} act_mtv_msg;

#endif

#ifndef _DEFINED_TYPEDEF_FOR_egc_bus_msg_
#define _DEFINED_TYPEDEF_FOR_egc_bus_msg_

/* EGC message containing current throttle setting */
typedef struct {
  uint8_T cfe_tlm_header_align[4];
  uint16_T throttle;
} egc_bus_msg;

#endif

#ifndef _DEFINED_TYPEDEF_FOR_est_mtv_msg_
#define _DEFINED_TYPEDEF_FOR_est_mtv_msg_

/* Estimator app output for MTV. */
typedef struct {
  uint8_T cfe_tlm_header_align[4];
  uint8_T landed;
  uint8_T integrating;
  uint8_T gps_meas_valid;
  uint8_T samples_since_valid_imu;
  uint8_T convergence_state;
  uint8_T pad1[7];
  real_T pos[3];
  real_T altitude;
  real_T vel[3];
  real_T accel[3];
  real_T rate[3];
  real_T q[4];
  real_T mass;
  real_T cg[3];
  real_T q_mci_to_mcmf[4];
  real_T q_mcmf_to_topo[4];
  real_T mean_accel[3];
  real_T mean_rate[3];
  real_T thrust_over_weight;
  real_T angle_off_vertical;
  real_T accel_10hz_meas_body[3];
  real_T rate_10hz_meas_body[3];
  real_T gps_pos_topo_meas[3];
} est_mtv_msg;

#endif

/* Parameters for system: '<S48>/nonzero_rate' */
typedef struct rtP_nonzero_rate_csc_est_state_est_mtv_
  rtP_nonzero_rate_csc_est_state_est_mtv;

/* Parameters for system: '<S151>/topocentric_frame' */
typedef struct rtP_topocentric_frame_csc_est_state_est_mtv_
  rtP_topocentric_frame_csc_est_state_est_mtv;

/* Parameters for system: '<S151>/inertial_frame' */
typedef struct rtP_inertial_frame_csc_est_state_est_mtv_
  rtP_inertial_frame_csc_est_state_est_mtv;

/* Parameters (auto storage) */
typedef struct Parameters_csc_est_state_est_mtv_
  Parameters_csc_est_state_est_mtv;

/* Forward declaration for rtModel */
typedef struct tag_RTM_csc_est_state_est_mtv RT_MODEL_csc_est_state_est_mtv;

#endif                                 /* RTW_HEADER_csc_est_state_est_mtv_types_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
