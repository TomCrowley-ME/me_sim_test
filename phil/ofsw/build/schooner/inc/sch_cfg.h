/******************************************************************************
** File: sch_cfg.h
**
** Purpose:
**   This file contains defines for the Scheduler task
**
******************************************************************************/

#ifndef SCH_CFG_H
#define SCH_CFG_H

/*****************************************************************************/
/* SCH Configuration Parameters */

/* Maximum number of Activities per Minor Frame */
#define SCH_ENTRIES_PER_SLOT 5

/* Maxiumum number of slots allowed for catch-up before skipping */
#define SCH_MAX_LAG_COUNT 50

/* Maximum number of message definitions in the Message Definition Table */
#define SCH_MAX_MESSAGE 128

/* Maxiumum length, in words, of a message */
#define SCH_MAX_MSG_WORDS 64

/* Maximum number of consecutive noisy Major Frame signals before they are ignored */
#define SCH_MAX_NOISY_MF 2

/* Maximum number of slots to be processed when in "Catch Up" mode */
#define SCH_MAX_SLOTS_PER_WAKEUP 5

/* Default SCH Message Definition Table filename */
#define SCH_MESSAGE_FILENAME "/cf/ptbl/sch_def_msgtbl.tbl"

/* Major Frame period (in microseconds) */
#define SCH_MICROS_PER_MAJOR_FRAME 1000000

/* Software Bus command pipe depth */
#define SCH_PIPE_DEPTH 12

/* Default SCH Schedule Definition Table filename */
#define SCH_SCHEDULE_FILENAME "/cf/ptbl/sch_def_schtbl.tbl"

/* Time, in microseconds, to wait for the first Major Frame Sync to arrive */
#define SCH_STARTUP_PERIOD 5000000

/* Time, in milliseconds, to wait for all applications to be started and ready to run */
#define SCH_STARTUP_SYNC_TIMEOUT 50000

/* Minor Frame Frequency (in Hz) */
#define SCH_TOTAL_SLOTS 100

/* Message ID for unused message definitions */
#define SCH_UNUSED_MID (CFE_SB_HIGHEST_VALID_MSGID+1)

/* Timer period in microseconds */
#define SCH_TIMER_USEC (SCH_MICROS_PER_MAJOR_FRAME/SCH_TOTAL_SLOTS)

/* Additional time allowed in Sync Slot to wait for Major Frame Sync (in microseconds) */
#define SCH_SYNC_SLOT_DRIFT_WINDOW (SCH_TIMER_USEC/2)

#endif
