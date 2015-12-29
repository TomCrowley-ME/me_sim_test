/* Copyright 2006 Gaisler Research */
/*
  modification history
  --------------------
  001,05sep06,eiselekd  initial addition (Konrad Eisele (konrad@gaisler.com))
*/

/*
This file contains the configuration parameters for the BSP.
*/
#ifndef __INCconfigh
#define __INCconfigh

#include "sysFlash.h"

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */


#define SPARCLEON_MMU 1

/*                                                                  */
/* BSP version/revision identification, should be placed before the */
/* the #include "configAll.h"                                       */

#define BSP_VER_1_1   1
#define BSP_VERSION   "1.0.8"
#define BSP_REV       "/1"

/* Now include the global configuration information.                */

#include "configAll.h"

#define SYS_MODEL   "MoonEx CAB v1"

#define MAX_CPU_ID           0

/*********************************************************************
 * Memory configuration:
 * The constants ROM_TEXT_ADRS, ROM_SIZE, and RAM_HIGH_ADRS are defined
 * in config.h and Makefile. All definitions for these constants must be
 * identical.  (can be fine-tuned for various configurations)
 *
 */

#define ROM_SIZE             0x01000000        /* 16M ROM space               */
#define ROM_BASE_ADRS        0x00000000        /* base address of ROM        */
#define ROM_TEXT_ADRS        ROM_BASE_ADRS /*+ 0x100*/
#define RAM_LOW_ADRS         0x40003000        /* RAM address for sys image  */
#define RAM_HIGH_ADRS        0x48003000        /* RAM address for ROM boot, where romdecompress data is copied to, choose middle of ram */
#define LOCAL_MEM_LOCAL_ADRS 0x40000000        /* Base of RAM                */
#define LOCAL_MEM_SIZE       0x0ffff000        /* 256 Mbyte memory           */
#define USER_RESERVED_MEM    0x00001000        /* user reserved memory size  */

#define ROM_WARM_ADRS        (ROM_TEXT_ADRS+0x14)  /* warm reboot entry */

#if defined(BOOTINIT_COPY) /* sparc: load to 0x60001000 */
# ifndef RAM_DST_ADRS         /* default uncompress dest. */
#  define RAM_DST_ADRS         RAM_LOW_ADRS
# endif  /* RAM_DST_ADRS */
#else
# ifndef RAM_DST_ADRS         /* default uncompress dest. */
#  define RAM_DST_ADRS         RAM_HIGH_ADRS
# endif  /* RAM_DST_ADRS */
#endif  /* RAM_DST_ADRS */


#define INCLUDE_FLASH

#define FLASH_BASE_ADRS         ROM_BASE_ADRS
#define FLASH_RESERVE_FOR_BOOTIMAGE 0x200000
#define FLASH_SIZE              ROM_SIZE    /* Flash memory size */
#define NV_RAM_SIZE         FLASH_SUBSECTOR_SIZE
#define NVRAM_START_ADDR        (FLASH_BASE_ADRS + FLASH_SIZE - FLASH_SUBSECTOR_SIZE)

/*#define SAVE_NVRAM_REGION*/

/* Serial port configuration */
#define INCLUDE_TTY_DEV      /* Include TTY Dev for those that use command line building */
#undef  NUM_TTY
#define NUM_TTY          2
#undef CONSOLE_BAUD_RATE
#define CONSOLE_BAUD_RATE 115200

#undef  CONSOLE_TTY
#define CONSOLE_TTY    0  /* uart 0 */

/* Timer configuration */
#define  INCLUDE_AUX_CLK
#define  INCLUDE_TIMESTAMP

/* Cache configuration  */
#define INCLUDE_CACHE_SUPPORT
#define USER_I_CACHE_ENABLE
#undef  USER_I_CACHE_MODE
#define USER_I_CACHE_MODE    CACHE_WRITETHROUGH /* select COPYBACK or WRITETHROUGH */

#define USER_D_CACHE_ENABLE
#undef  USER_D_CACHE_MODE
#define USER_D_CACHE_MODE    CACHE_WRITETHROUGH /* select COPYBACK or WRITETHROUGH */

/* MMU configuration */

#define INCLUDE_MMU_BASIC
/* #undef  INCLUDE_MMU_FULL */
/* #define USER_I_MMU_ENABLE */
/* #define USER_D_MMU_ENABLE */

/* real time process support */
/*
#define INCLUDE_RTP
#define INCLUDE_RTP_APPL_BOOTLINE
*/

/* posix support */
/*
#define INCLUDE_POSIX_AIO
#define INCLUDE_POSIX_AIO_SYSDRV
#define INCLUDE_POSIX_CLOCKS
#define INCLUDE_POSIX_FTRUNC
#define INCLUDE_POSIX_MEM
#define INCLUDE_POSIX_MQ
#define INCLUDE_POSIX_PTHREADS
#define INCLUDE_POSIX_SCHED
#define INCLUDE_POSIX_SEM
#define INCLUDE_POSIX_SIGNALS
#define INCLUDE_POSIX_TIMERS
#define INCLUDE_POSIX_DIRLIB
*/

/*#define VXB_LEGACY_ACCESS*/

/* IP Address configuration */

/*********************************************************************
 * IP Address configuration
 */
#define IP_ADRS_LEN     24  /* bytes in IP address */
#define MAX_IP_ADRS     2   /* IP addresses to save in flash */

/* MAC Address configuration */
#define MAC_ADRS_LEN    6   /* 6 bytes in MAC address */
#define MAX_MAC_ADRS    2   /* MAC addresses to save in flash */

#define WR_ENET0        0x00  /* WR specific portion of MAC (MSB->LSB) */
#define WR_ENET1        0xA0
#define WR_ENET2        0x1E

#define CUST_ENET3_0    0xA0  /* Customer portion of MAC address */
#define CUST_ENET3_1    0xA1
#define CUST_ENET4      0xAA
#define CUST_ENET5      0xA0

/*
 * The Ethernet hardware address that is used with greth or lnc is
 *
 *       00:A0:1E:nn:nn:nn
 *
 * where the first three bytes are defined below, and last three bytes are
 * user specified.
 */

/*              This is byte swapped (little endian issue)
 *                                    ___ Alignment pad
 *                                   |
 *                                  \|/
 *                                   V
 */
#define WR_ENET0          0x00  /* WR specific portion of MAC (MSB->LSB) */
#define WR_ENET1          0xA0
#define WR_ENET2          0x1E
#define ENET_DEFAULT         0x1EA00000 /* WR fixed MAC addr; see WR_ENETx */
#define ENET_DEFAULT0 WR_ENET0
#define ENET_DEFAULT1 WR_ENET1
#define ENET_DEFAULT2 WR_ENET2

#define ETHERNET_MAC_HANDLER   /* enable 'M' command */
#define MAX_MAC_DEVS         2 /* two network devices (greth, lnc) */

#undef  NV_BOOT_OFFSET       /* room for IP and MAC addresses  */

/* Define offsets back from boot line for sysNvRamGet();  */

#define NV_BOOT_OFFSET       ((IP_ADRS_LEN * MAX_IP_ADRS) + (MAC_ADRS_LEN * MAX_MAC_ADRS))
#define NV_IP_ADRS_OFFSET    0
#define NV_MAC_ADRS_OFFSET   (IP_ADRS_LEN * MAX_IP_ADRS)

/* Network driver configuration */
#define INCLUDE_END       /* Enhanced Network Driver (see configNet.h) */

/* Enhanced Network Driver Types */
#  define MAX_SCC_CHANNELS  1       /* max SCC number for Ethernet channels */
/* Specify Boot Device from Network Driver Types above */
#  define BOOT_DEVICE          SCC_FCC_END

#define DRV_GRLIB_END
/*#define INCLUDE_LAN91C111_END*/
#undef  INCLUDE_MOTFCCEND
#undef  INCLUDE_MOTSCCEND
#undef  INCLUDE_FEI_END
#define DRV_GRLIB_GRETH
/*#define BOOT_DEV_NAME        "lnc"*/
#define BOOT_DEV_NAME        "greth"

/* start - enable this section to use libmkprom */
/*
#undef  INCLUDE_BOOTCFG_CODE
#define INCLUDE_BOOTCFG_LIBMKPROM
#define BOOTCFG_LIBMKPROM_MKPROM_DIR "/opt/mkprom3"
#define BOOTCFG_LIBMKPROM_MKPROM_CONFIG "/opt/mkprom3/board-configs/tsim-generic/"
*/
/* end - enable this section to use libmkprom */

#define BOOTCFG_DEFAULT      0
#define BOOTCFG_USER         1                 /* Custom User provided config */

#define BOOTCFG_CID0         1000
#define BOOTCFG_CID1         (BOOTCFG_CID0+1)
#define BOOTCFG_CID2         (BOOTCFG_CID0+2)
#define BOOTCFG_CID3         (BOOTCFG_CID0+3)
#define BOOTCFG_CID4         (BOOTCFG_CID0+4)
#define BOOTCFG_CID5         (BOOTCFG_CID0+5)
#define BOOTCFG_CID6         (BOOTCFG_CID0+6)
#define BOOTCFG_CID7         (BOOTCFG_CID0+7)
#define BOOTCFG_CID8         (BOOTCFG_CID0+8)
#define BOOTCFG_CID9         (BOOTCFG_CID0+9)
#define BOOTCFG_CID10        (BOOTCFG_CID0+10)

/* Select boot loader configuration */
#define BOOTCFG_SELECT BOOTCFG_DEFAULT

#if (BOOTCFG_SELECT == BOOTCFG_USER)
#include "bootcfg_user.h"
#elif (BOOTCFG_SELECT == BOOTCFG_CID7)
#include "bootcfg_cid7.h"
#else
#include "bootcfg_def.h"
#endif

/* add on-chip drivers */

/* default doesn't include PCI library support */
#undef INCLUDE_PCI

/* Map PCI space to CPU RAM/SDRAM. Normally we skip the non-prefetchable
 * area, instead we use two prefetchable areas to map both RAM(MEM) and
 * SDRAM/DDR/DDR2 (MEM2).
 *
 * non-prefetchable area is for PCI targets to access AMBA cores close
 * to CPU.
 */
#define PCI_SLV_MEM_LOCAL      LOCAL_MEM_LOCAL_ADRS   /* RAM address on AMBA */
#define PCI_SLV_MEM_BUS        LOCAL_MEM_LOCAL_ADRS   /* PCI address to map amba address PCI_SLV_MEM_LOCAL to*/
#define PCI_SLV_MEM_SIZE       NOTUSED     /* Note: Hardcoded 16Mb page for AT697 */

#define PCI_SLV_MEM2_LOCAL     NOTUSED     /* SDRAM address on AMBA */
#define PCI_SLV_MEM2_BUS       NOTUSED     /* PCI address translated to AMBA SDRAM */
#define PCI_SLV_MEM2_SIZE      NOTUSED     /* Note: Hardcoded 16Mb page for AT697 */

/* UNUSED (non-prefetchable) */
#define PCI_SLV_MEMIO_LOCAL    NOTUSED     /* Cores address on AMBA */
#define PCI_SLV_MEMIO_BUS      NOTUSED     /* PCI address translated to AMBA Cores */
#define PCI_SLV_MEMIO_SIZE     NOTUSED     /* Note: Hardcoded 16Mb page for AT697 */

/* CPU addresses will be used to map PCI devices into the CPU address space.
 * The VxWorks PCI layer uses these addresses when allocating memory for
 * the BARs found during PCI board scanning.
 *
 * Increase/Decrease the CPU address space taken by PCI devices depending
 * on what devices and how many are available in the system. The BAR sizes
 * can be viewed by enabling debug output in respective PCI host controller
 * driver.
 *
 * Regions may not overlap.
 */
#define PCI_MSTR_MEM_BUS      0
#define PCI_MSTR_MEM_END      0
#define PCI_MSTR_MEM_SIZE     (PCI_MSTR_MEM_END - PCI_MSTR_MEM_BUS)

#define PCI_MSTR_MEMIO_BUS    0xC0000000
#define PCI_MSTR_MEMIO_END    0xFFF00000
#define PCI_MSTR_MEMIO_SIZE   (PCI_MSTR_MEMIO_END - PCI_MSTR_MEMIO_BUS)

#define PCI_MSTR_IO_BUS       0xFFF00000
#define PCI_MSTR_IO_END       0xFFF10000
#define PCI_MSTR_IO_SIZE      (PCI_MSTR_IO_END - PCI_MSTR_IO_BUS)

/* GRPCI can enable/disable byte twisting */
#define GRPCI_ENABLE_BYTETWISTING TRUE

#define GRPCI_GPIO_INTERRUPT TRUE
#define PCIF_GPIO_INTERRUPT FALSE

/* Default to shared IRQ */
#define USE_PCI_SHARED_IRQ FALSE

#ifdef  INCLUDE_PCI
#define INCLUDE_PCI_AUTOCONF
#undef INCLUDE_PCI_CFGSHOW

/* PCI IRQ Setup, two variants:
 *
 * 1. Shared PCI IRQ. INTA,INTB,INTC,INTD are connected to one system IRQ
 *    specify system IRQ with PCI_SHARED_IRQ
 *
 * 2. One system IRQ for every PCI IRQ, specify system IRQ numbers for all
 *    PCI IRQs used. Set unconnected PCI IRQs to 0xff.
 *
 */
#if (USE_PCI_SHARED_IRQ == TRUE)

/* PCI IRQ connected to system IRQ number: */
#define PCI_SHARED_IRQ 5    /* I/O1 LEON2 configuration) */
/* Assume all IRQs shared using the same IRQ */
#define PCI_INTA_IRQ PCI_SHARED_IRQ
#define PCI_INTB_IRQ PCI_SHARED_IRQ
#define PCI_INTC_IRQ PCI_SHARED_IRQ
#define PCI_INTD_IRQ PCI_SHARED_IRQ
#else
#define PCI_INTA_IRQ 8  /* INTA# -> GPIO8  -> System IRQ 8 */
#define PCI_INTB_IRQ 9  /* INTB# -> GPIO9  -> System IRQ 9 */
/*
 * Note that we must never enable PCI INTC#,INTD# at the same time as
 * using GRPSW0 and GRSPW1 since we can not mix Level IRQ and edge triggered
 * IRQ. Instead we should turn off GPIO10, GPIO11 IRQ generation by setting
 * PCI_INTC_IRQ to 8 and PCI_INTD_IRQ to 9 and hardwire INTC# to INTA# and
 * INTD# to INTB# on the mother board.
 */
#define PCI_INTC_IRQ 10 /* INTC# -> GPIO10 -> System IRQ 10 (shared GRPSW0) */
#define PCI_INTD_IRQ 11 /* INTD# -> GPIO11 -> System IRQ 11 (shared GRSPW1) */
#endif

#endif

/*********************************************************************
 * User application initialization
 *
 * USER_APPL_INIT must be a valid C statement or block.  It is
 * included in the usrRoot() routine only if INCLUDE_USER_APPL is
 * defined.  The code for USER_APPL_INIT is only an example.  The
 * user is expected to change it as needed.  The use of taskSpawn
 * is recommended over direct execution of the user routine.
 */
#undef  INCLUDE_USER_APPL

/* This is the entry point into the PowerQuiccII MultiEthernet Init software */
#ifdef  INCLUDE_USER_APPL
#  define USER_APPL_INIT {void myAppInit(); myAppInit();}
#endif


/* Flash address definitions, depending on boot configuration */
#ifdef INCLUDE_ON_BOARD_BOOT_FLASH
#  undef BOOT_FLASH
#  define BOOT_FLASH         ON_BOARD_FLASH
#elif defined INCLUDE_SIMM_BOOT_FLASH
#  undef BOOT_FLASH
#  define BOOT_FLASH         SIMM_FLASH
#endif

/* Define CPU type and number of Serial channels  */
#define BUS                       BUS_TYPE_NONE      /* bus-less board            */
#define CPU                       SPARC  /* CPU type                  */
#define N_SIO_CHANNELS            2      /* No. serial I/O channels   */

/* Only one can be selected, FULL overrides BASIC */

#ifdef INCLUDE_MMU_FULL
#   undef INCLUDE_MMU_BASIC
#endif

/* PowerQUICC II Internal Registers */
#define PQII_REG_BASE   0x10000  /* Internal Register Base Offset */

/* Individual register addresses below are in addition to base offset above */

/* General */

#ifndef TRUE
#define TRUE  1
#define FALSE 0
#endif

/* Debugging configuration */

/*
 * If the FORCE_DEFAULT_BOOT_LINE is defined then the DEFAULT_BOOT_LINE
 * parameters are always used regardless of NVRAM values specified at
 * bootrom time. See target.nr for details. This is usually used to debug
 * WR downloaded images without a bootrom present.
 */

#undef  FORCE_DEFAULT_BOOT_LINE

/* Transparent Mode Driver for WDB connection via Wind River emulator */
#undef  INCLUDE_WDB_COMM_VTMD
/* #ifdef  INCLUDE_WDB_COMM_VTMD */
/* #  undef FORCE_DEFAULT_BOOT_LINE /\* When using TMD this macro should be undefined *\/ */
/* #undef  WDB_COMM_TYPE */
/* #define WDB_COMM_TYPE WDB_COMM_VTMD */
/* #endif  /\* INCLUDE_WDB_COMM_VTMD *\/ */

/* Stuff to be excluded if FORCE_DEFAULT_BOOT_LINE defined */

#ifdef  FORCE_DEFAULT_BOOT_LINE
#  undef  NV_RAM_SIZE
#  define NV_RAM_SIZE         NONE
#endif  /* FORCE_DEFAULT_BOOT_LINE */

/* Boot line configuration */
/*#undef BOOT_LINE_ADRS
#define BOOT_LINE_ADRS  ((char *)sysGetBootLine())
*/

#ifdef BOOT_DEV_NAME
#  define DEFAULT_BOOT_LINE    BOOT_DEV_NAME \
                             "(0,0)nubium:vxWorks " \
                             "e=192.168.1.200:ffffff00 " \
                             "h=192.168.1.89 " \
                             "g=192.168.1.1 " \
                             "u=ut699 pw=buckwheat " \
                             "f=0x408 tn=banjo" /* 0x04 = no autoboot */


#endif /* BOOT_DEV_NAME */

#define INCLUDE_VXBUS
#define INCLUDE_VXB_CMDLINE

/*#define SHELL_DEFAULT_CONFIG "LINE_EDIT_MODE=,LINE_LENGTH=256,STRING_FREE=manual,INTERPRETER=Cmd,VXE_PATH=.;/romfs"*/

/*
#define INCLUDE_STARTUP_SCRIPT
*/
/* add romfs */
/*
#define INCLUDE_ROMFS
#define BUNDLE_STANDALONE_SHELL
*/
/*
#define INCLUDE_SIGNALS

#define INCLUDE_WINDVIEW

#define INCLUDE_POSIX_SHM
*/
/*
 * STANDALONE_NET must be defined for network debug with
 * standalone vxWorks
 */
#undef STANDALONE_NET

/* define for bspVal testing */
#undef BSPVAL_TEST

#ifdef BSPVAL_TEST
#  define INCLUDE_DEBUG
#  define INCLUDE_SHELL
#  define INCLUDE_SHOW_ROUTINES
#  define INCLUDE_NET_SHOW
#  define INCLUDE_NET_SYM_TBL
#  define INCLUDE_LOADER
#  define INCLUDE_PING
#  define INCLUDE_POWER_MGMT_CPU_BSP_SUPPORT
#endif /* BSPVAL_TEST */

/*
#define INCLUDE_SHARED_DATA
#define INCLUDE_ZBUF_SOCK
*/
/*
#define INCLUDE_DEBUG
#define INCLUDE_SHELL
#define INCLUDE_SHOW_ROUTINES
#define INCLUDE_STANDALONE_SYM_TBL
#define INCLUDE_SYM_TBL_SHOW

#define INCLUDE_PING
#define INCLUDE_NET_SHOW
#define INCLUDE_NET_IF_SHOW
#define INCLUDE_TCP_SHOW
#define INCLUDE_UDP_SHOW
#define INCLUDE_LOADER
#define INCLUDE_ADR_SPACE_SHOW
#define INCLUDE_VM_SHOW
#define INCLUDE_VM_SHOW_SHELL_CMD
#define INCLUDE_PAGE_POOL_SHOW
#define INCLUDE_DISK_UTIL
#define INCLUDE_SHELL_INTERP_CMD
#define INCLUDE_TELNET
#define INCLUDE_RLOGIN
#define TELNETD_MAX_CLIENTS 10
*/

#undef INCLUDE_SECURITY
#undef ROMSTART_BOOT_CLEAR



/*************************** VxBus drivers defines ***************************
 * Enable VxBus and the AMBA Plug&Play Bus Controller by default.
 *
 */
#define INCLUDE_HWMEM_ALLOC
#define HWMEM_POOL_SIZE 50000
#define INCLUDE_VXBUS
#define INCLUDE_VXBUS_SHOW
#define INCLUDE_PLB_BUS
#define INCLUDE_AMBAPP_BUS
#define INCLUDE_GRLIB_AMBAPP_BUSCTRL

#define DRV_INTCTRL_GRLIB_MPIRQ

/* Use VxBus driver for default timer support (sysClk, auxClk, timestampClk, delayMs...)*/
#define INCLUDE_TIMER_SYS
#define DRV_TIMER_GRLIB_GPTIMER
#define GPTIMER_SCALAR_RELOAD 8
#define DRV_TIMER_LEON2

/* Include LEON2 and GRLIB UART support by default */
#define DRV_GRLIB_APBUART
#define DRV_UART_LEON2
#define INCLUDE_TTY_DEV
#define INCLUDE_SIO_UTILS

/* GRETH driver requires MII-bus layer and generic PHY driver.
 * If PHY driver matching PCB's PHY is available the generic PHY
 * support can be replaced with that driver. For example the
 * GR-UT699 board can be used with the INCLUDE_LXT972PHY
 * PHY driver.
 */
#ifdef DRV_GRLIB_END
#define INCLUDE_MII_BUS
#define INCLUDE_GENERICPHY
#endif

/* GRETH driver default configuration */
#define GRETH_DEBUG_PHY_LEVEL 0

/* Core 0 */
#define GRETH0_CFG_MAC_ADDR "00:00:7a:cc:00:12"
#define GRETH0_CFG_TXBDNUM 16
#define GRETH0_CFG_RXBDNUM 16
#define GRETH0_CFG_EDCL_SPEED 1
#define GRETH0_CFG_EDCL_FD TRUE

/* Core 1 */
#define GRETH1_CFG_MAC_ADDR "00:00:7a:cc:00:13"
#define GRETH1_CFG_TXBDNUM 16
#define GRETH1_CFG_RXBDNUM 16
#define GRETH1_CFG_EDCL_SPEED 1
#define GRETH1_CFG_EDCL_FD TRUE


#ifdef __GNUC__
#define INCLUDE_GNU_INTRINSICS
#undef INCLUDE_DIAB_INTRINSICS
#endif

#ifdef __cplusplus
}
#endif

#endif  /* __INCconfigh */

#if defined(PRJ_BUILD)
#include "prjParams.h"
#else
#undef INCLUDE_FPU_DENORM_SUPPORT
#endif

