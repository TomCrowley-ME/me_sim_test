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
#include "sc_task.h"

extern SC_AppData_t SC_AppData;

static int SC_ATS_CompareCmds(const void *a, const void *b);

int32 SC_ATS_Register(void) {
    int32 Status;

    Status = CFE_TBL_Register(&SC_AppData.ATSHandle[0], "ATS_TBL1", SC_ATS_BUFF_SIZE, CFE_TBL_OPT_DEFAULT, SC_ATS_Validate);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(SC_TBL_REG_ERR_EID, CFE_EVS_ERROR, "Failed to register ATSA, RC=0x%08X", Status);
        return Status;
    }
    CFE_TBL_Manage(SC_AppData.ATSHandle[0]);

    Status = CFE_TBL_Register(&SC_AppData.ATSHandle[1], "ATS_TBL2", SC_ATS_BUFF_SIZE, CFE_TBL_OPT_DEFAULT, SC_ATS_Validate);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(SC_TBL_REG_ERR_EID, CFE_EVS_ERROR, "Failed to register ATSB, RC=0x%08X", Status);
        return Status;
    }
    CFE_TBL_Manage(SC_AppData.ATSHandle[1]);

    return CFE_SUCCESS;
}

int32 SC_ATS_Prepare(uint8 AtsNum) {
    int32 Status = CFE_SUCCESS;
    int32 RetVal = CFE_SUCCESS;
    uint32 i = 0;
    uint16 CmdIndex = 0;
    uint16 CmdCount = 0;
    uint16 Offset = 0;
    uint8 *AtsBuffer = 0;
    SC_ATSEntry_t *AtsEntry = NULL;
    CFE_TIME_SysTime_t CurrentTime;

    if (AtsNum != 1 && AtsNum != 2) {
        return -1;
    }

    Status = CFE_TBL_GetAddress((void*)&AtsBuffer, SC_AppData.ATSHandle[AtsNum-1]);

    if (Status != CFE_SUCCESS && Status != CFE_TBL_INFO_UPDATED) {
        if (Status == CFE_TBL_ERR_NEVER_LOADED) {
            CFE_TBL_ReleaseAddress(SC_AppData.ATSHandle[AtsNum-1]);
        }
        CFE_EVS_SendEvent(SC_ACQ_PTR_ERR_EID, CFE_EVS_ERROR, "Unable to get pointer to ATS%u, RC=0x%08X", AtsNum, Status);
        return -1;
    }

    /* Clear out the ATS command info structure */
    CFE_PSP_MemSet(SC_AppData.ATSCmdInfo, 0, sizeof(SC_AppData.ATSCmdInfo));

    /* Look up the first command index to see if we have any work to do */
    AtsEntry = (SC_ATSEntry_t *)&AtsBuffer[Offset];
    CFE_PSP_MemCpy(&CmdIndex, &AtsEntry->CmdId, sizeof(CmdIndex));
#ifdef SOFTWARE_LITTLE_BIT_ORDER
    CmdIndex = ntohs(CmdIndex);
#endif

    while (CmdIndex != 0 && CmdCount <= SC_MAX_ATS_CMDS) {
        uint16 MsgSize;
        CFE_SB_CmdHdr_t CmdHeader;

        /* Save the command index and offset to the start of the command */
        SC_AppData.ATSCmdInfo[CmdCount].CmdId = CmdIndex;
        SC_AppData.ATSCmdInfo[CmdCount].Offset = Offset + offsetof(SC_ATSEntry_t, CmdHeader);
        CFE_PSP_MemCpy(&SC_AppData.ATSCmdInfo[CmdCount].Timestamp, &AtsEntry->Timestamp, sizeof(uint32));
#ifdef SOFTWARE_LITTLE_BIT_ORDER
        SC_AppData.ATSCmdInfo[CmdCount].Timestamp = ntohl(SC_AppData.ATSCmdInfo[CmdCount].Timestamp);
#endif

        /* Copy the whole header out of the table to safely calculate its length... */
        CFE_PSP_MemCpy(&CmdHeader, &AtsEntry->CmdHeader, CFE_SB_CMD_HDR_SIZE);

        SC_AppData.ATSCmdInfo[CmdCount].Length = CFE_SB_GetTotalMsgLength((CFE_SB_MsgPtr_t)&CmdHeader);

        /* Calculate the new offset based on the message size */
        MsgSize = CFE_SB_GetUserDataLength((CFE_SB_MsgPtr_t)&CmdHeader);
        Offset += sizeof(SC_ATSEntry_t) + MsgSize;

        /* Set up the entry pointer and command index for the next iteration */
        AtsEntry = (SC_ATSEntry_t *)&AtsBuffer[Offset];
        CFE_PSP_MemCpy(&CmdIndex, &AtsEntry->CmdId, sizeof(CmdIndex));
#ifdef SOFTWARE_LITTLE_BIT_ORDER
        CmdIndex = ntohs(CmdIndex);
#endif

        CmdCount++;
    }

    /* Sort the new bunch of commands */
    qsort(SC_AppData.ATSCmdInfo, CmdCount, sizeof(SC_ATSCmdInfo_t), SC_ATS_CompareCmds);

    /* Look for where we are in the new ATS... */
    CurrentTime = CFE_TIME_GetTime();
    for (i = 0; i < CmdCount; i++) {
        if (CurrentTime.Seconds <= SC_AppData.ATSCmdInfo[i].Timestamp) {
            break;
        }
    }

    if (i != CmdCount) {
        if (i > 0) {
            CFE_EVS_SendEvent(SC_ATS_SKIP_ERR_EID, CFE_EVS_ERROR, "ATS starts at %u and current time is %u, skipping %u commands", SC_AppData.ATSCmdInfo[0].Timestamp, CurrentTime.Seconds, i);
        }
        /* Set up metadata for running this ATS */
        SC_AppData.NextATSCmdIndex = i;
        SC_AppData.HkPacket.AtsNumber = AtsNum;
        SC_AppData.HkPacket.AtsCmdNumber = SC_AppData.ATSCmdInfo[i].CmdId;
        SC_AppData.HkPacket.NextAtsTime = SC_AppData.ATSCmdInfo[i].Timestamp;
        RetVal = CFE_SUCCESS;
    } else {
        /* There are no commands for us to execute... */
        CFE_EVS_SendEvent(SC_ATS_SKIP_ERR_EID, CFE_EVS_ERROR, "cannot start ATS that occurs entirely in the past!");
        RetVal = -1;
    }

    CFE_TBL_ReleaseAddress(SC_AppData.ATSHandle[AtsNum-1]);

    return RetVal;
}

void SC_ATS_Update(CFE_TIME_SysTime_t CurrentTime) {
    int32 Status;
    uint8 *AtsBuffer;

    /* Only do anything if the ATS is active */
    if (SC_AppData.HkPacket.AtsState == SC_ATS_EXECUTING) {
        uint32 NextCmdTime = 0;
        uint32 AtsIdx = SC_AppData.HkPacket.AtsNumber-1;
        /* Get a pointer to the ATS */
        Status = CFE_TBL_GetAddress((void*)&AtsBuffer, SC_AppData.ATSHandle[AtsIdx]);

        if (Status != CFE_SUCCESS && Status != CFE_TBL_INFO_UPDATED) {
            if (Status == CFE_TBL_ERR_NEVER_LOADED) {
                CFE_TBL_ReleaseAddress(SC_AppData.ATSHandle[AtsIdx]);
            }
            CFE_EVS_SendEvent(SC_ACQ_PTR_ERR_EID, CFE_EVS_ERROR, "Unable to get pointer to ATS%u, RC=0x%08X", SC_AppData.HkPacket.AtsNumber, Status);
            return;
        }

        /* First check to see if something has caused us to overrun commands */
        NextCmdTime = SC_AppData.ATSCmdInfo[SC_AppData.NextATSCmdIndex].Timestamp;
        if (CurrentTime.Seconds > NextCmdTime) {
            uint32 i = SC_AppData.NextATSCmdIndex;

            while (SC_AppData.ATSCmdInfo[i].Timestamp < CurrentTime.Seconds && SC_AppData.ATSCmdInfo[i].Timestamp != 0) {
                i++;
            }

            CFE_EVS_SendEvent(SC_ATS_SKIP_ERR_EID, CFE_EVS_ERROR, "Unexpected time jump (current time=%u, expected cmd time=%u), skipping %u commands...", CurrentTime.Seconds, NextCmdTime, i-SC_AppData.NextATSCmdIndex);

            if (SC_AppData.ATSCmdInfo[i].Timestamp == 0) {
                /* Apparently we skipped past the end... */
                SC_ATS_Stop(SC_STOP_ON_ERROR);
                CFE_TBL_ReleaseAddress(SC_AppData.ATSHandle[AtsIdx]);
                return;
            } else {
                SC_AppData.NextATSCmdIndex = i;
                NextCmdTime = SC_AppData.ATSCmdInfo[i].Timestamp;
                SC_AppData.HkPacket.NextAtsTime = NextCmdTime;
                SC_AppData.HkPacket.AtsCmdNumber = SC_AppData.ATSCmdInfo[i].CmdId;
            }
        }

        /* Now that we've caught up if necessary, send this cycle's commands, if any */
        while (NextCmdTime == CurrentTime.Seconds) {
            CFE_SB_ZeroCopyHandle_t MsgHandle;
            CFE_SB_MsgPtr_t MsgPtr;
            uint16 Length;
            /* Commands in the ATS can be unaligned, so fill SB buffers ourselves to prevent SB from doing anything stupid */
            Length = SC_AppData.ATSCmdInfo[SC_AppData.NextATSCmdIndex].Length;
            MsgPtr = CFE_SB_ZeroCopyGetPtr(Length, &MsgHandle);

            if (MsgPtr == NULL) {
                CFE_EVS_SendEvent(SC_BUF_ERR_EID, CFE_EVS_ERROR, "Received null ZeroCopy buffer, not sending message %u", SC_AppData.NextATSCmdIndex);
                SC_AppData.HkPacket.AtsCmdErrCtr++;
                SC_AppData.HkPacket.LastAtsErrCmd = SC_AppData.HkPacket.AtsCmdNumber;
                SC_AppData.HkPacket.LastAtsErrSeq = 0;

                if (SC_AppData.HkPacket.ContinueAtsOnFailure == FALSE) {
                    SC_ATS_Stop(SC_STOP_ON_ERROR);
                    break;
                }
            } else {
                CFE_PSP_MemCpy(MsgPtr, &AtsBuffer[SC_AppData.ATSCmdInfo[SC_AppData.NextATSCmdIndex].Offset], Length);

                if (CFE_SB_ValidateChecksum(MsgPtr)) {
                    CFE_SB_ZeroCopySend(MsgPtr, MsgHandle);
                    SC_AppData.HkPacket.AtsCmdCtr++;
                } else {
                    CFE_EVS_SendEvent(SC_CHKSUM_ERR_EID, CFE_EVS_ERROR, "Failed checksum for ATS command %u", SC_AppData.NextATSCmdIndex);
                    CFE_SB_ZeroCopyReleasePtr(MsgPtr, MsgHandle);
                    SC_AppData.HkPacket.AtsCmdErrCtr++;
                    SC_AppData.HkPacket.LastAtsErrCmd = SC_AppData.HkPacket.AtsCmdNumber;
                    SC_AppData.HkPacket.LastAtsErrSeq = 1;

                    if (SC_AppData.HkPacket.ContinueAtsOnFailure == FALSE) {
                        SC_ATS_Stop(SC_STOP_ON_ERROR);
                        break;
                    }
                }
            }

            /* Update counters... */
            SC_AppData.NextATSCmdIndex++;
            SC_AppData.HkPacket.NextAtsTime = SC_AppData.ATSCmdInfo[SC_AppData.NextATSCmdIndex].Timestamp;
            SC_AppData.HkPacket.AtsCmdNumber = SC_AppData.ATSCmdInfo[SC_AppData.NextATSCmdIndex].CmdId;

            NextCmdTime = SC_AppData.HkPacket.NextAtsTime;
            if (NextCmdTime == 0) {
                SC_ATS_Stop(SC_STOP_ON_COMPLETE);
            }
        }

        CFE_TBL_ReleaseAddress(SC_AppData.ATSHandle[AtsIdx]);
    }
}

void SC_ATS_Jump(uint32 NewTime) {
    uint32 i = 0;

    /* Search for the first timestamp that comes on or after our new time */
    while (NewTime > SC_AppData.ATSCmdInfo[i].Timestamp && SC_AppData.ATSCmdInfo[i].Timestamp != 0) {
        i++;
    }

    if (SC_AppData.ATSCmdInfo[i].Timestamp == 0) {
        /* We jumped right past the end */
        SC_ATS_Stop(SC_STOP_ON_ATS_JUMP);
    } else {
        SC_AppData.HkPacket.NextAtsTime = SC_AppData.ATSCmdInfo[i].Timestamp;
        SC_AppData.HkPacket.AtsCmdNumber = SC_AppData.ATSCmdInfo[i].CmdId;
        SC_AppData.NextATSCmdIndex = i;
        CFE_EVS_SendEvent(SC_ATS_JUMP_INF_EID, CFE_EVS_INFORMATION, "Jumped to command %u at %us in ATS %u", SC_AppData.ATSCmdInfo[i].CmdId, SC_AppData.ATSCmdInfo[i].Timestamp, SC_AppData.HkPacket.AtsNumber);
    }
}

void SC_ATS_Stop(uint8 Reason) {
    SC_AppData.HkPacket.AtsState = SC_ATS_IDLE;
    SC_AppData.HkPacket.AtsCmdNumber = 0;
    SC_AppData.HkPacket.NextAtsTime = 0;

    switch (Reason) {
        case SC_STOP_ON_COMPLETE:
            CFE_EVS_SendEvent(SC_ATS_FINISH_INF_EID, CFE_EVS_INFORMATION, "Completed ATS %u", SC_AppData.HkPacket.AtsNumber);
            break;
        case SC_STOP_ON_COMMAND:
            CFE_EVS_SendEvent(SC_ATS_STOP_INF_EID, CFE_EVS_INFORMATION, "Stopped ATS %u", SC_AppData.HkPacket.AtsNumber);
            break;
        case SC_STOP_ON_ATS_JUMP:
            CFE_EVS_SendEvent(SC_ATS_STOP_INF_EID, CFE_EVS_INFORMATION, "Time jump past the end of ATS %u, stopping it", SC_AppData.HkPacket.AtsNumber);
            break;
        case SC_STOP_ON_TABLE_UPDATE:
            CFE_EVS_SendEvent(SC_ATS_UPDATE_STOP_ERR_EID, CFE_EVS_ERROR, "Table updated for active ATS %u, stopping it", SC_AppData.HkPacket.AtsNumber);
            break;
        default:
            CFE_EVS_SendEvent(SC_ATS_ERROR_STOP_ERR_EID, CFE_EVS_ERROR, "Stopped ATS %u on error", SC_AppData.HkPacket.AtsNumber);
            break;
    }
    SC_AppData.HkPacket.AtsNumber = 0;
}


int32 SC_ATS_Validate(void* buffer) {
    return CFE_SUCCESS;
}

static int SC_ATS_CompareCmds(const void *a, const void *b) {
    SC_ATSCmdInfo_t *Cmd1 = (SC_ATSCmdInfo_t *)a;
    SC_ATSCmdInfo_t *Cmd2 = (SC_ATSCmdInfo_t *)b;
    /* Compare first by timestamp... */
    if (Cmd1->Timestamp < Cmd2->Timestamp) {
        return -1;
    } else if (Cmd1->Timestamp > Cmd2->Timestamp) {
        return 1;
    } else {
        /* ...and second by ID */
        if (Cmd1->CmdId < Cmd2->CmdId) {
            return -1;
        } else {
            return 1;
        }
    }
}
