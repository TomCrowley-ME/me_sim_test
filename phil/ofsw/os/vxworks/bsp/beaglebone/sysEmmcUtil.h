/* sysEmmcUtil.h - EMMC driver header file */

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

#ifndef __INCsysEmmcUtilh
#define __INCsysEmmcUtilh

#ifdef __cplusplus
extern "C" {
#endif

/* defines */

#define AM335X_SDTXEVT1           2
#define AM335X_SDRXEVT1           3

/* function prototypes */

BOOL sysEmmcPowerInit (void);
BOOL sysEmmcPowerOn   (void);
BOOL sysEmmcDetect    (void);
BOOL sysEmmcWpCheck   (void);

#ifdef __cplusplus
}
#endif

#endif /* __INCsysEmmcUtilh */
