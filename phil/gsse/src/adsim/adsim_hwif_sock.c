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

#include "network_includes.h"
#include "net/if.h"
#include "ioctl.h"

static int ad_socket;
static struct sockaddr_in fsw_addr;

int32 ADSIM_HWIF_Init(void) {
    struct sockaddr_in *if_address;
    struct ifreq ifr;

    memset(&fsw_addr, 0, sizeof(struct sockaddr_in));

    ad_socket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (ad_socket >= 0) {
        ifr.ifr_addr.sa_family = AF_INET;
        strncpy(ifr.ifr_name, "cpsw0", IFNAMSIZ-1);
        ioctl(ad_socket, SIOCGIFADDR, &ifr);

        if_address = (struct sockaddr_in *)&ifr.ifr_addr;

        fsw_addr.sin_family = AF_INET;
        fsw_addr.sin_addr.s_addr = htonl(ntohl(if_address->sin_addr.s_addr) - 1);
        fsw_addr.sin_port = htons(4610);

        return CFE_SUCCESS;
    } else {
        return ad_socket;
    }
}

int32 ADSIM_WriteDeviceData(adio_veh_msg_t *adio_veh_msg) {
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

    sendto(ad_socket, (void*)CFE_SB_GetUserData((CFE_SB_MsgPtr_t)&scaled_readings), CFE_SB_GetUserDataLength((CFE_SB_MsgPtr_t)&scaled_readings), 0, (struct sockaddr *)&fsw_addr, sizeof(fsw_addr));

    return CFE_SUCCESS;
}
