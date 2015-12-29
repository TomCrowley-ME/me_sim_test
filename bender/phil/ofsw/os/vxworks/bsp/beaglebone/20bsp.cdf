/* 20bsp.cdf - BSP-specific component descriptor file */

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
01b,30aug12,my_  remove INCLUDE_BOOT_ETH_MAC_HANDLER
01a,09may12,my_  created from ti_dm81xx_evm
*/

/*
DESCRIPTION
This file contains descriptions for this BSP components.
*/

Bsp beaglebone {
    NAME            board support package
    CPU             ARMARCH7
    ENDIAN          little
    FP              vector
    REQUIRES        INCLUDE_KERNEL \
                    DRV_TIMER_OMAP35XX \
                    DRV_INTCTLR_OMAP35XX \
                    DRV_SIO_NS16550
}

Component INCLUDE_SIO_POLL {

/* always include when project is created, deselect separately */

    INCLUDE_WHEN += INCLUDE_KERNEL
}

/*
 * Network Boot Devices for a BSP
 * The REQUIRES line should be modified for a BSP.
 */

Component INCLUDE_BOOT_NET_DEVICES {
    REQUIRES        DRV_VXBEND_TI_CPSW \
                    INCLUDE_GENERICPHY
    INCLUDE_WHEN += INCLUDE_BOOT_NETWORK
}

Parameter VFPVARIANT {
    NAME         Vector Floating Point variant
    DEFAULT      VFPV3
}

Parameter RAM_HIGH_ADRS {
    NAME            Bootrom Copy region
    DEFAULT         (INCLUDE_BOOT_RAM_IMAGE)::(0x83500000)  \
                    (INCLUDE_BOOT_APP)::(0x82000000)        \
                    0x81000000
}

Parameter RAM_LOW_ADRS {
    NAME            Runtime kernel load address
    DEFAULT         (INCLUDE_BOOT_RAM_IMAGE)::(0x82a00000)  \
                    (INCLUDE_BOOT_APP)::(0x81000000)        \
                    0x80100000
}

Profile PROFILE_BOOTAPP {
    COMPONENTS += INCLUDE_MMU_BASIC
}

Component DRV_STORAGE_OMAP35XX_MMCHS {
    NAME        Omap35xx MMC/SD/SDIO host controller driver
    SYNOPSIS    Omap35xx MMC/SD/SDIO host controller driver
    MODULES     vxbOmap35xxMmchs.o
    REQUIRES    INCLUDE_VXBUS \
                INCLUDE_PLB_BUS \
                INCLUDE_ERF \
                INCLUDE_FS_MONITOR \
                INCLUDE_XBD \
                DRV_TI_EDMA3 \
                INCLUDE_VXB_LEGACY_INTERRUPTS
    _CHILDREN   FOLDER_DRIVERS
    INIT_RTN    omap35xxMmchsRegister();
    PROTOTYPE   void omap35xxMmchsRegister(void);
    _INIT_ORDER hardWareInterFaceBusInit
    INIT_AFTER  INCLUDE_PLB_BUS
}

Component INCLUDE_PRU_ICSS {
    NAME        TI PRU-ICSS Support
    SYNOPSIS    Enables the PRU-ICSS driver
    _CHILDREN   FOLDER_DRIVERS
}
