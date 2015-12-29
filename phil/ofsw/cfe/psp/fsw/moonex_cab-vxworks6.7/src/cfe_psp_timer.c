/************************************************************************************************
** File:  cfe_psp_timer.c
**
**
**      Copyright (c) 2004-2012, United States government as represented by the
**      administrator of the National Aeronautics Space Administration.
**      All rights reserved. This software(cFE) was created at NASA Goddard
**      Space Flight Center pursuant to government contracts.
**
**      This is governed by the NASA Open Source Agreement and may be used,
**      distributed and modified only pursuant to the terms of that agreement.
**
**
**
** Purpose:
**   This file contains glue routines between the cFE and the OS Board Support Package ( BSP ).
**   The functions here allow the cFE to interface functions that are board and OS specific
**   and usually dont fit well in the OS abstraction layer.
**
** History:
**   2005/06/05  K.Audra    | Initial version,
**
*************************************************************************************************/

/*
**  Include Files
*/

/*
**  Include Files
*/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "vxWorks.h"
#include "sysLib.h"
#include "vxLib.h"
#include "taskLib.h"
#include "ramDrv.h"
#include "dosFsLib.h"
#include "errnoLib.h"
#include "usrLib.h"
#include "cacheLib.h"
#include "vxBusLib.h"
#include "vxbTimerLib.h"
#include "hwif/util/vxbParamSys.h"

#include <hwif/grlib/gpiolib.h>
#include "moonex_cab.h"

/*
** cFE includes
*/
#include "common_types.h"
#include "osapi.h"
#include "cfe_es.h"            /* For reset types */
#include "cfe_platform_cfg.h"  /* for processor ID */

/*
** Types and prototypes for this module
*/
#include "cfe_psp.h"

/*
** External Declarations
*/
extern void CFE_TIME_Tone1HzISR(void);
extern void CFE_TIME_Local1HzISR(void);
extern void sysClk1HzCallbackAttach(VOIDFUNCPTR callback);

extern struct vxbTimerFunctionality *pVxbDelayTimer;
extern void *pVxbDelayCookie;

/*
** Local Declarations
*/
static void CFE_PSP_LocalRolloverISR(int x);

static volatile uint32 localTimerRollCount = 0;

/******************* Macro Definitions ***********************/

#define CFE_PSP_TIMER_TICKS_PER_SECOND         8250000   /* Resolution of the least significant 32 bits of the 64 bit
                                                           time stamp returned by OS_BSPGet_Timebase in timer ticks per second.
                                                           The timer resolution for accuracy should not be any slower than 1000000
                                                           ticks per second or 1 us per tick */
#define CFE_PSP_TIMER_LOW32_ROLLOVER         4290000000  /* The number that the least significant 32 bits of the 64 bit
                                                           time stamp returned by OS_BSPGet_Timebase rolls over.  If the lower 32
                                                           bits rolls at 1 second, then the OS_BSP_TIMER_LOW32_ROLLOVER will be 1000000.
                                                           if the lower 32 bits rolls at its maximum value (2^32) then
                                                           OS_BSP_TIMER_LOW32_ROLLOVER will be 0. */

#define CFE_PSP_TIMER_SHIFT                           2   /* Translation factors used to convert between timer ticks and microseconds */
#define CFE_PSP_TIMER_DIVISOR                        33   /* For subsecond value n, (n<<2)/33 is equivalent to n/8.25, without bringing
                                                            the FPU into the mix */

#define CFE_PSP_LOCAL_1HZ_TIMER_NAME  "grlibGpTimerDev"   /* VxBus device information for the local 1hz timer */
#define CFE_PSP_LOCAL_1HZ_TIMER_UNIT                  0
#define CFE_PSP_LOCAL_1HZ_TIMER_NUM                   3

/******************************************************************************
**  Function:  CFE_PSP_GetTime()
**
**  Purpose: Gets the value of the time from the hardware
**
**  Arguments: LocalTime - where the time is returned through
******************************************************************************/

void CFE_PSP_GetTime(OS_time_t *LocalTime)
{
    UINT32 counterVal;

    pVxbDelayTimer->timerCountGet(pVxbDelayCookie, &counterVal);

    LocalTime->seconds = counterVal / CFE_PSP_TIMER_TICKS_PER_SECOND;
    LocalTime->microsecs = ((counterVal % CFE_PSP_TIMER_TICKS_PER_SECOND) << CFE_PSP_TIMER_SHIFT) / CFE_PSP_TIMER_DIVISOR;
}/* end CFE_PSP_GetLocalTime */

/******************************************************************************
**  Function:  CFE_PSP_GetLocalMET
**
**  Purpose: Gets the value of the MET from the hardware
**
**  Arguments: seconds - where the time is returned through
******************************************************************************/

void CFE_PSP_GetLocalMET(uint32 *seconds)
{
    *seconds = cabGetMET();
}/* end CFE_PSP_GetLocalMET */

/******************************************************************************
**  Function:  CFE_PSP_SetLocalMET
**
**  Purpose: Sets the value of the MET from the hardware
**
**  Arguments: seconds - the new value of the hardware MET
******************************************************************************/

void CFE_PSP_SetLocalMET(uint32 seconds)
{
    cabSetMET(seconds);
}/* end CFE_PSP_SetLocalMET */


/******************************************************************************
**  Function:  CFE_PSP_Get_Timer_Tick()
**
**  Purpose:
**    Provides a common interface to system clock tick. This routine
**    is in the BSP because it is sometimes implemented in hardware and
**    sometimes taken care of by the RTOS.
**
**  Arguments:
**
**  Return:
**  OS system clock ticks per second
*/
uint32 CFE_PSP_Get_Timer_Tick(void)
{
   return (sysClkRateGet());
}

/******************************************************************************
**  Function:  CFE_PSP_GetTimerTicksPerSecond()
**
**  Purpose:
**    Provides the resolution of the least significant 32 bits of the 64 bit
**    time stamp returned by CFE_PSP_Get_Timebase in timer ticks per second.
**    The timer resolution for accuracy should not be any slower than 1000000
**    ticks per second or 1 us per tick
**
**  Arguments:
**
**  Return:
**    The number of timer ticks per second of the time stamp returned
**    by CFE_PSP_Get_Timebase
*/
uint32 CFE_PSP_GetTimerTicksPerSecond(void)
{
    return pVxbDelayTimer->clkFrequency;
}

/******************************************************************************
**  Function:  CFE_PSP_GetTimerLow32Rollover()
**
**  Purpose:
**    Provides the number that the least significant 32 bits of the 64 bit
**    time stamp returned by CFE_PSP_Get_Timebase rolls over.  If the lower 32
**    bits rolls at 1 second, then the CFE_PSP_TIMER_LOW32_ROLLOVER will be 1000000.
**    if the lower 32 bits rolls at its maximum value (2^32) then
**    CFE_PSP_TIMER_LOW32_ROLLOVER will be 0.
**
**  Arguments:
**
**  Return:
**    The number that the least significant 32 bits of the 64 bit time stamp
**    returned by CFE_PSP_Get_Timebase rolls over.
*/
uint32 CFE_PSP_GetTimerLow32Rollover(void)
{
    UINT32 maxCount;

    pVxbDelayTimer->timerRolloverGet(pVxbDelayCookie, &maxCount);
    return (uint32)maxCount;
}

/******************************************************************************
**  Function:  CFE_PSP_Get_Timebase()
**
**  Purpose:
**    Provides a common interface to system timebase. This routine
**    is in the BSP because it is sometimes implemented in hardware and
**    sometimes taken care of by the RTOS.
**
**  Arguments:
**
**  Return:
**  Timebase register value
*/
void CFE_PSP_Get_Timebase(uint32 *Tbu, uint32* Tbl)
{
    *Tbu = localTimerRollCount;
    pVxbDelayTimer->timerRolloverGet(pVxbDelayCookie, (UINT32*)Tbl);
}

/******************************************************************************
**  Function:  CFE_PSP_Get_Dec()
**
**  Purpose:
**    Provides a common interface to decrementer counter. This routine
**    is in the BSP because it is sometimes implemented in hardware and
**    sometimes taken care of by the RTOS.
**
**  Arguments:
**
**  Return:
**  Timebase register value
*/

uint32 CFE_PSP_Get_Dec(void)
{
   /* SUB -add function call code*/
   return(0);
}

/******************************************************************************
**  Function:  CFE_PSP_Init1HzTone()
**
**  Purpose:
**    Initializes the 1Hz Tone interrupt
**
**  Arguments:
**
**  Return:
**
*/
void CFE_PSP_Init1HzTone()
{
    void *gpio_handle;
    struct gpiolib_config gpio_cfg;

    /* Set up GPIO5 for a rising-edge interrupt */
    gpio_handle = gpioLibOpen(5);
    gpioLibSet(gpio_handle, 0, 0);

    gpio_cfg.mask = 1;
    gpio_cfg.irq_level = GPIOLIB_IRQ_EDGE;
    gpio_cfg.irq_polarity = GPIOLIB_IRQ_POL_HIGH;
    gpioLibSetConfig(gpio_handle, &gpio_cfg);

    /* Connect the Tone ISR and enable it */
    gpioLibIrqDisable(gpio_handle);
    gpioLibIrqClear(gpio_handle);
    gpioLibIrqRegister(gpio_handle, CFE_TIME_Tone1HzISR, 0);
    gpioLibIrqEnable(gpio_handle);

    gpioLibClose(gpio_handle);
}

/******************************************************************************
**  Function:  CFE_PSP_InitLocalTimers()
**
**  Purpose:
**    Initializes the 1Hz timer and connects it to the CFE local 1Hz ISR, and
**    sets up the 64-bit timestamp timer for local timekeeping
**
**  Arguments:
**
**  Return:
**
*/
void CFE_PSP_InitLocalTimers()
{
    UINT32 maxCount;

    /*
    ** Start off by setting up the local clock and timebase timer. We're going to latch on to the timer that
    ** VxWorks allocated for the delay timer. It's free-running and doesn't generate any interrupts, which
    ** is exactly what we're looking for.
    **
    **  We need to install our own ISR to handle overflow counting for the timebase timer, so to prevent
    ** any weirdness for tasks using the delay functions, we do a task lock (under the assumption that
    ** all bets are off for anybody that got preempted to run this while delaying)
    */
    taskLock();

    pVxbDelayTimer->timerDisable(pVxbDelayCookie);

    pVxbDelayTimer->timerISRSet(pVxbDelayCookie, (void(*)(int))CFE_PSP_LocalRolloverISR, 0);

    pVxbDelayTimer->timerRolloverGet(pVxbDelayCookie, &maxCount);
    pVxbDelayTimer->timerEnable(pVxbDelayCookie, (maxCount / pVxbDelayTimer->clkFrequency) * pVxbDelayTimer->clkFrequency);

    taskUnlock();

    /* Set up the local 1Hz timer. We're piggybacking on sysClk for this one */
    sysClk1HzCallbackAttach(CFE_TIME_Local1HzISR);
}

/******************************************************************************
**  Function:  CFE_PSP_LocalRolloverISR()
**
**  Purpose:
**    Counts rollovers of the local clock, for use with the timebase timer
**
**  Arguments:
**
**  Return:
**
*/
static void CFE_PSP_LocalRolloverISR(int x) {
    localTimerRollCount++;
}
