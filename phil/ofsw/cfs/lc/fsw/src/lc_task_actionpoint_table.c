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
 * lc_task_actionpoint_table.c
 *
 *  Created on: May 10, 2014
 *      Author: tklaus
 */
#include <string.h>

#include <cfe_error.h>
#include <cfe_time.h>

#include "lc_task.h"
#include "lc_task_actionpoint_table.h"

#include "sc_task.h"

typedef struct {
	int data[LC_MAX_RPN_EQU_SIZE];
	int size;
} Stack_t;

Stack_t RpnEquStack;

extern LC_AppData_t LC_AppData;

static int32 evaluate_actionpoint(LC_ActionpointDefinitionTable_t *apTblPtr,
		int apt_index);
static void stack_init(Stack_t* stack);
static int32 stack_push(Stack_t* stack, uint16 value);
static int32 stack_pop(Stack_t* stack, uint16* value);
static uint32 fire_rts(LC_ActionpointDefinition_t* ap, int ap_number);

void stack_init(Stack_t* stack) {
	stack->size = 0;
}

int32 stack_push(Stack_t* stack, uint16 value) {
	int32 Status = CFE_SUCCESS;

	if (stack->size < LC_MAX_RPN_EQU_SIZE) {
		stack->data[stack->size++] = value;
	} else {
		Status = LC_STACK_OVERFLOW_ERR_EID;
		CFE_EVS_SendEvent(LC_STACK_OVERFLOW_ERR_EID, CFE_EVS_ERROR,
				"LC: AP stack overflow, RC=0x%08X", Status);
	}
	return Status;
}

int32 stack_pop(Stack_t* stack, uint16* value) {
	int32 Status = CFE_SUCCESS;
	if (stack->size == 0) {
		Status = LC_STACK_UNDERFLOW_ERR_EID;
		CFE_EVS_SendEvent(LC_STACK_UNDERFLOW_ERR_EID, CFE_EVS_ERROR,
				"LC: AP stack underflow, RC=0x%08X", Status);
	} else {
		*value = stack->data[--(stack->size)];
	}

	return Status;
}

int32 LC_ProcessActionpoints() {
	LC_ActionpointDefinitionTable_t *apTblPtr = NULL;
	int32 Status = CFE_SUCCESS;

	Status = CFE_TBL_GetAddress((void*) &apTblPtr, LC_AppData.AptTblHandle);
	if (Status != CFE_SUCCESS && Status != CFE_TBL_INFO_UPDATED) {
		CFE_EVS_SendEvent(LC_ACQ_PTR_ERR_EID, CFE_EVS_ERROR,
				"LC: Error acquiring pointer to actionpoint table, RC=0x%08X",
				Status);
		return Status;
	}

	int num_actionpoints = sizeof(apTblPtr->actionpoints)
			/ sizeof(apTblPtr->actionpoints[0]);
	int apt_index = 0;
	int rpn_index = 0;
	uint16 operator;

	/* printf("num_actionpoints = %d\n", num_actionpoints); */

	for (apt_index = 0; apt_index < num_actionpoints; apt_index++) {

		/* copy current state into HkPacket here so we don't have to in other
		 * places where we update LC_AppData.ActionpointState[apt_index] */
		LC_AppData.HkPacket.ApCurrentState[apt_index] = LC_AppData.ActionpointState[apt_index];

		for (rpn_index = 0; rpn_index < LC_MAX_RPN_EQU_SIZE; rpn_index++) {
			operator =
					apTblPtr->actionpoints[apt_index].rpn_equation[rpn_index];
			if ((operator & 0xC000) == 0 && operator > 0) {
				/* this is a watchpoint index (+1) */
				if (LC_AppData.WatchpointUpdated[operator - 1]) {
					Status = evaluate_actionpoint(apTblPtr, apt_index);
					if (Status != CFE_SUCCESS) {
						CFE_TBL_ReleaseAddress(LC_AppData.AptTblHandle);
						return Status;
					}
					break; /* move on to next AP */
				}
			}
		}
	}

	CFE_TBL_ReleaseAddress(LC_AppData.AptTblHandle);

	return Status;
}

int32 evaluate_actionpoint(LC_ActionpointDefinitionTable_t *apTblPtr,
		int apt_index) {
	int32 Status = CFE_SUCCESS;
	LC_ActionpointDefinition_t* ap = &(apTblPtr->actionpoints[apt_index]);
	int rpn_index;
	uint16 ap_result;
	uint16 eq_element;
	uint16 operand_1;
	uint16 operand_2;
	uint16 tmp;
	int ap_number = apt_index + 1;

	DEBUG("LC: Evaluating actionpoint %d\n", apt_index);

	stack_init(&RpnEquStack);

	for (rpn_index = 0; rpn_index < LC_MAX_RPN_EQU_SIZE; rpn_index++) {
		eq_element = ap->rpn_equation[rpn_index];

		if (eq_element == 0) {
			/* end of equation */
			Status = stack_pop(&RpnEquStack, &ap_result);
			if (Status != CFE_SUCCESS) {
				return Status;
			}

			uint16 lastResult = LC_AppData.HkPacket.ApLastEvalResult[apt_index];
			LC_AppData.HkPacket.ApLastEvalResult[apt_index] = ap_result;

			if (ap_result == 0) {
				/* actionpoint evaluates to FALSE (PASS) */
				LC_AppData.ActionpointEval[apt_index] = FALSE;
				LC_AppData.ActionpointFailureCount[apt_index] = 0;

				LC_AppData.HkPacket.ApAllPassCount++;

				if(lastResult == 0){
					/* PASS -> PASS */
					LC_AppData.HkPacket.ApConsecutiveFailCount[apt_index] = 0;
				}else{
					/* FAIL -> PASS */
					LC_AppData.HkPacket.ApFailToPassCount[apt_index]++;
				}
			} else if (ap_result == 1) {
				/* actionpoint evaluates to TRUE (FAIL) */
				LC_AppData.ActionpointEval[apt_index] = TRUE;
				LC_AppData.ActionpointFailureCount[apt_index]++;

				LC_AppData.HkPacket.ApCumulativeFailCount[apt_index]++;
				LC_AppData.HkPacket.ApAllFailCount++;

				if(lastResult == 0){
					/* PASS -> FAIL */
					LC_AppData.HkPacket.ApPassToFailCount[apt_index]++;
				}else{
					/* FAIL -> FAIL */
					LC_AppData.HkPacket.ApConsecutiveFailCount[apt_index]++;
				}

				if (LC_AppData.ActionpointFailureCount[apt_index]
						>= ap->max_fail_before_rts) {
					DEBUG("LC_AppData.ActionpointFailureCount[apt_index]: %d\n", LC_AppData.ActionpointFailureCount[apt_index]); DEBUG("ap->max_fail_before_rts: %d\n", ap->max_fail_before_rts);

					if (LC_AppData.LcEnabled && LC_AppData.ActionpointState[apt_index] == ACTIVE) {
						CFE_EVS_SendEvent(ap->event_id, ap->event_type,
								"Tripped AP # %d, text = %s", ap_number, ap->event_text);

						LC_AppData.HkPacket.ApCumulativeRTSExecCount[apt_index]++;
						LC_AppData.HkPacket.AllRTSExecCount++;

						LC_AppData.HkPacket.NextToLastApFail = LC_AppData.HkPacket.LastApFail;
						LC_AppData.HkPacket.LastApFail = apt_index + 1;
						LC_AppData.HkPacket.NextToLastRTSExec = LC_AppData.HkPacket.LastRTSExec;
						LC_AppData.HkPacket.LastRTSExec = ap->rts_id;

						LC_AppData.HkPacket.NextToLastRtsExecTime = LC_AppData.HkPacket.LastRtsExecTime;
						LC_AppData.HkPacket.LastRtsExecTime = CFE_TIME_GetTime();

						/* FIRE RTS */
						Status = fire_rts(ap, ap_number);
						if (Status != CFE_SUCCESS) {
							return Status;
						}
					}else{
						/*
						CFE_EVS_SendEvent(ap->event_id, ap->event_type,
								"[PASSIVE] Tripped AP # %d, text = %s", ap_number, ap->event_text);
						*/

						LC_AppData.HkPacket.ApPassiveCount[apt_index]++;
					}

					/* passivate AP so it doesn't fire repeatedly. Must be reset by the ground */
					LC_AppData.ActionpointState[apt_index] = PASSIVE;
				}
			}
			return Status;
		} else if ((eq_element & 0xC000) == 0) {
			/* watchpoint index */
			Status = stack_push(&RpnEquStack,
					LC_AppData.WatchpointState[eq_element - 1]);
			if (Status != CFE_SUCCESS) {
				return Status;
			}
		} else {
			/* operator; pull operands from stack, perform operation, push result */
			/* watchpoint index; push to stack */
			Status = stack_pop(&RpnEquStack, &operand_1);
			if (Status != CFE_SUCCESS) {
				return Status;
			}

			if (eq_element == AND || eq_element == OR) {
				/* AND and OR take two arguments, NOT only needs one */
				Status = stack_pop(&RpnEquStack, &operand_2);
				if (Status != CFE_SUCCESS) {
					return Status;
				}
			}

			switch (eq_element) {
			case AND:
				tmp = operand_1 && operand_2;
				break;

			case OR:
				tmp = operand_1 || operand_2;
				break;

			case NOT:
				tmp = (operand_1 ? 0 : 1);
				break;
			}

			Status = stack_push(&RpnEquStack, tmp);
			if (Status != CFE_SUCCESS) {
				return Status;
			}
		}
	}

	DEBUG("LC: Evaluating actionpoint %d\n", apt_index);

	return Status;
}

uint32 fire_rts(LC_ActionpointDefinition_t* ap, int ap_number) {
	int32 Status = CFE_SUCCESS;

	/*  fire RTS */
	SC_TSCmd_t SC_CmdPkt;

	CFE_SB_InitMsg(&SC_CmdPkt, SC_CMD_MID, sizeof(SC_TSCmd_t), TRUE);
	CFE_SB_SetCmdCode((CFE_SB_MsgPtr_t) &SC_CmdPkt, SC_START_RTS_CC);
	SC_CmdPkt.Number = ap->rts_id;

	Status = CFE_SB_SendMsg((CFE_SB_MsgPtr_t) &SC_CmdPkt);

	if (Status != CFE_SUCCESS) {
		CFE_EVS_SendEvent(LC_FIRE_RTS_ERR_EID, CFE_EVS_ERROR,
				"LC: Failed to fire RTS, RC=0x%08X", Status);
	}

	return Status;
}
