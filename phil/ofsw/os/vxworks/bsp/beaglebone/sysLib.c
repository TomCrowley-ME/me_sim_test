/* sysLib.c - AM335X system-dependent routines */
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
01g,22nov12,y_c  add memory map for LCDC. (WIND00382478)
01f,23oct12,my_  workround for am335x errata advisory 1.0.9:
                 C0_TX_PEND and C0_RX_PEND interrupts not
                 connected to ARM Cortex-A8 (WIND00384090)
01e,13sep12,my_  fix build failure when including USB component (WIND00375425)
01d,04sep12,my_  add delay timer support
01c,27aug12,my_  add spi flash support
01b,23aug12,my_  add rtc support
01a,10may12,my_  created from ti_dm81xx_evm 01h.
*/

/*
DESCRIPTION
This library provides board-specific routines for the beaglebone BSP.

INCLUDE FILES: sysLib.h string.h intLib.h taskLib.h vxLib.h muxLib.h

SEE ALSO:
\tb VxWorks Programmer's Guide: Configuration
\tb "ARMv7-A Architecture Reference Manual,"
\tb "AM335x ARM Cortex-A8 Microprocessors (MPUs) Technical Reference Manual"
*/

/* includes */

#include <vxWorks.h>
#include "config.h"
#include <sysLib.h>
#include <string.h>
#include <intLib.h>
#include <taskLib.h>
#include <vxLib.h>
#include <muxLib.h>
#include <cacheLib.h>
#include <arch/arm/mmuArmLib.h>
#include <private/vmLibP.h>
#include <dllLib.h>
#include <hwif/intCtlr/vxbOmap35xxIntCtlr.h>
#include <hwif/timer/vxbOmap35xxTimer.h>

/* globals */

#if defined(INCLUDE_MMU)

/*
 * The following structure describes the various different parts of the
 * memory map to be used only during initialization by
 * vm(Base)GlobalMapInit() when INCLUDE_MMU_BASIC/FULL/GLOBAL_MAP are
 * defined.
 *
 * The following are not the smallest areas that could be allocated for a
 * working system. If the amount of memory used by the page tables is
 * critical, they could be reduced.
 */

PHYS_MEM_DESC sysPhysMemDesc [] =
    {

    /*
     * Map the DRAM at phys=virt
     * Warning, this entry MUST be first
     */

    {
    AM335X_SDRC_NCS0,     /* virtual address */
    AM335X_SDRC_NCS0,     /* physical address */
    ROUND_UP (LOCAL_MEM_SIZE, PAGE_SIZE), /* length, then initial state: */
    MMU_ATTR_VALID_MSK   | MMU_ATTR_PROT_MSK | MMU_ATTR_WRITEALLOCATE_MSK,
    MMU_ATTR_VALID       | MMU_ATTR_SUP_RWX  | MMU_ATTR_WRITEALLOCATE
    },

    /* and alias DRAM at zero */

    {
    0x00000000,           /* virtual address */
    AM335X_SDRC_NCS0,     /* physical address */
    ROUND_UP (SZ_1M, PAGE_SIZE), /* length, then initial state: */
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_WRITEALLOCATE_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_WRITEALLOCATE
    },

    /* L3 OCMC RAM */

    {
    AM335X_L3RAM_BASE,     /* virtual address */
    AM335X_L3RAM_BASE,     /* physical address */
    ROUND_UP (AM335X_L3RAM_SIZE, PAGE_SIZE), /* length, then initial state: */
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

    /* prcm base address */

    {
    AM335X_PRCM_BASE,      /* virtual address */
    AM335X_PRCM_BASE,      /* physical address */
    ROUND_UP (SZ_8K, PAGE_SIZE), /* length, then initial state: */
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

    /* control module base */

    {
    AM335X_CTRL_BASE,      /* virtual address */
    AM335X_CTRL_BASE,      /* physical address */
    ROUND_UP (SZ_8K, PAGE_SIZE), /* length, then initial state: */
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

    /* USB */

#if defined(INCLUDE_USB_MHDRC_HCD) || defined(INCLUDE_USB_MHDRC_TCD)
    {
    AM335X_USBSS_BASE,
    AM335X_USBSS_BASE,
    ROUND_UP (SZ_4M, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

#endif

    /* Interrupt Controller */

    {
    AM335X_MPU_INTC,
    AM335X_MPU_INTC,
    ROUND_UP (SZ_4K, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

#if defined(INCLUDE_TTY_DEV) || defined(INCLUDE_SIO_POLL)
    {
    AM335X_UART1_BASE,
    AM335X_UART1_BASE,
    ROUND_UP (AM335X_UART1_SIZE, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

    {
    AM335X_UART2_BASE,
    AM335X_UART2_BASE,
    ROUND_UP (AM335X_UART2_SIZE, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },
#endif /* INCLUDE_TTY_DEV || INCLUDE_SIO_POLL */
    {
    AM335X_GPTIMER0_BASE,  /* General purpose Timer 1 */
    AM335X_GPTIMER0_BASE,
    ROUND_UP (SZ_4K, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

    {
    AM335X_GPTIMER1_BASE,  /* General purpose Timer 1 */
    AM335X_GPTIMER1_BASE,
    ROUND_UP (SZ_4K, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

    {
    AM335X_GPTIMER2_BASE,  /* General purpose Timer 2 */
    AM335X_GPTIMER2_BASE,
    ROUND_UP (SZ_4K, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

    {
    AM335X_GPTIMER3_BASE,  /* General purpose Timer 3 */
    AM335X_GPTIMER3_BASE,
    ROUND_UP (SZ_4K, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

    {
    AM335X_GPTIMER4_BASE,  /* General purpose Timer 4 */
    AM335X_GPTIMER4_BASE,
    ROUND_UP (SZ_4K, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

    {
    AM335X_GPTIMER5_BASE,  /* General purpose Timer 5 */
    AM335X_GPTIMER5_BASE,
    ROUND_UP (SZ_4K, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID  | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

    {
    AM335X_GPTIMER6_BASE,  /* General purpose Timer 6 */
    AM335X_GPTIMER6_BASE,
    ROUND_UP (SZ_4K, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

    {
    AM335X_GPTIMER7_BASE,  /* General purpose Timer 7 */
    AM335X_GPTIMER7_BASE,
    ROUND_UP (SZ_4K, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

    /* gpio registers */

    {
    AM335X_GPIO0_BASE, /* General purpose I/O 0 */
    AM335X_GPIO0_BASE,
    ROUND_UP (SZ_8K, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

    {
    AM335X_GPIO1_BASE, /* General purpose I/O 1 */
    AM335X_GPIO1_BASE,
    ROUND_UP (SZ_8K, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

    {
    AM335X_GPIO2_BASE, /* General purpose I/O 2 */
    AM335X_GPIO2_BASE,
    ROUND_UP (SZ_8K, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

    {
    AM335X_GPIO3_BASE, /* General purpose I/O 3 */
    AM335X_GPIO3_BASE,
    ROUND_UP (SZ_8K, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

    {
    AM335X_LCDC_BASE,      /* virtual address */
    AM335X_LCDC_BASE,      /* physical address */
    ROUND_UP (AM335X_LCDC_SIZE, PAGE_SIZE), /* length, then initial state: */
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

#if defined(INCLUDE_I2C)
    {
    AM335X_I2C0_BASE, /* I2C TWL4030 connection */
    AM335X_I2C0_BASE,
    ROUND_UP (AM335X_I2C0_SIZE, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

    {
    AM335X_I2C1_BASE, /* I2C Exp. connector */
    AM335X_I2C1_BASE,
    ROUND_UP (AM335X_I2C1_SIZE, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

    {
    AM335X_I2C2_BASE, /* I2C Exp. connector */
    AM335X_I2C2_BASE,
    ROUND_UP (AM335X_I2C1_SIZE, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

#endif /* INCLUDE_I2C */

#ifdef INCLUDE_RTC
    {
    AM335X_RTC_BASE,
    AM335X_RTC_BASE,
    ROUND_UP (AM335X_RTC_SIZE, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },
#endif /* INCLUDE_RTC */

#ifdef INCLUDE_SPI
    {
    AM335X_SPI0_BASE,
    AM335X_SPI0_BASE,
    ROUND_UP (AM335X_SPI0_SIZE, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

    {
    AM335X_SPI1_BASE,
    AM335X_SPI1_BASE,
    ROUND_UP (AM335X_SPI1_SIZE, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

#endif /* INCLUDE_SPI */

#ifdef DRV_STORAGE_OMAP35XX_MMCHS
    {
    AM335X_MMC0_BASE,      /* MMC slot #1 */
    AM335X_MMC0_BASE,
    ROUND_UP (AM335X_MMC0_SIZE, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

    {
    AM335X_MMC1_BASE,      /* EMMC */
    AM335X_MMC1_BASE,
    ROUND_UP (AM335X_MMC1_SIZE, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },
#endif /* DRV_STORAGE_OMAP35XX_MMCHS */

    {
    AM335X_GPMC_BASE,      /* General Purpose Memory controller */
    AM335X_GPMC_BASE,
    ROUND_UP (AM335X_GPMC_SIZE, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },

#ifdef INCLUDE_END
    {
    AM335X_EMAC0_BASE,
    AM335X_EMAC0_BASE,
    ROUND_UP (AM335X_EMAC0_SIZE, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },
#endif

#ifdef DRV_TI_EDMA3
    {
    AM335X_EDMA_BASE,
    AM335X_EDMA_BASE,
    ROUND_UP (AM335X_EDMA_SIZE, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },
#endif

#ifdef INCLUDE_PRU_ICSS
    {
    AM335X_PRU_ICSS_BASE,
    AM335X_PRU_ICSS_BASE,
    ROUND_UP (AM335X_PRU_ICSS_SIZE, PAGE_SIZE),
    MMU_ATTR_VALID_MSK | MMU_ATTR_PROT_MSK | MMU_ATTR_DEVICE_SHARED_MSK,
    MMU_ATTR_VALID     | MMU_ATTR_SUP_RWX  | MMU_ATTR_DEVICE_SHARED
    },
#endif
    };
int sysPhysMemDescNumEnt = NELEMENTS (sysPhysMemDesc);

#endif /* defined(INCLUDE_MMU) */

/* globals */

UINT32 sysIntClear[MPU_INTERRUPT_NUM] = {0};

/* forward declarations */

IMPORT void (*_vxb_delayRtn) (void);
IMPORT void (*_vxb_msDelayRtn) (int);
IMPORT void (*_vxb_usDelayRtn) (int);

LOCAL unsigned int twps[4] = {
    0x1, 0x2, 0x4, 0x8
};

LOCAL unsigned int delaytimerbase = 0;

LOCAL UINT32 (* timerRead) (unsigned int base, unsigned int reg);
LOCAL void (* timerWrite)  (unsigned int base, unsigned int reg, unsigned int data);

LOCAL UINT32 am335xTimerSyncRead (unsigned int base, unsigned int reg);
LOCAL void am335xTimerSyncWrite (unsigned int base, unsigned int reg, unsigned int data);
LOCAL UINT32 am335xTimerRead (unsigned int base, unsigned int reg);
LOCAL void am335xTimerWrite (unsigned int base, unsigned int reg, unsigned int data);

void sysMsDelay (int);
void sysUsDelay (int);
void sysDelay   (void);

#ifdef INCLUDE_AUX_CLK
LOCAL void sysAuxClkInit (void);
#endif /* INCLUDE_AUX_CLK */

#ifdef INCLUDE_TIMESTAMP
LOCAL void sysTimestampInit (void);
#endif /* INCLUDE_TIMESTAMP */

LOCAL void sysGpTimersInit (void);

#ifdef DRV_VXBEND_TI_CPSW
LOCAL void sysEndInit  (void);
#endif /* DRV_VXBEND_TI_CPSW */

LOCAL void sysDelayTimerInit (void);

/* included source files */

#ifdef INCLUDE_VXBUS
#   include <hwif/vxbus/vxBus.h>
#   include "hwconf.c"
#   ifdef INCLUDE_SIO_UTILS
    IMPORT void sysSerialConnectAll (void);
#   endif /* INCLUDE_SIO_UTILS */
IMPORT void hardWareInterFaceInit (void);
#endif /* INCLUDE_VXBUS */

#include "sysBspCommon.c"
#include "am335xClock.c"
#include "sysGpio.c"

#if defined(INCLUDE_USB_MHDRC_HCD) || defined(INCLUDE_USB_MHDRC_TCD)
#   include "sysUsb.c"
#endif /* INCLUDE_USB_MHDRC_HCD && INCLUDE_USB_MHDRC_TCD */

#include "sysNvRam.c"

#if defined(INCLUDE_SPI)
#   include "ti81xxMcSpi.c"
#endif /* INCLUDE_SPI */

#include "sysNet.c"

#ifdef DRV_STORAGE_OMAP35XX_MMCHS
#   include "sysMmchsUtil.c"
#   include "sysEmmcUtil.c"
#endif /* DRV_STORAGE_OMAP35XX_MMCHS */

#ifdef INCLUDE_RTC
#   include "ti81xxRtc.c"
#endif /* INCLUDE_RTC */

#ifdef DRV_VXBEND_TI_CPSW
#   include "smscLan8710aPhy.c"
#endif

#ifdef DRV_I2C_AM38XX
#    include "tps65217c.c"
#endif

#ifdef DRV_I2C_EEPROM
#   include "eeprom.c"
#endif

#ifdef INCLUDE_PRU_ICSS
#   include "pru_icss.c"
#endif

/*******************************************************************************
*
* sysHwInit0 - perform early BSP-specific initialization
*
* This routine performs such BSP-specific initialization as is necessary before
* the architecture-independent cacheLibInit can be called. It is called
* from usrInit() before cacheLibInit(), before sysHwInit() and before BSS
* has been cleared.
*
* RETURNS: N/A
*/

void sysHwInit0 (void)
    {
    /*
     * Exception vectors are located at 0x20000, not 0x00000000.
     */

    excVecBaseSet (LOCAL_MEM_LOCAL_ADRS + 0x20000);

#ifdef INCLUDE_CACHE_SUPPORT
    /*
     * Install the appropriate cache library, no address translation
     * routines are required for this BSP, as the default memory map has
     * virtual and physical addresses the same.
     */

    cacheCortexA8LibInstall (mmuPhysToVirt, mmuVirtToPhys);

#endif /* INCLUDE_CACHE_SUPPORT */

#if defined(INCLUDE_MMU)

    /* Install the appropriate MMU library and translation routines */

    mmuCortexA8LibInstall (mmuPhysToVirt, mmuVirtToPhys);

#endif /* defined(INCLUDE_MMU) */
    }

/*******************************************************************************
*
* sysL3RamInit - enable L3 OCMC RAM clocks
*
* This routine enables L3 OCMC RAM clocks
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void sysL3RamInit (void)
    {
    omapClockEnable (&l3ram);
    }

#ifdef DRV_TI_EDMA3
/*******************************************************************************
*
* sysEdmaInit - enable edma3 clocks and configuration pad
*
* This routine enables edma3 clocks and configuration pad
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void sysEdmaInit (void)
    {
    omapClockEnable (&tpcc);
    omapClockEnable (&tptc0);
    omapClockEnable (&tptc1);
    omapClockEnable (&tptc2);
    }
#endif /* DRV_TI_EDMA3 */

#ifdef INCLUDE_PRU_ICSS
/*******************************************************************************
*
* sysPruIcssInit - enable pru-icss clocks and configuration pad
*
* This routine enables pru-icss clocks and configuration pad
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void sysPruIcssInit (void)
    {
    omapResetClear  (&pru_icss_reset);
    omapClockEnable (&pru_icss);
    }
#endif /* INCLUDE_PRU_ICSS */

#ifdef INCLUDE_I2C
/*******************************************************************************
*
* sysI2cInit - enable i2c module clocks and configuration pad
*
* This routine enables i2c module clocks and configuration pad
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void sysI2cInit (void)
    {
    omapClockEnable (&i2c0);
    omapClockEnable (&i2c1);
    omapClockEnable (&i2c2);

    omapPadConfig (i2c0_pads);
    omapPadConfig (i2c1_pads);
    }
#endif /* INCLUDE_I2C */

#ifdef INCLUDE_RTC
/*******************************************************************************
*
* sysRtcInit - enable rtc module clock
*
* This routine enables rtc module clock
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void sysRtcInit (void)
    {
    omapClockEnable (&rtc);
    ti81xxRtcInit ();
    }
#endif /* INCLUDE_RTC */

#ifdef INCLUDE_SPI
/*******************************************************************************
*
* sysSpiInit - enable spi module clock
*
* This routine enables spi module clock
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

void sysSpiInit (void)
    {
#   ifdef INCLUDE_SPI0
    omapClockEnable (&spi0);
    omapPadConfig (spi0_pads);
#   endif
#   ifdef INCLUDE_SPI1
    omapClockEnable (&spi1);
    omapPadConfig (spi1_pads);
#   endif
    }
#endif /* INCLUDE_SPI */


/*******************************************************************************
*
* sysHwInit - initialize the CPU board hardware
*
* This routine initializes various features of the hardware.
* Normally, it is called from usrInit() in usrConfig.c.
*
* NOTE: This routine should not be called directly by the user.
*
* RETURNS: N/A
*/

void sysHwInit (void)
    {

    sysGpioInit ();

    sysDelayTimerInit ();

    sysL3RamInit ();

#ifdef INCLUDE_AUX_CLK
    sysAuxClkInit ();
#endif /* INCLUDE_AUX_CLK */

#ifdef INCLUDE_TIMESTAMP
    sysTimestampInit ();
#endif /* INCLUDE_TIMESTAMP */

    sysGpTimersInit ();

#ifdef DRV_STORAGE_OMAP35XX_MMCHS
    sysMmchsInit ();
    sysEmmcInit ();
#endif /* DRV_STORAGE_OMAP35XX_MMCHS */

#ifdef DRV_VXBEND_TI_CPSW
    sysEndInit ();
#endif /* DRV_VXBEND_TI_CPSW */

#ifdef INCLUDE_I2C
    sysI2cInit ();
#endif /* INCLUDE_I2C */

#ifdef INCLUDE_RTC
    sysRtcInit ();
#endif /* INCLUDE_RTC */

#ifdef INCLUDE_SPI
    sysSpiInit ();
#endif /* INCLUDE_SPI */

#ifdef DRV_TI_EDMA3
    sysEdmaInit ();
#endif /* DRV_TI_EDMA3 */

#ifdef INCLUDE_PRU_ICSS
    sysPruIcssInit ();
#endif /* INCLUDE_PRU_ICSS */

    /* install the IRQ/SVC interrupt stack splitting routine */

#ifndef _ARCH_SUPPORTS_PROTECT_INTERRUPT_STACK
    _func_armIntStackSplit = sysIntStackSplit;
#endif /* !_ARCH_SUPPORTS_PROTECT_INTERRUPT_STACK */

#if defined(INCLUDE_USB_MHDRC_HCD) || defined(INCLUDE_USB_MHDRC_TCD)
    sysUsbInit ();
#endif /* INCLUDE_USB_MHDRC_HCD && INCLUDE_USB_MHDRC_TCD */

#ifdef INCLUDE_VXBUS
    hardWareInterFaceInit ();
#endif /* INCLUDE_VXBUS */

#ifdef FORCE_DEFAULT_BOOT_LINE
#warning forcing default bootline
    strncpy (sysBootLine, DEFAULT_BOOT_LINE, BOOT_LINE_SIZE);
#endif /* FORCE_DEFAULT_BOOT_LINE */
    }

/*******************************************************************************
*
* sysHwInit2 - additional system configuration and initialization
*
* This routine connects system interrupts and does any additional
* configuration necessary.  Note that this is called from
* sysClkConnect() in the timer driver.
*
* RETURNS: N/A
*/

void sysHwInit2 (void)
    {
    LOCAL BOOL initialized = FALSE;

#ifdef DRV_I2C_EEPROM
    int status;
    eeprom_header header;
#endif
    if (initialized)
        return;

#ifdef INCLUDE_VXBUS
    vxbDevInit ();
#endif /* INCLUDE_VXBUS */

#ifdef DRV_STORAGE_OMAP35XX_MMCHS
    sysCardPowerInit ();
    sysEmmcPowerInit ();
#endif

#if defined(INCLUDE_VXBUS) && defined(INCLUDE_SIO_UTILS)
    sysSerialConnectAll ();
#endif /* INCLUDE_VXBUS && INCLUDE_SIO_UTILS */

#if defined(DRV_I2C_EEPROM) && !defined(INCLUDE_BOOT_APP)
    status = eepromReadHeader(&header);
    if (status != ERROR) {
        if (eepromIsBone(&header)) {
            kprintf("Running on BeagleBone, ramping up to 720MHz...\n");
            omapMpuPllSet(720);
        } else if (eepromIsBoneBlack(&header)) {
            kprintf("Running on BeagleBone Black, ramping up to 1GHz...\n");
            omapMpuPllSet(1000);
        } else {
            kprintf("Running on unknown board!\n");
        }
    } else {
        kprintf("Couldn't read EEPROM\n");
    }
#endif

#ifdef INCLUDE_VXBUS
    taskSpawn ("tDevConn", 11, 0, 10000, vxbDevConnect, 0,1,2,3,4,5,6,7,8,9);
#endif /* INCLUDE_VXBUS */

#ifdef DRV_VXBEND_TI_CPSW
    smscLan8710aPhyInit();
#endif
    initialized = TRUE;
    }

/*******************************************************************************
*
* sysToMonitor - transfer control to the ROM monitor
*
* This routine transfers control to the ROM monitor.  It is usually called
* only by reboot() -- which services ^X -- and aborts at interrupt
* level.  However, in some circumstances, the user may wish to introduce a
* new <startType> to enable special boot ROM facilities.
*
* RETURNS: Does not return
*/

STATUS sysToMonitor
    (
    int startType   /* passed to ROM to tell it how to boot */
    )
    {
    FUNCPTR     pRom;
    UINT32 *    p;

    p = (UINT32 *)ROM_TEXT_ADRS;

#ifdef INCLUDE_TIMER_SYS
    sysClkDisable ();
#endif /* INCLUDE_TIMER_SYS */

    intIFLock ();

    /* disable individual interrupts in the interrupt controller */

    am335xOutLong (AM335X_MPU_INTC + OMAP_INTCPS_MIR(0), 0xffffffff);
    am335xOutLong (AM335X_MPU_INTC + OMAP_INTCPS_MIR(1), 0xffffffff);
    am335xOutLong (AM335X_MPU_INTC + OMAP_INTCPS_MIR(2), 0xffffffff);
    am335xOutLong (AM335X_MPU_INTC + OMAP_INTCPS_MIR(3), 0xffffffff);

    /*
     * Examine ROM - if it's a VxWorks boot ROM, jump to the warm boot entry
     * point; otherwise jump to the start of the ROM.
     * A VxWorks boot ROM begins
     *    MOV   R0,#BOOT_COLD
     *    B ...
     *    DCB   "Copyright"
     * We check the first and third words only. This could be tightened up
     * if required (see romInit.s).
     */

    if (p[0] == 0xE3A00002 && p[2] == 0x706F430A)
        pRom = (FUNCPTR)(ROM_TEXT_ADRS + 4); /* warm boot address */
    else
        pRom = (FUNCPTR)ROM_TEXT_ADRS;       /* start of ROM */

#ifdef  INCLUDE_MMU
    VM_ENABLE(FALSE);   /* disable the MMU, cache(s) and write-buffer */
    cacheFlush((CACHE_TYPE)DATA_CACHE, (void *)0, (size_t)ENTIRE_CACHE);
    cachePipeFlush();
#endif /* INCLUDE_MMU */

    (*pRom)(startType); /* jump to boot ROM */

    return OK;          /* in case we ever continue from ROM monitor */
    }


#ifdef DRV_VXBEND_TI_EMAC
/*******************************************************************************
*
* sysGetEmacClock - get emac clk.
*
* It is used by davinci emac  driver to set up mii clk.
*
* RETURNS: emac clk value
*/

UINT32 sysGetEmacClock (void)
    {
    return EMAC_CLK;
    }
#endif /* DRV_VXBEND_TI_EMAC */

/******************************************************************************
*
* sysGetChipVer - return chip version number
*
* This routine returns the chip version. It reads the device identification
* register and returns the hawkeye value. Revision number is ignored.
*
* RETURNS: chip version number
*
* ERRNO: N/A
*/

unsigned int sysGetChipVer (void)
    {
    return (am335xInLong(AM335X_DEV_ID) >> 12) & 0xffff;
    }

/******************************************************************************
*
* sysGetChipRev - return chip revision number
*
* This routine returns the chip revision. It reads the device identification
* register and returns the revision value
*
* RETURNS: chip version number
*
* ERRNO: N/A
*/

unsigned int sysGetChipRev (void)
    {
    return (am335xInLong(AM335X_DEV_ID) >> 28);
    }

/******************************************************************************
*
* sysChipIsTi335x - check if chip is TI AM335x
*
* This routine checks whether chip is TI AM335x
*
* RETURNS: 1 if chip is TI AM335x, otherwise 0
*
* ERRNO: N/A
*/

unsigned int sysChipIsTi335x (void)
    {
    return sysGetChipVer() == 0xb944;
    }

/******************************************************************************
*
* sysTimerIsDM81xx
*
* This routine returns 1, to signify a DM81xx-compatible timer
*
* RETURNS: 1
*
* ERRNO: N/A
*/

unsigned int sysTimerIsDM81xx (void)
    {
    return 1;
    }

/******************************************************************************
*
* sysTimerIsOMAP35xx
*
* This routine returns 0, to signify a OMAP35xx-compatible timer
*
* RETURNS: 0
*
* ERRNO: N/A
*/

unsigned int sysTimerIsOMAP35xx (void)
    {
    return 0;
    }

/*******************************************************************************
*
* sysUsDelay - delay the specified amount of time (in microseconds)
*
* This routine delays for approximately one microsecond. The accuracy of the
* delay increases as the requested delay increases due to a certain amount of
* overhead.
*
* NOTE:  This routine will not relinquish the CPU, as it is meant to perform a
* busy loop delay
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

void sysUsDelay
    (
    int us
    )
    {
    /*
     * the clock source is selected to 24MHz, so
     * every hardware clock tick is 1/24000000
     * seconds, which is ~41.6666ns
     */

#define SYS_DELAY_TIMER_FREQ 4166666666UL
#define SYS_DELAY_SCALE      100000000ULL
    unsigned int ticks = (us * 1000ULL * SYS_DELAY_SCALE) / SYS_DELAY_TIMER_FREQ;
    unsigned int delta = 0;
    unsigned int end , start;

    start = timerRead (delaytimerbase, TCRR);
    while (delta < ticks)
        {
        end = timerRead (delaytimerbase, TCRR);
        delta += (end - start);
        start = end;
        }
    }

/*******************************************************************************
*
* sysMsDelay - delay the specified amount of time (in milliseconds)
*
* This routine delays for approximately one millisecond. It just calls
* sysUsDelay to delay.
*
* RETURNS: N/A
*/

void sysMsDelay
    (
    int delay        /* length of time in ms to delay */
    )
    {
    sysUsDelay (1000 * delay);
    }

/*******************************************************************************
*
* sysDelay - fixed 1ms delay.
*
* This routine consumes approximately 1ms of time. It just calls sysMsDelay.
*
* RETURNS: N/A
*/

void sysDelay (void)
    {
    sysMsDelay (1);
    }

#ifdef DRV_VXBEND_TI_CPSW

/******************************************************************************
*
* sysEndInit - initialize END PAD control register
*
* This routine initializes END PAD control register.
*
* RETURNS: N/A
*
* ERRNO: N/A
*
*/

LOCAL void sysEndInit(void)
    {

    /* enable clock first */
    omapClockEnable (&cpgmac0);
    omapClockEnableNoWait (&cpsw);

    /* set emac to gmii mode */
    am335xOutLong (MAC_MII_SEL, GMII_MODE_ENABLE);

    }
#endif /* DRV_VXBEND_TI_CPSW */

#ifdef INCLUDE_AUX_CLK
/******************************************************************************
*
* sysAuxClkInit - initialize AUX clock
*
* This routine initializes AUX clock
*
* RETURNS: N/A
*
* ERRNO: N/A
*
*/

LOCAL void sysAuxClkInit(void)
    {
    am335xOutLong (AM335X_CM_TIMER4_CLKSEL, 0x1);
    omapClockEnable (&timer4);
    }

#endif

#ifdef INCLUDE_TIMESTAMP
/******************************************************************************
*
* sysTimestampInit - initialize Timestamp clock
*
* This routine initializes Timestamp clock
*
* RETURNS: N/A
*
* ERRNO: N/A
*
*/

LOCAL void sysTimestampInit(void)
    {
    am335xOutLong (AM335X_CM_TIMER3_CLKSEL, 0x1);
    omapClockEnable (&timer3);
    }

#endif

/******************************************************************************
*
* sysGpTimersInit - initialize unused GP Timers
*
* This routine initializes the remaining available GP timers
*
* RETURNS: N/A
*
* ERRNO: N/A
*
*/

LOCAL void sysGpTimersInit(void)
    {
    am335xOutLong (AM335X_CM_TIMER5_CLKSEL, 0x1);
    omapClockEnable (&timer5);
    am335xOutLong (AM335X_GPTIMER5_BASE + TIOCP_CFG, 0x1);

    am335xOutLong (AM335X_CM_TIMER6_CLKSEL, 0x1);
    omapClockEnable (&timer6);
    am335xOutLong (AM335X_GPTIMER6_BASE + TIOCP_CFG, 0x1);
    }

/******************************************************************************
*
* am335xTimerSyncRead - read register value from timer device
*
* This routine reads register value from timer device. This routine
* uses posted read method.
*
* RETURNS: register value read
*
* ERRNO: N/A
*
*/

LOCAL UINT32 am335xTimerSyncRead
    (
    unsigned int base,  /* delay timer base address */
    unsigned int reg    /* timer register to read from */
    )
    {
    unsigned int val;

    do
        {
        val = am335xInLong (base + TWPS);

        /*
         * poll for ready, the array twps[] determins
         * which bit to poll based on the input
         * register offset
         */

        } while (val & twps [(reg - 0x38) >> 2]);

    return am335xInLong (base + reg);
    }

/******************************************************************************
*
* am335xTimerSyncWrite - write register value to timer device
*
* This routine writes register value to timer device. This routine
* uses posted write method.
*
* RETURNS: N/A
*
* ERRNO: N/A
*
*/

LOCAL void am335xTimerSyncWrite
    (
    unsigned int base, /* delay timer base address */
    unsigned int reg,  /* timer register to write to*/
    unsigned int data  /* data to be written */
    )
    {
    unsigned int val;

    am335xOutLong (base + reg, data);

    do
        {
        val = am335xInLong (base + TWPS);

        /*
         * poll for ready, the array twps[] determins
         * which bit to poll based on the input
         * register offset
         */

        } while (val & twps [(reg - 0x38) >> 2]);
    }

/******************************************************************************
*
* am335xTimerRead - read register value from timer device
*
* This routine reads register value from timer device. This routine
* uses non-posted read method.
*
* RETURNS: register value read
*
* ERRNO: N/A
*
*/

LOCAL UINT32 am335xTimerRead
    (
    unsigned int base,
    unsigned int reg
    )
    {
    return am335xInLong (base + reg);
    }

/******************************************************************************
*
* am335xTimerWrite - write register value to timer device
*
* This routine writes register value to timer device. This routine
* uses non-posted write method.
*
* RETURNS: N/A
*
* ERRNO: N/A
*
*/

LOCAL void am335xTimerWrite
    (
    unsigned int base,
    unsigned int reg,
    unsigned int data
    )
    {
    am335xOutLong (base + reg, data);
    }

/******************************************************************************
*
* sysDelayTimerInit - initialize timer for sysUsDelay
*
* This routine initializes timer for sysUsDelay. On this BSP, timer7
* is selected to be the timer for sysUsDelay()
*
* RETURNS: N/A
*
* ERRNO: N/A
*
*/

LOCAL void sysDelayTimerInit (void)
    {
    unsigned int val;
    int timeout = 0;

    delaytimerbase = AM335X_GPTIMER7_BASE;
    VX_MEM_BARRIER_W();

    omapClockEnable (&timer7);

    /* set timer7 to use CLK_M_OSC clock which is 24MHz */

    am335xOutLong (AM335X_CM_TIMER7_CLKSEL, 0x1);

    am335xOutLong (delaytimerbase + TIOCP_CFG, 0x1);
    do
        {
        val = am335xInLong (delaytimerbase + TIOCP_CFG);
        if (timeout++ > 10000)
            break;
        } while (val & 0x1);

    am335xOutLong (delaytimerbase + IRQSTATUS, 0x7);
    am335xOutLong (delaytimerbase + IRQENABLE_CLR, 0x7);

    val = am335xInLong (delaytimerbase + TSICR);
    if (val & 0x2)
        {
        timerRead = am335xTimerSyncRead;
        timerWrite = am335xTimerSyncWrite;
        }
    else
        {
        timerRead = am335xTimerRead;
        timerWrite = am335xTimerWrite;
        }

    timerWrite (delaytimerbase, TLDR, 0x0);
    timerWrite (delaytimerbase, TCRR, 0x0);
    timerWrite (delaytimerbase, TCLR, 0x3);

    _vxb_delayRtn   = sysDelay;
    _vxb_msDelayRtn = sysMsDelay;
    _vxb_usDelayRtn = sysUsDelay;
    }

