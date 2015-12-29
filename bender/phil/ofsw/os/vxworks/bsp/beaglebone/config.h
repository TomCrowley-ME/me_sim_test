/* config.h - TI AM335X configuration header */

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
01d,22nov12,y_c  add memory map for LCDC. (WIND00382478)
01c,24aug12,my_  add spi support
01b,23aug12,my_  add rtc support
01a,08may12,my_  created from ti_dm81xx_evm BSP.
*/

/*
DESCRIPTION
This module contains the configuration parameters for the beaglebone BSP.
*/

#ifndef __INCconfigh
#define __INCconfigh

#ifdef __cplusplus
extern "C" {
#endif

/* BSP version/revision identification, before configAll.h */

#define BSP_VERSION     "6.9"
#define BSP_REV         "/2"    /* 0 for first revision */

#include <configAll.h>
#include "beaglebone.h"

/* vxbus support */

#define INCLUDE_VXBUS
#define INCLUDE_HWMEM_ALLOC
#define INCLUDE_PLB_BUS
#define INCLUDE_PARAM_SYS
#define INCLUDE_MII_BUS
#define INCLUDE_GENERICPHY
#define INCLUDE_SIO_UTILS
#define INCLUDE_ISR_DEFER
#define INCLUDE_TIMER_SYS
#define INCLUDE_VXB_CMDLINE
#define HWMEM_POOL_SIZE 50000
#define DRV_SIO_NS16550
#define DRV_TIMER_OMAP35XX
#define DRV_INTCTLR_OMAP35XX

/* SYS_MODEL define */

#define SYS_MODEL "TI_AM335X - ARMv7 (ARM)"

/* Support network devices */

#define INCLUDE_NETWORK
#define DEFAULT_BOOT_LINE \
      "cpsw(0,0)host:vxWorks " \
      "h=192.168.1.89 e=192.168.1.6:ffffff00 u=anonymous tn=simbone"

/*
 * Boot ROM is an image written into Flash. Part of the Flash can be
 * reserved for boot parameters etc. (see the Flash section below).
 *
 * The following parameters are defined here and in the Makefile.
 * They must be kept synchronized; effectively config.h depends on Makefile.
 * Any changes made here must be made in the Makefile and vice versa.
 *
 * ROM_BASE_ADRS is the base of the Flash ROM/EPROM.
 * ROM_TEXT_ADRS is the entry point of the VxWorks image
 * ROM_SIZE is the size of the part of the Flash ROM/EPROM allocated to
 *      the VxWorks image (block size - size of headers)
 *
 * The values are given as literals here to make it easier to ensure
 * that they are the same as those in the Makefile.
 */

#undef  ROM_SIZE                                  /* Avoid warning */
#define ROM_SIZE                (0x00400000)      /* size of ROM holding VxWorks */

/* Memory configuration */

#undef  LOCAL_MEM_AUTOSIZE                        /* run-time memory sizing */
#define USER_RESERVED_MEM       (0x0)             /* see sysMemTop() */

#define AM335X_MEM_SIZE         (SZ_256M)     /* SZ_256M */
#define LOCAL_MEM_LOCAL_ADRS    (0x80000000)
#define LOCAL_MEM_BUS_ADRS      (LOCAL_MEM_LOCAL_ADRS)
#define LOCAL_MEM_SIZE          (AM335X_MEM_SIZE)

#define LOCAL_MEM_END_ADRS      (LOCAL_MEM_LOCAL_ADRS + LOCAL_MEM_SIZE)

#define ROM_BASE_ADRS           (0x00020000)      /* the base address of Flash module */
#define ROM_TEXT_ADRS           (0x00020000) /* code start addr in ROM */

/*
 * BOOTROM_FAST_BOOT is defined to support "fast boot". With "fast boot
 * technic", VxWorks bootrom can speed up boot time.
 *
 * This feature is enabled by default.
 */

#define BOOTROM_FAST_BOOT

#ifdef  BOOTROM_FAST_BOOT

#   define MMU_SECTION_DESC_AP_READ_WRITE            0xC00
#   define MMU_SECTION_DESC_SECTION_INDICATE         0x2

#   define MMU_SECTION_DESC_DEFAULT_VALUE  \
                              (MMU_SECTION_DESC_AP_READ_WRITE | \
                              MMU_SECTION_DESC_SECTION_INDICATE)

#   define MMU_SECTION_DESC_CACHE_WRITE_THROUGH      0x8
#   define MMU_SECTION_DESC_CACHE_WRITE_BACK         0xC
#   define MMU_SECTION_DESC_CACHE_MODE      \
                           MMU_SECTION_DESC_CACHE_WRITE_BACK

/*
 * To support bootrom fast boot, we need a reserved memory to store the MMU
 * descriptors. And this memory can't be clear before sysInit(), so put it
 * to the bottom of STACK_SAVE area and add STACK_SAVE size to save the descriptor.
 */

#   undef STACK_SAVE
#   define STACK_SAVE    (0x80000)

/*
 * The entire DRAM memory should be mapped by MMU. So LOCAL_MEM_SIZE_TOTAL is
 * defined to represent the real size of DRAM memory.
 */

#   define LOCAL_MEM_SIZE_TOTAL     (LOCAL_MEM_SIZE + ROM_SIZE)

/* The base address to store MMU descriptor */

#   define SYS_MMU_PAGE_TABLE_BASE  (STACK_ADRS - STACK_SAVE)

/*
 * To support fast boot, we need implement BSP_BOOT_CACHE_SYNC which is used
 * in romStart()
 */

#   define BSP_BOOT_CACHE_SYNC         sysBspBootCacheSync()
#   define BSP_BOOT_CACHE_SYNC_POST    sysBspBootCacheSyncPost()

#endif /* BOOTROM_FAST_BOOT */


/* Minimum rate at which the system clock can run */

#define SYS_CLK_RATE_MIN (10)

/* 1000 ticks, Maximum rate at which the system clock can run */

#define SYS_CLK_RATE_MAX (8000)

/* Minimum rate at which the auxiliary clock can run */

#define AUX_CLK_RATE_MIN (10)

/* 1000 ticks, Maximum rate at which the auxiliary clock can run */

#define AUX_CLK_RATE_MAX (8000)

/*
 * Flash/NVRAM memory configuration
 *
 * A block of the Flash memory (FLASH_SIZE bytes at FLASH_ADRS) is
 * reserved for non-volatile storage of data.
 *
 */


#define NV_MAC_ADRS_OFFSET   (0)

/* ARM VFP Support */

#define INCLUDE_VFP

/* Serial port configuration */

#define N_SIO_CHANNELS   1

#undef  NUM_TTY
#define NUM_TTY             N_SIO_CHANNELS

/* Console baud rate reconfiguration */

#undef  CONSOLE_BAUD_RATE
#define CONSOLE_BAUD_RATE   115200     /* Reconfigure default baud rate */

/*
 * We use the generic architecture libraries, with caches/MMUs present. A
 * call to sysHwInit0() is needed from within usrInit before
 * cacheLibInit() is called.
 */

#define INCLUDE_SYS_HW_INIT_0

#ifdef INCLUDE_SYS_HW_INIT_0
#   ifndef _ASMLANGUAGE
    IMPORT void sysHwInit0 (void);
#   endif
#   define SYS_HW_INIT_0() sysHwInit0 ()
#endif

/*
 * Cache/MMU configuration
 *
 * Note that when MMU is enabled, cache modes are controlled by
 * the MMU table entries in sysPhysMemDesc[], not the cache mode
 * macros defined here.
 */

#undef  USER_I_CACHE_MODE
#define USER_I_CACHE_MODE        CACHE_COPYBACK

#undef  USER_D_CACHE_MODE
#define USER_D_CACHE_MODE        CACHE_COPYBACK

#ifdef BOOTAPP
#   undef INCLUDE_MMU_BASIC
#   undef INCLUDE_MMU_FULL
#   undef INCLUDE_MMU_GLOBAL_MAP
#   undef INCLUDE_EDR_SYSDBG_FLAG
#   undef INCLUDE_CACHE_SUPPORT
/*
 * Because of the restriction of hardware, address 0 is not mapped by system.
 * Therefore, MMU must be enabled and address 0 should also be mapped to boot
 * bootrom or vxWorks image.
 *
 * INCLUDE_BOOT_MMU_BASIC is defined to enable MMU in bootrom.
 */

#   define INCLUDE_BOOT_MMU_BASIC
#else /* BOOTAPP */
#   define INCLUDE_MMU_BASIC
#   define INCLUDE_MMU_FULL
#   define INCLUDE_CACHE_SUPPORT
#endif /* BOOTAPP */

#if defined(INCLUDE_MMU_BASIC) || defined(INCLUDE_MMU_FULL)
#   define INCLUDE_MMU
#endif /* INCLUDE_MMU_BASIC || INCLUDE_MMU_FULL */

/* Enhanced Network Driver (END) Support */

#define INCLUDE_END

#ifdef  INCLUDE_END
#   define DRV_VXBEND_TI_CPSW
#   define MAC_ADRS_LEN 6
#   define MAX_MAC_ADRS 2
#   define MAX_MAC_DEVS 2
#   define WR_ENET0        0x00  /* WR specific portion of MAC (MSB->LSB) */
#   define WR_ENET1        0x50
#   define WR_ENET2        0xC2
#   define CUST_ENET3      0x7E  /* Customer portion of MAC address */
#   define CUST_ENET4      0xCC
#   define CUST_ENET5      0xA0

/* Default MAC address */

#   define ENET_DEFAULT0        WR_ENET0
#   define ENET_DEFAULT1        WR_ENET1
#   define ENET_DEFAULT2        WR_ENET2

#   undef  ETHERNET_MAC_HANDLER
#   undef  ENET_MAC_DEBUG                /* can be defined for debugging "M" */

#   ifdef ETHERNET_MAC_HANDLER
#       ifdef BOOTAPP
#           define INCLUDE_BOOT_ETH_MAC_HANDLER
#       endif
#   endif /* ETHERNET_MAC_HANDLER */

#endif /* INCLUDE_END */

/*
 * interrupt mode - interrupts can be in either preemptive or non-preemptive
 * mode. For preemptive mode, change INT_MODE to INT_PREEMPT_MODEL
 */

#define INT_MODE    INT_NON_PREEMPT_MODEL

/*
 * miscellaneous definitions
 * Note: ISR_STACK_SIZE is defined here rather than in ../all/configAll.h
 * (as is more usual) because the stack size depends on the interrupt
 * structure of the BSP.
 */

#define ISR_STACK_SIZE  0x2000  /* size of ISR stack, in bytes */

#undef  DRV_STORAGE_OMAP35XX_MMCHS
#ifdef  DRV_STORAGE_OMAP35XX_MMCHS
#   define DRV_TI_EDMA3
#   define INCLUDE_VXB_LEGACY_INTERRUPTS
#endif

#undef INCLUDE_AM335X_USB
#ifdef INCLUDE_AM335X_USB
#   define INCLUDE_USB_INIT
#   define INCLUDE_USB
#   define INCLUDE_USB_MHDRC_HCD_INIT
#   define INCLUDE_USB_MHDRC_HCD
#   define INCLUDE_USB_MS_BULKONLY_INIT
#   define INCLUDE_USB_MS_BULKONLY
#   define INCLUDE_USB_TGT
#   define INCLUDE_USB_MHDRC_TCD_INIT
#   define INCLUDE_USB_MHDRC_TCD
#   define INCLUDE_USB_TGT_FUNC_INIT
#   define INCLUDE_USBTGT_MSC_INIT
#   define INCLUDE_USBTGT_MSC
#   define INCLUDE_USBTGT_MSC_1
#endif /* INCLUDE_AM335X_USB */

/* I2C */

#define INCLUDE_I2C
#ifdef  INCLUDE_I2C
#   define DRV_I2C_AM38XX
#   define INCLUDE_I2C_BUS
#   define DRV_I2C_EEPROM
#   define INCLUDE_EEPROMDRV
#   define DRV_I2C_GENERIC_DEV
#endif /* INCLUDE_I2C */

/* SPI */
#define INCLUDE_SPI1
#if  defined(INCLUDE_SPI0) || defined(INCLUDE_SPI1)
#    define INCLUDE_SPI

#   define NR_SPIS              (2)
#   define OMAP_SPI_0           (AM335X_SPI0_BASE + 0x100)
#   define OMAP_SPI_1           (AM335X_SPI1_BASE + 0x100)
#endif /* INCLUDE_SPI0 || INCLUDE_SPI1 */

/* RTC support */

#ifdef  INCLUDE_RTC
#   define RTC_BASE AM335X_RTC_BASE
#endif /* INCLUDE_RTC */

#ifdef __cplusplus
}
#endif
#endif /* __INCconfigh */

#if defined(PRJ_BUILD)
#   include "prjParams.h"
#endif
