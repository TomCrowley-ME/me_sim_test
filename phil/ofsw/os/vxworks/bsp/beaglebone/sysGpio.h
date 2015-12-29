/* sysGpio.h - SD MMC driver header file */

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
01a,09may12,my_ written from ti_dm81xx_evm 01a
*/

#ifndef __INCsysGpioh
#define __INCsysGpioh

#ifdef __cplusplus
extern "C" {
#endif

/* defines */

#define GPIO_PIN_NUMBER(module, pin) \
	(((module)<<5) | (pin))

#define GPIO_MODULE_NUMBER(pinNumber) \
	(((pinNumber) & 0x60) >> 5)

#define GPIO_MODULE_PIN(pinNumber) \
	((pinNumber) & 0x1f)

#define GPIO_MAX_PIN_NUM (0x7f)

/* function prototypes */

STATUS sysGpioOutputEnable(UINT32 pinNumber);
STATUS sysGpioOutputDisable(UINT32 pinNumber);
STATUS sysGpioSet(UINT32 pinNumber);
STATUS sysGpioClear(UINT32 pinNumber);
STATUS sysGpioGet(UINT32 pinNumber, UINT8 *level);

#ifdef __cplusplus
}
#endif

#endif /* __INCsysGpioh */
