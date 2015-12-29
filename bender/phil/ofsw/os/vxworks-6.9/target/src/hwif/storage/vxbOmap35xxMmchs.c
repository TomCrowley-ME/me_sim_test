/* vxbOmap35xxMmchs.c - TI Omap35xx MMCHS driver */

/*
 * Copyright (c) 2010-2014 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify or otherwise make use
 * of this software may be licensed only pursuant to the terms
 * of an applicable Wind River license agreement.
 */

/*
modification history
--------------------
01l,19jun14,e_d  fix the quickly insert/pull out device issue. (VXW6-14680)
01k,08jul13,e_d  check maximum clk threshold in
                 omap35xxMmchsClkFreqSetup. (WIND00425553)
01j,07mar13,c_l  Remove build warnings. (WIND00406706)
01j,27feb13,clx  fix getting unwanted data interrupt issue. (WIND00404595)
01i,18dec12,e_d  Fixed blkNo more than 0xFFFF issue in omap35xxMmchsBlkRead
                 and omap35xxMmchsBlkWrite function. (WIND00389400)
01h,17dec12,e_d  set attached attribute to FALSE before delete device. (WIND00390089)
01g,19oct12,sye  fix potential interrupts missing. (WIND00352539)
01f,21aug11,my_  decouple DMA oprerations from driver.
01e,13sep11,d_c  Resolve build errors created by conflicting parallel changes:
                 1) fix for defect WIND00291597 in this file and 2) updates
                 made to hwif/h/storage/vxbSdMmcLib.h (01d, 05jul11) that
                 modified the cmdIssued member of the SDMMC_HOST struct.
01d,08aug11,my_  fix build issue due to interface changes (WIND00291814)
01c,05sep11,hcl  fix cache coherency issue. (WIND00291597)
01b,07dec10,sye  fix unable to boot from SD card. (WIND00240777)
01a,02jun10,hcl  written.
*/

/*
DESCRIPTION

This is the vxbus compliant MMC/SD/SDIO Host Controller (MMCHS)
driver which implements the functionality specific to the TI SOCs.

The MMCHS provides an interface between the host system and SD/MMC memory cards.

The driver implements all the vxbus driver specific initialization routines like
omap35xxMmchsInstInit(), omap35xxMmchsInstInit2() and
omap35xxMmchsInstConnect().

EXTERNAL INTERFACE

The driver provides the standard vxbus external interface function
omap35xxMmchsRegister(). This function registers the driver with the vxbus
subsystem, and instances will be created as needed. Since omap35xxMmchs is a
processor local bus device, each device instance must be specified in the
hwconf.c file in a BSP.

The hwconf entry must specify the following parameters:

\is

\i <regBase>
Specifies the base address where MMCHS registers are mapped into the host's
address space. All register offsets are computed relative to this address.

\i <dmaMode>
Specifies the DMA mode of MMCHS. Both SDMA and PIO mode are supported now.
If this property is not explicitly specified, the driver uses SDMA by default.

\i <cardDetect>
Specifie the card present detect function. This function is used to detect if
the card is present.

\i <cardWpCheck>
Specifie the card write protect detect function. This function is used to detect
if the card is write protect.

\i <cardPowerOn>
Specifie the MMCHS power-on function. This function is used to power on the
MMCHS module.

\i <dmaStart>
Specify the DMA start function. This function is used to start DMA transfer on
a given channel.

\i <dmaAlloc>
Specify the DMA allocation function. This function is used to allocate DMA
resources.

\i <dmaFree>
Specify the DMA release function. This function is used to release DMA resources

\ie

An example hwconf entry is shown below:

\cs
struct hcfResource omap35xxMmchsResources[] = {
    { "regBase",             HCF_RES_INT,    { (void *)OMAP_MMC1 } },
    { "cardDetect",          HCF_RES_ADDR,   { (void *)sysCardDetect } },
    { "cardWpCheck",         HCF_RES_ADDR,   { (void *)sysCardWpCheck } },
    { "cardPowerOn",         HCF_RES_ADDR,   { (void *)sysCardPowerOn } },
    { "dmaMode",             HCF_RES_INT,    { (void *)MMCHS_DMA_MODE_DEFAULT } },
    { "dmaStart",            HCF_RES_ADDR,   { (void *)sysDmaStart} },
    { "dmaAlloc",            HCF_RES_ADDR,   { (void *)sysDmaAlloc} },
    { "dmaFree",             HCF_RES_ADDR,   { (void *)sysDmaFree} },
};
\ce

SEE ALSO: vxBus, xbd
\tb "OMAP35x_TRM"
*/

/* includes */

#include <vxWorks.h>
#include <stdio.h>
#include <semLib.h>
#include <sysLib.h>
#include <taskLib.h>
#include <vxBusLib.h>
#include <hwif/vxbus/vxBus.h>
#include <hwif/vxbus/hwConf.h>
#include <hwif/util/vxbParamSys.h>
#include <hwif/util/vxbDmaLib.h>
#include <../src/hwif/h/vxbus/vxbAccess.h>
#include <../src/hwif/h/storage/vxbSdMmcLib.h>
#include <../src/hwif/h/storage/vxbSdMmcXbd.h>
#include <../src/hwif/h/storage/vxbOmap35xxMmchs.h>

/* defines */

#undef  OMAP35XX_MMCHS_DBG_ON
#ifdef  OMAP35XX_MMCHS_DBG_ON

#   ifdef  LOCAL
#   undef  LOCAL
#   define LOCAL
#   endif

#   define MMCHS_DBG_IRQ            0x00000001
#   define MMCHS_DBG_RW             0x00000002
#   define MMCHS_DBG_XBD            0x00000004
#   define MMCHS_DBG_ERR            0x00000008
#   define MMCHS_DBG_ALL            0xffffffff
#   define MMCHS_DBG_OFF            0x00000000

UINT32 omap35xxMmchsDbgMask = MMCHS_DBG_ALL;

IMPORT FUNCPTR _func_logMsg;

#   define OMAP35XX_MMCHS_DBG(mask, string, a, b, c, d, e, f)          \
        if ((omap35xxMmchsDbgMask & mask) || (mask == MMCHS_DBG_ALL))   \
            _func_logMsg(string, a, b, c, d, e, f)
#else
#   define OMAP35XX_MMCHS_DBG(mask, string, a, b, c, d, e, f)
#endif  /* OMAP35XX_MMCHS_DBG_ON */

/* forward declarations */

LOCAL void omap35xxMmchsInstInit (VXB_DEVICE_ID);
LOCAL void omap35xxMmchsInstInit2 (VXB_DEVICE_ID);
LOCAL void omap35xxMmchsInstConnect (VXB_DEVICE_ID);

LOCAL void omap35xxMmchsHardwareInit (VXB_DEVICE_ID);
LOCAL void omap35xxMmchsDevInit (VXB_DEVICE_ID);

LOCAL void omap35xxMmchsIsr (VXB_DEVICE_ID);
LOCAL void omap35xxMmchsCardMonTask (VXB_DEVICE_ID);

LOCAL STATUS omap35xxMmchsCmdIssue (SDMMC_HOST *);
LOCAL void omap35xxMmchsClkFreqSetup (SDMMC_HOST *, UINT32);
LOCAL void omap35xxMmchsBusWidthSetup (SDMMC_HOST *, UINT32);

LOCAL STATUS omap35xxMmchsBlkRead (SDMMC_CARD *, sector_t, UINT32, void *);
LOCAL STATUS omap35xxMmchsBlkWrite (SDMMC_CARD *, sector_t, UINT32, void *);

LOCAL STATUS omap35xxMmchsPioRead (VXB_DEVICE_ID);
LOCAL STATUS omap35xxMmchsPioWrite (VXB_DEVICE_ID);

LOCAL STATUS omap35xxMmchsCmdPrepare (SDMMC_HOST *, SDMMC_CMD *);

/* locals */

LOCAL DRIVER_INITIALIZATION omap35xxMmchsFuncs =
    {
    omap35xxMmchsInstInit,        /* devInstanceInit */
    omap35xxMmchsInstInit2,       /* devInstanceInit2 */
    omap35xxMmchsInstConnect      /* devConnect */
    };

LOCAL DRIVER_REGISTRATION omap35xxMmchsRegistration =
    {
    NULL,                   /* pNext */
    VXB_DEVID_DEVICE,       /* devID */
    VXB_BUSID_PLB,          /* busID = PLB */
    VXB_VER_4_0_0,          /* vxbVersion */
    MMCHS_NAME,             /* drvName */
    &omap35xxMmchsFuncs,    /* pDrvBusFuncs */
    NULL,                   /* pMethods */
    NULL,                   /* devProbe */
    NULL                    /* pParamDefaults */
    };

/* externs */

IMPORT UCHAR erfLibInitialized;
IMPORT void vxbUsDelay (int);
IMPORT void bzero (char *, int);

/*******************************************************************************
*
* omap35xxMmchsHardwareInit - initialize omap35xxMmchs chip
*
* This routine initializes omap35xxMmchs.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void omap35xxMmchsHardwareInit
    (
    VXB_DEVICE_ID   pDev
    )
    {
    volatile UINT32 value;

    /* HSMMC1 software reset */

    value = CSR_READ_4 (pDev, MMCHS_SYSCONFIG);
    value |= MMCHS_SYSCONFIG_SOFTRESET_MASK;
    CSR_WRITE_4 (pDev, MMCHS_SYSCONFIG, value);
    do{
        value = CSR_READ_4 (pDev, MMCHS_SYSSTATUS);
    }while (!(value & MMCHS_SYSSTATUS_RESETDONE_MASK));

    /* HSMMC1 software reset for all */

    value = CSR_READ_4 (pDev, MMCHS_SYSCTL);
    value |= MMCHS_SYSCTL_SRC_MASK;
    CSR_WRITE_4 (pDev, MMCHS_SYSCTL, value);
    do{
        value = CSR_READ_4 (pDev, MMCHS_SYSCTL);
    }while (value & MMCHS_SYSCTL_SRC_MASK);

    /* 1.8V Supported, 3.0V supported */

    value = CSR_READ_4 (pDev, MMCHS_CAPA);
    value |= MMCHS_CAPA_VS30_MASK | MMCHS_CAPA_VS18_MASK;
    CSR_WRITE_4 (pDev, MMCHS_CAPA, value);

    /* SD bus voltage select, 3.0V */

    value = CSR_READ_4 (pDev, MMCHS_HCTL);
    value &= ~MMCHS_HCTL_SDVS_MASK;
    value |= (MMCHS_HCTL_SDVS << MMCHS_HCTL_SDVS_SHIFT);
    CSR_WRITE_4 (pDev, MMCHS_HCTL, value);

    /* Debounce time for the card detect signal */

    value = CSR_READ_4 (pDev, MMCHS_CON);
    value &= ~MMCHS_CON_DVAL_MASK;
    value |= (MMCHS_CON_DVAL << MMCHS_CON_DVAL_SHIFT);
    CSR_WRITE_4 (pDev, MMCHS_CON, value);

    /* 1-bit Data width */

    value = CSR_READ_4 (pDev, MMCHS_HCTL);
    value &= ~MMCHS_HCTL_DTW_MASK;
    CSR_WRITE_4 (pDev, MMCHS_HCTL, value);

    /* SD bus power off */

    value = CSR_READ_4 (pDev, MMCHS_HCTL);
    value &= ~MMCHS_HCTL_SDBP_MASK;
    CSR_WRITE_4 (pDev, MMCHS_HCTL, value);

    /* Internal clock is stopped, clock is not provided to the card */

    value = CSR_READ_4 (pDev, MMCHS_SYSCTL);
    value &= ~(MMCHS_SYSCTL_ICE_MASK | \
            MMCHS_SYSCTL_CEN_MASK | MMCHS_SYSCTL_DTO_MASK);
    value |= (MMCHS_SYSCTL_DTO << MMCHS_SYSCTL_DTO_SHIFT);
    CSR_WRITE_4 (pDev, MMCHS_SYSCTL, value);

    /* Clock frequency select for initialization stream, enable clock */

    value = CSR_READ_4 (pDev, MMCHS_SYSCTL);
    value &= ~MMCHS_SYSCTL_CLKD_MASK;
    value |= MMCHS_SYSCTL_ICE_MASK | \
            (MMCHS_SYSCTL_CLKD << MMCHS_SYSCTL_CLKD_SHIFT);
    CSR_WRITE_4 (pDev, MMCHS_SYSCTL, value);

    /* Wait clock to be stable */

    do{
        value = CSR_READ_4 (pDev, MMCHS_SYSCTL);
    }while (!(value & MMCHS_SYSCTL_ICS_MASK));

    /* The clock is provided to the card */

    value = CSR_READ_4 (pDev, MMCHS_SYSCTL);
    value |= MMCHS_SYSCTL_CEN_MASK;
    CSR_WRITE_4 (pDev, MMCHS_SYSCTL, value);

    /* SD bus power on */

    value = CSR_READ_4 (pDev, MMCHS_HCTL);
    value |= MMCHS_HCTL_SDBP_MASK;
    CSR_WRITE_4 (pDev, MMCHS_HCTL, value);
    do{
        value = CSR_READ_4 (pDev, MMCHS_HCTL);
    }while (!(value & MMCHS_HCTL_SDBP_MASK));

    /* Enable MMC1 ENAWAKEUP */

    value = CSR_READ_4 (pDev, MMCHS_SYSCONFIG);
    value |= MMCHS_SYSCONFIG_ENAWAKEUP_MASK;
    CSR_WRITE_4 (pDev, MMCHS_SYSCONFIG, value);

    /* MMC1_HCTL IWE */

    value = CSR_READ_4 (pDev, MMCHS_HCTL);
    value |= MMCHS_HCTL_IWE_MASK;
    CSR_WRITE_4 (pDev, MMCHS_HCTL, value);

    /* MMC1 SIDLEMODE CLOCKACTIVITY */

    value = CSR_READ_4 (pDev, MMCHS_SYSCONFIG);
    value |= (MMCHS_SYSCONFIG_SIDLEMODE << MMCHS_SYSCONFIG_SIDLEMODE_SHIFT) | \
        (MMCHS_SYSCONFIG_CLOCKACTIVITY << MMCHS_SYSCONFIG_CLOCKACTIVITY_SHIFT);
    CSR_WRITE_4 (pDev, MMCHS_SYSCONFIG, value);

    /* Enable MMC1 AUTOIDLE */

    value = CSR_READ_4 (pDev, MMCHS_SYSCONFIG);
    value |= MMCHS_SYSCONFIG_AUTOIDLE_MASK;
    CSR_WRITE_4 (pDev, MMCHS_SYSCONFIG, value);

    /* Enable interrupts */

    value = MMCHS_IE_EN_DEFUALT;
    CSR_WRITE_4 (pDev, MMCHS_IE, value);

    /* Send initialization stream */

    value = CSR_READ_4 (pDev, MMCHS_CON);
    value |= MMCHS_CON_INIT_MASK;
    CSR_WRITE_4 (pDev, MMCHS_CON, value);

    /* Send CMD0 */

    value = MMCHS_CMD0;
    CSR_WRITE_4 (pDev, MMCHS_CMD, value);

    /* Wait command to complete */

    do{
        value = CSR_READ_4 (pDev, MMCHS_STAT);
    }while (!(value & MMCHS_STAT_CC_MASK));

    CSR_WRITE_4 (pDev, MMCHS_STAT, MMCHS_STAT_CC_MASK);

    /* Send CMD0 */

    value = MMCHS_CMD0;
    CSR_WRITE_4 (pDev, MMCHS_CMD, value);

    /* Wait command to complete */

    do{
        value = CSR_READ_4 (pDev, MMCHS_STAT);
    }while (!(value & MMCHS_STAT_CC_MASK));

    CSR_WRITE_4 (pDev, MMCHS_STAT, value);

    /* Initialization stream finished */

    value = CSR_READ_4 (pDev, MMCHS_CON);
    value &= ~MMCHS_STAT_TC_MASK;
    CSR_WRITE_4 (pDev, MMCHS_CON, value);

    /* Clear MMCHS_STAT registe */

    CSR_WRITE_4 (pDev, MMCHS_STAT, IRQ_ALL);

    /* Disable interrupt */

    CSR_WRITE_4 (pDev, MMCHS_IE, 0);
    }

/*******************************************************************************
*
* omap35xxMmchsRegister - register omap35xxMmchs driver
*
* This routine registers the omap35xxMmchs driver with the vxbus subsystem.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

void omap35xxMmchsRegister (void)
    {
    vxbDevRegister (&omap35xxMmchsRegistration);
    }

/*******************************************************************************
*
* omap35xxMmchsInstInit - first level initialization routine of omap35xxMmchs
* device
*
* This routine performs the first level initialization of the omap35xxMmchs
* device.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void omap35xxMmchsInstInit
    (
    VXB_DEVICE_ID   pInst
    )
    {
    }

/*******************************************************************************
*
* omap35xxMmchsInstInit2 - second level initialization routine
*
* This routine performs the second level initialization of the omap35xxMmchs.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void omap35xxMmchsInstInit2
    (
    VXB_DEVICE_ID   pInst
    )
    {
    MMCHS_DRV_CTRL * pDrvCtrl;
    struct hcfDevice * pHcf;

    pDrvCtrl = (MMCHS_DRV_CTRL *)malloc (sizeof(MMCHS_DRV_CTRL));
    if (pDrvCtrl == NULL)
        {
        return;
        }
    bzero ((char *)pDrvCtrl, sizeof(MMCHS_DRV_CTRL));

    pDrvCtrl->pDev = pInst;
    pInst->pDrvCtrl = pDrvCtrl;

    pDrvCtrl->regBase = pInst->pRegBase[0];
    vxbRegMap (pInst, 0, &pDrvCtrl->regHandle);

    /* internal buffer data port is little endian */

    pDrvCtrl->pioHandle = (void *)((UINT32)pDrvCtrl->regHandle);
    pHcf = (struct hcfDevice *)hcfDeviceGet (pInst);
    if (pHcf == NULL)
        {
        free (pDrvCtrl);
        return;
        }

    /*
     * resourceDesc {
     * The dmaMode resource specifies the DMA
     * mode of MMCHS. If this property is not
     * explicitly specified, the driver uses
     * SDMA by default. }
     */

    (void) devResourceGet (pHcf, "dmaMode", HCF_RES_INT,
                          (void *)&pDrvCtrl->dmaMode);

    /*
     * resourceDesc {
     * The card power function is used to
     * detect if the card is present.
     * }
     */

    (void) devResourceGet (pHcf, "cardDetect", HCF_RES_ADDR,
                          (void *)&pDrvCtrl->cardDetect);

    /*
     * resourceDesc {
     * The card protect detect function is used to
     * check if the card is write protect.
     * }
     */

    (void) devResourceGet (pHcf, "cardWpCheck", HCF_RES_ADDR,
                          (void *)&pDrvCtrl->cardWpCheck);
    /*
     * resourceDesc {
     * The card power on function is used to
     * power on the card.
     * }
     */

    (void) devResourceGet (pHcf, "cardPowerOn", HCF_RES_ADDR,
                          (void *)&pDrvCtrl->cardPowerOn);

    /*
     * resourceDesc {
     * The dma start function is used to
     * start dma transfer.
     * }
     */

    (void) devResourceGet (pHcf, "dmaStart", HCF_RES_ADDR,
                          (void *)&pDrvCtrl->dmaStart);

    /*
     * resourceDesc {
     * The dma alloc function is used to
     * initialize dma channel.
     * }
     */

    (void) devResourceGet (pHcf, "dmaAlloc", HCF_RES_ADDR,
                          (void *)&pDrvCtrl->dmaAlloc);

    /*
     * resourceDesc {
     * The dma release function is used to
     * free dma channel.
     * }
     */

    (void) devResourceGet (pHcf, "dmaFree", HCF_RES_ADDR,
                          (void *)&pDrvCtrl->dmaFree);

    /* per-device init */

    omap35xxMmchsDevInit (pInst);
    }

/*******************************************************************************
*
* omap35xxMmchsInstConnect - third level initialization routine of omap35xxMmchs
*
* This routine performs the third level initialization of the omap35xxMmchs.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void omap35xxMmchsInstConnect
    (
    VXB_DEVICE_ID   pInst
    )
    {
    FUNCPTR cardMon;
    MMCHS_DRV_CTRL * pDrvCtrl = (MMCHS_DRV_CTRL *)pInst->pDrvCtrl;

    /* create a monitor task that handles card state change */

    cardMon = (FUNCPTR)omap35xxMmchsCardMonTask;

    taskSpawn (MMCHS_CARD_MON_TASK_NAME, MMCHS_CARD_MON_TASK_PRI, 0,
               MMCHS_CARD_MON_TASK_STACK, cardMon, (int)pInst,
               0, 0, 0, 0, 0, 0, 0, 0, 0);

    /* setup the interrupt mask */

    pDrvCtrl->intMask = (IRQ_DATA | IRQ_CMD);
    pDrvCtrl->intMask |= IRQ_AC12E;

    if (pDrvCtrl->dmaMode == MMCHS_DMA_MODE_PIO)
        {
        pDrvCtrl->intMask |= (IRQ_BRR | IRQ_BWR);
        }

    CSR_WRITE_4 (pInst, MMCHS_IE, pDrvCtrl->intMask);

    /* connect and enable interrupt */

    (void) vxbIntConnect (pInst, 0, omap35xxMmchsIsr, pInst);
    (void) vxbIntEnable (pInst, 0, omap35xxMmchsIsr, pInst);

    /* enable MMCHS interrupts */

    CSR_WRITE_4 (pInst, MMCHS_ISE, pDrvCtrl->intMask);
    }

/*******************************************************************************
*
* omap35xxMmchsDevInit - the MMCHS per device specific initialization
*
* This routine performs per device specific initialization of MMCHS.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void omap35xxMmchsDevInit
    (
    VXB_DEVICE_ID   pInst
    )
    {
    MMCHS_DRV_CTRL * pDrvCtrl = (MMCHS_DRV_CTRL *)pInst->pDrvCtrl;
    UINT32 hostCap;

    /* initialize MMCHS hardware */

    omap35xxMmchsHardwareInit (pInst);

    /* get host controller version */

    pDrvCtrl->hcVer = CSR_READ_4 (pInst, MMCHS_REV) & 0xffff0000;

    /* get host controller capabilities */

    hostCap = CSR_READ_4 (pInst, MMCHS_CAPA);

    /* determind DMA mode supported */

    if (!(hostCap & CAPA_DMAS))
        {
        pDrvCtrl->dmaMode = MMCHS_DMA_MODE_PIO;
        }

    /* fill in SDMMC_HOST structure */

    pDrvCtrl->host.pDev = pInst;
    pDrvCtrl->host.ops.cmdIssue = (FUNCPTR)omap35xxMmchsCmdIssue;

    pDrvCtrl->host.ops.clkFreqSetup = (FUNCPTR)omap35xxMmchsClkFreqSetup;
    pDrvCtrl->host.ops.busWidthSetup = (FUNCPTR)omap35xxMmchsBusWidthSetup;
    pDrvCtrl->host.ops.cardWpCheck = (FUNCPTR)pDrvCtrl->cardWpCheck;

    /* determine voltage supported */

    if (hostCap & CAPA_VS30)
        {
        pDrvCtrl->host.capbility |= (OCR_VDD_VOL_29_30 | OCR_VDD_VOL_30_31);
        }

    if (hostCap & CAPA_VS33)
        {
        pDrvCtrl->host.capbility |= (OCR_VDD_VOL_32_33 | OCR_VDD_VOL_33_34);
        }

    /* high capacity SD card is supported */

    pDrvCtrl->host.capbility |= OCR_CARD_CAP_STS;

    /* determine high speed SD card supported */

    if (hostCap & CAPA_HSS)
        {
        pDrvCtrl->host.highSpeed = TRUE;
        }

    pDrvCtrl->card.host = &pDrvCtrl->host;

    /* fill in SDMMC_XBD_DEV structure */

    pDrvCtrl->card.xbdDev.blkRd = (FUNCPTR)omap35xxMmchsBlkRead;
    pDrvCtrl->card.xbdDev.blkWt = (FUNCPTR)omap35xxMmchsBlkWrite;

    pDrvCtrl->card.xbdDev.card = &pDrvCtrl->card;

    /*
     * The devChange semaphore is used by the interrupt service routine
     * to inform the card monitor task that a state change has occurred.
     */

    pDrvCtrl->devChange = semBCreate (SEM_Q_PRIORITY, SEM_EMPTY);
    pDrvCtrl->cmdDone = semBCreate (SEM_Q_PRIORITY, SEM_EMPTY);
    pDrvCtrl->dataDone = semBCreate (SEM_Q_PRIORITY, SEM_EMPTY);

    }

/*******************************************************************************
*
* omap35xxMmchsIsr - interrupt service routine of omap35xxMmchs
*
* This routine handles interrupts of omap35xx MMCHS.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void omap35xxMmchsIsr
    (
    VXB_DEVICE_ID   pDev
    )
    {
    MMCHS_DRV_CTRL * pDrvCtrl = (MMCHS_DRV_CTRL *)pDev->pDrvCtrl;
    SDMMC_HOST * host = &pDrvCtrl->host;
    UINT32 intSts;

    intSts = CSR_READ_4 (pDev, MMCHS_STAT);
    pDrvCtrl->intSts = intSts;

    if (!intSts)
        {
        return;
        }

    /* clear interrupts */

    CSR_WRITE_4 (pDev, MMCHS_STAT, intSts);

    /* command interrupts */

    if (intSts & IRQ_CMD)
        {
        if (intSts & IRQ_CC)
            {
            OMAP35XX_MMCHS_DBG (MMCHS_DBG_IRQ, "CMD%d cmd complete\n",
                          host->cmdIssued.cmdIdx, 0, 0, 0, 0, 0);
            }

        if (intSts & IRQ_CMD_ERR)
            {
            if (intSts & IRQ_CIE)
                {
                OMAP35XX_MMCHS_DBG (MMCHS_DBG_ERR, "CMD%d cmd index error\n",
                            host->cmdIssued.cmdIdx, 0, 0, 0, 0, 0);
                host->cmdIssued.cmdErr |= SDMMC_CMD_ERR_PROTOCOL;
                }

            if (intSts & IRQ_CEBE)
                {
                OMAP35XX_MMCHS_DBG (MMCHS_DBG_ERR,
                            "CMD%d cmd end of bit error\n",
                            host->cmdIssued.cmdIdx, 0, 0, 0, 0, 0);
                host->cmdIssued.cmdErr |= SDMMC_CMD_ERR_PROTOCOL;
                }

            if (intSts & IRQ_CCE)
                {
                OMAP35XX_MMCHS_DBG (MMCHS_DBG_ERR, "CMD%d cmd crc error\n",
                            host->cmdIssued.cmdIdx, 0, 0, 0, 0, 0);
                host->cmdIssued.cmdErr |= SDMMC_CMD_ERR_PROTOCOL;
                }

            if (intSts & IRQ_CTOE)
                {
                OMAP35XX_MMCHS_DBG (MMCHS_DBG_ERR, "CMD%d cmd timeout error\n",
                            host->cmdIssued.cmdIdx, 0, 0, 0, 0, 0);
                host->cmdIssued.cmdErr |= SDMMC_CMD_ERR_TIMEOUT;
                }
            }

        semGive (pDrvCtrl->cmdDone);
        }

    /* data interrupts */

    if (intSts & IRQ_DATA)
        {
        if ((host->cmdIssued.rspType & SDMMC_CMD_RSP_BUSY) &&
                host->cmdIssued.hasData == FALSE)
             {
             OMAP35XX_MMCHS_DBG (MMCHS_DBG_ERR, "got data interrupt but no data\n",
                          0, 0, 0, 0, 0, 0);
             return;
             }

        if (intSts & IRQ_TC)
            {
            OMAP35XX_MMCHS_DBG (MMCHS_DBG_IRQ, "CMD%d data complete\n",
                            host->cmdIssued.cmdIdx, 0, 0, 0, 0, 0);
            }

        if (intSts & IRQ_DATA_ERR)
            {
            if (intSts & IRQ_DEBE)
                {
                OMAP35XX_MMCHS_DBG (MMCHS_DBG_ERR,
                            "CMD%d data end of bit error\n",
                            host->cmdIssued.cmdIdx, 0, 0, 0, 0, 0);
                host->cmdIssued.dataErr |= SDMMC_DATA_ERR_PROTOCOL;
                }

            if (intSts & IRQ_DCE)
                {
                OMAP35XX_MMCHS_DBG (MMCHS_DBG_ERR, "CMD%d data crc error\n",
                            host->cmdIssued.cmdIdx, 0, 0, 0, 0, 0);
                host->cmdIssued.dataErr |= SDMMC_DATA_ERR_PROTOCOL;
                }

            if (intSts & IRQ_DTOE)
                {
                OMAP35XX_MMCHS_DBG (MMCHS_DBG_ERR, "CMD%d data timeout error\n",
                            host->cmdIssued.cmdIdx, 0, 0, 0, 0, 0);
                host->cmdIssued.dataErr |= SDMMC_DATA_ERR_TIMEOUT;
                }
            }

        semGive (pDrvCtrl->dataDone);
        }

    /* PIO mode */

    if (intSts & IRQ_BRR)
        {
        OMAP35XX_MMCHS_DBG (MMCHS_DBG_IRQ, "CMD%d buffer read ready\n",
                      host->cmdIssued.cmdIdx, 0, 0, 0, 0, 0);

        if (CSR_READ_4 (pDev, MMCHS_PSTATE) & PSTATE_BREN)
            omap35xxMmchsPioRead (pDev);
        }

    if (intSts & IRQ_BWR)
        {
        OMAP35XX_MMCHS_DBG (MMCHS_DBG_IRQ, "CMD%d buffer write ready\n",
                      host->cmdIssued.cmdIdx, 0, 0, 0, 0, 0);

        if (CSR_READ_4 (pDev, MMCHS_PSTATE) & PSTATE_BWEN)
            omap35xxMmchsPioWrite (pDev);
        }

    /* other errors */

    if (intSts & IRQ_AC12E)
        {
        OMAP35XX_MMCHS_DBG (MMCHS_DBG_ERR, "Auto CMD12 error\n",
                      0, 0, 0, 0, 0, 0);

        /* FIXME: error recovery */
        }
    }

/*******************************************************************************
*
* omap35xxMmchsCardMonTask - card status monitor task
*
* This routine is the task loop to handle card insersion and removal.
*
* RETURN: N/A
*
* ERRNO: N/A
*/

LOCAL void omap35xxMmchsCardMonTask
    (
    VXB_DEVICE_ID   pDev
    )
    {
    STATUS rc;
    device_t dev;
    UINT32 regValue = 0;
	UINT32 timeOut = 0;

    MMCHS_DRV_CTRL * pDrvCtrl = (MMCHS_DRV_CTRL *)pDev->pDrvCtrl;

    while (!erfLibInitialized)
        taskDelay (sysClkRateGet ());

    FOREVER
        {
        /* delay for debounce */

        taskDelay (sysClkRateGet ());

        if (pDrvCtrl->cardDetect () && !pDrvCtrl->cardIns)
            {
            /* power on MMC1 */

            pDrvCtrl->cardPowerOn ();

            if (pDrvCtrl->dmaMode == MMCHS_DMA_MODE_SDMA)
                {
                if (pDrvCtrl->dmaAlloc (pDrvCtrl) != OK)
                    {
                    OMAP35XX_MMCHS_DBG (MMCHS_DBG_XBD,
                        "SD/MMC DMA channel allocation failed\n",
                        0, 0, 0, 0, 0, 0);
                    continue;
                    }
                }

            rc = sdMmcIdentify (&pDrvCtrl->card);
            if (rc == ERROR)
                {
                OMAP35XX_MMCHS_DBG (MMCHS_DBG_XBD,
                        "SD/MMC identification process failed\n",
                        0, 0, 0, 0, 0, 0);

                pDrvCtrl->cardIns = TRUE;
                    goto removeCheck;
                }

            printf ("Card inserted\n");

            /* already attached, do not create new xbd */

            if (pDrvCtrl->card.attached)
                {
                OMAP35XX_MMCHS_DBG (MMCHS_DBG_XBD,
                        "This should never happen unless hardware \
                        state is unstable\n",
                        0, 0, 0, 0, 0, 0);
                continue;
                }

            pDrvCtrl->card.attached = TRUE;

            dev = sdMmcXbdDevCreate (&pDrvCtrl->card, (char *)NULL);
            if (dev == (device_t)NULL)
                {
                OMAP35XX_MMCHS_DBG (MMCHS_DBG_ERR,
                        "sdMmcXbdXbdCreate () failed\n",
                        0, 0, 0, 0, 0, 0);
                pDrvCtrl->card.attached = FALSE;
                goto removeCheck;
                }

            pDrvCtrl->cardIns = TRUE;
            }

        if (!pDrvCtrl->cardDetect () && pDrvCtrl->cardIns)
            {
removeCheck:
            if (pDrvCtrl->card.attached == TRUE)
                {
                pDrvCtrl->card.attached = FALSE;
                sdMmcXbdDevDelete (&pDrvCtrl->card);
                }
            pDrvCtrl->cardIns = FALSE;
            while (CSR_READ_4 (pDev, MMCHS_PSTATE) & PSTATE_CIHB)
                {
                CSR_SETBIT_4 (pDev, MMCHS_SYSCTL, MMCHS_SYSCTL_SRA_MASK);
                do
                    {
                    regValue = CSR_READ_4 (pDev, MMCHS_SYSCTL);
                    }while (((regValue & MMCHS_SYSCTL_SRA_MASK) != 0x0) && (timeOut++ < 0x100000));
                }

            timeOut = 0;
            if (CSR_READ_4 (pDev, MMCHS_PSTATE) & PSTATE_CDIHB)
                {
                CSR_SETBIT_4 (pDev, MMCHS_SYSCTL, MMCHS_SYSCTL_SRD_MASK);
                do
                    {
                    regValue = CSR_READ_4 (pDev, MMCHS_SYSCTL);
                    }while (((regValue & MMCHS_SYSCTL_SRD_MASK) != 0x0)  && (timeOut++ < 0x100000));
                }

            if (pDrvCtrl->dmaMode == MMCHS_DMA_MODE_SDMA)
                {

                /* free the allocated DMA channel */

                pDrvCtrl->dmaFree (pDrvCtrl);
                }

            }

        while (semTake (pDrvCtrl->devChange, WAIT_FOREVER) != OK)
            {
            OMAP35XX_MMCHS_DBG (MMCHS_DBG_ERR,
                   "semTake () failed\n",
                   0, 0, 0, 0, 0, 0);
            }
        }
    }

/*******************************************************************************
*
* omap35xxMmchsCmdPrepare - prepare the command to be sent
*
* This routine prepares the command to be sent.
*
* RETURNS: OK or ERROR
*
* ERRNO: N/A
*/

LOCAL STATUS omap35xxMmchsCmdPrepare
    (
    SDMMC_HOST *    host,
    SDMMC_CMD *     cmd
    )
    {
    STATUS ret;
    VXB_DEVICE_ID pDev = host->pDev;
    MMCHS_DRV_CTRL * pDrvCtrl = (MMCHS_DRV_CTRL *)pDev->pDrvCtrl;
    UINT32 xferTyp = 0;
    UINT32 timeOut = 0;

    /* check PRSSTAT[CDIHB] and PRSSTAT[CIHB] before writing to XFERTYP */

    while ((CSR_READ_4 (pDev, MMCHS_PSTATE) & PSTATE_CDIHB) ||
           (CSR_READ_4 (pDev, MMCHS_PSTATE) & PSTATE_CIHB))
        {
        vxbUsDelay(1);
        timeOut++;
        if (timeOut > 10000)
            {
            OMAP35XX_MMCHS_DBG (MMCHS_DBG_ERR, "CIHB/CDIHB busy \n", 1, 2, 3, 4, 5, 6);
            return ERROR;
            }
        }
    timeOut = 0;

    /* setup command */

    xferTyp |= CMD_CMDINX (cmd->cmdIdx);

    /* setup command fields */

    if (cmd->rspType & SDMMC_CMD_RSP_CMDIDX)
        {
        xferTyp |= CMD_CICEN;
        }

    if (cmd->rspType & SDMMC_CMD_RSP_CRC)
        {
        xferTyp |= CMD_CCCEN;
        }

    if (cmd->rspType & SDMMC_CMD_RSP_LEN136)
        {
        xferTyp |= CMD_RSPTYP_LEN136;
        }
    else if (cmd->rspType & SDMMC_CMD_RSP_BUSY)
        {
        xferTyp |= CMD_RSPTYP_LEN48B;
        }
    else if (cmd->rspType & SDMMC_CMD_RSP_LEN48)
        {
        xferTyp |= CMD_RSPTYP_LEN48;
        }

    /* setup data fields */

    if (cmd->hasData)
        {
        xferTyp |= CMD_DATA_PRESENT;

        /* direction */

        if (cmd->cmdData.isRead)
            xferTyp |= CMD_DIR_READ;

        if (pDrvCtrl->dmaMode != MMCHS_DMA_MODE_PIO)
            xferTyp |= CMD_DMAEN;

        /* multipule block transfer */

        if (cmd->cmdData.blkNum > 1)
            {
            xferTyp |= (CMD_MULTI_BLK | CMD_BCEN);

            /* automatically issue CMD12 */

            xferTyp |= CMD_AC12EN;
            }

        if (pDrvCtrl->dmaMode != MMCHS_DMA_MODE_PIO)
            {
            /* require dma channel,set transfer params */

            ret = pDrvCtrl->dmaStart (host, cmd);

            if (ret != OK)
                {
                OMAP35XX_MMCHS_DBG (MMCHS_DBG_ERR,
                        "omap35xxMmchsDmaStart () failed with %d\n",
                        ret, 0, 0, 0, 0, 0);

                return ERROR;
                }
            }
        else
            {
            pDrvCtrl->pioDesc.bufOri = cmd->cmdData.buffer;
            pDrvCtrl->pioDesc.bufCur = cmd->cmdData.buffer;
            pDrvCtrl->pioDesc.blkSize = cmd->cmdData.blkSize;
            }

        CSR_WRITE_4 (pDev, MMCHS_BLK,
             (cmd->cmdData.blkNum << BLK_CNT_SHIFT) | cmd->cmdData.blkSize);

        /* setup transfer timeouts */

        CSR_CLRBIT_4 (pDev, MMCHS_SYSCTL, SYSCTL_DTOCV_MASK);
        CSR_SETBIT_4 (pDev, MMCHS_SYSCTL,
                        SYSCTL_DTOCV_MAX << SYSCTL_DTOCV_SHIFT);
        }

    /* issue the command */

    CSR_WRITE_4 (pDev, MMCHS_ARG, cmd->cmdArg);
    CSR_WRITE_4 (pDev, MMCHS_CMD, xferTyp);
    return OK;
    }

/*******************************************************************************
*
* omap35xxMmchsCmdIssue - issue the command
*
* This routine issues the command.
*
* RETURNS: OK or ERROR
*
* ERRNO: N/A
*/

LOCAL STATUS omap35xxMmchsCmdIssue
    (
    SDMMC_HOST *    host
    )
    {
    VXB_DEVICE_ID pDev = host->pDev;
    MMCHS_DRV_CTRL * pDrvCtrl = (MMCHS_DRV_CTRL *)host->pDev->pDrvCtrl;
    STATUS rc;
    SDMMC_CMD * cmd = &host->cmdIssued;

    rc = omap35xxMmchsCmdPrepare (host, cmd);
    if (rc == ERROR)
        return ERROR;

    rc = semTake (pDrvCtrl->cmdDone,
                (sysClkRateGet() * SDMMC_CMD_WAIT_IN_SECS));
    if (rc == ERROR)
        {
        OMAP35XX_MMCHS_DBG (MMCHS_DBG_ERR,
                    "[omap35xxMmchsCmdIssue]: CMD%d cmd timeout\n",
                    cmd->cmdIdx, 0, 0, 0, 0, 0);

        cmd->cmdErr |= SDMMC_CMD_ERR_TIMEOUT;
        return (rc);
        }
    else
        {
        if (cmd->cmdErr)
            {
            /* Software reset for mmci_cmd line */

            if ((cmd->cmdErr & SDMMC_CMD_ERR_TIMEOUT) &&
                ((cmd->cmdIdx == SD_CMD_SEND_IF_COND) ||
                 (cmd->cmdIdx == SDMMC_CMD_APP_CMD)))
                {
                CSR_SETBIT_4 (pDev, MMCHS_SYSCTL, SYSCTL_SRC_MASK);
                while (CSR_READ_4 (pDev, MMCHS_SYSCTL) & SYSCTL_SRC_MASK);
                }
            }
        }

    if (cmd->rspType != SDMMC_CMD_RSP_NONE)
        {
        if (cmd->rspType & SDMMC_CMD_RSP_LEN136)
            {
            UINT32 cmdRsp[4];

            cmdRsp[0] = CSR_READ_4 (host->pDev, MMCHS_RSP10);
            cmdRsp[1] = CSR_READ_4 (host->pDev, MMCHS_RSP32);
            cmdRsp[2] = CSR_READ_4 (host->pDev, MMCHS_RSP54);
            cmdRsp[3] = CSR_READ_4 (host->pDev, MMCHS_RSP76 );

            cmd->cmdRsp[0] = be32toh (cmdRsp[3]);
            cmd->cmdRsp[1] = be32toh (cmdRsp[2]);
            cmd->cmdRsp[2] = be32toh (cmdRsp[1]);
            cmd->cmdRsp[3] = be32toh (cmdRsp[0]);
            }
        else
            {
            cmd->cmdRsp[0] = CSR_READ_4 (host->pDev, MMCHS_RSP10);
            }
        }

    if (cmd->hasData)
        {
        rc = semTake (pDrvCtrl->dataDone,
                     (sysClkRateGet() * SDMMC_CMD_WAIT_IN_SECS));
        if (rc == ERROR)
            {
            OMAP35XX_MMCHS_DBG (MMCHS_DBG_ERR,
                        "[omap35xxMmchsCmdIssue]: CMD%d data timeout\n",
                        cmd->cmdIdx, 0, 0, 0, 0, 0);

            cmd->dataErr |= SDMMC_DATA_ERR_TIMEOUT;
            return (rc);
            }
        else
            {
            if (cmd->dataErr)
                {
                return ERROR;
                }
            }
        }

    /* if we do not delay here, CMD24 timeout */

    vxbUsDelay (MMCHS_CMD_DELAY);

    return OK;
    }

/*******************************************************************************
*
* omap35xxMmchsClkFreqSetup - setup the clock frequency
*
* This routine setup the clock frequency.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void omap35xxMmchsClkFreqSetup
    (
    SDMMC_HOST * host,
    UINT32       clk
    )
    {
    UINT32 sdClk, value;
    VXB_DEVICE_ID pDev = host->pDev;

    if (clk > MMCHS_MAX_CLK_FREQ)
        clk = MMCHS_MAX_CLK_FREQ;

    if (clk == CLK_FREQ_400K)
        {
        sdClk = (MMCHS_REF_CLK_FREQ / clk);
        }
    else
        {
        sdClk = (MMCHS_REF_CLK_FREQ / clk) + 1;
        }
    sdClk &= MMC_CLKD_MASK;

    value = SYSCTL_ICE_MASK | SYSCTL_CEN_MASK;
    CSR_CLRBIT_4 (pDev, MMCHS_SYSCTL, value);

    value = CSR_READ_4 (pDev, MMCHS_SYSCTL);
    value &= ~(SYSCTL_DTO_MASK | SYSCTL_CLKD_MASK);
    value |= (SYSCTL_DTO_MAX << SYSCTL_DTO_SHIFT) | \
            (sdClk << SYSCTL_CLKD_SHIFT) | SYSCTL_ICE_MASK;
    CSR_WRITE_4 (pDev, MMCHS_SYSCTL, value);

    while (!(CSR_READ_4 (pDev, MMCHS_SYSCTL) & SYSCTL_ICS_MASK));

    CSR_SETBIT_4 (pDev, MMCHS_SYSCTL, SYSCTL_CEN_MASK);
    }

/*******************************************************************************
*
* omap35xxMmchsBusWidthSetup - setup the bus width
*
* This routine setup the bus width.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void omap35xxMmchsBusWidthSetup
    (
    SDMMC_HOST *    host,
    UINT32          width
    )
    {
    if (width == SDMMC_BUS_WIDTH_1BIT)
        {
        CSR_CLRBIT_4 (host->pDev, MMCHS_HCTL, HCTL_DTW_4BIT);
        }
    else if (width == SDMMC_BUS_WIDTH_4BIT)
        {
        CSR_SETBIT_4 (host->pDev, MMCHS_HCTL, HCTL_DTW_4BIT);
        }
    }

/*******************************************************************************
*
* omap35xxMmchsBlkRead - read block from SD/MMC card
*
* This routine reads block from SD/MMC card.
*
* RETURNS: OK or ERROR
*
* ERRNO: N/A
*/

LOCAL STATUS omap35xxMmchsBlkRead
    (
    SDMMC_CARD *    card,
    sector_t        blkNo,
    UINT32          numBlks,
    void *          pBuf
    )
    {
    STATUS rc;
    ULONG ix, round, remain;
    void *bufAddr;
    sector_t blkAddr;

    /* split the transfer */

    round = numBlks / SDHC_MAX_RW_SECTORS;
    remain = numBlks % SDHC_MAX_RW_SECTORS;

    for (ix = 0; ix < round; ix ++)
        {
        blkAddr = blkNo + ix * SDHC_MAX_RW_SECTORS;
        bufAddr = (void *)((ULONG)pBuf + ix * SDHC_MAX_RW_SECTORS *
                      SDMMC_BLOCK_SIZE);

        rc = sdMmcBlkRead (card, blkAddr, SDHC_MAX_RW_SECTORS, bufAddr);
        if (rc == ERROR)
            return ERROR;

        sdMmcStatusWaitReadyForData (card);
        }

     if (remain != 0)
         {
         blkAddr = blkNo + round * SDHC_MAX_RW_SECTORS;
         bufAddr = (void *)((ULONG)pBuf + round * SDHC_MAX_RW_SECTORS *
                       SDMMC_BLOCK_SIZE);

         rc = sdMmcBlkRead (card, blkAddr, remain, bufAddr);
         if (rc == ERROR)
             return ERROR;

         sdMmcStatusWaitReadyForData(card);
         }

    return OK;
    }

/*******************************************************************************
*
* omap35xxMmchsBlkWrite - write block to SD/MMC card
*
* This routine writes block to SD/MMC card.
*
* RETURNS: OK or ERROR
*
* ERRNO: N/A
*/

LOCAL STATUS omap35xxMmchsBlkWrite
    (
    SDMMC_CARD *    card,
    sector_t        blkNo,
    UINT32          numBlks,
    void *          pBuf
    )
    {
    STATUS rc;
    ULONG ix, round, remain;
    sector_t blkAddr;
    void * bufAddr;

    /* split the transfer */

    round = numBlks / SDHC_MAX_RW_SECTORS;
    remain = numBlks % SDHC_MAX_RW_SECTORS;

    for (ix = 0; ix < round; ix ++)
        {
        bufAddr = (void *)((ULONG)pBuf + ix * SDHC_MAX_RW_SECTORS *
                      SDMMC_BLOCK_SIZE);
        blkAddr = blkNo + ix * SDHC_MAX_RW_SECTORS;

        rc = sdMmcBlkWrite (card, blkAddr, SDHC_MAX_RW_SECTORS, bufAddr);
        if (rc == ERROR)
            return ERROR;

        sdMmcStatusWaitReadyForData (card);
        }

    if (remain != 0)
        {
        bufAddr = (void *)((ULONG)pBuf + round * SDHC_MAX_RW_SECTORS *
                      SDMMC_BLOCK_SIZE);
        blkAddr = blkNo + round * SDHC_MAX_RW_SECTORS;

        rc = sdMmcBlkWrite (card, blkAddr, remain, bufAddr);
        if (rc == ERROR)
            return ERROR;

        sdMmcStatusWaitReadyForData(card);
        }

    return OK;
    }

/*******************************************************************************
*
* omap35xxMmchsPioRead - read data from SD/MMC card using PIO
*
* This routine reads data from SD/MMC card using PIO.
*
* RETURNS: OK
*
* ERRNO: N/A
*/

LOCAL STATUS omap35xxMmchsPioRead
    (
    VXB_DEVICE_ID   pDev
    )
    {
    MMCHS_DRV_CTRL * pDrvCtrl = (MMCHS_DRV_CTRL *)pDev->pDrvCtrl;
    UINT32 blkSize;
    char * buffer;
    UINT32 data = 0;
    UINT32 i;

    blkSize = pDrvCtrl->pioDesc.blkSize;
    buffer = pDrvCtrl->pioDesc.bufCur;

    for (i = 0; i < blkSize; i += 4)
        {
        data = PIO_READ_4 (pDev, MMCHS_DATA);
        *(UINT32 *)buffer = data;
        buffer += 4;
        }

    pDrvCtrl->pioDesc.bufCur = buffer;

    OMAP35XX_MMCHS_DBG (MMCHS_DBG_RW,
                "[PIO_READ]: bufOri (%08x) bufCur (%08x)\n",
                pDrvCtrl->pioDesc.bufOri, pDrvCtrl->pioDesc.bufCur,
                0, 0, 0, 0);

    return OK;
    }

/*******************************************************************************
*
* omap35xxMmchsPioWrite - write data to SD/MMC card using PIO
*
* This routine writes data to SD/MMC card using PIO.
*
* RETURNS: OK
*
* ERRNO: N/A
*/

LOCAL STATUS omap35xxMmchsPioWrite
    (
    VXB_DEVICE_ID   pDev
    )
    {
    MMCHS_DRV_CTRL * pDrvCtrl = (MMCHS_DRV_CTRL *)pDev->pDrvCtrl;
    UINT32 blkSize, data, i;
    char * buffer;

    blkSize = pDrvCtrl->pioDesc.blkSize;
    buffer = pDrvCtrl->pioDesc.bufCur;

    for (i = 0; i < blkSize; i += 4)
        {
        data = *(UINT32 *)buffer;
        buffer += 4;
        PIO_WRITE_4 (pDev, MMCHS_DATA, data);
        }

    pDrvCtrl->pioDesc.bufCur = buffer;

    OMAP35XX_MMCHS_DBG (MMCHS_DBG_RW,
                "[PIO_WRITE]: bufOri (%08x) bufCur (%08x)\n",
                pDrvCtrl->pioDesc.bufOri, pDrvCtrl->pioDesc.bufCur,
                0, 0, 0, 0);

    return OK;
    }

/*******************************************************************************
*
* omap35xxMmchsShow - print omap35xxMmchs related information
*
* This routine prints omap35xxMmchs related information.
*
* RETURNS: OK or ERROR
*
* ERRNO: N/A
*/

STATUS omap35xxMmchsShow
    (
    int unit
    )
    {
    VXB_DEVICE_ID       pDev;
    MMCHS_DRV_CTRL *    pDrvCtrl;

    pDev = vxbInstByNameFind (MMCHS_NAME, unit);
    if (pDev == NULL)
        {
        return ERROR;
        }

    pDrvCtrl = (MMCHS_DRV_CTRL *)pDev->pDrvCtrl;

    printf ("[MMCHS]: regBase @ %08x, dmaMode (%d)\n",
            (int)pDrvCtrl->regBase, pDrvCtrl->dmaMode);

    sdMmcHostShow (&pDrvCtrl->host);
    if (pDrvCtrl->cardIns)
        {
        sdMmcCardShow (&pDrvCtrl->card);
        }
    else
        {
        printf ("\nNo SD/MMC card inserted\n");
        }

    return OK;
    }
