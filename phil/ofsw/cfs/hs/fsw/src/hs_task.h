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
#ifndef HS_TASK_H
#define HS_TASK_H

#include "cfe_sb.h"
#include "cfe_evs.h"
#include "cfe_tbl.h"

#include "hs_cfg.h"
#include "hs_msg.h"

/* HS Event IDs */
#define HS_INIT_INF_EID           1
#define HS_NOOP_INF_EID           2
#define HS_APP_MON_ENABLE_INF_EID 3
#define HS_DISABLE_INF_EID        4
#define HS_ACTION_INF_EID         5
#define HS_RESETCTRS_DBG_EID     10
#define HS_CRPIPE_ERR_EID        20
#define HS_SUBSCRIBE_ERR_EID     21
#define HS_MSGID_ERR_EID         22
#define HS_CC1_ERR_EID           23
#define HS_MSGLEN_ERR_EID        24
#define HS_PIPE_ERR_EID          25
#define HS_TBL_REG_ERR_EID       26
#define HS_TBL_LOAD_ERR_EID      27
#define HS_ACQ_PTR_ERR_EID       28
#define HS_INVALID_APP_ERR_EID   29
#define HS_MSG_ACTION_ERR_EID    30

#define HS_FILTERED_EVT_COUNT     9

/* Structure definitions */
typedef struct {
    CFE_SB_PipeId_t WakeupPipe;
    CFE_SB_PipeId_t CmdPipe;
    CFE_SB_PipeId_t EventPipe;

    CFE_SB_MsgPtr_t MsgPtr;

    CFE_TBL_Handle_t MsgActTblHandle;
    CFE_TBL_Handle_t AppMonitorTblHandle;
    CFE_TBL_Handle_t EventMonitorTblHandle;

    HS_HkPacket_t HkPacket;

    uint32 StaticAppCounts[HS_MAX_CRITICAL_APPS];
    uint32 PrevAppCounts[HS_MAX_CRITICAL_APPS];

    uint8 CpuUtilHist[HS_PEAK_NUM_INTERVALS];
    uint32 CpuUtilPtr;

    CFE_EVS_BinFilter_t EventFilters[HS_FILTERED_EVT_COUNT];
} HS_AppData_t;

/* Function Prototypes */
void    HS_TaskMain(void);
int32   HS_Init(void);
void    HS_AppPipe(void);
void    HS_ProcessGroundCommand(void);
void    HS_ReportHousekeeping(void);
void    HS_ResetCounters(void);
boolean HS_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength);
void    HS_MonitorApplications(void);
void    HS_MonitorEvents(void);
void    HS_PerformMessageAction(uint32 MessageNumber);

void    HS_NoopCmd(void);
void    HS_ResetCountersCmd(void);

int32   HS_MessageActionTableValidate(void* buffer);
int32   HS_AppMonitorTableValidate(void* buffer);
int32   HS_EventMonitorTableValidate(void* buffer);

#endif /* HS_TASK_H */
