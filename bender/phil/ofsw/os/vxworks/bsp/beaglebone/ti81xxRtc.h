/* ti81xxRtc.h - TI DM81XX RTC register definitions */

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

#ifndef __INCti81xxRtch
#define __INCti81xxRtch

#ifdef __cplusplus
extern "C" {
#endif

/* register */

#define TI81XX_RTC_SECONDS_REG          0x0000
#define TI81XX_RTC_MINUTES_REG          0x0004
#define TI81XX_RTC_HOURS_REG            0x0008
#define TI81XX_RTC_DAYS_REG             0x000C
#define TI81XX_RTC_MONTHS_REG           0x0010
#define TI81XX_RTC_YEARS_REG            0x0014
#define TI81XX_RTC_WEEK_REG             0x0018
#define TI81XX_RTC_ALARM_SECONDS_REG    0x0020
#define TI81XX_RTC_ALARM_MINUTES_REG    0x0024
#define TI81XX_RTC_ALARM_HOURS_REG      0x0028
#define TI81XX_RTC_ALARM_DAYS_REG       0x002C
#define TI81XX_RTC_ALARM_MONTHS_REG     0x0030
#define TI81XX_RTC_ALARM_YEARS_REG      0x0034
#define TI81XX_RTC_CTRL_REG             0x0040
#define TI81XX_RTC_STATUS_REG           0x0044
#define TI81XX_RTC_INTERRUPTS_REG       0x0048
#define TI81XX_RTC_COMP_LSB_REG         0x004C
#define TI81XX_RTC_COMP_MSB_REG         0x0050
#define TI81XX_RTC_OSC_REG              0x0054
#define TI81XX_RTC_SCRATCH0_REG         0x0060
#define TI81XX_RTC_SCRATCH1_REG         0x0064
#define TI81XX_RTC_SCRATCH2_REG         0x0068
#define TI81XX_RTC_KICK0                0x006C
#define TI81XX_RTC_KICK1                0x0070
#define TI81XX_RTC_REVISION             0x0074
#define TI81XX_RTC_SYSCONFIG            0x0078
#define TI81XX_RTC_IRQWAKEEN_0          0x007A

/* RTC control */

#define TI81XX_RTC_CTRL_DISABLE         (1<<6)
#define TI81XX_RTC_CTRL_SET32KHZ        (1<<5)
#define TI81XX_RTC_CTRL_TESTMODE        (1<<4)
#define TI81XX_RTC_CTRL_MODE12          (1<<3)
#define TI81XX_RTC_CTRL_AUTOCOMP        (1<<2)
#define TI81XX_RTC_CTRL_ROUND30S        (1<<1)
#define TI81XX_RTC_CTRL_RUN             (1<<0)

/* RTC status */

#define TI81XX_RTC_STATUS_ALARM         (1<<6)
#define TI81XX_RTC_STATUS_1DEVT         (1<<5)
#define TI81XX_RTC_STATUS_1HEVT         (1<<4)
#define TI81XX_RTC_STATUS_1MEVT         (1<<3)
#define TI81XX_RTC_STATUS_1SEVT         (1<<2)
#define TI81XX_RTC_STATUS_RUN           (1<<1)
#define TI81XX_RTC_STATUS_BUSY          (1<<0)

/* misc bits */

#define TI81XX_RTC_KICK_KEY0            0x83E70B13
#define TI81XX_RTC_KICK_KEY1            0x95A4F1E0

/* clock sel */

#define TI81XX_32KCLK_EN                (0x40)
#define TI81XX_32KCLK_SEL               (0x8)

#define TI81XX_RTC_HOURS_IS_PM          0x0080

/* utility */

#define TI81XX_RTC_REGISTER_READ(reg) \
    (*(volatile UINT *)(RTC_BASE + (UINT)(reg)))

#define TI81XX_RTC_REGISTER_WRITE(reg, data) \
    (*((volatile UINT *)(RTC_BASE + (UINT)(reg))) = (data))

#define TI81XX_RTC_REG_TO_VAL(reg)    \
    ((((UINT)(reg) & 0x70) >> 4 ) * 10 + ((UINT)(reg) & 0xf))

#define TI81XX_RTC_VAL_TO_REG(val)    \
    ((((UINT)(val) / 10) << 4) | ((UINT)(val) % 10))

/* enum */

typedef enum cal_regs
{
    RTC_TC_SEC      =0x0,
    RTC_TC_MIN      =0x4,
    RTC_TC_HOUR     =0x8,
    RTC_TC_DAY      =0xc,
    RTC_TC_MONTH    =0x10,
    RTC_TC_YEAR     =0x14,
    RTC_TC_WEEK     =0x18
}RTC_CAL_REGS;

typedef enum cal_week
{
    RTC_WEEK_SUN    =0x0,
    RTC_WEEK_MON    ,
    RTC_WEEK_TUE    ,
    RTC_WEEK_WED    ,
    RTC_WEEK_THU    ,
    RTC_WEEK_FRI    ,
    RTC_WEEK_SAT
}RTC_CAL_WEEK;

typedef enum cal_month
{
    RTC_MONTH_JAN    =0x01,
    RTC_MONTH_FEB    ,
    RTC_MONTH_MAR    ,
    RTC_MONTH_APR    ,
    RTC_MONTH_MAY    ,
    RTC_MONTH_JUN    ,
    RTC_MONTH_JUL    ,
    RTC_MONTH_AUG    ,
    RTC_MONTH_SEP    ,
    RTC_MONTH_OCT    ,
    RTC_MONTH_NOV    ,
    RTC_MONTH_DEC
}RTC_CAL_MONTH;

/* api */

void ti81xxRtcInit( );
void ti81xxRtcShutdown( );

UINT ti81xxRtcTcRead(RTC_CAL_REGS regs);
UINT ti81xxRtcTcWrite(RTC_CAL_REGS regs,UINT vale);

#ifdef __cplusplus
}
#endif

#endif /* __INCti81xxRtch */

