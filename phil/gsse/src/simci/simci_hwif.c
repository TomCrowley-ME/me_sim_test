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
#include "simci.h"
#include "cfe.h"
#include "app_perfids.h"
#include "network_includes.h"

#include "pru_icss.h"
#include "puppetmaster_interface.h"

int32 SIMCI_HWIF_Init(void) {
    return CFE_SUCCESS;
}

void SIMCI_ForwardUplinkPacket(void) {
    int32 bytes_received;

    CFE_ES_PerfLogEntry(SIMCI_UPLINK_RCV_PERF_ID);

    /* First make sure we don't clobber an already sending frame */
    if (pru_icss_check_event(RADIO_UPLINK_EVENT) == 1) {
        CFE_EVS_SendEvent(SIMCI_UPLINK_ERR_EID, CFE_EVS_ERROR, "SIMCI: PRU has not sent previous frame, dropping the new one, errno=0x%08X", errno);
        SIMCI_AppData.HkPacket.uplink_errors++;

        CFE_ES_PerfLogExit(SIMCI_UPLINK_RCV_PERF_ID);
        return;
    }

    /* Read the packet into the PRU DRAM */
    bytes_received = recvfrom(SIMCI_AppData.UplinkSocketID,
                              (void*)(PRU0_DRAM_BASE + RADIO_UPLINK_BUFFER_ADDR),
                              SIMCI_MAX_INGEST, MSG_DONTWAIT, 0, 0);


    if (bytes_received == ERROR) {
        /* It broke! */
        CFE_EVS_SendEvent(SIMCI_UPLINK_ERR_EID, CFE_EVS_ERROR, "SIMCI: Error receiving from uplink socket, errno=0x%08X", errno);
        SIMCI_AppData.HkPacket.uplink_errors++;
    } else {
        /* Notify the PRU of how many bytes it should be sending */
        CFE_PSP_MemWrite32(PRU0_DRAM_BASE + PM_RADIO_UPLINK_LEN, bytes_received);

        /* ...And tell it that it has something to uplink */
        pru_icss_set_event(RADIO_UPLINK_EVENT);

        SIMCI_AppData.HkPacket.uplink_packets++;
    }
    CFE_ES_PerfLogExit(SIMCI_UPLINK_RCV_PERF_ID);
}
