#ifdef _________________________________________________________________________
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
                                                                          #endif
#ifndef PRU_INTERFACE_H
#define PRU_INTERFACE_H

#ifdef _________________________________________________________________________
         ----- Status/Control Registers (in range 0x0000-0x00ff) -----
                                                                          #endif
#define PM_RADIO_UPLINK_LEN        (0x00)

#ifdef _________________________________________________________________________
                       ----- Scratch buffer ------
                                                                          #endif
#define PM_SCRATCH_BUFFER_ADDR     (0x0100)
#define PM_SCRATCH_BUFFER_LEN      (0x0100)

#ifdef _________________________________________________________________________
                         ----- I/O Buffers -----
                                                                          #endif
#define RADIO_UPLINK_BUFFER_ADDR   (0x0200)
#define RADIO_DOWNLINK_BUFFER_ADDR (0x0700)
#define VALVES_BUFFER_ADDR         (0x0c00)
#define MEMS1_BUFFER_ADDR          (0x0d00)
#define MEMS2_BUFFER_ADDR          (0x0d80)
#define MEMS3_BUFFER_ADDR          (0x0e00)
#define EGC_BUFFER_ADDR            (0x0e80)
#define THERMPOW_AD_BUFFER_ADDR    (0x0f00)
#define ST_BUFFER_ADDR             (0x1000)

#define GPS_BUFFER_ADDR            (RADIO_UPLINK_BUFFER_ADDR)
#define IMU_BUFFER_ADDR            (MEMS1_BUFFER_ADDR)

#ifdef _________________________________________________________________________
                      ----- Device System Events -----
                                                                          #endif
#define VALVES_READ_EVENT          (0)
#define RADIO_UPLINK_EVENT         (1)
#define ST_WRITE_EVENT             (2)
#define MEMS_WRITE_EVENT           (3)
#define THERMPOW_AD_WRITE_EVENT    (4)
#define EGC_READ_EVENT             (15)

#define RADIO_DOWNLINK_EVENT       (16)

#define GPS_WRITE_EVENT            (RADIO_UPLINK_EVENT)
#define IMU_WRITE_EVENT            (MEMS_WRITE_EVENT)

#endif
