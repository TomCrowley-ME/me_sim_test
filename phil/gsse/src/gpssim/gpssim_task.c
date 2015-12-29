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

#include "gpssim.h"

GPSSIM_AppData_t GPSSIM_AppData;

void GPSSIM_TaskMain(void) {
    uint32 RunStatus = CFE_ES_APP_RUN;
    int32  Status = CFE_SUCCESS;

    CFE_ES_PerfLogEntry(GPSSIM_MAIN_TASK_PERF_ID);

    Status = GPSSIM_Init();
    if (Status != CFE_SUCCESS) {
        RunStatus = CFE_ES_APP_ERROR;
    }

    while (CFE_ES_RunLoop(&RunStatus) == TRUE) {
        CFE_ES_PerfLogExit(GPSSIM_MAIN_TASK_PERF_ID);

        Status = CFE_SB_RcvMsg(&GPSSIM_AppData.MsgPtr, GPSSIM_AppData.CmdPipe, CFE_SB_PEND_FOREVER);

        CFE_ES_PerfLogEntry(GPSSIM_MAIN_TASK_PERF_ID);

        if (Status == CFE_SUCCESS) {
            GPSSIM_AppPipe();
        } else {
            CFE_EVS_SendEvent(GPSSIM_PIPE_ERR_EID, CFE_EVS_ERROR, "SB pipe read error, GPSSIM will exit.");
            RunStatus = CFE_ES_APP_ERROR;
        }
    }
}

int32 GPSSIM_Init(void) {
    int32 Status = CFE_SUCCESS;

    CFE_ES_RegisterApp();

    /* Initialize app data */
    GPSSIM_AppData.CmdPipe = 0;
    GPSSIM_AppData.MsgPtr = NULL;

    /* Set up and register events */
    GPSSIM_AppData.EventFilters[0].EventID = GPSSIM_INIT_INF_EID;
    GPSSIM_AppData.EventFilters[0].Mask    = CFE_EVS_NO_FILTER;
    GPSSIM_AppData.EventFilters[1].EventID = GPSSIM_NOOP_INF_EID;
    GPSSIM_AppData.EventFilters[1].Mask    = CFE_EVS_NO_FILTER;
    GPSSIM_AppData.EventFilters[2].EventID = GPSSIM_CRCMDPIPE_ERR_EID;
    GPSSIM_AppData.EventFilters[2].Mask    = CFE_EVS_NO_FILTER;
    GPSSIM_AppData.EventFilters[3].EventID = GPSSIM_SUBSCRIBE_ERR_EID;
    GPSSIM_AppData.EventFilters[3].Mask    = CFE_EVS_NO_FILTER;
    GPSSIM_AppData.EventFilters[4].EventID = GPSSIM_MSGID_ERR_EID;
    GPSSIM_AppData.EventFilters[4].Mask    = CFE_EVS_NO_FILTER;
    GPSSIM_AppData.EventFilters[5].EventID = GPSSIM_CC1_ERR_EID;
    GPSSIM_AppData.EventFilters[5].Mask    = CFE_EVS_NO_FILTER;
    GPSSIM_AppData.EventFilters[6].EventID = GPSSIM_MSGLEN_ERR_EID;
    GPSSIM_AppData.EventFilters[6].Mask    = CFE_EVS_NO_FILTER;
    GPSSIM_AppData.EventFilters[7].EventID = GPSSIM_PIPE_ERR_EID;
    GPSSIM_AppData.EventFilters[7].Mask    = CFE_EVS_NO_FILTER;

    Status = CFE_EVS_Register(GPSSIM_AppData.EventFilters, GPSSIM_FILTERED_EVT_COUNT, CFE_EVS_BINARY_FILTER);
    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog("Error registering events, RC = 0x%08X\n", Status);
        return Status;
    }

    /* Initialize housekeeping */
    CFE_SB_InitMsg(&GPSSIM_AppData.HkPacket, GPSSIM_HK_TLM_MID, sizeof(GPSSIM_HkPacket_t), TRUE);
    GPSSIM_ResetCounters();

    /* Create a command pipe and subscribe to its messages */
    Status = CFE_SB_CreatePipe(&GPSSIM_AppData.CmdPipe, GPSSIM_PIPE_DEPTH, "GPSSIM_CMD_PIPE");
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(GPSSIM_CRCMDPIPE_ERR_EID, CFE_EVS_ERROR, "Can't create command pipe, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(GPSSIM_CMD_MID, GPSSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(GPSSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to GPSSIM_CMD_MID(0x%04X), RC=0x%08X", GPSSIM_CMD_MID, Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(GPSSIM_SEND_HK_MID, GPSSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(GPSSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to GPSSIM_SEND_HK_MID(0x%04X), RC=0x%08X", GPSSIM_SEND_HK_MID, Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(GPS_VEH_MID, GPSSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(GPSSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to GPS_VEH_MID(0x%04X), RC=0x%08X", GPS_VEH_MID, Status);
        return Status;
    }

    Status = GPSSIM_HWIF_Init();
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(GPSSIM_HWIF_ERR_EID, CFE_EVS_ERROR, "Error initializing HWIF, RC=0x%08X", Status);
        return Status;
    }

    CFE_EVS_SendEvent(GPSSIM_INIT_INF_EID, CFE_EVS_INFORMATION, "App initialized.");
    return CFE_SUCCESS;
}

void GPSSIM_AppPipe(void) {
    CFE_SB_MsgId_t MsgId = CFE_SB_GetMsgId(GPSSIM_AppData.MsgPtr);

    switch (MsgId) {
        case GPSSIM_CMD_MID:
            GPSSIM_ProcessGroundCommand();
            break;
        case GPSSIM_SEND_HK_MID:
            GPSSIM_ReportHousekeeping();
            break;
        case GPS_VEH_MID:
            GPSSIM_SendPosition();
            break;
        default:
            CFE_EVS_SendEvent(GPSSIM_MSGID_ERR_EID, CFE_EVS_ERROR, "Received invalid MsgId 0x%04X", MsgId);
            GPSSIM_AppData.HkPacket.error_count++;
            break;
    }
}

void GPSSIM_SendPosition(void) {
    int32 Status;

    Status = GPSSIM_WriteDeviceData((gps_veh_msg_t *)GPSSIM_AppData.MsgPtr);

    if (Status == CFE_SUCCESS) {
        GPSSIM_AppData.HkPacket.gps_write_count++;
    } else {
        CFE_EVS_SendEvent(GPSSIM_DEVICE_ERR_EID, CFE_EVS_ERROR, "Error writing to GPS device");
    }
}

void GPSSIM_ProcessGroundCommand(void) {
    uint16 ExpectedLength = sizeof(GPSSIM_NoArgsCmd_t);

    if (GPSSIM_VerifyCmdLength(GPSSIM_AppData.MsgPtr, ExpectedLength)) {
        uint16 CommandCode = CFE_SB_GetCmdCode(GPSSIM_AppData.MsgPtr);

        switch (CommandCode) {
            case GPSSIM_NOOP_CC:
                GPSSIM_AppData.HkPacket.command_count++;
                CFE_EVS_SendEvent(GPSSIM_NOOP_INF_EID, CFE_EVS_INFORMATION, "NOOP command");
                break;
            case GPSSIM_RESETCTRS_CC:
                GPSSIM_ResetCounters();
                break;
            default:
                GPSSIM_AppData.HkPacket.error_count++;
                CFE_EVS_SendEvent(GPSSIM_CC1_ERR_EID, CFE_EVS_ERROR, "Invalid command code %u", CommandCode);
                break;
        }
    }
}

void GPSSIM_ReportHousekeeping(void) {
    CFE_SB_TimeStampMsg((CFE_SB_MsgPtr_t) &GPSSIM_AppData.HkPacket);
    CFE_SB_SendMsg((CFE_SB_MsgPtr_t) &GPSSIM_AppData.HkPacket);
}


void GPSSIM_ResetCounters(void) {
    GPSSIM_AppData.HkPacket.command_count = 0;
    GPSSIM_AppData.HkPacket.error_count = 0;
    GPSSIM_AppData.HkPacket.gps_write_count = 0;
}

boolean GPSSIM_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength) {
    boolean result = TRUE;
    uint16  ActualLength = CFE_SB_GetTotalMsgLength(Msg);

    if (ExpectedLength != ActualLength) {
        CFE_SB_MsgId_t MessageId = CFE_SB_GetMsgId(Msg);
        uint16 CommandCode = CFE_SB_GetCmdCode(Msg);

        CFE_EVS_SendEvent(GPSSIM_MSGLEN_ERR_EID, CFE_EVS_ERROR, "Invalid cmd length: MID = 0x%04X, CC = %02u, Exp Len = %u, Len = %u", MessageId, CommandCode, ExpectedLength, ActualLength);
        result = FALSE;
        GPSSIM_AppData.HkPacket.error_count++;
    }
    return result;
}
