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
#ifndef GPSSIM_H
#define GPSSIM_H

#include "cfe_es.h"
#include "cfe_sb.h"
#include "cfe_evs.h"

/* GPSSIM Configuration Parameters */
#define GPSSIM_PIPE_DEPTH              4

/* GPSSIM Command Codes */
#define GPSSIM_NOOP_CC              0x00
#define GPSSIM_RESETCTRS_CC         0x01

/* GPSSIM Event IDs */
#define GPSSIM_INIT_INF_EID            1
#define GPSSIM_NOOP_INF_EID            2
#define GPSSIM_CRCMDPIPE_ERR_EID      20
#define GPSSIM_SUBSCRIBE_ERR_EID      21
#define GPSSIM_MSGID_ERR_EID          22
#define GPSSIM_CC1_ERR_EID            23
#define GPSSIM_MSGLEN_ERR_EID         24
#define GPSSIM_DEVICE_ERR_EID         25
#define GPSSIM_PIPE_ERR_EID           26
#define GPSSIM_HWIF_ERR_EID           27

#define GPSSIM_FILTERED_EVT_COUNT      8

/* GPSSIM Structure Definitions */
typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;
    uint32 tow_ecef;
    double x;
    double y;
    double z;
    uint16 accuracy;
    uint8  n_sats_ecef;
    uint8  flags_ecef;
    uint32 iar;
    uint32 tow_ned;
    int32  n;
    int32  e;
    int32  d;
    uint16 h_accuracy;
    uint16 v_accuracy;
    uint8  n_sats_ned;
    uint8  flags_ned;
    uint8  pad1[2];
    uint32 tow_vel;
    int32  n_vel;
    int32  e_vel;
    int32  d_vel;
    uint16 v_accuracy_vel;
    uint16 h_accuracy_vel;
    uint8  n_stats_vel;
    uint8  flags_vel;
    uint8  pad2[2];
} gps_veh_msg_t;

typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;

    uint8  command_count;
    uint8  error_count;
    uint8  pad[2];
    uint32 gps_write_count;
} GPSSIM_HkPacket_t;

typedef struct {
    CFE_SB_PipeId_t CmdPipe;
    CFE_SB_MsgPtr_t MsgPtr;

    GPSSIM_HkPacket_t HkPacket;

    CFE_EVS_BinFilter_t EventFilters[GPSSIM_FILTERED_EVT_COUNT];
} GPSSIM_AppData_t;

typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
} OS_PACK GPSSIM_NoArgsCmd_t;

/* GPSSIM Function Prototypes */
void    GPSSIM_TaskMain(void);
int32   GPSSIM_Init(void);
int32   GPSSIM_HWIF_Init(void);
void    GPSSIM_ResetCounters(void);
void    GPSSIM_AppPipe(void);
void    GPSSIM_SendPosition(void);
int32   GPSSIM_WriteDeviceData(gps_veh_msg_t *gps_veh_msg);
void    GPSSIM_ProcessGroundCommand(void);
void    GPSSIM_ReportHousekeeping(void);
boolean GPSSIM_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength);

/* GPSSIM Global Data */
extern GPSSIM_AppData_t GPSSIM_AppData;

#endif
