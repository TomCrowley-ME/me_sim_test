/* sysEmmcUtil.c - SD card helper routine */

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
#include "sysEmmcUtil.h"

/* defines */

#undef   TIAM335X_DBG_PRINT_ON
#ifdef  TIAM335X_DBG_PRINT_ON

#   define PWR_DBG_IRQ            0x00000001
#   define PWR_DBG_RW             0x00000002
#   define PWR_DBG_XBD            0x00000004
#   define PWR_DBG_ERR            0x00000008
#   define PWR_DBG_ALL            0xffffffff
#   define PWR_DBG_OFF            0x00000000

UINT32 am335xEmmcDbgMask = PWR_DBG_ALL;

IMPORT FUNCPTR _func_logMsg;

#   define TIAM335X_DBG_PRINT(mask, string, a, b, c, d, e, f)          \
        if ((_func_logMsg != NULL) && (am335xEmmcDbgMask & mask))     \
            _func_logMsg(string, a, b, c, d, e, f);
#else
#   define TIAM335X_DBG_PRINT(mask, string, a, b, c, d, e, f)
#endif /* TIAM335X_DBG_PRINT_ON */

/* locals */

LOCAL unsigned int am335xEmmcBase = 0;
LOCAL unsigned int am335xEmmcDmaTxChan = 0;
LOCAL unsigned int am335xEmmcDmaRxChan = 0;
LOCAL TI_EDMA3_CHAN_ALLOC_INFO pEmmcTxInfo, pEmmcRxInfo;
LOCAL TI_EDMA3_PARAM           pEmmcTxRam , pEmmcRxRam;

/*******************************************************************************
*
* sysEmmcPowerInit - initiate tps65950 power chip
*
* This routine initializes tps65950 power chip.
*
* RETURNS: TRUE if power initialization succeeds, else FALSE
*
* ERRNO: N/A
*/

BOOL sysEmmcPowerInit (void)
    {
    VXB_DEVICE_ID pDev;
    SEM_ID devChange;

    pDev = vxbInstByNameFind (MMCHS_NAME, 1);
    if (pDev == NULL)
        {
        TIAM335X_DBG_PRINT (PWR_DBG_ERR,
                "Cannot get the MMCHS instance\n",
                0, 0, 0, 0, 0, 0);

        return FALSE;
        }
    devChange = ((MMCHS_DRV_CTRL *)pDev->pDrvCtrl)->devChange;

    semGive(devChange);

    return TRUE;
    }

/*******************************************************************************
*
* sysEmmcPowerOn - power on MMCHS subsystem
*
* This routine powers on the MMCHS subsystem.
*
* RETURNS: TRUE
*
* ERRNO: N/A
*/

BOOL sysEmmcPowerOn (void)
    {

    UINT32 value;

    /* SD bus power on */

    value = am335xInLong (am335xEmmcBase + MMCHS_HCTL);
    value |= MMCHS_HCTL_SDBP_MASK;
    am335xOutLong (am335xEmmcBase + MMCHS_HCTL, value);

    do
        {
        value = am335xInLong (am335xEmmcBase + MMCHS_HCTL);
        } while (!(value & MMCHS_HCTL_SDBP_MASK));

    return TRUE;
    }

/*******************************************************************************
*
* sysEmmcWpCheck - check if card is write protect
*
* This routine checks if card is write protected.
*
* RETURNS: TRUE if card is write protect, else FALSE
*
* ERRNO: N/A
*/

BOOL sysEmmcWpCheck (void)
    {
    return FALSE;
    }

/*******************************************************************************
*
* sysEmmcDetect - return TRUE because EMMC is always present
*
* RETURNS: TRUE
*
* ERRNO: N/A
*/

BOOL sysEmmcDetect (void)
    {
    return TRUE;
    }

/*******************************************************************************
*
* sysEmmcInit - SD module initilization
*
* This routine powers up the SD module.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

void sysEmmcInit (void)
    {
    omapClockEnable (&mmc1);
    omapPadConfig (mmc1_pads);
    omapPadConfig (xdma_pads);

    am335xEmmcBase        = AM335X_MMC1_SDHC_BASE;
    am335xEmmcDmaTxChan = AM335X_SDTXEVT1;
    am335xEmmcDmaRxChan = AM335X_SDRXEVT1;
    }

/*******************************************************************************
*
* sysEmmcDmaCallback - callback routine when DMA transfer is done
*
* This routine is called when DMA transfer is done.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void sysEmmcDmaCallback
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
* sysEmmcDmaStart - perform DMA read/write operation
*
* This routine performs DMA read/write operation on a given channel.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

STATUS sysEmmcDmaStart
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
                    (pVXB_DMA_COMPLETE_FN)sysEmmcDmaCallback,
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
                    (pVXB_DMA_COMPLETE_FN)sysEmmcDmaCallback,
                    (void *)host);
        }

    if (ret != OK)
        return ERROR;

    return OK;
    }

/*******************************************************************************
*
* sysEmmcDmaChanAlloc - allocate DMA resource
*
* This routine allocates DMA resource
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

STATUS sysEmmcDmaChanAlloc
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

    memset (&pEmmcTxInfo, 0, sizeof (TI_EDMA3_CHAN_ALLOC_INFO));
    memset (&pEmmcTxRam, 0, sizeof (TI_EDMA3_PARAM));

    pEmmcTxInfo.requestedChan = am335xEmmcDmaTxChan;
    pEmmcTxInfo.autoTrigger = TRUE;
    pEmmcTxInfo.usrProvideParam = TRUE;
    pEmmcTxInfo.data = &pEmmcTxRam;

    /* allocate TX channel */

    pDrvCtrl->dmaTxRes = vxbDmaChanAlloc (pInst, 1, 0, &pEmmcTxInfo);
    if (!pDrvCtrl->dmaTxRes)
        {
        TIAM335X_DBG_PRINT (PWR_DBG_RW,
                    "Can not allocate tx dma resource\n",
                    0, 0, 0, 0, 0, 0);
        goto failed;
        }

    memset (&pEmmcRxInfo, 0, sizeof (TI_EDMA3_CHAN_ALLOC_INFO));
    memset (&pEmmcRxRam, 0, sizeof (TI_EDMA3_PARAM));

    pEmmcRxInfo.requestedChan = am335xEmmcDmaRxChan;
    pEmmcRxInfo.autoTrigger = TRUE;
    pEmmcRxInfo.usrProvideParam = TRUE;
    pEmmcRxInfo.data = &pEmmcRxRam;

    /* allocate RX channel */

    pDrvCtrl->dmaRxRes = vxbDmaChanAlloc (pInst, 1, 0, &pEmmcRxInfo);
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
* sysEmmcDmaChanFree - free DMA resource
*
* This routine frees DMA resource
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

void sysEmmcDmaChanFree
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
