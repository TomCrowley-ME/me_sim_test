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
#include "cfe.h"
#include "thrsim.h"

typedef struct {
    double thrio_time;
    uint8  thr_ontimes[THRSIM_NUM_VALVES];
} thrsim_cmd_t;

uint32 g_thrio_q_id;

static double RemainingOntimes[THRSIM_NUM_VALVES];
static double ClosingTimes[THRSIM_NUM_VALVES];

int32 THRSIM_HWIF_Init(void) {
    /* Create a queue for HWIO<-->HWSIM communication */
    return OS_QueueCreate(&g_thrio_q_id, "thrio_q", 4, sizeof(thrsim_cmd_t), 0);
}

int32 THRSIM_ReadDeviceData(thr_sim_msg_t *thr_sim_msg) {
    int32 Status;
    uint32 SizeCopied;
    CFE_TIME_SysTime_t CurrentTime;
    thrsim_cmd_t thrsim_cmd;
    double CurrentSeconds;
    uint32 i;

    CurrentTime = CFE_TIME_GetTime();
    CurrentSeconds = (double)CurrentTime.Seconds + ((double)(CFE_TIME_Sub2MicroSecs(CurrentTime.Subseconds))/1000000.0);

    Status = OS_QueueGet(g_thrio_q_id, &thrsim_cmd, sizeof(thrsim_cmd_t), &SizeCopied, OS_CHECK);
    if (Status == CFE_SUCCESS) {
        for (i = 0; i < THRSIM_NUM_VALVES; i++) {
            if (thrsim_cmd.thr_ontimes[i] != 0 && RemainingOntimes[i] == 0) {
                /* Thruster was previously off, mark new rising transition now */
                thr_sim_msg->transition[i] = THRSIM_RISING_TRANSITION;
                thr_sim_msg->transition_time[i] = thrsim_cmd.thrio_time;
                RemainingOntimes[i] = thrsim_cmd.thr_ontimes[i]/1000.0 - (CurrentSeconds - thrsim_cmd.thrio_time);
                ClosingTimes[i] = thrsim_cmd.thrio_time + thrsim_cmd.thr_ontimes[i]/1000.0;
            } else if (thrsim_cmd.thr_ontimes[i] == 0 && RemainingOntimes[i] != 0) {
                /* Thruster was on, but is now commanded off */
                thr_sim_msg->transition[i] = THRSIM_FALLING_TRANSITION;
                thr_sim_msg->transition_time[i] = thrsim_cmd.thrio_time;
                RemainingOntimes[i] = 0;
            } else {
                thr_sim_msg->transition[i] = 0;
                thr_sim_msg->transition_time[i] = 0;

                if (thrsim_cmd.thr_ontimes[i] == 0) {
                    RemainingOntimes[i] = 0;
                    ClosingTimes[i] = 0;
                } else {
                    RemainingOntimes[i] = thrsim_cmd.thr_ontimes[i]/1000.0 - (CurrentSeconds - thrsim_cmd.thrio_time);
                    ClosingTimes[i] = thrsim_cmd.thrio_time + thrsim_cmd.thr_ontimes[i]/1000.0;
                }
            }
        }
    } else {
        for (i = 0; i < THRSIM_NUM_VALVES; i++) {
            if (RemainingOntimes[i] > 0 && RemainingOntimes[i] <= 0.01) {
                /* Thruster turned off this cycle */
                thr_sim_msg->transition[i] = THRSIM_FALLING_TRANSITION;
                thr_sim_msg->transition_time[i] = ClosingTimes[i];
                ClosingTimes[i] = 0;
                RemainingOntimes[i] = 0;
            } else {
                if (RemainingOntimes[i] != 0)  {
                    RemainingOntimes[i] -= 0.01;
                }
                thr_sim_msg->transition[i] = 0;
                thr_sim_msg->transition_time[i] = 0;
            }
        }
    }

    return CFE_SUCCESS;
}
