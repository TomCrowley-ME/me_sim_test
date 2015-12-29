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
#ifndef HS_MSG_H
#define HS_MSG_H

/* HS Command Codes */
#define HS_NOOP_CC               0
#define HS_RESETCTRS_CC          1
#define HS_ENABLE_APP_MON_CC     2
#define HS_DISABLE_APP_MON_CC    3
#define HS_ENABLE_EVENT_MON_CC   4
#define HS_DISABLE_EVENT_MON_CC  5
#define HS_RESET_RESETS_CC       8
#define HS_SET_MAX_RESETS_CC     9

typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
} HS_NoArgsCmd_t;

typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;
    uint8  CommandCount;
    uint8  ErrorCount;
    uint8  CPUAverage;
    uint8  CPUPeak;
    uint8  AppMonitorStatus;
    uint8  EventMonitorStatus;
    uint8  EventCount;
    uint8  ExeCountErrors;
    uint32 ExeCount[HS_MAX_EXEC_CNT_SLOTS];
    uint32 MemFree;
} HS_HkPacket_t;

#endif
