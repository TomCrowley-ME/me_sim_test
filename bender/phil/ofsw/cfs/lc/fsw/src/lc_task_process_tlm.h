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
 * lc_task_process_tlm.h
 *
 *  Created on: May 10, 2014
 *      Author: tklaus
 */

#ifndef LC_TASK_PROCESS_TLM_H_
#define LC_TASK_PROCESS_TLM_H_

int32 LC_ProcessTelemetryMsg(void);
int32 LC_Subscribe_Tlm(void);
int32 LC_Unsubscribe_Tlm(void);

#endif /* LC_TASK_PROCESS_TLM_H_ */
