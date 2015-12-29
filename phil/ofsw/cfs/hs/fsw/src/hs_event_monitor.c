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
#include "hs_task.h"
#include "hs_tables.h"
#include "cfe.h"

extern HS_AppData_t HS_AppData;

void HS_MonitorEvents(void) {
    HS_EventMonitorTable_t *EMTPtr = NULL;
    int32 Status;
    uint32 i;
    uint32 j;

    /* Get a pointer to the event monitor table */
    Status = CFE_TBL_GetAddress((void*)&EMTPtr, HS_AppData.EventMonitorTblHandle);

    if (Status != CFE_SUCCESS && Status != CFE_TBL_INFO_UPDATED) {
        if (Status == CFE_TBL_ERR_NEVER_LOADED) {
            CFE_TBL_ReleaseAddress(HS_AppData.EventMonitorTblHandle);
        }
        CFE_EVS_SendEvent(HS_ACQ_PTR_ERR_EID, CFE_EVS_ERROR, "HS: Unable to get pointer to event monitor table, RC=0x%08X", Status);
        return;
    }

    for (j = 0; j < HS_EVENT_PIPE_DEPTH; j++) {
        Status = CFE_SB_RcvMsg(&HS_AppData.MsgPtr, HS_AppData.EventPipe, CFE_SB_POLL);

        if (Status == CFE_SUCCESS) {
            for (i = 0; i < HS_MAX_CRITICAL_EVENTS; i++) {
                CFE_EVS_Packet_t *EventPacket = (CFE_EVS_Packet_t *)HS_AppData.MsgPtr;

                if ((strncmp(EMTPtr->MonitoredEvent[i].AppName, EventPacket->PacketID.AppName, OS_MAX_API_NAME) == 0)
                    && (EMTPtr->MonitoredEvent[i].EventId == EventPacket->PacketID.EventID)) {
                    uint32 AppId = 0;

                    /* We've hit the limit, perform the requested action */
                    switch (EMTPtr->MonitoredEvent[i].ActionType) {
                        case HS_ACTION_PROCESSOR_RESET:
                            CFE_EVS_SendEvent(HS_ACTION_INF_EID, CFE_EVS_INFORMATION, "HS: Received critical event %u from %s, performing processor reset...", EMTPtr->MonitoredEvent[i].EventId, EMTPtr->MonitoredEvent[i].AppName);

                            OS_TaskDelay(HS_RESET_TASK_DELAY);
                            CFE_ES_ResetCFE(CFE_ES_PROCESSOR_RESET);

                            break;

                        case HS_ACTION_APP_RESTART:
                            Status = CFE_ES_GetAppIDByName(&AppId, EMTPtr->MonitoredEvent[i].AppName);
                            CFE_EVS_SendEvent(HS_ACTION_INF_EID, CFE_EVS_INFORMATION, "HS: Received critical event %u from %s, resetting it...", EMTPtr->MonitoredEvent[i].EventId, EMTPtr->MonitoredEvent[i].AppName);

                            CFE_ES_RestartApp(AppId);

                            break;

                        case HS_ACTION_SEND_EVENT:
                            CFE_EVS_SendEvent(HS_ACTION_INF_EID, CFE_EVS_INFORMATION, "HS: Received critical event %u from %s.", EMTPtr->MonitoredEvent[i].EventId, EMTPtr->MonitoredEvent[i].AppName);
                            break;

                        default:
                            CFE_EVS_SendEvent(HS_ACTION_INF_EID, CFE_EVS_INFORMATION, "HS: Received critical event %u from %s, sending message %u...", EMTPtr->MonitoredEvent[i].EventId, EMTPtr->MonitoredEvent[i].AppName, EMTPtr->MonitoredEvent[i].ActionType);
                            HS_PerformMessageAction(EMTPtr->MonitoredEvent[i].ActionType);
                            break;
                    }
                }
            }
        } else if (Status == CFE_SB_NO_MESSAGE) {
            break;
        } else {
            CFE_EVS_SendEvent(HS_PIPE_ERR_EID, CFE_EVS_ERROR, "HS: Can't read event pipe, RC=0x%08X", Status);
            break;
        }
    }

    CFE_TBL_ReleaseAddress(HS_AppData.EventMonitorTblHandle);
}

int32 HS_EventMonitorTableValidate(void* buffer) {
    uint32 i;
    HS_EventMonitorTable_t *EMTPtr = (HS_EventMonitorTable_t *)buffer;

    /* Check the action type for each entry */
    for (i = 0; i < HS_MAX_CRITICAL_EVENTS; i++) {
        if (strlen(EMTPtr->MonitoredEvent[i].AppName) != 0) {
            uint16 Action = EMTPtr->MonitoredEvent[i].ActionType;

            if (!((Action >=1 && Action <= HS_MAX_MSG_ACT_TYPES) ||
                   Action == HS_ACTION_PROCESSOR_RESET ||
                   Action == HS_ACTION_APP_RESTART ||
                   Action == HS_ACTION_SEND_EVENT)) {
                return HS_EMT_INVALID_ACTION;
            }
        }
    }

    return CFE_SUCCESS;
}
