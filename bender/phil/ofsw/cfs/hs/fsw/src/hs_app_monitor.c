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

void HS_MonitorApplications(void) {
    HS_AppMonitorTable_t *AMTPtr = NULL;
    int32 Status;
    uint32 i;

    /* Get a pointer to the app monitor table */
    Status = CFE_TBL_GetAddress((void*)&AMTPtr, HS_AppData.AppMonitorTblHandle);

    if (Status != CFE_SUCCESS && Status != CFE_TBL_INFO_UPDATED) {
        if (Status == CFE_TBL_ERR_NEVER_LOADED) {
            CFE_TBL_ReleaseAddress(HS_AppData.AppMonitorTblHandle);
        }
        CFE_EVS_SendEvent(HS_ACQ_PTR_ERR_EID, CFE_EVS_ERROR, "HS: Unable to get pointer to app monitor table, RC=0x%08X", Status);
        return;
    }

    /* Check each entry that has a non-zero-length string */
    for (i = 0; i < HS_MAX_CRITICAL_APPS; i++) {
        if (strlen(AMTPtr->MonitoredApp[i].AppName) != 0) {
            uint32 AppId;

            /* Look up the  */
            Status = CFE_ES_GetAppIDByName(&AppId, AMTPtr->MonitoredApp[i].AppName);
            if (Status == CFE_SUCCESS) {
                CFE_ES_AppInfo_t AppInfo;

                /* Get the app info for execution counts */
                CFE_ES_GetAppInfo(&AppInfo, AppId);

                /* Check to see if the app has executed */
                if (AppInfo.ExecutionCounter == HS_AppData.PrevAppCounts[i]) {
                    HS_AppData.StaticAppCounts[i]++;
                    if (HS_AppData.StaticAppCounts[i] == AMTPtr->MonitoredApp[i].CycleCount) {
                        /* We've hit the limit, perform the requested action */
                        switch (AMTPtr->MonitoredApp[i].ActionType) {
                            case HS_ACTION_PROCESSOR_RESET:
                                CFE_EVS_SendEvent(HS_ACTION_INF_EID, CFE_EVS_INFORMATION, "HS: App %s not responding, performing processor reset...", AMTPtr->MonitoredApp[i].AppName);

                                OS_TaskDelay(HS_RESET_TASK_DELAY);
                                CFE_ES_ResetCFE(CFE_ES_PROCESSOR_RESET);

                                break;

                            case HS_ACTION_APP_RESTART:
                                CFE_EVS_SendEvent(HS_ACTION_INF_EID, CFE_EVS_INFORMATION, "HS: App %s not responding, resetting it...", AMTPtr->MonitoredApp[i].AppName);

                                CFE_ES_RestartApp(AppId);

                                break;

                            case HS_ACTION_SEND_EVENT:
                                CFE_EVS_SendEvent(HS_ACTION_INF_EID, CFE_EVS_INFORMATION, "HS: App %s is not responding.", AMTPtr->MonitoredApp[i].AppName);
                                break;

                            default:
                                CFE_EVS_SendEvent(HS_ACTION_INF_EID, CFE_EVS_INFORMATION, "HS: App %s is not responding, sending message %u...", AMTPtr->MonitoredApp[i].AppName, AMTPtr->MonitoredApp[i].ActionType);
                                HS_PerformMessageAction(AMTPtr->MonitoredApp[i].ActionType);
                                break;
                        }

                        /* Now that the action has been done, reset the static counter */
                        HS_AppData.StaticAppCounts[i] = 0;
                    }
                }

                HS_AppData.PrevAppCounts[i] = AppInfo.ExecutionCounter;

            } else {
                /* Oh boy, I don't even know what to do here. Restart everyting? */
                CFE_EVS_SendEvent(HS_INVALID_APP_ERR_EID, CFE_EVS_CRITICAL, "HS: Nonexistent application '%s' in app monitor table\n", AMTPtr->MonitoredApp[i].AppName);
            }
        }
    }

    CFE_TBL_ReleaseAddress(HS_AppData.AppMonitorTblHandle);
}

int32 HS_AppMonitorTableValidate(void* buffer) {
    uint32 i;
    HS_AppMonitorTable_t *AMTPtr = (HS_AppMonitorTable_t *)buffer;

    /* Check the action type for each entry */
    for (i = 0; i < HS_MAX_CRITICAL_APPS; i++) {
        if (strlen(AMTPtr->MonitoredApp[i].AppName) != 0) {
            uint16 Action = AMTPtr->MonitoredApp[i].ActionType;

            if (!((Action >=1 && Action <= HS_MAX_MSG_ACT_TYPES) ||
                   Action == HS_ACTION_PROCESSOR_RESET ||
                   Action == HS_ACTION_APP_RESTART ||
                   Action == HS_ACTION_SEND_EVENT)) {
                return HS_AMT_INVALID_ACTION;
            }
        }
    }

    return CFE_SUCCESS;
}
