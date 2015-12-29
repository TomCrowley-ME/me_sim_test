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
/*******************************************************************************
 ** File: lc.c
 **
 ** Purpose:
 **   This file contains the source code for the Limit Checker Application.
 **
 *******************************************************************************/

/*
 **   Include Files:
 */

#include <stddef.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>

#include "lc_task.h"
#include "lc_task_watchpoint_table.h"
#include "lc_task_actionpoint_table.h"
#include "lc_task_process_commands.h"
#include "lc_task_process_tlm.h"

LC_AppData_t LC_AppData;

/** * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* LC_TaskMain() -- Application entry point and main process loop          */
/*                                                                            */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  * *  * * * * **/
int32 LC_TaskMain(void) {
    int32 Status = CFE_SUCCESS;
    uint32 RunStatus = CFE_ES_APP_RUN;
    CFE_SB_MsgId_t MsgId;

    CFE_ES_PerfLogEntry(LC_MAIN_TASK_PERF_ID);

    Status = LC_AppInit();
    if (Status != CFE_SUCCESS) {
        RunStatus = CFE_ES_APP_ERROR;
    }

    /* Main LC Loop */
    while (CFE_ES_RunLoop(&RunStatus) == TRUE) {
        boolean tlm_received = FALSE;
        CFE_ES_PerfLogExit(LC_MAIN_TASK_PERF_ID);

        /* Pend on receipt of command packet or SCH message */
        Status = CFE_SB_RcvMsg(&LC_AppData.MsgPtr, LC_AppData.CmdPipe, CFE_SB_PEND_FOREVER);

        CFE_ES_PerfLogEntry(LC_MAIN_TASK_PERF_ID);

        if (Status == CFE_SUCCESS) {
            MsgId = CFE_SB_GetMsgId(LC_AppData.MsgPtr);

            if(MsgId == LC_EVAL_WPAP_MID){ /* from cfe Scheduler */
                CFE_PSP_MemSet(&LC_AppData.WatchpointUpdated, 0, sizeof(LC_AppData.WatchpointUpdated));
                CFE_PSP_MemSet(&LC_AppData.WatchpointState, 0, sizeof(LC_AppData.WatchpointState));
                /* drain TLM pipe and update watchpoint results */
                while(Status == CFE_SUCCESS){
                    Status = CFE_SB_RcvMsg(&LC_AppData.MsgPtr, LC_AppData.TlmPipe, CFE_SB_POLL);
                    if(Status == CFE_SUCCESS){
                        LC_ProcessTelemetryMsg();
                        tlm_received = TRUE;
                    }else if(Status == CFE_SB_NO_MESSAGE){
                        DEBUG("LC: No more TLM messages\n");
                        break;
                    }else{
                        CFE_EVS_SendEvent(LC_TLM_ERR_EID, CFE_EVS_ERROR, "LC: CFE_SB_RcvMsg() failed, RC=0x%08X", Status);
                        return Status;
                    }
                }

                DEBUG("tlm_received = %d\n", tlm_received);

                if(tlm_received){
                    LC_ProcessActionpoints();
                }
            }else{
                LC_ProcessCommandMsg();
            }
        }

    }

    CFE_ES_ExitApp(RunStatus);

    return RunStatus;

} /* End of LC_TaskMain() */


int32 LC_WatchpointTblValidationFunc(void* buffer) {
    return CFE_SUCCESS;
}

int32 LC_ActionpointTblValidationFunc(void* buffer) {
    return CFE_SUCCESS;
}

int32 LC_ManageTables(void){
    CFE_TBL_Manage(LC_AppData.AptTblHandle);
    LC_ManageWptTable();

    return CFE_SUCCESS;
}

void LC_ManageWptTable(void) {
    int32 Status = CFE_SUCCESS;
    int32 TblStatus = CFE_SUCCESS;

    do {
        TblStatus = CFE_TBL_GetStatus(LC_AppData.WptTblHandle);

        if (TblStatus == CFE_TBL_INFO_VALIDATION_PENDING) {
            /* Perform a validation, and stop table managing if it fails */
            Status = CFE_TBL_Validate(LC_AppData.WptTblHandle);
            if (Status != CFE_SUCCESS) {
                break;
            }
        } else if (TblStatus == CFE_TBL_INFO_UPDATE_PENDING) {
            /*
             * To properly update this table, we need to drop our current subscriptions, update the table, and then
             * subscribe to everything in the new table. Unfortunately table services can't tell us exactly WHAT
             * has been changed during a table update, so we just have to assume it's everything.
             */
            LC_WatchpointDefinitionTable_t *wpttbl_ptr = NULL;

            /* First, try to get access to the table. If this fails, we can just return */
            Status = CFE_TBL_GetAddress((void*)&wpttbl_ptr, LC_AppData.WptTblHandle);
            if (Status != CFE_SUCCESS) {
                if (Status == CFE_TBL_ERR_NEVER_LOADED) {
                    CFE_TBL_ReleaseAddress(LC_AppData.WptTblHandle);
                }
                break;
            }

            LC_Unsubscribe_Tlm();

            /* Release the table so table services can update it */
            CFE_TBL_ReleaseAddress(LC_AppData.WptTblHandle);

            /* Perform the actual update */
            CFE_TBL_Update(LC_AppData.WptTblHandle);

            /* If we don't get the address back here, something very bad and weird has happened */
            Status = CFE_TBL_GetAddress((void*)&wpttbl_ptr, LC_AppData.WptTblHandle);

            LC_Subscribe_Tlm();

            /* Release the table again now that we're done */
            CFE_TBL_ReleaseAddress(LC_AppData.WptTblHandle);
        }

    } while (TblStatus == CFE_TBL_INFO_VALIDATION_PENDING);
}

int32 LC_AppInit(void) {
    int32 Status = CFE_SUCCESS;

    CFE_ES_RegisterApp();

    /* Initialize app data */
    LC_AppData.LcEnabled = FALSE;
    LC_AppData.MsgPtr = 0;
    LC_AppData.CmdPipe = 0;
    LC_AppData.TlmPipe = 0;
    LC_AppData.SubscriptionCount = 0;

    CFE_PSP_MemSet((void*) &LC_AppData.Subscriptions, 0, sizeof(LC_AppData.Subscriptions));
    CFE_PSP_MemSet((void*) &LC_AppData.WatchpointUpdated, 0, sizeof(LC_AppData.WatchpointUpdated));
    CFE_PSP_MemSet((void*) &LC_AppData.ActionpointState, 0, sizeof(LC_AppData.ActionpointState));
    CFE_PSP_MemSet((void*) &LC_AppData.ActionpointEval, 0, sizeof(LC_AppData.ActionpointEval));
    CFE_PSP_MemSet((void*) &LC_AppData.ActionpointFailureCount, 0, sizeof(LC_AppData.ActionpointFailureCount));
    CFE_PSP_MemSet((void*) &LC_AppData.HkPacket, 0, sizeof(LC_HkPacket_t));

    /* Initialize event filters and register events */
    LC_AppData.EventFilters[0].EventID = LC_INIT_INF_EID;
    LC_AppData.EventFilters[0].Mask = CFE_EVS_NO_FILTER;
    LC_AppData.EventFilters[1].EventID = LC_NOOP_INF_EID;
    LC_AppData.EventFilters[1].Mask = CFE_EVS_NO_FILTER;
    LC_AppData.EventFilters[2].EventID = LC_COMMAND_ERR_EID;
    LC_AppData.EventFilters[2].Mask = CFE_EVS_NO_FILTER;
    LC_AppData.EventFilters[3].EventID = LC_COMMANDNOP_INF_EID;
    LC_AppData.EventFilters[3].Mask = CFE_EVS_NO_FILTER;
    LC_AppData.EventFilters[4].EventID = LC_COMMANDRST_INF_EID;
    LC_AppData.EventFilters[4].Mask = CFE_EVS_NO_FILTER;
    LC_AppData.EventFilters[5].EventID = LC_INVALID_MSGID_ERR_EID;
    LC_AppData.EventFilters[5].Mask = CFE_EVS_NO_FILTER;
    LC_AppData.EventFilters[6].EventID = LC_LEN_ERR_EID;
    LC_AppData.EventFilters[6].Mask = CFE_EVS_NO_FILTER;
    LC_AppData.EventFilters[7].EventID = LC_TLM_ERR_EID;
    LC_AppData.EventFilters[7].Mask = CFE_EVS_NO_FILTER;
    LC_AppData.EventFilters[8].EventID = LC_INIT_ERR_EID;
    LC_AppData.EventFilters[8].Mask = CFE_EVS_NO_FILTER;
    LC_AppData.EventFilters[9].EventID = LC_WPT_REG_ERR_EID;
    LC_AppData.EventFilters[9].Mask = CFE_EVS_NO_FILTER;
    LC_AppData.EventFilters[10].EventID = LC_WPT_LOAD_ERR_EID;
    LC_AppData.EventFilters[10].Mask = CFE_EVS_NO_FILTER;
    LC_AppData.EventFilters[11].EventID = LC_APT_REG_ERR_EID;
    LC_AppData.EventFilters[11].Mask = CFE_EVS_NO_FILTER;
    LC_AppData.EventFilters[12].EventID = LC_APT_LOAD_ERR_EID;
    LC_AppData.EventFilters[12].Mask = CFE_EVS_NO_FILTER;
    LC_AppData.EventFilters[13].EventID = LC_CREATE_PIPE_ERR_EID;
    LC_AppData.EventFilters[13].Mask = CFE_EVS_NO_FILTER;
    LC_AppData.EventFilters[14].EventID = LC_SUBSCRIBE_ERR_EID;
    LC_AppData.EventFilters[14].Mask = CFE_EVS_NO_FILTER;
    LC_AppData.EventFilters[15].EventID = LC_UNSUBSCRIBE_ERR_EID;
    LC_AppData.EventFilters[15].Mask = CFE_EVS_NO_FILTER;
    LC_AppData.EventFilters[16].EventID = LC_MANAGE_TBL_ERR_EID;
    LC_AppData.EventFilters[16].Mask = CFE_EVS_NO_FILTER;
    LC_AppData.EventFilters[17].EventID = LC_ACQ_PTR_ERR_EID;
    LC_AppData.EventFilters[17].Mask = CFE_EVS_NO_FILTER;

    Status = CFE_EVS_Register(LC_AppData.EventFilters,
            sizeof(LC_AppData.EventFilters) / sizeof(LC_AppData.EventFilters[0]),
            CFE_EVS_BINARY_FILTER);
    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog("LC: Error registering events, RC = 0x%08X\n", Status);
        return Status;
    }

    /* Initialize housekeeping */
    LC_ResetCounters();

    /* Register and load watchpoint table */
    Status = CFE_TBL_Register(&LC_AppData.WptTblHandle, LC_WDT_NAME, sizeof(LC_WatchpointDefinitionTable_t),
    CFE_TBL_OPT_DEFAULT, LC_WatchpointTblValidationFunc);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(LC_WPT_REG_ERR_EID, CFE_EVS_ERROR, "LC: Can't register watchpoint table, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_TBL_Load(LC_AppData.WptTblHandle, CFE_TBL_SRC_FILE, LC_WDT_FILENAME);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(LC_WPT_LOAD_ERR_EID, CFE_EVS_ERROR, "LC: Can't load watchpoint table, RC=0x%08X", Status);
        return Status;
    }

    /* Register and load actionpoint table */
    Status = CFE_TBL_Register(&LC_AppData.AptTblHandle, LC_ADT_NAME, sizeof(LC_ActionpointDefinitionTable_t),
    CFE_TBL_OPT_DEFAULT, LC_ActionpointTblValidationFunc);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(LC_APT_REG_ERR_EID, CFE_EVS_ERROR, "LC: Can't register actionpoint table, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_TBL_Load(LC_AppData.AptTblHandle, CFE_TBL_SRC_FILE, LC_ADT_FILENAME);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(LC_APT_LOAD_ERR_EID, CFE_EVS_ERROR, "LC: Can't load actionpoint table, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_TBL_Manage(LC_AppData.WptTblHandle);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(LC_MANAGE_TBL_ERR_EID, CFE_EVS_ERROR, "LC: Can't manage wp table, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_TBL_Manage(LC_AppData.AptTblHandle);
    if (Status != CFE_SUCCESS && Status != CFE_TBL_INFO_UPDATED) {
        CFE_EVS_SendEvent(LC_MANAGE_TBL_ERR_EID, CFE_EVS_ERROR, "LC: Can't manage ap table, RC=0x%08X", Status);
        return Status;
    }

    Status = LC_Init_Actionpoints();
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(LC_APT_REG_ERR_EID, CFE_EVS_ERROR, "LC: Can't init actionpoint table, RC=0x%08X", Status);
        return Status;
    }

    /* Create command pipe and subscribe to its messages */
    Status = CFE_SB_CreatePipe(&LC_AppData.CmdPipe, LC_CMD_PIPE_DEPTH, "LC_CMD_PIPE");
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(LC_CREATE_PIPE_ERR_EID, CFE_EVS_ERROR, "LC: Can't create command pipe, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(LC_CMD_MID, LC_AppData.CmdPipe);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(LC_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "LC: Error subscribing to LC_CMD_MID(0x%4X), RC=0x%08X",
                LC_CMD_MID, Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(LC_SEND_HK_MID, LC_AppData.CmdPipe);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(LC_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR,
                "LC: Error subscribing to LC_SEND_HK_MID(0x%4X), RC=0x%08X", LC_SEND_HK_MID, Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(LC_EVAL_WPAP_MID, LC_AppData.CmdPipe);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(LC_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR,
                "LC: Error subscribing to LC_EVAL_WPAP_MID(0x%4X), RC=0x%08X", LC_EVAL_WPAP_MID, Status);
        return Status;
    }

    /* Create telemetry pipe and subscribe to what's in the watchpoint table */
    Status = CFE_SB_CreatePipe(&LC_AppData.TlmPipe, LC_TLM_PIPE_DEPTH, "LC_TLM_PIPE");
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(LC_CREATE_PIPE_ERR_EID, CFE_EVS_ERROR, "LC: Can't create telemetry pipe, RC=0x%08X", Status);
        return Status;
    }

    Status = LC_Subscribe_Tlm();
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(LC_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR,
                "LC: Error subscribing, RC=0x%08X", Status);
        return Status;
    }

    CFE_EVS_SendEvent(LC_INIT_INF_EID, CFE_EVS_INFORMATION, "LC App Initialized. Version %d.%d.%d.%d",
    LC_MAJOR_VERSION, LC_MINOR_VERSION, LC_REVISION, LC_MISSION_REV);

    return CFE_SUCCESS;
} /* End of LC_AppInit() */

int32 LC_Init_Actionpoints(){
    LC_ActionpointDefinitionTable_t *apTblPtr = NULL;
    int32 Status = CFE_SUCCESS;

    Status = CFE_TBL_GetAddress((void*) &apTblPtr, LC_AppData.AptTblHandle);
    if (Status != CFE_SUCCESS && Status != CFE_TBL_INFO_UPDATED) {
        CFE_EVS_SendEvent(LC_ACQ_PTR_ERR_EID, CFE_EVS_ERROR,
                "LC: Error acquiring pointer to actionpoint table, RC=0x%08X", Status);
        return Status;
    }

    int ActionpointIndex = 0;

    for(ActionpointIndex = 0; ActionpointIndex < LC_MAX_ACTIONPOINTS; ActionpointIndex++){
        LC_AppData.ActionpointState[ActionpointIndex] = apTblPtr->actionpoints[ActionpointIndex].default_state;
    }

    CFE_TBL_ReleaseAddress(LC_AppData.AptTblHandle);

    if(Status == CFE_TBL_INFO_UPDATED){
        return CFE_SUCCESS;
    }else{
        CFE_EVS_SendEvent(LC_ACQ_PTR_ERR_EID, CFE_EVS_ERROR,
                "LC: Error releasing pointer to actionpoint table, RC=0x%08X", Status);
        return Status;
    }
}

