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
#ifndef EGCSIM_H
#define EGCSIM_H

#include "cfe_es.h"
#include "cfe_sb.h"
#include "cfe_evs.h"

/* EGCSIM Configuration Parameters */
#define EGCSIM_PIPE_DEPTH              4
#define EGCSIM_TICK_MID   TICK_100HZ_MID

/* EGCSIM Command Codes */
#define EGCSIM_NOOP_CC              0x00
#define EGCSIM_RESETCTRS_CC         0x01

/* EGCSIM Event IDs */
#define EGCSIM_INIT_INF_EID            1
#define EGCSIM_NOOP_INF_EID            2
#define EGCSIM_CRCMDPIPE_ERR_EID      20
#define EGCSIM_SUBSCRIBE_ERR_EID      21
#define EGCSIM_MSGID_ERR_EID          22
#define EGCSIM_CC1_ERR_EID            23
#define EGCSIM_MSGLEN_ERR_EID         24
#define EGCSIM_DEVICE_ERR_EID         25
#define EGCSIM_PIPE_ERR_EID           26
#define EGCSIM_HWIF_ERR_EID           27

#define EGCSIM_FILTERED_EVT_COUNT      8

/* EGCSIM Structure Definitions */
typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;
    uint16 throttle;
} egc_veh_msg_t;


typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;

    uint8  command_count;
    uint8  error_count;
    uint8  pad[2];
    uint32 egc_read_count;
} EGCSIM_HkPacket_t;

typedef struct {
    CFE_SB_PipeId_t CmdPipe;
    CFE_SB_MsgPtr_t MsgPtr;

    EGCSIM_HkPacket_t HkPacket;
    egc_veh_msg_t egc_veh_msg;

    CFE_EVS_BinFilter_t EventFilters[EGCSIM_FILTERED_EVT_COUNT];
} EGCSIM_AppData_t;

typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
} OS_PACK EGCSIM_NoArgsCmd_t;

/* EGCSIM Function Prototypes */
void    EGCSIM_TaskMain(void);
int32   EGCSIM_Init(void);
int32   EGCSIM_HWIF_Init(void);
void    EGCSIM_ResetCounters(void);
void    EGCSIM_AppPipe(void);
void    EGCSIM_SendThrottle(void);
int32   EGCSIM_ReadDeviceData(uint16 *value);
void    EGCSIM_ProcessGroundCommand(void);
void    EGCSIM_ReportHousekeeping(void);
boolean EGCSIM_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength);

/* EGCSIM Global Data */
extern EGCSIM_AppData_t EGCSIM_AppData;

#endif
