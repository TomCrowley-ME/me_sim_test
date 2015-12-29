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

void HS_PerformMessageAction(uint32 MessageNumber) {
    HS_MessageActionTable_t *MATPtr = NULL;
    int32 Status;

    /* Make sure we're about to send a valid message */
    if (MessageNumber < 1 || MessageNumber > HS_MAX_MSG_ACT_TYPES) {
        CFE_EVS_SendEvent(HS_MSG_ACTION_ERR_EID, CFE_EVS_ERROR, "HS: Cannot send invalid message #%u", MessageNumber);
        return;
    }

    /* Get a pointer to the message action table */
    Status = CFE_TBL_GetAddress((void*)&MATPtr, HS_AppData.MsgActTblHandle);

    if (Status != CFE_SUCCESS && Status != CFE_TBL_INFO_UPDATED) {
        if (Status == CFE_TBL_ERR_NEVER_LOADED) {
            CFE_TBL_ReleaseAddress(HS_AppData.MsgActTblHandle);
        }
        CFE_EVS_SendEvent(HS_ACQ_PTR_ERR_EID, CFE_EVS_ERROR, "HS: Unable to get pointer to message action table, RC=0x%08X", Status);
        return;
    }

    /* Verify that it's actually enabled */
    if (MATPtr->MessageAction[MessageNumber-1].EnableState == HS_STATE_DISABLED) {
        CFE_EVS_SendEvent(HS_MSG_ACTION_ERR_EID, CFE_EVS_ERROR, "HS: Cannot send disabled message #%u", MessageNumber);
    } else {
        /* Send the message */
        CFE_SB_SendMsg((CFE_SB_MsgPtr_t)(MATPtr->MessageAction[MessageNumber-1].MsgData));
    }

    CFE_TBL_ReleaseAddress(HS_AppData.AppMonitorTblHandle);
}

int32 HS_MessageActionTableValidate(void* buffer) {
    uint32 i;
    HS_MessageActionTable_t *MATPtr = (HS_MessageActionTable_t *)buffer;

    /* Check the state and checksum for each entry */
    for (i = 0; i < HS_MAX_MSG_ACT_TYPES; i++) {
        uint16 EnableState = MATPtr->MessageAction[i].EnableState;

        if (EnableState == HS_STATE_ENABLED) {
            /* Only validate enabled messages... */
            if (CFE_SB_ValidateChecksum((CFE_SB_MsgPtr_t)(MATPtr->MessageAction[i].MsgData)) == FALSE) {
                return HS_MAT_INVALID_CHECKSUM;
            }
        } else if (EnableState != HS_STATE_DISABLED) {
            /* ...but make sure the state is valid */
            return HS_MAT_INVALID_STATE;
        }
    }

    return CFE_SUCCESS;
}
