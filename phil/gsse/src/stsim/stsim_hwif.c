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
#include "stsim.h"

#include "pru_icss.h"
#include "pru_fw/puppetmaster_interface.h"

int32 STSIM_HWIF_Init(void) {
    return CFE_SUCCESS;
}

void STSIM_WriteSTValues(void) {
    sta_veh_msg_t sta_veh_msg;

    /* This is all super inefficient, and will go away when we bring
     * the real DTU microcontroller into the loop */
    memcpy((void *)&sta_veh_msg, (void*)STSIM_AppData.MsgPtr, CFE_SB_GetTotalMsgLength(STSIM_AppData.MsgPtr));

    binvert((char*)&sta_veh_msg.q_eci_to_head[0], sizeof(double));
    binvert((char*)&sta_veh_msg.q_eci_to_head[1], sizeof(double));
    binvert((char*)&sta_veh_msg.q_eci_to_head[2], sizeof(double));
    binvert((char*)&sta_veh_msg.q_eci_to_head[3], sizeof(double));
    binvert((char*)&sta_veh_msg.acc_meas[0], sizeof(double));
    binvert((char*)&sta_veh_msg.acc_meas[1], sizeof(double));
    binvert((char*)&sta_veh_msg.acc_meas[2], sizeof(double));
    binvert((char*)&sta_veh_msg.rate_meas[0], sizeof(double));
    binvert((char*)&sta_veh_msg.rate_meas[1], sizeof(double));
    binvert((char*)&sta_veh_msg.rate_meas[2], sizeof(double));

    /* Wait for the previous ST job to complete, if there was one (should never happen) */
    pru_icss_wait_event_clear(ST_WRITE_EVENT, sysClkRateGet()/500);

    /* Copy the data over into the ST buffer in the PRU DRAM */
    memcpy((void*)(PRU0_DRAM_BASE + ST_BUFFER_ADDR), CFE_SB_GetUserData((CFE_SB_MsgPtr_t)&sta_veh_msg), CFE_SB_GetUserDataLength((CFE_SB_MsgPtr_t)&sta_veh_msg));

    /* Tell the PRU to write out the buffer */
    pru_icss_set_event(ST_WRITE_EVENT);

    STSIM_AppData.HkPacket.st_write_count++;
}
