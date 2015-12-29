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

#include "pru_icss.h"
#include "puppetmaster_interface.h"

int32 THRSIM_HWIF_Init(void) {
    return CFE_SUCCESS;
}

int32 THRSIM_ReadDeviceData(thr_sim_msg_t *thr_sim_msg) {
    CFE_TIME_SysTime_t TransitionMET, TransitionUTC;
    ValveState_t *ValveStates;
    uint32 i;

    uint8 ValveStatus;
    uint16 ValveSubseconds;

    uint32 METseconds;

    /*
     * Reading thruster states from the valves mcu is the synchronization
     * point for the start of the simulation frame. The PRU firmware should,
     * at the beginning of each cycle, wait to be specifically told to go and
     * fetch thruster states, in order to make sure they're accessed as close
     * to the start of the physics step as possible. After this, the PRU will
     * do its own thing and transmit/receive things as it pleases, until the
     * start of the next frame
     */
    pru_icss_set_event(VALVES_READ_EVENT);

    /* Wait for the thruster interrogation to complete */
    if (pru_icss_wait_event_clear(VALVES_READ_EVENT, sysClkRateGet()/400) == ERROR) {
        /* Give up on this attempt, we'll try again next time */
        pru_icss_clear_event(VALVES_READ_EVENT);
        return ERROR;
    }

    ValveStates = (ValveState_t *)(PRU0_DRAM_BASE + VALVES_BUFFER_ADDR);

    METseconds = CFE_TIME_GetMETseconds();

    /* Build up state information for each valve */
    for (i = 0; i < THRSIM_NUM_VALVES; i++) {
        uint8 ThrNum;

        /* If the valve isn't mapped, skip over it */
        ThrNum = THRSIM_ValveMap[i];
        if (ThrNum == 0) {
            continue;
        }

        /* Adjust down the thruster number for 0-based indexing */
        ThrNum--;

        /* Read in state info for the current valve */
        ValveStatus = ValveStates[i].status;
        ValveSubseconds = ValveStates[i].subseconds;

        /* Process the data into sim-friendly format */
        if (ValveStatus & THRSIM_VALVESTATE_TO) {
            /* Transition occurred. We first need to translate the MET of the transition into UTC */
            TransitionMET.Seconds = METseconds - THRSIM_VALVESTATE_NPPS(ValveStatus);
            TransitionMET.Subseconds = ValveSubseconds << 16;

            TransitionUTC = CFE_TIME_MET2SCTime(TransitionMET);
            thr_sim_msg->transition_time[ThrNum] = (double)TransitionUTC.Seconds + ((double)(CFE_TIME_Sub2MicroSecs(TransitionUTC.Subseconds))/1000000.0);

            /* Populate the transtiion type information */
            if (ValveStatus & THRSIM_VALVESTATE_RF) {
                thr_sim_msg->transition[ThrNum] = THRSIM_RISING_TRANSITION;
            } else {
                thr_sim_msg->transition[ThrNum] = THRSIM_FALLING_TRANSITION;
            }
        } else {
            /* No transition happened on this valve */
            thr_sim_msg->transition[ThrNum] = THRSIM_NO_TRANSITION;
            thr_sim_msg->transition_time[ThrNum] = 0;
        }
    }
    return CFE_SUCCESS;
}
