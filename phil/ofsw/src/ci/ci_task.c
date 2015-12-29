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
#include "app_perfids.h"

#include "ci_task.h"

#include "selectLib.h"

CI_AppData_t CI_AppData;

void CI_TaskMain(void) {
    uint32 RunStatus = CFE_ES_APP_RUN;
    int32  Status = CFE_SUCCESS;

    int max_fd;
    fd_set readfds;
    OS_FDTableEntry fd_prop;
    int rcvrOsFd;

    CFE_ES_PerfLogEntry(CI_MAIN_TASK_PERF_ID);

    Status = CI_Init();
    if (Status != CFE_SUCCESS) {
        RunStatus = CFE_ES_APP_ERROR;
    }

    OS_FDGetInfo(CI_AppData.RcvrDevFd, &fd_prop);
    rcvrOsFd = fd_prop.OSfd;

    max_fd = max(rcvrOsFd, CI_AppData.CmdPipeFd);
    max_fd++;

    while (CFE_ES_RunLoop(&RunStatus) == TRUE) {
        FD_ZERO(&readfds);

        FD_SET(CI_AppData.CmdPipeFd, &readfds);
        FD_SET(rcvrOsFd, &readfds);

        CFE_ES_PerfLogExit(CI_MAIN_TASK_PERF_ID);
        select(max_fd, &readfds, NULL, NULL, NULL);
        CFE_ES_PerfLogEntry(CI_MAIN_TASK_PERF_ID);

        if (FD_ISSET(CI_AppData.CmdPipeFd, &readfds)) {
            Status = CFE_SB_RcvMsg(&CI_AppData.MsgPtr, CI_AppData.CmdPipe, CFE_SB_POLL);
            if (Status == CFE_SUCCESS) {
                CI_AppPipe();
            } else {
                CFE_EVS_SendEvent(CI_PIPE_ERR_EID, CFE_EVS_ERROR, "CI: Error reading from command pipe, RC=0x%08X", Status);
            }
        }
        if (FD_ISSET(rcvrOsFd, &readfds)) {
            CI_ReadUplinkFrame();
        }
    }

    CFE_ES_PerfLogExit(CI_MAIN_TASK_PERF_ID);

    CFE_ES_ExitApp(RunStatus);
}

void CI_DeleteCallback(void) {
    if (CI_AppData.HkPacket.DeviceConnected) {
        OS_close(CI_AppData.RcvrDevFd);
    }
}

int32 CI_Init(void) {
    int32 Status = CFE_SUCCESS;
    uint32 cmdQueueId = 0;

    CFE_ES_RegisterApp();

    /* Initialize app data */
    CI_AppData.CmdPipe = 0;
    CI_AppData.RcvrDevFd = 0;
    CI_AppData.CmdPipeFd = 0;
    CI_AppData.MsgPtr = NULL;
    
    /* Set up and register events */
    CI_AppData.EventFilters[0].EventID = CI_INIT_INF_EID;
    CI_AppData.EventFilters[0].Mask    = CFE_EVS_NO_FILTER;
    CI_AppData.EventFilters[1].EventID = CI_NOOP_INF_EID;
    CI_AppData.EventFilters[1].Mask    = CFE_EVS_NO_FILTER;
    CI_AppData.EventFilters[2].EventID = CI_CRCMDPIPE_ERR_EID;
    CI_AppData.EventFilters[2].Mask    = CFE_EVS_NO_FILTER;
    CI_AppData.EventFilters[3].EventID = CI_SUBSCRIBE_ERR_EID;
    CI_AppData.EventFilters[3].Mask    = CFE_EVS_NO_FILTER;
    CI_AppData.EventFilters[4].EventID = CI_DEVICE_ERR_EID;
    CI_AppData.EventFilters[4].Mask    = CFE_EVS_NO_FILTER;
    CI_AppData.EventFilters[5].EventID = CI_MSGID_ERR_EID;
    CI_AppData.EventFilters[5].Mask    = CFE_EVS_NO_FILTER;
    CI_AppData.EventFilters[6].EventID = CI_CC1_ERR_EID;
    CI_AppData.EventFilters[6].Mask    = CFE_EVS_NO_FILTER;

    Status = CFE_EVS_Register(CI_AppData.EventFilters, CI_FILTERED_EVT_COUNT, CFE_EVS_BINARY_FILTER);
    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog("CI: Error registering events, RC=0x%08X\n", Status);
        return Status;
    }

    /* Initialize housekeeping */
    CFE_SB_InitMsg(&CI_AppData.HkPacket, CI_HK_TLM_MID, sizeof(CI_HkPacket_t), TRUE);
    CI_ResetCounters();
    CI_AppData.HkPacket.DeviceConnected = FALSE;
    CI_AppData.HkPacket.RejectionReason = 0;
    CI_AppData.HkPacket.LastFrameTime = 0;

    /* Install task delete handler */
    OS_TaskInstallDeleteHandler((void*)&CI_DeleteCallback);

    /* Create command pipe and subscribe to its messages */
    Status = CFE_SB_CreatePipe(&CI_AppData.CmdPipe, CI_CMD_PIPE_DEPTH, "CI_CMD_PIPE");
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(CI_CRCMDPIPE_ERR_EID, CFE_EVS_ERROR, "CI: Can't create command pipe, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(CI_CMD_MID, CI_AppData.CmdPipe);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(CI_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "CI: Error subscribing to CI_CMD_MID(0x%04X), RC=0x%08X", CI_CMD_MID, Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(CI_SEND_HK_MID, CI_AppData.CmdPipe);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(CI_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "CI: Error subscribing to CI_SEND_HK_MID(0x%04X), RC=0x%08X", CI_SEND_HK_MID, Status);
        return Status;
    }
    Status = OS_QueueGetIdByName(&cmdQueueId, "CI_CMD_PIPE");
    Status = OS_QueueFdGet(cmdQueueId, &CI_AppData.CmdPipeFd);

    /* Open up the receiver device */
    CI_AppData.RcvrDevFd = OS_open("/rcvr", OS_READ_ONLY, 0);
    if (CI_AppData.RcvrDevFd < 0) {
        CFE_EVS_SendEvent(CI_DEVICE_ERR_EID, CFE_EVS_ERROR, "CI: Error opening command receiver device, RC=0x%08X", CI_AppData.RcvrDevFd);
        return CI_AppData.RcvrDevFd;
    } else {
        CI_AppData.HkPacket.DeviceConnected = TRUE;
    }

    CFE_EVS_SendEvent(CI_INIT_INF_EID, CFE_EVS_INFORMATION, "CI: App initialized");
    return CFE_SUCCESS;
}

void CI_AppPipe(void) {
    CFE_SB_MsgId_t MsgId;

    MsgId = CFE_SB_GetMsgId(CI_AppData.MsgPtr);
    switch (MsgId) {
        case CI_CMD_MID:
            CI_ProcessGroundCommand();
            break;
        case CI_SEND_HK_MID:
            CI_ReportHousekeeping();
            break;
        default:
            CFE_EVS_SendEvent(CI_MSGID_ERR_EID, CFE_EVS_ERROR, "CI: invalid command packet, MID=0x%04X", MsgId);
            break;
    }
}

void CI_ProcessGroundCommand(void) {
    uint16 CommandCode;

    CommandCode = CFE_SB_GetCmdCode(CI_AppData.MsgPtr);
    switch (CommandCode) {
        case CI_NOOP_CC:
            CFE_EVS_SendEvent(CI_NOOP_INF_EID, CFE_EVS_INFORMATION, "CI: Noop command");
            CI_AppData.HkPacket.CommandCount++;
            break;

        case CI_RESETCTRS_CC:
            CI_ResetCounters();
            break;

        default:
            CFE_EVS_SendEvent(CI_CC1_ERR_EID, CFE_EVS_ERROR, "CI: invalid command code, MID=0x%04X, CC=%02u", CFE_SB_GetMsgId(CI_AppData.MsgPtr), CommandCode);
            break;
    }
}

void CI_ReportHousekeeping(void) {
    CFE_SB_TimeStampMsg((CFE_SB_MsgPtr_t)&CI_AppData.HkPacket);
    CFE_SB_SendMsg((CFE_SB_MsgPtr_t)&CI_AppData.HkPacket);
}

void CI_ResetCounters(void) {
    CI_AppData.HkPacket.CommandCount = 0;
    CI_AppData.HkPacket.ErrorCount = 0;
    CI_AppData.HkPacket.IngestFrames = 0;
    CI_AppData.HkPacket.IngestErrors = 0;
    CI_AppData.HkPacket.BytesIngested = 0;
}

void CI_ReadUplinkFrame(void) {
    int32 BytesRead = 0;
    CFE_SB_MsgPtr_t PktPointer = NULL;

    BytesRead = OS_read(CI_AppData.RcvrDevFd, CI_AppData.FrameBufferRaw, CI_MAX_INGEST);

    if (BytesRead > 0) {
        uint32 i = 0;
        uint32 j = 0;

        /* Strip BCH bytes */
        for (i = 0; i < BytesRead; i++) {
            if (i % 7 != 0) {
                CI_AppData.FrameBuffer[j] = CI_AppData.FrameBuffer[i];
                j++;
            }
        }

        /* No error checking or anything, just go! */
        PktPointer = (CFE_SB_MsgPtr_t)&CI_AppData.FrameBuffer[5];

        CFE_SB_SendMsg(PktPointer);
    } else {
        CFE_EVS_SendEvent(CI_DEVICE_ERR_EID, CFE_EVS_ERROR, "CI: Error reading from receiver device");
    }
}
