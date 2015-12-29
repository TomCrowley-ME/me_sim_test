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
#ifndef ADSIM_H
#define ADSIM_H

#include "cfe_es.h"
#include "cfe_sb.h"
#include "cfe_evs.h"

/* ADSIM Configuration Parameters */
#define ADSIM_PIPE_DEPTH              4

/* ADSIM Command Codes */
#define ADSIM_NOOP_CC              0x00
#define ADSIM_RESETCTRS_CC         0x01

/* ADSIM Event IDs */
#define ADSIM_INIT_INF_EID            1
#define ADSIM_NOOP_INF_EID            2
#define ADSIM_CRCMDPIPE_ERR_EID      20
#define ADSIM_SUBSCRIBE_ERR_EID      21
#define ADSIM_MSGID_ERR_EID          22
#define ADSIM_CC1_ERR_EID            23
#define ADSIM_MSGLEN_ERR_EID         24
#define ADSIM_DEVICE_ERR_EID         25
#define ADSIM_PIPE_ERR_EID           26
#define ADSIM_HWIF_ERR_EID           27

#define ADSIM_FILTERED_EVT_COUNT      8

/* ADSIM Structure Definitions */
typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;
    uint16 voltage_meas_vec[9];
    uint16 current_meas_vec[46];
    int16 pressure_meas_vec[6];
    int16 temp_meas_vec[64];
} adio_veh_msg_t;

typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;

    uint8  command_count;
    uint8  error_count;
    uint8  pad[2];
    uint32 ad_write_count;
} ADSIM_HkPacket_t;

typedef struct {
    CFE_SB_PipeId_t CmdPipe;
    CFE_SB_MsgPtr_t MsgPtr;

    ADSIM_HkPacket_t HkPacket;

    CFE_EVS_BinFilter_t EventFilters[ADSIM_FILTERED_EVT_COUNT];
} ADSIM_AppData_t;

typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
} OS_PACK ADSIM_NoArgsCmd_t;

/* ADSIM Function Prototypes */
void    ADSIM_TaskMain(void);
int32   ADSIM_Init(void);
int32   ADSIM_HWIF_Init(void);
void    ADSIM_ResetCounters(void);
void    ADSIM_AppPipe(void);
void    ADSIM_SendAnalogs(void);
int32   ADSIM_WriteDeviceData(adio_veh_msg_t *adio_veh_msg);
void    ADSIM_ProcessGroundCommand(void);
void    ADSIM_ReportHousekeeping(void);
boolean ADSIM_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength);

/* ADSIM Global Data */
extern ADSIM_AppData_t ADSIM_AppData;

#endif
