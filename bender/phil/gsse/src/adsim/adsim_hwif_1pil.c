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
#include "adsim.h"

uint32 g_adio_mutex_id;
uint8  g_adio_latest_readings[sizeof(adio_veh_msg_t)-sizeof(CFE_SB_TlmHdr_t)];

int32 ADSIM_HWIF_Init(void) {
    int32 Status;

    Status = OS_MutSemCreate(&g_adio_mutex_id, "adio_mutex", 0);
    if (Status != OS_SUCCESS) {
        return Status;
    }

    CFE_PSP_MemSet(g_adio_latest_readings, 0, sizeof(g_adio_latest_readings));

    return CFE_SUCCESS;
}

int32 ADSIM_WriteDeviceData(adio_veh_msg_t *adio_veh_msg) {
    int32 Status;

    Status = OS_MutSemTake(g_adio_mutex_id);
    if (Status == OS_SUCCESS) {
        adio_veh_msg_t scaled_readings;
        uint32 i;

        CFE_PSP_MemCpy((uint8*)&scaled_readings, (uint8*)adio_veh_msg, sizeof(CFE_SB_TlmHdr_t));

        for (i = 0; i < 9; i++) {
            scaled_readings.voltage_meas_vec[i] = adio_veh_msg->voltage_meas_vec[i];
        }
        for (i = 0; i < 46; i++) {
            scaled_readings.current_meas_vec[i] = adio_veh_msg->current_meas_vec[i];
        }
        for (i = 0; i < 6; i++) {
            scaled_readings.pressure_meas_vec[i] = (uint16)((double)adio_veh_msg->pressure_meas_vec[i] * 4095.0/3103.0);
        }
        for (i = 0; i < 64; i++) {
            scaled_readings.temp_meas_vec[i] = adio_veh_msg->temp_meas_vec[i];
        }

        CFE_PSP_MemCpy(g_adio_latest_readings,
                       CFE_SB_GetUserData((CFE_SB_MsgPtr_t)&scaled_readings),
                       CFE_SB_GetUserDataLength((CFE_SB_MsgPtr_t)&scaled_readings));

        OS_MutSemGive(g_adio_mutex_id);
    }

    return Status;
}
