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
/******************************************************************************
 ** File: sch_task.c
 **
 ** Purpose:
 **   This module defines the top level of the Scheduler task.
 ** ******************************************************************************/

#include "cfe_error.h"
#include "cfe_time.h"
#include "cfe_tbl.h"
#include "cfe_evs.h"
#include "cfe_sb.h"
#include "cfe_es.h"

#include "app_msgids.h"
#include "app_perfids.h"

#include "sch_task.h"

/* Local Data Section */

SCH_AppData_t SCH_AppData;

CFE_EVS_BinFilter_t SCH_EventFilters[] = {
     /* Event ID            mask */
     {SCH_INIT_INF_EID,    CFE_EVS_NO_FILTER},
     {SCH_NOOP_INF_EID,    CFE_EVS_NO_FILTER},
     {SCH_RESET_INF_EID,   CFE_EVS_NO_FILTER},
     {SCH_MID_ERR_EID,     CFE_EVS_NO_FILTER},
     {SCH_CC_ERR_EID,      CFE_EVS_NO_FILTER},
     {SCH_LEN_ERR_EID,     CFE_EVS_NO_FILTER},
     {SCH_SLOT_ERR_EID,    CFE_EVS_NO_FILTER},
     {SCH_ENTRY_ERR_EID,   CFE_EVS_NO_FILTER},
     {SCH_TBL_GET_ERR_EID, CFE_EVS_NO_FILTER},
     {SCH_TBL_MOD_ERR_EID, CFE_EVS_NO_FILTER},
     {SCH_STATUS_ERR_EID,  CFE_EVS_NO_FILTER},
     {SCH_GROUP_ERR_EID,   CFE_EVS_NO_FILTER},
};

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                 */
/* SCH_TaskMain() -- Application entry point and main process loop */
/*                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

void SCH_TaskMain(void) {
    uint32  RunStatus = CFE_ES_APP_RUN;
    int32   status = CFE_SUCCESS;

    SCH_ScheduleTable_t *schedule_tbl_ptr = 0;
    SCH_MessageTable_t  *message_tbl_ptr  = 0;
    SCH_ScheduleEntry_t *current_entry = 0;

    uint16 next_frame = 0;
    uint16 i = 0;
    uint16 j = 0;
    uint16 slots_to_process = 1;

    CFE_ES_PerfLogEntry(SCH_MAIN_TASK_PERF_ID);

    status = SCH_Init();
    if (status != CFE_SUCCESS) {
        RunStatus = CFE_ES_APP_ERROR;
    }

    while (CFE_ES_RunLoop(&RunStatus) == TRUE)
    {
        CFE_ES_PerfLogExit(SCH_MAIN_TASK_PERF_ID);
        OS_BinSemTake(SCH_AppData.SemaphoreId);
        CFE_ES_PerfLogEntry(SCH_MAIN_TASK_PERF_ID);

        next_frame = (SCH_AppData.MinorFrame+1) % (SCH_TOTAL_SLOTS);

        /* Calculate the next frame */
        if (next_frame == 0) {
            /* The Slot Formerly Known As The Reserved Slot */

            /* Extend the timer so we'll hopefully get the expected major frame */
            if (SCH_AppData.IgnoreMajorFrame == FALSE) {
                OS_TimerSet(SCH_AppData.TimerId, SCH_TIMER_USEC+SCH_SYNC_SLOT_DRIFT_WINDOW, SCH_TIMER_USEC);
            }
            /* Process some command packets before moving on */
            SCH_ProcessCommandPackets();
        }

        /* Check to see if we woke up in the same slot as last time */
        if (SCH_AppData.LastSlot == SCH_AppData.CurrentSlot) {
            SCH_AppData.HkPacket.same_slot_count++;
        }
        SCH_AppData.LastSlot = SCH_AppData.CurrentSlot;

        /* Check if we need to catch up, and if so, by how much */
        if (SCH_AppData.CurrentSlot != SCH_AppData.MinorFrame) {
            uint16 frame_difference = (SCH_TOTAL_SLOTS + next_frame - SCH_AppData.CurrentSlot) % SCH_TOTAL_SLOTS;
            if (SCH_AppData.CatchUpCount < SCH_MAX_LAG_COUNT) {
                uint16 max_allowed = SCH_MAX_LAG_COUNT - SCH_AppData.CatchUpCount;
                max_allowed = (max_allowed > SCH_MAX_SLOTS_PER_WAKEUP) ? SCH_MAX_SLOTS_PER_WAKEUP : max_allowed;
                slots_to_process = (frame_difference > max_allowed) ? max_allowed : frame_difference;
                SCH_AppData.HkPacket.multi_slot_count++;

                if (slots_to_process == frame_difference) {
                    SCH_AppData.CatchUpCount = 0;
                } else {
                    SCH_AppData.CatchUpCount += slots_to_process;
                }
            } else {
                /* We've gone over the lag count, skip the rest of the slots */
                SCH_AppData.CurrentSlot = SCH_AppData.MinorFrame;
                SCH_AppData.CatchUpCount = 0;
                slots_to_process = 1;
                SCH_AppData.HkPacket.skip_slot_count++;
            }
        } else {
            slots_to_process = 1;
        }

        /* Get the current addresses of the tables */
        CFE_TBL_GetAddress((void*)&schedule_tbl_ptr, SCH_AppData.ScheduleTblHandle);
        CFE_TBL_GetAddress((void*)&message_tbl_ptr, SCH_AppData.MessageTblHandle);

        for (j = 0; j < slots_to_process; j++) {
            for (i = 0; i < SCH_ENTRIES_PER_SLOT; i++) {
                /* Get a pointer to the current entry to simplify accessing it */
                current_entry = &(schedule_tbl_ptr->slots[SCH_AppData.CurrentSlot][i]);

                if (current_entry->enable_state == SCH_ENABLED) {
                    if (current_entry->remainder == 0) {
                        current_entry->remainder = current_entry->period-1;

                        /* Currently we only know how to send messages... */
                        if (current_entry->type == SCH_ACTIVITY_SEND_MSG) {
                            status = CFE_SB_SendMsg((CFE_SB_MsgPtr_t)&message_tbl_ptr->msg_buffer[current_entry->msg_index]);
                            if (status == CFE_SUCCESS) {
                                SCH_AppData.HkPacket.act_success_count++;
                            } else {
                                SCH_AppData.HkPacket.act_failure_count++;
                            }
                        }
                    } else {
                        current_entry->remainder--;
                    }
                }
            }
            SCH_AppData.CurrentSlot = (SCH_AppData.CurrentSlot + 1) % SCH_TOTAL_SLOTS;
        }

        /* Release our holds on the tables */
        CFE_TBL_ReleaseAddress(SCH_AppData.MessageTblHandle);
        CFE_TBL_ReleaseAddress(SCH_AppData.ScheduleTblHandle);

        SCH_AppData.MinorFrame = next_frame;
        SCH_AppData.LastSlot = SCH_AppData.CurrentSlot;
        SCH_AppData.CurrentSlot = next_frame;
    }

    CFE_ES_PerfLogExit(SCH_MAIN_TASK_PERF_ID);

    CFE_ES_ExitApp(RunStatus);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                 */
/* SCH_Init() -- SCH initialization                                */
/*                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int32 SCH_Init(void) {
    uint32 clock_accuracy = 0;
    int32 status = CFE_SUCCESS;

    CFE_ES_RegisterApp();

    /* Initialize App Data */
    SCH_AppData.CommandPipe = 0;
    SCH_AppData.MsgPtr = NULL;

    SCH_AppData.MinorFrame = 0;
    SCH_AppData.CurrentSlot = 0;
    SCH_AppData.LastSlot = SCH_TOTAL_SLOTS-1;

    SCH_AppData.CatchUpCount = 0;
    SCH_AppData.NoisyMajorFrameCount = 0;

    SCH_AppData.IgnoreMajorFrame = FALSE;

    CFE_EVS_Register(SCH_EventFilters, sizeof(SCH_EventFilters)/sizeof(CFE_EVS_BinFilter_t), CFE_EVS_BINARY_FILTER);

    /* Create the command pipe and subscribe it to SCH's command messages */
    CFE_SB_CreatePipe(&SCH_AppData.CommandPipe, SCH_PIPE_DEPTH, "SCH_CMD_PIPE");
    CFE_SB_Subscribe(SCH_CMD_MID, SCH_AppData.CommandPipe);
    CFE_SB_Subscribe(SCH_SEND_HK_MID, SCH_AppData.CommandPipe);

    /* Initialize telemetry packets */
    SCH_ResetCounters();
    CFE_SB_InitMsg(&SCH_AppData.HkPacket, SCH_HK_TLM_MID, sizeof(SCH_HkPacket_t), TRUE);
    CFE_SB_InitMsg(&SCH_AppData.DiagPacket, SCH_DIAG_TLM_MID, sizeof(SCH_DiagPacket_t), TRUE);

    /* Register and load the tables */
    status = CFE_TBL_Register(&SCH_AppData.ScheduleTblHandle, "schedule_tbl", sizeof(SCH_ScheduleTable_t), CFE_TBL_OPT_DEFAULT, SCH_ScheduleTblValidationFunc);
    if (status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog("SCH: Error registering schedule table, RC = 0x%08X\n", status);
        return status;
    } else {
        CFE_TBL_Load(SCH_AppData.ScheduleTblHandle, CFE_TBL_SRC_FILE, SCH_SCHEDULE_FILENAME);
        CFE_TBL_Manage(SCH_AppData.ScheduleTblHandle);
    }

    status = CFE_TBL_Register(&SCH_AppData.MessageTblHandle, "message_tbl", sizeof(SCH_MessageTable_t), CFE_TBL_OPT_DEFAULT, SCH_MessageTblValidationFunc);
    if (status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog("SCH: Error registering message table, RC = 0x%08X\n", status);
        return status;
    } else {
        CFE_TBL_Load(SCH_AppData.MessageTblHandle, CFE_TBL_SRC_FILE, SCH_MESSAGE_FILENAME);
        CFE_TBL_Manage(SCH_AppData.MessageTblHandle);
    }

    /* Make the semaphore used for scheduling timing */
    OS_BinSemCreate(&SCH_AppData.SemaphoreId, "SCH_TimingSemaphore", OS_SEM_EMPTY, 0);

    /* Set up the time callbacks */
    OS_TimerCreate(&SCH_AppData.TimerId, "SCH_App_Timer", &clock_accuracy, SCH_Timer_Callback);
    /* Schedule the timer with a longer startup period to wait for the first major frame sync */

    CFE_TIME_RegisterSynchCallback(SCH_1Hz_Callback);

    /* Since we're making a timer cFE doesn't know about, we need to use a callback to manually delete it */
    OS_TaskInstallDeleteHandler((void *)&SCH_Delete_Callback);

    CFE_ES_WaitForStartupSync(SCH_STARTUP_SYNC_TIMEOUT);
    CFE_EVS_SendEvent(SCH_INIT_INF_EID, CFE_EVS_INFORMATION, "SCH app initialized.");

    OS_TimerSet(SCH_AppData.TimerId, SCH_STARTUP_PERIOD, SCH_TIMER_USEC);

    return CFE_SUCCESS;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                             */
/* SCH_Delete_callback() -- Callback for cleaning up in case of task deletion  */
/*                                                                             */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

void SCH_Delete_Callback(void) {
    OS_TimerDelete(SCH_AppData.TimerId);
    OS_BinSemDelete(SCH_AppData.SemaphoreId);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                 */
/* SCH_1Hz_callback() -- Callback for the 1Hz sync signal          */
/*                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int32 SCH_1Hz_Callback(void) {
    if (SCH_AppData.IgnoreMajorFrame == FALSE) {
        OS_TimerSet(SCH_AppData.TimerId, SCH_TIMER_USEC, SCH_TIMER_USEC);
        SCH_AppData.HkPacket.last_sync_met_slot = SCH_AppData.MinorFrame;
        SCH_AppData.HkPacket.minor_since_tone_count = 0;

        if (SCH_AppData.MinorFrame != 0) {
            /* Unexpected major frame -- sync anyways, but make note and maybe stop listening */
            SCH_AppData.MinorFrame = 0;
            SCH_AppData.NoisyMajorFrameCount++;

            if (SCH_AppData.NoisyMajorFrameCount >= SCH_MAX_NOISY_MF) {
                OS_printf("SCH: IGNORING MAJOR FRAMES\n");
                SCH_AppData.IgnoreMajorFrame = TRUE;
                SCH_AppData.NoisyMajorFrameCount = 0;
            }

            SCH_AppData.HkPacket.unexpected_major_frame = 1;
            SCH_AppData.HkPacket.unexpected_major_frame_count++;

        } else {
            /* Valid major frame */
            SCH_AppData.NoisyMajorFrameCount = 0;
            SCH_AppData.HkPacket.valid_major_frame_count++;
            SCH_AppData.HkPacket.unexpected_major_frame = 0;
        }
        OS_BinSemGive(SCH_AppData.SemaphoreId);
    }
    return 1;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                 */
/* SCH_Timer_callback() -- Callback for the timer sync signal      */
/*                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

void SCH_Timer_Callback(uint32 timer_id) {
    SCH_AppData.HkPacket.minor_since_tone_count++;

    if (SCH_AppData.MinorFrame == 0 && SCH_AppData.IgnoreMajorFrame == FALSE) {
        /* Missing major frame -- reschedule the timer to make up for the drift window */
        OS_TimerSet(SCH_AppData.TimerId, SCH_TIMER_USEC-SCH_SYNC_SLOT_DRIFT_WINDOW, SCH_TIMER_USEC);
        SCH_AppData.HkPacket.missing_major_frame_count++;
    }
    OS_BinSemGive(SCH_AppData.SemaphoreId);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                 */
/* SCH_ProcessCommandPackets() -- Process command pipe message     */
/*                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

void SCH_ProcessCommandPackets(void) {
    CFE_SB_MsgId_t MsgId;
    int32 status = 0;
    uint32 i = 0;

    for (i = 0; i < SCH_PIPE_DEPTH; i++) {
        status = CFE_SB_RcvMsg(&SCH_AppData.MsgPtr, SCH_AppData.CommandPipe, CFE_SB_POLL);
        if (status == CFE_SUCCESS) {
            MsgId = CFE_SB_GetMsgId(SCH_AppData.MsgPtr);

            switch (MsgId) {
                case SCH_CMD_MID:
                    SCH_ProcessGroundCommand();
                    break;
                case SCH_SEND_HK_MID:
                    SCH_ReportHousekeeping();
                    break;
                default:
                    CFE_EVS_SendEvent(SCH_MID_ERR_EID, CFE_EVS_ERROR, "SCH: invalid command packet, MID = 0x%04x", MsgId);
                    SCH_AppData.HkPacket.command_error_count++;
                    break;
            }
        } else {
            break;
        }
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                 */
/*  SCH_ProcessGroundCommand() -- Process ground message           */
/*                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

void SCH_ProcessGroundCommand(void) {
    uint16 CommandCode;

    CommandCode = CFE_SB_GetCmdCode(SCH_AppData.MsgPtr);

    switch (CommandCode) {
        case SCH_NOOP_CC:
            SCH_NoopCmd();
            break;

        case SCH_RESETCTRS_CC:
            SCH_ResetCmd();
            break;

        case SCH_ENABLEENTRY_CC:
            SCH_SetEntryStateCmd(SCH_ENABLED);
            break;

        case SCH_DISABLEENTRY_CC:
            SCH_SetEntryStateCmd(SCH_DISABLED);
            break;

        case SCH_ENABLEGROUP_CC:
            SCH_SetGroupStateCmd(SCH_ENABLED);
            break;

        case SCH_DISABLEGROUP_CC:
            SCH_SetGroupStateCmd(SCH_DISABLED);
            break;

        case SCH_ENABLESYNC_CC:
            SCH_EnableSyncCmd();
            break;

        case SCH_SENDDIAG_CC:
            SCH_SendDiagCmd();
            break;

        default:
            SCH_AppData.HkPacket.command_error_count++;
            CFE_EVS_SendEvent(SCH_CC_ERR_EID, CFE_EVS_ERROR, "SCH: invalid command packet, CC = 0x%02x", CommandCode);
            break;
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                 */
/* SCH_NoopCmd() -- SCH task ground command (NOOP)                 */
/*                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

void SCH_NoopCmd(void) {
    uint16 ExpectedLength = sizeof(SCH_NoArgsCmd_t);

    if (SCH_VerifyCmdLength(SCH_AppData.MsgPtr, ExpectedLength)) {
        CFE_EVS_SendEvent(SCH_NOOP_INF_EID, CFE_EVS_INFORMATION, "SCH: NOOP command");
        SCH_AppData.HkPacket.command_count++;
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                 */
/* SCH_ResetCmd() -- SCH task ground command (Reset)               */
/*                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

void SCH_ResetCmd(void) {
    uint16 ExpectedLength = sizeof(SCH_NoArgsCmd_t);

    if (SCH_VerifyCmdLength(SCH_AppData.MsgPtr, ExpectedLength)) {
        SCH_ResetCounters();
        CFE_EVS_SendEvent(SCH_RESET_INF_EID, CFE_EVS_INFORMATION, "SCH: RESET command");
        SCH_AppData.HkPacket.command_count++;
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                           */
/* SCH_SetEntryStateCmd() -- SCH task ground command (Enable/Disable Entry)  */
/*                                                                           */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

void SCH_SetEntryStateCmd(uint8 CommandedState) {
    uint16 ExpectedLength = sizeof(SCH_EntryCmd_t);

    if (SCH_VerifyCmdLength(SCH_AppData.MsgPtr, ExpectedLength)) {
        SCH_EntryCmd_t *cmd = (SCH_EntryCmd_t*)SCH_AppData.MsgPtr;
        uint8 RequiredState = SCH_DISABLED;
        char *CommandName = 0;

        if (CommandedState == SCH_ENABLED) {
            CommandName = "Enable";
            RequiredState = SCH_DISABLED;
        } else {
            CommandName = "Disable";
            RequiredState = SCH_ENABLED;
        }

        /* First check for a valid slot+entry combo */
        if (cmd->slot_number >= SCH_TOTAL_SLOTS) {
            SCH_AppData.HkPacket.command_error_count++;
            CFE_EVS_SendEvent(SCH_SLOT_ERR_EID, CFE_EVS_ERROR, "SCH %s entry: slot number is too big: %u", CommandName, cmd->slot_number);
        } else if (cmd->entry_number >= SCH_ENTRIES_PER_SLOT) {
            SCH_AppData.HkPacket.command_error_count++;
            CFE_EVS_SendEvent(SCH_ENTRY_ERR_EID, CFE_EVS_ERROR, "SCH %s entry: entry number is too big: %u", CommandName, cmd->entry_number);
        } else {
            int32 status = CFE_SUCCESS;
            SCH_ScheduleTable_t *schedule_tbl_ptr = 0;
            SCH_ScheduleEntry_t *entry_ptr = 0;

            /* Everything looks good so far, so try to get access to the schedule table */
            status = CFE_TBL_GetAddress((void*)&schedule_tbl_ptr, SCH_AppData.ScheduleTblHandle);

            if (status == CFE_SUCCESS || status == CFE_TBL_INFO_UPDATED) {
                entry_ptr = &schedule_tbl_ptr->slots[cmd->slot_number][cmd->entry_number];

                /* Make sure we're trying to enable something that can be enabled */
                if (entry_ptr->enable_state == RequiredState) {
                    entry_ptr->enable_state = CommandedState;
                    status = CFE_TBL_Modified(SCH_AppData.ScheduleTblHandle);
                    /* CFE_TBL_Modified should by this point not fail, but it doesn't hurt to be sure */
                    if (status == CFE_SUCCESS) {
                        SCH_AppData.HkPacket.command_count++;
                    } else {
                        SCH_AppData.HkPacket.command_error_count++;
                        CFE_EVS_SendEvent(SCH_TBL_MOD_ERR_EID, CFE_EVS_ERROR, "SCH %s entry: schedule table modification failed: error = %08X", CommandName, status);
                    }
                } else {
                    SCH_AppData.HkPacket.command_error_count++;
                    CFE_EVS_SendEvent(SCH_STATUS_ERR_EID, CFE_EVS_ERROR, "SCH %s entry: slot %u, entry %u has incorrect state: enable_state = %02u", CommandName, cmd->slot_number, cmd->entry_number, entry_ptr->enable_state);
                }

                CFE_TBL_ReleaseAddress(SCH_AppData.ScheduleTblHandle);

            } else {
                SCH_AppData.HkPacket.command_error_count++;
                CFE_EVS_SendEvent(SCH_TBL_GET_ERR_EID, CFE_EVS_ERROR, "SCH %s entry: schedule table address get failed: error = %08X", CommandName, status);

                /* This particular failure code gives back a valid table pointer that needs to be released */
                if (status == CFE_TBL_ERR_NEVER_LOADED) {
                    CFE_TBL_ReleaseAddress(SCH_AppData.ScheduleTblHandle);
                }
            }
        }
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                 */
/* SCH_EnableGroupCmd() -- SCH task ground command (Enable Group)  */
/*                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

void SCH_SetGroupStateCmd(uint8 CommandedState) {
    uint16 ExpectedLength = sizeof(SCH_GroupCmd_t);

    if (SCH_VerifyCmdLength(SCH_AppData.MsgPtr, ExpectedLength)) {
        SCH_GroupCmd_t *cmd = (SCH_GroupCmd_t*)SCH_AppData.MsgPtr;
        SCH_ScheduleTable_t *schedule_tbl_ptr = 0;
        int32 status = CFE_SUCCESS;
        uint8 RequiredState = SCH_DISABLED;
        char *CommandName = 0;

        /* Determine required information for updating and giving events */
        if (CommandedState == SCH_ENABLED) {
            CommandName = "Enable";
            RequiredState = SCH_DISABLED;
        } else {
            CommandName = "Disable";
            RequiredState = SCH_ENABLED;
        }

        status = CFE_TBL_GetAddress((void*)&schedule_tbl_ptr, SCH_AppData.ScheduleTblHandle);

        if (status == CFE_SUCCESS || status == CFE_TBL_INFO_UPDATED) {
            uint16 i = 0;
            uint16 j = 0;

            uint16 entries_changed = 0;
            uint16 group_count = 0;

            /* Go through each entry, recording total group number and total changed number */
            for (j = 0; j < SCH_TOTAL_SLOTS; j++) {
                for (i = 0; i < SCH_ENTRIES_PER_SLOT; i++) {
                    SCH_ScheduleEntry_t *entry_ptr = &schedule_tbl_ptr->slots[j][i];

                    if (entry_ptr->group_data == cmd->group_data) {
                        group_count++;
                        if (entry_ptr->enable_state == RequiredState) {
                            entry_ptr->enable_state = CommandedState;
                            entries_changed++;
                        }
                    }
                }
            }

            if (group_count == 0) { /* Does the group even exist? */
                SCH_AppData.HkPacket.command_error_count++;
                CFE_EVS_SendEvent(SCH_GROUP_ERR_EID, CFE_EVS_ERROR, "SCH %s group: no such group: %u", CommandName, cmd->group_data);
            } else {
                if (entries_changed == 0) { /* If we didn't change anything, succeed but notify */
                    SCH_AppData.HkPacket.command_count++;
                    CFE_EVS_SendEvent(SCH_GROUP_INF_EID, CFE_EVS_INFORMATION, "SCH %s group: no group members needed change", CommandName);
                } else { /* Mark table modified and verify sucess */
                    status = CFE_TBL_Modified(SCH_AppData.ScheduleTblHandle);
                    if (status == CFE_SUCCESS) {
                        SCH_AppData.HkPacket.command_count++;
                    } else {
                        SCH_AppData.HkPacket.command_error_count++;
                        CFE_EVS_SendEvent(SCH_TBL_MOD_ERR_EID, CFE_EVS_ERROR, "SCH %s group: schedule table modification failed: error = %08X", CommandName, status);
                    }
                }
            }
            CFE_TBL_ReleaseAddress(SCH_AppData.ScheduleTblHandle);
        } else {
            SCH_AppData.HkPacket.command_error_count++;
            CFE_EVS_SendEvent(SCH_TBL_GET_ERR_EID, CFE_EVS_ERROR, "SCH %s group: schedule table address get failed: error = %08X", CommandName, status);

            /* This particular failure code gives back a valid table pointer that needs to be released */
            if (status == CFE_TBL_ERR_NEVER_LOADED) {
                CFE_TBL_ReleaseAddress(SCH_AppData.ScheduleTblHandle);
            }
        }
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                 */
/* SCH_EnableSyncCmd() -- SCH task ground command (Enable sync)    */
/*                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

void SCH_EnableSyncCmd(void) {
    uint16 ExpectedLength = sizeof(SCH_NoArgsCmd_t);

    if (SCH_VerifyCmdLength(SCH_AppData.MsgPtr, ExpectedLength)) {
        SCH_AppData.IgnoreMajorFrame = FALSE;
        SCH_AppData.HkPacket.command_count++;
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                 */
/* SCH_SendDiagCmd() -- SCH task ground command (Send Diagnostics) */
/*                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

void SCH_SendDiagCmd(void) {
    uint16 ExpectedLength = sizeof(SCH_NoArgsCmd_t);

    if (SCH_VerifyCmdLength(SCH_AppData.MsgPtr, ExpectedLength)) {
        SCH_ScheduleTable_t *schedule_tbl_ptr = 0;
        SCH_MessageTable_t *message_tbl_ptr = 0;
        uint16 i = 0;
        uint16 j = 0;
        uint32 status = CFE_SUCCESS;

        status = CFE_TBL_GetAddress((void*)&schedule_tbl_ptr, SCH_AppData.ScheduleTblHandle);

        if (status != CFE_SUCCESS && status != CFE_TBL_INFO_UPDATED) {
            SCH_AppData.HkPacket.command_error_count++;
            CFE_EVS_SendEvent(SCH_TBL_GET_ERR_EID, CFE_EVS_ERROR, "SCH send diag: schedule table address get failed: error = %08X", status);

            /* This particular failure code gives back a valid table pointer that needs to be released */
            if (status == CFE_TBL_ERR_NEVER_LOADED) {
                CFE_TBL_ReleaseAddress(SCH_AppData.ScheduleTblHandle);
            }

            return;
        }

        status = CFE_TBL_GetAddress((void*)&message_tbl_ptr, SCH_AppData.MessageTblHandle);

        if (status != CFE_SUCCESS && status != CFE_TBL_INFO_UPDATED) {
            SCH_AppData.HkPacket.command_error_count++;
            CFE_EVS_SendEvent(SCH_TBL_GET_ERR_EID, CFE_EVS_ERROR, "SCH send diag: message table address get failed: error = %08X", status);

            /* This particular failure code gives back a valid table pointer that needs to be released */
            if (status == CFE_TBL_ERR_NEVER_LOADED) {
                CFE_TBL_ReleaseAddress(SCH_AppData.MessageTblHandle);
            }

            return;
        }

        for (j = 0; j < SCH_TOTAL_SLOTS; j++) {
            for (i = 0; i < SCH_ENTRIES_PER_SLOT; i++) {
                SCH_ScheduleEntry_t *entry_ptr = &schedule_tbl_ptr->slots[j][i];
                uint16 index = SCH_ENTRIES_PER_SLOT*j + i;
                SCH_AppData.DiagPacket.entry_states[index] = entry_ptr->enable_state;
                SCH_AppData.DiagPacket.msgids[index] = message_tbl_ptr->msg_buffer[entry_ptr->msg_index][0]<<8 | message_tbl_ptr->msg_buffer[entry_ptr->msg_index][1];
            }
        }

        CFE_TBL_ReleaseAddress(SCH_AppData.MessageTblHandle);
        CFE_TBL_ReleaseAddress(SCH_AppData.ScheduleTblHandle);

        CFE_SB_TimeStampMsg((CFE_SB_Msg_t *) &SCH_AppData.DiagPacket);
        CFE_SB_SendMsg((CFE_SB_Msg_t *)&SCH_AppData.DiagPacket);

        SCH_AppData.HkPacket.command_count++;
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                   */
/*  SCH_VerifyCmdLength() -- Verifies the length of command packets  */
/*                                                                   */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

boolean SCH_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength) {
    boolean result = TRUE;
    uint16  ActualLength = CFE_SB_GetTotalMsgLength(Msg);

    if (ExpectedLength != ActualLength) {
        CFE_SB_MsgId_t MessageID = CFE_SB_GetMsgId(Msg);
        uint16 CommandCode = CFE_SB_GetCmdCode(Msg);

        CFE_EVS_SendEvent(SCH_LEN_ERR_EID, CFE_EVS_ERROR,
           "SCH: Invalid cmd length: ID = 0x%04X, CC = %02u, Exp Len = %u, Len = %u",
                          MessageID, CommandCode, ExpectedLength, ActualLength);
        result = FALSE;
        SCH_AppData.HkPacket.command_error_count++;
    }
    return result;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                 */
/* SCH_ReportHousekeeping() -- Send out the Hk packet              */
/*                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

void SCH_ReportHousekeeping(void) {
    /* Manage our tables -- this is usually done while reporting housekeeping */
    CFE_TBL_Manage(SCH_AppData.ScheduleTblHandle);
    CFE_TBL_Manage(SCH_AppData.MessageTblHandle);

    SCH_AppData.HkPacket.next_slot = SCH_AppData.CurrentSlot;
    SCH_AppData.HkPacket.ignore_major_frame = SCH_AppData.IgnoreMajorFrame;
    SCH_AppData.HkPacket.sync_to_MET = !SCH_AppData.IgnoreMajorFrame;
    SCH_AppData.HkPacket.major_frame_source = 0;

    CFE_SB_TimeStampMsg((CFE_SB_Msg_t *) &SCH_AppData.HkPacket);
    CFE_SB_SendMsg((CFE_SB_Msg_t *)&SCH_AppData.HkPacket);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                 */
/* SCH_ResetCounters() -- Reset counters                           */
/*                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

void SCH_ResetCounters(void) {
    SCH_AppData.HkPacket.command_count = 0;
    SCH_AppData.HkPacket.command_error_count = 0;
    SCH_AppData.HkPacket.act_success_count = 0;
    SCH_AppData.HkPacket.act_failure_count = 0;
    SCH_AppData.HkPacket.slot_proc_count = 0;
    SCH_AppData.HkPacket.skip_slot_count = 0;
    SCH_AppData.HkPacket.multi_slot_count = 0;
    SCH_AppData.HkPacket.same_slot_count = 0;
    SCH_AppData.HkPacket.bad_tbl_data_count = 0;
    SCH_AppData.HkPacket.tbl_pass_verify_count = 0;
    SCH_AppData.HkPacket.tbl_fail_verify_count = 0;
    SCH_AppData.HkPacket.tbl_proc_count = 0;
    SCH_AppData.HkPacket.valid_major_frame_count = 0;
    SCH_AppData.HkPacket.missing_major_frame_count = 0;
    SCH_AppData.HkPacket.unexpected_major_frame_count = 0;
    SCH_AppData.HkPacket.minor_since_tone_count = 0;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                 */
/* SCH_ScheduleTblValidationFunc() -- Validates the Schedule table */
/*                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int32 SCH_ScheduleTblValidationFunc(void* buffer) {
    int32 status = CFE_SUCCESS;
    SCH_ScheduleTable_t *schedule_tbl_ptr = (SCH_ScheduleTable_t*)buffer;
    SCH_ScheduleEntry_t *entry_ptr = 0;
    uint32 i = 0;
    uint32 j = 0;

    for (j = 0; j < SCH_TOTAL_SLOTS; j++) {
        for (i = 0; i < SCH_ENTRIES_PER_SLOT; i++) {
            entry_ptr = &schedule_tbl_ptr->slots[j][i];

            if (entry_ptr->enable_state > SCH_DISABLED) {
                status = SCH_SCHEDULE_STATE_ERR;
            }

            if (entry_ptr->enable_state != SCH_UNUSED) {
                if (entry_ptr->type > SCH_ACTIVITY_SEND_MSG) {
                    status = SCH_SCHEDULE_ACTIVITY_ERR;
                }

                if (entry_ptr->remainder >= entry_ptr->period) {
                    status = SCH_SCHEDULE_RMNDR_ERR;
                }

                if (entry_ptr->msg_index >= SCH_MAX_MESSAGE) {
                    status = SCH_SCHEDULE_MSG_INDEX_ERR;
                }
            }
        }
    }

    if (status == CFE_SUCCESS) {
        SCH_AppData.HkPacket.tbl_pass_verify_count++;
    } else {
        SCH_AppData.HkPacket.tbl_fail_verify_count++;
    }

    return status;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                 */
/* SCH_MessageTblValidationFunc() -- Validates the Message table   */
/*                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int32 SCH_MessageTblValidationFunc(void* buffer) {
    int32 status = CFE_SUCCESS;
    SCH_MessageTable_t *message_tbl_ptr = (SCH_MessageTable_t*)buffer;
    uint32 i = 0;
    uint32 j = 0;
    uint8 *message_buf = 0;

    for (i = 0; i < SCH_MAX_MESSAGE; i++) {
        CFE_SB_MsgId_t msgid;

        message_buf = message_tbl_ptr->msg_buffer[i];
        msgid = message_buf[0]<<8 | message_buf[1];

        if (msgid > SCH_UNUSED_MID) { /* Check for invalid MSGIDs */
            status = SCH_MESSAGE_MID_ERR;
            break;
        }
        else if (msgid == 0) { /* Check for an empty row */
            for (j = 2; j < SCH_MAX_MSG_WORDS*2; j++) {
                if (message_buf[j] != 0) {
                    break;
                }
            }
            if (j == SCH_MAX_MSG_WORDS*2) {
                status = SCH_MESSAGE_EMPTY_ROW_ERR;
                break;
            }
        }
        else if (msgid < SCH_UNUSED_MID) { /* Validate checksum for each message */
            if (CFE_SB_ValidateChecksum((CFE_SB_MsgPtr_t)message_buf) == FALSE) {
                status = SCH_MESSAGE_CHECKSUM_ERR;
                break;
            }
        }
    }

    if (status == CFE_SUCCESS) {
        SCH_AppData.HkPacket.tbl_pass_verify_count++;
    } else {
        SCH_AppData.HkPacket.tbl_fail_verify_count++;
    }

    return status;
}

/************************/
/*  End of File Comment */
/************************/
