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

#include "stdio.h"
#include "string.h"

extern SC_AppData_t SC_AppData;

int32 SC_RTS_Register(void) {
    int32 Status;
    os_dirp_t RtsDir;
    os_dirent_t *RtsFile;

    /* Open the RTS folder for searching */
    RtsDir = OS_opendir(SC_FILENAME_PATH);
    if (RtsDir == NULL) {
        CFE_EVS_SendEvent(SC_TBL_REG_ERR_EID, CFE_EVS_CRITICAL, "RTS directory does not exist!");
        return -1;
    }

    /* Initialize the RTS Info Table to 0 */
    CFE_PSP_MemSet(SC_AppData.RTSInfo, 0, sizeof(SC_AppData.RTSInfo));

    do {
        RtsFile = OS_readdir(RtsDir);
        if (RtsFile != NULL) {
            uint32 RtsNum;
            int Consumed;

            Status = sscanf(RtsFile->d_name, "rts_%u%*[^.].tbl%n", &RtsNum, &Consumed);

            /* Valid matches must be of the format rts_<num>*.tbl */
            if (Status == 1 && Consumed == strlen(RtsFile->d_name)) {
                char RtsTableName[12];

                if (RtsNum == 0 || RtsNum > SC_NUMBER_OF_RTS) {
                    CFE_EVS_SendEvent(SC_BAD_RTS_ERR_EID, CFE_EVS_ERROR, "Ignoring out-of-range RTS %u", RtsNum);
                    continue;
                }

                /* Don't load a duplicate RTS */
                if (SC_AppData.RTSHandle[RtsNum-1] != CFE_TBL_BAD_TABLE_HANDLE) {
                    CFE_EVS_SendEvent(SC_BAD_RTS_ERR_EID, CFE_EVS_ERROR, "Ignoring duplicate RTS %u", RtsNum);
                    continue;
                }

                /* We've got a good candidate RTS file. Let's try to register and load it */
                sprintf(RtsTableName, "RTS_TBL%03u", RtsNum);
                Status = CFE_TBL_Register(&SC_AppData.RTSHandle[RtsNum-1], RtsTableName, SC_RTS_BUFF_SIZE, CFE_TBL_OPT_DEFAULT, SC_RTS_Validate);
                if (Status == CFE_SUCCESS) {
                    char FullFilePath[OS_MAX_PATH_LEN] = SC_FILENAME_PATH;

                    /* Construct the full path to the table for loading */
                    strncat(FullFilePath, RtsFile->d_name, OS_MAX_PATH_LEN);
                    FullFilePath[OS_MAX_PATH_LEN-1] = '\0';

                    Status = CFE_TBL_Load(SC_AppData.RTSHandle[RtsNum-1], CFE_TBL_SRC_FILE, FullFilePath);
                    if (Status != CFE_SUCCESS) {
                        CFE_EVS_SendEvent(SC_TBL_LOAD_ERR_EID, CFE_EVS_ERROR, "Failed to load RTS %u (%s), RC=0x%08X", RtsNum, FullFilePath, Status);
                    } else {
                        /* Successful load! Manage the table, set its status to idle, and enable it */
                        CFE_TBL_Manage(SC_AppData.RTSHandle[RtsNum-1]);
                        SC_AppData.RTSInfo[RtsNum-1].Status = SC_RTS_IDLE;
                        SC_AppData.RTSInfo[RtsNum-1].EnableState = SC_RTS_ENABLED;
                        SC_AppData.RTSInfo[RtsNum-1].DisableOnFinish = FALSE;
                    }
                } else {
                    CFE_EVS_SendEvent(SC_TBL_REG_ERR_EID, CFE_EVS_ERROR, "Error registering table for RTS %u", RtsNum);
                }
            }
        }
    } while (RtsFile != NULL);

    OS_closedir(RtsDir);

    return CFE_SUCCESS;
}

void SC_RTS_UpdateAll(CFE_TIME_SysTime_t CurrentTime) {
    uint16 i;
    CFE_TIME_SysTime_t ToleranceTime;
    CFE_TIME_SysTime_t ComparisonTime;

    /* Add the tolerance for RTS times */
    ToleranceTime.Seconds = 0;
    ToleranceTime.Subseconds = CFE_TIME_Micro2SubSecs(SC_RTS_TIME_TOLERANCE);

    ComparisonTime = CFE_TIME_Add(CurrentTime, ToleranceTime);

    for (i=0; i < SC_NUMBER_OF_RTS; i++) {
        if (SC_AppData.RTSInfo[i].Status == SC_RTS_EXECUTING) {
            CFE_TIME_Compare_t Result;

            Result = CFE_TIME_Compare(SC_AppData.RTSInfo[i].NextCmdTime, ComparisonTime);
            if (Result != CFE_TIME_A_GT_B) {
                CFE_TIME_SysTime_t Difference;
                uint32 MicroSecs;

                Difference = CFE_TIME_Subtract(ComparisonTime, SC_AppData.RTSInfo[i].NextCmdTime);
                MicroSecs = CFE_TIME_Sub2MicroSecs(Difference.Subseconds);
                if (Difference.Seconds != 0 || MicroSecs > SC_RTS_MAX_ERROR) {
                    CFE_EVS_SendEvent(SC_RTS_LATE_ERR_EID, CFE_EVS_ERROR, "Delay detected, sending RTS %u command %u %u.%06us late", i+1, SC_AppData.RTSInfo[i].NextCmdNum, Difference.Seconds, MicroSecs);
                }

                SC_RTS_SendCommands(i+1, CurrentTime);
            }
        }
    }
}

int32 SC_RTS_Start(uint16 RtsNum) {
    int32 Status;
    uint8 *RtsBuffer;
    uint16 RtsIdx;
    uint16 InitialDelay;
    CFE_TIME_SysTime_t StartTime;
    CFE_SB_CmdHdr_t FirstCmdHdr;

    RtsIdx = RtsNum-1;

    /* Grab a pointer to the RTS */
    Status = CFE_TBL_GetAddress((void*)&RtsBuffer, SC_AppData.RTSHandle[RtsIdx]);

    if (Status != CFE_SUCCESS && Status != CFE_TBL_INFO_UPDATED) {
        if (Status == CFE_TBL_ERR_NEVER_LOADED) {
            CFE_TBL_ReleaseAddress(SC_AppData.RTSHandle[RtsIdx]);
        }
        SC_AppData.HkPacket.RtsActivErrCtr++;
        CFE_EVS_SendEvent(SC_ACQ_PTR_ERR_EID, CFE_EVS_ERROR, "Unable to get pointer to RTS%u, RC=0x%08X", RtsNum, Status);
        return -1;
    }

    /* Set up status info and increment counters */
    SC_AppData.RTSInfo[RtsIdx].Status = SC_RTS_EXECUTING;
    SC_AppData.RTSInfo[RtsIdx].NextCmdPtr = 2;
    SC_AppData.RTSInfo[RtsIdx].NextCmdNum = 1;

    SC_AppData.RTSInfo[RtsIdx].UseCount++;

    /* Get the current time, on which the execution of the RTS will be based */
    StartTime = CFE_TIME_GetTime();

    /* Copy in the initial command's delay and add it to the current time to get the initial command's time */
    CFE_PSP_MemCpy(&InitialDelay, &RtsBuffer[0], sizeof(InitialDelay));
#ifdef SOFTWARE_LITTLE_BIT_ORDER
    InitialDelay = ntohs(InitialDelay);
#endif

    StartTime.Seconds += InitialDelay;

    SC_AppData.RTSInfo[RtsIdx].NextCmdTime = StartTime;

    /* Copy in the first command's header to determine length */
    CFE_PSP_MemCpy(&FirstCmdHdr, &RtsBuffer[2], CFE_SB_CMD_HDR_SIZE);

    SC_AppData.RTSInfo[RtsIdx].NextCmdLength = CFE_SB_GetTotalMsgLength((CFE_SB_MsgPtr_t)&FirstCmdHdr);

    /* We're done with the table for now */
    CFE_TBL_ReleaseAddress(SC_AppData.RTSHandle[RtsIdx]);

    CFE_EVS_SendEvent(SC_RTS_START_INF_EID, CFE_EVS_INFORMATION, "Starting RTS %u", RtsNum);

    /* If the initial delay is 0, we need to update RIGHT NOW */
    if (InitialDelay == 0) {
        SC_RTS_SendCommands(RtsNum, StartTime);
    }

    return CFE_SUCCESS;
}

void SC_RTS_SendCommands(uint16 RtsNum, CFE_TIME_SysTime_t CurrentTime) {
    int32 Status;
    uint16 RtsIdx;
    uint16 Delay;
    uint8 *RtsBuffer;

    RtsIdx = RtsNum - 1;

    /* Grab a pointer to the RTS */
    Status = CFE_TBL_GetAddress((void*)&RtsBuffer, SC_AppData.RTSHandle[RtsIdx]);

    if (Status != CFE_SUCCESS && Status != CFE_TBL_INFO_UPDATED) {
        if (Status == CFE_TBL_ERR_NEVER_LOADED) {
            CFE_TBL_ReleaseAddress(SC_AppData.RTSHandle[RtsIdx]);
        }
        CFE_EVS_SendEvent(SC_ACQ_PTR_ERR_EID, CFE_EVS_ERROR, "Error sending RTS commands: Unable to get pointer to RTS%u, RC=0x%08X", RtsNum, Status);
        return;
    }


    do {
        CFE_SB_ZeroCopyHandle_t MsgHandle;
        CFE_SB_MsgPtr_t MsgPtr;
        CFE_SB_CmdHdr_t NextCmdHdr;
        CFE_SB_MsgId_t NextMsgId;
        uint16 Length;

        Length = SC_AppData.RTSInfo[RtsIdx].NextCmdLength;
        MsgPtr = CFE_SB_ZeroCopyGetPtr(Length, &MsgHandle);

        if (MsgPtr == NULL) {
            CFE_EVS_SendEvent(SC_BUF_ERR_EID, CFE_EVS_ERROR, "Error sending command %u from RTS %u: Received null ZeroCopy buffer", SC_AppData.RTSInfo[RtsIdx].NextCmdNum, RtsNum);
            SC_AppData.HkPacket.RtsCmdErrCtr++;
            SC_AppData.HkPacket.LastRtsErrCmd = SC_AppData.RTSInfo[RtsIdx].NextCmdNum;
            SC_AppData.HkPacket.LastRtsErrNum = RtsNum;

            if (SC_AppData.HkPacket.ContinueRtsOnFailure == FALSE) {
                SC_RTS_Stop(RtsNum, SC_STOP_ON_ERROR);
                break;
            }
        }

        /* Copy, validate, and send the message */
        CFE_PSP_MemCpy(MsgPtr, &RtsBuffer[SC_AppData.RTSInfo[RtsIdx].NextCmdPtr], Length);

        if (CFE_SB_ValidateChecksum(MsgPtr)) {
            CFE_SB_ZeroCopySend(MsgPtr, MsgHandle);
            SC_AppData.RTSInfo[RtsIdx].ExecCount++;
            SC_AppData.HkPacket.RtsCmdCtr++;
        } else {
            CFE_EVS_SendEvent(SC_CHKSUM_ERR_EID, CFE_EVS_ERROR, "Failed checksum for RTS #%u command %u", RtsNum, SC_AppData.RTSInfo[RtsIdx].NextCmdNum);
            SC_AppData.HkPacket.RtsCmdErrCtr++;
            SC_AppData.HkPacket.LastRtsErrCmd = SC_AppData.RTSInfo[RtsIdx].NextCmdNum;
            SC_AppData.HkPacket.LastRtsErrNum = RtsNum;

            if (SC_AppData.HkPacket.ContinueRtsOnFailure == FALSE) {
                SC_RTS_Stop(RtsNum, SC_STOP_ON_ERROR);
                break;
            }
        }

        /* Set things up for the next command */

        /* Calculate the offset of the next command */
        SC_AppData.RTSInfo[RtsIdx].NextCmdPtr += Length + sizeof(uint16);
        if (SC_AppData.RTSInfo[RtsIdx].NextCmdPtr + CFE_SB_CMD_HDR_SIZE > SC_RTS_BUFF_SIZE) {
            /* Not enough room for a command, we're done */
            SC_RTS_Stop(RtsNum, SC_STOP_ON_COMPLETE);
            break;
        }

        /* Check to see if there *is* a next command  */
        CFE_PSP_MemCpy(&NextCmdHdr, &RtsBuffer[SC_AppData.RTSInfo[RtsIdx].NextCmdPtr], CFE_SB_CMD_HDR_SIZE);

        NextMsgId = CFE_SB_GetMsgId((CFE_SB_MsgPtr_t)&NextCmdHdr);
        if (NextMsgId == 0) {
            /* We've just sent the last command */
            SC_RTS_Stop(RtsNum, SC_STOP_ON_COMPLETE);
            break;
        }

        /* Update next command info based on what we've seen */
        SC_AppData.RTSInfo[RtsIdx].NextCmdLength = CFE_SB_GetTotalMsgLength((CFE_SB_MsgPtr_t)&NextCmdHdr);
        SC_AppData.RTSInfo[RtsIdx].NextCmdNum++;

        /* Last up is calculating time of run */
        CFE_PSP_MemCpy(&Delay, &RtsBuffer[SC_AppData.RTSInfo[RtsIdx].NextCmdPtr-sizeof(uint16)], sizeof(uint16));
#ifdef SOFTWARE_LITTLE_BIT_ORDER
        Delay = ntohs(Delay);
#endif


        /* Delay past the current seconds */
        SC_AppData.RTSInfo[RtsIdx].NextCmdTime = CurrentTime;
        SC_AppData.RTSInfo[RtsIdx].NextCmdTime.Seconds += Delay;

    } while (Delay == 0);

    CFE_TBL_ReleaseAddress(SC_AppData.RTSHandle[RtsIdx]);
}

void SC_RTS_Stop(uint16 RtsNum, uint8 Reason) {
    uint16 RtsIdx;

    RtsIdx = RtsNum - 1;

    SC_AppData.RTSInfo[RtsIdx].Status = SC_RTS_IDLE;
    SC_AppData.RTSInfo[RtsIdx].NextCmdPtr = 0;
    SC_AppData.RTSInfo[RtsIdx].NextCmdLength = 0;
    SC_AppData.RTSInfo[RtsIdx].NextCmdNum = 0;
    SC_AppData.RTSInfo[RtsIdx].NextCmdTime.Seconds = 0;
    SC_AppData.RTSInfo[RtsIdx].NextCmdTime.Subseconds = 0;

    switch (Reason) {
        case SC_STOP_ON_COMPLETE:
            CFE_EVS_SendEvent(SC_RTS_FINISH_INF_EID, CFE_EVS_INFORMATION, "Finished RTS %u", RtsNum);
            break;
        case SC_STOP_ON_COMMAND:
            CFE_EVS_SendEvent(SC_RTS_STOP_INF_EID, CFE_EVS_INFORMATION, "Stopped RTS %u", RtsNum);
            break;
        default:
            CFE_EVS_SendEvent(SC_RTS_ERROR_STOP_ERR_EID, CFE_EVS_ERROR, "Stopped RTS %u on error", RtsNum);
            break;
    }

    /* Check to see if we have a pending disable */
    if (SC_AppData.RTSInfo[RtsIdx].DisableOnFinish) {
        SC_AppData.RTSInfo[RtsIdx].EnableState = SC_RTS_DISABLED;
        SC_AppData.RTSInfo[RtsIdx].DisableOnFinish = FALSE;
        CFE_EVS_SendEvent(SC_RTS_DISABLE_INF_EID, CFE_EVS_INFORMATION, "Disabled RTS %u", RtsNum);
    }
}

int32 SC_RTS_Validate(void* buffer) {
    return CFE_SUCCESS;
}
