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
#include "intLib.h"
#include "iv.h"
#include "vxBusLib.h"
#include "vxbTimerLib.h"
#include "hwif/util/vxbParamSys.h"

/*
** cFE includes
*/
#include "common_types.h"
#include "osapi.h"
#include "cfe_es.h"            /* For reset types */
#include "cfe_platform_cfg.h"  /* for processor ID */

#include "beaglebone.h"

/*
** External Declarations
*/
extern void CFE_TIME_Tone1HzISR(void);
extern void CFE_TIME_Local1HzISR(void);
extern void sysClk1HzCallbackAttach(VOIDFUNCPTR callback);

/*
** Local Declarations
*/
static void CFE_PSP_ToneISR(int x);
static void CFE_PSP_LocalRolloverISR(int x);

static struct vxbTimerFunctionality *localTimer;
static void *localTimerCookie;
static volatile uint32 localTimerRollCount = 0;

/*
** Types and prototypes for this module
*/
#include "cfe_psp.h"


/******************************************************************************
**  Function:  CFE_PSP_GetTime()
**
**  Purpose: Gets the value of the time from the hardware
**
**  Arguments: LocalTime - where the time is returned through
******************************************************************************/

void CFE_PSP_GetTime(OS_time_t *LocalTime)
{
    uint32 counterVal;
    uint32 clkFrequency;

    localTimer->timerCountGet(localTimerCookie, (UINT32*)&counterVal);
    clkFrequency = localTimer->clkFrequency;

    LocalTime->seconds = counterVal / clkFrequency;
    LocalTime->microsecs = (counterVal % clkFrequency) / (clkFrequency / 1000000);
}/* end CFE_PSP_GetLocalTime */


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
    return localTimer->clkFrequency;
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
    uint32 maxCount;

    localTimer->timerRolloverGet(localTimerCookie, (UINT32*)&maxCount);
    return maxCount;
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
    localTimer->timerCountGet(localTimerCookie, (UINT32*)Tbl);
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
    uint32 val;
    uint32 tone1HzPin = (1 << 7); /* GPIO0_7 */

    val = am335xInLong (AM335X_GPIO0_BASE + AM335X_GPIO_IRQSTATUS_SET1);
    am335xOutLong (AM335X_GPIO0_BASE + AM335X_GPIO_IRQSTATUS_SET1, val | tone1HzPin);

    val = am335xInLong (AM335X_GPIO0_BASE + AM335X_GPIO_RISINGDETECT);
    am335xOutLong (AM335X_GPIO0_BASE + AM335X_GPIO_RISINGDETECT, val | tone1HzPin);

    intConnect((VOIDFUNCPTR *)INUM_TO_IVEC (AM335X_GPIOINT0B), CFE_PSP_ToneISR, 0);
    intEnable(AM335X_GPIOINT0B);
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
    VXB_DEVICE_ID devID;
    FUNCPTR pFunc;
    uint32 maxCount;

    /* Set up the local timer */
    devID = vxbInstByNameFind("omap35xxTimer", 3);
    pFunc = vxbDevMethodGet(devID, (VXB_METHOD_ID)vxbTimerFuncGet_desc);
    (*pFunc)(devID, &localTimer, 0);

    localTimer->timerAllocate(devID, localTimer->features & VXB_TIMER_AUTO_RELOAD, &localTimerCookie, 0);
    localTimer->timerDisable(localTimerCookie);

    /* Hook up our rollover-counting ISR for use with the timebase functions */
    localTimer->timerISRSet(localTimerCookie, (void(*)(_Vx_usr_arg_t))CFE_PSP_LocalRolloverISR, 0);

    /* For rollover accuracy, make the timer roll over exactly on a second boundary */
    localTimerRollCount = 0;
    localTimer->timerRolloverGet(localTimerCookie, (UINT32*)&maxCount);
    localTimer->timerEnable(localTimerCookie, (maxCount / localTimer->clkFrequency) * localTimer->clkFrequency);

    /* Set up the local 1Hz timer. We're piggybacking on sysClk for this one */
    sysClk1HzCallbackAttach(CFE_TIME_Local1HzISR);
}


/******************************************************************************
**  Function:  CFE_PSP_ToneISR()
**
**  Purpose:
**    Calls the CFE TIME Tone ISR. This is needed to properly reset the IRQ
**    status -- otherwise the ISR would never return
**
**  Arguments:
**
**  Return:
**
*/
static void CFE_PSP_ToneISR(int x) {
    uint32 val;
    val = am335xInLong(AM335X_GPIO0_BASE + AM335X_GPIO_IRQSTATUS1);

    CFE_TIME_Tone1HzISR();

    am335xOutLong(AM335X_GPIO0_BASE + AM335X_GPIO_IRQSTATUS1, val);
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
