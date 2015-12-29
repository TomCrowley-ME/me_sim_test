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
#ifndef CI_TASK_H
#define CI_TASK_H

#include "cfe_sb.h"
#include "cfe_evs.h"

/* CI configuration parameters */
#define CI_CMD_PIPE_DEPTH 32
#define CI_DEFAULT_VC     1
#define CI_MAX_INGEST     1024

/* CI Command Codes */
#define CI_NOOP_CC        0
#define CI_RESETCTRS_CC   1

/* CI Event IDs */
#define CI_INIT_INF_EID           1
#define CI_NOOP_INF_EID           2
#define CI_CRCMDPIPE_ERR_EID     20
#define CI_SUBSCRIBE_ERR_EID     21
#define CI_DEVICE_ERR_EID        22
#define CI_MSGID_ERR_EID         23
#define CI_CC1_ERR_EID           24
#define CI_PIPE_ERR_EID          25

#define CI_FILTERED_EVT_COUNT    7

/* Structure definitions */
typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;
    uint8 CommandCount;
    uint8 ErrorCount;
    uint8 DeviceConnected;
    uint8 RejectionReason;
    uint32 IngestFrames;
    uint32 IngestErrors;
    uint32 BytesIngested;
    uint32 LastFrameTime;
} CI_HkPacket_t;

typedef struct {
    CFE_SB_PipeId_t CmdPipe;

    int CmdPipeFd;
    int RcvrDevFd;

    CFE_SB_MsgPtr_t MsgPtr;

    CI_HkPacket_t HkPacket;

    uint8 OS_ALIGN(4) FrameBuffer[CI_MAX_INGEST];
    uint8 OS_ALIGN(4) FrameBufferRaw[CI_MAX_INGEST];

    CFE_EVS_BinFilter_t EventFilters[CI_FILTERED_EVT_COUNT];
} CI_AppData_t;

/* Function Prototypes */
void  CI_TaskMain(void);
void  CI_DeleteCallback(void);
int32 CI_Init(void);
void  CI_AppPipe(void);
void  CI_ProcessGroundCommand(void);
void  CI_ReportHousekeeping(void);
void  CI_ResetCounters(void);
void  CI_ReadUplinkFrame(void);

#endif /* CI_TASK_H */
