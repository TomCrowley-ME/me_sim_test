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
#include "memssim.h"

#include "pru_icss.h"
#include "puppetmaster_interface.h"

int32 MEMSSIM_HWIF_Init(void) {
    return CFE_SUCCESS;
}

int32 MEMSSIM_WriteDeviceData(mem_veh_msg_t *mem_veh_msg) {
    /* Wait for the previous MEMS job to complete, if there was one (should never happen) */
    if (pru_icss_wait_event_clear(MEMS_WRITE_EVENT, sysClkRateGet()/400) == ERROR) {
        return ERROR;
    }

    /* Copy the data over into the ST buffer in the PRU DRAM */
    CFE_PSP_MemCpy((void*)(PRU0_DRAM_BASE + MEMS1_BUFFER_ADDR), &mem_veh_msg->mem1, sizeof(mems_reading_t));
    CFE_PSP_MemCpy((void*)(PRU0_DRAM_BASE + MEMS2_BUFFER_ADDR), &mem_veh_msg->mem2, sizeof(mems_reading_t));
    CFE_PSP_MemCpy((void*)(PRU0_DRAM_BASE + MEMS3_BUFFER_ADDR), &mem_veh_msg->mem3, sizeof(mems_reading_t));

    /* Tell the PRU to write out the buffers */
    pru_icss_set_event(MEMS_WRITE_EVENT);

    return CFE_SUCCESS;
}
