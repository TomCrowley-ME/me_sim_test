/* ti81xxRtc.c - TI DM81XX RTC routines */

/*
 * Copyright (c) 2011, 2012 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify or otherwise make use
 * of this software may be licensed only pursuant to the terms
 * of an applicable Wind River license agreement.
 */

/*
modification history
--------------------
01b,23aug12,my_  add 335x support
01a,27jan11,ita  written
*/

/* includes */

#include <vxWorks.h>
#include "config.h"
#include "ti81xxRtc.h"

/*******************************************************************************
*
* ti81xxRtcIsBusy - check RTC is busy.
*
* This routine check busy status.
*
* RETURNS: TRUE, or FALSE if not busy
*/

LOCAL BOOL ti81xxRtcIsBusy(void)
    {
    if (TI81XX_RTC_REGISTER_READ(TI81XX_RTC_STATUS_REG) & TI81XX_RTC_STATUS_BUSY)
        return TRUE;
    return FALSE;
    }
/*******************************************************************************
*
* ti81xxRtcInit - RTC init routine.
*
* This routine initialize RTC module
*
* RETURNS: N/A
*/

void ti81xxRtcInit(void)
    {
    /* unlock */

    TI81XX_RTC_REGISTER_WRITE(TI81XX_RTC_KICK0, TI81XX_RTC_KICK_KEY0);
    TI81XX_RTC_REGISTER_WRITE(TI81XX_RTC_KICK1, TI81XX_RTC_KICK_KEY1);

    TI81XX_RTC_REGISTER_WRITE(TI81XX_RTC_OSC_REG, 
		    TI81XX_32KCLK_EN | TI81XX_32KCLK_SEL);

    /* run rtc in 24 hour mode */

    TI81XX_RTC_REGISTER_WRITE(TI81XX_RTC_CTRL_REG, TI81XX_RTC_CTRL_RUN );

    /* lock */

    TI81XX_RTC_REGISTER_WRITE(TI81XX_RTC_KICK0, 0);
    TI81XX_RTC_REGISTER_WRITE(TI81XX_RTC_KICK1, 0);
    }

/*******************************************************************************
*
* ti81xxRtcShutdown - RTC finalize routine.
*
* This routine finalize RTCi (i = 0, 1, 2) module
*
* RETURNS: N/A
*/

void ti81xxRtcShutdown( )
    {
    /* unlock */

    TI81XX_RTC_REGISTER_WRITE(TI81XX_RTC_KICK0, TI81XX_RTC_KICK_KEY0);
    TI81XX_RTC_REGISTER_WRITE(TI81XX_RTC_KICK1, TI81XX_RTC_KICK_KEY1);

    /* stop rtc */

    TI81XX_RTC_REGISTER_WRITE(TI81XX_RTC_CTRL_REG, 0);

    /* lock */

    TI81XX_RTC_REGISTER_WRITE(TI81XX_RTC_KICK0, 0);
    TI81XX_RTC_REGISTER_WRITE(TI81XX_RTC_KICK1, 0);
    }

/*******************************************************************************
*
* ti81xxRtcRead - Read Time/Calendar Data from RTC 
*
* This routine reads time/calendar data from RTC 
*
* RETURNS: Time/Calendar data
*/

UINT ti81xxRtcTcRead
    (
    RTC_CAL_REGS regs
    )
    {
    UINT data;

    /* check busy status */

    while(ti81xxRtcIsBusy());

    /* update TC register */

    data = TI81XX_RTC_REGISTER_READ(TI81XX_RTC_SECONDS_REG);
    
    /* read specfic register */

    data = TI81XX_RTC_REGISTER_READ(regs);

    /* convert from BCD */

    return TI81XX_RTC_REG_TO_VAL(data);
    }

/*******************************************************************************
*
* ti81xxRtcTcWrite - Write Time/Calendar Data to RTC .
*
* This routine writes time/calendar data to RTC 
*
* RETURNS: Time/Calendar value or ERROR if value is out of range
*/

UINT ti81xxRtcTcWrite
    (
    RTC_CAL_REGS regs,
    UINT value
    )
    {
    if(value > 59)
        return (UINT)ERROR;

    /* unlock */

    TI81XX_RTC_REGISTER_WRITE(TI81XX_RTC_KICK0, TI81XX_RTC_KICK_KEY0);
    TI81XX_RTC_REGISTER_WRITE(TI81XX_RTC_KICK1, TI81XX_RTC_KICK_KEY1);

    /* check busy status */

    while(ti81xxRtcIsBusy());

    /* convert to BCD */

    value = TI81XX_RTC_VAL_TO_REG(value);

    /* write to specfic register */

    TI81XX_RTC_REGISTER_WRITE(regs, value);

    /* lock */

    TI81XX_RTC_REGISTER_WRITE(TI81XX_RTC_KICK0, 0);
    TI81XX_RTC_REGISTER_WRITE(TI81XX_RTC_KICK1, 0);

    /* read */

    return ti81xxRtcTcRead(regs);
    }

/*******************************************************************************
*
* sysRtcRead - Read Time/Calendar Data from RTC 
*
* This routine reads time/calendar data from RTC 
*
* RETURNS: Time/Calendar data
*/

UINT sysRtcRead
    (
    UINT regs
    )
    {
    return ti81xxRtcTcRead((RTC_CAL_REGS)regs);
    }

/*******************************************************************************
*
* sysRtcWrite - Write Time/Calendar Data to RTC .
*
* This routine writes time/calendar data to RTC 
*
* RETURNS: Time/Calendar value or ERROR if value is out of range
*/

UINT sysRtcWrite
    (
    UINT regs,
    UINT value
    )
    {
    return ti81xxRtcTcWrite((RTC_CAL_REGS)regs,value);
    }

#define INCLUDE_RTC_TEST
#ifdef INCLUDE_RTC_TEST

#include <stdio.h>

/*******************************************************************************
*
* ti81xxRtcWrite - Write Time/Calendar Data to RTC .
*
* This routine writes time/calendar data to RTC 
*
* RETURNS: Time/Calendar value or ERROR if value is out of range
*/
void ti81xxRtcCalShow( )
    {
    char week[7][4] = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"};
    char month[12][4] = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};

    printf("time : %02d:%02d:%02d \n", ti81xxRtcTcRead(RTC_TC_HOUR),

    ti81xxRtcTcRead(RTC_TC_MIN), ti81xxRtcTcRead(RTC_TC_SEC));
    printf("date : %02d/%s/%02d %s \n", ti81xxRtcTcRead(RTC_TC_DAY),
            month[ti81xxRtcTcRead(RTC_TC_MONTH) - 1],
            1970 + ti81xxRtcTcRead(RTC_TC_YEAR),
            week[ti81xxRtcTcRead(RTC_TC_WEEK)]);
    }
#endif /* INCLUDE_RTC_TEST */
