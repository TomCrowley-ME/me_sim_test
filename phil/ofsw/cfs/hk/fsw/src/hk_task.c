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

#include "hk_task.h"

HK_AppData_t HK_AppData;

static uint32 HK_MemPoolDefSize[CFE_ES_MAX_MEMPOOL_BLOCK_SIZES] = {
    HK_MAX_BLOCK_SIZE,
    HK_MEM_BLOCK_SIZE_16,
    HK_MEM_BLOCK_SIZE_15,
    HK_MEM_BLOCK_SIZE_14,
    HK_MEM_BLOCK_SIZE_13,
    HK_MEM_BLOCK_SIZE_12,
    HK_MEM_BLOCK_SIZE_11,
    HK_MEM_BLOCK_SIZE_10,
    HK_MEM_BLOCK_SIZE_09,
    HK_MEM_BLOCK_SIZE_08,
    HK_MEM_BLOCK_SIZE_07,
    HK_MEM_BLOCK_SIZE_06,
    HK_MEM_BLOCK_SIZE_05,
    HK_MEM_BLOCK_SIZE_04,
    HK_MEM_BLOCK_SIZE_03,
    HK_MEM_BLOCK_SIZE_02,
    HK_MEM_BLOCK_SIZE_01,
};

void HK_TaskMain(void) {
    uint32 RunStatus = CFE_ES_APP_RUN;
    int32  Status = CFE_SUCCESS;

    CFE_ES_PerfLogEntry(HK_MAIN_TASK_PERF_ID);

    Status = HK_Init();
    if (Status != CFE_SUCCESS) {
        RunStatus = CFE_ES_APP_ERROR;
    }

    while (CFE_ES_RunLoop(&RunStatus) == TRUE) {
        CFE_ES_PerfLogExit(HK_MAIN_TASK_PERF_ID);

        Status = CFE_SB_RcvMsg(&HK_AppData.MsgPtr, HK_AppData.CmdPipe, CFE_SB_PEND_FOREVER);

        CFE_ES_PerfLogEntry(HK_MAIN_TASK_PERF_ID);

        if (Status == CFE_SUCCESS) {
            HK_AppPipe();
        } else {
            CFE_EVS_SendEvent(HK_PIPE_ERR_EID, CFE_EVS_ERROR, "HK: SB pipe read error, HK will exit.");
            RunStatus = CFE_ES_APP_ERROR;
        }
    }
}

int32 HK_Init(void) {
    int32 Status = CFE_SUCCESS;

    CFE_ES_RegisterApp();

    /* Initialize app data */
    HK_AppData.CmdPipe = 0;
    HK_AppData.MsgPtr = NULL;
    HK_AppData.CopyTblHandle = 0;
    HK_AppData.RuntimeTblHandle = 0;

    /* Set up and register events */
    HK_AppData.EventFilters[0].EventID = HK_INIT_INF_EID;
    HK_AppData.EventFilters[0].Mask    = CFE_EVS_NO_FILTER;
    HK_AppData.EventFilters[1].EventID = HK_CRCMDPIPE_ERR_EID;
    HK_AppData.EventFilters[1].Mask    = CFE_EVS_NO_FILTER;
    HK_AppData.EventFilters[2].EventID = HK_SUBSCRIBE_ERR_EID;
    HK_AppData.EventFilters[2].Mask    = CFE_EVS_NO_FILTER;
    HK_AppData.EventFilters[3].EventID = HK_MSGID_ERR_EID;
    HK_AppData.EventFilters[3].Mask    = CFE_EVS_NO_FILTER;
    HK_AppData.EventFilters[4].EventID = HK_CC1_ERR_EID;
    HK_AppData.EventFilters[4].Mask    = CFE_EVS_NO_FILTER;

    Status = CFE_EVS_Register(HK_AppData.EventFilters, HK_FILTERED_EVT_COUNT, CFE_EVS_BINARY_FILTER);
    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog("HK: Error registering events, RC = 0x%08X\n", Status);
        return Status;
    }

    /* Initialize housekeeping */
    CFE_SB_InitMsg(&HK_AppData.HkPacket, HK_HK_TLM_MID, sizeof(HK_HkPacket_t), TRUE);
    HK_ResetCounters();

    /* Set up memory pool */
    HK_AppData.MemPoolHandle = 0;
    Status = CFE_ES_PoolCreateEx(&HK_AppData.MemPoolHandle, HK_AppData.MsgPoolRam, HK_NUM_BYTES_IN_MEM_POOL, CFE_ES_MAX_MEMPOOL_BLOCK_SIZES, HK_MemPoolDefSize, CFE_ES_NO_MUTEX);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(HK_MEMPOOL_ERR_EID, CFE_EVS_ERROR, "HK: Error creating memory pool, RC=0x%08X", Status);
        return Status;
    }

    /* Register and load copy table */
    Status = CFE_TBL_Register(&HK_AppData.CopyTblHandle, HK_COPY_TABLE_NAME, sizeof(HK_CopyTable_t), CFE_TBL_OPT_DEFAULT, HK_CopyTableValidate);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(HK_COPY_REG_ERR_EID, CFE_EVS_ERROR, "HK: Failed to register copy table, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_TBL_Load(HK_AppData.CopyTblHandle, CFE_TBL_SRC_FILE, HK_COPY_TABLE_FILENAME);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(HK_COPY_LOAD_ERR_EID, CFE_EVS_ERROR, "HK: Failed to load default copy table(%s), RC=0x%08X", HK_COPY_TABLE_FILENAME, Status);
        return Status;
    }
    CFE_TBL_Manage(HK_AppData.CopyTblHandle);

    /* Set up runtime table */
    CFE_PSP_MemSet((void*)&HK_AppData.RuntimeTable, 0, sizeof(HK_RuntimeTable_t));
    Status = CFE_TBL_Register(&HK_AppData.RuntimeTblHandle, HK_RUNTIME_TABLE_NAME, sizeof(HK_RuntimeTable_t), CFE_TBL_OPT_DUMP_ONLY | CFE_TBL_OPT_USR_DEF_ADDR, NULL);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(HK_RUNTIME_REG_ERR_EID, CFE_EVS_ERROR, "HK: Failed to register runtime table, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_TBL_Load(HK_AppData.RuntimeTblHandle, CFE_TBL_SRC_ADDRESS, &HK_AppData.RuntimeTable);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(HK_RUNTIME_LOAD_ERR_EID, CFE_EVS_ERROR, "HK: Failed to load runtime table address, RC=0x%08X", Status);
        return Status;
    }
    CFE_TBL_Manage(HK_AppData.RuntimeTblHandle);

    /* Create a command pipe and subscribe to its messages */
    Status = CFE_SB_CreatePipe(&HK_AppData.CmdPipe, HK_PIPE_DEPTH, "HK_CMD_PIPE");
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(HK_CRCMDPIPE_ERR_EID, CFE_EVS_ERROR, "HK: Can't create command pipe, RC=0x%08X", Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(HK_CMD_MID, HK_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(HK_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "HK: Error subscribing to HK_CMD_MID(0x%04X), RC=0x%08X", HK_CMD_MID, Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(HK_SEND_HK_MID, HK_AppData.CmdPipe);
    if (Status != CFE_SUCCESS)  {
        CFE_EVS_SendEvent(HK_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "HK: Error subscribing to HK_SEND_HK_MID(0x%04X), RC=0x%08X", HK_SEND_HK_MID, Status);
        return Status;
    }

    /* Set up the tables now that they are loaded and the SB pipe is working */
    Status = HK_SetupTables();
    if (Status != CFE_SUCCESS) {
        return Status;
    }

    CFE_EVS_SendEvent(HK_INIT_INF_EID, CFE_EVS_INFORMATION, "HK app initialized.");
    return CFE_SUCCESS;
}

void HK_AppPipe(void) {
    CFE_SB_MsgId_t MsgId = CFE_SB_GetMsgId(HK_AppData.MsgPtr);

    switch (MsgId) {
        case HK_CMD_MID:
            HK_ProcessGroundCommand();
            break;
        case HK_SEND_HK_MID:
            HK_ReportHousekeeping();
            break;
        default:
            HK_ProcessPacket();
            break;
    }
}

void HK_ProcessGroundCommand(void) {
    uint16 ExpectedLength = sizeof(HK_NoArgsCmd_t);

    if (HK_VerifyCmdLength(HK_AppData.MsgPtr, ExpectedLength)) {
        uint16 CommandCode = CFE_SB_GetCmdCode(HK_AppData.MsgPtr);

        switch (CommandCode) {
            case HK_NOOP_CC:
                CFE_EVS_SendEvent(HK_NOOP_INF_EID, CFE_EVS_INFORMATION, "HK: NOOP command");
                HK_AppData.HkPacket.command_count++;
                break;
            case HK_RESETCTRS_CC:
                HK_ResetCounters();
                break;
            default:
                CFE_EVS_SendEvent(HK_CC1_ERR_EID, CFE_EVS_ERROR, "HK: Invalid command code %u", CommandCode);
                break;
        }
    }
}

void HK_ReportHousekeeping(void) {
    uint16 ExpectedLength = sizeof(HK_SendHkCmd_t);
    if (HK_VerifyCmdLength(HK_AppData.MsgPtr, ExpectedLength)) {
        HK_SendHkCmd_t *cmd = (HK_SendHkCmd_t*)HK_AppData.MsgPtr;
        uint32 i = 0;
        uint32 j = 0;
        HK_CopyTableEntry_t *copy_entry = NULL;
        HK_RuntimeTableEntry_t *runtime_entry = NULL;
        HK_CopyTable_t *copytbl_ptr = NULL;
        int32 Status = CFE_SUCCESS;

        /* Start off by checking for our own HK */
        if (cmd->MsgIdToSend == HK_HK_TLM_MID) {
            CFE_TBL_Manage(HK_AppData.RuntimeTblHandle);
            HK_ManageCopyTable();

            HK_AppData.HkPacket.mem_pool_handle = (uint32)HK_AppData.MemPoolHandle;

            CFE_SB_TimeStampMsg((CFE_SB_MsgPtr_t)&HK_AppData.HkPacket);
            CFE_SB_SendMsg((CFE_SB_MsgPtr_t)&HK_AppData.HkPacket);

            return;
        }

        Status = CFE_TBL_GetAddress((void*)&copytbl_ptr, HK_AppData.CopyTblHandle);
        if (Status != CFE_SUCCESS && Status != CFE_TBL_INFO_UPDATED) {
            if (Status == CFE_TBL_ERR_NEVER_LOADED) {
                CFE_TBL_ReleaseAddress(HK_AppData.CopyTblHandle);
            }
            CFE_EVS_SendEvent(HK_ACQ_PTR_ERR_EID, CFE_EVS_ERROR, "HK: Couldn't get pointer to copy table while processing HK packet, RC=0x%08X", Status);
            return;
        }

        /* Find the first instance of our output MID in the copy table */
        for (i = 0; i < HK_COPY_TABLE_ENTRIES; i++) {
            if (copytbl_ptr->entries[i].output_mid == cmd->MsgIdToSend) {
                copy_entry = &copytbl_ptr->entries[i];
                runtime_entry = &HK_AppData.RuntimeTable.entries[i];
                break;
            }
        }

        if (i >= HK_COPY_TABLE_ENTRIES) {
            /* Requested MID is not in the table! */
            CFE_EVS_SendEvent(HK_MSGID_ERR_EID, CFE_EVS_ERROR, "HK: Received command to send MID 0x%04X not in copy table", cmd->MsgIdToSend);
            HK_AppData.HkPacket.error_count++;

            CFE_TBL_ReleaseAddress(HK_AppData.CopyTblHandle);
            return;
        }

        /* Go through and check for input messages that have failed to check in */
        for (j = i; j < HK_COPY_TABLE_ENTRIES; j++) {
            if (copytbl_ptr->entries[j].output_mid == cmd->MsgIdToSend) {
                if (!HK_AppData.RuntimeTable.entries[j].input_mid_present) {
                    CFE_EVS_SendEvent(HK_CHECKIN_DBG_EID, CFE_EVS_DEBUG, "HK: Input MID 0x%04X failed to checkin for output msg 0x%04X", copytbl_ptr->entries[j].input_mid, cmd->MsgIdToSend);
                    HK_AppData.HkPacket.missing_data_count++;
                }
                /* Now that we've verified an input is present or absent, clean up for next time by marking it absent */
                HK_AppData.RuntimeTable.entries[j].input_mid_present = FALSE;
            }
        }

        /* Timestamp and send the message */
        CFE_SB_TimeStampMsg((CFE_SB_MsgPtr_t)runtime_entry->output_mid_address);
        CFE_SB_SendMsg((CFE_SB_MsgPtr_t)runtime_entry->output_mid_address);
        HK_AppData.HkPacket.packets_sent_count++;

        CFE_TBL_ReleaseAddress(HK_AppData.CopyTblHandle);
    }
}

void HK_ProcessPacket(void) {
    /* Do stuff using the copy table! */
    uint32 i = 0;
    HK_CopyTable_t *copytbl_ptr = NULL;
    CFE_SB_MsgId_t MsgId = CFE_SB_GetMsgId(HK_AppData.MsgPtr);
    uint16 Length = CFE_SB_GetUserDataLength(HK_AppData.MsgPtr);
    int32 Status = CFE_SUCCESS;
    char *SourceAddress = NULL;
    char *DestAddress = NULL;

    Status = CFE_TBL_GetAddress((void*)&copytbl_ptr, HK_AppData.CopyTblHandle);
    if (Status != CFE_SUCCESS && Status != CFE_TBL_INFO_UPDATED) {
        if (Status == CFE_TBL_ERR_NEVER_LOADED) {
            CFE_TBL_ReleaseAddress(HK_AppData.CopyTblHandle);
        }
        CFE_EVS_SendEvent(HK_ACQ_PTR_ERR_EID, CFE_EVS_ERROR, "HK: Couldn't get pointer to copy table while processing HK packet, RC=0x%08X", Status);
        return;
    }

    for (i = 0; i < HK_COPY_TABLE_ENTRIES; i++) {
        HK_CopyTableEntry_t *copy_entry = &copytbl_ptr->entries[i];
        HK_RuntimeTableEntry_t *runtime_entry = &HK_AppData.RuntimeTable.entries[i];
        uint16 NeededLength = 0;

        if (copy_entry->input_mid != MsgId) {
            continue;
        }

        NeededLength = copy_entry->output_offset + copy_entry->num_bytes;
        if (NeededLength > Length) {
            CFE_EVS_SendEvent(HK_MSGLEN_ERR_EID, CFE_EVS_ERROR, "HK: Copy table entry %u expected input message 0x%04X to be %u bytes long, but got %u", i, MsgId, NeededLength, Length);
            continue;
        }

        SourceAddress = (char*)HK_AppData.MsgPtr + copy_entry->input_offset;
        DestAddress = (char*)runtime_entry->output_mid_address + copy_entry->output_offset;
        CFE_PSP_MemCpy((void*)DestAddress, (void*)SourceAddress, copy_entry->num_bytes);

        runtime_entry->input_mid_present = TRUE;
    }
}

boolean HK_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength) {
    boolean result = TRUE;
    uint16 ActualLength = CFE_SB_GetTotalMsgLength(Msg);

    if (ActualLength != ExpectedLength) {
        CFE_SB_MsgId_t MsgId = CFE_SB_GetMsgId(Msg);
        uint16 CommandCode = CFE_SB_GetCmdCode(Msg);

        CFE_EVS_SendEvent(HK_MSGLEN_ERR_EID, CFE_EVS_ERROR, "HK: Invalid cmd length: MID = 0x%04X, CC = %02u, Exp Len = %u, Len = %u", MsgId, CommandCode, ExpectedLength, ActualLength);
        result = FALSE;
        HK_AppData.HkPacket.error_count++;
    }
    return result;
}

void HK_ResetCounters(void) {
    HK_AppData.HkPacket.command_count = 0;
    HK_AppData.HkPacket.error_count = 0;
    HK_AppData.HkPacket.packets_sent_count = 0;
    HK_AppData.HkPacket.missing_data_count = 0;
}

int32 HK_SetupTables(void) {
    int32 Status = CFE_SUCCESS;
    uint32 i = 0;
    HK_CopyTable_t *copytbl_ptr = NULL;

    /* Use the copy table to set up the runtime table and subscribe to messages */
    Status = CFE_TBL_GetAddress((void*)&copytbl_ptr, HK_AppData.CopyTblHandle);
    if (Status != CFE_SUCCESS && Status != CFE_TBL_INFO_UPDATED) {
        if (Status == CFE_TBL_ERR_NEVER_LOADED) {
            CFE_TBL_ReleaseAddress(HK_AppData.CopyTblHandle);
        }
        CFE_EVS_SendEvent(HK_ACQ_PTR_ERR_EID, CFE_EVS_ERROR, "HK: Couldn't get pointer to copy table, RC=0x%08X", Status);
        return Status;
    }

    for (i = 0; i < HK_COPY_TABLE_ENTRIES; i++) {
        HK_CopyTableEntry_t *copy_entry = &copytbl_ptr->entries[i];
        HK_RuntimeTableEntry_t *runtime_entry = &HK_AppData.RuntimeTable.entries[i];

        if (copy_entry->input_mid != 0 && !runtime_entry->input_mid_subscribed) {
            /* Subscribe to a message and mark all associated runtime entries */
            uint32 j = 0;

            Status = CFE_SB_Subscribe(copy_entry->input_mid, HK_AppData.CmdPipe);
            if (Status != CFE_SUCCESS)  {
                CFE_EVS_SendEvent(HK_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "HK: Error subscribing to MID 0x%04X, RC=0x%08X", copy_entry->input_mid, Status);
                break;
            }

            runtime_entry->input_mid_subscribed = TRUE;
            for (j = i+1; j < HK_COPY_TABLE_ENTRIES; j++) {
                if (copytbl_ptr->entries[j].input_mid == copy_entry->input_mid) {
                    HK_AppData.RuntimeTable.entries[j].input_mid_subscribed = TRUE;
                }
            }
        }

        if (copy_entry->output_mid != 0 && runtime_entry->output_mid_address == 0) {
            /* Allocate space for the output message from our pool and updated all related runtime entries */
            uint32 j = 0;
            uint32 *Address = NULL;
            uint16 MsgLen = copy_entry->output_offset + copy_entry->num_bytes;

            /*
             * Calculate the message size by looking for the largest known ending spot (output message offset + number of bytes)
             * and adding the telemetry header size to it
             */
            for (j = i+1; j < HK_COPY_TABLE_ENTRIES; j++) {
                if (copytbl_ptr->entries[j].output_mid == copy_entry->output_mid) {
                    uint16 entry_end = copytbl_ptr->entries[j].output_offset + copytbl_ptr->entries[j].num_bytes;
                    if (entry_end > MsgLen) {
                        MsgLen = entry_end;
                    }
                }
            }

            Status = CFE_ES_GetPoolBuf(&Address, HK_AppData.MemPoolHandle, MsgLen);
            if (Status <= 0) {
                CFE_EVS_SendEvent(HK_MEMPOOL_ERR_EID, CFE_EVS_ERROR, "HK: Error allocating memory for MID 0x%04X (length = %u), RC=0x%08X", copy_entry->output_mid, MsgLen, Status);
                break;
            }

            runtime_entry->output_mid_address = (uint32)Address;
            for (j = i+1; j < HK_COPY_TABLE_ENTRIES; j++) {
                if (copytbl_ptr->entries[j].output_mid == copy_entry->output_mid) {
                    HK_AppData.RuntimeTable.entries[j].output_mid_address= (uint32)Address;
                }
            }

            /* Now that we have the address and have updated all relevant entries with it, set up a message there */
            CFE_SB_InitMsg(Address, copy_entry->output_mid, MsgLen, TRUE);
        }
    }

    CFE_TBL_ReleaseAddress(HK_AppData.CopyTblHandle);

    return Status;
}

int32 HK_UnloadTables(void) {
    int32 Status = CFE_SUCCESS;
    uint32 i = 0;
    HK_CopyTable_t *copytbl_ptr = NULL;

    Status = CFE_TBL_GetAddress((void*)&copytbl_ptr, HK_AppData.CopyTblHandle);
    if (Status != CFE_SUCCESS && Status != CFE_TBL_INFO_UPDATED) {
        if (Status == CFE_TBL_ERR_NEVER_LOADED) {
            CFE_TBL_ReleaseAddress(HK_AppData.CopyTblHandle);
        }
        CFE_EVS_SendEvent(HK_ACQ_PTR_ERR_EID, CFE_EVS_ERROR, "HK: Couldn't get pointer to copy table, RC=0x%08X", Status);
        return Status;
    }

    for (i=0; i < HK_COPY_TABLE_ENTRIES; i++) {
        HK_CopyTableEntry_t *copy_entry = &copytbl_ptr->entries[i];
        HK_RuntimeTableEntry_t *runtime_entry = &HK_AppData.RuntimeTable.entries[i];

        if (runtime_entry->input_mid_subscribed) {
            uint32 j = 0;

            CFE_SB_Unsubscribe(copy_entry->input_mid, HK_AppData.CmdPipe);
            runtime_entry->input_mid_subscribed = FALSE;

            for (j = i+1; j < HK_COPY_TABLE_ENTRIES; j++) {
                if (copytbl_ptr->entries[j].input_mid == copy_entry->input_mid) {
                    HK_AppData.RuntimeTable.entries[j].input_mid_subscribed = FALSE;
                }
            }
        }

        if (runtime_entry->output_mid_address != 0) {
            uint32 j = 0;

            CFE_ES_PutPoolBuf(HK_AppData.MemPoolHandle, (uint32*)runtime_entry->output_mid_address);
            runtime_entry->output_mid_address = 0;

            for (j = i+1; j < HK_COPY_TABLE_ENTRIES; j++) {
                if (copytbl_ptr->entries[j].output_mid == copy_entry->output_mid) {
                    HK_AppData.RuntimeTable.entries[j].output_mid_address = 0;
                }
            }
        }
    }

    CFE_TBL_ReleaseAddress(HK_AppData.CopyTblHandle);

    return Status;
}

void HK_ManageCopyTable() {
    int32 Status = CFE_SUCCESS;
    int32 TblStatus = CFE_SUCCESS;

    do {
        TblStatus = CFE_TBL_GetStatus(HK_AppData.CopyTblHandle);

        if (TblStatus == CFE_TBL_INFO_VALIDATION_PENDING) {
            Status = CFE_TBL_Validate(HK_AppData.CopyTblHandle);
            if (Status != CFE_SUCCESS) {
                break;
            }
        } else if (TblStatus == CFE_TBL_INFO_UPDATE_PENDING) {
            HK_UnloadTables();
            Status = CFE_TBL_Update(HK_AppData.CopyTblHandle);
            HK_SetupTables();
            break;
        }
    } while (TblStatus == CFE_TBL_INFO_VALIDATION_PENDING);
}

int32 HK_CopyTableValidate(void* buffer) {
    return CFE_SUCCESS;
}
