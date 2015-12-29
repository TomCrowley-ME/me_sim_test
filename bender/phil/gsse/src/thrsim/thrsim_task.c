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

#include "thrsim.h"

THRSIM_AppData_t THRSIM_AppData;

void THRSIM_TaskMain(void) {
    uint32 RunStatus = CFE_ES_APP_RUN;
    int32  Status = CFE_SUCCESS;

    CFE_ES_PerfLogEntry(THRSIM_MAIN_TASK_PERF_ID);

    Status = THRSIM_Init();
    if (Status != CFE_SUCCESS) {
        RunStatus = CFE_ES_APP_ERROR;
    }

    while (CFE_ES_RunLoop(&RunStatus) == TRUE) {
        CFE_ES_PerfLogExit(THRSIM_MAIN_TASK_PERF_ID);

        Status = CFE_SB_RcvMsg(&THRSIM_AppData.MsgPtr, THRSIM_AppData.CmdPipe, CFE_SB_PEND_FOREVER);

        CFE_ES_PerfLogEntry(THRSIM_MAIN_TASK_PERF_ID);

        if (Status == CFE_SUCCESS) {
            THRSIM_AppPipe();
        } else {
            CFE_EVS_SendEvent(THRSIM_PIPE_ERR_EID, CFE_EVS_ERROR, "SB pipe read error, THRSIM will exit.");
            RunStatus = CFE_ES_APP_ERROR;
        }
    }
}

int32 THRSIM_Init(void) {
    int32 Status = CFE_SUCCESS;

    CFE_ES_RegisterApp();

    /* Initialize app data */
    THRSIM_AppData.CmdPipe = 0;
    THRSIM_AppData.MsgPtr = NULL;

    /* Set up and register events */
    THRSIM_AppData.EventFilters[0].EventID = THRSIM_INIT_INF_EID;
    THRSIM_AppData.EventFilters[0].Mask    = CFE_EVS_NO_FILTER;
    THRSIM_AppData.EventFilters[1].EventID = THRSIM_NOOP_INF_EID;
    THRSIM_AppData.EventFilters[1].Mask    = CFE_EVS_NO_FILTER;
    THRSIM_AppData.EventFilters[2].EventID = THRSIM_CRCMDPIPE_ERR_EID;
    THRSIM_AppData.EventFilters[2].Mask    = CFE_EVS_NO_FILTER;
    THRSIM_AppData.EventFilters[3].EventID = THRSIM_SUBSCRIBE_ERR_EID;
    THRSIM_AppData.EventFilters[3].Mask    = CFE_EVS_NO_FILTER;
    THRSIM_AppData.EventFilters[4].EventID = THRSIM_MSGID_ERR_EID;
    THRSIM_AppData.EventFilters[4].Mask    = CFE_EVS_NO_FILTER;
    THRSIM_AppData.EventFilters[5].EventID = THRSIM_CC1_ERR_EID;
    THRSIM_AppData.EventFilters[5].Mask    = CFE_EVS_NO_FILTER;
    THRSIM_AppData.EventFilters[6].EventID = THRSIM_MSGLEN_ERR_EID;
    THRSIM_AppData.EventFilters[6].Mask    = CFE_EVS_NO_FILTER;
    THRSIM_AppData.EventFilters[7].EventID = THRSIM_PIPE_ERR_EID;
    THRSIM_AppData.EventFilters[7].Mask    = CFE_EVS_NO_FILTER;

    Status = CFE_EVS_Register(THRSIM_AppData.EventFilters, THRSIM_FILTERED_EVT_COUNT, CFE_EVS_BINARY_FILTER);
    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog("Error registering events, RC = 0x%08X\n", Status);
        return Status;
    }

    /* Initialize housekeeping */
    CFE_SB_InitMsg(&THRSIM_AppData.HkPacket, THRSIM_HK_TLM_MID, sizeof(THRSIM_HkPacket_t), TRUE);
    THRSIM_ResetCounters();

    /* Create a command pipe and subscribe to its messages */
    Status = CFE_SB_CreatePipe(&THRSIM_AppData.CmdPipe, THRSIM_PIPE_DEPTH, "THRSIM_CMD_PIPE");
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(THRSIM_CRCMDPIPE_ERR_EID, CFE_EVS_ERROR, "Can't create command pipe, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(THRSIM_CMD_MID, THRSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(THRSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to THRSIM_CMD_MID(0x%04X), RC=0x%08X", THRSIM_CMD_MID, Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(THRSIM_SEND_HK_MID, THRSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(THRSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to THRSIM_SEND_HK_MID(0x%04X), RC=0x%08X", THRSIM_SEND_HK_MID, Status);
        return Status;
    }
    CFE_SB_Subscribe(THRSIM_TICK_MID, THRSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(THRSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to tick message (0x%04X), RC=0x%08X", THRSIM_TICK_MID, Status);
        return Status;
    }

    /* Initialize the output message */
    CFE_SB_InitMsg(&THRSIM_AppData.thr_sim_msg, THR_SIM_MID,  sizeof(thr_sim_msg_t), TRUE);

    Status = THRSIM_HWIF_Init();
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(THRSIM_HWIF_ERR_EID, CFE_EVS_ERROR, "Error initializing HWIF, RC=0x%08X", Status);
        return Status;
    }

    CFE_EVS_SendEvent(THRSIM_INIT_INF_EID, CFE_EVS_INFORMATION, "THRSIM app initialized.");
    return CFE_SUCCESS;
}

void THRSIM_AppPipe(void) {
    CFE_SB_MsgId_t MsgId = CFE_SB_GetMsgId(THRSIM_AppData.MsgPtr);

    switch (MsgId) {
        case THRSIM_CMD_MID:
            THRSIM_ProcessGroundCommand();
            break;
        case THRSIM_SEND_HK_MID:
            THRSIM_ReportHousekeeping();
            break;
        case THRSIM_TICK_MID:
            THRSIM_GetValveStates();
            break;
        default:
            CFE_EVS_SendEvent(THRSIM_MSGID_ERR_EID, CFE_EVS_ERROR, "Received invalid MsgId 0x%04X", MsgId);
            THRSIM_AppData.HkPacket.error_count++;
            break;
    }
}

void THRSIM_GetValveStates(void) {
    /* Timestamp and send out our message */
    if (THRSIM_ReadDeviceData(&THRSIM_AppData.thr_sim_msg) != CFE_SUCCESS) {
        CFE_EVS_SendEvent(THRSIM_DEVICE_ERR_EID, CFE_EVS_ERROR, "Error reading from valves device");
        CFE_PSP_MemSet(CFE_SB_GetUserData((CFE_SB_MsgPtr_t)&THRSIM_AppData.thr_sim_msg),
                       0,
                       CFE_SB_GetUserDataLength((CFE_SB_MsgPtr_t)&THRSIM_AppData.thr_sim_msg));
    }
    CFE_SB_TimeStampMsg((CFE_SB_MsgPtr_t) &THRSIM_AppData.thr_sim_msg);
    CFE_SB_SendMsg((CFE_SB_MsgPtr_t) &THRSIM_AppData.thr_sim_msg);
}


void THRSIM_ProcessGroundCommand(void) {
    uint16 ExpectedLength = sizeof(THRSIM_NoArgsCmd_t);

    if (THRSIM_VerifyCmdLength(THRSIM_AppData.MsgPtr, ExpectedLength)) {
        uint16 CommandCode = CFE_SB_GetCmdCode(THRSIM_AppData.MsgPtr);

        switch (CommandCode) {
            case THRSIM_NOOP_CC:
                THRSIM_AppData.HkPacket.command_count++;
                CFE_EVS_SendEvent(THRSIM_NOOP_INF_EID, CFE_EVS_INFORMATION, "NOOP command");
                break;
            case THRSIM_RESETCTRS_CC:
                THRSIM_ResetCounters();
                break;
            default:
                THRSIM_AppData.HkPacket.error_count++;
                CFE_EVS_SendEvent(THRSIM_CC1_ERR_EID, CFE_EVS_ERROR, "Invalid command code %u", CommandCode);
                break;
        }
    }
}

void THRSIM_ReportHousekeeping(void) {
    CFE_SB_TimeStampMsg((CFE_SB_MsgPtr_t) &THRSIM_AppData.HkPacket);
    CFE_SB_SendMsg((CFE_SB_MsgPtr_t) &THRSIM_AppData.HkPacket);
}


void THRSIM_ResetCounters(void) {
    THRSIM_AppData.HkPacket.command_count = 0;
    THRSIM_AppData.HkPacket.error_count = 0;
}

boolean THRSIM_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength) {
    boolean result = TRUE;
    uint16  ActualLength = CFE_SB_GetTotalMsgLength(Msg);

    if (ExpectedLength != ActualLength) {
        CFE_SB_MsgId_t MessageId = CFE_SB_GetMsgId(Msg);
        uint16 CommandCode = CFE_SB_GetCmdCode(Msg);

        CFE_EVS_SendEvent(THRSIM_MSGLEN_ERR_EID, CFE_EVS_ERROR, "Invalid cmd length: MID = 0x%04X, CC = %02u, Exp Len = %u, Len = %u", MessageId, CommandCode, ExpectedLength, ActualLength);
        result = FALSE;
        THRSIM_AppData.HkPacket.error_count++;
    }
    return result;
}
