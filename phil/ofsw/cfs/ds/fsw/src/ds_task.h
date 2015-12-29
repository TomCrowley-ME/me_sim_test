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
#ifndef DS_TASK_H
#define DS_TASK_H

#include "cfe_sb.h"
#include "cfe_evs.h"
#include "cfe_tbl.h"

#include "ds_cfg.h"
#include "ds_msg.h"

#define DS_APP_ENABLED  1
#define DS_APP_DISABLED 0

/* DS Event IDs */
#define DS_INIT_INF_EID           1
#define DS_NOOP_INF_EID           2
#define DS_RESETCTRS_DBG_EID     10
#define DS_CRCMDPIPE_ERR_EID     20
#define DS_SUBSCRIBE_ERR_EID     21
#define DS_MSGID_ERR_EID         22
#define DS_CC1_ERR_EID           23
#define DS_MSGLEN_ERR_EID        24
#define DS_PIPE_ERR_EID          25
#define DS_TBL_REG_ERR_EID       26
#define DS_TBL_LOAD_ERR_EID      27
#define DS_ACQ_PTR_ERR_EID       28

#define DS_FILTERED_EVT_COUNT     8

/* Structure definitions */
typedef struct {
    CFE_SB_PipeId_t CmdPipe;

    CFE_SB_MsgPtr_t MsgPtr;

    CFE_TBL_Handle_t FilterTblHandle;
    CFE_TBL_Handle_t FileTblHandle;

    DS_HkPacket_t HkPacket;

    CFE_EVS_BinFilter_t EventFilters[DS_FILTERED_EVT_COUNT];
} DS_AppData_t;

/* Function Prototypes */
void    DS_TaskMain(void);
int32   DS_Init(void);
void    DS_AppPipe(void);
void    DS_ProcessGroundCommand(void);
void    DS_ReportHousekeeping(void);
void    DS_ResetCounters(void);
boolean DS_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength);

void    DS_NoopCmd(void);
void    DS_ResetCountersCmd(void);

int32   DS_FilterTableValidate(void* buffer);
int32   DS_FileTableValidate(void* buffer);

#endif /* DS_TASK_H */
