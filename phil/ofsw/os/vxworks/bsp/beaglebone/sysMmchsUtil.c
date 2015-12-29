/* sysMmchsUtil.c - SD card helper routine */

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
01a,10may12,my_  written from ti_dm81xx_evm 01c.
*/

/* includes */

#include <vxWorks.h>
#include <stdlib.h>
#include <string.h>
#include <cacheLib.h>
#include <semLib.h>
#include <intLib.h>
#include <hwif/util/vxbParamSys.h> /* for vxbInstByNameFind */
#include <hwif/util/vxbDmaLib.h>
#include <../src/hwif/h/storage/vxbSdMmcLib.h>
#include <../src/hwif/h/storage/vxbOmap35xxMmchs.h>
#include <../src/hwif/h/dmaCtlr/vxbTiEdma3.h>
#include "sysMmchsUtil.h"

/* defines */

#undef  TIAM335X_DBG_PRINT_ON
#ifdef  TIAM335X_DBG_PRINT_ON

#   define PWR_DBG_IRQ            0x00000001
#   define PWR_DBG_RW             0x00000002
#   define PWR_DBG_XBD            0x00000004
#   define PWR_DBG_ERR            0x00000008
#   define PWR_DBG_ALL            0xffffffff
#   define PWR_DBG_OFF            0x00000000

UINT32 am335xDbgMask = PWR_DBG_ALL;

IMPORT FUNCPTR _func_logMsg;

#   define TIAM335X_DBG_PRINT(mask, string, a, b, c, d, e, f)          \
        if ((_func_logMsg != NULL) && (am335xDbgMask & mask))     \
            _func_logMsg(string, a, b, c, d, e, f);
#else
#   define TIAM335X_DBG_PRINT(mask, string, a, b, c, d, e, f)
#endif /* TIAM335X_DBG_PRINT_ON */

/* locals */

LOCAL unsigned int am335xBase = 0;
LOCAL unsigned int am335xSdcdPin = 0;
LOCAL unsigned int am335xSdDmaTxChan = 0;
LOCAL unsigned int am335xSdDmaRxChan = 0;
LOCAL TI_EDMA3_CHAN_ALLOC_INFO pTxInfo, pRxInfo;
LOCAL TI_EDMA3_PARAM           pTxRam , pRxRam;

#define am35xx_gpio_int0a 96
#define am35xx_gpio_int0b 97

/*******************************************************************************
*
* powerIsr - interrupt service routine for tps65950 power chip
*
* This routine handles interrupts of tps65950.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void powerIsr
    (
    SEM_ID devChange
    )
    {
    unsigned int val;
    static BOOL detectSts = FALSE;

    val = am335xInLong (AM335X_GPIO0_BASE + AM335X_GPIO_IRQSTATUS0);

    if (val & am335xSdcdPin)
       {
       if (detectSts != sysCardDetect())
           {
           detectSts = sysCardDetect();

           TIAM335X_DBG_PRINT (PWR_DBG_IRQ,
                   "detect card %s \n",
                   detectSts ? "insertion" : "removed", 0, 0, 0, 0, 0);
           semGive (devChange);
           }
        }
    else
        {
        TIAM335X_DBG_PRINT (PWR_DBG_IRQ,
                "Unknown interrupt = 0x%x \n",
                val, 0, 0, 0, 0, 0);
        }

    am335xOutLong (AM335X_GPIO0_BASE + AM335X_GPIO_IRQSTATUS0, val);
    }

/*******************************************************************************
*
* sysCardPowerInit - initiate tps65950 power chip
*
* This routine initializes tps65950 power chip.
*
* RETURNS: TRUE if power initialization succeeds, else FALSE
*
* ERRNO: N/A
*/

BOOL sysCardPowerInit (void)
    {
    VXB_DEVICE_ID pDev;
    SEM_ID devChange;
    unsigned int val;

    /* enable interrupt of card detect */

    val = am335xInLong (AM335X_GPIO0_BASE + AM335X_GPIO_IRQSTATUS_SET0);
    am335xOutLong (AM335X_GPIO0_BASE + AM335X_GPIO_IRQSTATUS_SET0,
                     val | am335xSdcdPin);

    val = am335xInLong (AM335X_GPIO0_BASE + AM335X_GPIO_RISINGDETECT);
    am335xOutLong (AM335X_GPIO0_BASE + AM335X_GPIO_RISINGDETECT,
                     val | am335xSdcdPin);

    val = am335xInLong (AM335X_GPIO0_BASE + AM335X_GPIO_FALLINGDETECT);
    am335xOutLong (AM335X_GPIO0_BASE + AM335X_GPIO_FALLINGDETECT,
                     val | am335xSdcdPin);

    /* Connect card detect interrupt */

    pDev = vxbInstByNameFind (MMCHS_NAME, 0);
    if (pDev == NULL)
        {
        TIAM335X_DBG_PRINT (PWR_DBG_ERR,
                "Cannot get the MMCHS instance\n",
                0, 0, 0, 0, 0, 0);

        return FALSE;
        }
    devChange = ((MMCHS_DRV_CTRL *)pDev->pDrvCtrl)->devChange;

    if (intConnect ((VOIDFUNCPTR *)INUM_TO_IVEC (am35xx_gpio_int0a), powerIsr,
                    (_Vx_usr_arg_t)devChange)
        != OK)
        {
        return FALSE;
        }

    /* Enable card detect interrupt */

    if (intEnable (am35xx_gpio_int0a) != OK)
        {
        return FALSE;
        }

    return TRUE;
    }

/*******************************************************************************
*
* sysCardPowerOn - power on MMCHS subsystem
*
* This routine powers on the MMCHS subsystem.
*
* RETURNS: TRUE
*
* ERRNO: N/A
*/

BOOL sysCardPowerOn (void)
    {

    UINT32 value;

    /* SD bus power on */

    value = am335xInLong (am335xBase + MMCHS_HCTL);
    value |= MMCHS_HCTL_SDBP_MASK;
    am335xOutLong (am335xBase + MMCHS_HCTL, value);

    do
        {
        value = am335xInLong (am335xBase + MMCHS_HCTL);
        } while (!(value & MMCHS_HCTL_SDBP_MASK));

    return TRUE;
    }

/*******************************************************************************
*
* sysCardDetect - check if card is present
*
* This routine checks if card is present.
*
* RETURNS: TRUE if card is present, else FALSE
*
* ERRNO: N/A
*/

BOOL sysCardDetect (void)
    {
    unsigned int val;

    val = am335xInLong (AM335X_GPIO0_BASE + AM335X_GPIO_DATAIN);

    if (!(val & am335xSdcdPin))
        return TRUE;
    else
        return FALSE;
    }

/*******************************************************************************
*
* sysCardWpCheck - check if card is write protect
*
* This routine checks if card is write protected.
*
* RETURNS: TRUE if card is write protect, else FALSE
*
* ERRNO: N/A
*/

BOOL sysCardWpCheck (void)
    {
    return FALSE;
    }

/*******************************************************************************
*
* sysMmchsInit - SD module initilization
*
* This routine powers up the SD module.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

void sysMmchsInit (void)
    {
    omapClockEnable (&mmc0);
    omapPadConfig (mmc0_pads);
    omapPadConfig (xdma_pads);

    am335xBase        = AM335X_MMC0_SDHC_BASE;
    am335xSdcdPin     = AM335X_MMC0_SDCD;
    am335xSdDmaTxChan = AM335X_SDTXEVT0;
    am335xSdDmaRxChan = AM335X_SDRXEVT0;
    }

/*******************************************************************************
*
* sysCardDmaCallback - callback routine when DMA transfer is done
*
* This routine is called when DMA transfer is done.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void sysCardDmaCallback
    (
    void * pData,
    UINT32 a,
    UINT32 b
    )
    {
    UINT32 count;
    SDMMC_HOST * host = (SDMMC_HOST *)pData;
    SDMMC_CMD cmd = host->cmdIssued;
    MMCHS_DRV_CTRL * pDrvCtrl = host->pDev->pDrvCtrl;
    TI_EDMA3_PARAM * pChanParam =
        ((TI_EDMA3_CHAN *)(pDrvCtrl->dmaRxRes->pDmaChan))->param;

    /* run in interrupt context */

    TIAM335X_DBG_PRINT (PWR_DBG_IRQ,
                "DMA channel callback function\n",
                0, 0, 0, 0, 0, 0);

    if (cmd.cmdData.isRead && cmd.hasData)
        {
        count =
            pChanParam->acnt * pChanParam->bcnt * pChanParam->ccnt;

        cacheInvalidate (DATA_CACHE, (void *)pChanParam->dst, count);
        }
    }

/*******************************************************************************
*
* sysCardDmaStart - perform DMA read/write operation
*
* This routine performs DMA read/write operation on a given channel.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

STATUS sysCardDmaStart
    (
    SDMMC_HOST *    host,
    SDMMC_CMD *     cmd
    )
    {
    STATUS ret;
    VXB_DEVICE_ID pDev;
    MMCHS_DRV_CTRL * pDrvCtrl;
    TI_EDMA3_CHAN * pChan;
    TI_EDMA3_PARAM * param;

    pDev = host->pDev;
    pDrvCtrl = (MMCHS_DRV_CTRL *)pDev->pDrvCtrl;

    if (cmd->cmdData.isRead)
        {
        pChan = (TI_EDMA3_CHAN *)pDrvCtrl->dmaRxRes->pDmaChan;
        param = pChan->param;

        param->src     = ((UINT32)MMCHS_BAR(pDev) + MMCHS_DATA);
        param->dst     = (UINT32)cmd->cmdData.buffer;
        param->acnt    = sizeof (UINT32);
        param->bcnt    = cmd->cmdData.blkSize / sizeof (UINT32);
        param->ccnt    = cmd->cmdData.blkNum;
        param->srcbidx = 0x0;
        param->dstbidx = sizeof (UINT32);
        param->srccidx = 0x0;
        param->dstcidx = cmd->cmdData.blkSize;
        param->bcntrld = 0;
        param->opt     = TI_EDMA3_SYNCDIM_AB |
                         TI_EDMA3_OPT_SAM_CA |
                         TI_EDMA3_TCINTEN    |
                         TI_EDMA3_FIFO_WIDTH_32;
        param->link    = TI_EDMA3_LINK_END;

        ret = vxbDmaRead (pDrvCtrl->dmaRxRes, 0, 0, 0, 0, 0,
                    (pVXB_DMA_COMPLETE_FN)sysCardDmaCallback,
                    (void *)host);
        }
    else
        {

        pChan = (TI_EDMA3_CHAN *)pDrvCtrl->dmaTxRes->pDmaChan;
        param = pChan->param;

        param->src     = (UINT32)cmd->cmdData.buffer;
        param->dst     = ((UINT32)MMCHS_BAR(pDev) + MMCHS_DATA);
        param->acnt    = sizeof (UINT32);
        param->bcnt    = cmd->cmdData.blkSize / sizeof (UINT32);
        param->ccnt    = cmd->cmdData.blkNum;
        param->srcbidx = sizeof (UINT32);
        param->dstbidx = 0x0;
        param->srccidx = cmd->cmdData.blkSize;
        param->dstcidx = 0x0;
        param->bcntrld = 0x0;
        param->opt     = TI_EDMA3_SYNCDIM_AB |
                         TI_EDMA3_OPT_DAM_CA |
                         TI_EDMA3_TCINTEN    |
                         TI_EDMA3_FIFO_WIDTH_32;
        param->link    = TI_EDMA3_LINK_END;

        cacheFlush (DATA_CACHE, cmd->cmdData.buffer,
                        cmd->cmdData.blkSize * cmd->cmdData.blkNum);

        ret = vxbDmaWrite (pDrvCtrl->dmaTxRes, 0, 0, 0, 0, 0,
                    (pVXB_DMA_COMPLETE_FN)sysCardDmaCallback,
                    (void *)host);
        }

    if (ret != OK)
        return ERROR;

    return OK;
    }

/*******************************************************************************
*
* sysCardDmaChanAlloc - allocate DMA resource
*
* This routine allocates DMA resource
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

STATUS sysCardDmaChanAlloc
    (
    void * pCookie
    )
    {
    VXB_DEVICE_ID pInst;
    MMCHS_DRV_CTRL * pDrvCtrl = (MMCHS_DRV_CTRL *)pCookie;

    /*
     * we may enter here with dmaTxRes/dmaRxRes not NULL. For this
     * case we just return OK and do not allocate anything
     */

    if (pDrvCtrl->dmaTxRes != NULL || pDrvCtrl->dmaRxRes != NULL)
        {
        TIAM335X_DBG_PRINT (PWR_DBG_RW,
                    "warning: dma channels already allocated\n",
                    0, 0, 0, 0, 0, 0);
        return OK;
        }

    /* find EDMA3 controller instance */

    pInst = vxbInstByNameFind ("tiedma3", 0);
    if (!pInst)
        {
        TIAM335X_DBG_PRINT (PWR_DBG_RW,
                    "Can not find DMA controller instance\n",
                    0, 0, 0, 0, 0, 0);
        return ERROR;
        }

    memset (&pTxInfo, 0, sizeof (TI_EDMA3_CHAN_ALLOC_INFO));
    memset (&pTxRam, 0, sizeof (TI_EDMA3_PARAM));

    pTxInfo.requestedChan = am335xSdDmaTxChan;
    pTxInfo.autoTrigger = TRUE;
    pTxInfo.usrProvideParam = TRUE;
    pTxInfo.data = &pTxRam;

    /* allocate TX channel */

    pDrvCtrl->dmaTxRes = vxbDmaChanAlloc (pInst, 1, 0, &pTxInfo);
    if (!pDrvCtrl->dmaTxRes)
        {
        TIAM335X_DBG_PRINT (PWR_DBG_RW,
                    "Can not allocate tx dma resource\n",
                    0, 0, 0, 0, 0, 0);
        goto failed;
        }

    memset (&pRxInfo, 0, sizeof (TI_EDMA3_CHAN_ALLOC_INFO));
    memset (&pRxRam, 0, sizeof (TI_EDMA3_PARAM));

    pRxInfo.requestedChan = am335xSdDmaRxChan;
    pRxInfo.autoTrigger = TRUE;
    pRxInfo.usrProvideParam = TRUE;
    pRxInfo.data = &pRxRam;

    /* allocate RX channel */

    pDrvCtrl->dmaRxRes = vxbDmaChanAlloc (pInst, 1, 0, &pRxInfo);
    if (!pDrvCtrl->dmaRxRes)
        {
        TIAM335X_DBG_PRINT (PWR_DBG_RW,
                    "Can not allocate rx dma resource\n",
                    0, 0, 0, 0, 0, 0);
        goto failed;
        }

    return OK;

failed:

    if (pDrvCtrl->dmaTxRes)
        {
        vxbDmaChanFree (pDrvCtrl->dmaTxRes);
        pDrvCtrl->dmaTxRes = NULL;
        }

    if (pDrvCtrl->dmaRxRes)
        {
        vxbDmaChanFree (pDrvCtrl->dmaRxRes);
        pDrvCtrl->dmaRxRes = NULL;
        }

    return ERROR;
    }

/*******************************************************************************
*
* sysCardDmaChanFree - free DMA resource
*
* This routine frees DMA resource
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

void sysCardDmaChanFree
    (
    void * pCookie
    )
    {
    if (pCookie)
        {
        MMCHS_DRV_CTRL * pDrvCtrl = (MMCHS_DRV_CTRL *)pCookie;

        vxbDmaChanFree(pDrvCtrl->dmaTxRes);

        vxbDmaChanFree(pDrvCtrl->dmaRxRes);

        pDrvCtrl->dmaTxRes = pDrvCtrl->dmaRxRes = NULL;
        }
    }
