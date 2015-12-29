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
#ifndef IMUSIM_H
#define IMUSIM_H

#include "cfe_es.h"
#include "cfe_sb.h"
#include "cfe_evs.h"

/* IMUSIM Configuration Parameters */
#define IMUSIM_PIPE_DEPTH             4

/* IMUSIM Command Codes */
#define IMUSIM_NOOP_CC             0x00
#define IMUSIM_RESETCTRS_CC        0x01

/* IMUSIM Event IDs */
#define IMUSIM_INIT_INF_EID           1
#define IMUSIM_NOOP_INF_EID           2
#define IMUSIM_CRCMDPIPE_ERR_EID     20
#define IMUSIM_SUBSCRIBE_ERR_EID     21
#define IMUSIM_MSGID_ERR_EID         22
#define IMUSIM_CC1_ERR_EID           23
#define IMUSIM_MSGLEN_ERR_EID        24
#define IMUSIM_DEVICE_ERR_EID        25
#define IMUSIM_PIPE_ERR_EID          26
#define IMUSIM_HWIF_ERR_EID          27

#define IMUSIM_FILTERED_EVT_COUNT     8

/* IMUSIM Structure Definitions */
typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;
    int32 gyro[3];
    int32 accel[3];
    int32 incline[3];
} imu_veh_msg_t;

typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;

    uint8  command_count;
    uint8  error_count;
    uint8  pad[2];
    uint32 imu_write_count;
} IMUSIM_HkPacket_t;

typedef struct {
    CFE_SB_PipeId_t CmdPipe;
    CFE_SB_MsgPtr_t MsgPtr;

    IMUSIM_HkPacket_t HkPacket;

    CFE_EVS_BinFilter_t EventFilters[IMUSIM_FILTERED_EVT_COUNT];
} IMUSIM_AppData_t;

typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
} OS_PACK IMUSIM_NoArgsCmd_t;

/* IMUSIM Function Prototypes */
void    IMUSIM_TaskMain(void);
int32   IMUSIM_Init(void);
int32   IMUSIM_HWIF_Init(void);
void    IMUSIM_ResetCounters(void);
void    IMUSIM_AppPipe(void);
int32   IMUSIM_WriteDeviceData(imu_veh_msg_t *imu_veh_msg);
void    IMUSIM_ProcessGroundCommand(void);
void    IMUSIM_ReportHousekeeping(void);
boolean IMUSIM_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength);
void    IMUSIM_SendDeviceReadings(void);

/* IMUSIM Global Data */
extern IMUSIM_AppData_t IMUSIM_AppData;

#endif
