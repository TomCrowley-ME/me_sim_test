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
/******************************************************************************
** File: sch_task.h
**
** Purpose:
**   This file contains defines for the Scheduler task
**
******************************************************************************/

#ifndef SCH_TASK_H
#define SCH_TASK_H

#include "cfe_sb.h"
#include "sch_cfg.h"

/*****************************************************************************/ /* Event message ID's */
#define SCH_INIT_INF_EID     0x01
#define SCH_NOOP_INF_EID     0x02
#define SCH_RESET_INF_EID    0x03
#define SCH_GROUP_INF_EID    0x04
#define SCH_MID_ERR_EID      0x50
#define SCH_CC_ERR_EID       0x51
#define SCH_LEN_ERR_EID      0x52
#define SCH_SLOT_ERR_EID     0x53
#define SCH_ENTRY_ERR_EID    0x54
#define SCH_TBL_GET_ERR_EID  0x55
#define SCH_TBL_MOD_ERR_EID  0x56
#define SCH_STATUS_ERR_EID   0x57
#define SCH_GROUP_ERR_EID    0x58
#define SCH_FRAME_ERR_EID    0x59

/* SCH command packet command codes */
#define SCH_NOOP_CC          0x00
#define SCH_RESETCTRS_CC     0x01
#define SCH_ENABLEENTRY_CC   0x02
#define SCH_DISABLEENTRY_CC  0x03
#define SCH_ENABLEGROUP_CC   0x04
#define SCH_DISABLEGROUP_CC  0x05
#define SCH_ENABLESYNC_CC    0x06
#define SCH_SENDDIAG_CC      0x07
#define SCH_BAD_CMD_CC       0x7F

/* SCH Table entry defines */
#define SCH_UNUSED   0
#define SCH_ENABLED  1
#define SCH_DISABLED 2

#define SCH_GROUP_NONE   0
#define SCH_GROUP_CFS_HK 1

#define SCH_ACTIVITY_NONE     0
#define SCH_ACTIVITY_SEND_MSG 1

/* SCH Validation Error Codes */
#define SCH_MESSAGE_MID_ERR       (-1L)
#define SCH_MESSAGE_CHECKSUM_ERR  (-2L)
#define SCH_MESSAGE_EMPTY_ROW_ERR (-3L)

#define SCH_SCHEDULE_STATE_ERR     (-1L)
#define SCH_SCHEDULE_ACTIVITY_ERR  (-2L)
#define SCH_SCHEDULE_RMNDR_ERR     (-3L)
#define SCH_SCHEDULE_MSG_INDEX_ERR (-4L)

/*****************************************************************************/

/* SCH Structure Typedefs */

/* Command Message Definitions */
typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
} OS_PACK SCH_NoArgsCmd_t;

typedef struct {
    CFE_SB_CmdHdr_t  CmdHeader;
    uint16           slot_number;
    uint16           entry_number;
} OS_PACK SCH_EntryCmd_t;

typedef struct {
    CFE_SB_CmdHdr_t  CmdHeader;
    uint32           group_data;
} OS_PACK SCH_GroupCmd_t;

/* Telemetry Message Definitions */
typedef struct {
    CFE_SB_TlmHdr_t  tlm_header;
    uint16           command_count;                /* Number of commands received */
    uint16           command_error_count;          /* Number of invalid commands (MID or CC) received */
    uint32           act_success_count;            /* Number of successfully performed activities */
    uint32           act_failure_count;            /* Number of unsuccessful activities attempted */
    uint32           slot_proc_count;              /* Total number of Schedule Slots (Minor Frames) processed */
    uint16           skip_slot_count;              /* Number of times that slots were skipped */
    uint16           multi_slot_count;             /* Number of times that multiple slots were processed */
    uint16           same_slot_count;              /* Number of times SCH woke up in the same slot as last time */
    uint16           bad_tbl_data_count;           /* Number of times corrupted table entries were processed */
    uint16           tbl_pass_verify_count;        /* Number of times table loads successfully verified */
    uint16           tbl_fail_verify_count;        /* Number of times table loads failed to verify */
    uint32           tbl_proc_count;               /* Number of times the Schedule Table has been processed */
    uint32           valid_major_frame_count;      /* Number of valid Major Frame tones received */
    uint32           missing_major_frame_count;    /* Number of missing Major Frame tones */
    uint32           unexpected_major_frame_count; /* Number of unexpected Major Frame tones */
    uint16           minor_since_tone_count;       /* Number of Minor Frames since last Major Frame tone */
    uint16           next_slot;                    /* Next Minor Frame to be processed */
    uint16           last_sync_met_slot;           /* Slot number Time Sync last occurred */
    uint8            ignore_major_frame;           /* Major Frame too noisy to trust */
    uint8            unexpected_major_frame;       /* Most recent Major Frame signal was unexpected */
    uint8            sync_to_MET;                  /* Status indicating whether slots are synced to MET */
    uint8            major_frame_source;           /* Major Frame signal source identifier */
    uint8            spare[2];
} OS_PACK SCH_HkPacket_t;

typedef struct {
    CFE_SB_TlmHdr_t  tlm_header;
    uint16           entry_states[SCH_TOTAL_SLOTS*SCH_ENTRIES_PER_SLOT];
    uint16           msgids[SCH_TOTAL_SLOTS*SCH_ENTRIES_PER_SLOT];
} OS_PACK SCH_DiagPacket_t;


/* Application Data Structure Definition */
typedef struct {
    CFE_SB_PipeId_t CommandPipe;
    CFE_SB_MsgPtr_t MsgPtr;

    SCH_HkPacket_t  HkPacket;
    SCH_DiagPacket_t  DiagPacket;

    uint32 TimerId;
    uint32 SemaphoreId;

    CFE_TBL_Handle_t ScheduleTblHandle;
    CFE_TBL_Handle_t MessageTblHandle;

    uint16 LastSlot;
    uint16 MinorFrame;
    uint16 CurrentSlot;

    uint16 CatchUpCount;
    uint16 NoisyMajorFrameCount;
    boolean IgnoreMajorFrame;
} SCH_AppData_t;

/*****************************************************************************/

/* SCH Table Typedefs */

typedef struct {
    uint8  enable_state;
    uint8  type;
    uint16 period;
    uint16 remainder;
    uint16 msg_index;
    uint32 group_data;
} SCH_ScheduleEntry_t;

typedef struct {
    SCH_ScheduleEntry_t slots[SCH_TOTAL_SLOTS][SCH_ENTRIES_PER_SLOT];
} SCH_ScheduleTable_t;


typedef struct {
    uint8 msg_buffer[SCH_MAX_MESSAGE][SCH_MAX_MSG_WORDS*2];
} SCH_MessageTable_t;

/*****************************************************************************/

/* Prototypes Section */

void    SCH_TaskMain(void);
int32   SCH_Init(void);
void    SCH_ProcessCommandPackets(void);
void    SCH_ProcessGroundCommand(void);
void    SCH_NoopCmd(void);
void    SCH_ResetCmd(void);
void    SCH_SetEntryStateCmd(uint8 CommandedState);
void    SCH_SetGroupStateCmd(uint8 CommandedState);
void    SCH_EnableSyncCmd(void);
void    SCH_SendDiagCmd(void);
boolean SCH_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength);
void    SCH_ReportHousekeeping(void);
void    SCH_ResetCounters(void);
void    SCH_Delete_Callback(void);
int32   SCH_1Hz_Callback(void);
void    SCH_Timer_Callback(uint32 timer_id);
int32   SCH_ScheduleTblValidationFunc(void* buffer);
int32   SCH_MessageTblValidationFunc(void* buffer);

/*****************************************************************************/

#endif  /* SCH_TASK_H */
