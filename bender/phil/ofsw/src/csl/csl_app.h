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
 ** File: csl_app.h
 **
 ** Purpose:
 **   This file is the main header file for the CSL app
 **
 ******************************************************************************/

#ifndef CSL_APP_H
#define CSL_APP_H

#include "cfe_evs.h"
#include "cfe_sb.h"
#include "cfe_tbl.h"

#define CSL_MAX_RCVMSG       10
#define CSL_QUEUE_LEN        25
#define CSL_SL_BUS_PIPE_LIM  CFE_SB_DEFAULT_MSG_LIMIT
#define CSL_SL_CMD_PIPE_LIM  10

/*
** Event message ID's.
*/
#define CSL_INIT_INF_EID    1    /* start up message "informational" */

#define CSL_NOOP_INF_EID    2    /* processed command "informational" */
#define CSL_RESET_INF_EID   3
#define CSL_EXIT_INF_EID    4

#define CSL_MID_ERR_EID     5    /* invalid command packet "error" */
#define CSL_CC1_ERR_EID     6
#define CSL_LEN_ERR_EID     7
#define CSL_PIPE_ERR_EID    8
#define CSL_TBL_ERR_EID     9
#define CSL_BUF_ERR_EID    10

#define CSL_EVT_COUNT      10    /* count of event message ID's */

/*
** CSL command packet command codes
*/
#define CSL_NOOP_CC         0    /* no-op command */
#define CSL_RESET_CC        1    /* reset counters */
#define CSL_INIT_CC         2    /* Perform (Re)Init of Routine */
#define CSL_RESET_SEQ_CC    3
#define CSL_HK_REQUEST_CC   4
#define CSL_CLEAR_QUEUE_CC  5
#define CSL_VERBOSE_CC      6    /* Change the Verbosity 0 - Quiet */
#define CSL_EXIT_CC         9    /* Exit the application */

/*
** CSL OS Events
*/
#define CSL_CMD_PIPE_EVENT  0x01

/* Codegen values */
#define SL_CI_CMD_MID     0xffff
#define CFE_TIME_MID      0xfffe

typedef enum {
    EQUAL = 0,
    LESS_THAN_EQUAL
} CSL_Comparison_t;

typedef enum {
    CSC_MSG = 0,
    SIL_MSG
} CSL_MsgType_t;

typedef enum {
    ACCEPT = 0, /* Flag that a message was accepted */
    WAKEUP,     /* Flag that a message is a Wakeup message */
    LENGTHFAIL, /* Flag that the message failed the length check */
    IDFAIL,     /* Flag that the message failed the ID check */
    REJECT,     /* Flag that the message was rejected */
    QUEUED,     /* Flag that the message was placed in a command queue */
    QUEUEFULL   /* Flag that the destination queue is full */
} CSL_CntControl_t;

typedef struct {
    CFE_SB_MsgId_t  mid;
    void            *mptr;
    uint16          siz;
    uint16          lim;
    uint8           *qptr;
} SL_Msg_t;

typedef enum {
    TICK = 0,
    NONTICK
} CSL_TickControl_t;

typedef struct {
    CFE_SB_MsgId_t  mid;
    void            *mptr;
    uint16          siz;
    uint16          lim;
    uint8           *qptr;
    uint16          mcnt;
    uint16          ecnt;
    uint8           *qtl;
    uint8           *qhd;
    uint16          qcnt;
    boolean         qexists;
    uint16          seq;
} CSCMsg_t;

typedef struct {
    uint16 AppId;
    uint16 CommandCode;
    uint16 Sequence;
} CSC_CmdHeader_t;

typedef struct {
    CFE_SB_TlmHdr_t TlmHeader;

    uint32 CmdAcceptCounter;
    uint32 NonCmdAcceptCounter;
    uint32 AppExecuteCounter;
    uint32 SentMsgCounter;
    uint8 CmdErrorCounter;
    uint8 NonCmdErrorCounter;
    uint8 SILCmdExecuteCounter;
    uint8 SILCmdErrorCounter;
    uint8 TriggerMsgErrorCounter;
    uint8 EventCounter;
    uint8 InitCounter;
} OS_PACK CSL_HkPacket_t;

typedef struct {
    CFE_SB_CmdHdr_t CmdHeader;
} CSL_NoArgsCmd_t;

typedef struct {
    uint32 CmdAcceptCounter;
    uint32 NonCmdAcceptCounter;
    uint32 AppExecuteCounter;
    uint32 SentMsgCounter;
    uint8 CmdErrorCounter;
    uint8 NonCmdErrorCounter;
    uint8 SILCmdExecuteCounter;
    uint8 SILCmdErrorCounter;
    uint8 TriggerMsgErrorCounter;
    uint8 EventCounter;
    uint8 InitCounter;

    CSL_HkPacket_t HkPacket;

    CFE_SB_PipeId_t CmdPipe;

    CFE_TBL_Handle_t ParamTblHandle;
    CFE_TBL_Handle_t StateTblHandle;

    uint32 RunStatus;

    char PipeName[OS_MAX_PATH_LEN];
    uint16 PipeDepth;

    CFE_EVS_BinFilter_t EventFilters[CSL_EVT_COUNT];
} CSL_AppData_t;

static int32   csl_app_init(void);
static boolean csl_verify_msg_length(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength, CSL_Comparison_t Comparison);
static int32   csl_app_pipe(void);
static void    csl_housekeeping_cmd(void);
static void    csl_no_op_cmd(void);
static void    csl_reset_hk_counter_cmd(void);
static void    csl_change_verbose_lvl(void);
static void    csl_reinit(void);
static void    csl_reset_sequence_numbers(void);
static void    csl_clear_queue(void);
static void    csl_exit_cmd(void);
static void    csl_do_step(void);
static void    csl_increment_msg_counters(CSL_MsgType_t type, uint16 mid, CSL_CntControl_t status);
static void    csl_table_init(void);
static void    csl_event_signal(void);

static int32   sl_init(void);
static void    sl_manage_tables(void);
static void    sl_rcv_msg(CFE_SB_MsgPtr_t Msg);
static void    sl_enqueue_msg(CFE_SB_MsgPtr_t Msg, CSCMsg_t *CSCMsg);
static void    sl_dequeue_msg(CSCMsg_t *CSCMsg);
static void    sl_msg_manage(CFE_SB_MsgPtr_t Msg, CSCMsg_t *CSCMsg);
static void    sl_increment_cmd_msg_sequence(void);
static void    sl_msg_cleanup(void);
static void    csl_publish_outputs(void);

void           CSL_MAIN(void);

#endif
