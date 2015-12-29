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

uint32 g_memsio_q_id;

int32 MEMSSIM_HWIF_Init(void) {
    /* Create a queue for HWIO<-->HWSIM communication */
    return OS_QueueCreate(&g_memsio_q_id, "memsio_q", 20, sizeof(mem_veh_msg_t)-sizeof(CFE_SB_TlmHdr_t), 0);
}

int32 MEMSSIM_WriteDeviceData(mem_veh_msg_t *mem_veh_msg) {
    OS_QueuePut(g_memsio_q_id, CFE_SB_GetUserData((CFE_SB_MsgPtr_t)mem_veh_msg), CFE_SB_GetUserDataLength((CFE_SB_MsgPtr_t)mem_veh_msg), 0);

    return CFE_SUCCESS;
}
