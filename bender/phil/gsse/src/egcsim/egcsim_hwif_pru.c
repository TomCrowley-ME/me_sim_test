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

#include "pru_icss.h"
#include "puppetmaster_interface.h"

int32 EGCSIM_HWIF_Init(void) {
    return CFE_SUCCESS;
}

int32 EGCSIM_ReadDeviceData(uint16 *value) {
    if (value == NULL) {
        return ERROR;
    }

    /*
     * When EGC is included, it's the initial synchronization point
     * for a simulation frame.
     */
    pru_icss_set_event(EGC_READ_EVENT);

    /* Wait for EGC read to be done */
    if (pru_icss_wait_event_clear(EGC_READ_EVENT, sysClkRateGet()/400) == ERROR) {
        /* Give up on this attempt, we'll try again next time */
        pru_icss_clear_event(EGC_READ_EVENT);
        return ERROR;
    }


    /* Read in the new EGC throttle value */
    *value = *((uint16*)(PRU0_DRAM_BASE + EGC_BUFFER_ADDR));

    return CFE_SUCCESS;
}
