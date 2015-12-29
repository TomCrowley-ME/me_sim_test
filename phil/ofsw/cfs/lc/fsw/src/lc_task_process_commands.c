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
/*
 * lc_task_process_commands.c
 *
 *  Created on: May 10, 2014
 *      Author: tklaus
 */

#include <stddef.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>

#include "lc_task.h"
#include "lc_task_process_commands.h"

extern LC_AppData_t LC_AppData;

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **/
/*                                                                            */
/* LC_VerifyCmdLength() -- Verify command packet length                   */
/*                                                                            */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **/
boolean LC_VerifyCmdLength(CFE_SB_MsgPtr_t msg, uint16 ExpectedLength) {
    boolean invalid = FALSE;

    uint16 ActualLength = CFE_SB_GetTotalMsgLength(msg);

    /*
     ** Verify the command packet length.
     */
    if (ExpectedLength != ActualLength) {
        CFE_SB_MsgId_t MessageID = CFE_SB_GetMsgId(msg);
        uint16 CommandCode = CFE_SB_GetCmdCode(msg);

        CFE_EVS_SendEvent(LC_LEN_ERR_EID, CFE_EVS_ERROR,
                "Invalid msg length: ID = 0x%X,  CC = %d, Len = %d, Expected = %d", MessageID, CommandCode,
                ActualLength, ExpectedLength);
        invalid = TRUE;
        LC_AppData.HkPacket.ErrCount++;
    }
    return (invalid);
} /* End of LC_VerifyCmdLength() */

int32 LC_ProcessCommandMsg(void){
    CFE_SB_MsgId_t MsgId;

    MsgId = CFE_SB_GetMsgId(LC_AppData.MsgPtr);

    switch (MsgId) {
    case LC_CMD_MID:
        LC_ProcessGroundCommand();
        break;

    case LC_SEND_HK_MID:
        if(LC_VerifyCmdLength(LC_AppData.MsgPtr, sizeof(LC_NoArgsCmd_t))){
        	return LC_COMMAND_ERR_EID; /* bail out */
        }
        LC_ReportHousekeeping();
        break;

    default:
        LC_AppData.HkPacket.ErrCount++;
        CFE_EVS_SendEvent(LC_COMMAND_ERR_EID, CFE_EVS_ERROR, "LC: invalid command packet, MID = 0x%x", MsgId);
        break;
    }

    return CFE_SUCCESS;

} /* End LC_ProcessCommandPacket */

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **/
/*                                                                            */
/* LC_ProcessGroundCommand() -- LC ground commands                            */
/*                                                                            */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **/

int32 LC_ProcessGroundCommand(void) {
    uint16 CommandCode;

    CommandCode = CFE_SB_GetCmdCode(LC_AppData.MsgPtr);

    if(CommandCode == LC_SET_GLOBAL_STATE_CC){
        if(LC_VerifyCmdLength(LC_AppData.MsgPtr, sizeof(LC_SetGlobalStateCmd_t))){
        	return LC_COMMAND_ERR_EID; /* bail out */
        }

        LC_SetGlobalState();
    }else if(CommandCode == LC_SET_ACTIONPOINT_STATE_CC){
        if(LC_VerifyCmdLength(LC_AppData.MsgPtr, sizeof(LC_SetActionpointStateCmd_t))){
        	return LC_COMMAND_ERR_EID; /* bail out */
        }

        LC_SetActionpointState();
    }else{
    	/* no-arg commands */
        if(LC_VerifyCmdLength(LC_AppData.MsgPtr, sizeof(LC_NoArgsCmd_t))){
        	return LC_COMMAND_ERR_EID; /* bail out */
        }

        switch (CommandCode) {
        case LC_NOOP_CC:
            LC_AppData.HkPacket.CmdCount++;
            CFE_EVS_SendEvent(LC_COMMANDNOP_INF_EID, CFE_EVS_INFORMATION, "LC: NOOP command");
            break;

        case LC_RESETCTRS_CC:
            LC_ResetCounters();
            break;

        case LC_RESET_ACTIONPOINT_STATES_CC:
            LC_ResetActionpointStates();
            break;

        default:
            LC_AppData.HkPacket.ErrCount++;
            CFE_EVS_SendEvent(LC_COMMAND_ERR_EID, CFE_EVS_ERROR, "LC: invalid command code = 0x%x", CommandCode);
            break;
        }
    }

    return CFE_SUCCESS;

} /* End of LC_ProcessGroundCommand() */

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **/
/*  Name:  LC_ReportHousekeeping                                              */
/*                                                                            */
/*  Purpose:                                                                  */
/*         This function is triggered in response to a task telemetry request */
/*         from the housekeeping task. This function will gather the Apps     */
/*         telemetry, packetize it and send it to the housekeeping task via   */
/*         the software bus                                                   */
/* * * * * * * * * * * * * * * * * * * * * * * *  * * * * * * *  * *  * * * * */
int32 LC_ReportHousekeeping(void) {
    int32 Status = CFE_SUCCESS;

    /* Manage the tables before doing anything else */
    Status = LC_ManageTables();
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(LC_MANAGE_TBL_ERR_EID, CFE_EVS_ERROR,
                "LC: Error unsubscribing to TLM messages, RC=0x%08X", Status);
        return Status;
    }

    LC_AppData.HkPacket.CurrentLcState = LC_AppData.LcEnabled;

    CFE_TBL_Info_t tbl_info;

    CFE_TBL_GetInfo(&tbl_info, LC_APP_NAME "." LC_WDT_NAME);
    strncpy(LC_AppData.HkPacket.WpTableInUse, tbl_info.LastFileLoaded, OS_MAX_PATH_LEN);

    CFE_TBL_GetInfo(&tbl_info, LC_APP_NAME "." LC_ADT_NAME);
    strncpy(LC_AppData.HkPacket.ApTableInUse, tbl_info.LastFileLoaded, OS_MAX_PATH_LEN);

    CFE_SB_TimeStampMsg((CFE_SB_Msg_t *) &LC_AppData.HkPacket);
    CFE_SB_SendMsg((CFE_SB_Msg_t *) &LC_AppData.HkPacket);

    return CFE_SUCCESS;

} /* End of LC_ReportHousekeeping() */

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **/
/*  Name:  LC_ResetCounters                                               */
/*                                                                            */
/*  Purpose:                                                                  */
/*         This function resets all the global counter variables that are     */
/*         part of the task telemetry.                                        */
/*                                                                            */
/* * * * * * * * * * * * * * * * * * * * * * * *  * * * * * * *  * *  * * * * */
int32 LC_ResetCounters(void) {

    CFE_SB_InitMsg(&LC_AppData.HkPacket, LC_HK_TLM_MID, sizeof(LC_AppData.HkPacket), TRUE);

    CFE_EVS_SendEvent(LC_COMMANDRST_INF_EID, CFE_EVS_INFORMATION, "LC: RESET command");

    return CFE_SUCCESS;

} /* End of LC_ResetCounters() */

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **/
/*  Name:  LC_ResetActionpointStates                                          */
/*                                                                            */
/*  Purpose:                                                                  */
/*         This function resets all actionpoint states to the defaults        */
/*         defined in the currently loaded table                              */
/*                                                                            */
/* * * * * * * * * * * * * * * * * * * * * * * *  * * * * * * *  * *  * * * * */
int32 LC_ResetActionpointStates(void){

	LC_Init_Actionpoints();

	return CFE_SUCCESS;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **/
/*  Name:  LC_SetGlobalState                                                  */
/*                                                                            */
/*  Purpose:                                                                  */
/*         This function resets all the global counter variables that are     */
/*         part of the task telemetry.                                        */
/*                                                                            */
/* * * * * * * * * * * * * * * * * * * * * * * *  * * * * * * *  * *  * * * * */
int32 LC_SetGlobalState(void){

	LC_SetGlobalStateCmd_t *cmd_msg = (LC_SetGlobalStateCmd_t*) LC_AppData.MsgPtr;

	uint8 old_state = LC_AppData.LcEnabled;
	uint8 new_state = cmd_msg -> NewState;

	LC_AppData.LcEnabled = new_state;

    CFE_EVS_SendEvent(LC_COMMANDRST_INF_EID, CFE_EVS_INFORMATION, "LC: SetGlobalState command: %d -> %d",
    		old_state, new_state);

	return CFE_SUCCESS;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **/
/*  Name:  LC_SetActionpointState                                             */
/*                                                                            */
/*  Purpose:                                                                  */
/*         This function resets all the global counter variables that are     */
/*         part of the task telemetry.                                        */
/*                                                                            */
/* * * * * * * * * * * * * * * * * * * * * * * *  * * * * * * *  * *  * * * * */
int32 LC_SetActionpointState(void){

	LC_SetActionpointStateCmd_t *cmd_msg = (LC_SetActionpointStateCmd_t*) LC_AppData.MsgPtr;
	uint16 actionpoint_index = cmd_msg -> ActionpointNumber - 1; /* convert to zero-based */

	if(actionpoint_index >= LC_MAX_ACTIONPOINTS){
        CFE_EVS_SendEvent(LC_COMMAND_ERR_EID, CFE_EVS_ERROR,
                "LC: Error: Invalid AP index = %d", actionpoint_index);
        return CFE_SUCCESS;
	}

	uint8 old_state = LC_AppData.ActionpointState[actionpoint_index];
	uint8 new_state = cmd_msg -> NewState;

	LC_AppData.ActionpointState[actionpoint_index] = new_state;

    CFE_EVS_SendEvent(LC_COMMANDRST_INF_EID, CFE_EVS_INFORMATION, "LC: SetActionpointState number: %d, state: %d -> %d",
    		cmd_msg -> ActionpointNumber, old_state, new_state);

    return CFE_SUCCESS;
}

