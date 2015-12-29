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
 * File: csc_egc_earth_grv_cancel_types.h
 *
 * Code generated for Simulink model 'csc_egc_earth_grv_cancel'.
 *
 * Model version                  : 1.2132
 * Simulink Coder version         : 8.7 (R2014b) 08-Sep-2014
 * C/C++ source code generated on : Tue Nov 11 17:44:34 2014
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: 32-bit Generic
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef RTW_HEADER_csc_egc_earth_grv_cancel_types_h_
#define RTW_HEADER_csc_egc_earth_grv_cancel_types_h_
#include "rtwtypes.h"
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

#ifndef _DEFINED_TYPEDEF_FOR_converted_temperatures_t_
#define _DEFINED_TYPEDEF_FOR_converted_temperatures_t_

/* temps in celcius */
typedef struct {
  real_T temp_meas_vec[64];
} converted_temperatures_t;

#endif

#ifndef _DEFINED_TYPEDEF_FOR_converted_pressures_t_
#define _DEFINED_TYPEDEF_FOR_converted_pressures_t_

/* Converted pressures in psi */
typedef struct {
  real_T press_h2o2_tank;
  real_T press_htp_pressurant;
  real_T press_pressurant_manifold;
  real_T press_gn2_acs;
  real_T press_main_engine_chamber;
  real_T press_prop_spare;
} converted_pressures_t;

#endif

#ifndef _DEFINED_TYPEDEF_FOR_tcs_bus_msg_
#define _DEFINED_TYPEDEF_FOR_tcs_bus_msg_

/* thermal controller bus */
typedef struct {
  uint8_T cfe_tlm_header_align[4];
  converted_temperatures_t converted_temperatures;
  converted_pressures_t converted_pressures;
} tcs_bus_msg;

#endif

#ifndef _DEFINED_TYPEDEF_FOR_egc_bus_msg_
#define _DEFINED_TYPEDEF_FOR_egc_bus_msg_

/* EGC message containing current throttle setting */
typedef struct {
  uint8_T cfe_tlm_header_align[4];
  uint16_T throttle;
} egc_bus_msg;

#endif

/* Parameters (auto storage) */
typedef struct Parameters_csc_egc_earth_grv_cancel_
  Parameters_csc_egc_earth_grv_cancel;

/* Forward declaration for rtModel */
typedef struct tag_RTM_csc_egc_earth_grv_cancel
  RT_MODEL_csc_egc_earth_grv_cancel;

#endif                                 /* RTW_HEADER_csc_egc_earth_grv_cancel_types_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
