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
#include "cfe_evs.h"
#include "cfe_sb.h"

#include "app_msgids.h"
#include "app_perfids.h"

#include "stsim.h"

STSIM_AppData_t STSIM_AppData;

void STSIM_TaskMain(void) {
    uint32 RunStatus = CFE_ES_APP_RUN;
    int32  Status = CFE_SUCCESS;

    CFE_ES_PerfLogEntry(STSIM_MAIN_TASK_PERF_ID);

    Status = STSIM_Init();
    if (Status != CFE_SUCCESS) {
        RunStatus = CFE_ES_APP_ERROR;
    }

    while (CFE_ES_RunLoop(&RunStatus) == TRUE) {
        CFE_ES_PerfLogExit(STSIM_MAIN_TASK_PERF_ID);

        Status = CFE_SB_RcvMsg(&STSIM_AppData.MsgPtr, STSIM_AppData.CmdPipe, CFE_SB_PEND_FOREVER);

        CFE_ES_PerfLogEntry(STSIM_MAIN_TASK_PERF_ID);

        if (Status == CFE_SUCCESS) {
            STSIM_AppPipe();
        } else {
            CFE_EVS_SendEvent(STSIM_PIPE_ERR_EID, CFE_EVS_ERROR, "STSIM: SB pipe read error, STSIM will exit.");
            RunStatus = CFE_ES_APP_ERROR;
        }
    }
}

int32 STSIM_Init(void) {
    int32 Status = CFE_SUCCESS;

    CFE_ES_RegisterApp();

    /* Initialize app data */
    STSIM_AppData.CmdPipe = 0;
    STSIM_AppData.MsgPtr = NULL;

    /* Set up and register events */
    STSIM_AppData.EventFilters[0].EventID = STSIM_INIT_INF_EID;
    STSIM_AppData.EventFilters[0].Mask    = CFE_EVS_NO_FILTER;
    STSIM_AppData.EventFilters[1].EventID = STSIM_NOOP_INF_EID;
    STSIM_AppData.EventFilters[1].Mask    = CFE_EVS_NO_FILTER;
    STSIM_AppData.EventFilters[2].EventID = STSIM_CRCMDPIPE_ERR_EID;
    STSIM_AppData.EventFilters[2].Mask    = CFE_EVS_NO_FILTER;
    STSIM_AppData.EventFilters[3].EventID = STSIM_SUBSCRIBE_ERR_EID;
    STSIM_AppData.EventFilters[3].Mask    = CFE_EVS_NO_FILTER;
    STSIM_AppData.EventFilters[4].EventID = STSIM_MSGID_ERR_EID;
    STSIM_AppData.EventFilters[4].Mask    = CFE_EVS_NO_FILTER;
    STSIM_AppData.EventFilters[5].EventID = STSIM_CC1_ERR_EID;
    STSIM_AppData.EventFilters[5].Mask    = CFE_EVS_NO_FILTER;
    STSIM_AppData.EventFilters[6].EventID = STSIM_MSGLEN_ERR_EID;
    STSIM_AppData.EventFilters[6].Mask    = CFE_EVS_NO_FILTER;
    STSIM_AppData.EventFilters[7].EventID = STSIM_PIPE_ERR_EID;
    STSIM_AppData.EventFilters[7].Mask    = CFE_EVS_NO_FILTER;

    Status = CFE_EVS_Register(STSIM_AppData.EventFilters, STSIM_FILTERED_EVT_COUNT, CFE_EVS_BINARY_FILTER);
    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog("STSIM: Error registering events, RC = 0x%08X\n", Status);
        return Status;
    }

    /* Initialize housekeeping */
    CFE_SB_InitMsg(&STSIM_AppData.HkPacket, STSIM_HK_TLM_MID, sizeof(STSIM_HkPacket_t), TRUE);
    STSIM_ResetCounters();

    /* Create a command pipe and subscribe to its messages */
    Status = CFE_SB_CreatePipe(&STSIM_AppData.CmdPipe, STSIM_PIPE_DEPTH, "STSIM_CMD_PIPE");
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(STSIM_CRCMDPIPE_ERR_EID, CFE_EVS_ERROR, "STSIM: Can't create command pipe, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(STSIM_CMD_MID, STSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(STSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "STSIM: Error subscribing to STSIM_CMD_MID(0x%04X), RC=0x%08X", STSIM_CMD_MID, Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(STSIM_SEND_HK_MID, STSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(STSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "STSIM: Error subscribing to STSIM_SEND_HK_MID(0x%04X), RC=0x%08X", STSIM_SEND_HK_MID, Status);
        return Status;
    }
    CFE_SB_Subscribe(STA_VEH_MID, STSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(STSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "STSIM: Error subscribing to STA_VEH_MID (0x%04X), RC=0x%08X", STA_VEH_MID, Status);
        return Status;
    }

    Status = STSIM_HWIF_Init();
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(STSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error initializing HWIF, RC=0x%08X", Status);
        return Status;
    }

    CFE_EVS_SendEvent(STSIM_INIT_INF_EID, CFE_EVS_INFORMATION, "STSIM app initialized.");
    return CFE_SUCCESS;
}

void STSIM_AppPipe(void) {
    CFE_SB_MsgId_t MsgId = CFE_SB_GetMsgId(STSIM_AppData.MsgPtr);

    switch (MsgId) {
        case STSIM_CMD_MID:
            STSIM_ProcessGroundCommand();
            break;
        case STSIM_SEND_HK_MID:
            STSIM_ReportHousekeeping();
            break;
        case STA_VEH_MID:
            STSIM_WriteSTValues();
            break;
        default:
            CFE_EVS_SendEvent(STSIM_MSGID_ERR_EID, CFE_EVS_ERROR, "STSIM: Received invalid MsgId 0x%04X", MsgId);
            STSIM_AppData.HkPacket.error_count++;
            break;
    }
}

void STSIM_ProcessGroundCommand(void) {
    uint16 ExpectedLength = sizeof(STSIM_NoArgsCmd_t);

    if (STSIM_VerifyCmdLength(STSIM_AppData.MsgPtr, ExpectedLength)) {
        uint16 CommandCode = CFE_SB_GetCmdCode(STSIM_AppData.MsgPtr);

        switch (CommandCode) {
            case STSIM_NOOP_CC:
                STSIM_AppData.HkPacket.command_count++;
                CFE_EVS_SendEvent(STSIM_NOOP_INF_EID, CFE_EVS_INFORMATION, "STSIM: NOOP command");
                break;
            case STSIM_RESETCTRS_CC:
                STSIM_ResetCounters();
                break;
            default:
                STSIM_AppData.HkPacket.error_count++;
                CFE_EVS_SendEvent(STSIM_CC1_ERR_EID, CFE_EVS_ERROR, "STSIM: Invalid command code %u", CommandCode);
                break;
        }
    }
}

void STSIM_ReportHousekeeping(void) {
    CFE_SB_TimeStampMsg((CFE_SB_MsgPtr_t) &STSIM_AppData.HkPacket);
    CFE_SB_SendMsg((CFE_SB_MsgPtr_t) &STSIM_AppData.HkPacket);
}


void STSIM_ResetCounters(void) {
    STSIM_AppData.HkPacket.command_count = 0;
    STSIM_AppData.HkPacket.error_count = 0;
    STSIM_AppData.HkPacket.st_write_count = 0;
}

boolean STSIM_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength) {
    boolean result = TRUE;
    uint16  ActualLength = CFE_SB_GetTotalMsgLength(Msg);

    if (ExpectedLength != ActualLength) {
        CFE_SB_MsgId_t MessageId = CFE_SB_GetMsgId(Msg);
        uint16 CommandCode = CFE_SB_GetCmdCode(Msg);

        CFE_EVS_SendEvent(STSIM_MSGLEN_ERR_EID, CFE_EVS_ERROR, "STSIM: Invalid cmd length: MID = 0x%04X, CC = %02u, Exp Len = %u, Len = %u", MessageId, CommandCode, ExpectedLength, ActualLength);
        result = FALSE;
        STSIM_AppData.HkPacket.error_count++;
    }
    return result;
}
