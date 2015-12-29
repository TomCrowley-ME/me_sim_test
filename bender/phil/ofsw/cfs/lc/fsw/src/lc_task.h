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
#ifndef LC_TASK_H
#define LC_TASK_H

#include "cfe.h"
#include "app_msgids.h"
#include "app_perfids.h"

#include "lc_version.h"

/* LC general configuration parameters */
#define LC_APP_NAME                 "LC_APP"
#define LC_CMD_PIPE_DEPTH           16
#define LC_TLM_PIPE_DEPTH           32
#define LC_RTS_REQ_CC               4
#define LC_RTS_REQ_MID              0x18a9
#define LC_MAX_WATCHPOINTS          40
#define LC_STATE_POWER_ON_RESET     LC_STATE_ACTIVE
#define LC_STATE_WHEN_CDS_RESTORED  LC_STATE_FROM_CDS
#define LC_WDT_NAME                 "WDT"
#define LC_ADT_NAME                 "ADT"
#define LC_WDT_FILENAME             "/cf/ptbl/lc_def_wdt.tbl"
#define LC_ADT_FILENAME             "/cf/ptbl/lc_def_adt.tbl"
#define LC_MAX_RPN_EQU_SIZE         20
#define LC_MAX_ACTION_TEXT          64
#define LC_MAX_ACTIONPOINTS         20
#define LC_MAX_VALID_ADT_RTSID      0xFFF0
#define LC_FLOAT_TOLERANCE          (1.0e-25)

/* LC no-arg Command Codes */
#define LC_NOOP_CC                      0x00
#define LC_RESETCTRS_CC                 0x01
#define LC_RESET_ACTIONPOINT_STATES_CC  0x02
/* LC arg Command Codes */
#define LC_SET_GLOBAL_STATE_CC          0x03 /* global LC enable, 1 arg */
#define LC_SET_ACTIONPOINT_STATE_CC     0x04 /* 2 args */

/* LC Event IDs */
#define LC_INIT_INF_EID             1
#define LC_NOOP_INF_EID             2
#define LC_COMMAND_ERR_EID          3
#define LC_COMMANDNOP_INF_EID       4
#define LC_COMMANDRST_INF_EID       5
#define LC_INVALID_MSGID_ERR_EID    6
#define LC_LEN_ERR_EID              7
#define LC_TLM_ERR_EID              8
#define LC_INIT_ERR_EID             20
#define LC_WPT_REG_ERR_EID          21
#define LC_WPT_LOAD_ERR_EID         22
#define LC_APT_REG_ERR_EID          23
#define LC_APT_LOAD_ERR_EID         24
#define LC_STACK_OVERFLOW_ERR_EID   25
#define LC_STACK_UNDERFLOW_ERR_EID  26
#define LC_CREATE_PIPE_ERR_EID      25
#define LC_SUBSCRIBE_ERR_EID        26
#define LC_UNSUBSCRIBE_ERR_EID      27
#define LC_MANAGE_TBL_ERR_EID       28
#define LC_ACQ_PTR_ERR_EID          29
#define LC_FIRE_RTS_ERR_EID         30

#define LC_EVT_COUNT                18

/* 4 subtracted to account for SPARC padding added to codegen structs that is removed in csc_csl_interface.h */
#define BUS_OFFSET(bus, signal) (CFE_SB_TLM_HDR_SIZE +  offsetof(bus,signal) - 4)

#ifdef DEBUG_LOG
#define DEBUG(format, ...) fprintf (stderr, format, ##__VA_ARGS__)
#else
#define DEBUG(format, ...)
#endif

/* if (value & 0xC000) != 0, value is an operator */
typedef enum {
    AND = 0x4000,
    OR = 0x8000,
    NOT = 0xC000
} LC_LogicalOperator_t;

typedef enum {
    EQUAL_TO,
    NOT_EQUAL_TO,
    LESS_THAN,
    LESS_THAN_OR_EQUAL_TO,
    GREATER_THAN_OR_EQUAL_TO,
    GREATER_THAN
} LC_OperatorID_t;

typedef enum {
    DISABLED = 0,
    PASSIVE,
    ACTIVE
} LC_ActionpointState_t;

typedef enum {
    LC_DOUBLE = 0,
    LC_FLOAT,
    LC_UINT32,
    LC_INT32,
    LC_UINT16,
    LC_INT16,
    LC_UINT8,
    LC_INT8
} LC_DataType_t;

typedef struct {
    uint8 data_type;
    uint8 operator_id;
    uint16 message_id;
    uint32 offset;
    uint32 bitmask;
    union {
        double f64;
        float f32;
        uint32 u32;
        int32 i32;
        uint16 u16;
        int16 i16;
        uint8 u8;
        int8 i8;
    } value;
} LC_WatchpointDefinition_t;

typedef struct {
    LC_WatchpointDefinition_t watchpoints[LC_MAX_WATCHPOINTS];
} LC_WatchpointDefinitionTable_t;

typedef struct {
    uint8 default_state;
    uint8 padding;
    uint16 rts_id;
    uint16 max_fail_before_rts;
    uint16 rpn_equation[LC_MAX_RPN_EQU_SIZE];
    uint16 event_type;
    uint16 event_id;
    char event_text[LC_MAX_ACTION_TEXT];
} LC_ActionpointDefinition_t;

typedef struct {
    LC_ActionpointDefinition_t actionpoints[LC_MAX_ACTIONPOINTS];
} LC_ActionpointDefinitionTable_t;

typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
} LC_NoArgsCmd_t;

typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
    uint8 NewState; /* 0=disabled, 1=enabled */
} OS_PACK LC_SetGlobalStateCmd_t;

typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
    uint8 ActionpointNumber; /* actionpoint index, one-based */
    uint8 NewState; /* 0=disabled, 1=enabled */
} LC_SetActionpointStateCmd_t;

typedef struct {
	CFE_SB_TlmHdr_t TlmHeader;
    uint8  CurrentLcState;
    char  WpTableInUse[OS_MAX_PATH_LEN];
    char  ApTableInUse[OS_MAX_PATH_LEN];
    uint8  CmdCount;
    uint8  ErrCount;

    /* Rollup stats */

    uint16 WpAllEvalTrueCount;
    uint16 WpAllEvalFalseCount;
    uint16 ApAllPassCount;
    uint16 ApAllFailCount;
    uint16 AllRTSExecCount;

    uint16 LastApFail;
    uint16 NextToLastApFail;
    uint16 LastRTSExec;
    CFE_TIME_SysTime_t LastRtsExecTime;
    uint16 NextToLastRTSExec;
    CFE_TIME_SysTime_t NextToLastRtsExecTime;

    /* Individual  stats */

    uint16 WpLastEvalResult[LC_MAX_WATCHPOINTS];
    uint16 WpEvalCount[LC_MAX_WATCHPOINTS];
    uint16 WpFalseToTrueCount[LC_MAX_WATCHPOINTS];
    uint16 WpConsecutiveTrueCount[LC_MAX_WATCHPOINTS];
    uint16 WpCumulativeTrueCount[LC_MAX_WATCHPOINTS];

    uint16 ApLastEvalResult[LC_MAX_ACTIONPOINTS];
    uint16 ApCurrentState[LC_MAX_ACTIONPOINTS];
    uint16 ApPassiveCount[LC_MAX_ACTIONPOINTS];
    uint16 ApFailToPassCount[LC_MAX_ACTIONPOINTS];
    uint16 ApPassToFailCount[LC_MAX_ACTIONPOINTS];
    uint16 ApConsecutiveFailCount[LC_MAX_ACTIONPOINTS];
    uint16 ApCumulativeFailCount[LC_MAX_ACTIONPOINTS];
    uint16 ApCumulativeRTSExecCount[LC_MAX_ACTIONPOINTS];

}OS_PACK LC_HkPacket_t;

#define LC_HK_TLM_LNGTH   sizeof ( LC_HkPacket_t )

#define LC_HASH_MAX_ENTRIES_PER_BUCKET 30

/*
 * For maximum performance at the expense of memory,
 * set LC_HASH_TABLE_SIZE to be at least as big
 * as the possible range of message ID's (MAX_MSGID - MIN_MSGID)
 */
#define LC_HASH_TABLE_SIZE 100

typedef struct {
    uint16 message_id;
    uint8 pad[2];
    uint32 offset;
    uint16 watchpoint_def_table_index;
} LC_HashEntry_T;

typedef struct {
    uint16 num_entries;
    /* each entry is an index into watchpoint_def_table defined in lc_def_wdt.c */
    LC_HashEntry_T entries[LC_HASH_MAX_ENTRIES_PER_BUCKET];
} LC_HashBucket_T;

typedef struct {
    LC_HashBucket_T buckets[LC_HASH_TABLE_SIZE];
} LC_HashTable_T;

#define HASH_IDX(message_id) (message_id % LC_HASH_TABLE_SIZE)


/* LC app global data */
typedef struct {
	/* global enable for LC. If false, all incoming TLM messages are ignored */
	boolean LcEnabled;

    CFE_SB_MsgPtr_t MsgPtr;
    CFE_SB_PipeId_t CmdPipe;
    CFE_SB_PipeId_t TlmPipe;

    LC_HkPacket_t HkPacket;

    CFE_ES_CDSHandle_t CDSHandle;
    CFE_EVS_BinFilter_t EventFilters[LC_EVT_COUNT];

    CFE_TBL_Handle_t WptTblHandle;
    CFE_TBL_Handle_t AptTblHandle;

    uint16 Subscriptions[LC_MAX_WATCHPOINTS];
    uint16 SubscriptionCount;

    /* Whether the watchpoint was updated by an incoming TLM SB message */
    boolean WatchpointUpdated[LC_MAX_WATCHPOINTS];
    /* The current state of updated watchpoints (non-updated watchpoints are set to FALSE */
    boolean WatchpointState[LC_MAX_WATCHPOINTS];

    LC_HashTable_T WatchpointLookupHashTable;

    /* Current state of the action point. Same as APT.default_state unless modified by ground command */
    boolean ActionpointState[LC_MAX_ACTIONPOINTS];
    /* Most recent evaluation of each action point */
    boolean ActionpointEval[LC_MAX_ACTIONPOINTS];
    /* Number of consecutive times each AP has evaluated to TRUE */
    boolean ActionpointFailureCount[LC_MAX_ACTIONPOINTS];

} LC_AppData_t;

/****************************************************************************/
/*
 ** Local function prototypes.
 **
 ** Note: Except for the entry point (LC_TaskMain), these
 **       functions are not called from any other source module.
 */
int32 LC_TaskMain(void);
int32 LC_AppInit(void);
int32 LC_ManageTables(void);
void LC_ManageWptTable(void);
int32 LC_WatchpointTblValidationFunc(void* buffer);
int32 LC_ActionpointTblValidationFunc(void* buffer);
int32 LC_Init_Actionpoints(void);

#endif
