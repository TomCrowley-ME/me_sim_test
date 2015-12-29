/* sysGpio.c - TIAM335X GPIO module */

/*
 * Copyright (c) 2012 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify or otherwise make use
 * of this software may be licensed only pursuant to the terms
 * of an applicable Wind River license agreement.
 */

/*
modification history
--------------------
01a,09may12,my_ written.
*/

#include <vxWorks.h>
#include "config.h"
#include "sysGpio.h"

LOCAL UINT32 sysGpioModuleBase[4] = {
	AM335X_GPIO0_BASE,
	AM335X_GPIO1_BASE,
	AM335X_GPIO2_BASE,
	AM335X_GPIO3_BASE
};
/******************************************************************************* *
* sysGpioReset - perform software reset operation on a given GPIO module
*
* This routine performs software reset operation on a given GPIO module
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

_WRS_INLINE void sysGpioReset
    (
    unsigned int base
    )
    {
    unsigned int val;

    val = am335xInLong (base + AM335X_GPIO_SYSCONFIG);
    am335xOutLong (base + AM335X_GPIO_SYSCONFIG, val | 0x2);
    }

/*******************************************************************************
*
* sysGpioInit - initialize GPIO modules
*
* This routine initializes GPIO modules.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void sysGpioInit (void)
    {
    omapClockEnable (&gpio0);
    omapClockEnable (&gpio1);
    omapClockEnable (&gpio2);
    omapClockEnable (&gpio3);

    sysGpioReset (AM335X_GPIO0_BASE);
    sysGpioReset (AM335X_GPIO1_BASE);
    sysGpioReset (AM335X_GPIO2_BASE);
    sysGpioReset (AM335X_GPIO3_BASE);

    omapPadConfig (gpio_pads);
    }

STATUS sysGpioOutputEnable(UINT32 pinNumber) {
	UINT32 moduleBase;
	UINT32 modulePin;
	UINT32 val;

	if (pinNumber <= GPIO_MAX_PIN_NUM) {
		modulePin = GPIO_MODULE_PIN(pinNumber);
		moduleBase = sysGpioModuleBase[GPIO_MODULE_NUMBER(pinNumber)];

		val = am335xInLong(moduleBase + AM335X_GPIO_OE);
		val &= ~(0x1 << modulePin);
		am335xOutLong(moduleBase + AM335X_GPIO_OE, val);

		return OK;
	} else {
		return ERROR;
	}
}

STATUS sysGpioOutputDisable(UINT32 pinNumber) {
	UINT32 moduleBase;
	UINT32 modulePin;
	UINT32 val;

	if (pinNumber <= GPIO_MAX_PIN_NUM) {
		modulePin = GPIO_MODULE_PIN(pinNumber);
		moduleBase = sysGpioModuleBase[GPIO_MODULE_NUMBER(pinNumber)];

		val = am335xInLong(moduleBase + AM335X_GPIO_OE);
		val |= (0x1 << modulePin);
		am335xOutLong(moduleBase + AM335X_GPIO_OE, val);

		return OK;
	} else {
		return ERROR;
	}
}

STATUS sysGpioSet(UINT32 pinNumber) {
	UINT32 moduleBase;
	UINT32 modulePin;

	if (pinNumber <= GPIO_MAX_PIN_NUM) {
		modulePin = GPIO_MODULE_PIN(pinNumber);
		moduleBase = sysGpioModuleBase[GPIO_MODULE_NUMBER(pinNumber)];

		am335xOutLong(moduleBase + AM335X_GPIO_SETDATAOUT, (0x1 << modulePin));

		return OK;
	} else {
		return ERROR;
	}
}

STATUS sysGpioClear(UINT32 pinNumber) {
	UINT32 moduleBase;
	UINT32 modulePin;

	if (pinNumber <= GPIO_MAX_PIN_NUM) {
		modulePin = GPIO_MODULE_PIN(pinNumber);
		moduleBase = sysGpioModuleBase[GPIO_MODULE_NUMBER(pinNumber)];

		am335xOutLong(moduleBase + AM335X_GPIO_CLEARDATAOUT, (0x1 << modulePin));

		return OK;
	} else {
		return ERROR;
	}
}

STATUS sysGpioGet(UINT32 pinNumber, UINT8 *level) {
	UINT32 moduleBase;
	UINT32 modulePin;
        if (level == NULL) {
            return ERROR;
        }

	if (pinNumber <= GPIO_MAX_PIN_NUM) {
                UINT32 pin_levels;

		modulePin = GPIO_MODULE_PIN(pinNumber);
		moduleBase = sysGpioModuleBase[GPIO_MODULE_NUMBER(pinNumber)];

		pin_levels = am335xInLong(moduleBase + AM335X_GPIO_DATAIN);

                *level = (pin_levels & (1<<modulePin)) ? 1 : 0;

		return OK;
	} else {
		return ERROR;
	}
}
