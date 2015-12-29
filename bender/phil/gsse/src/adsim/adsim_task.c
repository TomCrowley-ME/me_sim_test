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

#include "adsim.h"

ADSIM_AppData_t ADSIM_AppData;

void ADSIM_TaskMain(void) {
    uint32 RunStatus = CFE_ES_APP_RUN;
    int32  Status = CFE_SUCCESS;

    CFE_ES_PerfLogEntry(ADSIM_MAIN_TASK_PERF_ID);

    Status = ADSIM_Init();
    if (Status != CFE_SUCCESS) {
        RunStatus = CFE_ES_APP_ERROR;
    }

    while (CFE_ES_RunLoop(&RunStatus) == TRUE) {
        CFE_ES_PerfLogExit(ADSIM_MAIN_TASK_PERF_ID);

        Status = CFE_SB_RcvMsg(&ADSIM_AppData.MsgPtr, ADSIM_AppData.CmdPipe, CFE_SB_PEND_FOREVER);

        CFE_ES_PerfLogEntry(ADSIM_MAIN_TASK_PERF_ID);

        if (Status == CFE_SUCCESS) {
            ADSIM_AppPipe();
        } else {
            CFE_EVS_SendEvent(ADSIM_PIPE_ERR_EID, CFE_EVS_ERROR, "SB pipe read error, ADSIM will exit.");
            RunStatus = CFE_ES_APP_ERROR;
        }
    }
}

int32 ADSIM_Init(void) {
    int32 Status = CFE_SUCCESS;

    CFE_ES_RegisterApp();

    /* Initialize app data */
    ADSIM_AppData.CmdPipe = 0;
    ADSIM_AppData.MsgPtr = NULL;

    /* Set up and register events */
    ADSIM_AppData.EventFilters[0].EventID = ADSIM_INIT_INF_EID;
    ADSIM_AppData.EventFilters[0].Mask    = CFE_EVS_NO_FILTER;
    ADSIM_AppData.EventFilters[1].EventID = ADSIM_NOOP_INF_EID;
    ADSIM_AppData.EventFilters[1].Mask    = CFE_EVS_NO_FILTER;
    ADSIM_AppData.EventFilters[2].EventID = ADSIM_CRCMDPIPE_ERR_EID;
    ADSIM_AppData.EventFilters[2].Mask    = CFE_EVS_NO_FILTER;
    ADSIM_AppData.EventFilters[3].EventID = ADSIM_SUBSCRIBE_ERR_EID;
    ADSIM_AppData.EventFilters[3].Mask    = CFE_EVS_NO_FILTER;
    ADSIM_AppData.EventFilters[4].EventID = ADSIM_MSGID_ERR_EID;
    ADSIM_AppData.EventFilters[4].Mask    = CFE_EVS_NO_FILTER;
    ADSIM_AppData.EventFilters[5].EventID = ADSIM_CC1_ERR_EID;
    ADSIM_AppData.EventFilters[5].Mask    = CFE_EVS_NO_FILTER;
    ADSIM_AppData.EventFilters[6].EventID = ADSIM_MSGLEN_ERR_EID;
    ADSIM_AppData.EventFilters[6].Mask    = CFE_EVS_NO_FILTER;
    ADSIM_AppData.EventFilters[7].EventID = ADSIM_PIPE_ERR_EID;
    ADSIM_AppData.EventFilters[7].Mask    = CFE_EVS_NO_FILTER;

    Status = CFE_EVS_Register(ADSIM_AppData.EventFilters, ADSIM_FILTERED_EVT_COUNT, CFE_EVS_BINARY_FILTER);
    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog("Error registering events, RC = 0x%08X\n", Status);
        return Status;
    }

    /* Initialize housekeeping */
    CFE_SB_InitMsg(&ADSIM_AppData.HkPacket, ADSIM_HK_TLM_MID, sizeof(ADSIM_HkPacket_t), TRUE);
    ADSIM_ResetCounters();

    /* Create a command pipe and subscribe to its messages */
    Status = CFE_SB_CreatePipe(&ADSIM_AppData.CmdPipe, ADSIM_PIPE_DEPTH, "ADSIM_CMD_PIPE");
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(ADSIM_CRCMDPIPE_ERR_EID, CFE_EVS_ERROR, "Can't create command pipe, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(ADSIM_CMD_MID, ADSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(ADSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to ADSIM_CMD_MID(0x%04X), RC=0x%08X", ADSIM_CMD_MID, Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(ADSIM_SEND_HK_MID, ADSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(ADSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to ADSIM_SEND_HK_MID(0x%04X), RC=0x%08X", ADSIM_SEND_HK_MID, Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(ADIO_VEH_MID, ADSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(ADSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to ADIO_VEH_MID(0x%04X), RC=0x%08X", ADIO_VEH_MID, Status);
        return Status;
    }

    Status = ADSIM_HWIF_Init();
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(ADSIM_HWIF_ERR_EID, CFE_EVS_ERROR, "Error initializing HWIF, RC=0x%08X", Status);
        return Status;
    }

    CFE_EVS_SendEvent(ADSIM_INIT_INF_EID, CFE_EVS_INFORMATION, "App initialized.");
    return CFE_SUCCESS;
}

void ADSIM_AppPipe(void) {
    CFE_SB_MsgId_t MsgId = CFE_SB_GetMsgId(ADSIM_AppData.MsgPtr);

    switch (MsgId) {
        case ADSIM_CMD_MID:
            ADSIM_ProcessGroundCommand();
            break;
        case ADSIM_SEND_HK_MID:
            ADSIM_ReportHousekeeping();
            break;
        case ADIO_VEH_MID:
            ADSIM_SendAnalogs();
            break;
        default:
            CFE_EVS_SendEvent(ADSIM_MSGID_ERR_EID, CFE_EVS_ERROR, "Received invalid MsgId 0x%04X", MsgId);
            ADSIM_AppData.HkPacket.error_count++;
            break;
    }
}

void ADSIM_SendAnalogs(void) {
    int32 Status;

    Status = ADSIM_WriteDeviceData((adio_veh_msg_t *)ADSIM_AppData.MsgPtr);

    if (Status == CFE_SUCCESS) {
        ADSIM_AppData.HkPacket.ad_write_count++;
    } else {
        CFE_EVS_SendEvent(ADSIM_DEVICE_ERR_EID, CFE_EVS_ERROR, "Error writing to AD device");
    }
}

void ADSIM_ProcessGroundCommand(void) {
    uint16 ExpectedLength = sizeof(ADSIM_NoArgsCmd_t);

    if (ADSIM_VerifyCmdLength(ADSIM_AppData.MsgPtr, ExpectedLength)) {
        uint16 CommandCode = CFE_SB_GetCmdCode(ADSIM_AppData.MsgPtr);

        switch (CommandCode) {
            case ADSIM_NOOP_CC:
                ADSIM_AppData.HkPacket.command_count++;
                CFE_EVS_SendEvent(ADSIM_NOOP_INF_EID, CFE_EVS_INFORMATION, "NOOP command");
                break;
            case ADSIM_RESETCTRS_CC:
                ADSIM_ResetCounters();
                break;
            default:
                ADSIM_AppData.HkPacket.error_count++;
                CFE_EVS_SendEvent(ADSIM_CC1_ERR_EID, CFE_EVS_ERROR, "Invalid command code %u", CommandCode);
                break;
        }
    }
}

void ADSIM_ReportHousekeeping(void) {
    CFE_SB_TimeStampMsg((CFE_SB_MsgPtr_t) &ADSIM_AppData.HkPacket);
    CFE_SB_SendMsg((CFE_SB_MsgPtr_t) &ADSIM_AppData.HkPacket);
}


void ADSIM_ResetCounters(void) {
    ADSIM_AppData.HkPacket.command_count = 0;
    ADSIM_AppData.HkPacket.error_count = 0;
    ADSIM_AppData.HkPacket.ad_write_count = 0;
}

boolean ADSIM_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength) {
    boolean result = TRUE;
    uint16  ActualLength = CFE_SB_GetTotalMsgLength(Msg);

    if (ExpectedLength != ActualLength) {
        CFE_SB_MsgId_t MessageId = CFE_SB_GetMsgId(Msg);
        uint16 CommandCode = CFE_SB_GetCmdCode(Msg);

        CFE_EVS_SendEvent(ADSIM_MSGLEN_ERR_EID, CFE_EVS_ERROR, "Invalid cmd length: MID = 0x%04X, CC = %02u, Exp Len = %u, Len = %u", MessageId, CommandCode, ExpectedLength, ActualLength);
        result = FALSE;
        ADSIM_AppData.HkPacket.error_count++;
    }
    return result;
}
