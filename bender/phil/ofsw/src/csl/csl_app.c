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
 ** File: csl_app.c
 **
 ** Purpose:
 **   This module defines the base Simulink Interface Layer app
 **
 ******************************************************************************/

#include "csl_app.h"
#include "csc_sl_interface.h"
#include "csc_model_hz.h"

#include "app_msgids.h"
#include "app_perfids.h"

#include "cfe.h"

#include <string.h>

/* Local data */
static CSL_AppData_t CSL_AppData;

static CSCMsg_t CSL_MsgSnd[SL_NUM_OUTPUTS+1];
static CSCMsg_t CSL_MsgRcv[SL_NUM_INPUTS+1];

#ifdef NEED_TIME
static void    csl_get_time(void);
#endif
#ifdef NEED_PARAMETER_TBL
static int32   csl_param_table_register(void);
static int32   csl_param_table_validation(void *buffer);
static void    csl_load_param_table(void);
#endif
#ifdef NEED_STATE_TBL
static int32   csl_state_table_register(void);
static int32   csl_state_table_validation(void *buffer);
#endif

#include "csc_sl_events.c"

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                 */
/* csl_app_init() -- Generic CSL layer initialization              */
/*                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static int32 csl_app_init(void) {
    int32 Status;
    uint32 cmd_pipe_id;

    /* Set up the RunStatus variable */
    CSL_AppData.RunStatus = CFE_ES_APP_RUN;

    /* Initialize the cmd execution counters */
    CSL_AppData.CmdAcceptCounter = 0;
    CSL_AppData.NonCmdAcceptCounter = 0;
    CSL_AppData.AppExecuteCounter = 0;
    CSL_AppData.SentMsgCounter = 0;
    CSL_AppData.CmdErrorCounter = 0;
    CSL_AppData.NonCmdErrorCounter = 0;
    CSL_AppData.SILCmdExecuteCounter = 0;
    CSL_AppData.SILCmdErrorCounter = 0;
    CSL_AppData.TriggerMsgErrorCounter = 0;
    CSL_AppData.EventCounter = 0;
    CSL_AppData.InitCounter = 0;

    /* Initialize the app configuration data */
    strcpy(CSL_AppData.PipeName, CSL_PipeName);
    CSL_AppData.PipeDepth = 3*SL_NUM_INPUTS + 12;

    /* Initialize event filter table. */
    CSL_AppData.EventFilters[0].EventID = CSL_INIT_INF_EID;
    CSL_AppData.EventFilters[0].Mask    = CFE_EVS_NO_FILTER;
    CSL_AppData.EventFilters[1].EventID = CSL_NOOP_INF_EID;
    CSL_AppData.EventFilters[1].Mask    = CFE_EVS_NO_FILTER;
    CSL_AppData.EventFilters[2].EventID = CSL_RESET_INF_EID;
    CSL_AppData.EventFilters[2].Mask    = CFE_EVS_NO_FILTER;
    CSL_AppData.EventFilters[3].EventID = CSL_EXIT_INF_EID;
    CSL_AppData.EventFilters[3].Mask    = CFE_EVS_NO_FILTER;
    CSL_AppData.EventFilters[4].EventID = CSL_MID_ERR_EID;
    CSL_AppData.EventFilters[4].Mask    = CFE_EVS_NO_FILTER;
    CSL_AppData.EventFilters[5].EventID = CSL_CC1_ERR_EID;
    CSL_AppData.EventFilters[5].Mask    = CFE_EVS_NO_FILTER;
    CSL_AppData.EventFilters[6].EventID = CSL_LEN_ERR_EID;
    CSL_AppData.EventFilters[6].Mask    = CFE_EVS_NO_FILTER;
    CSL_AppData.EventFilters[7].EventID = CSL_PIPE_ERR_EID;
    CSL_AppData.EventFilters[7].Mask    = CFE_EVS_NO_FILTER;
    CSL_AppData.EventFilters[8].EventID = CSL_TBL_ERR_EID;
    CSL_AppData.EventFilters[8].Mask    = CFE_EVS_NO_FILTER;
    CSL_AppData.EventFilters[9].EventID = CSL_BUF_ERR_EID;
    CSL_AppData.EventFilters[9].Mask    = CFE_EVS_NO_FILTER;

    Status = CFE_EVS_Register(CSL_AppData.EventFilters, CSL_EVT_COUNT, CFE_EVS_BINARY_FILTER);

    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog(CSL_NAME ": Error registering events, RC = 0x%08X\n", Status);
        return Status;
    }

    /* Initialize the housekeeping packet */
    CFE_SB_InitMsg(&CSL_AppData.HkPacket, MY_HK_TLM_MID, sizeof(CSL_HkPacket_t), TRUE);

    /* Create the SB message pipe */
    Status = CFE_SB_CreatePipe(&CSL_AppData.CmdPipe, CSL_AppData.PipeDepth, CSL_AppData.PipeName);

    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog(CSL_NAME ": Error creating SB pipe, RC = 0x%08X\n", Status);
        return Status;
    }

    /* Subscribe to Housekeeping and CSL ground command packets */
    Status = CFE_SB_Subscribe(CSC_SEND_HK_MID, CSL_AppData.CmdPipe);
    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog(CSL_NAME ": Error subscribing to CSL HK request, RC = 0x%08x\n", Status);
        return Status;
    }

    Status = CFE_SB_Subscribe(CSC_CMD_MID, CSL_AppData.CmdPipe);
    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog(CSL_NAME ": Error subscribing to CSL command, RC = 0x%08X\n", Status);
        return Status;
    }

    Status = OS_QueueGetIdByName(&cmd_pipe_id, CSL_AppData.PipeName);
    Status = OS_QueueEventStart(cmd_pipe_id, CSL_CMD_PIPE_EVENT);

    /* Initialize tables */
    csl_table_init();

    /* Initialize the model */
    Status =  sl_init();
    if (Status != CFE_SUCCESS) {
        return Status;
    }

    CFE_EVS_SendEvent(CSL_INIT_INF_EID, CFE_EVS_INFORMATION, CSL_NAME ": Application Initialized");

    return CFE_SUCCESS;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                                               */
/* csl_verify_msg_length() -- Checks the length of a message against a supplied expected length  */
/*                                                                                               */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static boolean csl_verify_msg_length(CFE_SB_MsgPtr_t Msg, uint16 ExpectedLength, CSL_Comparison_t Comparison) {
    boolean result = TRUE;
    uint16 ActualLength = CFE_SB_GetTotalMsgLength(Msg);

    if (Comparison == EQUAL) {
        result = (ActualLength == ExpectedLength);
    } else if (Comparison == LESS_THAN_EQUAL) {
        result = (ActualLength <= ExpectedLength);
    } else {
        result = FALSE;
    }

    if (result == FALSE) {
        CFE_SB_MsgId_t MessageID = CFE_SB_GetMsgId(Msg);
        uint16 CommandCode = CFE_SB_GetCmdCode(Msg);

        CFE_EVS_SendEvent(CSL_LEN_ERR_EID, CFE_EVS_ERROR,
                CSL_NAME ": Invalid packet: ID = 0x%04X, CC = %d, Len = %d (Expected = %d)",
                MessageID, CommandCode, ActualLength, ExpectedLength);
    }

    return result;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                   */
/* csl_app_pipe() -- Initial processing of each message in the pipe  */
/*                                                                   */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static int32 csl_app_pipe(void) {
    int32 Status;
    uint32 i;
    CFE_SB_MsgPtr_t Msg;
    CFE_SB_MsgId_t MessageID;
    uint16 CommandCode;
    uint16 ExpectedLength;
    boolean gotTickMsg = FALSE;
#ifdef MY_RT_MID
    boolean gotRTMsg = FALSE;
#endif

    for (i = 0; i < CSL_AppData.PipeDepth; i++) {
        Status = CFE_SB_RcvMsg(&Msg, CSL_AppData.CmdPipe, CFE_SB_POLL);

        if (Status == CFE_SB_NO_MESSAGE) {
            /* queue is empty, so break */
            break;
        } else if (Status != CFE_SUCCESS) {
            /* Pipe error! not good. */
            return Status;
        }

        MessageID = CFE_SB_GetMsgId(Msg);

        switch (MessageID)
        {
            case CSC_SEND_HK_MID:
            case MY_SEND_HK_MID:
                ExpectedLength = sizeof(CSL_NoArgsCmd_t);
                if (csl_verify_msg_length(Msg, ExpectedLength, EQUAL)) {
                    csl_housekeeping_cmd();
                } else {
                    csl_increment_msg_counters(SIL_MSG, MessageID, LENGTHFAIL);
                }
                break;

            case CSC_CMD_MID:
            case MY_CMD_MID:
                CommandCode = CFE_SB_GetCmdCode(Msg);
                switch (CommandCode) {
                    case CSL_NOOP_CC:
                        ExpectedLength = sizeof(CSL_NoArgsCmd_t);
                        if (csl_verify_msg_length(Msg, ExpectedLength, EQUAL)) {
                            csl_no_op_cmd();
                            csl_increment_msg_counters(SIL_MSG, MessageID, ACCEPT);
                        } else {
                            csl_increment_msg_counters(SIL_MSG, MessageID, LENGTHFAIL);
                        }
                        break;

                    case CSL_RESET_CC:
                        ExpectedLength = sizeof(CSL_NoArgsCmd_t);
                        if (csl_verify_msg_length(Msg, ExpectedLength, EQUAL)) {
                            csl_reset_hk_counter_cmd();
                        } else {
                            csl_increment_msg_counters(SIL_MSG, MessageID, LENGTHFAIL);
                        }
                        break;

                    case CSL_INIT_CC:
                        ExpectedLength = sizeof(CSL_NoArgsCmd_t);
                        if (csl_verify_msg_length(Msg, ExpectedLength, EQUAL)) {
                            csl_reinit();
                            csl_increment_msg_counters(SIL_MSG, MessageID, ACCEPT);
                        } else {
                            csl_increment_msg_counters(SIL_MSG, MessageID, LENGTHFAIL);
                        }
                        break;

                    case CSL_RESET_SEQ_CC:
                        ExpectedLength = sizeof(CSL_NoArgsCmd_t);
                        if (csl_verify_msg_length(Msg, ExpectedLength, EQUAL)) {
                            csl_reset_sequence_numbers();
                            csl_increment_msg_counters(SIL_MSG, MessageID, ACCEPT);
                        } else {
                            csl_increment_msg_counters(SIL_MSG, MessageID, LENGTHFAIL);
                        }
                        break;

                    case CSL_CLEAR_QUEUE_CC:
                        ExpectedLength = sizeof(CSL_NoArgsCmd_t);
                        if (csl_verify_msg_length(Msg, ExpectedLength, EQUAL)) {
                            csl_clear_queue();
                            csl_increment_msg_counters(SIL_MSG, MessageID, ACCEPT);
                        } else {
                            csl_increment_msg_counters(SIL_MSG, MessageID, LENGTHFAIL);
                        }
                        break;

                    case CSL_VERBOSE_CC:
                        ExpectedLength = sizeof(CSL_NoArgsCmd_t);
                        if (csl_verify_msg_length(Msg, ExpectedLength, EQUAL)) {
                            csl_change_verbose_lvl();
                            csl_increment_msg_counters(SIL_MSG, MessageID, ACCEPT);
                        } else {
                            csl_increment_msg_counters(SIL_MSG, MessageID, LENGTHFAIL);
                        }
                        break;

                    case CSL_EXIT_CC:
                        ExpectedLength = sizeof(CSL_NoArgsCmd_t);
                        if (csl_verify_msg_length(Msg, ExpectedLength, EQUAL)) {
                            csl_exit_cmd();
                            csl_increment_msg_counters(SIL_MSG, MessageID, ACCEPT);
                        } else {
                            csl_increment_msg_counters(SIL_MSG, MessageID, LENGTHFAIL);
                        }
                        break;

                    default:
                        CFE_EVS_SendEvent(CSL_CC1_ERR_EID, CFE_EVS_ERROR,
                                CSL_NAME ": Invalid ground command code: ID = 0x%04X, CC= %d",
                                MessageID, CommandCode);
                        csl_increment_msg_counters(SIL_MSG, MessageID, REJECT);
                        break;
                }
                break;
            default:
                sl_rcv_msg(Msg);
                break;
        }

        /* Now that the message has been received properly, check to see if it's a tick or RT message. */
        if (MessageID == MY_TICK_MID) {
            gotTickMsg = TRUE;
        }

#ifdef MY_RT_MID
        if (MessageID == MY_RT_MID) {
            gotRTMsg = TRUE;
        }
#endif
    }

    /* Now that we've processed all of our inputs, do step and output publishing if needed */
    if (gotTickMsg) {
        /* Perform the step if we got the message defined as our tick */
        csl_do_step();
    }
#ifdef MY_RT_MID
    if (gotRTMsg) {
        /* Only publish outputs on the rate transition tick if it exists */
        csl_publish_outputs();
    }
#endif
    return CFE_SUCCESS;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                   */
/* csl_housekeeping_cmd() -- Pack up housekeeping data and send it   */
/*                                                                   */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static void csl_housekeeping_cmd(void) {
    /* Copy over current counter values */
    CSL_AppData.HkPacket.CmdAcceptCounter = CSL_AppData.CmdAcceptCounter;
    CSL_AppData.HkPacket.NonCmdAcceptCounter = CSL_AppData.NonCmdAcceptCounter;
    CSL_AppData.HkPacket.AppExecuteCounter = CSL_AppData.AppExecuteCounter;
    CSL_AppData.HkPacket.SentMsgCounter = CSL_AppData.SentMsgCounter;
    CSL_AppData.HkPacket.CmdErrorCounter = CSL_AppData.CmdErrorCounter;
    CSL_AppData.HkPacket.NonCmdErrorCounter = CSL_AppData.NonCmdErrorCounter;
    CSL_AppData.HkPacket.SILCmdExecuteCounter = CSL_AppData.SILCmdExecuteCounter;
    CSL_AppData.HkPacket.SILCmdErrorCounter = CSL_AppData.SILCmdErrorCounter;
    CSL_AppData.HkPacket.TriggerMsgErrorCounter = CSL_AppData.TriggerMsgErrorCounter;
    CSL_AppData.HkPacket.EventCounter = CSL_AppData.EventCounter;
    CSL_AppData.HkPacket.InitCounter = CSL_AppData.InitCounter;

    CFE_SB_TimeStampMsg((CFE_SB_MsgPtr_t) &CSL_AppData.HkPacket);
    CFE_SB_SendMsg((CFE_SB_MsgPtr_t) &CSL_AppData.HkPacket);
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                   */
/* csl_no_op_cmd() -- Perform a NOOP                                 */
/*                                                                   */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static void csl_no_op_cmd(void) {
    CFE_EVS_SendEvent(CSL_NOOP_INF_EID, CFE_EVS_INFORMATION, CSL_NAME ": Noop command. Codegen revision: " CSL_CODEGEN_REVISION);
}

static void csl_reset_hk_counter_cmd(void) {
    CSL_AppData.CmdAcceptCounter = 0;
    CSL_AppData.NonCmdAcceptCounter = 0;
    CSL_AppData.AppExecuteCounter = 0;
    CSL_AppData.SentMsgCounter = 0;
    CSL_AppData.CmdErrorCounter = 0;
    CSL_AppData.NonCmdErrorCounter = 0;
    CSL_AppData.SILCmdExecuteCounter = 0;
    CSL_AppData.SILCmdErrorCounter = 0;
    CSL_AppData.TriggerMsgErrorCounter = 0;
    CSL_AppData.EventCounter = 0;
    CSL_AppData.InitCounter = 0;

    CFE_EVS_SendEvent(CSL_RESET_INF_EID, CFE_EVS_INFORMATION, CSL_NAME ": Reset HK Counters command");
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                   */
/* csl_change_verbose_lvl() -- Change verbosity of CSL output        */
/*                                                                   */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static void csl_change_verbose_lvl(void) {
    CFE_EVS_SendEvent(CSL_NOOP_INF_EID, CFE_EVS_INFORMATION, CSL_NAME ": No verbosity to set yet");
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                                 */
/* csl_reset_sequence_numbers() -- Reset sequence numbers on all Simulink commands */
/*                                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static void csl_reset_sequence_numbers(void) {
    uint32 i;

    for (i = 0; i < SL_NUM_INPUTS; i++) {
        CSL_MsgRcv[i].seq = 0;
    }
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                                 */
/* csl_reset_sequence_numbers() -- Reset all command queues, dropping all messages */
/*                                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static void csl_clear_queue(void) {
    uint32 i;

    for (i = 0; i < SL_NUM_INPUTS; i++) {
        CSCMsg_t *CSCMsg = &CSL_MsgRcv[i];

        CSCMsg->qhd = CSCMsg->qptr;
        CSCMsg->qtl = CSCMsg->qptr;
        CSCMsg->qcnt = 0;
        CSCMsg->mcnt = 0;
        CSCMsg->ecnt = 0;
    }
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                                 */
/* csl_reinit() -- Completely reinitialize the CSL and attached Simulink code      */
/*                                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static void csl_reinit(void) {
    CSL_AppData.CmdAcceptCounter = 0;
    CSL_AppData.NonCmdAcceptCounter = 0;
    CSL_AppData.AppExecuteCounter = 0;
    CSL_AppData.SentMsgCounter = 0;
    CSL_AppData.CmdErrorCounter = 0;
    CSL_AppData.NonCmdErrorCounter = 0;
    CSL_AppData.SILCmdExecuteCounter = 0;
    CSL_AppData.SILCmdErrorCounter = 0;
    CSL_AppData.TriggerMsgErrorCounter = 0;
    CSL_AppData.EventCounter = 0;

    CSL_AppData.InitCounter++;

    /* Clear queues */
    csl_clear_queue();
    /* Reset sequence numbers */
    csl_reset_sequence_numbers();
    /* Load default parameter table */
#ifdef NEED_PARAMETER_TBL
    csl_load_param_table();
#endif

    /* Terminate and then call the model initialization function again */
    sl_mdl_term();
    sl_mdl_init();

    CFE_EVS_SendEvent(CSL_INIT_INF_EID, CFE_EVS_INFORMATION, CSL_NAME ": reinitialize command");
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                     */
/* csl_exit_cmd() -- Causes this CSL instance to exit  */
/*                                                     */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * */

static void csl_exit_cmd(void) {
    CSL_AppData.RunStatus = CFE_ES_APP_EXIT;
    CFE_EVS_SendEvent(CSL_EXIT_INF_EID, CFE_EVS_INFORMATION, CSL_NAME ": Exit command");
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                                 */
/* csl_do_step() -- Perform all tasks needed for a Simulink step                   */
/*                                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static void csl_do_step(void) {
    /* Manage tables */
    sl_manage_tables();
    /* Increment sequence numbers */
    sl_increment_cmd_msg_sequence();

#ifdef NEED_TIME
    csl_get_time();
#endif

#ifdef CSL_GSSE_APP
    {
        /*
         * Only step the sim apps if we're beyond the sim start time.
         * This currently has only a resolution of 1s, and looks at a copy
         * of the time that shouldn't even be there... so it's a bit hacky.
         * In the future we'll have both seconds and subseconds and a proper
         * place for the parameter to live.
         */
        CFE_TIME_SysTime_t utc_time = CFE_TIME_GetUTC();

        if (utc_time.Seconds >= (uint32)CSL_PARAM_TABLE.ini_epoch_seconds) {
#endif
            /* Do the step! */
            sl_mdl_step();
            CSL_AppData.AppExecuteCounter++;

#ifdef CSL_GSSE_APP
        }
    }
#endif


    /* Clean up message counters */
    sl_msg_cleanup();
    /* Send events */
    csl_event_signal();
    /* Send output messages */
#ifndef MY_RT_MID
    csl_publish_outputs();
#endif
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                                 */
/* csl_publish_outputs() -- Iterate through the output table and send messages out */
/*                                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static void csl_publish_outputs(void) {
    uint32 i;
    uint8 *output_msg_data_ptr;
    uint8 *sl_data_ptr;
    uint16 sl_data_length;
    CFE_SB_MsgId_t output_msg_mid;
    CFE_SB_ZeroCopyHandle_t output_msg_handle;
    CFE_SB_MsgPtr_t output_msg_ptr;
    uint16 output_msg_length;

    for (i = 0; i < SL_NUM_OUTPUTS; i++) {
	if (CCSDS_SID_TYPE(CSL_MsgSnd[i].mid) == CCSDS_CMD) {
            uint16 output_msg_cmd_code;

            if (CSL_MsgSnd[i].mid == SL_CI_CMD_MID) {
                /* If this output has CI-type functionality (ie, able to send commands with any and all MsgIds,
                 * we need to extract information like MsgId, command code, sequence number, etc. from the
                 * beginning of the message, and then pull the rest of the data from beyond that header */
                CSC_CmdHeader_t* cmd_header_ptr = (CSC_CmdHeader_t*)CSL_MsgSnd[i].mptr;

                if (cmd_header_ptr->Sequence == CSL_MsgSnd[i].seq) {
                    /* If the sequence count on this command has not changed, it is not new, so don't publish it */
                    continue;
                }
                CSL_MsgSnd[i].seq = cmd_header_ptr->Sequence;

                /* Grab the needed info from the CMD header */
                output_msg_mid = cmd_header_ptr->AppId;
                output_msg_cmd_code = cmd_header_ptr->CommandCode;

                /* Calculate offsets and sizes */
                sl_data_ptr = (uint8*)CSL_MsgSnd[i].mptr + sizeof(CSC_CmdHeader_t);
                sl_data_length = CSL_MsgSnd[i].siz - sizeof(CSC_CmdHeader_t);
            } else {
                /* Not a CI-type command, so this is easy -- just copy over the whole thing */
                output_msg_mid = CSL_MsgSnd[i].mid;
                output_msg_cmd_code = 0;

                sl_data_ptr = (uint8*)CSL_MsgSnd[i].mptr;
                sl_data_length = CSL_MsgSnd[i].siz;
            }

            output_msg_length = CFE_SB_CMD_HDR_SIZE + sl_data_length;
            output_msg_ptr = CFE_SB_ZeroCopyGetPtr(output_msg_length, &output_msg_handle);

            if (output_msg_ptr == NULL) {
                CFE_EVS_SendEvent(CSL_BUF_ERR_EID, CFE_EVS_ERROR,
                        CSL_NAME ": Received null ZeroCopy buffer, not sending Msg 0x%04X", output_msg_mid);
                continue;
            }

            CFE_SB_InitMsg(output_msg_ptr, output_msg_mid, output_msg_length, TRUE);
            CFE_SB_SetCmdCode(output_msg_ptr, output_msg_cmd_code);

            /* We're sending out a command -- assume CMD header */
	    output_msg_data_ptr = ((uint8*)output_msg_ptr) + CFE_SB_CMD_HDR_SIZE;
	} else {
            /* Sending a telemetry message -- assume tlm header, copy over whole message and timestamp */
            sl_data_ptr = (uint8*)CSL_MsgSnd[i].mptr;
            sl_data_length = CSL_MsgSnd[i].siz;

            output_msg_mid = CSL_MsgSnd[i].mid;
            output_msg_length = CFE_SB_TLM_HDR_SIZE + sl_data_length;
            output_msg_ptr = CFE_SB_ZeroCopyGetPtr(output_msg_length, &output_msg_handle);

            if (output_msg_ptr == NULL) {
                CFE_EVS_SendEvent(CSL_BUF_ERR_EID, CFE_EVS_ERROR,
                        CSL_NAME ": Received null ZeroCopy buffer, not sending Msg 0x%04X", output_msg_mid);
                continue;
            }

            CFE_SB_InitMsg(output_msg_ptr, output_msg_mid, output_msg_length, FALSE);
            CFE_SB_TimeStampMsg(output_msg_ptr);

            output_msg_data_ptr = ((uint8*)output_msg_ptr) + CFE_SB_TLM_HDR_SIZE;
	}

        /* Copy over the appropriate data and send the message! */
        CFE_PSP_MemCpy(output_msg_data_ptr, sl_data_ptr, sl_data_length);

        CFE_SB_ZeroCopySend(output_msg_ptr, output_msg_handle);
        CSL_MsgSnd[i].mcnt++;
        CSL_AppData.SentMsgCounter++;
    }
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                                                   */
/* csl_increment_msg_counters() -- Updates various counters based on destination, MsgId, and status  */
/*                                                                                                   */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static void csl_increment_msg_counters(CSL_MsgType_t type, uint16 mid, CSL_CntControl_t status) {
    if (type == SIL_MSG) {
        if (status == ACCEPT) {
            /* Accepted CSL command */
            CSL_AppData.SILCmdExecuteCounter++;
        } else {
            /* Rejected/failed CSL command */
            CSL_AppData.SILCmdErrorCounter++;
        }
    } else {
        if (CCSDS_SID_TYPE(mid) == CCSDS_CMD) {
            if (status == ACCEPT) {
                /* Accepted simulink command */
                CSL_AppData.CmdAcceptCounter++;
            } else if (status != QUEUED) {
                /* Rejected/failed simulink command */
                CSL_AppData.CmdErrorCounter++;
            }
        } else {
            if (status == ACCEPT) {
                /* Accepted TLM input */
                CSL_AppData.NonCmdAcceptCounter++;
            } else {
                /* Rejected TLM input */
                CSL_AppData.NonCmdErrorCounter++;
            }
        }
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                                                   */
/* csl_get_time() -- Grabs the current cFE time and inserts it into the sch_bus_msg input of the app */
/*                                                                                                   */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifdef NEED_TIME
static void csl_get_time(void) {
    uint32 i;

    /* Get the current cFE time and pack it */
    CFE_TIME_SysTime_t utc = CFE_TIME_GetUTC();

    /* Look for cfe_time_msg and copy the time in */
    for (i = 0; i < SL_NUM_INPUTS; i++) {
        if (CSL_MsgRcv[i].mid == CFE_TIME_MID) {
            cfe_time_msg *csl_time;

            csl_time = (cfe_time_msg *)CSL_MsgRcv[i].mptr;
            csl_time->utc_seconds = utc.Seconds;
            csl_time->utc_mseconds = CFE_TIME_Sub2MicroSecs(utc.Subseconds) / 1000;

            break;
        }
    }
}
#endif

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                           */
/* csl_table_init() -- Register and load default cFE tables  */
/*                                                           */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static void csl_table_init(void) {
#ifdef NEED_PARAMETER_TBL
    {
        int32 status;

        status = csl_param_table_register();
        if (status == CFE_SUCCESS) {
            csl_load_param_table();
        } else {
            CFE_ES_WriteToSysLog(CSL_NAME ": Error registering parameter table, RC = 0x%08X\n", status);
        }
    }
#endif

#ifdef NEED_STATE_TBL
    {
        int32 status;

        status = csl_state_table_register();
        if (status == CFE_SUCCESS) {
            status = CFE_TBL_Load(CSL_AppData.StateTblHandle, CFE_TBL_SRC_ADDRESS, &CSL_STATE_TABLE);
            CFE_TBL_Manage(CSL_AppData.StateTblHandle);

        } else {
            CFE_ES_WriteToSysLog(CSL_NAME ": Error registering parameter table, RC = 0x%08X\n", status);
        }
    }
#endif
}

#ifdef NEED_PARAMETER_TBL /* Parameter table support functions */

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                             */
/* csl_param_table_register() -- Register app parameter table  */
/*                                                             */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static int32 csl_param_table_register(void) {
    int32 status;
    status = CFE_TBL_Register(&CSL_AppData.ParamTblHandle, "parameter_tbl", sizeof(CSL_PARAM_TABLE), CFE_TBL_OPT_DEFAULT, csl_param_table_validation);
    return status;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                             */
/* csl_param_table_validation() -- Validate parameter table    */
/*                                                             */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static int32 csl_param_table_validation(void *buffer) {
    /* Not implemented yet, and will probably be external since it is different for each app */
    return CFE_SUCCESS;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                             */
/* csl_load_param_table() -- Load the default parameter table  */
/*                                                             */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static void csl_load_param_table(void) {
    int32 status;

    /* First off, make cFE load the table */
    status = CFE_TBL_Load(CSL_AppData.ParamTblHandle, CFE_TBL_SRC_FILE, CSL_DEFAULT_PARAM_FILE);
    if (status == CFE_SUCCESS) {
        void *table_buf;

        /* Do initial table management */
        CFE_TBL_Manage(CSL_AppData.ParamTblHandle);

        /* Copy the loaded parameters over into the actual used Simulink parameter table */
        status = CFE_TBL_GetAddress(&table_buf, CSL_AppData.ParamTblHandle);
        if (status == CFE_SUCCESS || status == CFE_TBL_INFO_UPDATED) {
            CFE_PSP_MemCpy((void*)&CSL_PARAM_TABLE, table_buf, sizeof(CSL_PARAM_TABLE));
            CFE_TBL_ReleaseAddress(CSL_AppData.ParamTblHandle);
        } else {
            CFE_EVS_SendEvent(CSL_TBL_ERR_EID, CFE_EVS_ERROR, CSL_NAME ": param table pointer acquisition failed after successful load, RC=0x%08X", status);
            if (status == CFE_TBL_ERR_NEVER_LOADED) {
                /* This should never ever happen -- we got here after a successful load */
                CFE_TBL_ReleaseAddress(CSL_AppData.ParamTblHandle);
            }
        }
    } else {
        CFE_EVS_SendEvent(CSL_TBL_ERR_EID, CFE_EVS_ERROR, CSL_NAME ": Failed to load param table, RC=0X%08X", status);
    }
}

#endif

/* State table support functions */
#ifdef NEED_STATE_TBL

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                             */
/* csl_state_table_register() -- Register app state table      */
/*                                                             */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static int32 csl_state_table_register(void) {
    int32 status;
    status = CFE_TBL_Register(&CSL_AppData.StateTblHandle, "state_tbl", sizeof(CSL_STATE_TABLE), CFE_TBL_OPT_DUMP_ONLY | CFE_TBL_OPT_USR_DEF_ADDR, csl_state_table_validation);
    return status;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                             */
/* csl_state_table_validation() -- Validate state table        */
/*                                                             */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static int32 csl_state_table_validation(void *buffer) {
    /* Not even sure we'll ever need this */
    return CFE_SUCCESS;
}

#endif


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                             */
/* sl_manage_tables() -- Table management function             */
/*                                                             */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static void sl_manage_tables(void) {
    /* Since we need to worry about copying parameters around, we need extra logic on top of CFE_TBL_Manage */
#ifdef NEED_PARAMETER_TBL
    {
        int32 status;

        status = CFE_TBL_Manage(CSL_AppData.ParamTblHandle);
        if (status == CFE_TBL_INFO_UPDATED) {
            /* Param table got updated, so copy it over into simulink parameters */
            void *table_buf;

            status = CFE_TBL_GetAddress(&table_buf, CSL_AppData.ParamTblHandle);
            if (status == CFE_SUCCESS || status == CFE_TBL_INFO_UPDATED) {
                CFE_PSP_MemCpy((void*)&CSL_PARAM_TABLE, table_buf, sizeof(CSL_PARAM_TABLE));
                CFE_TBL_ReleaseAddress(CSL_AppData.ParamTblHandle);
            } else {
                CFE_EVS_SendEvent(CSL_TBL_ERR_EID, CFE_EVS_ERROR, CSL_NAME ": param table pointer acquisition failed after successful load, RC=0x%08X", status);
                if (status == CFE_TBL_ERR_NEVER_LOADED) {
                    CFE_TBL_ReleaseAddress(CSL_AppData.ParamTblHandle);
                }
            }
        }
        else if (status != CFE_SUCCESS) {
            CFE_EVS_SendEvent(CSL_TBL_ERR_EID, CFE_EVS_ERROR, CSL_NAME ": Error managing parameter table, status = 0x%08X", status);
        }
    }
#endif
#ifdef NEED_STATE_TBL
    {
        int32 status;

        status = CFE_TBL_Manage(CSL_AppData.StateTblHandle);
        if (status != CFE_SUCCESS) {
            CFE_EVS_SendEvent(CSL_TBL_ERR_EID, CFE_EVS_ERROR, CSL_NAME ": Error managing status table, status = 0x%08X", status);
        }
    }
#endif
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                                                     */
/* sl_init() -- Perform app-specific initialization: setting up buffers, subscribing to messages, etc. */
/*                                                                                                     */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static int32 sl_init(void) {
    int32 Status;
    uint32 i;
    boolean tick_subscribed = FALSE;

    sl_mdl_init();

    /* Set up output messages */
    for (i = 0; i < SL_NUM_OUTPUTS ; i++) {
        CSL_MsgSnd[i].mid  = output_msg_tbl[i].mid;
        CSL_MsgSnd[i].mptr = output_msg_tbl[i].mptr;
        CSL_MsgSnd[i].siz  = output_msg_tbl[i].siz;
        CSL_MsgSnd[i].seq = 0;
    }

    /* Subscribe to common input messages */
    Status = CFE_SB_Subscribe(MY_CMD_MID, CSL_AppData.CmdPipe);
    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog(CSL_NAME ": Error subscribing to app command message, RC = 0x%08x\n", Status);
        return Status;
    }

    Status = CFE_SB_Subscribe(MY_SEND_HK_MID, CSL_AppData.CmdPipe);
    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog(CSL_NAME ": Error subscribing to app HK request, RC = 0x%08x\n", Status);
        return Status;
    }

#ifdef MY_RT_MID
    Status = CFE_SB_Subscribe(MY_RT_MID, CSL_AppData.CmdPipe);
    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog(CSL_NAME ": Error subscribing to rate transition message, RC = 0x%08x\n", Status);
        return Status;
    }
#endif

    /* Set up the input message table and subscribe to each entry */
    for (i = 0; i < SL_NUM_INPUTS; i++) {
        CSL_MsgRcv[i].mid  = input_msg_tbl[i].mid;
        CSL_MsgRcv[i].mptr = input_msg_tbl[i].mptr;
        CSL_MsgRcv[i].siz  = input_msg_tbl[i].siz;
        CSL_MsgRcv[i].lim  = input_msg_tbl[i].lim;
        CSL_MsgRcv[i].mcnt = 0;
        CSL_MsgRcv[i].ecnt = 0;
        CSL_MsgRcv[i].qcnt = 0;
        CSL_MsgRcv[i].seq = 0;

        /* check command messages etc. */
        if (CCSDS_SID_TYPE(input_msg_tbl[i].mid) == CCSDS_CMD) {
            CSL_MsgRcv[i].qptr = input_msg_tbl[i].qptr;
            CSL_MsgRcv[i].qhd = input_msg_tbl[i].qptr;
            CSL_MsgRcv[i].qtl = input_msg_tbl[i].qptr;
            CSL_MsgRcv[i].qexists = TRUE;
        } else {
            CSL_MsgRcv[i].qexists = FALSE;
        }

#ifdef NEED_TIME
        /* cfe_time_msg isn't real, so don't try to subscribe to it (we'll get yelled at) */
        if (CSL_MsgRcv[i].mid == CFE_TIME_MID) {
            continue;
        }
#endif

        Status = CFE_SB_SubscribeEx(CSL_MsgRcv[i].mid, CSL_AppData.CmdPipe, CFE_SB_Default_Qos, CSL_MsgRcv[i].lim);
        if (Status != CFE_SUCCESS) {
            CFE_ES_WriteToSysLog(CSL_NAME ": Error subscribing to MsgID 0x%04X, RC = 0x%08x\n", CSL_MsgRcv[i].mid, CSL_AppData.CmdPipe);
        } else {
            if (CSL_MsgRcv[i].mid == MY_TICK_MID) {
                tick_subscribed = TRUE;
            }
        }
    }

    /* If we haven't subscribed to our tick message by now, subscribe to it as well */
    if (!tick_subscribed) {
        Status = CFE_SB_Subscribe(MY_TICK_MID, CSL_AppData.CmdPipe);
        if (Status != CFE_SUCCESS) {
            CFE_ES_WriteToSysLog(CSL_NAME ": Error subscribing to tick message, RC = 0x%08x\n", Status);
            return Status;
        }
    }

    return CFE_SUCCESS;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                         */
/* sl_rcv_msg() -- Process incoming message destined for the Simulink app  */
/*                                                                         */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static void sl_rcv_msg(CFE_SB_MsgPtr_t Msg) {
    uint32 i;
    CFE_SB_MsgId_t mid;

    /* Get the message ID */
    mid = CFE_SB_GetMsgId(Msg);

    /* Look for the message ID in the input table */
    for (i = 0; i < SL_NUM_INPUTS; i++) {
        if (CSL_MsgRcv[i].mid == mid) {
            /* Found the message in the table, check its length before passing it along to message management */
            uint16 ExpectedLength;
            CSL_Comparison_t comparison;
            CSCMsg_t *CSCMsg;

            CSCMsg = &CSL_MsgRcv[i];

            if (CCSDS_SID_TYPE(mid) == CCSDS_CMD) {
                /* If we've got a (variable-length) command, its size will be <= the max specified in CSCMsg->siz */
                ExpectedLength = CSCMsg->siz + CFE_SB_CMD_HDR_SIZE;
                comparison = LESS_THAN_EQUAL;
            } else {
                /* If we've got a tlm message, its size should be constant */
                ExpectedLength = CSCMsg->siz + CFE_SB_TLM_HDR_SIZE;
                comparison = EQUAL;
            }

            if (csl_verify_msg_length(Msg, ExpectedLength, comparison)) {
                /* Looks like we got a good input message, pass it along to management function */
                sl_msg_manage(Msg, CSCMsg);
            } else {
                /* Bad message, increment appropriate counters */
                csl_increment_msg_counters(CSC_MSG, mid, LENGTHFAIL);
            }
        }
    }
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                                         */
/* sl_msg_manage() -- Manage verified telemetry by enqueuing it or copying its data over   */
/*                                                                                         */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static void sl_msg_manage(CFE_SB_MsgPtr_t Msg, CSCMsg_t *CSCMsg) {
    if (CSCMsg->qexists) {
        /* If the message has an associated queue, stick it into the queue */
        sl_enqueue_msg(Msg, CSCMsg);
    } else {
        /* Otherwise overwrite the current data with the contents of the message */
        void *ptr = CFE_SB_GetUserData(Msg);
        CFE_PSP_MemCpy(CSCMsg->mptr, ptr, CSCMsg->siz);
        CSCMsg->qcnt++;
        csl_increment_msg_counters(CSC_MSG, CSCMsg->mid, ACCEPT);
    }
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                                 */
/* sl_enqueue_msg() -- Put a message into its associated queue in the input table  */
/*                                                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static void sl_enqueue_msg(CFE_SB_MsgPtr_t Msg, CSCMsg_t *CSCMsg) {
    CSL_CntControl_t Status = QUEUEFULL;

    /* Only enqueue the message if the queue is not full */
    if (CSCMsg->qcnt < CSL_MAX_RCVMSG) {
        void *ptr;
        CSC_CmdHeader_t *cmdHeader;
        uint16 userDataLength;

        /* Currently we're only queueing commands, so fill out command information */
        cmdHeader = (CSC_CmdHeader_t*)CSCMsg->qtl;
        ptr = CFE_SB_GetUserData(Msg);
        userDataLength = CFE_SB_GetUserDataLength(Msg);

        cmdHeader->AppId = CSCMsg->mid;
        cmdHeader->CommandCode = CFE_SB_GetCmdCode(Msg);
        cmdHeader->Sequence = 0;

        /* Copy the contained information after the command header */
        CFE_PSP_MemCpy(CSCMsg->qtl + sizeof(CSC_CmdHeader_t), ptr, userDataLength);

        /* Update queue counts and pointers */
        CSCMsg->qtl += CSCMsg->siz;
        CSCMsg->qcnt++;

        if (CSCMsg->qtl >= CSCMsg->qptr + (CSL_MAX_RCVMSG * CSCMsg->siz)) {
            CSCMsg->qtl = CSCMsg->qptr;
        }
        Status = QUEUED;
    }
    /* Increment appropriate counters */
    csl_increment_msg_counters(CSC_MSG, CSCMsg->mid, Status);
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                               */
/* sl_dequeue_msg() -- Remove the front message from the queue   */
/*                                                               */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static void sl_dequeue_msg(CSCMsg_t *CSCMsg) {
    CSCMsg->qhd += CSCMsg->siz;
    if (CSCMsg->qhd >= CSCMsg->qptr + (CSL_MAX_RCVMSG * CSCMsg->siz)) {
        CSCMsg->qhd = CSCMsg->qptr;
    }
    CSCMsg->qcnt--;

    csl_increment_msg_counters(CSC_MSG, CSCMsg->mid, ACCEPT);
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                                                             */
/* sl_increment_cmd_msg_sequence() -- Update the sequence for and prepare a command from each non-empty queue  */
/*                                                                                                             */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static void sl_increment_cmd_msg_sequence(void) {
    uint32 i;

    /* Go through the input table and look for non-empty queues */
    for (i = 0; i < SL_NUM_INPUTS; i++) {
        if (CSL_MsgRcv[i].qexists && CSL_MsgRcv[i].qcnt > 0) {
            /* This queue still has stuff in it */
            CSC_CmdHeader_t *cmdHeader;
            CSCMsg_t *Msg;

            /* Increment the command's sequence number */
            Msg = &CSL_MsgRcv[i];
            Msg->seq++;

            /* Copy the command over into the simulink input buffer, and update its associated sequence in its header */
            CFE_PSP_MemCpy(Msg->mptr, Msg->qhd, Msg->siz);
            cmdHeader = (CSC_CmdHeader_t*)Msg->mptr;
            cmdHeader->Sequence = Msg->seq;
        }
    }
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                               */
/* sl_msg_cleanup() -- Dequeue used command messages and mark inputs as accepted */
/*                                                                               */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static void sl_msg_cleanup(void) {
    uint32 i;

    for (i = 0; i < SL_NUM_INPUTS; i++) {
        if (CSL_MsgRcv[i].qcnt > 0) {
            CSCMsg_t *Msg = &CSL_MsgRcv[i];
            if (Msg->qexists) {
                /* Queued message, dequeue the front */
                sl_dequeue_msg(Msg);
                CSL_AppData.CmdAcceptCounter++;
            } else {
                /* Tlm message, accept */
                Msg->qcnt = 0;
                CSL_AppData.NonCmdAcceptCounter++;
            }
            Msg->mcnt++;
        }
    }
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                               */
/* CSL_MAIN() -- Main function for each CSL app (name changes)                   */
/*                                                                               */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

void CSL_MAIN(void) {
    int32 Status;
    uint32 events;

    /* Register the application with executive services */
    CFE_ES_RegisterApp();

    /* Create the first performance log entry */
    CFE_ES_PerfLogEntry(MY_PERF_ID);

    /* Perform application initialization */
    Status = csl_app_init();

    if (Status != CFE_SUCCESS) {
        CSL_AppData.RunStatus = CFE_ES_APP_ERROR;
    }

    while (CFE_ES_RunLoop(&CSL_AppData.RunStatus) == TRUE) {
        /* Performance log exit stamp */
        CFE_ES_PerfLogExit(MY_PERF_ID);

        /* Pend on the arrival of the next software bus message. */
        OS_EventReceive(CSL_CMD_PIPE_EVENT, OS_EVENT_ANY, OS_PEND, &events);

        /* Performance log entry stamp */
        CFE_ES_PerfLogEntry(MY_PERF_ID);

        Status = csl_app_pipe();

        if (Status != CFE_SUCCESS) {
            /* Received an error reading the SB pipe */
            CFE_EVS_SendEvent(CSL_PIPE_ERR_EID, CFE_EVS_ERROR, CSL_NAME ": SB pipe read error, CSL App will exit.");
            CSL_AppData.RunStatus = CFE_ES_APP_ERROR;
        }
    }

    /* Terminate the model */
    sl_mdl_term();

    CFE_SB_DeletePipe(CSL_AppData.CmdPipe);
    CFE_ES_PerfLogExit(MY_PERF_ID);

    CFE_ES_ExitApp(CSL_AppData.RunStatus);
}
