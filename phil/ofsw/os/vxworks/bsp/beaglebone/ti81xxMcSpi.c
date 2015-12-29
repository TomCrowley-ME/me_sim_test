/* ti81xxMcSpi.c - TI DM81XX McSPI routines */

/*
 * Copyright (c) 2011 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify or otherwise make use
 * of this software may be licensed only pursuant to the terms
 * of an applicable Wind River license agreement.
 */

/*
modification history
--------------------
01a,15aug11,clx created from mst_omap3530evm BSP
*/
#include <vxWorks.h>
#include <semLib.h>
#include "config.h"
#include "ti81xxMcSpi.h"
#include "sysGpio.h"

LOCAL SEM_ID mcSpiSem[NR_SPIS] = {NULL};

LOCAL STATUS ti81xxMcSpiSanityCheck
    (
    int module,       /* SPI module number */
    int channel       /* SPI channel number */
    );
LOCAL STATUS ti81xxMcSpiWaitForStatus
    (
    int module,       /* module to be waited */
    int channel,      /* channel to be waited */
    int status        /* specific status to be waiting for */
    );

LOCAL UINT32 ti81xxSpiBase[NR_SPIS] = {
    OMAP_SPI_0,
    OMAP_SPI_1
};

/*******************************************************************************
*
* ti81xxSpiInit - Initialize McSPI Module.
*
* This routine initializes McSPI module
*
* RETURNS: OK or ERROR if initialisation fails
*/

STATUS ti81xxMcSpiInit
    (
    int module,     /* SPI module number */
    int cfgValue    /* value used to configure the module */
    )
    {
    volatile UINT32 val;

    if (module < 0 || module >= NR_SPIS)
        {
        TI81XX_SPI_LOG("%s : invalid parameter.\n", __FUNCTION__, 0, 0, 0, 0, 0);
        return (ERROR);
        }

    if (mcSpiSem[module] == NULL)
        mcSpiSem[module] = semMCreate (SEM_Q_PRIORITY | SEM_INVERSION_SAFE);

    semTake(mcSpiSem[module], WAIT_FOREVER);

    /* initialiate a software reset */

    TI81XX_SPI_REGISTER_WRITE(module, MCSPI_SYSCONFIG, TI81XX_SOFTRESET);

    /* wait for SPI module reset done */

    do
        {
        val = TI81XX_SPI_REGISTER_READ(module, MCSPI_SYSSTATUS);
        } while ((val & 0x1) != 0x1);

    /* disable SPI wakeup event */

    TI81XX_SPI_REGISTER_WRITE(module, MCSPI_WAKEUPENABL, 0x0);

    /* disable all SPI interrupts */

    TI81XX_SPI_REGISTER_WRITE(module, MCSPI_IRQENABLE, 0x0);

    /* clear previouly pending IRQ status */

    TI81XX_SPI_REGISTER_WRITE(module, MCSPI_IRQSTATUS, 0xffffffff);

    /* configure module with supplied value */

    TI81XX_SPI_REGISTER_WRITE(module, MCSPI_MODULCTRL, cfgValue);

    semGive(mcSpiSem[module]);

    return (OK);
    }

/*******************************************************************************
*
* ti81xxMcSpiSanityCheck - Parameter check.
*
* This routine validates input parameters
*
* RETURNS: OK or ERROR if parameters are invalid
*/

LOCAL STATUS ti81xxMcSpiSanityCheck
    (
    int module,  /* SPI module number */
    int channel  /* SPI channel number */
    )
    {
    if (module < 0 || module >= NR_SPIS)
        return (ERROR);

    if ((module == 0) && ((channel < 0) || (channel > 3)))
        return (ERROR);

    if (((module == 1) || (module == 2)) && ((channel < 0) || (channel > 1)))
        return (ERROR);

    if ((module == 3) && (channel != 0))
        return (ERROR);

    if (mcSpiSem[module] == NULL)
        return (ERROR);

    return (OK);
    }

/*******************************************************************************
*
* ti81xxMcSpiWaitForStatus - wait for McSpi channel specific status
*
* This routine waits for McSpi channel specific status
*
* RETURNS: OK, or ERROR if timeout
*/

LOCAL STATUS ti81xxMcSpiWaitForStatus
    (
    int module,             /* module to be waited */
    int channel,            /* channel to be waited */
    int status              /* specific status to be waiting for */
    )
    {
    volatile int tempValue;
    UINT32 timeout = 0;
    STATUS sts = OK;

    TI81XX_SPI_LOG("waiting for MCSPI module 0x%x, channel 0x%x ..",
                    module, channel, 0, 0, 0, 0);

    do
        {
        tempValue = TI81XX_SPI_REGISTER_READ(module, MCSPI_CHxSTAT(channel));
        }while ((tempValue & status) != status);

    if (timeout >= MCSPI_TIMEOUT)
        {
        TI81XX_SPI_LOG("timeout\n",0,0,0,0,0,0);
        sts = ERROR;
        }
    else
        {
        TI81XX_SPI_LOG("ok\n",0,0,0,0,0,0);
        }

    return sts;
    }

/*******************************************************************************
*
* ti81xxSpiChannelConfig - Configure McSPI channel.
*
* This routine configures an McSPI channel
*
* RETURNS: OK or ERROR if configuration fails
*/

STATUS ti81xxSpiChannelConfig
    (
    int module,     /* SPI module number */
    int channel,    /* SPI channel number */
    int cfgValue    /* SPI channel configure value */
    )
    {
    if (ti81xxMcSpiSanityCheck(module, channel) == ERROR)
        {
        TI81XX_SPI_LOG("%s : invalid parameter.\n", __FUNCTION__, 0, 0, 0, 0, 0);
        return (ERROR);
        }

    semTake(mcSpiSem[module], WAIT_FOREVER);

    TI81XX_SPI_REGISTER_WRITE(module, MCSPI_CHxCONF(channel), cfgValue);

    semGive(mcSpiSem[module]);

    return (OK);

    }

/*******************************************************************************
*
* ti81xxSpiStart - Start a transmission through McSPI Interface
*
* This routine takes the supplied CS pin # low and enables the SPI channel
*/

void ti81xxSpiStart
    (
	int      module,    /* SPI module number */
	int      channel,   /* SPI channel number */
    UINT32   csPin      /* sysGpio-compatible pin number */
    )
	{
	/* Take hold of this module's mutex for the duration of the transfer */
	semTake(mcSpiSem[module], WAIT_FOREVER);

    TI81XX_SPI_REGISTER_WRITE(module, MCSPI_CHxCONF(channel),
                TI81XX_SPI_FORCE_SPIEN |
               (TI81XX_SPI_REGISTER_READ(module, MCSPI_CHxCONF(channel))));

	if (csPin != TI81XX_SPI_AUTO_SPIEN) {
		sysGpioClear(csPin);
	}

    TI81XX_SPI_REGISTER_WRITE(module, MCSPI_CHxCTRL(channel), TI81XX_SPI_ENABLE);
	}

/*******************************************************************************
*
* ti81xxSpiStop - Stop a transmission through McSPI Interface
*
* This routine takes the supplied CS pin # high and disables the SPI channel
*/

void ti81xxSpiStop
    (
	int      module,  /* SPI module number */
	int      channel, /* SPI channel number */
    UINT32   csPin    /* sysGpio-compatible pin number */
    )
	{
	TI81XX_SPI_REGISTER_WRITE(module, MCSPI_CHxCTRL(channel), TI81XX_SPI_DISABLE);

	if (csPin != TI81XX_SPI_AUTO_SPIEN) {
		sysGpioSet(csPin);
	}
    TI81XX_SPI_REGISTER_WRITE(module, MCSPI_CHxCONF(channel),
               (~TI81XX_SPI_FORCE_SPIEN) &
               (TI81XX_SPI_REGISTER_READ(module, MCSPI_CHxCONF(channel))));

    /* Give back the module semaphore now that we're done */
    semGive(mcSpiSem[module]);
	}

/*******************************************************************************
*
* ti81xxSpiXfer - Read & Write data through McSPI Interface.
*
* This routine reads and writes data through McSPI Interface
*
* RETURNS: OK or ERROR if the operation fails
*/

STATUS ti81xxSpiXfer
    (
    int      module,  /* SPI module number (0, 1, 2, 3) */
    int      channel, /* SPI channel number */
    char *   data,    /* data to be transferred */
    UINT32   len,     /* data length */
    int      flag     /* read or write */
    )
    {
    int i;

    if ((data == NULL) || (len == 0))
        {
        TI81XX_SPI_LOG("%s : invalid parameter.\n", __FUNCTION__, 0, 0, 0, 0, 0);
        return (ERROR);
        }

    if (ti81xxMcSpiSanityCheck(module, channel) == ERROR)
        {
        TI81XX_SPI_LOG("%s : invalid parameter.\n", __FUNCTION__, 0, 0, 0, 0, 0);
        return (ERROR);
        }
    /*
     * Start off by taking the module mutex. If a transfer has been properly
     * started by a preceding ti81xxSpiStart call, we should already have a
     * hold on this, and will receive a recursive hold throughout this function.
     * Otherwise, this will halt anybody trying to do an invalid transfer on
     * an already active module.
     */
    semTake(mcSpiSem[module], WAIT_FOREVER);

    /* Read or Write specific number data */

    if (flag & TI81XX_SPI_WRITE)
        {
        /* Wait for TX register to be empty */
        if (ti81xxMcSpiWaitForStatus(module, channel,
                                          TI81XX_SPI_CHSTAT_TXS) == ERROR)
            {
            goto error;
            }
        for (i = 0; i < len; i++)
            {
            TI81XX_SPI_REGISTER_WRITE(module, MCSPI_TXx(channel), data[i]);

            /* Wait for the new word to be copied into the shift register */
            /* Wait for TX register to be empty */
            if (ti81xxMcSpiWaitForStatus(module, channel,
                                              TI81XX_SPI_CHSTAT_RXS) == ERROR)
                {
                goto error;
                }
            TI81XX_SPI_REGISTER_READ(module, MCSPI_RXx(channel));
           }
        }
    else if (flag & TI81XX_SPI_READ)
        {
        /* Wait for TX register to be empty to begin */
        if (ti81xxMcSpiWaitForStatus(module, channel,
                                          TI81XX_SPI_CHSTAT_TXS) == ERROR)
            {
            goto error;
            }
        for (i = 0; i < len; i++)
            {
            TI81XX_SPI_REGISTER_WRITE(module, MCSPI_TXx(channel), 0);

            /* Wait for the new word to be copied into the shift register */
            if (ti81xxMcSpiWaitForStatus(module, channel,
                                              TI81XX_SPI_CHSTAT_RXS) == ERROR)
                {
                goto error;
                }
            data[i] = TI81XX_SPI_REGISTER_READ(module, MCSPI_RXx(channel));
           }
        }
    else
        {
        goto error;
        }
    
    /*
     * Give back the module mutex for this call to this function.
     */
    semGive(mcSpiSem[module]);

    return (OK);

error:

    TI81XX_SPI_LOG("%s : ti81xxSpiXfer Error.\n", __FUNCTION__, 0, 0, 0, 0, 0);

    semGive(mcSpiSem[module]);

    return (ERROR);
    }
