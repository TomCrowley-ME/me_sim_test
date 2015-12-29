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

#include "pru_icss.h"
#include "puppetmaster_bin.h"

#include "prusim.h"

PRUSIM_AppData_t PRUSIM_AppData;

void PRUSIM_TaskMain(void) {
    uint32 RunStatus = CFE_ES_APP_RUN;
    int32  Status = CFE_SUCCESS;

    CFE_ES_PerfLogEntry(PRUSIM_MAIN_TASK_PERF_ID);

    Status = PRUSIM_Init();
    if (Status != CFE_SUCCESS) {
        RunStatus = CFE_ES_APP_ERROR;
    }

    while (CFE_ES_RunLoop(&RunStatus) == TRUE) {
        CFE_ES_PerfLogExit(PRUSIM_MAIN_TASK_PERF_ID);

        Status = CFE_SB_RcvMsg(&PRUSIM_AppData.MsgPtr, PRUSIM_AppData.CmdPipe, CFE_SB_PEND_FOREVER);

        CFE_ES_PerfLogEntry(PRUSIM_MAIN_TASK_PERF_ID);

        if (Status == CFE_SUCCESS) {
            PRUSIM_AppPipe();
        } else {
            CFE_EVS_SendEvent(PRUSIM_PIPE_ERR_EID, CFE_EVS_ERROR, "SB pipe read error, PRUSIM will exit.");
            RunStatus = CFE_ES_APP_ERROR;
        }
    }
}

int32 PRUSIM_Init(void) {
    int32 Status = CFE_SUCCESS;

    CFE_ES_RegisterApp();

    /* Initialize app data */
    PRUSIM_AppData.CmdPipe = 0;
    PRUSIM_AppData.MsgPtr = NULL;

    /* Set up and register events */
    PRUSIM_AppData.EventFilters[0].EventID = PRUSIM_INIT_INF_EID;
    PRUSIM_AppData.EventFilters[0].Mask    = CFE_EVS_NO_FILTER;
    PRUSIM_AppData.EventFilters[1].EventID = PRUSIM_NOOP_INF_EID;
    PRUSIM_AppData.EventFilters[1].Mask    = CFE_EVS_NO_FILTER;
    PRUSIM_AppData.EventFilters[2].EventID = PRUSIM_CRCMDPIPE_ERR_EID;
    PRUSIM_AppData.EventFilters[2].Mask    = CFE_EVS_NO_FILTER;
    PRUSIM_AppData.EventFilters[3].EventID = PRUSIM_SUBSCRIBE_ERR_EID;
    PRUSIM_AppData.EventFilters[3].Mask    = CFE_EVS_NO_FILTER;
    PRUSIM_AppData.EventFilters[4].EventID = PRUSIM_MSGID_ERR_EID;
    PRUSIM_AppData.EventFilters[4].Mask    = CFE_EVS_NO_FILTER;
    PRUSIM_AppData.EventFilters[5].EventID = PRUSIM_CC1_ERR_EID;
    PRUSIM_AppData.EventFilters[5].Mask    = CFE_EVS_NO_FILTER;
    PRUSIM_AppData.EventFilters[6].EventID = PRUSIM_MSGLEN_ERR_EID;
    PRUSIM_AppData.EventFilters[6].Mask    = CFE_EVS_NO_FILTER;
    PRUSIM_AppData.EventFilters[7].EventID = PRUSIM_PIPE_ERR_EID;
    PRUSIM_AppData.EventFilters[7].Mask    = CFE_EVS_NO_FILTER;

    Status = CFE_EVS_Register(PRUSIM_AppData.EventFilters, PRUSIM_FILTERED_EVT_COUNT, CFE_EVS_BINARY_FILTER);
    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog("Error registering events, RC = 0x%08X\n", Status);
        return Status;
    }

    /* Initialize housekeeping */
    CFE_SB_InitMsg(&PRUSIM_AppData.HkPacket, PRUSIM_HK_TLM_MID, sizeof(PRUSIM_HkPacket_t), TRUE);
    PRUSIM_ResetCounters();

    /* Create a command pipe and subscribe to its messages */
    Status = CFE_SB_CreatePipe(&PRUSIM_AppData.CmdPipe, PRUSIM_PIPE_DEPTH, "PRUSIM_CMD_PIPE");
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(PRUSIM_CRCMDPIPE_ERR_EID, CFE_EVS_ERROR, "Can't create command pipe, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(PRUSIM_CMD_MID, PRUSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(PRUSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to PRUSIM_CMD_MID(0x%04X), RC=0x%08X", PRUSIM_CMD_MID, Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(PRUSIM_SEND_HK_MID, PRUSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(PRUSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to PRUSIM_SEND_HK_MID(0x%04X), RC=0x%08X", PRUSIM_SEND_HK_MID, Status);
        return Status;
    }

    Status = PRUSIM_LoadPRUFirmware();
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(PRUSIM_DEVICE_ERR_EID, CFE_EVS_ERROR, "Error loading PRU firmawre, RC=0x%08X", Status);
        return Status;
    }

    CFE_EVS_SendEvent(PRUSIM_INIT_INF_EID, CFE_EVS_INFORMATION, "PRU Initialized.");
    return CFE_SUCCESS;
}

int32 PRUSIM_LoadPRUFirmware(void) {
    if (pru_icss_pru_load(0, (char*)PRUcode, sizeof(PRUcode)) == OK) {
        /* Wait for applications to check in with the PRU */
        CFE_ES_WaitForStartupSync(5000);

        /* Start the firmware running */
        pru_icss_pru_enable(0);
    } else {
        return ERROR;
    }
    return CFE_SUCCESS;
}

void PRUSIM_AppPipe(void) {
    CFE_SB_MsgId_t MsgId = CFE_SB_GetMsgId(PRUSIM_AppData.MsgPtr);

    switch (MsgId) {
        case PRUSIM_CMD_MID:
            PRUSIM_ProcessGroundCommand();
            break;
        case PRUSIM_SEND_HK_MID:
            PRUSIM_ReportHousekeeping();
            break;
        default:
            CFE_EVS_SendEvent(PRUSIM_MSGID_ERR_EID, CFE_EVS_ERROR, "Received invalid MsgId 0x%04X", MsgId);
            PRUSIM_AppData.HkPacket.error_count++;
            break;
    }
}

void PRUSIM_ProcessGroundCommand(void) {
    uint16 ExpectedLength = sizeof(PRUSIM_NoArgsCmd_t);

    if (PRUSIM_VerifyCmdLength(PRUSIM_AppData.MsgPtr, ExpectedLength)) {
        uint16 CommandCode = CFE_SB_GetCmdCode(PRUSIM_AppData.MsgPtr);

        switch (CommandCode) {
            case PRUSIM_NOOP_CC:
                PRUSIM_AppData.HkPacket.command_count++;
                CFE_EVS_SendEvent(PRUSIM_NOOP_INF_EID, CFE_EVS_INFORMATION, "NOOP command");
                break;
            case PRUSIM_RESETCTRS_CC:
                PRUSIM_ResetCounters();
                break;
            default:
                PRUSIM_AppData.HkPacket.error_count++;
                CFE_EVS_SendEvent(PRUSIM_CC1_ERR_EID, CFE_EVS_ERROR, "Invalid command code %u", CommandCode);
                break;
        }
    }
}

void PRUSIM_ReportHousekeeping(void) {
    CFE_SB_TimeStampMsg((CFE_SB_MsgPtr_t) &PRUSIM_AppData.HkPacket);
    CFE_SB_SendMsg((CFE_SB_MsgPtr_t) &PRUSIM_AppData.HkPacket);
}


void PRUSIM_ResetCounters(void) {
    PRUSIM_AppData.HkPacket.command_count = 0;
    PRUSIM_AppData.HkPacket.error_count = 0;
}

boolean PRUSIM_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength) {
    boolean result = TRUE;
    uint16  ActualLength = CFE_SB_GetTotalMsgLength(Msg);

    if (ExpectedLength != ActualLength) {
        CFE_SB_MsgId_t MessageId = CFE_SB_GetMsgId(Msg);
        uint16 CommandCode = CFE_SB_GetCmdCode(Msg);

        CFE_EVS_SendEvent(PRUSIM_MSGLEN_ERR_EID, CFE_EVS_ERROR, "Invalid cmd length: MID = 0x%04X, CC = %02u, Exp Len = %u, Len = %u", MessageId, CommandCode, ExpectedLength, ActualLength);
        result = FALSE;
        PRUSIM_AppData.HkPacket.error_count++;
    }
    return result;
}
