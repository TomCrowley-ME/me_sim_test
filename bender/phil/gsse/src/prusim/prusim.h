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
#ifndef PRUSIM_H
#define PRUSIM_H

#include "cfe_es.h"
#include "cfe_sb.h"
#include "cfe_evs.h"

/* PRUSIM Configuration Parameters */
#define PRUSIM_PIPE_DEPTH             4

/* PRUSIM Command Codes */
#define PRUSIM_NOOP_CC             0x00
#define PRUSIM_RESETCTRS_CC        0x01

/* PRUSIM Event IDs */
#define PRUSIM_INIT_INF_EID           1
#define PRUSIM_NOOP_INF_EID           2
#define PRUSIM_CRCMDPIPE_ERR_EID     20
#define PRUSIM_SUBSCRIBE_ERR_EID     21
#define PRUSIM_MSGID_ERR_EID         22
#define PRUSIM_CC1_ERR_EID           23
#define PRUSIM_MSGLEN_ERR_EID        24
#define PRUSIM_DEVICE_ERR_EID        25
#define PRUSIM_PIPE_ERR_EID          26

#define PRUSIM_FILTERED_EVT_COUNT     8

/* PRUSIM Structure Definitions */
typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;

    uint8  command_count;
    uint8  error_count;
} PRUSIM_HkPacket_t;

typedef struct {
    CFE_SB_PipeId_t CmdPipe;
    CFE_SB_MsgPtr_t MsgPtr;

    PRUSIM_HkPacket_t HkPacket;

    CFE_EVS_BinFilter_t EventFilters[PRUSIM_FILTERED_EVT_COUNT];
} PRUSIM_AppData_t;

typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
} PRUSIM_NoArgsCmd_t;

/* PRUSIM Function Prototypes */
void    PRUSIM_TaskMain(void);
int32   PRUSIM_Init(void);
int32   PRUSIM_LoadPRUFirmware(void);
void    PRUSIM_ResetCounters(void);
void    PRUSIM_AppPipe(void);
void    PRUSIM_ProcessGroundCommand(void);
void    PRUSIM_ReportHousekeeping(void);
boolean PRUSIM_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength);

/* PRUSIM Global Data */
extern PRUSIM_AppData_t PRUSIM_AppData;

#endif
