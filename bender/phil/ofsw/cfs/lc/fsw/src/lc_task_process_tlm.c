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
 * lc_task_process_tlm.c
 *
 *  Created on: May 10, 2014
 *      Author: tklaus
 */

#include <stddef.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>

#include "lc_task.h"
#include "lc_task_process_tlm.h"
#include "lc_task_watchpoint_table.h"

extern LC_AppData_t LC_AppData;

int32 LC_Subscribe_Tlm(void){
    LC_WatchpointDefinitionTable_t *wpTblPtr = NULL;
    int32 Status = CFE_SUCCESS;
    int WatchpointIndex = 0;
    int SubscriptionIndex = 0;

    Status = CFE_TBL_GetAddress((void*) &wpTblPtr, LC_AppData.WptTblHandle);
    if (Status != CFE_SUCCESS && Status != CFE_TBL_INFO_UPDATED) {
        CFE_EVS_SendEvent(LC_ACQ_PTR_ERR_EID, CFE_EVS_ERROR,
                "LC: Error acquiring pointer to watchpoint table, RC=0x%08X", Status);
        return Status;
    }

    for (WatchpointIndex = 0; WatchpointIndex < LC_MAX_WATCHPOINTS; WatchpointIndex++) {
        uint16 WatchpointMsgid = wpTblPtr->watchpoints[WatchpointIndex].message_id;
        if (WatchpointMsgid == 0) {
            continue;
        }

        for (SubscriptionIndex = 0; SubscriptionIndex < LC_AppData.SubscriptionCount; SubscriptionIndex++) {
            if (LC_AppData.Subscriptions[SubscriptionIndex] == WatchpointMsgid) {
                /* found */
                break;
            }
        }

        if (SubscriptionIndex == LC_AppData.SubscriptionCount) {
            /* not found, so not a dup -- subscribe and add it to the list */
            Status = CFE_SB_Subscribe(WatchpointMsgid, LC_AppData.TlmPipe);
            if (Status != CFE_SUCCESS) {
                CFE_EVS_SendEvent(LC_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR,
                        "LC: Error subscribing to 0x%4X, RC=0x%08X", WatchpointMsgid, Status);
                CFE_TBL_ReleaseAddress(LC_AppData.WptTblHandle);
                return Status;
            }

            LC_AppData.Subscriptions[LC_AppData.SubscriptionCount] = WatchpointMsgid;
            LC_AppData.SubscriptionCount++;
        }
    }

    /* initialize msgid -> watchpoint lookup table */
    Status = LC_wpt_init(wpTblPtr);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(LC_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR,
                "LC: Error initializing lookup table, RC=0x%08X", Status);
        CFE_TBL_ReleaseAddress(LC_AppData.WptTblHandle);
        return Status;
    }

    CFE_TBL_ReleaseAddress(LC_AppData.WptTblHandle);

    return Status;
}

int32 LC_Unsubscribe_Tlm(void){
    int32 Status = CFE_SUCCESS;
    int SubscriptionIndex = 0;

    for (SubscriptionIndex = 0; SubscriptionIndex < LC_AppData.SubscriptionCount; SubscriptionIndex++) {
        uint16 msgId = LC_AppData.Subscriptions[SubscriptionIndex];
        Status = CFE_SB_Unsubscribe(msgId, LC_AppData.TlmPipe);
        if (Status != CFE_SUCCESS) {
            CFE_EVS_SendEvent(LC_UNSUBSCRIBE_ERR_EID, CFE_EVS_ERROR,
                    "LC: Error unsubscribing to 0x%4X, RC=0x%08X", msgId, Status);
            return Status;
        }
    }
    return Status;
}

int32 LC_ProcessTelemetryMsg(){
    DEBUG("LC: LC_ProcessTelemetryMsg\n");
    CFE_SB_MsgId_t MsgId;

    MsgId = CFE_SB_GetMsgId(LC_AppData.MsgPtr);
    LC_wpt_process_message(MsgId, (uint8 *)LC_AppData.MsgPtr);

    return CFE_SUCCESS;
}

