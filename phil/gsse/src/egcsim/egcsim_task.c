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

#include "egcsim.h"

EGCSIM_AppData_t EGCSIM_AppData;

void EGCSIM_TaskMain(void) {
    uint32 RunStatus = CFE_ES_APP_RUN;
    int32  Status = CFE_SUCCESS;

    CFE_ES_PerfLogEntry(EGCSIM_MAIN_TASK_PERF_ID);

    Status = EGCSIM_Init();
    if (Status != CFE_SUCCESS) {
        RunStatus = CFE_ES_APP_ERROR;
    }

    while (CFE_ES_RunLoop(&RunStatus) == TRUE) {
        CFE_ES_PerfLogExit(EGCSIM_MAIN_TASK_PERF_ID);

        Status = CFE_SB_RcvMsg(&EGCSIM_AppData.MsgPtr, EGCSIM_AppData.CmdPipe, CFE_SB_PEND_FOREVER);

        CFE_ES_PerfLogEntry(EGCSIM_MAIN_TASK_PERF_ID);

        if (Status == CFE_SUCCESS) {
            EGCSIM_AppPipe();
        } else {
            CFE_EVS_SendEvent(EGCSIM_PIPE_ERR_EID, CFE_EVS_ERROR, "SB pipe read error, EGCSIM will exit.");
            RunStatus = CFE_ES_APP_ERROR;
        }
    }
}

int32 EGCSIM_Init(void) {
    int32 Status = CFE_SUCCESS;

    CFE_ES_RegisterApp();

    /* Initialize app data */
    EGCSIM_AppData.CmdPipe = 0;
    EGCSIM_AppData.MsgPtr = NULL;

    /* Set up and register events */
    EGCSIM_AppData.EventFilters[0].EventID = EGCSIM_INIT_INF_EID;
    EGCSIM_AppData.EventFilters[0].Mask    = CFE_EVS_NO_FILTER;
    EGCSIM_AppData.EventFilters[1].EventID = EGCSIM_NOOP_INF_EID;
    EGCSIM_AppData.EventFilters[1].Mask    = CFE_EVS_NO_FILTER;
    EGCSIM_AppData.EventFilters[2].EventID = EGCSIM_CRCMDPIPE_ERR_EID;
    EGCSIM_AppData.EventFilters[2].Mask    = CFE_EVS_NO_FILTER;
    EGCSIM_AppData.EventFilters[3].EventID = EGCSIM_SUBSCRIBE_ERR_EID;
    EGCSIM_AppData.EventFilters[3].Mask    = CFE_EVS_NO_FILTER;
    EGCSIM_AppData.EventFilters[4].EventID = EGCSIM_MSGID_ERR_EID;
    EGCSIM_AppData.EventFilters[4].Mask    = CFE_EVS_NO_FILTER;
    EGCSIM_AppData.EventFilters[5].EventID = EGCSIM_CC1_ERR_EID;
    EGCSIM_AppData.EventFilters[5].Mask    = CFE_EVS_NO_FILTER;
    EGCSIM_AppData.EventFilters[6].EventID = EGCSIM_MSGLEN_ERR_EID;
    EGCSIM_AppData.EventFilters[6].Mask    = CFE_EVS_NO_FILTER;
    EGCSIM_AppData.EventFilters[7].EventID = EGCSIM_PIPE_ERR_EID;
    EGCSIM_AppData.EventFilters[7].Mask    = CFE_EVS_NO_FILTER;

    Status = CFE_EVS_Register(EGCSIM_AppData.EventFilters, EGCSIM_FILTERED_EVT_COUNT, CFE_EVS_BINARY_FILTER);
    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog("Error registering events, RC = 0x%08X\n", Status);
        return Status;
    }

    /* Initialize housekeeping */
    CFE_SB_InitMsg(&EGCSIM_AppData.HkPacket, EGCSIM_HK_TLM_MID, sizeof(EGCSIM_HkPacket_t), TRUE);
    EGCSIM_ResetCounters();

    /* Create a command pipe and subscribe to its messages */
    Status = CFE_SB_CreatePipe(&EGCSIM_AppData.CmdPipe, EGCSIM_PIPE_DEPTH, "EGCSIM_CMD_PIPE");
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(EGCSIM_CRCMDPIPE_ERR_EID, CFE_EVS_ERROR, "Can't create command pipe, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(EGCSIM_CMD_MID, EGCSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(EGCSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to EGCSIM_CMD_MID(0x%04X), RC=0x%08X", EGCSIM_CMD_MID, Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(EGCSIM_SEND_HK_MID, EGCSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(EGCSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to EGCSIM_SEND_HK_MID(0x%04X), RC=0x%08X", EGCSIM_SEND_HK_MID, Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(EGCSIM_TICK_MID, EGCSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(EGCSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to tick message(0x%04X), RC=0x%08X", EGCSIM_TICK_MID, Status);
        return Status;
    }

    /* Init EGC_VEH_MSG for sending to the sim */
    CFE_SB_InitMsg(&EGCSIM_AppData.egc_veh_msg, EGC_VEH_MID, sizeof(egc_veh_msg_t), TRUE);

    Status = EGCSIM_HWIF_Init();
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(EGCSIM_HWIF_ERR_EID, CFE_EVS_ERROR, "Error initializing HWIF, RC=0x%08X", Status);
        return Status;
    }

    CFE_EVS_SendEvent(EGCSIM_INIT_INF_EID, CFE_EVS_INFORMATION, "App initialized.");
    return CFE_SUCCESS;
}

void EGCSIM_AppPipe(void) {
    CFE_SB_MsgId_t MsgId = CFE_SB_GetMsgId(EGCSIM_AppData.MsgPtr);

    switch (MsgId) {
        case EGCSIM_CMD_MID:
            EGCSIM_ProcessGroundCommand();
            break;
        case EGCSIM_SEND_HK_MID:
            EGCSIM_ReportHousekeeping();
            break;
        case EGCSIM_TICK_MID:
            EGCSIM_SendThrottle();
            break;
        default:
            CFE_EVS_SendEvent(EGCSIM_MSGID_ERR_EID, CFE_EVS_ERROR, "Received invalid MsgId 0x%04X", MsgId);
            EGCSIM_AppData.HkPacket.error_count++;
            break;
    }
}

void EGCSIM_SendThrottle(void) {
    int32  Status;
    uint16 Throttle;

    Status = EGCSIM_ReadDeviceData(&Throttle);

    if (Status == CFE_SUCCESS) {
        EGCSIM_AppData.egc_veh_msg.throttle = Throttle;

        CFE_SB_TimeStampMsg((CFE_SB_MsgPtr_t) &EGCSIM_AppData.egc_veh_msg);
        CFE_SB_SendMsg((CFE_SB_MsgPtr_t) &EGCSIM_AppData.egc_veh_msg);

        EGCSIM_AppData.HkPacket.egc_read_count++;
    } else {
        CFE_EVS_SendEvent(EGCSIM_DEVICE_ERR_EID, CFE_EVS_ERROR, "Error reading data from EGC device");
    }
}

void EGCSIM_ProcessGroundCommand(void) {
    uint16 ExpectedLength = sizeof(EGCSIM_NoArgsCmd_t);

    if (EGCSIM_VerifyCmdLength(EGCSIM_AppData.MsgPtr, ExpectedLength)) {
        uint16 CommandCode = CFE_SB_GetCmdCode(EGCSIM_AppData.MsgPtr);

        switch (CommandCode) {
            case EGCSIM_NOOP_CC:
                EGCSIM_AppData.HkPacket.command_count++;
                CFE_EVS_SendEvent(EGCSIM_NOOP_INF_EID, CFE_EVS_INFORMATION, "NOOP command");
                break;
            case EGCSIM_RESETCTRS_CC:
                EGCSIM_ResetCounters();
                break;
            default:
                EGCSIM_AppData.HkPacket.error_count++;
                CFE_EVS_SendEvent(EGCSIM_CC1_ERR_EID, CFE_EVS_ERROR, "Invalid command code %u", CommandCode);
                break;
        }
    }
}

void EGCSIM_ReportHousekeeping(void) {
    CFE_SB_TimeStampMsg((CFE_SB_MsgPtr_t) &EGCSIM_AppData.HkPacket);
    CFE_SB_SendMsg((CFE_SB_MsgPtr_t) &EGCSIM_AppData.HkPacket);
}


void EGCSIM_ResetCounters(void) {
    EGCSIM_AppData.HkPacket.command_count = 0;
    EGCSIM_AppData.HkPacket.error_count = 0;
    EGCSIM_AppData.HkPacket.egc_read_count = 0;
}

boolean EGCSIM_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength) {
    boolean result = TRUE;
    uint16  ActualLength = CFE_SB_GetTotalMsgLength(Msg);

    if (ExpectedLength != ActualLength) {
        CFE_SB_MsgId_t MessageId = CFE_SB_GetMsgId(Msg);
        uint16 CommandCode = CFE_SB_GetCmdCode(Msg);

        CFE_EVS_SendEvent(EGCSIM_MSGLEN_ERR_EID, CFE_EVS_ERROR, "Invalid cmd length: MID = 0x%04X, CC = %02u, Exp Len = %u, Len = %u", MessageId, CommandCode, ExpectedLength, ActualLength);
        result = FALSE;
        EGCSIM_AppData.HkPacket.error_count++;
    }
    return result;
}
