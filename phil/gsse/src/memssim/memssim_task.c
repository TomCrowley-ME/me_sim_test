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

#include "memssim.h"

MEMSSIM_AppData_t MEMSSIM_AppData;

void MEMSSIM_TaskMain(void) {
    uint32 RunStatus = CFE_ES_APP_RUN;
    int32  Status = CFE_SUCCESS;

    CFE_ES_PerfLogEntry(MEMSSIM_MAIN_TASK_PERF_ID);

    Status = MEMSSIM_Init();
    if (Status != CFE_SUCCESS) {
        RunStatus = CFE_ES_APP_ERROR;
    }

    while (CFE_ES_RunLoop(&RunStatus) == TRUE) {
        CFE_ES_PerfLogExit(MEMSSIM_MAIN_TASK_PERF_ID);

        Status = CFE_SB_RcvMsg(&MEMSSIM_AppData.MsgPtr, MEMSSIM_AppData.CmdPipe, CFE_SB_PEND_FOREVER);

        CFE_ES_PerfLogEntry(MEMSSIM_MAIN_TASK_PERF_ID);

        if (Status == CFE_SUCCESS) {
            MEMSSIM_AppPipe();
        } else {
            CFE_EVS_SendEvent(MEMSSIM_PIPE_ERR_EID, CFE_EVS_ERROR, "SB pipe read error, MEMSSIM will exit.");
            RunStatus = CFE_ES_APP_ERROR;
        }
    }
}

int32 MEMSSIM_Init(void) {
    int32 Status = CFE_SUCCESS;

    CFE_ES_RegisterApp();

    /* Initialize app data */
    MEMSSIM_AppData.CmdPipe = 0;
    MEMSSIM_AppData.MsgPtr = NULL;

    /* Set up and register events */
    MEMSSIM_AppData.EventFilters[0].EventID = MEMSSIM_INIT_INF_EID;
    MEMSSIM_AppData.EventFilters[0].Mask    = CFE_EVS_NO_FILTER;
    MEMSSIM_AppData.EventFilters[1].EventID = MEMSSIM_NOOP_INF_EID;
    MEMSSIM_AppData.EventFilters[1].Mask    = CFE_EVS_NO_FILTER;
    MEMSSIM_AppData.EventFilters[2].EventID = MEMSSIM_CRCMDPIPE_ERR_EID;
    MEMSSIM_AppData.EventFilters[2].Mask    = CFE_EVS_NO_FILTER;
    MEMSSIM_AppData.EventFilters[3].EventID = MEMSSIM_SUBSCRIBE_ERR_EID;
    MEMSSIM_AppData.EventFilters[3].Mask    = CFE_EVS_NO_FILTER;
    MEMSSIM_AppData.EventFilters[4].EventID = MEMSSIM_MSGID_ERR_EID;
    MEMSSIM_AppData.EventFilters[4].Mask    = CFE_EVS_NO_FILTER;
    MEMSSIM_AppData.EventFilters[5].EventID = MEMSSIM_CC1_ERR_EID;
    MEMSSIM_AppData.EventFilters[5].Mask    = CFE_EVS_NO_FILTER;
    MEMSSIM_AppData.EventFilters[6].EventID = MEMSSIM_MSGLEN_ERR_EID;
    MEMSSIM_AppData.EventFilters[6].Mask    = CFE_EVS_NO_FILTER;
    MEMSSIM_AppData.EventFilters[7].EventID = MEMSSIM_PIPE_ERR_EID;
    MEMSSIM_AppData.EventFilters[7].Mask    = CFE_EVS_NO_FILTER;

    Status = CFE_EVS_Register(MEMSSIM_AppData.EventFilters, MEMSSIM_FILTERED_EVT_COUNT, CFE_EVS_BINARY_FILTER);
    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog("Error registering events, RC = 0x%08X\n", Status);
        return Status;
    }

    /* Initialize housekeeping */
    CFE_SB_InitMsg(&MEMSSIM_AppData.HkPacket, MEMSSIM_HK_TLM_MID, sizeof(MEMSSIM_HkPacket_t), TRUE);
    MEMSSIM_ResetCounters();

    /* Create a command pipe and subscribe to its messages */
    Status = CFE_SB_CreatePipe(&MEMSSIM_AppData.CmdPipe, MEMSSIM_PIPE_DEPTH, "MEMSSIM_CMD_PIPE");
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(MEMSSIM_CRCMDPIPE_ERR_EID, CFE_EVS_ERROR, "Can't create command pipe, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(MEMSSIM_CMD_MID, MEMSSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(MEMSSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to MEMSSIM_CMD_MID(0x%04X), RC=0x%08X", MEMSSIM_CMD_MID, Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(MEMSSIM_SEND_HK_MID, MEMSSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(MEMSSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to MEMSSIM_SEND_HK_MID(0x%04X), RC=0x%08X", MEMSSIM_SEND_HK_MID, Status);
        return Status;
    }
    CFE_SB_Subscribe(MEM_VEH_MID, MEMSSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(MEMSSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to MEM_VEH_MID (0x%04X), RC=0x%08X", MEM_VEH_MID, Status);
        return Status;
    }

    Status = MEMSSIM_HWIF_Init();
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(MEMSSIM_HWIF_ERR_EID, CFE_EVS_ERROR, "Error initializing HWIF, RC=0x%08X", Status);
        return Status;
    }

    CFE_EVS_SendEvent(MEMSSIM_INIT_INF_EID, CFE_EVS_INFORMATION, "App initialized.");
    return CFE_SUCCESS;
}

void MEMSSIM_AppPipe(void) {
    CFE_SB_MsgId_t MsgId = CFE_SB_GetMsgId(MEMSSIM_AppData.MsgPtr);

    switch (MsgId) {
        case MEMSSIM_CMD_MID:
            MEMSSIM_ProcessGroundCommand();
            break;
        case MEMSSIM_SEND_HK_MID:
            MEMSSIM_ReportHousekeeping();
            break;
        case MEM_VEH_MID:
            MEMSSIM_SendDeviceReadings();
            break;
        default:
            CFE_EVS_SendEvent(MEMSSIM_MSGID_ERR_EID, CFE_EVS_ERROR, "Received invalid MsgId 0x%04X", MsgId);
            MEMSSIM_AppData.HkPacket.error_count++;
            break;
    }
}

void MEMSSIM_SendDeviceReadings(void) {
    int32 Status;

    Status = MEMSSIM_WriteDeviceData((mem_veh_msg_t *)MEMSSIM_AppData.MsgPtr);
    if (Status == CFE_SUCCESS) {
        MEMSSIM_AppData.HkPacket.mems_write_count++;
    } else {
        CFE_EVS_SendEvent(MEMSSIM_DEVICE_ERR_EID, CFE_EVS_ERROR, "Error writing to MEMS device");
    }
}

void MEMSSIM_ProcessGroundCommand(void) {
    uint16 ExpectedLength = sizeof(MEMSSIM_NoArgsCmd_t);

    if (MEMSSIM_VerifyCmdLength(MEMSSIM_AppData.MsgPtr, ExpectedLength)) {
        uint16 CommandCode = CFE_SB_GetCmdCode(MEMSSIM_AppData.MsgPtr);

        switch (CommandCode) {
            case MEMSSIM_NOOP_CC:
                MEMSSIM_AppData.HkPacket.command_count++;
                CFE_EVS_SendEvent(MEMSSIM_NOOP_INF_EID, CFE_EVS_INFORMATION, "NOOP command");
                break;
            case MEMSSIM_RESETCTRS_CC:
                MEMSSIM_ResetCounters();
                break;
            default:
                MEMSSIM_AppData.HkPacket.error_count++;
                CFE_EVS_SendEvent(MEMSSIM_CC1_ERR_EID, CFE_EVS_ERROR, "Invalid command code %u", CommandCode);
                break;
        }
    }
}

void MEMSSIM_ReportHousekeeping(void) {
    CFE_SB_TimeStampMsg((CFE_SB_MsgPtr_t) &MEMSSIM_AppData.HkPacket);
    CFE_SB_SendMsg((CFE_SB_MsgPtr_t) &MEMSSIM_AppData.HkPacket);
}


void MEMSSIM_ResetCounters(void) {
    MEMSSIM_AppData.HkPacket.command_count = 0;
    MEMSSIM_AppData.HkPacket.error_count = 0;
    MEMSSIM_AppData.HkPacket.mems_write_count = 0;
}

boolean MEMSSIM_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength) {
    boolean result = TRUE;
    uint16  ActualLength = CFE_SB_GetTotalMsgLength(Msg);

    if (ExpectedLength != ActualLength) {
        CFE_SB_MsgId_t MessageId = CFE_SB_GetMsgId(Msg);
        uint16 CommandCode = CFE_SB_GetCmdCode(Msg);

        CFE_EVS_SendEvent(MEMSSIM_MSGLEN_ERR_EID, CFE_EVS_ERROR, "Invalid cmd length: MID = 0x%04X, CC = %02u, Exp Len = %u, Len = %u", MessageId, CommandCode, ExpectedLength, ActualLength);
        result = FALSE;
        MEMSSIM_AppData.HkPacket.error_count++;
    }
    return result;
}
