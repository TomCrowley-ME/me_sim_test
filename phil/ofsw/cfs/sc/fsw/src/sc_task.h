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
#ifndef SC_TASK_H
#define SC_TASK_H

#include "cfe_sb.h"
#include "cfe_evs.h"
#include "cfe_tbl.h"
#include "network_includes.h"

#define SC_ATS_IDLE                 2
#define SC_ATS_EXECUTING            5

#define SC_RTS_DISABLED             0
#define SC_RTS_ENABLED              1

#define SC_RTS_UNLOADED             0
#define SC_RTS_IDLE                 2
#define SC_RTS_EXECUTING            5

#define SC_STOP_ON_COMPLETE         1
#define SC_STOP_ON_COMMAND          2
#define SC_STOP_ON_ERROR            3
#define SC_STOP_ON_ATS_JUMP         4
#define SC_STOP_ON_TABLE_UPDATE     5


/* SC general configuration parameters */
#define SC_MISSION_REV              0
#define SC_PIPE_DEPTH               12
#define SC_SAVE_TO_CDS              FALSE
#define SC_PACKET_MIN_SIZE          8
#define SC_PACKET_MAX_SIZE          250
#define SC_MAX_CMDS_PER_SEC         8
#define SC_TICK_MID                 TICK_10HZ_MID

/* SC ATS configuration parameters */
#define SC_ATS_CONT_ON_FAILURE_START TRUE
#define SC_MAX_ATS_CMDS              2048
#define SC_ATS_BUFF_SIZE             (48 * 1024)
#define SC_ATS_CMD_STAT_TABLE_NAME   "ATSCMD_TBL"
#define SC_ATS_CTRL_TABLE_NAME       "ATPCTR_TBL"
#define SC_ATSINFO_TABLE_NAME        "ATSINF_TBL"
#define SC_ATS_TABLE_NAME            "ATS_TBL"

/* SC RTS configuration parameters */
#define SC_RTS_CONT_ON_FAILURE_START TRUE
#define SC_NUMBER_OF_RTS             256
#define SC_LAST_RTS_WITH_EVENTS      128
#define SC_RTS_BUFF_SIZE             1800
#define SC_FILENAME_PATH             "/cf/rtbl/"
#define SC_RTS_FILE_NAME             "/cf/rtbl/RTS_TBL"
#define SC_RTP_CTRL_TABLE_NAME       "RTPCTR_TBL"
#define SC_RTS_TABLE_NAME            "RTS_TBL"
#define SC_RTSINFO_TABLE_NAME        "RTSINF_TBL"
#define SC_RTS_TIME_TOLERANCE        1000
#define SC_RTS_MAX_ERROR             100000

/* SC Command Codes */
#define SC_NOOP_CC             0x00
#define SC_RESETCTRS_CC        0x01
#define SC_START_ATS_CC        0x02
#define SC_STOP_ATS_CC         0x03
#define SC_START_RTS_CC        0x04
#define SC_STOP_RTS_CC         0x05
#define SC_DISABLE_RTS_CC      0x06
#define SC_ENABLE_RTS_CC       0x07
#define SC_SWITCH_ATS_CC       0x08
#define SC_ATS_JUMP_CC         0x09
#define SC_CONT_ATS_ON_FAIL_CC 0x0A
#define SC_CONT_RTS_ON_FAIL_CC 0x0B

/* SC Event IDs */
#define SC_INIT_INF_EID                  1
#define SC_NOOP_INF_EID                  2
#define SC_ATS_START_INF_EID             3
#define SC_ATS_JUMP_INF_EID              4
#define SC_ATS_STOP_INF_EID              5
#define SC_ATS_FINISH_INF_EID            6
#define SC_ATS_SWITCH_INF_EID            7
#define SC_ATS_CONT_INF_EID              8
#define SC_RTS_START_INF_EID             9
#define SC_RTS_STOP_INF_EID             10
#define SC_RTS_FINISH_INF_EID           11
#define SC_RTS_DISABLE_INF_EID          12
#define SC_RTS_ENABLE_INF_EID           13
#define SC_RTS_DISABLE_CANCEL_INF_EID   14
#define SC_RTS_CONT_INF_EID             15
#define SC_CRCMDPIPE_ERR_EID            20
#define SC_SUBSCRIBE_ERR_EID            21
#define SC_MSGID_ERR_EID                22
#define SC_CC1_ERR_EID                  23
#define SC_MSGLEN_ERR_EID               24
#define SC_PIPE_ERR_EID                 25
#define SC_TBL_REG_ERR_EID              26
#define SC_TBL_LOAD_ERR_EID             27
#define SC_BAD_RTS_ERR_EID              28
#define SC_ACQ_PTR_ERR_EID              29
#define SC_ATS_BAD_ARG_ERR_EID          30
#define SC_BUF_ERR_EID                  31
#define SC_CHKSUM_ERR_EID               32
#define SC_ATS_SKIP_ERR_EID             34
#define SC_ATS_BUSY_ERR_EID             34
#define SC_ATS_NOT_RUNNING_ERR_EID      35
#define SC_RTS_BAD_ARG_ERR_EID          36
#define SC_RTS_BUSY_ERR_EID             37
#define SC_RTS_ABSENT_ERR_EID           38
#define SC_RTS_DISABLED_ERR_EID         39
#define SC_RTS_LATE_ERR_EID             40
#define SC_ATS_CONT_ERR_EID             41
#define SC_RTS_CONT_ERR_EID             42
#define SC_ATS_ERROR_STOP_ERR_EID       43
#define SC_RTS_ERROR_STOP_ERR_EID       44
#define SC_ATS_UPDATE_STOP_ERR_EID      45
#define SC_RTS_ALREADY_DISABLED_ERR_EID 46
#define SC_RTS_ALREADY_ENABLED_ERR_EID  47
#define SC_DISABLE_RUNNING_RTS_ERR_EID  48

#define SC_FILTERED_EVT_COUNT 8

/* SC Structure Definitions */
typedef struct {
    uint16 CmdId;
    uint16 Offset;
    uint16 Length;
    uint32 Timestamp;
} SC_ATSCmdInfo_t;

typedef struct {
    uint8 Status;
    uint8 EnableState;
    uint16 NextCmdPtr;
    uint16 NextCmdLength;
    uint16 NextCmdNum;
    CFE_TIME_SysTime_t NextCmdTime;
    uint16 ExecCount;
    uint16 ErrCount;
    uint32 UseCount;
    uint8  DisableOnFinish;
} SC_RTSInfo_t;

typedef struct {
    uint16 CmdId;
    uint32 Timestamp;
    CFE_SB_CmdHdr_t CmdHeader;
} OS_PACK SC_ATSEntry_t;

typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;
    uint16 CmdCtr;
    uint16 CmdErrCtr;
    uint8  AtsNumber;
    uint8  AtsState;
    uint16 AtsCmdNumber;
    uint16 AtsCmdCtr;
    uint16 AtsCmdErrCtr;
    uint32 LastAtsErrSeq;
    uint32 NextAtsTime;
    uint8  ContinueAtsOnFailure;
    uint8  ContinueRtsOnFailure;
    uint16 RtsActivCtr;
    uint16 RtsActivErrCtr;
    uint16 NextRtsNumber;
    uint32 RtsExecutingStatus[SC_NUMBER_OF_RTS/32];
    CFE_TIME_SysTime_t NextRtsTime;
    uint16 RtsCmdCtr;
    uint16 RtsCmdErrCtr;
    uint16 LastAtsErrCmd;
    uint16 LastRtsErrCmd;
    uint16 LastRtsErrNum;
} OS_PACK SC_HkPacket_t;

typedef struct {
    CFE_SB_PipeId_t CmdPipe;
    CFE_SB_MsgPtr_t MsgPtr;

    SC_HkPacket_t HkPacket;

    CFE_TBL_Handle_t ATSHandle[2];
    CFE_TBL_Handle_t RTSHandle[SC_NUMBER_OF_RTS];

    uint16 NextATSCmdIndex;
    SC_ATSCmdInfo_t ATSCmdInfo[SC_MAX_ATS_CMDS+1];

    SC_RTSInfo_t RTSInfo[SC_NUMBER_OF_RTS];

    CFE_EVS_BinFilter_t EventFilters[SC_FILTERED_EVT_COUNT];
} SC_AppData_t;

typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
} SC_NoArgsCmd_t;

typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
    uint16 Number;
} SC_TSCmd_t;

typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
    uint32 NewTime;
} SC_AtsTimeCmd_t;

typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
    uint16 Continue;
} SC_ContOnFailCmd_t;

/* SC Function Prototypes */
void    SC_TaskMain(void);
int32   SC_Init(void);
void    SC_ResetCounters(void);
void    SC_AppPipe(void);
void    SC_ProcessGroundCommand(void);
void    SC_ReportHousekeeping(void);
void    SC_RunSequences(void);

void    SC_StartATSCmd(CFE_SB_MsgPtr_t MsgPtr);
void    SC_StopATSCmd(void);
void    SC_StartRTSCmd(CFE_SB_MsgPtr_t MsgPtr);
void    SC_StopRTSCmd(CFE_SB_MsgPtr_t MsgPtr);
void    SC_DisableRTSCmd(CFE_SB_MsgPtr_t MsgPtr);
void    SC_EnableRTSCmd(CFE_SB_MsgPtr_t MsgPtr);
void    SC_SwitchATSCmd(void);
void    SC_JumpATSCmd(CFE_SB_MsgPtr_t MsgPtr);
void    SC_ContATSOnFailCmd(CFE_SB_MsgPtr_t MsgPtr);
void    SC_ContRTSOnFailCmd(CFE_SB_MsgPtr_t MsgPtr);

boolean SC_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength);

int32 SC_ATS_Register(void);
int32 SC_ATS_Prepare(uint8 AtsNum);
void  SC_ATS_Update(CFE_TIME_SysTime_t CurrentTime);
void  SC_ATS_Jump(uint32 NewTime);
void  SC_ATS_Stop(uint8 Reason);
int32 SC_ATS_Validate(void* buffer);

int32 SC_RTS_Register(void);
void  SC_RTS_UpdateAll(CFE_TIME_SysTime_t CurrentTime);
int32 SC_RTS_Start(uint16 RtsNum);
void  SC_RTS_SendCommands(uint16 RtsNum, CFE_TIME_SysTime_t CurrentTime);
void  SC_RTS_Stop(uint16 RtsNum, uint8 Reason);
int32 SC_RTS_Validate(void* buffer);

#endif
