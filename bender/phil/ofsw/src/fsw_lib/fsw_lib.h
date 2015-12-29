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
#ifndef FSW_LIB_H
#define FSW_LIB_H

#include "cfe.h"

#define MAX_VCS       2
#define FRAMES_PER_VC 8

typedef struct {
    unsigned int Version : 2;
    unsigned int SCID : 8;
    unsigned int VCID : 6;
    unsigned int Counter : 24;
    unsigned int ReplayFlag : 1;
    unsigned int Spare : 7;
} OS_PACK VCDU_Header_t;

typedef struct {
    unsigned int Spare : 5;
    unsigned int FirstHeader : 11;
} OS_PACK M_PDU_Header_t;

typedef struct {
    uint32 CADU_Sync;
    VCDU_Header_t VCDU_Header;
    M_PDU_Header_t M_PDU_Header;
    uint8  data[1105];
    uint8  crc[2];
} OS_PACK CCSDS_AOS_Transfer_Frame_t;

extern uint16 FreeFramePostn[MAX_VCS][FRAMES_PER_VC];
extern uint32 MasterFrameCounter[MAX_VCS];

CCSDS_AOS_Transfer_Frame_t* CCSDS_GetFrame(uint16 vc, uint8 index);
uint8 CCSDS_GetCurrFrameId(uint16 vc);
uint8 CCSDS_GetNextFrameId(uint16 vc);
uint8 CCSDS_FrameIsExactlyFull(uint16 vc, uint8 index);
uint16 CCSDS_CalculateCRC(uint8 *buf, uint32 len);

#endif
