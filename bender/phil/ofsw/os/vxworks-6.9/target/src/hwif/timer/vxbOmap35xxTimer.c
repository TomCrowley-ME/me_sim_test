/* vxbOmap35xxTimer.c - TI OMAP35xx processor timer library */

/*
 * Copyright (c) 2008-2011, 2013-2014 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify or otherwise make use
 * of this software may be licensed only pursuant to the terms
 * of an applicable Wind River license agreement.
 *
 */

/*
modification history
--------------------
15apr14,c_l  fix clock frequency for ti81xx. (VXW6-81778)
01l,08mar13,c_l  remove build warnings (WIND00406706)
01k,25oct11,rec  WIND313562 - omap35xxOneShotEnable rollover bug
01j,11oct11,rec  WIND00308647 - omap35xxOneShotDisable misses rollover
01i,13jul11,clx  add dm81xx timer support
01h,08mar11,bsk  fix compiler warnings
01g,28feb11,rec  WIND00257399 - fix pointer dereference.
                 WIND00257405 - invalid return value
01f,22feb11,bsk  fix format and spell errors for doc gen
01e,06oct10,rec  add tickless-idle
01d,29oct09,j_b  fix omap35xxTimerCountGet to account for initial load value
                 (WIND00188725)
01c,02mar09,m_h  cleanup
01b,25nov08,m_h  support for more than one timer
01a,08jul08,m_h  created
*/

/*
DESCRIPTION
This is the vxBus compliant timer driver which implements the functionality
specific to OMAP35xx timers.

A timer-specific data structure (struct omap35xxTimerData) is maintained
within this driver.  This is given as 'pCookie' in omap35xxTimerAllocate() and
is used from then on by the Timer Abstraction Layer or application to
communicate with this driver.

The driver implements all the vxBus driver-specific initialization
routines like omap35xxTimerInstInit(), omap35xxTimerInstInit2() and
omap35xxTimerInstConnect().

A variable of type 'struct omap35xxTimerData' is allocated for
a timer device and stored in 'pInst->pDrvCtrl' in omap35xxTimerInstInit()

omap35xxTimerInstInit2() hooks an ISR to be used for the timer device.

A method for methodId VXB_METHOD_TIMER_FUNC_GET is implemented in
this driver and is used by the Timer Abstraction Layer or application to
retrieve the characteristics of a timer device.  A pointer to
'struct vxbTimerFunctionality' is allocated by the Timer Abstraction
Layer or application and pointer to this structure is given as the parameter
to this method.  The timer driver populates this data structure with the
features of the timer device.

Hardware Functional Description:

Each GP timer contains a free-running upward counter with autoreload
capability on overflow. The timer counter can be read and written
on-the-fly (while counting). Each GP timer includes compare logic to
allow an interrupt event on a programmable counter matching value. A
dedicated output signal can be pulsed or toggled on either an overflow
or a match event. This offers time-stamp trigger signaling or PWM
signal sources. A dedicated input signal can be used to trigger an
automatic timer counter capture or an interrupt event on a
programmable input signal transition type. A programmable clock
divider (prescaler) allows reduction of the timer input clock
frequency. All internal timer interrupt sources are merged into one
module interrupt line and one wake-up line. Each internal interrupt
source can be independently enabled/disabled with a dedicated bit of
the GPTi.TIER register for the interrupt features and a dedicated bit
of the GPTi.TWER register for the wakeup. In addition, GPTIMER1,
GPTIMER2, and GPTIMER10 have implemented a mechanism to generate an
accurate tick interrupt.

Note: many of the above features are not implemented in this driver.  This
driver provides functionality for timestamp and periodic interrupt
capabilities.

Note: Although some infrastructure is built into this driver to lay the
groundwork for supporting power management, the full capabilities of
power management supported by the hardware are not supported by this driver.

*/

/* includes */

#include <vxWorks.h>
#include <vxBusLib.h>
#include <string.h>
#include <hwif/util/hwMemLib.h>
#include <hwif/vxbus/vxBus.h>
#include <hwif/vxbus/vxbPlbLib.h>
#include <hwif/vxbus/hwConf.h>
#include <vxbTimerLib.h>
#include <../src/hwif/h/vxbus/vxbAccess.h>
#include <intLib.h>
#include <logLib.h> /* for logMsg */

#include <hwif/timer/vxbOmap35xxTimer.h>
#include <windPwrLib.h>

IMPORT struct  vxbTimerFunctionality *  pClkTimer;

/* VxBus-compliant register access macros */

#define CSR_READ_4(pDev, addr)                                \
    vxbRead32 ((pDev->vxbHandle),                             \
               (UINT32 *)((char *)(pDev->baseAddress) + addr))

#define CSR_WRITE_4(pDev, addr, data)                         \
    vxbWrite32 ((pDev->vxbHandle),                            \
                (UINT32 *)((char *)(pDev->baseAddress) + addr), data)

#define OMAP35XX_TIMER_REG_SYNC_WRITE(pTimerData, reg, result, syncBit)        \
        do {                                                                   \
            if (pTimerData->isPosted == TRUE)                                  \
                {                                                              \
                UINT32 __val;                                                     \
                do                                                             \
                    {                                                          \
                    __val = CSR_READ_4 (pTimerData, TIMER_TWPS_OFFSET) & 0xff; \
                    } while (__val & syncBit);                                 \
                }                                                              \
            CSR_WRITE_4 (pTimerData, reg, result);                             \
        } while (0)

#define OMAP35XX_TIMER_REG_SYNC_READ(pTimerData, reg, result, syncBit)         \
        do {                                                                   \
            if (pTimerData->isPosted == TRUE)                                  \
                {                                                              \
                UINT32 __val;                                                     \
                do                                                             \
                    {                                                          \
                    __val = CSR_READ_4 (pTimerData, TIMER_TWPS_OFFSET) & 0xff; \
                    } while (__val & syncBit);                                 \
                }                                                              \
            result = CSR_READ_4 (pTimerData, reg);                             \
        } while (0)

#define OMAP35XX_TIMER_REG_READ(pTimerData, reg, result)      \
    do {                                                      \
        result = CSR_READ_4(pTimerData, reg);                 \
    } while (FALSE)

#define OMAP35XX_TIMER_REG_WRITE(pTimerData, reg, result)     \
    do {                                                      \
        CSR_WRITE_4(pTimerData, reg, result);                 \
    } while (FALSE)

#define REG_SYNC \
    do {OMAP35XX_TIMER_REG_READ (pTimerData, TIMER_TWPS_OFFSET, \
        regVal); \
    } while (regVal != 0x00000000)

#define OMAP35XX_MAX_COUNT_VAL      0xffffffff
#define OMAP35XX_MAX_MATCH_VAL      0xffffff
#define TIMER_NAME                  "omap35xxTimer"

/* Debugging */

#undef OMAP_TIMER_LIB_DEBUG

#ifdef OMAP_TIMER_LIB_DEBUG
#undef OMAP_TIMER_LIB_SHOW
#define OMAP_TIMER_LIB_SHOW

volatile BOOL vxbOmapTimerDebugLvl = 100;

#define PRINTF printf

#define VXB_OMAP_TIMER_DBG_MSG(lvl,fmt,a,b,c,d,e,f)	  \
	do					  \
	    {					  \
	    if ( vxbOmapTimerDebugLvl >= lvl )      \
		{				  \
		PRINTF(fmt,a,b,c,d,e,f);	  \
		}				  \
	    }					  \
	while ((FALSE))

#else /* OMAP_TIMER_LIB_DEBUG */

#define VXB_OMAP_TIMER_DBG_MSG(lvl, fmt, a,b,c,d,e,f)

#endif /* OMAP_TIMER_LIB_DEBUG */

/* Locals */

/* define the power domain of the timer */
enum omapTimerPowerDomain
{
    OMAP_TIMER_PWR_WKUP,
    OMAP_TIMER_PWR_PER,
    OMAP_TIMER_PWR_CORE
};

/* structure to store the timer information */

struct omap35xxTimerData
    {
    VXB_DEVICE_ID                pInst;
    void *                       baseAddress;      /* base address of timer */
    void *                       vxbHandle;        /* vxBus handle */
    struct vxbTimerFunctionality timerFunclty;     /* capabilities of driver */
    void                         (*pIsrFunc)(int); /* BSP provides ISR Func */
    int                          arg;              /* ISR func argument */
    BOOL                         timerEnabled;     /* true if enabled */
    BOOL                         errorCorrect1ms;  /* GP1,2,10 1ms exactly */
    BOOL                         autoReload;       /* auto-reload timer */
    enum omapTimerPowerDomain    powerDomain;      /* Power management domain */
    UINT32                       rollover;         /* rollover value */
    UINT32                       positiveIncrement1ms; /* 1ms correction */
    UINT32                       negativeIncrement1ms; /* 1ms correction */
    BOOL                         chipIsDM81xx;     /* true if chip is DM81xx */
    BOOL                         isPosted;
    };

/*
 * Those registers have different offset in omap35xx and dm81xx,
 * but the function are the same.
 * Use array to reference.
 */

LOCAL int omap35xxRegs[] =
    {
    OMAP35XX_TIMER_TIOCP_CFG_OFFSET,
    OMAP35XX_TIMER_TCLR_OFFSET,
    OMAP35XX_TIMER_TCRR_OFFSET,
    OMAP35XX_TIMER_TLDR_OFFSET,
    OMAP35XX_TIMER_TTGR_OFFSET,
    OMAP35XX_TIMER_TWPS_OFFSET,
    OMAP35XX_TIMER_TMAR_OFFSET,
    OMAP35XX_TIMER_TCAR1_OFFSET,
    OMAP35XX_TIMER_TSICR_OFFSET,
    OMAP35XX_TIMER_TCAR2_OFFSET,
    };

LOCAL int dm81xxRegs[] =
    {
    DM81XX_TIMER_TIOCP_CFG_OFFSET,
    DM81XX_TIMER_TCLR_OFFSET,
    DM81XX_TIMER_TCRR_OFFSET,
    DM81XX_TIMER_TLDR_OFFSET,
    DM81XX_TIMER_TTGR_OFFSET,
    DM81XX_TIMER_TWPS_OFFSET,
    DM81XX_TIMER_TMAR_OFFSET,
    DM81XX_TIMER_TCAR1_OFFSET,
    DM81XX_TIMER_TSICR_OFFSET,
    DM81XX_TIMER_TCAR2_OFFSET,
    };

LOCAL int *pChipRegs;

#define TIMER_TIOCP_CFG_OFFSET  pChipRegs[0]
#define TIMER_TCLR_OFFSET       pChipRegs[1]
#define TIMER_TCRR_OFFSET       pChipRegs[2]
#define TIMER_TLDR_OFFSET       pChipRegs[3]
#define TIMER_TTGR_OFFSET       pChipRegs[4]
#define TIMER_TWPS_OFFSET       pChipRegs[5]
#define TIMER_TMAR_OFFSET       pChipRegs[6]
#define TIMER_TCAR1_OFFSET      pChipRegs[7]
#define TIMER_TSICR_OFFSET      pChipRegs[8]
#define TIMER_TCAR2_OFFSET      pChipRegs[9]

/* function declarations */

LOCAL void omap35xxTimerInstInit (VXB_DEVICE_ID);
LOCAL void omap35xxTimerInstInit2 (VXB_DEVICE_ID);
LOCAL void omap35xxTimerInstConnect (VXB_DEVICE_ID);
LOCAL STATUS omap35xxTimerFuncGet
    (VXB_DEVICE_ID pInst,
     struct vxbTimerFunctionality ** pTimerFunc,
     int                                timerNo
    );

LOCAL void vxbOmap35xxTimerClkInt (VXB_DEVICE_ID);
LOCAL STATUS omap35xxTimerAllocate
    (
    VXB_DEVICE_ID   pInst,
    UINT32      flags,
    void **     pCookie,
    UINT32      timerNo
    );
LOCAL STATUS omap35xxTimerRelease
    (
    VXB_DEVICE_ID              pInst,
    void*                      pCookie
    );

LOCAL STATUS omap35xxTimerRolloverGet
    (
    void*    pCookie,
    UINT32*  count
    );

LOCAL STATUS omap35xxTimerCountGet
    (
    void*    pCookie,
    UINT32*  count
    );

LOCAL STATUS omap35xxTimerISRSet
    (
    void*   pCookie,
    void    (*pFunc)(int),
    int     arg
    );

LOCAL STATUS omap35xxTimerDisable
    (
    void*    pCookie
    );

LOCAL STATUS omap35xxTimerEnable
    (
    void*    pCookie,
    UINT32   maxTimerCount
    );

/* globals */

/* structure to store the driver functions for vxBus */

LOCAL struct drvBusFuncs omap35xxTimerDrvFuncs =
    {
    omap35xxTimerInstInit,        /* devInstanceInit */
    omap35xxTimerInstInit2,       /* devInstanceInit2 */
    omap35xxTimerInstConnect      /* devConnect */
    };

/* driver methods */

LOCAL device_method_t omap35xxTimerDrv_methods[] =
    {
    DEVMETHOD(vxbTimerFuncGet,omap35xxTimerFuncGet),
    DEVMETHOD_END
    };

/* structure used for registration with vxbus */

LOCAL struct vxbDevRegInfo omap35xxTimerDrvRegistration =
    {
    NULL,                            /* pNext */
    VXB_DEVID_DEVICE,                /* devID */
    VXB_BUSID_PLB,                   /* busID = PLB */
    VXB_VER_4_0_0,                   /* busVer */
    TIMER_NAME,                      /* drvName */
    &omap35xxTimerDrvFuncs,          /* pDrvBusFuncs */
    &omap35xxTimerDrv_methods[0],    /* pMethods */
    NULL                             /* devProbe */
    };

/******************************************************************************
*
* omap35xxTimerDrvRegister - register omap35xx timer driver
*
* This routine registers the OMAP35xx timer driver with the vxBus subsystem.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

void vxbOmap35xxTimerDrvRegister(void)
    {

    /* call the vxBus routine to register the timer driver */

    vxbDevRegister(&omap35xxTimerDrvRegistration);

    }

/*******************************************************************************
*
* omap35xxTimerInstInit - first level initialization routine of timer device
*
* This is the function called to perform the first level initialization of
* the ixp400 timer device.
*
* NOTE:
*
* This routine is called early during system initialization, and
* *MUST NOT* make calls to OS facilities such as memory allocation
* and I/O.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void omap35xxTimerInstInit
    (
    VXB_DEVICE_ID              pInst
    )
    {
    struct omap35xxTimerData         *pTimerData;
    struct vxbTimerFunctionality     *pTimerFunc;
    FUNCPTR                           chipCheckFunc;
    UINT32                            val;
    FUNCPTR                           pFunc = NULL;

    /* to store the HCF device */

    HCF_DEVICE *        pHcf = NULL;

    VXB_OMAP_TIMER_DBG_MSG (100, "omap35xxTimerInstInit\n", 1, 2, 3, 4, 5, 6);

    /* check for valid parameter */

    if (pInst == NULL)
        return;

    /* get the HCF device from vxBus device structure */

    pHcf = hcfDeviceGet (pInst);

    /* if pHcf is NULL, no device is present */

    if (pHcf == NULL)
        return;

    pInst->pDrvCtrl = NULL;  /* just in case an error occurs */

    /* allocate the memory for the structure */


    pTimerData = (struct omap35xxTimerData *)
        hwMemAlloc (sizeof (struct omap35xxTimerData));

    /* check if memory allocation is successful */

    if (pTimerData == NULL)
        return;

    /* initialize the memory allocated */

    bzero ((char *)(pTimerData), sizeof(struct omap35xxTimerData));

    pTimerData->baseAddress = pInst->pRegBase[0];
    vxbRegMap (pInst, 0, &pTimerData->vxbHandle);


    /*
     * We are about to initialize the timer functionality structure.
     * Grab a pointer to it.
     */

    pTimerFunc = &(pTimerData->timerFunclty);

    /* get the minimum clock period */

    (void) devResourceGet (pHcf,"clkRateMin", HCF_RES_INT,
                          ((void *)&(pTimerFunc->minFrequency)));

    /* get the maximum clock period */

    (void) devResourceGet (pHcf,"clkRateMax", HCF_RES_INT,
                          ((void *)&(pTimerFunc->maxFrequency)));

    /* Get the frequency */

    if (devResourceGet (pHcf,"clkFreq", HCF_RES_INT,
                        ((void *)&(pTimerFunc->clkFrequency))) != OK)
        {
        (void) devResourceGet (pHcf,"clkFreq", HCF_RES_ADDR, (void *)&pFunc);
        if (pFunc)
            pTimerFunc->clkFrequency = (*pFunc)();
        }

    /*
     * Set up 1ms Error correction if supported by timer
     *
     * positive increment = ((integer(Fclk*Ttick)+1)*1000000) -
     *                       (Fclk*Ttick*1000000)
     *
     * negative increment = ((integer(Fclk*Ttick))*1000000) -
     *                       (Fclk*Ttick*1000000)
     *
     */

    (void) devResourceGet (pHcf,"errorCorrect1ms", HCF_RES_INT,
                          ((void *)&(pTimerData->errorCorrect1ms)));

    if ((UINT32)pTimerData->baseAddress != OMAP35XX_BASE_ADDR_GPTIMER1 &&
        (UINT32)pTimerData->baseAddress != OMAP35XX_BASE_ADDR_GPTIMER2 &&
        (UINT32)pTimerData->baseAddress != OMAP35XX_BASE_ADDR_GPTIMER10)
        {
        /* 1ms error correction is not supported by the chosen timer */
        pTimerData->errorCorrect1ms = FALSE;
        }

    if (pTimerData->errorCorrect1ms)
        {
        (void) devResourceGet (pHcf,"positiveIncrement1ms", HCF_RES_INT,
                              ((void *)&(pTimerData->positiveIncrement1ms)));

        (void) devResourceGet (pHcf,"negativeIncrement1ms", HCF_RES_INT,
                              ((void *)&(pTimerData->negativeIncrement1ms)));
        }
    else
        {
        pTimerData->positiveIncrement1ms = 0;
        pTimerData->negativeIncrement1ms = 0;
        }

    if ((devResourceGet (pHcf, "chipCheck", HCF_RES_ADDR,
                     (void *)&chipCheckFunc) == OK) && (UINT32)(chipCheckFunc()))
        {
        pTimerData->chipIsDM81xx = 1;
        pChipRegs = dm81xxRegs;
        }
    else
        {
        pTimerData->chipIsDM81xx = 0;
        pChipRegs = omap35xxRegs;
        }

    /* Store the feature provided by a general purpose timer */

    pTimerFunc->features =  VXB_TIMER_CAN_INTERRUPT |
                            VXB_TIMER_INTERMEDIATE_COUNT |
                            VXB_TIMER_SIZE_32 |
                            VXB_TIMER_AUTO_RELOAD;

    /* store the ticksPerSecond of the timer */

    pTimerFunc->ticksPerSecond = 60;

    /*
     * For manual testing of the timer, the name of the timer is
     * initialized
     */

    strncpy(pTimerFunc->timerName , TIMER_NAME, MAX_DRV_NAME_LEN);

    /* update the timer rollover period */

    pTimerFunc->rolloverPeriod = OMAP35XX_MAX_COUNT_VAL /
        pTimerFunc->clkFrequency;

    /* populate the function pointers */

    pTimerFunc->timerAllocate    = omap35xxTimerAllocate;
    pTimerFunc->timerRelease     = omap35xxTimerRelease;
    pTimerFunc->timerRolloverGet = omap35xxTimerRolloverGet;
    pTimerFunc->timerCountGet    = omap35xxTimerCountGet;
    pTimerFunc->timerDisable     = omap35xxTimerDisable;
    pTimerFunc->timerEnable      = omap35xxTimerEnable;
    pTimerFunc->timerISRSet      = omap35xxTimerISRSet;

    pTimerData->rollover = OMAP35XX_MAX_COUNT_VAL;

    /*
     * Caution: Do not put the overflow value (0xffffffff) in the GPTi.TLDR
     * register because it can lead to undesired results
     */

    if (pTimerData->rollover == 0)
        pTimerData->rollover = 1;

    OMAP35XX_TIMER_REG_READ (pTimerData, TIMER_TSICR_OFFSET, val);
    if (val & TIMER_POSTED)
        pTimerData->isPosted = TRUE;
    else
        pTimerData->isPosted = FALSE;

    pInst->pDrvCtrl = pTimerData;

    if ((UINT32)pTimerData->baseAddress == OMAP35XX_BASE_ADDR_GPTIMER1 ||
        (UINT32)pTimerData->baseAddress == OMAP35XX_BASE_ADDR_GPTIMER12)
        {
        pTimerData->powerDomain = OMAP_TIMER_PWR_WKUP;
        }
    else if ((UINT32)pTimerData->baseAddress == OMAP35XX_BASE_ADDR_GPTIMER10 ||
             (UINT32)pTimerData->baseAddress == OMAP35XX_BASE_ADDR_GPTIMER11)
        {
        pTimerData->powerDomain = OMAP_TIMER_PWR_CORE;
        }
    else
        {
        pTimerData->powerDomain = OMAP_TIMER_PWR_PER;
        }

    VXB_OMAP_TIMER_DBG_MSG (100, "... end omap35xxTimerInstInit\n", 1, 2, 3, 4, 5, 6);


    return;
    }

/*******************************************************************************
*
* omap35xxTimerInstInit2 - second level initialization routine of timer device
*
* This routine performs the second level initialization of the timer device.
*
* This routine is called later during system initialization.  OS features
* such as memory allocation are available at this time.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void omap35xxTimerInstInit2
    (
    VXB_DEVICE_ID              pInst
    )
    {

    VXB_OMAP_TIMER_DBG_MSG (100, "omap35xxTimerInstInit2\n", 1, 2, 3, 4, 5, 6);

    /* connect the ISR */

    (void) vxbIntConnect (pInst, 0, vxbOmap35xxTimerClkInt, pInst);
    }

/*******************************************************************************
*
* omap35xxTimerInstConnect - third level initialization routine of timer device
*
* This is the function called to perform the third level initialization of
* the timer device.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void omap35xxTimerInstConnect
    (
    VXB_DEVICE_ID                pInst
    )
    {

    /* nothing is done here */

    }

/*******************************************************************************
*
* vxbOmap35xxTimerClkInt - handle system clock interrupts
*
* This routine handles system clock interrupts.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void vxbOmap35xxTimerClkInt
    (
    VXB_DEVICE_ID pInst
    )
    {
    struct omap35xxTimerData *pTimerData;
    UINT32                    regVal;

    VXB_OMAP_TIMER_DBG_MSG (200, "vxbOmap35xxTimerClkInt\n", 1, 2, 3, 4, 5, 6);

    if ((pInst == NULL) || (pInst->pDrvCtrl == NULL))
        return;

    pTimerData = pInst->pDrvCtrl;

    VXB_OMAP_TIMER_DBG_MSG (200, "   base address = 0x%x\n",
                            pTimerData->baseAddress, 2, 3, 4, 5, 6);

    /*
     * Clear all types of pending interrupts by writing 1 to the status flag.
     * Bit 0 is match interrupt
     * Bit 1 is overflow interrupt
     * Bit 2 is capture interrupt
     */

    if (pTimerData->chipIsDM81xx)
        OMAP35XX_TIMER_REG_WRITE (pTimerData, DM81XX_TIMER_IRQSTATUS_OFFSET,
                              0x00000007);
    else
        OMAP35XX_TIMER_REG_WRITE (pTimerData, OMAP35XX_TIMER_TISR_OFFSET,
                              0x00000007);

    /* re-enable the timer if the autoReload is not set */

    if (!pTimerData->autoReload)
        {

        /* restart or start the timer*/

        OMAP35XX_TIMER_REG_SYNC_READ (pTimerData, TIMER_TCLR_OFFSET, regVal,
                        TIMER_W_PEND_TCLR);
        regVal |= 0x1;
        OMAP35XX_TIMER_REG_SYNC_WRITE (pTimerData, TIMER_TCLR_OFFSET, regVal,
                        TIMER_W_PEND_TCLR);
        }


    if (pTimerData->pIsrFunc != NULL)
        (*(pTimerData->pIsrFunc)) (pTimerData->arg);
    }

/*******************************************************************************
*
* omap35xxTimerAllocate - allocate resources for a timer
*
* This is the function called to allocate resources for a timer for usage by the
* Timer Abstraction Layer
*
* RETURNS: OK or ERROR if timer allocation fails
*
* ERRNO: N/A
*/

LOCAL STATUS omap35xxTimerAllocate
    (
    VXB_DEVICE_ID   pInst,
    UINT32          flags,
    void **         pCookie,
    UINT32          timerNo
    )
    {
    struct omap35xxTimerData *   pTimerData;

    /* check whether the parameters are valid */

    if ( (pInst == NULL) || (pCookie == NULL))
        {

        /* invalid parameters return ERROR */

        return ERROR;
        }

    if ( timerNo >= OMAP35XX_MAX_TIMERS)
        {

        /* invalid parameters return ERROR */

        return ERROR;
        }

    pTimerData = (struct omap35xxTimerData *)(pInst->pDrvCtrl);

    /* check whether 'pTimerData' is valid or not */

    if (pTimerData != NULL)
        {
        /* if the timer is already allocated, return ERROR */

        if ((pTimerData->pInst != NULL) || (pTimerData->timerFunclty.allocated))
            return ERROR;

        /* set the auto-reload flag */

        if ((flags & VXB_TIMER_AUTO_RELOAD) != 0)
            pTimerData->autoReload = TRUE;

        /* copy the instance pointer */

        pTimerData->pInst = pInst;

        /* set the allocated flag */

        pTimerData->timerFunclty.allocated = TRUE;
        }
    else
        return ERROR;

    /* store the timer information in the pCookie */

    *pCookie = pInst->pDrvCtrl;

    return OK;
    }

/*******************************************************************************
*
* omap35xxTimerRelease - release the timer resource
*
* This is the function called to release the resources allocated for a timer
* device
*
* RETURNS: OK or ERROR
*
* ERRNO: N/A
*/

LOCAL STATUS omap35xxTimerRelease
    (
    VXB_DEVICE_ID              pInst,
    void*                      pCookie
    )
    {
    struct omap35xxTimerData *pTimerData;

    VXB_OMAP_TIMER_DBG_MSG (100, "omap35xxTimerRelease\n", 1, 2, 3, 4, 5, 6);

    /* check whether the parameters are valid */

    if ( (pInst == NULL) || (pCookie == NULL) )
        {

        /* invalid parameters */

        return ERROR;
        }

    /* parse the driver information from pCookie */

    pTimerData = (struct omap35xxTimerData *)pCookie;

    /* check whether the members are valid */

    if ((pTimerData == NULL) ||
        (pTimerData->pInst != pInst) ||
        (!pTimerData->timerFunclty.allocated))
        return ERROR;

    omap35xxTimerDisable (pCookie);

    /* reset the autoReload flag */

    if (pTimerData->autoReload)
        pTimerData->autoReload = FALSE;

    pTimerData->pIsrFunc = NULL;
    pTimerData->arg = 0;

    /* reset the timer allocated flag */

    pTimerData->timerFunclty.allocated = FALSE;

    /* release the pInst for timer */

    pTimerData->pInst = NULL;

    return OK;
    }

/*******************************************************************************
*
* omap35xxTimerRolloverGet - retrieve the maximum value of the counter
*
* This is the function called to retrieve the maximum value of the counter.
* The maximum value is returned in 'count' parameter.
*
* RETURNS: OK or ERROR if the parameter is invalid.
*
* ERRNO: N/A
*/

LOCAL STATUS omap35xxTimerRolloverGet
    (
    void*    pCookie,
    UINT32*  count
    )
    {
    struct omap35xxTimerData *   pTimerData;

    /* check whether the parameters are valid */

    if ( (count == NULL) || (pCookie == NULL) )
        {

        /* invalid parameters */

        return ERROR;
        }

    pTimerData = (struct omap35xxTimerData *)pCookie;

    *count = pTimerData->rollover;

    return OK;
    }

/*******************************************************************************
*
* omap35xxTimerCountGet - retrieve the current timer count
*
* This function is used to retrieve the current timer count.
* The current value is returned in 'count' parameter.
*
* RETURNS: OK or ERROR if the parameter is invalid.
*
* ERRNO: N/A
*/

LOCAL STATUS omap35xxTimerCountGet
    (
    void*    pCookie,
    UINT32*  count
    )
    {
    struct omap35xxTimerData *   pTimerData;
    UINT32 timer_val, load_val;  /* timer counter and start/load values */

    /* check whether the parameters are valid */

    if ((count == NULL) || (pCookie == NULL))
        {

        /* invalid parameters */

        return ERROR;
        }

    pTimerData = (struct omap35xxTimerData *)pCookie;

    OMAP35XX_TIMER_REG_SYNC_READ (pTimerData, TIMER_TCRR_OFFSET, timer_val,
                    TIMER_W_PEND_TCRR);
    OMAP35XX_TIMER_REG_SYNC_READ (pTimerData, TIMER_TLDR_OFFSET, load_val ,
                    TIMER_W_PEND_TLDR);

    /*
     * Since this is an upward counting timer, the count value is the
     * increase from the start/load value.
     */

    *count = timer_val - load_val;

    return OK;
    }

/*******************************************************************************
*
* omap35xxTimerISRSet - set a function to be called on the timer interrupt
*
* This function is called to set a function which can be called whenever
* the timer interrupt occurs.
*
* RETURNS: OK or ERROR if the parameter is invalid.
*
* ERRNO: N/A
*/

LOCAL STATUS omap35xxTimerISRSet
    (
    void*   pCookie,
    void    (*pFunc)(int),
    int     arg
    )
    {
    struct omap35xxTimerData *   pTimerData;

    VXB_OMAP_TIMER_DBG_MSG (100, "omap35xxTimerISRSet\n", 1, 2, 3, 4, 5, 6);

    if (pCookie == NULL)
    return ERROR;

    pTimerData = (struct omap35xxTimerData *)pCookie;

    /*
     * Store the interrupt routine and argument information
     * 1) set the function to NULL so old ISR is not called while we are here
     * 2) next set the arg so if the new function is called while as we are
     *    setting up, it does not get the arg from the old ISR
     * 3) assign the function last
     */

    pTimerData->pIsrFunc = NULL;
    pTimerData->arg = arg;
    pTimerData->pIsrFunc = pFunc;

    return OK;
    }

/*******************************************************************************
*
* omap35xxTimerDisable - disable the timer
*
* This routine disables system clock interrupts.
*
* RETURNS: OK or ERROR if argument is NULL
*
* ERRNO: N/A
*/

LOCAL STATUS omap35xxTimerDisable
    (
    void*    pCookie
    )
    {
    struct omap35xxTimerData *pTimerData;
    VXB_DEVICE_ID             pInst;

    VXB_OMAP_TIMER_DBG_MSG (100, "omap35xxTimerDisable\n", 1, 2, 3, 4, 5, 6);

    /* check for valid pointer */

    if (pCookie == NULL)
        return ERROR;

    pTimerData = (struct omap35xxTimerData *)pCookie;
    pInst = pTimerData->pInst;

    if (pTimerData->timerEnabled)
        {
        /*
         * just disable the timer tick interrupt.
         * Note:
         *      don't disable timer counting,
         *      other functions(e.g sysUsDelay()) may use it.
         */

        if (vxbIntDisable (pInst, 0, vxbOmap35xxTimerClkInt, pInst) != OK)
                logMsg ("int diable error!!!\n",0,0,0,0,0,0);

        pTimerData->timerEnabled = FALSE;
        }

    return OK;
    }

/*******************************************************************************
*
* omap35xxTimerEnable - enable the timer
*
* This routine enables system clock interrupts.
*
* RETURNS: OK or ERROR if argument is NULL
*
* ERRNO: N/A
*/

LOCAL STATUS omap35xxTimerEnable
    (
    void*    pCookie,
    UINT32   maxTimerCount
    )
    {
    struct omap35xxTimerData *pTimerData;
    VXB_DEVICE_ID             pInst;
    UINT32                    regVal;

    VXB_OMAP_TIMER_DBG_MSG (100, "omap35xxTimerEnable(0x%x, %d)\n",
                            pCookie, maxTimerCount, 3, 4, 5, 6);

    /* check for valid pointer */

    if (pCookie == NULL)
        return ERROR;

    pTimerData = (struct omap35xxTimerData *)pCookie;
    pInst = pTimerData->pInst;

    pTimerData->rollover = maxTimerCount;


    VXB_OMAP_TIMER_DBG_MSG (100, "   base address = 0x%x\n",
                            pTimerData->baseAddress, 2, 3, 4, 5, 6);

    /* Hit the reset bit to stop the timer & reset various regs */

    if (pTimerData->chipIsDM81xx)
        {
        OMAP35XX_TIMER_REG_WRITE (pTimerData, TIMER_TIOCP_CFG_OFFSET, 0x1);

    /* wait for reset to complete */

        do
            {
            OMAP35XX_TIMER_REG_READ (pTimerData, TIMER_TIOCP_CFG_OFFSET,
                                     regVal);
            }
        while (regVal & 0x1);
        }
    else
        {
        OMAP35XX_TIMER_REG_WRITE (pTimerData, TIMER_TIOCP_CFG_OFFSET, 0x2);

        /* wait for reset to complete */

        do
            {
            OMAP35XX_TIMER_REG_READ (pTimerData, OMAP35XX_TIMER_TISTAT_OFFSET,
                                     regVal);
            }
        while (!(regVal & 0x1));
        }

    /*
     * Set the rollover load register
     * The timer counts from rollover up to 0xffffffff so subtract.
     */

    /*
     * Caution: Do not put the overflow value (0xffffffff) in the GPTi.TLDR
     * register because it can lead to undesired results
     *
     */

    if (pTimerData->rollover == 0)
        pTimerData->rollover = 1;


    VXB_OMAP_TIMER_DBG_MSG (100, "TLDR=0x%x\n",
                            OMAP35XX_MAX_COUNT_VAL - pTimerData->rollover,
                            2, 3, 4, 5, 6);

    /* set up value to be loaded */

    OMAP35XX_TIMER_REG_SYNC_WRITE (pTimerData, TIMER_TLDR_OFFSET,
                              OMAP35XX_MAX_COUNT_VAL - pTimerData->rollover,
                              TIMER_W_PEND_TLDR);

    /* and load it */

    OMAP35XX_TIMER_REG_SYNC_WRITE (pTimerData, TIMER_TTGR_OFFSET, 0x1,
                    TIMER_W_PEND_TTGR);

    /* enable overflow interrupts and wakeup (capture and match are disabled) */

    if (pTimerData->chipIsDM81xx)
        {
        OMAP35XX_TIMER_REG_WRITE (pTimerData,
                                        DM81XX_TIMER_IRQSTATUS_SET_OFFSET, 0x2);
        OMAP35XX_TIMER_REG_WRITE (pTimerData,
                                            DM81XX_TIMER_IRQWAKEEN_OFFSET, 0x2);
        }
    else
        {
        OMAP35XX_TIMER_REG_WRITE (pTimerData, OMAP35XX_TIMER_TIER_OFFSET, 0x2);
        OMAP35XX_TIMER_REG_WRITE (pTimerData, OMAP35XX_TIMER_TWER_OFFSET, 0x2);
        }

    if (pTimerData->autoReload)
        {
        /* enable autoreload and start the timer with overflow */

        OMAP35XX_TIMER_REG_SYNC_WRITE (pTimerData, TIMER_TCLR_OFFSET,
                        0x403, TIMER_W_PEND_TCLR);
        }
    else
        {
        /* start the timer as a one-shot*/

        OMAP35XX_TIMER_REG_SYNC_WRITE (pTimerData, TIMER_TCLR_OFFSET,
                        0x401, TIMER_W_PEND_TCLR);
        OMAP35XX_TIMER_REG_SYNC_WRITE (pTimerData, TIMER_TMAR_OFFSET,
                        1, TIMER_W_PEND_TMAR);
        }

    VXB_OMAP_TIMER_DBG_MSG (100, "omap35xxTimerEnable  calling vxbIntEnable\n",
                            1, 2, 3, 4, 5, 6);

    (void) vxbIntEnable (pInst, 0, vxbOmap35xxTimerClkInt, pInst);

    VXB_OMAP_TIMER_DBG_MSG (100, "... called omap35xxTimerEnable\n",
                            1, 2, 3, 4, 5, 6);

    pTimerData->timerEnabled = TRUE;

    return OK;
    }

/*******************************************************************************
*
* omap35xxTimerFuncGet - method to retrieve the timer functionality
*
* This function is the driver method used to retrieve the timer functionality.
*
* RETURNS: OK or ERROR if functionality is not retrieved.
*
* ERRNO: N/A
*/

LOCAL STATUS omap35xxTimerFuncGet
    (
    VXB_DEVICE_ID                  pInst,
    struct vxbTimerFunctionality **pTimerFunc,
    int                            timerNo
    )
    {
    struct omap35xxTimerData *   pTimerData;

    if (pTimerFunc == NULL)
        {
        return ERROR;
        }

    if (timerNo >= OMAP35XX_MAX_TIMERS)
        {
        *pTimerFunc = NULL;
        return ERROR;
        }

    /* check the validity of parameters */

    if ((pInst == NULL) || (pInst->pDrvCtrl == NULL))
        {
        *pTimerFunc = NULL;
        return ERROR;
        }

    /* retrieve the timer specific data */

    pTimerData = (struct omap35xxTimerData *)(pInst->pDrvCtrl);

    if (pTimerData  == NULL)
        {

        return ERROR;
        }

    /* update the timer functionality pointer */

    *pTimerFunc = &(pTimerData->timerFunclty);

    return OK;
    }

/*******************************************************************************
*
* omap35xxGetSysclkTicksPerSecond - method to retrieve the timer ticks
*
* This function is the driver method used to retrieve the sysclk timer ticks.
*
* RETURNS: Timer ticks per second
*
* ERRNO: N/A
*/

int omap35xxGetSysclkTicksPerSecond(void)
    {
    return pClkTimer->ticksPerSecond;
    }

/**************************************************************************
*
* omap35xxOneShotEnable - clear wakeup time
*
* This routine resets the system clock timer for an expiration that
* is a programmable time in the future.  This is used as part of power
* management.
* If nTicks == 0, wait forever (or as long as possible)
*
*
* RETURNS: past ticks
*
* ERRNO: N/A
*
* SEE ALSO: sysOneShotEnable(), sysOneShotDisable(), sysOneShotInit()
*/
void omap35xxOneShotEnable
    (
    VXB_DEVICE_ID                  pInst,
    UINT32 nTicks
    )
    {
    UINT32 sleepTicks;
    UINT32 isrStatus;

    struct vxbTimerFunctionality * pTimerFunc;
    struct omap35xxTimerData *pSysClkTimerInfo;

    if (pInst == NULL)
        {
        return; /* ERROR */
        }

    /*
     * check if sys clk timer was initialized and enabled
     */

    pSysClkTimerInfo = pInst->pDrvCtrl;

    if (!pSysClkTimerInfo || !pSysClkTimerInfo->timerEnabled )
        {
        return; /* ERROR */
        }


    pTimerFunc = &pSysClkTimerInfo->timerFunclty;

    /*
     * we want to sleep one tick less than what was requested, plus whatever
     * fraction of a tick remains on the system clock
     *
     * hardware limitation requires clamping this number
     */

    if ((nTicks == 0 ) || (nTicks >= OMAP35XX_MAX_MATCH_VAL))
        {
        sleepTicks = OMAP35XX_MAX_MATCH_VAL;
        }
    else
        {
    	/*
    	 * advance the number of requested ticks
    	 */

    	sleepTicks = nTicks - 1;    /* Caller will not pass nTicks == 1 */
        }

    /* write the match count register */

    OMAP35XX_TIMER_REG_SYNC_WRITE(pSysClkTimerInfo, OMAP35XX_TIMER_TOWR_OFFSET,
        sleepTicks, TIMER_W_PEND_TOWR);

    /*
     * Detect rollover failure
     * The count register may be in the process of rolling over.  An interrupt
     * pending at this point means that the timer will generate an interrupt
     * and needs to be serviced.  The number of ticks elapsed is only one
     * however, the rollover tick.
     */

    /* get the current ISR status */

    OMAP35XX_TIMER_REG_READ (pSysClkTimerInfo, OMAP35XX_TIMER_TISR_OFFSET,
    	isrStatus);

    /* If interrupt is pending */

    if ((isrStatus & 0x2) != 0)
        {

        /*
         * Clear the match count register.  The timer will service the
         * interrupt and advance system time by one-tick.  Since
         * the omap35xxOneShotDisable uses the match count to figure out
         * how long its been sleeping, we need to clear it out.  It hasn't
         * slept.
         */

        OMAP35XX_TIMER_REG_WRITE(pSysClkTimerInfo, OMAP35XX_TIMER_TOWR_OFFSET,
    	    0);

        }
    }


/**************************************************************************
*
* omap35xxOneShotDisable - system clock clear
*
* This routine turns off the sleep timer.  This is used as part of power
* management.
*
* RETURNS: the number of ticks the system slept.
*
* ERRNO: N/A
*
* SEE ALSO: sysCpuPwrUp(), sysOneShotEnable(), sysOneShotInit(),
*           sysOneShotInt()
*/

UINT32 omap35xxOneShotDisable
    (
    VXB_DEVICE_ID                  pInst
    )
    {
    UINT32 elapsedCount;
    UINT32 timerCountPerTick;
    UINT32 isrStatus;
    UINT32 ticksExpired;
    struct vxbTimerFunctionality * pTimerFunc;
    struct omap35xxTimerData *pSysClkTimerInfo;

    if (pInst == NULL)
        {
        return 0; /* ERROR */
        }

    /*
     * check if sys clk timer was initialized and enabled
     */

    pSysClkTimerInfo = pInst->pDrvCtrl;

    if (!pSysClkTimerInfo || !pSysClkTimerInfo->timerEnabled )
        {
        return 0; /* ERROR */
        }


    pTimerFunc = &pSysClkTimerInfo->timerFunclty;

    /* get the current ISR status */

    OMAP35XX_TIMER_REG_READ (pSysClkTimerInfo, OMAP35XX_TIMER_TISR_OFFSET,
    	isrStatus);

    /*
     * Check the timer interrupt pending status
     */

    if (isrStatus & 0x2)
        {
        /*
         * Timer interrupt, the number of ticks expired is equal
         * to what we requested.
         */

        /* read the match count register */

        OMAP35XX_TIMER_REG_SYNC_READ(pSysClkTimerInfo, OMAP35XX_TIMER_TOWR_OFFSET,
            ticksExpired, TIMER_W_PEND_TOWR);

        /*
         * When the timer expires, the TOCR resets to zero so TOWR is invalid
         * The matchCount has the number of ticks that were skipped, so the
         * total number is matchCount+1.  We want to report one less however
         * because the timer ISR will call windTickAnnounce for one tick.
         */

        OMAP35XX_TIMER_REG_SYNC_READ(pSysClkTimerInfo, OMAP35XX_TIMER_TOCR_OFFSET,
    	    elapsedCount, TIMER_W_PEND_TOCR);
        }
    else
        {
        /*
         * Some of the ticks expired, return expired ticks
         */

        /*
         * read how much time remains on the current one shot timer. TOCR
         * increments till it is equal to TOWR, then reset to 0 and starts
         * incrementing again
         */

        OMAP35XX_TIMER_REG_SYNC_READ(pSysClkTimerInfo, OMAP35XX_TIMER_TOCR_OFFSET,
    	    ticksExpired, TIMER_W_PEND_TOCR);

        }

    /* while awake, interrupt with each clock tick */

    OMAP35XX_TIMER_REG_SYNC_WRITE(pSysClkTimerInfo, OMAP35XX_TIMER_TOCR_OFFSET, 0, TIMER_W_PEND_TOCR);
    OMAP35XX_TIMER_REG_SYNC_WRITE(pSysClkTimerInfo, OMAP35XX_TIMER_TOWR_OFFSET, 0, TIMER_W_PEND_TOWR);


    /*
     * Detect rollover failure
     * The count register was zero'd above and the match register
     * was set to zero.  If the count register subsequently incremented,
     * there should be an interrupt pending.  In the failure mode,
     * the timer rolled over but no match was detected (i.e. no interrupt).
     * If we don't correct for this, we won't get a timer interrupt until
     * it rolls over again.
     */

    OMAP35XX_TIMER_REG_SYNC_READ(pSysClkTimerInfo, OMAP35XX_TIMER_TOCR_OFFSET,
    	elapsedCount, TIMER_W_PEND_TOCR);
    OMAP35XX_TIMER_REG_READ (pSysClkTimerInfo, OMAP35XX_TIMER_TISR_OFFSET,
    	isrStatus);

    /* If the counter rolled over but no interrupt is pending */

    if ((elapsedCount != 0) && ((isrStatus & 0x2) == 0))
        {
        ticksExpired++;     /* Missed tick, increment count */
        OMAP35XX_TIMER_REG_SYNC_WRITE(pSysClkTimerInfo,
            OMAP35XX_TIMER_TOCR_OFFSET, 0, TIMER_W_PEND_TOCR); /* clear overflow count */

        }


    return (ticksExpired); /* return ticks expired */
    }


