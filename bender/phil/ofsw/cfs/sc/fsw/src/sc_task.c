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

#include "sc_task.h"

SC_AppData_t SC_AppData;

void SC_TaskMain(void) {
    uint32 RunStatus = CFE_ES_APP_RUN;
    int32  Status = CFE_SUCCESS;

    CFE_ES_PerfLogEntry(SC_MAIN_TASK_PERF_ID);

    Status = SC_Init();
    if (Status != CFE_SUCCESS) {
        RunStatus = CFE_ES_APP_ERROR;
    }

    while (CFE_ES_RunLoop(&RunStatus) == TRUE) {
        CFE_ES_PerfLogExit(SC_MAIN_TASK_PERF_ID);

        Status = CFE_SB_RcvMsg(&SC_AppData.MsgPtr, SC_AppData.CmdPipe, CFE_SB_PEND_FOREVER);

        CFE_ES_PerfLogEntry(SC_MAIN_TASK_PERF_ID);

        if (Status == CFE_SUCCESS) {
            SC_AppPipe();
        } else {
            CFE_EVS_SendEvent(SC_PIPE_ERR_EID, CFE_EVS_ERROR, "SB pipe read error, SC will exit.");
            RunStatus = CFE_ES_APP_ERROR;
        }
    }
    CFE_ES_PerfLogExit(SC_MAIN_TASK_PERF_ID);
}

int32 SC_Init(void) {
    int32 Status = CFE_SUCCESS;
    uint32 i = 0;

    CFE_ES_RegisterApp();

    /* Initialize app data */
    SC_AppData.CmdPipe = 0;
    SC_AppData.MsgPtr = NULL;

    SC_AppData.NextATSCmdIndex = 0;
    SC_AppData.ATSHandle[0] = CFE_TBL_BAD_TABLE_HANDLE;
    SC_AppData.ATSHandle[1] = CFE_TBL_BAD_TABLE_HANDLE;
    for (i=0; i < SC_NUMBER_OF_RTS; i++) {
        SC_AppData.RTSHandle[i] = CFE_TBL_BAD_TABLE_HANDLE;
    }

    /* Set up and register events */
    SC_AppData.EventFilters[0].EventID = SC_INIT_INF_EID;
    SC_AppData.EventFilters[0].Mask    = CFE_EVS_NO_FILTER;
    SC_AppData.EventFilters[1].EventID = SC_NOOP_INF_EID;
    SC_AppData.EventFilters[1].Mask    = CFE_EVS_NO_FILTER;
    SC_AppData.EventFilters[2].EventID = SC_CRCMDPIPE_ERR_EID;
    SC_AppData.EventFilters[2].Mask    = CFE_EVS_NO_FILTER;
    SC_AppData.EventFilters[3].EventID = SC_SUBSCRIBE_ERR_EID;
    SC_AppData.EventFilters[4].Mask    = CFE_EVS_NO_FILTER;
    SC_AppData.EventFilters[4].EventID = SC_MSGID_ERR_EID;
    SC_AppData.EventFilters[4].Mask    = CFE_EVS_NO_FILTER;
    SC_AppData.EventFilters[5].EventID = SC_CC1_ERR_EID;
    SC_AppData.EventFilters[5].Mask    = CFE_EVS_NO_FILTER;
    SC_AppData.EventFilters[6].EventID = SC_MSGLEN_ERR_EID;
    SC_AppData.EventFilters[6].Mask    = CFE_EVS_NO_FILTER;
    SC_AppData.EventFilters[7].EventID = SC_PIPE_ERR_EID;
    SC_AppData.EventFilters[7].Mask    = CFE_EVS_NO_FILTER;

    Status = CFE_EVS_Register(SC_AppData.EventFilters, SC_FILTERED_EVT_COUNT, CFE_EVS_BINARY_FILTER);
    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog("Error registering events, RC = 0x%08X\n", Status);
        return Status;
    }

    /* Initialize housekeeping */
    CFE_SB_InitMsg(&SC_AppData.HkPacket, SC_HK_TLM_MID, sizeof(SC_HkPacket_t), TRUE);
    SC_ResetCounters();

    SC_AppData.HkPacket.AtsNumber = 0;
    SC_AppData.HkPacket.AtsState = SC_ATS_IDLE;
    SC_AppData.HkPacket.AtsCmdNumber = 0;
    SC_AppData.HkPacket.LastAtsErrSeq = 0;
    SC_AppData.HkPacket.NextAtsTime = 0;
    SC_AppData.HkPacket.ContinueAtsOnFailure = SC_ATS_CONT_ON_FAILURE_START;
    SC_AppData.HkPacket.ContinueRtsOnFailure = SC_RTS_CONT_ON_FAILURE_START;
    SC_AppData.HkPacket.NextRtsNumber = 0;
    SC_AppData.HkPacket.NextRtsTime.Seconds = 0;
    SC_AppData.HkPacket.NextRtsTime.Subseconds = 0;
    SC_AppData.HkPacket.LastAtsErrCmd = 0;
    SC_AppData.HkPacket.LastRtsErrCmd = 0;
    SC_AppData.HkPacket.LastRtsErrNum = 0;

    for (i = 0; i < sizeof(SC_AppData.HkPacket.RtsExecutingStatus)/sizeof(SC_AppData.HkPacket.RtsExecutingStatus[0]); i++) {
        SC_AppData.HkPacket.RtsExecutingStatus[i] = 0;
    }

    /* Create a command pipe and subscribe to its messages */
    Status = CFE_SB_CreatePipe(&SC_AppData.CmdPipe, SC_PIPE_DEPTH, "SC_CMD_PIPE");
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(SC_CRCMDPIPE_ERR_EID, CFE_EVS_ERROR, "Can't create command pipe, RC = 0x%08X", Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(SC_CMD_MID, SC_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(SC_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to SC_CMD_MID(0x%04X), RC=0x%08X", SC_CMD_MID, Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(SC_SEND_HK_MID, SC_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(SC_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to SC_SEND_HK_MID(0x%04X), RC=0x%08X", SC_SEND_HK_MID, Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(SC_TICK_MID, SC_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(SC_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "Error subscribing to SC_TICK_MID(0x%04X), RC=0x%08X", SC_TICK_MID, Status);
        return Status;
    }

    /* Register ATS tables */
    Status = SC_ATS_Register();
    if (Status != CFE_SUCCESS) {
        return Status;
    }

    /* Register/load RTS tables */
    Status = SC_RTS_Register();
    if (Status != CFE_SUCCESS) {
        return Status;
    }


    CFE_EVS_SendEvent(SC_INIT_INF_EID, CFE_EVS_INFORMATION, "SC app initialized.");
    return CFE_SUCCESS;
}

void SC_RunSequences(void) {
    CFE_TIME_SysTime_t CurrentTime;

    /* Get the current spacecraft time */
    CurrentTime = CFE_TIME_GetTime();

    SC_ATS_Update(CurrentTime);
    SC_RTS_UpdateAll(CurrentTime);
}

void SC_AppPipe(void) {
    CFE_SB_MsgId_t MsgId = CFE_SB_GetMsgId(SC_AppData.MsgPtr);

    switch (MsgId) {
        case SC_CMD_MID:
            SC_ProcessGroundCommand();
            break;
        case SC_SEND_HK_MID:
            SC_ReportHousekeeping();
            break;
        case SC_TICK_MID:
            SC_RunSequences();
            break;
        default:
            CFE_EVS_SendEvent(SC_MSGID_ERR_EID, CFE_EVS_ERROR, "Received invalid MsgId 0x%04X", MsgId);
            SC_AppData.HkPacket.CmdErrCtr++;
            break;
    }
}


void SC_ProcessGroundCommand(void) {
    uint16 CommandCode = CFE_SB_GetCmdCode(SC_AppData.MsgPtr);

    switch (CommandCode) {
        case SC_NOOP_CC:
            if (SC_VerifyCmdLength(SC_AppData.MsgPtr, sizeof(SC_NoArgsCmd_t))) {
                CFE_EVS_SendEvent(SC_NOOP_INF_EID, CFE_EVS_INFORMATION, "NOOP Command");
                SC_AppData.HkPacket.CmdCtr++;
            }
            break;
        case SC_RESETCTRS_CC:
            if (SC_VerifyCmdLength(SC_AppData.MsgPtr, sizeof(SC_NoArgsCmd_t))) {
                SC_ResetCounters();
            }
            break;
        case SC_START_ATS_CC:
            if (SC_VerifyCmdLength(SC_AppData.MsgPtr, sizeof(SC_TSCmd_t))) {
                SC_StartATSCmd(SC_AppData.MsgPtr);
            }
            break;
        case SC_STOP_ATS_CC:
            if (SC_VerifyCmdLength(SC_AppData.MsgPtr, sizeof(SC_NoArgsCmd_t))) {
                SC_StopATSCmd();
            }
            break;
        case SC_START_RTS_CC:
            if (SC_VerifyCmdLength(SC_AppData.MsgPtr, sizeof(SC_TSCmd_t))) {
                SC_StartRTSCmd(SC_AppData.MsgPtr);
            }
            break;
        case SC_STOP_RTS_CC:
            if (SC_VerifyCmdLength(SC_AppData.MsgPtr, sizeof(SC_TSCmd_t))) {
                SC_StopRTSCmd(SC_AppData.MsgPtr);
            }
            break;
        case SC_DISABLE_RTS_CC:
            if (SC_VerifyCmdLength(SC_AppData.MsgPtr, sizeof(SC_TSCmd_t))) {
                SC_DisableRTSCmd(SC_AppData.MsgPtr);
            }
            break;
        case SC_ENABLE_RTS_CC:
            if (SC_VerifyCmdLength(SC_AppData.MsgPtr, sizeof(SC_TSCmd_t))) {
                SC_EnableRTSCmd(SC_AppData.MsgPtr);
            }
            break;
        case SC_SWITCH_ATS_CC:
            if (SC_VerifyCmdLength(SC_AppData.MsgPtr, sizeof(SC_NoArgsCmd_t))) {
                SC_SwitchATSCmd();
            }
            break;
        case SC_ATS_JUMP_CC:
            if (SC_VerifyCmdLength(SC_AppData.MsgPtr, sizeof(SC_AtsTimeCmd_t))) {
                SC_JumpATSCmd(SC_AppData.MsgPtr);
            }
            break;
        case SC_CONT_ATS_ON_FAIL_CC:
            if (SC_VerifyCmdLength(SC_AppData.MsgPtr, sizeof(SC_ContOnFailCmd_t))) {
                SC_ContATSOnFailCmd(SC_AppData.MsgPtr);
            }
            break;
        case SC_CONT_RTS_ON_FAIL_CC:
            if (SC_VerifyCmdLength(SC_AppData.MsgPtr, sizeof(SC_ContOnFailCmd_t))) {
                SC_ContRTSOnFailCmd(SC_AppData.MsgPtr);
            }
            break;
        default:
            CFE_EVS_SendEvent(SC_CC1_ERR_EID, CFE_EVS_ERROR, "Invalid command code %u", CommandCode);
            SC_AppData.HkPacket.CmdErrCtr++;
            break;
    }
}

void SC_StartATSCmd(CFE_SB_MsgPtr_t MsgPtr) {
    SC_TSCmd_t *AtsCmd = (SC_TSCmd_t *)MsgPtr;

    if (AtsCmd->Number != 1 && AtsCmd->Number != 2) {
        /* There's only two ATSs yo */
        CFE_EVS_SendEvent(SC_ATS_BAD_ARG_ERR_EID, CFE_EVS_ERROR, "Cannot start invalid ATS %u", AtsCmd->Number);
        SC_AppData.HkPacket.CmdErrCtr++;
    } else if (SC_AppData.HkPacket.AtsState == SC_ATS_EXECUTING) {
        /* There's already an ATS going... */
        CFE_EVS_SendEvent(SC_ATS_BUSY_ERR_EID, CFE_EVS_ERROR, "Cannot start ATS %u because ATS %u is already running", AtsCmd->Number, SC_AppData.HkPacket.AtsNumber);
        SC_AppData.HkPacket.CmdErrCtr++;
    } else {
        /* Prepare the ATS */
        if (SC_ATS_Prepare(AtsCmd->Number) == CFE_SUCCESS) {
            /* Start it executing */
            SC_AppData.HkPacket.AtsState = SC_ATS_EXECUTING;

            CFE_EVS_SendEvent(SC_ATS_START_INF_EID, CFE_EVS_INFORMATION, "Started ATS %u", AtsCmd->Number);
            SC_AppData.HkPacket.CmdCtr++;
        } else {
            SC_AppData.HkPacket.CmdErrCtr++;
        }
    }
}

void SC_StopATSCmd(void) {
    if (SC_AppData.HkPacket.AtsState != SC_ATS_EXECUTING) {
        CFE_EVS_SendEvent(SC_ATS_NOT_RUNNING_ERR_EID, CFE_EVS_ERROR, "Cannot stop ATS because there isn't one running");
        SC_AppData.HkPacket.CmdErrCtr++;
    } else {
        SC_ATS_Stop(SC_STOP_ON_COMMAND);
        SC_AppData.HkPacket.CmdCtr++;
    }
}

void SC_StartRTSCmd(CFE_SB_MsgPtr_t MsgPtr) {
    int32 Status;
    SC_TSCmd_t *RtsCmd = (SC_TSCmd_t *)MsgPtr;

    if (RtsCmd->Number == 0 || RtsCmd->Number > SC_NUMBER_OF_RTS) {
        /* Out-of-range RTS */
        CFE_EVS_SendEvent(SC_RTS_BAD_ARG_ERR_EID, CFE_EVS_ERROR, "Cannot start invalid RTS %u", RtsCmd->Number);
        SC_AppData.HkPacket.RtsActivErrCtr++;
        SC_AppData.HkPacket.CmdErrCtr++;
    } else if (SC_AppData.RTSInfo[RtsCmd->Number-1].Status == SC_RTS_EXECUTING) {
        /* This RTS is already going... */
        CFE_EVS_SendEvent(SC_RTS_BUSY_ERR_EID, CFE_EVS_ERROR, "Cannot start RTS %u because it is already running", RtsCmd->Number);
        SC_AppData.HkPacket.RtsActivErrCtr++;
        SC_AppData.HkPacket.CmdErrCtr++;
    } else if (SC_AppData.RTSInfo[RtsCmd->Number-1].Status == SC_RTS_UNLOADED) {
        /* This RTS doesn't exist */
        CFE_EVS_SendEvent(SC_RTS_ABSENT_ERR_EID, CFE_EVS_ERROR, "Cannot start nonexistent RTS %u", RtsCmd->Number);
        SC_AppData.HkPacket.RtsActivErrCtr++;
        SC_AppData.HkPacket.CmdErrCtr++;
    } else if (SC_AppData.RTSInfo[RtsCmd->Number-1].EnableState == SC_RTS_DISABLED) {
        /* This RTS is disabled */
        CFE_EVS_SendEvent(SC_RTS_ABSENT_ERR_EID, CFE_EVS_ERROR, "Cannot start disabled RTS %u", RtsCmd->Number);
        SC_AppData.HkPacket.RtsActivErrCtr++;
        SC_AppData.HkPacket.CmdErrCtr++;
    } else {
        /* Start the RTS */
        Status = SC_RTS_Start(RtsCmd->Number);
        if (Status == CFE_SUCCESS) {
            SC_AppData.HkPacket.RtsActivCtr++;
            SC_AppData.HkPacket.CmdCtr++;
        } else {
            SC_AppData.HkPacket.CmdErrCtr++;
        }
    }
}

void SC_StopRTSCmd(CFE_SB_MsgPtr_t MsgPtr) {
    SC_TSCmd_t *RtsCmd = (SC_TSCmd_t *)MsgPtr;

    if (RtsCmd->Number == 0 || RtsCmd->Number > SC_NUMBER_OF_RTS) {
        /* Out-of-range RTS */
        CFE_EVS_SendEvent(SC_RTS_BAD_ARG_ERR_EID, CFE_EVS_ERROR, "Cannot stop invalid RTS %u", RtsCmd->Number);
        SC_AppData.HkPacket.CmdErrCtr++;
    } else if (SC_AppData.RTSInfo[RtsCmd->Number-1].Status == SC_RTS_UNLOADED) {
        /* This RTS doesn't exist */
        CFE_EVS_SendEvent(SC_RTS_ABSENT_ERR_EID, CFE_EVS_ERROR, "Cannot stop nonexistent RTS %u", RtsCmd->Number);
        SC_AppData.HkPacket.CmdErrCtr++;
    } else if (SC_AppData.RTSInfo[RtsCmd->Number-1].Status != SC_RTS_EXECUTING) {
        /* This RTS is already going... */
        CFE_EVS_SendEvent(SC_RTS_BUSY_ERR_EID, CFE_EVS_ERROR, "Cannot stop RTS %u because it is not running", RtsCmd->Number);
        SC_AppData.HkPacket.CmdErrCtr++;
    } else {
        /* Stop the RTS */
        SC_RTS_Stop(RtsCmd->Number, SC_STOP_ON_COMMAND);
        SC_AppData.HkPacket.CmdCtr++;
    }
}

void SC_DisableRTSCmd(CFE_SB_MsgPtr_t MsgPtr) {
    SC_TSCmd_t *RtsCmd = (SC_TSCmd_t *)MsgPtr;

    if (RtsCmd->Number == 0 || RtsCmd->Number > SC_NUMBER_OF_RTS) {
        /* Out-of-range RTS */
        CFE_EVS_SendEvent(SC_RTS_BAD_ARG_ERR_EID, CFE_EVS_ERROR, "Cannot disable invalid RTS %u", RtsCmd->Number);
        SC_AppData.HkPacket.CmdErrCtr++;
    } else if (SC_AppData.RTSInfo[RtsCmd->Number-1].Status == SC_RTS_UNLOADED) {
        /* This RTS doesn't exist */
        CFE_EVS_SendEvent(SC_RTS_ABSENT_ERR_EID, CFE_EVS_ERROR, "Cannot disable nonexistent RTS %u", RtsCmd->Number);
        SC_AppData.HkPacket.CmdErrCtr++;
    } else if (SC_AppData.RTSInfo[RtsCmd->Number-1].EnableState == SC_RTS_DISABLED) {
        /* This RTS doesn't exist */
        CFE_EVS_SendEvent(SC_RTS_ALREADY_DISABLED_ERR_EID, CFE_EVS_ERROR, "RTS %u is already disabled", RtsCmd->Number);
        SC_AppData.HkPacket.CmdErrCtr++;
    } else {
        /* Stop the RTS if it's running */
        if (SC_AppData.RTSInfo[RtsCmd->Number-1].Status == SC_RTS_EXECUTING) {
            SC_AppData.RTSInfo[RtsCmd->Number-1].DisableOnFinish = TRUE;
            CFE_EVS_SendEvent(SC_DISABLE_RUNNING_RTS_ERR_EID, CFE_EVS_ERROR, "Attempt to disable running RTS %u -- it will be disabled upon completion", RtsCmd->Number);
        } else {
            /* Set its state to disabled */
            SC_AppData.RTSInfo[RtsCmd->Number-1].EnableState = SC_RTS_DISABLED;
            CFE_EVS_SendEvent(SC_RTS_DISABLE_INF_EID, CFE_EVS_INFORMATION, "Disabled RTS %u", RtsCmd->Number);

        }
        SC_AppData.HkPacket.CmdCtr++;
    }
}

void SC_EnableRTSCmd(CFE_SB_MsgPtr_t MsgPtr) {
    SC_TSCmd_t *RtsCmd = (SC_TSCmd_t *)MsgPtr;

    if (RtsCmd->Number == 0 || RtsCmd->Number > SC_NUMBER_OF_RTS) {
        /* Out-of-range RTS */
        CFE_EVS_SendEvent(SC_RTS_BAD_ARG_ERR_EID, CFE_EVS_ERROR, "Cannot enable invalid RTS %u", RtsCmd->Number);
        SC_AppData.HkPacket.CmdErrCtr++;
    } else if (SC_AppData.RTSInfo[RtsCmd->Number-1].Status == SC_RTS_UNLOADED) {
        /* This RTS doesn't exist */
        CFE_EVS_SendEvent(SC_RTS_ABSENT_ERR_EID, CFE_EVS_ERROR, "Cannot enable nonexistent RTS %u", RtsCmd->Number);
        SC_AppData.HkPacket.CmdErrCtr++;
    } else if (SC_AppData.RTSInfo[RtsCmd->Number-1].EnableState == SC_RTS_ENABLED) {
        if (SC_AppData.RTSInfo[RtsCmd->Number-1].DisableOnFinish) {
            SC_AppData.RTSInfo[RtsCmd->Number-1].DisableOnFinish = FALSE;
            CFE_EVS_SendEvent(SC_RTS_DISABLE_CANCEL_INF_EID, CFE_EVS_INFORMATION, "Canncelled pending disable for RTS %u", RtsCmd->Number);

            SC_AppData.HkPacket.CmdCtr++;
        } else {
            /* The RTS is enabled and doesn't have a pending disable */
            CFE_EVS_SendEvent(SC_RTS_ALREADY_DISABLED_ERR_EID, CFE_EVS_ERROR, "RTS %u is already enabled", RtsCmd->Number);
            SC_AppData.HkPacket.CmdErrCtr++;
        }
    } else {
        /* Set its state to enabled */
        SC_AppData.RTSInfo[RtsCmd->Number-1].EnableState = SC_RTS_ENABLED;
        CFE_EVS_SendEvent(SC_RTS_ENABLE_INF_EID, CFE_EVS_INFORMATION, "Enabled RTS %u", RtsCmd->Number);

        SC_AppData.HkPacket.CmdCtr++;
    }
}

void SC_SwitchATSCmd(void) {
    if (SC_AppData.HkPacket.AtsState != SC_ATS_EXECUTING) {
        CFE_EVS_SendEvent(SC_ATS_NOT_RUNNING_ERR_EID, CFE_EVS_ERROR, "Cannot switch ATS because there isn't one running");
        SC_AppData.HkPacket.CmdErrCtr++;
    } else {
        uint8 CurrentATS = SC_AppData.HkPacket.AtsNumber;
        uint8 NewATS;

        /* Stop the current ATS */
        SC_ATS_Stop(SC_STOP_ON_COMMAND);

        /* Figure out which ATS to switch to */
        if (CurrentATS == 2) {
            NewATS = 1;
        } else {
            NewATS = 2;
        }

        /* TODO: Combine this logic with SC_STARTATS? */
        if (SC_ATS_Prepare(NewATS) == CFE_SUCCESS) {
            /* Start the new ATS */
            SC_AppData.HkPacket.AtsState = SC_ATS_EXECUTING;

            CFE_EVS_SendEvent(SC_ATS_SWITCH_INF_EID, CFE_EVS_INFORMATION, "Switched to ATS %u", NewATS);
            SC_AppData.HkPacket.CmdCtr++;
        } else {
            SC_AppData.HkPacket.CmdErrCtr++;
        }
    }
}

void SC_JumpATSCmd(CFE_SB_MsgPtr_t MsgPtr) {
    SC_AtsTimeCmd_t *TimeCmd = (SC_AtsTimeCmd_t *)MsgPtr;

    if (SC_AppData.HkPacket.AtsState != SC_ATS_EXECUTING) {
        CFE_EVS_SendEvent(SC_ATS_NOT_RUNNING_ERR_EID, CFE_EVS_ERROR, "Error jumping ATS time: no ATS running");
        SC_AppData.HkPacket.CmdErrCtr++;
    } else {
        SC_ATS_Jump(TimeCmd->NewTime);
        SC_AppData.HkPacket.CmdCtr++;
    }
}

void SC_ContATSOnFailCmd(CFE_SB_MsgPtr_t MsgPtr) {
    SC_ContOnFailCmd_t *ContCmd = (SC_ContOnFailCmd_t *)MsgPtr;

    if (ContCmd->Continue != FALSE && ContCmd->Continue != TRUE) {
        CFE_EVS_SendEvent(SC_ATS_CONT_ERR_EID, CFE_EVS_ERROR, "Error setting ATS continue on fail: %u is not a boolean value", ContCmd->Continue);
        SC_AppData.HkPacket.CmdErrCtr++;
    } else {
        SC_AppData.HkPacket.ContinueAtsOnFailure = ContCmd->Continue;
        CFE_EVS_SendEvent(SC_ATS_CONT_INF_EID, CFE_EVS_INFORMATION, "Setting ATS continue on failure to %u", ContCmd->Continue);
        SC_AppData.HkPacket.CmdCtr++;
    }
}

void SC_ContRTSOnFailCmd(CFE_SB_MsgPtr_t MsgPtr) {
    SC_ContOnFailCmd_t *ContCmd = (SC_ContOnFailCmd_t *)MsgPtr;

    if (ContCmd->Continue != FALSE && ContCmd->Continue != TRUE) {
        CFE_EVS_SendEvent(SC_RTS_CONT_ERR_EID, CFE_EVS_ERROR, "Error setting RTS continue on fail: %u is not a boolean value", ContCmd->Continue);
        SC_AppData.HkPacket.CmdErrCtr++;
    } else {
        SC_AppData.HkPacket.ContinueRtsOnFailure = ContCmd->Continue;
        CFE_EVS_SendEvent(SC_RTS_CONT_INF_EID, CFE_EVS_INFORMATION, "Setting RTS continue on failure to %u", ContCmd->Continue);
        SC_AppData.HkPacket.CmdCtr++;
    }
}

void SC_ReportHousekeeping(void) {
    uint16 ExpectedLength = sizeof(SC_NoArgsCmd_t);
    if (SC_VerifyCmdLength(SC_AppData.MsgPtr, ExpectedLength)) {
        uint32 i = 0;
        int32 Status;

        /* Manage tables */
        Status = CFE_TBL_Manage(SC_AppData.ATSHandle[0]);
        if (Status == CFE_TBL_INFO_UPDATED && (SC_AppData.HkPacket.AtsState == SC_ATS_EXECUTING && SC_AppData.HkPacket.AtsNumber == 1)) {
            SC_ATS_Stop(SC_STOP_ON_TABLE_UPDATE);
        }
        Status = CFE_TBL_Manage(SC_AppData.ATSHandle[1]);
        if (Status == CFE_TBL_INFO_UPDATED && (SC_AppData.HkPacket.AtsState == SC_ATS_EXECUTING && SC_AppData.HkPacket.AtsNumber == 2)) {
            SC_ATS_Stop(SC_STOP_ON_TABLE_UPDATE);
        }

        /* Clear out old RTS executing bits */
        for (i = 0; i < (SC_NUMBER_OF_RTS/32); i++) {
            SC_AppData.HkPacket.RtsExecutingStatus[i] = 0;
        }

        SC_AppData.HkPacket.NextRtsTime.Seconds = 0;
        SC_AppData.HkPacket.NextRtsTime.Subseconds = 0;
        SC_AppData.HkPacket.NextRtsNumber = 0;

        /* While managing RTS tables, build up status information */
        for (i = 0; i < SC_NUMBER_OF_RTS; i++) {
            if (SC_AppData.RTSHandle[i] != CFE_TBL_BAD_TABLE_HANDLE) {
                CFE_TBL_Manage(SC_AppData.RTSHandle[i]);
            }

            if (SC_AppData.RTSInfo[i].Status == SC_RTS_EXECUTING) {
                /* Set the executing bit */
                SC_AppData.HkPacket.RtsExecutingStatus[(SC_NUMBER_OF_RTS/32)-i/32-1] |= 1<<(i%32);
                if (CFE_TIME_Compare(SC_AppData.RTSInfo[i].NextCmdTime, SC_AppData.HkPacket.NextRtsTime) == CFE_TIME_A_LT_B || (SC_AppData.HkPacket.NextRtsTime.Seconds == 0 && SC_AppData.HkPacket.NextRtsTime.Subseconds ==0)) {
                    SC_AppData.HkPacket.NextRtsTime = SC_AppData.RTSInfo[i].NextCmdTime;
                    SC_AppData.HkPacket.NextRtsNumber = i+1;
                }
            }
        }


        /* Timestamp and send HK packet */
        CFE_SB_TimeStampMsg((CFE_SB_MsgPtr_t)&SC_AppData.HkPacket);
        CFE_SB_SendMsg((CFE_SB_MsgPtr_t)&SC_AppData.HkPacket);
    }
}

void SC_ResetCounters(void) {
    SC_AppData.HkPacket.CmdErrCtr = 0;
    SC_AppData.HkPacket.CmdCtr = 0;
    SC_AppData.HkPacket.AtsCmdCtr = 0;
    SC_AppData.HkPacket.AtsCmdErrCtr = 0;
    SC_AppData.HkPacket.RtsActivErrCtr = 0;
    SC_AppData.HkPacket.RtsActivCtr = 0;
    SC_AppData.HkPacket.RtsCmdCtr = 0;
    SC_AppData.HkPacket.RtsCmdErrCtr = 0;
}

boolean SC_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength) {
    boolean result = TRUE;
    uint16 ActualLength = CFE_SB_GetTotalMsgLength(Msg);

    if (ActualLength != ExpectedLength) {
        CFE_SB_MsgId_t MsgId = CFE_SB_GetMsgId(Msg);
        uint16 CommandCode = CFE_SB_GetCmdCode(Msg);

        CFE_EVS_SendEvent(SC_MSGLEN_ERR_EID, CFE_EVS_ERROR, "Invalid cmd length: MID = 0x%04X, CC = %02u, Exp Len = %u, Len = %u", MsgId, CommandCode, ExpectedLength, ActualLength);
        result = FALSE;
        SC_AppData.HkPacket.CmdErrCtr++;
    }
    return result;
}
