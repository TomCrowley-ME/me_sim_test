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
 * lc_task_watchpoint_table.h
 *
 *  Created on: May 10, 2014
 *      Author: tklaus
 */

#ifndef LC_TASK_WATCHPOINT_TABLE_H_

#include <cfe_psp.h>

#include "lc_task.h"


int32 LC_wpt_init(LC_WatchpointDefinitionTable_t *wpTblPtr);
int32 LC_wpt_process_message(uint16 message_id, uint8 *message_data);

#define LC_TASK_WATCHPOINT_TABLE_H_

#endif /* LC_TASK_WATCHPOINT_TABLE_H_ */
