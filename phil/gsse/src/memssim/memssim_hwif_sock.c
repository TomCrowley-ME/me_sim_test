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

#include "network_includes.h"
#include "net/if.h"
#include "ioctl.h"

static int mems_socket;
static struct sockaddr_in fsw_addr;

int32 MEMSSIM_HWIF_Init(void) {
    struct sockaddr_in *if_address;
    struct ifreq ifr;

    memset(&fsw_addr, 0, sizeof(struct sockaddr_in));

    mems_socket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (mems_socket >= 0) {
        ifr.ifr_addr.sa_family = AF_INET;
        strncpy(ifr.ifr_name, "cpsw0", IFNAMSIZ-1);
        ioctl(mems_socket, SIOCGIFADDR, &ifr);

        if_address = (struct sockaddr_in *)&ifr.ifr_addr;

        fsw_addr.sin_family = AF_INET;
        fsw_addr.sin_addr.s_addr = htonl(ntohl(if_address->sin_addr.s_addr) - 1);
        fsw_addr.sin_port = htons(9395);

        return CFE_SUCCESS;
    } else {
        return mems_socket;
    }
}

int32 MEMSSIM_WriteDeviceData(mem_veh_msg_t *mem_veh_msg) {
    sendto(mems_socket, (void*)CFE_SB_GetUserData(((CFE_SB_MsgPtr_t)mem_veh_msg)), CFE_SB_GetUserDataLength(((CFE_SB_MsgPtr_t)mem_veh_msg)), 0, (struct sockaddr *)&fsw_addr, sizeof(fsw_addr));

    return CFE_SUCCESS;
}
