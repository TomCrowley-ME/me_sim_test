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

#include "imusim.h"

IMUSIM_AppData_t IMUSIM_AppData;

void IMUSIM_TaskMain(void) {
    uint32 RunStatus = CFE_ES_APP_RUN;
    int32  Status = CFE_SUCCESS;

    CFE_ES_PerfLogEntry(IMUSIM_MAIN_TASK_PERF_ID);

    Status = IMUSIM_Init();
    if (Status != CFE_SUCCESS) {
        RunStatus = CFE_ES_APP_ERROR;
    }

    while (CFE_ES_RunLoop(&RunStatus) == TRUE) {
        CFE_ES_PerfLogExit(IMUSIM_MAIN_TASK_PERF_ID);

        Status = CFE_SB_RcvMsg(&IMUSIM_AppData.MsgPtr, IMUSIM_AppData.CmdPipe, CFE_SB_PEND_FOREVER);

        CFE_ES_PerfLogEntry(IMUSIM_MAIN_TASK_PERF_ID);

        if (Status == CFE_SUCCESS) {
            IMUSIM_AppPipe();
        } else {
            CFE_EVS_SendEvent(IMUSIM_PIPE_ERR_EID, CFE_EVS_ERROR, "SB pipe read error, IMUSIM will exit.");
            RunStatus = CFE_ES_APP_ERROR;
        }
    }
}

int32 IMUSIM_Init(void) {
    int32 Status = CFE_SUCCESS;

    CFE_ES_RegisterApp();

    /* Initialize app data */
    IMUSIM_AppData.CmdPipe = 0;
    IMUSIM_AppData.MsgPtr = NULL;

    /* Set up and register events */
    IMUSIM_AppData.EventFilters[0].EventID = IMUSIM_INIT_INF_EID;
    IMUSIM_AppData.EventFilters[0].Mask    = CFE_EVS_NO_FILTER;
    IMUSIM_AppData.EventFilters[1].EventID = IMUSIM_NOOP_INF_EID;
    IMUSIM_AppData.EventFilters[1].Mask    = CFE_EVS_NO_FILTER;
    IMUSIM_AppData.EventFilters[2].EventID = IMUSIM_CRCMDPIPE_ERR_EID;
    IMUSIM_AppData.EventFilters[2].Mask    = CFE_EVS_NO_FILTER;
    IMUSIM_AppData.EventFilters[3].EventID = IMUSIM_SUBSCRIBE_ERR_EID;
    IMUSIM_AppData.EventFilters[3].Mask    = CFE_EVS_NO_FILTER;
    IMUSIM_AppData.EventFilters[4].EventID = IMUSIM_MSGID_ERR_EID;
    IMUSIM_AppData.EventFilters[4].Mask    = CFE_EVS_NO_FILTER;
    IMUSIM_AppData.EventFilters[5].EventID = IMUSIM_CC1_ERR_EID;
    IMUSIM_AppData.EventFilters[5].Mask    = CFE_EVS_NO_FILTER;
    IMUSIM_AppData.EventFilters[6].EventID = IMUSIM_MSGLEN_ERR_EID;
    IMUSIM_AppData.EventFilters[6].Mask    = CFE_EVS_NO_FILTER;
    IMUSIM_AppData.EventFilters[7].EventID = IMUSIM_PIPE_ERR_EID;
    IMUSIM_AppData.EventFilters[7].Mask    = CFE_EVS_NO_FILTER;

    Status = CFE_EVS_Register(IMUSIM_AppData.EventFilters, IMUSIM_FILTERED_EVT_COUNT, CFE_EVS_BINARY_FILTER);
    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog("Error registering events, RC = 0x%08X\n", Status);
        return Status;
    }

    /* Initialize housekeeping */
    CFE_SB_InitMsg(&IMUSIM_AppData.HkPacket, IMUSIM_HK_TLM_MID, sizeof(IMUSIM_HkPacket_t), TRUE);
    IMUSIM_ResetCounters();

    /* Create a command pipe and subscribe to its messages */
    Status = CFE_SB_CreatePipe(&IMUSIM_AppData.CmdPipe, IMUSIM_PIPE_DEPTH, "IMUSIM_CMD_PIPE");
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(IMUSIM_CRCMDPIPE_ERR_EID, CFE_EVS_ERROR, "Can't create command pipe, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(IMUSIM_CMD_MID, IMUSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(IMUSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to IMUSIM_CMD_MID(0x%04X), RC=0x%08X", IMUSIM_CMD_MID, Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(IMUSIM_SEND_HK_MID, IMUSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(IMUSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to IMUSIM_SEND_HK_MID(0x%04X), RC=0x%08X", IMUSIM_SEND_HK_MID, Status);
        return Status;
    }
    CFE_SB_Subscribe(IMU_VEH_MID, IMUSIM_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(IMUSIM_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to IMU_VEH_MID (0x%04X), RC=0x%08X", IMU_VEH_MID, Status);
        return Status;
    }

    Status = IMUSIM_HWIF_Init();
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(IMUSIM_HWIF_ERR_EID, CFE_EVS_ERROR, "Error initializing HWIF, RC=0x%08X", Status);
        return Status;
    }

    CFE_EVS_SendEvent(IMUSIM_INIT_INF_EID, CFE_EVS_INFORMATION, "App initialized.");
    return CFE_SUCCESS;
}

void IMUSIM_AppPipe(void) {
    CFE_SB_MsgId_t MsgId = CFE_SB_GetMsgId(IMUSIM_AppData.MsgPtr);

    switch (MsgId) {
        case IMUSIM_CMD_MID:
            IMUSIM_ProcessGroundCommand();
            break;
        case IMUSIM_SEND_HK_MID:
            IMUSIM_ReportHousekeeping();
            break;
        case IMU_VEH_MID:
            IMUSIM_SendDeviceReadings();
            break;
        default:
            CFE_EVS_SendEvent(IMUSIM_MSGID_ERR_EID, CFE_EVS_ERROR, "Received invalid MsgId 0x%04X", MsgId);
            IMUSIM_AppData.HkPacket.error_count++;
            break;
    }
}

void IMUSIM_SendDeviceReadings(void) {
    int32 Status;

    Status = IMUSIM_WriteDeviceData((imu_veh_msg_t *)IMUSIM_AppData.MsgPtr);
    if (Status == CFE_SUCCESS) {
        IMUSIM_AppData.HkPacket.imu_write_count++;
    } else {
        CFE_EVS_SendEvent(IMUSIM_DEVICE_ERR_EID, CFE_EVS_ERROR, "Error writing to IMU device");
    }
}

void IMUSIM_ProcessGroundCommand(void) {
    uint16 ExpectedLength = sizeof(IMUSIM_NoArgsCmd_t);

    if (IMUSIM_VerifyCmdLength(IMUSIM_AppData.MsgPtr, ExpectedLength)) {
        uint16 CommandCode = CFE_SB_GetCmdCode(IMUSIM_AppData.MsgPtr);

        switch (CommandCode) {
            case IMUSIM_NOOP_CC:
                IMUSIM_AppData.HkPacket.command_count++;
                CFE_EVS_SendEvent(IMUSIM_NOOP_INF_EID, CFE_EVS_INFORMATION, "NOOP command");
                break;
            case IMUSIM_RESETCTRS_CC:
                IMUSIM_ResetCounters();
                break;
            default:
                IMUSIM_AppData.HkPacket.error_count++;
                CFE_EVS_SendEvent(IMUSIM_CC1_ERR_EID, CFE_EVS_ERROR, "Invalid command code %u", CommandCode);
                break;
        }
    }
}

void IMUSIM_ReportHousekeeping(void) {
    CFE_SB_TimeStampMsg((CFE_SB_MsgPtr_t) &IMUSIM_AppData.HkPacket);
    CFE_SB_SendMsg((CFE_SB_MsgPtr_t) &IMUSIM_AppData.HkPacket);
}


void IMUSIM_ResetCounters(void) {
    IMUSIM_AppData.HkPacket.command_count = 0;
    IMUSIM_AppData.HkPacket.error_count = 0;
    IMUSIM_AppData.HkPacket.imu_write_count = 0;
}

boolean IMUSIM_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength) {
    boolean result = TRUE;
    uint16  ActualLength = CFE_SB_GetTotalMsgLength(Msg);

    if (ExpectedLength != ActualLength) {
        CFE_SB_MsgId_t MessageId = CFE_SB_GetMsgId(Msg);
        uint16 CommandCode = CFE_SB_GetCmdCode(Msg);

        CFE_EVS_SendEvent(IMUSIM_MSGLEN_ERR_EID, CFE_EVS_ERROR, "Invalid cmd length: MID = 0x%04X, CC = %02u, Exp Len = %u, Len = %u", MessageId, CommandCode, ExpectedLength, ActualLength);
        result = FALSE;
        IMUSIM_AppData.HkPacket.error_count++;
    }
    return result;
}
