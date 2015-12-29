/* usrAppInit.c - stub application initialization routine */

/* Copyright (c) 1998,2006,2011 Wind River Systems, Inc.
 * The right to copy, distribute, modify or otherwise make use
 * of this software may be licensed only pursuant to the terms
 * of an applicable Wind River license agreement.
 */

/*
modification history
--------------------
01c,26may11,pcs  Add stubs corresponding to the boot sequence hook callout
                 mechanism.
01b,16mar06,jmt  Add header file to find USER_APPL_INIT define
01a,02jun98,ms   written
*/

/*
DESCRIPTION
Initialize user application code.
*/ 

#include <vxWorks.h>
#if defined(PRJ_BUILD)
#include "prjParams.h"
#endif /* defined PRJ_BUILD */

#include <taskLib.h>
#include <stdio.h>
#include <unistd.h>

#include "ti81xxMcSpi.h"
#include "genericSpiDrv.h"
#include "sysGpio.h"

/******************************************************************************
*
* usrAppInit - initialize the users application
*/ 
void usrAppInit (void)
    {
#ifdef	USER_APPL_INIT
	USER_APPL_INIT;		/* for backwards compatibility */
#endif

    }

#ifdef INCLUDE_USER_PRE_KERNEL_APPL_INIT
/******************************************************************************
*
* usrPreKernelAppInit - initialize the users pre-kernel application code
*/ 

void usrPreKernelAppInit (void)
    {

    /*
     * Add application specific code here.
     * No kernel feature is available at this point.
     */

    }
#endif

#ifdef INCLUDE_USER_POST_KERNEL_APPL_INIT
/******************************************************************************
*
* usrPostKernelAppInit - initialize the users post-kernel application code
*/ 

void usrPostKernelAppInit (void)
    {

    /*
     * Add application specific code here.
     * Core kernel feature is available at this point.
     * IO system and Network is not available.
     * kernel features dependent on system clock or timer not available.
     */

    }
#endif


#ifdef INCLUDE_USER_PRE_NETWORK_APPL_INIT
/******************************************************************************
*
* usrPreNetworkAppInit - initialize the users pre-network application code
*/ 

void usrPreNetworkAppInit (void)
    {

    /*
     * Add application specific code here.
     * Core kernel feature and IO system is available at this point.
     * Network is not available.
     */

    /*
     * Add application specific code here.
     * Core kernel feature, Network, IO system is available at this point.
     * User tools not available.
     */

    int module = 1;
    int channel = 0;

    /*
     * Drop the priority of tIsr0 since it's only being used by the UART driver
     * and we don't want the UART to preempt the FSW
     */
    TASK_ID tisr0_id = taskNameToId("tIsr0");
    taskPrioritySet(tisr0_id, 254);
    
    /* Set up the shared SPI port used by all of the microcontrollers */
    ti81xxMcSpiInit(module, TI81XX_SPI_MASTER | TI81XX_SPI_FUNC | TI81XX_SPI_SINGLE | TI81XX_SPI_3PIN);

    ti81xxSpiChannelConfig(module, channel, TI81XX_SPI_XFER    |
                                            TI81XX_SPI_DPE0    |
                                            TI81XX_SPI_EPOL    |
                                            TI81XX_SPI_CLKG    |
                                            TI81XX_SPI_CLKD(2) |
                                            TI81XX_SPI_WL(8)   |
                                            TI81XX_SPI_TURBO   |
                                            TI81XX_SPI_PHA); /* 0x20103c1 */
    }
#endif
