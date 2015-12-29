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
#include "network_includes.h"

static uint16 latest_egc_throttle;
static int egc_socket;

int32 EGCSIM_HWIF_Init(void) {
    struct sockaddr_in socket_address;

    egc_socket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (egc_socket >= 0) {
        int status;

        socket_address.sin_family = AF_INET;
        socket_address.sin_addr.s_addr = htonl(INADDR_ANY);
        socket_address.sin_port = htons(3636);

        status = bind(egc_socket, (struct sockaddr *)&socket_address, sizeof(socket_address));
        if (status == ERROR) {
            return ERROR;
        }

        return CFE_SUCCESS;
    } else {
        return egc_socket;
    }
}

int32 EGCSIM_ReadDeviceData(uint16 *value) {
    int32 bytes_received;

    if (value == NULL) {
        return ERROR;
    }

    bytes_received = recvfrom(egc_socket, value, 2, MSG_DONTWAIT, 0, 0);
    if (bytes_received == 2) {
        latest_egc_throttle = *value;
    } else {
        *value = latest_egc_throttle;
    }

    return CFE_SUCCESS;
}
