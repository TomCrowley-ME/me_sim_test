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
#include "cfe.h"
#include "egcsim.h"

uint32 g_egcio_q_id;
static uint16 last_throttle = 0;

int32 EGCSIM_HWIF_Init(void) {
    /* Create a queue for HWIO<-->HWSIM communication */
    return OS_QueueCreate(&g_egcio_q_id, "egcio_q", 4, sizeof(uint16), 0);
}

int32 EGCSIM_ReadDeviceData(uint16 *value) {
    uint32 SizeCopied;
    int32  Status;

    Status = OS_QueueGet(g_egcio_q_id, value, sizeof(uint16), &SizeCopied, OS_CHECK);

    /* If we didn't get anything, assume it's whatever we saw last */
    if (Status != OS_SUCCESS) {
        *value = last_throttle;
    } else {
        last_throttle = *value;
    }

    return CFE_SUCCESS;
}
