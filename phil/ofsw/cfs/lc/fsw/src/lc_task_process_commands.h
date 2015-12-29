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
 * lc_task_process_commands.h
 *
 *  Created on: May 10, 2014
 *      Author: tklaus
 */

#ifndef LC_TASK_PROCESS_COMMANDS_H_
#define LC_TASK_PROCESS_COMMANDS_H_

#include "cfe.h"

int32 LC_ProcessCommandMsg(void);
int32 LC_ProcessGroundCommand(void);
int32 LC_ReportHousekeeping(void);
int32 LC_ResetCounters(void);
int32 LC_ResetActionpointStates(void);
int32 LC_SetGlobalState(void);
int32 LC_SetActionpointState(void);
boolean LC_VerifyCmdLength(CFE_SB_MsgPtr_t msg, uint16 ExpectedLength);

#endif /* LC_TASK_PROCESS_COMMANDS_H_ */
