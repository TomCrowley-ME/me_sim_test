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
#ifndef DS_MSG_H
#define DS_MSG_H

#include "ds_cfg.h"

/* DS Command Codes */
#define DS_NOOP_CC               0
#define DS_RESETCTRS_CC          1

typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
} DS_NoArgsCmd_t;

typedef struct {
    uint32 Age;
    uint32 Size;
    uint32 Rate;
    uint32 Sequence;
    uint16 EnableState;
    uint16 OpenState;
} DS_FileStatus_t;

typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;
    uint16 CommandCount;
    uint16 ErrorCount;
    uint32 DisabledPktCount;
    uint32 IgnoredPktCount;
    uint32 FilteredPktCount;
    uint32 PassedPktCount;
    uint16 FileWriteCount;
    uint16 FileWriteErrCount;
    uint16 FileUpdateCount;
    uint16 FileUpdateErrCount;
    uint16 DestTblLoadCount;
    uint16 DestPtrErrCount;
    uint16 FilterTblLoadCount;
    uint16 FilterPtrErrCount;
    uint16 AppEnableState;
    uint16 Pad1;
    DS_FileStatus_t FileStatus[DS_DEST_FILE_CNT];
} DS_HkPacket_t;

#endif
