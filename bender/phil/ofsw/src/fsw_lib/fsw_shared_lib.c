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
#include "moonex_cab.h"
#include "fsw_lib.h"

CCSDS_AOS_Transfer_Frame_t MasterFrameList[MAX_VCS][FRAMES_PER_VC];
uint16 FreeFramePostn[MAX_VCS][FRAMES_PER_VC];
uint8 FrameId[MAX_VCS];
uint32 MasterFrameCounter[MAX_VCS];

int32 fsw_lib_init(void) {
    uint32 i;
    uint32 j;
    uint8 SCID;

    SCID = cabGetSCID();

    for (i = 0; i < MAX_VCS; i++) {

        MasterFrameCounter[i] = 0;
        FrameId[i] = 0;

        for (j = 0; j < FRAMES_PER_VC; j++) {
            CCSDS_AOS_Transfer_Frame_t *frame = &MasterFrameList[i][j];

            frame->CADU_Sync = 0x1ACFFC1D;

            frame->VCDU_Header.Version = 1;
            frame->VCDU_Header.SCID = SCID;
            frame->VCDU_Header.VCID = i+1;
            frame->VCDU_Header.ReplayFlag = 0;
            frame->VCDU_Header.Spare = 0;

            frame->M_PDU_Header.Spare = 0;
            frame->M_PDU_Header.FirstHeader = 0;

            FreeFramePostn[i][j] = 12;
        }
    }

    OS_printf("FSW_LIB Initialized\n");
    return CFE_SUCCESS;
}


CCSDS_AOS_Transfer_Frame_t* CCSDS_GetFrame(uint16 vc, uint8 index) {
    if (vc == 0 || vc > MAX_VCS || index >= FRAMES_PER_VC) {
        return NULL;
    }
    return &MasterFrameList[vc-1][index];
}


uint8 CCSDS_GetCurrFrameId(uint16 vc) {
    if (vc == 0 || vc > MAX_VCS) {
        return 0xff;
    }
    return FrameId[vc-1];
}


uint8 CCSDS_GetNextFrameId(uint16 vc) {
    uint16 newFrameId;
    if (vc == 0 || vc > MAX_VCS) {
        return 0xff;
    }
    newFrameId = (FrameId[vc-1] + 1) % FRAMES_PER_VC;
    FreeFramePostn[vc-1][newFrameId] = 12;
    FrameId[vc-1] = newFrameId;
    return newFrameId;
}


uint8 CCSDS_FrameIsExactlyFull(uint16 vc, uint8 index) {
    if (vc == 0 || vc > MAX_VCS) {
        return 0xff;
    }
    return (FreeFramePostn[vc-1][index] == 1117);
}
