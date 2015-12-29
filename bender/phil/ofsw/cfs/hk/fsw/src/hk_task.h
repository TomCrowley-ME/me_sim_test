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
#ifndef HK_TASK_H
#define HK_TASK_H

#include "cfe_es.h"
#include "cfe_sb.h"
#include "cfe_evs.h"
#include "cfe_tbl.h"

/* HK Configuration Parameters */
#define HK_COPY_TABLE_ENTRIES    256
#define HK_COPY_TABLE_FILENAME   "/cf/ptbl/hk_cpy_tbl0.tbl"
#define HK_COPY_TABLE_NAME       "CopyTable"
#define HK_NUM_BYTES_IN_MEM_POOL (6 * 1024)
#define HK_PIPE_DEPTH            40
#define HK_RUNTIME_TABLE_NAME    "RuntimeTable"

/* HK Command Codes */
#define HK_NOOP_CC      0x00
#define HK_RESETCTRS_CC 0x01

/* HK Event IDs */
#define HK_INIT_INF_EID          1
#define HK_NOOP_INF_EID          2
#define HK_CHECKIN_DBG_EID      10
#define HK_CRCMDPIPE_ERR_EID    20
#define HK_SUBSCRIBE_ERR_EID    21
#define HK_MSGID_ERR_EID        22
#define HK_CC1_ERR_EID          23
#define HK_COPY_REG_ERR_EID     24
#define HK_COPY_LOAD_ERR_EID    25
#define HK_RUNTIME_REG_ERR_EID  26
#define HK_RUNTIME_LOAD_ERR_EID 27
#define HK_ACQ_PTR_ERR_EID      28
#define HK_MSGLEN_ERR_EID       29
#define HK_PIPE_ERR_EID         30
#define HK_MEMPOOL_ERR_EID      31

#define HK_FILTERED_EVT_COUNT 5

/* HK Memory Pool Block Sizes */
#define HK_MEM_BLOCK_SIZE_01  16
#define HK_MEM_BLOCK_SIZE_02  20
#define HK_MEM_BLOCK_SIZE_03  24
#define HK_MEM_BLOCK_SIZE_04  32
#define HK_MEM_BLOCK_SIZE_05  40
#define HK_MEM_BLOCK_SIZE_06  48
#define HK_MEM_BLOCK_SIZE_07  56
#define HK_MEM_BLOCK_SIZE_08  64
#define HK_MEM_BLOCK_SIZE_09  72
#define HK_MEM_BLOCK_SIZE_10  80
#define HK_MEM_BLOCK_SIZE_11  96
#define HK_MEM_BLOCK_SIZE_12 112
#define HK_MEM_BLOCK_SIZE_13 128
#define HK_MEM_BLOCK_SIZE_14 160
#define HK_MEM_BLOCK_SIZE_15 192
#define HK_MEM_BLOCK_SIZE_16 224
#define HK_MAX_BLOCK_SIZE    256

/* HK Structure Definitions */
typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;
    uint8 command_count;
    uint8 error_count;
    uint16 packets_sent_count;
    uint16 missing_data_count;
    uint32 mem_pool_handle;
} OS_PACK HK_HkPacket_t;

typedef struct {
    uint16   input_mid;
    uint16   input_offset;
    uint16   output_mid;
    uint16   output_offset;
    uint16   num_bytes;
} OS_PACK HK_CopyTableEntry_t;

typedef struct {
    HK_CopyTableEntry_t entries[HK_COPY_TABLE_ENTRIES];
} OS_PACK HK_CopyTable_t;

typedef struct {
    boolean input_mid_subscribed;
    boolean input_mid_present;
    uint32  output_mid_address;
} OS_PACK HK_RuntimeTableEntry_t;

typedef struct {
    HK_RuntimeTableEntry_t entries[HK_COPY_TABLE_ENTRIES];
} OS_PACK HK_RuntimeTable_t;

typedef struct {
    CFE_SB_PipeId_t CmdPipe;
    CFE_SB_MsgPtr_t MsgPtr;

    HK_HkPacket_t HkPacket;

    CFE_TBL_Handle_t CopyTblHandle;
    CFE_TBL_Handle_t RuntimeTblHandle;

    CFE_ES_MemHandle_t MemPoolHandle;
    uint8 OS_ALIGN(8) MsgPoolRam[HK_NUM_BYTES_IN_MEM_POOL];

    HK_RuntimeTable_t RuntimeTable;

    CFE_EVS_BinFilter_t EventFilters[HK_FILTERED_EVT_COUNT];
} HK_AppData_t;

typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
} OS_PACK HK_NoArgsCmd_t;

typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
    CFE_SB_MsgId_t MsgIdToSend;
} OS_PACK HK_SendHkCmd_t;

/* HK Function Prototypes */
void    HK_TaskMain(void);
int32   HK_Init(void);
void    HK_ResetCounters(void);
void    HK_AppPipe(void);
void    HK_ProcessPacket(void);
void    HK_ProcessGroundCommand(void);
int32   HK_SetupTables(void);
int32   HK_UnloadTables(void);
void    HK_ManageCopyTable(void);
void    HK_ReportHousekeeping(void);
boolean HK_VerifyCmdLength(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength);
int32   HK_CopyTableValidate(void* buffer);

#endif
