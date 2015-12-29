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

#include "hs_task.h"
#include "hs_tables.h"


/* External data */
extern uint32 sysIdleTicks;
extern uint32 sysClkIntTicks;

/* Global data */
HS_AppData_t HS_AppData;

void HS_TaskMain(void) {
    uint32 RunStatus = CFE_ES_APP_RUN;
    int32  Status = CFE_SUCCESS;

    CFE_ES_PerfLogEntry(HS_MAIN_TASK_PERF_ID);

    Status = HS_Init();
    if (Status != CFE_SUCCESS) {
        RunStatus = CFE_ES_APP_ERROR;
    }

    while (CFE_ES_RunLoop(&RunStatus) == TRUE) {
        CFE_ES_PerfLogExit(HS_MAIN_TASK_PERF_ID);
        Status = CFE_SB_RcvMsg(&HS_AppData.MsgPtr, HS_AppData.WakeupPipe, HS_WAKEUP_TIMEOUT);
        CFE_ES_PerfLogEntry(HS_MAIN_TASK_PERF_ID);

        if (Status == CFE_SUCCESS) {
            uint32 i = 0;

            /* Manage tables */
            CFE_TBL_Manage(HS_AppData.MsgActTblHandle);
            CFE_TBL_Manage(HS_AppData.EventMonitorTblHandle);

            Status = CFE_TBL_Manage(HS_AppData.AppMonitorTblHandle);
            if (Status == CFE_TBL_INFO_UPDATED) {
                /* New app monitor table, reset counters */
                CFE_PSP_MemSet(HS_AppData.StaticAppCounts, 0, sizeof(HS_AppData.StaticAppCounts));
                CFE_PSP_MemSet(HS_AppData.PrevAppCounts, 0, sizeof(HS_AppData.StaticAppCounts));
            }

            /* Monitor Applications */
            if (HS_AppData.HkPacket.AppMonitorStatus == HS_STATE_ENABLED) {
                HS_MonitorApplications();
            }

            /* Check for any commands */
            for (i = 1; i < HS_CMD_PIPE_DEPTH; i++) {
                Status = CFE_SB_RcvMsg(&HS_AppData.MsgPtr, HS_AppData.CmdPipe, CFE_SB_POLL);
                if (Status == CFE_SUCCESS) {
                    HS_AppPipe();
                } else if (Status == CFE_SB_NO_MESSAGE) {
                    break;
                } else {
                    CFE_EVS_SendEvent(HS_PIPE_ERR_EID, CFE_EVS_ERROR, "HS: Can't read command pipe, RC=0x%08X", Status);
                    RunStatus = CFE_ES_APP_ERROR;
                    break;
                }
            }

            /* Monitor Events */
            if (HS_AppData.HkPacket.EventMonitorStatus == HS_STATE_ENABLED) {
                HS_MonitorEvents();
            }

        } else if (Status != CFE_SB_TIME_OUT) {
            CFE_EVS_SendEvent(HS_PIPE_ERR_EID, CFE_EVS_ERROR, "HS: Error reading wakeup pipe, RC=0x%08X", Status);
            RunStatus = CFE_ES_APP_ERROR;
        }
    }

    CFE_ES_PerfLogExit(HS_MAIN_TASK_PERF_ID);

    CFE_ES_ExitApp(RunStatus);
}

int32 HS_Init(void) {
    int32 Status = CFE_SUCCESS;

    CFE_ES_RegisterApp();

    /* Initialize app data */
    HS_AppData.CmdPipe = 0;
    HS_AppData.WakeupPipe = 0;
    HS_AppData.EventPipe = 0;
    HS_AppData.MsgPtr = NULL;
    HS_AppData.CpuUtilPtr = 0;
    CFE_PSP_MemSet(HS_AppData.CpuUtilHist, 0, sizeof(HS_AppData.CpuUtilHist));
    CFE_PSP_MemSet(HS_AppData.StaticAppCounts, 0, sizeof(HS_AppData.StaticAppCounts));
    CFE_PSP_MemSet(HS_AppData.PrevAppCounts, 0, sizeof(HS_AppData.StaticAppCounts));

    /* Set up and register events */
    HS_AppData.EventFilters[0].EventID = HS_INIT_INF_EID;
    HS_AppData.EventFilters[0].Mask    = CFE_EVS_NO_FILTER;
    HS_AppData.EventFilters[1].EventID = HS_NOOP_INF_EID;
    HS_AppData.EventFilters[1].Mask    = CFE_EVS_NO_FILTER;
    HS_AppData.EventFilters[2].EventID = HS_RESETCTRS_DBG_EID;
    HS_AppData.EventFilters[2].Mask    = CFE_EVS_NO_FILTER;
    HS_AppData.EventFilters[3].EventID = HS_CRPIPE_ERR_EID;
    HS_AppData.EventFilters[3].Mask    = CFE_EVS_NO_FILTER;
    HS_AppData.EventFilters[4].EventID = HS_SUBSCRIBE_ERR_EID;
    HS_AppData.EventFilters[4].Mask    = CFE_EVS_NO_FILTER;
    HS_AppData.EventFilters[5].EventID = HS_MSGID_ERR_EID;
    HS_AppData.EventFilters[5].Mask    = CFE_EVS_NO_FILTER;
    HS_AppData.EventFilters[6].EventID = HS_CC1_ERR_EID;
    HS_AppData.EventFilters[6].Mask    = CFE_EVS_NO_FILTER;
    HS_AppData.EventFilters[7].EventID = HS_MSGLEN_ERR_EID;
    HS_AppData.EventFilters[7].Mask    = CFE_EVS_NO_FILTER;
    HS_AppData.EventFilters[8].EventID = HS_PIPE_ERR_EID;
    HS_AppData.EventFilters[8].Mask    = CFE_EVS_NO_FILTER;

    Status = CFE_EVS_Register(HS_AppData.EventFilters, HS_FILTERED_EVT_COUNT, CFE_EVS_BINARY_FILTER);
    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog("HS: Error registering events, RC=0x%08X\n", Status);
        return Status;
    }

    /* Initialize housekeeping */
    CFE_SB_InitMsg(&HS_AppData.HkPacket, HS_HK_TLM_MID, sizeof(HS_HkPacket_t), TRUE);
    HS_AppData.HkPacket.AppMonitorStatus = HS_APPMON_DEFAULT_STATE;
    HS_AppData.HkPacket.EventMonitorStatus = HS_EVENTMON_DEFAULT_STATE;
    CFE_PSP_MemSet(HS_AppData.HkPacket.ExeCount, 0, sizeof(HS_AppData.HkPacket.ExeCount));
    HS_ResetCounters();

    /* Register and load message action table */
    Status = CFE_TBL_Register(&HS_AppData.MsgActTblHandle, "MAT", sizeof(HS_MessageActionTable_t), CFE_TBL_OPT_DEFAULT, HS_MessageActionTableValidate);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(HS_TBL_REG_ERR_EID, CFE_EVS_ERROR, "HS: Failed to register message action table, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_TBL_Load(HS_AppData.MsgActTblHandle, CFE_TBL_SRC_FILE, HS_MAT_FILENAME);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(HS_TBL_LOAD_ERR_EID, CFE_EVS_ERROR, "HS: Failed to load default message action table(%s), RC=0x%08X", HS_MAT_FILENAME, Status);
    } else {
        CFE_TBL_Manage(HS_AppData.MsgActTblHandle);
    }

    /* Register and load critical app monitor table */
    Status = CFE_TBL_Register(&HS_AppData.AppMonitorTblHandle, "AMT", sizeof(HS_AppMonitorTable_t), CFE_TBL_OPT_DEFAULT, HS_AppMonitorTableValidate);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(HS_TBL_REG_ERR_EID, CFE_EVS_ERROR, "HS: Failed to register app monitor table, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_TBL_Load(HS_AppData.AppMonitorTblHandle, CFE_TBL_SRC_FILE, HS_AMT_FILENAME);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(HS_TBL_LOAD_ERR_EID, CFE_EVS_ERROR, "HS: Failed to load default app monitor table(%s), RC=0x%08X", HS_AMT_FILENAME, Status);
        HS_AppData.HkPacket.AppMonitorStatus = HS_STATE_DISABLED;
    } else {
        CFE_TBL_Manage(HS_AppData.AppMonitorTblHandle);
    }

    /* Register and load critical event monitor table */
    Status = CFE_TBL_Register(&HS_AppData.EventMonitorTblHandle, "EMT", sizeof(HS_EventMonitorTable_t), CFE_TBL_OPT_DEFAULT, HS_EventMonitorTableValidate);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(HS_TBL_REG_ERR_EID, CFE_EVS_ERROR, "HS: Failed to register event monitor table, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_TBL_Load(HS_AppData.EventMonitorTblHandle, CFE_TBL_SRC_FILE, HS_EMT_FILENAME);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(HS_TBL_LOAD_ERR_EID, CFE_EVS_ERROR, "HS: Failed to load default event monitor table(%s), RC=0x%08X", HS_EMT_FILENAME, Status);
        HS_AppData.HkPacket.EventMonitorStatus = HS_STATE_DISABLED;
    } else {
        CFE_TBL_Manage(HS_AppData.EventMonitorTblHandle);
    }

    /* Create the command pipe and subscribe to its messages */
    Status = CFE_SB_CreatePipe(&HS_AppData.CmdPipe, HS_CMD_PIPE_DEPTH, "HS_CMD_PIPE");
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(HS_CRPIPE_ERR_EID, CFE_EVS_ERROR, "HS: Can't create command pipe, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(HS_CMD_MID, HS_AppData.CmdPipe);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(HS_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "HS: Error subscribing to HS_CMD_MID(0x%04X), RC=0x%08X", HS_CMD_MID, Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(HS_SEND_HK_MID, HS_AppData.CmdPipe);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(HS_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "HS: Error subscribing to HS_SEND_HK_MID(0x%04X), RC=0x%08X", HS_SEND_HK_MID, Status);
        return Status;
    }

    /* Create the wakeup pipe and subscribe to its message */
    Status = CFE_SB_CreatePipe(&HS_AppData.WakeupPipe, HS_WAKEUP_PIPE_DEPTH, "HS_WAKEUP_PIPE");
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(HS_CRPIPE_ERR_EID, CFE_EVS_ERROR, "HS: Can't create wakeup pipe, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(TICK_1HZ_MID, HS_AppData.WakeupPipe);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(HS_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "HS: Error subscribing to HS_CMD_MID(0x%04X), RC=0x%08X", HS_CMD_MID, Status);
        return Status;
    }

    /* Create the event pipe and subscribe to events */
    Status = CFE_SB_CreatePipe(&HS_AppData.EventPipe, HS_EVENT_PIPE_DEPTH, "HS_EVENT_PIPE");
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(HS_CRPIPE_ERR_EID, CFE_EVS_ERROR, "HS: Can't create event pipe, RC=0x%08X", Status);
        return Status;
    }

    if (HS_AppData.HkPacket.EventMonitorStatus == HS_STATE_ENABLED) {
        Status = CFE_SB_SubscribeEx(CFE_EVS_EVENT_MSG_MID, HS_AppData.EventPipe, CFE_SB_Default_Qos, HS_EVENT_PIPE_DEPTH);
        if (Status != CFE_SUCCESS) {
            CFE_EVS_SendEvent(HS_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "HS: Error subscribing to CFE_EVS_EVENT_MSG_MID(0x%04X), RC=0x%08X", CFE_EVS_EVENT_MSG_MID, Status);
            return Status;
        }
    }

    CFE_ES_WaitForStartupSync(HS_STARTUP_SYNC_TIMEOUT);
    CFE_EVS_SendEvent(HS_INIT_INF_EID, CFE_EVS_INFORMATION, "HS: App initialized");

    return CFE_SUCCESS;
}

void HS_AppPipe(void) {
    CFE_SB_MsgId_t MsgId;

    MsgId = CFE_SB_GetMsgId(HS_AppData.MsgPtr);
    switch (MsgId) {
        case HS_CMD_MID:
            HS_ProcessGroundCommand();
            break;
        case HS_SEND_HK_MID:
            HS_ReportHousekeeping();
            break;
        default:
            CFE_EVS_SendEvent(HS_MSGID_ERR_EID, CFE_EVS_ERROR, "HS: invalid command packet, MID=0x%04X", MsgId);
            HS_AppData.HkPacket.ErrorCount++;
            break;
    }
}

void HS_ProcessGroundCommand(void) {
    uint16 CommandCode;

    CommandCode = CFE_SB_GetCmdCode(HS_AppData.MsgPtr);
    switch (CommandCode) {
        case HS_NOOP_CC:
            HS_NoopCmd();
            break;
        case HS_RESETCTRS_CC:
            HS_ResetCountersCmd();
            break;
        default:
            CFE_EVS_SendEvent(HS_CC1_ERR_EID, CFE_EVS_ERROR, "HS: invalid command code, MID=0x%04X, CC=%02u", CFE_SB_GetMsgId(HS_AppData.MsgPtr), CommandCode);
            HS_AppData.HkPacket.ErrorCount++;
            break;
    }
}

void HS_ReportHousekeeping(void) {
    MEM_PART_STATS partStats;
    uint32 i;
    uint8 CpuUsage;

    /* Calculate CPU usage */
    if (sysClkIntTicks != 0) {
        CpuUsage = 100 - (sysIdleTicks * 100 / sysClkIntTicks);
    } else {
        CpuUsage = 0;
    }
    /* Reset delta counters */
    sysIdleTicks = 0;
    sysClkIntTicks = 0;

    HS_AppData.CpuUtilHist[HS_AppData.CpuUtilPtr] = CpuUsage;
    HS_AppData.CpuUtilPtr = (HS_AppData.CpuUtilPtr + 1) % HS_PEAK_NUM_INTERVALS;

    HS_AppData.HkPacket.CPUAverage = CpuUsage;
    HS_AppData.HkPacket.CPUPeak = 0;
    for (i = 0; i < HS_PEAK_NUM_INTERVALS; i++) {
        if (HS_AppData.CpuUtilHist[i] > HS_AppData.HkPacket.CPUPeak) {
            HS_AppData.HkPacket.CPUPeak = HS_AppData.CpuUtilHist[i];
        }
    }

    /* Calculate memory usage */
    memPartInfoGet(memSysPartId, &partStats);
    HS_AppData.HkPacket.MemFree = partStats.numBytesFree;

    CFE_SB_TimeStampMsg((CFE_SB_MsgPtr_t)&HS_AppData.HkPacket);
    CFE_SB_SendMsg((CFE_SB_MsgPtr_t)&HS_AppData.HkPacket);
}

void HS_ResetCounters(void) {
    HS_AppData.HkPacket.CommandCount = 0;
    HS_AppData.HkPacket.ErrorCount = 0;
    HS_AppData.HkPacket.EventCount = 0;
    HS_AppData.HkPacket.ExeCountErrors = 0;
}

void HS_NoopCmd(void) {
    uint16 ExpectedLength = sizeof(HS_NoArgsCmd_t);

    if (HS_VerifyCmdLength(HS_AppData.MsgPtr, ExpectedLength)) {
        HS_AppData.HkPacket.CommandCount++;
        CFE_EVS_SendEvent(HS_NOOP_INF_EID, CFE_EVS_INFORMATION, "HS: Noop command");
    }
}

void HS_ResetCountersCmd(void) {
    uint16 ExpectedLength = sizeof(HS_NoArgsCmd_t);

    if (HS_VerifyCmdLength(HS_AppData.MsgPtr, ExpectedLength)) {
        HS_ResetCounters();
        CFE_EVS_SendEvent(HS_RESETCTRS_DBG_EID, CFE_EVS_DEBUG, "HS: Reset counters");
    }
}

boolean HS_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength) {
    boolean result = TRUE;
    uint16  ActualLength = CFE_SB_GetTotalMsgLength(Msg);

    if (ExpectedLength != ActualLength) {
        CFE_SB_MsgId_t MessageId = CFE_SB_GetMsgId(Msg);
        uint16 CommandCode = CFE_SB_GetCmdCode(Msg);

        CFE_EVS_SendEvent(HS_MSGLEN_ERR_EID, CFE_EVS_ERROR, "HS: Invalid cmd length: MID = 0x%04X, CC = %02u, Exp Len = %u, Len = %u", MessageId, CommandCode, ExpectedLength, ActualLength);
        result = FALSE;
        HS_AppData.HkPacket.ErrorCount++;
    }
    return result;
}
