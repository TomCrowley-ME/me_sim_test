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
#include "gpssim.h"

uint32 g_gpsio_mutex_id;
uint8  g_gpsio_latest_readings[sizeof(gps_veh_msg_t)-sizeof(CFE_SB_TlmHdr_t)];

int32 GPSSIM_HWIF_Init(void) {
    int32 Status;

    Status = OS_MutSemCreate(&g_gpsio_mutex_id, "gpsio_mutex", 0);
    if (Status != OS_SUCCESS) {
        return Status;
    }

    CFE_PSP_MemSet(g_gpsio_latest_readings, 0, sizeof(g_gpsio_latest_readings));

    return CFE_SUCCESS;
}

int32 GPSSIM_WriteDeviceData(gps_veh_msg_t *gps_veh_msg) {
    int32 Status;

    Status = OS_MutSemTake(g_gpsio_mutex_id);
    if (Status == OS_SUCCESS) {
        CFE_PSP_MemCpy(g_gpsio_latest_readings,
                       CFE_SB_GetUserData((CFE_SB_MsgPtr_t)gps_veh_msg),
                       CFE_SB_GetUserDataLength((CFE_SB_MsgPtr_t)gps_veh_msg));

        OS_MutSemGive(g_gpsio_mutex_id);
    }

    return Status;
}
