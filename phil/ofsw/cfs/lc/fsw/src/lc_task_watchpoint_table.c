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
/*
 * lc_task_watchpoint_table.c
 *
 *  Created on: May 10, 2014
 *      Author: tklaus
 */

#include <string.h>

#include <cfe_error.h>

#include "lc_task.h"
#include "lc_task_watchpoint_table.h"
#include "lc_task_actionpoint_table.h"

static int32 wpt_hash_put(uint16 message_id, uint16 index);
static LC_HashBucket_T * wpt_hash_get_bucket(uint16 message_id);
static int32 wpt_process_watchpoint(uint16 message_id, uint8 *message_data, LC_HashEntry_T* watchpoint_entry);

extern LC_AppData_t LC_AppData;

int32 LC_wpt_init(LC_WatchpointDefinitionTable_t *wpTblPtr) {
    CFE_PSP_MemSet(&LC_AppData.WatchpointLookupHashTable, 0, sizeof(LC_AppData.WatchpointLookupHashTable));

    int num_watchpoints = sizeof(wpTblPtr->watchpoints) / sizeof(wpTblPtr->watchpoints[0]);
    int wpt_index = 0;
    int num_valid_watchpoints = 0;

    for (wpt_index = 0; wpt_index < num_watchpoints; wpt_index++) {
        uint16 message_id = wpTblPtr->watchpoints[wpt_index].message_id;

        if (message_id) {
            num_valid_watchpoints++;
            int32 rc = wpt_hash_put(message_id, wpt_index);
            if (rc != CFE_SUCCESS) {
                return rc;
            }
        }
    }

    DEBUG("LC: Initialized %d watch points\n", num_valid_watchpoints);
    return CFE_SUCCESS;
}

int32 LC_wpt_process_message(uint16 message_id, uint8 *message_data) {
    LC_HashBucket_T *bucket = wpt_hash_get_bucket(message_id);
    boolean found = FALSE;

    DEBUG("LC: lc_wpt_process_message: message_id = 0x%04x\n", message_id);

    int i = 0;
    for (i = 0; i < bucket->num_entries; i++) {
        if (bucket->entries[i].message_id == message_id) { /* in case of hash collisions*/
        	found = TRUE;
            LC_HashEntry_T* entry = &(bucket->entries[i]);
            wpt_process_watchpoint(message_id, message_data, entry);
        }
    }

    if(!found){
        CFE_EVS_SendEvent(LC_INIT_ERR_EID, CFE_EVS_ERROR,
                "LC: No hash entries found for mesgid = 0x%04x\n", message_id);
    }

    return CFE_SUCCESS;
}


int32 wpt_hash_put(uint16 message_id, uint16 index) {
    int32 rc = CFE_SUCCESS;

    uint16 bucket_idx = HASH_IDX(message_id);
    LC_HashBucket_T *bucket = &(LC_AppData.WatchpointLookupHashTable.buckets[bucket_idx]);

    DEBUG("bucket_idx = %d, mesgid = 0x%04x\n", bucket_idx, message_id);

    if (bucket->num_entries > LC_HASH_MAX_ENTRIES_PER_BUCKET) {
        CFE_EVS_SendEvent(LC_INIT_ERR_EID, CFE_EVS_ERROR,
                "LC: LC_HASH_MAX_ENTRIES_PER_BUCKET is too small! LC will exit.");
        rc = CFE_ES_APP_ERROR;
        return rc;
    }

    LC_HashEntry_T *new_entry = &(bucket->entries[bucket->num_entries]);

    new_entry->message_id = message_id;
    new_entry->watchpoint_def_table_index = index;

    bucket->num_entries++;

    return rc;
}

LC_HashBucket_T * wpt_hash_get_bucket(uint16 message_id) {
    uint16 bucket_idx = HASH_IDX(message_id);

    DEBUG("LC: lc_wpt_hash_get_bucket: bucket_idx = %d\n", bucket_idx);

    return &(LC_AppData.WatchpointLookupHashTable.buckets[bucket_idx]);
}

boolean eval_wp(uint8 operator, uint32 bitmask, int32 diff) {
    switch (operator) {
        case EQUAL_TO:
            return (diff == 0);

        case NOT_EQUAL_TO:
            return (diff != 0);

        case LESS_THAN:
            return (diff < 0);

        case LESS_THAN_OR_EQUAL_TO:
            return (diff <= 0);

        case GREATER_THAN_OR_EQUAL_TO:
            return (diff >= 0);

        case GREATER_THAN:
            return (diff > 0);
    }
    return FALSE;
}

int32 wpt_process_watchpoint(uint16 message_id, uint8 *message_data, LC_HashEntry_T* watchpoint_entry) {

    LC_WatchpointDefinitionTable_t *wpTblPtr = NULL;
    uint16 watchpoint_def_table_index = watchpoint_entry->watchpoint_def_table_index;
    int32 Status = CFE_SUCCESS;
    boolean eval_result;
    int32 difference;
	double *message_double;
	float *message_float;
    double double_difference;
    uint8 *member_pointer;

    Status = CFE_TBL_GetAddress((void*) &wpTblPtr, LC_AppData.WptTblHandle);
    if (Status != CFE_SUCCESS && Status != CFE_TBL_INFO_UPDATED) {
        CFE_EVS_SendEvent(LC_ACQ_PTR_ERR_EID, CFE_EVS_ERROR,
                "LC: Error acquiring pointer to watchpoint table, RC=0x%08X", Status);
        return Status;
    }

    LC_WatchpointDefinition_t* watchpoint = &(wpTblPtr->watchpoints[watchpoint_def_table_index]);

    DEBUG("LC: evaluating watchpoint %d (1-based)\n", (int)watchpoint_def_table_index+1);

    /* Example Watchpoint

     .data_type = LC_UINT8,
     .operator_id = EQUAL_TO,
     .message_id = CMP_BULC_AppData.S_MID,
     .offset = BUS_OFFSET(cmp_bus_msg, takeoff_enable),
     .bitmask = 0,
     .value.u8 = 1,
     */

    member_pointer = message_data + watchpoint->offset;

    switch (watchpoint->data_type) {
        case LC_DOUBLE:
        	message_double = (double *) member_pointer;
            double_difference = *message_double - watchpoint->value.f64;
            if(double_difference < LC_FLOAT_TOLERANCE && double_difference > -LC_FLOAT_TOLERANCE){
                difference = 0;
            }else{
            	difference = double_difference < 0.0 ? -1 : 1;
            }
            break;

        case LC_FLOAT:
        	message_float = (float *) member_pointer;
            double_difference = *message_float - watchpoint->value.f32;
            if(double_difference < LC_FLOAT_TOLERANCE && double_difference > -LC_FLOAT_TOLERANCE){
                difference = 0;
            }else{
            	difference = double_difference < 0.0 ? -1 : 1;
            }
            break;

        case LC_UINT32:
            difference = (*((uint32*) (message_data + watchpoint->offset)) | watchpoint->bitmask)
                    - (watchpoint->value.u32);
            break;

        case LC_INT32:
            difference = (*((int32*) (message_data + watchpoint->offset)) | watchpoint->bitmask)
                    - (watchpoint->value.i32);
            break;

        case LC_UINT16:
            difference = (*((uint16*) (message_data + watchpoint->offset)) | watchpoint->bitmask)
                    - (watchpoint->value.u16);
            break;

        case LC_INT16:
            difference = (*((int16*) (message_data + watchpoint->offset)) | watchpoint->bitmask)
                    - (watchpoint->value.i16);
            break;

        case LC_UINT8:
            difference = (*((uint8*) (message_data + watchpoint->offset)) | watchpoint->bitmask)
                    - (watchpoint->value.u8);
            break;

        case LC_INT8:
            difference = (*((int8*) (message_data + watchpoint->offset)) | watchpoint->bitmask)
                    - (watchpoint->value.i8);
            break;
    }

    eval_result = eval_wp(watchpoint->operator_id, watchpoint->bitmask, difference);

    uint16 lastResult = LC_AppData.HkPacket.WpLastEvalResult[watchpoint_def_table_index];

    LC_AppData.HkPacket.WpLastEvalResult[watchpoint_def_table_index] = eval_result;
    LC_AppData.HkPacket.WpEvalCount[watchpoint_def_table_index]++;

    if(eval_result){
		LC_AppData.HkPacket.WpAllEvalTrueCount++;
		LC_AppData.HkPacket.WpCumulativeTrueCount[watchpoint_def_table_index]++;

		if(lastResult){
    		/* TRUE -> TRUE */
        	LC_AppData.HkPacket.WpConsecutiveTrueCount[watchpoint_def_table_index]++;
    	}else{
    		/* FALSE -> TRUE */
        	LC_AppData.HkPacket.WpConsecutiveTrueCount[watchpoint_def_table_index] = 0;
    	}
    }else{
		LC_AppData.HkPacket.WpAllEvalFalseCount++;
		if(!lastResult){
    		/* FALSE -> TRUE */
        	LC_AppData.HkPacket.WpFalseToTrueCount[watchpoint_def_table_index]++;
    	}
    }

    LC_AppData.WatchpointUpdated[watchpoint_def_table_index] = TRUE;
    LC_AppData.WatchpointState[watchpoint_def_table_index] = eval_result;

    DEBUG("LC: watchpoint %d (1-based): diff=%d, eval_result=%d\n",
    		(int)watchpoint_def_table_index+1, (int)difference, (int)eval_result);

    CFE_TBL_ReleaseAddress(LC_AppData.WptTblHandle);

    return CFE_SUCCESS;
}

