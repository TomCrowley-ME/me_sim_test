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
#include "cfe_error.h"
#include "cfe_es.h"

#include "app_msgids.h"
#include "cfe_msgids.h"
#include "app_perfids.h"

#include "ds_task.h"
#include "ds_tables.h"

/* Global data */
DS_AppData_t DS_AppData;

void DS_TaskMain(void) {
    uint32 RunStatus = CFE_ES_APP_RUN;
    int32  Status = CFE_SUCCESS;

    CFE_ES_PerfLogEntry(DS_MAIN_TASK_PERF_ID);

    Status = DS_Init();
    if (Status != CFE_SUCCESS) {
        RunStatus = CFE_ES_APP_ERROR;
    }

    while (CFE_ES_RunLoop(&RunStatus) == TRUE) {
        CFE_ES_PerfLogExit(DS_MAIN_TASK_PERF_ID);
        Status = CFE_SB_RcvMsg(&DS_AppData.MsgPtr, DS_AppData.CmdPipe, CFE_SB_PEND_FOREVER);
        CFE_ES_PerfLogEntry(DS_MAIN_TASK_PERF_ID);

        if (Status == CFE_SUCCESS) {
            DS_AppPipe();
        } else if (Status != CFE_SB_TIME_OUT) {
            CFE_EVS_SendEvent(DS_PIPE_ERR_EID, CFE_EVS_ERROR, "Error reading command pipe, RC=0x%08X", Status);
            RunStatus = CFE_ES_APP_ERROR;
        }
    }

    CFE_ES_PerfLogExit(DS_MAIN_TASK_PERF_ID);

    CFE_ES_ExitApp(RunStatus);
}

int32 DS_Init(void) {
    int32 Status = CFE_SUCCESS;
    uint32 i;

    CFE_ES_RegisterApp();

    /* Initialize app data */
    DS_AppData.CmdPipe = 0;
    DS_AppData.MsgPtr = NULL;

    DS_AppData.FilterTblHandle = CFE_TBL_BAD_TABLE_HANDLE;
    DS_AppData.FileTblHandle = CFE_TBL_BAD_TABLE_HANDLE;

    /* Set up and register events */
    DS_AppData.EventFilters[0].EventID = DS_INIT_INF_EID;
    DS_AppData.EventFilters[0].Mask    = CFE_EVS_NO_FILTER;
    DS_AppData.EventFilters[1].EventID = DS_NOOP_INF_EID;
    DS_AppData.EventFilters[1].Mask    = CFE_EVS_NO_FILTER;
    DS_AppData.EventFilters[2].EventID = DS_CRCMDPIPE_ERR_EID;
    DS_AppData.EventFilters[2].Mask    = CFE_EVS_NO_FILTER;
    DS_AppData.EventFilters[3].EventID = DS_SUBSCRIBE_ERR_EID;
    DS_AppData.EventFilters[4].Mask    = CFE_EVS_NO_FILTER;
    DS_AppData.EventFilters[4].EventID = DS_MSGID_ERR_EID;
    DS_AppData.EventFilters[4].Mask    = CFE_EVS_NO_FILTER;
    DS_AppData.EventFilters[5].EventID = DS_CC1_ERR_EID;
    DS_AppData.EventFilters[5].Mask    = CFE_EVS_NO_FILTER;
    DS_AppData.EventFilters[6].EventID = DS_MSGLEN_ERR_EID;
    DS_AppData.EventFilters[6].Mask    = CFE_EVS_NO_FILTER;
    DS_AppData.EventFilters[7].EventID = DS_PIPE_ERR_EID;
    DS_AppData.EventFilters[7].Mask    = CFE_EVS_NO_FILTER;

    Status = CFE_EVS_Register(DS_AppData.EventFilters, DS_FILTERED_EVT_COUNT, CFE_EVS_BINARY_FILTER);
    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog("Error registering events, RC = 0x%08X\n", Status);
        return Status;
    }

    /* Initialize housekeeping */
    CFE_SB_InitMsg(&DS_AppData.HkPacket, DS_HK_TLM_MID, sizeof(DS_HkPacket_t), TRUE);
    DS_ResetCounters();

    DS_AppData.HkPacket.AppEnableState = DS_APP_ENABLED;

    for (i = 0; i < DS_DEST_FILE_CNT; i++) {
        DS_AppData.HkPacket.FileStatus[i].Age = 0;
        DS_AppData.HkPacket.FileStatus[i].Size = 0;
        DS_AppData.HkPacket.FileStatus[i].Rate = 0;
        DS_AppData.HkPacket.FileStatus[i].Sequence = 0;
        DS_AppData.HkPacket.FileStatus[i].EnableState = 0;
        DS_AppData.HkPacket.FileStatus[i].OpenState = 0;
    }

    /* Create a command pipe and subscribe to its messages */
    Status = CFE_SB_CreatePipe(&DS_AppData.CmdPipe, DS_APP_PIPE_DEPTH, DS_APP_PIPE_NAME);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(DS_CRCMDPIPE_ERR_EID, CFE_EVS_ERROR, "Can't create command pipe, RC = 0x%08X", Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(DS_CMD_MID, DS_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(DS_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to DS_CMD_MID(0x%04X), RC=0x%08X", DS_CMD_MID, Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(DS_SEND_HK_MID, DS_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(DS_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to DS_SEND_HK_MID(0x%04X), RC=0x%08X", DS_SEND_HK_MID, Status);
        return Status;
    }

    /* REGISTER TABLES */

    CFE_EVS_SendEvent(DS_INIT_INF_EID, CFE_EVS_INFORMATION, "DS app initialized.");

    return CFE_SUCCESS;
}

void DS_AppPipe(void) {
    CFE_SB_MsgId_t MsgId;

    MsgId = CFE_SB_GetMsgId(DS_AppData.MsgPtr);
    switch (MsgId) {
        case DS_CMD_MID:
            DS_ProcessGroundCommand();
            break;
        case DS_SEND_HK_MID:
            DS_ReportHousekeeping();
            break;
        default:
            /* Process packet */
            break;
    }
}

void DS_ProcessGroundCommand(void) {
    uint16 CommandCode;

    CommandCode = CFE_SB_GetCmdCode(DS_AppData.MsgPtr);
    switch (CommandCode) {
        case DS_NOOP_CC:
            if (DS_VerifyCmdLength(DS_AppData.MsgPtr, sizeof(DS_NoArgsCmd_t))) {
                CFE_EVS_SendEvent(DS_NOOP_INF_EID, CFE_EVS_INFORMATION, "NOOP Command");
                DS_AppData.HkPacket.CommandCount++;
            }
            break;
        case DS_RESETCTRS_CC:
            if (DS_VerifyCmdLength(DS_AppData.MsgPtr, sizeof(DS_NoArgsCmd_t))) {
                DS_ResetCounters();
            }
            break;
        default:
            CFE_EVS_SendEvent(DS_CC1_ERR_EID, CFE_EVS_ERROR, "Invalid command code, MID=0x%04X, CC=%02u", CFE_SB_GetMsgId(DS_AppData.MsgPtr), CommandCode);
            DS_AppData.HkPacket.ErrorCount++;
            break;
    }
}

void DS_ReportHousekeeping(void) {
    /* MANAGE TABLES */
    /* FILL OUT HK PACKET FILE STATUSES */
    /* Timestamp and send HK packet */
    CFE_SB_TimeStampMsg((CFE_SB_MsgPtr_t)&DS_AppData.HkPacket);
    CFE_SB_SendMsg((CFE_SB_MsgPtr_t)&DS_AppData.HkPacket);
}

void DS_ResetCounters(void) {
    DS_AppData.HkPacket.CommandCount = 0;
    DS_AppData.HkPacket.ErrorCount = 0;
    DS_AppData.HkPacket.DisabledPktCount = 0;
    DS_AppData.HkPacket.IgnoredPktCount = 0;
    DS_AppData.HkPacket.FilteredPktCount = 0;
    DS_AppData.HkPacket.PassedPktCount = 0;
    DS_AppData.HkPacket.FileWriteCount = 0;
    DS_AppData.HkPacket.FileWriteErrCount = 0;
    DS_AppData.HkPacket.FileUpdateCount = 0;
    DS_AppData.HkPacket.FileUpdateErrCount = 0;
    DS_AppData.HkPacket.DestTblLoadCount = 0;
    DS_AppData.HkPacket.DestPtrErrCount = 0;
    DS_AppData.HkPacket.FilterTblLoadCount = 0;
    DS_AppData.HkPacket.FilterPtrErrCount = 0;
}

boolean DS_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength) {
    boolean result = TRUE;
    uint16  ActualLength = CFE_SB_GetTotalMsgLength(Msg);

    if (ExpectedLength != ActualLength) {
        CFE_SB_MsgId_t MessageId = CFE_SB_GetMsgId(Msg);
        uint16 CommandCode = CFE_SB_GetCmdCode(Msg);

        CFE_EVS_SendEvent(DS_MSGLEN_ERR_EID, CFE_EVS_ERROR, "Invalid cmd length: MID = 0x%04X, CC = %02u, Exp Len = %u, Len = %u", MessageId, CommandCode, ExpectedLength, ActualLength);
        result = FALSE;
        DS_AppData.HkPacket.ErrorCount++;
    }
    return result;
}
