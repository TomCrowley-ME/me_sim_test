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
#ifndef THRSIM_H
#define THRSIM_H

#include "cfe_es.h"
#include "cfe_sb.h"
#include "cfe_evs.h"

/* THRSIM Configuration Parameters */
#define THRSIM_PIPE_DEPTH             4
#define THRSIM_TICK_MID  TICK_100HZ_MID
#define THRSIM_NUM_VALVES            22

/* THRSIM Command Codes */
#define THRSIM_NOOP_CC             0x00
#define THRSIM_RESETCTRS_CC        0x01

/* THRSIM Event IDs */
#define THRSIM_INIT_INF_EID           1
#define THRSIM_NOOP_INF_EID           2
#define THRSIM_CRCMDPIPE_ERR_EID     20
#define THRSIM_SUBSCRIBE_ERR_EID     21
#define THRSIM_MSGID_ERR_EID         22
#define THRSIM_CC1_ERR_EID           23
#define THRSIM_MSGLEN_ERR_EID        24
#define THRSIM_DEVICE_ERR_EID        25
#define THRSIM_PIPE_ERR_EID          26
#define THRSIM_HWIF_ERR_EID          27

#define THRSIM_FILTERED_EVT_COUNT     8

/* Valve State Bitfields */
#define THRSIM_VALVESTATE_RF      (1<<0)
#define THRSIM_VALVESTATE_TO      (1<<1)
#define THRSIM_VALVESTATE_NPPS(x) (((x)>>4) & 0x3)

/* Transition Types */
#define THRSIM_NO_TRANSITION          0
#define THRSIM_FALLING_TRANSITION     1
#define THRSIM_RISING_TRANSITION      2

/* THRSIM Structure Definitions */

typedef struct {
    uint8 id;
    uint8 status;
    uint16 subseconds;
} ValveState_t;

typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;
    uint8  transition[THRSIM_NUM_VALVES];
    uint8  pad1[6];
    double transition_time[THRSIM_NUM_VALVES];
} thr_sim_msg_t;

typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;
    uint8 command_count;
    uint8 error_count;
    uint16 packets_sent_count;
} OS_PACK THRSIM_HkPacket_t;

typedef struct {
    CFE_SB_PipeId_t CmdPipe;
    CFE_SB_MsgPtr_t MsgPtr;

    thr_sim_msg_t thr_sim_msg;

    THRSIM_HkPacket_t HkPacket;

    CFE_EVS_BinFilter_t EventFilters[THRSIM_FILTERED_EVT_COUNT];
} THRSIM_AppData_t;

typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
} OS_PACK THRSIM_NoArgsCmd_t;

/* THRSIM Function Prototypes */
void    THRSIM_TaskMain(void);
int32   THRSIM_Init(void);
int32   THRSIM_HWIF_Init(void);
void    THRSIM_ResetCounters(void);
void    THRSIM_AppPipe(void);
void    THRSIM_GetValveStates(void);
int32   THRSIM_ReadDeviceData(thr_sim_msg_t *thr_sim_msg);
void    THRSIM_ProcessGroundCommand(void);
void    THRSIM_ReportHousekeeping(void);
boolean THRSIM_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength);

/* THRSIM Data */
extern THRSIM_AppData_t THRSIM_AppData;
extern uint8 THRSIM_ValveMap[THRSIM_NUM_VALVES];

#endif
