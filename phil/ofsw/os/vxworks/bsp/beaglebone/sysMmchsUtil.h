/* sysMmchsUtil.h - SD MMC driver header file */

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

#ifndef __INCsysMmchsUtilh
#define __INCsysMmchsUtilh

#ifdef __cplusplus
extern "C" {
#endif

/* defines */

#define AM335X_MMC0_SDCD          (0x1 << 6)   /* gpio 0 pin 6 */
#define AM335X_MMC0_SDWP          (0x1 << 18)  /* gpio 3 pin 18 */
#define AM335X_SDTXEVT0           24
#define AM335X_SDRXEVT0           25

/* function prototypes */

BOOL sysCardPowerInit (void);
BOOL sysCardPowerOn   (void);
BOOL sysCardDetect    (void);
BOOL sysCardWpCheck   (void);

#ifdef __cplusplus
}
#endif

#endif /* __INCsysMmchsUtilh */
