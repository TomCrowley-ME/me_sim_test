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
#ifndef MEMSSIM_H
#define MEMSSIM_H

#include "cfe_es.h"
#include "cfe_sb.h"
#include "cfe_evs.h"

/* MEMSSIM Configuration Parameters */
#define MEMSSIM_PIPE_DEPTH             4

/* MEMSSIM Command Codes */
#define MEMSSIM_NOOP_CC             0x00
#define MEMSSIM_RESETCTRS_CC        0x01

/* MEMSSIM Event IDs */
#define MEMSSIM_INIT_INF_EID           1
#define MEMSSIM_NOOP_INF_EID           2
#define MEMSSIM_CRCMDPIPE_ERR_EID     20
#define MEMSSIM_SUBSCRIBE_ERR_EID     21
#define MEMSSIM_MSGID_ERR_EID         22
#define MEMSSIM_CC1_ERR_EID           23
#define MEMSSIM_MSGLEN_ERR_EID        24
#define MEMSSIM_DEVICE_ERR_EID        25
#define MEMSSIM_PIPE_ERR_EID          26
#define MEMSSIM_HWIF_ERR_EID          27

#define MEMSSIM_FILTERED_EVT_COUNT     8

/* MEMSSIM Structure Definitions */
typedef struct {
    int16 accel[3];
    int16 temp;
    int16 gyro[3];
} mems_reading_t;

typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;
    mems_reading_t mem1;
    mems_reading_t mem2;
    mems_reading_t mem3;
} mem_veh_msg_t;

typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;

    uint8  command_count;
    uint8  error_count;
    uint8  pad[2];
    uint32 mems_write_count;
} MEMSSIM_HkPacket_t;

typedef struct {
    CFE_SB_PipeId_t CmdPipe;
    CFE_SB_MsgPtr_t MsgPtr;

    MEMSSIM_HkPacket_t HkPacket;

    CFE_EVS_BinFilter_t EventFilters[MEMSSIM_FILTERED_EVT_COUNT];
} MEMSSIM_AppData_t;

typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
} OS_PACK MEMSSIM_NoArgsCmd_t;

/* MEMSSIM Function Prototypes */
void    MEMSSIM_TaskMain(void);
int32   MEMSSIM_Init(void);
int32   MEMSSIM_HWIF_Init(void);
void    MEMSSIM_ResetCounters(void);
void    MEMSSIM_AppPipe(void);
int32   MEMSSIM_WriteDeviceData(mem_veh_msg_t *mem_veh_msg);
void    MEMSSIM_ProcessGroundCommand(void);
void    MEMSSIM_ReportHousekeeping(void);
boolean MEMSSIM_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength);
void    MEMSSIM_SendDeviceReadings(void);

/* MEMSSIM Global Data */
extern MEMSSIM_AppData_t MEMSSIM_AppData;

#endif
