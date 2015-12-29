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
#ifndef STSIM_H
#define STSIM_H

#include "cfe_es.h"
#include "cfe_sb.h"
#include "cfe_evs.h"

/* STSIM Configuration Parameters */
#define STSIM_PIPE_DEPTH             4

/* STSIM Command Codes */
#define STSIM_NOOP_CC             0x00
#define STSIM_RESETCTRS_CC        0x01

/* STSIM Event IDs */
#define STSIM_INIT_INF_EID           1
#define STSIM_NOOP_INF_EID           2
#define STSIM_CRCMDPIPE_ERR_EID     20
#define STSIM_SUBSCRIBE_ERR_EID     21
#define STSIM_MSGID_ERR_EID         22
#define STSIM_CC1_ERR_EID           23
#define STSIM_MSGLEN_ERR_EID        24
#define STSIM_DEVICE_ERR_EID        25
#define STSIM_PIPE_ERR_EID          26
#define STSIM_HWIF_ERR_EID          27

#define STSIM_FILTERED_EVT_COUNT     8

/* STSIM Structure Definitions */

typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;
    uint8  q_valid;
    uint8  pad1[3];
    double q_eci_to_head[4];
    double acc_meas[3];
    double rate_meas[3];
} OS_PACK sta_veh_msg_t;

typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;

    uint8  command_count;
    uint8  error_count;
    uint32 st_write_count;
} OS_PACK STSIM_HkPacket_t;

typedef struct {
    CFE_SB_PipeId_t CmdPipe;
    CFE_SB_MsgPtr_t MsgPtr;

    STSIM_HkPacket_t HkPacket;

    CFE_EVS_BinFilter_t EventFilters[STSIM_FILTERED_EVT_COUNT];
} STSIM_AppData_t;

typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
} OS_PACK STSIM_NoArgsCmd_t;

/* STSIM Function Prototypes */
void    STSIM_TaskMain(void);
int32   STSIM_Init(void);
int32   STSIM_HWIF_Init(void);
void    STSIM_ResetCounters(void);
void    STSIM_AppPipe(void);
void    STSIM_WriteSTValues(void);
void    STSIM_ProcessGroundCommand(void);
void    STSIM_ReportHousekeeping(void);
boolean STSIM_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength);

/* STSIM Global Data */
extern STSIM_AppData_t STSIM_AppData;

#endif
