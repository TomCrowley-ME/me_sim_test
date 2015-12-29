/******************************************************************************
** File:  cfe_psp_start.c
**
**
**      Copyright (c) 2004-2012, United States government as represented by the
**      administrator of the National Aeronautics Space Administration.
**      All rights reserved. This software(cFE) was created at NASA Goddard
**      Space Flight Center pursuant to government contracts.
**
**      This is governed by the NASA Open Source Agreement and may be used,
**      distributed and modified only pursuant to the terms of that agreement.
**
**
**
** Purpose:
**   cFE PSP main entry point.
**
** History:
**   2004/09/23  J.P. Swinski    | Initial version,
**   2004/10/01  P.Kutt          | Replaced OS API task delay with VxWorks functions
**                                 since OS API is initialized later.
**
******************************************************************************/

/*
**  Include Files
*/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "vxWorks.h"
#include "sysLib.h"
#include "taskLib.h"
#include "ramDrv.h"
#include "dosFsLib.h"
#include "xbdBlkDev.h"
#include "errnoLib.h"
#include "usrLib.h"
#include "cacheLib.h"

/*
** cFE includes
*/
#include "common_types.h"
#include "osapi.h"
#include "cfe_es.h"            /* For reset types */
#include "cfe_platform_cfg.h"  /* for processor ID */

#include "cfe_psp.h"
#include "cfe_psp_memory.h"

/*
**  External Declarations
*/
extern int  sysStartType; /* VxWorks global containing its start type info */

/******************************************************************************
**  Function:  CFE_PSP_Main()
**
**  Purpose:
**    vxWorks/BSP Application entry point.
**
**  Arguments:
**    (none)
**
**  Return:
**    (none)
*/

void CFE_PSP_Main(  int ModeId, char *StartupFilePath )
{
    int    TicksPerSecond;
    uint32 reset_type;
    uint32 reset_subtype;

    /*
    ** Initialize the OS API
    */
    OS_API_Init();

    /*
    ** Delay for one second.
    */
    TicksPerSecond = sysClkRateGet();
    (void) taskDelay( TicksPerSecond );

    /*
    ** Setup the pointer to the reserved area in vxWorks.
    ** This must be done before any of the reset variables are used.
    */
    CFE_PSP_ReservedMemoryPtr = (CFE_PSP_ReservedMemory_t *)sysMemTop();

    /*
    ** Determine Reset type by reading the hardware reset register.
    */

    /* TODO: More robustly determine reset subtypes */
    if (sysStartType & BOOT_CLEAR) {
        reset_type = CFE_ES_POWERON_RESET;
        reset_subtype = CFE_ES_POWER_CYCLE;
    } else {
        reset_type = CFE_ES_PROCESSOR_RESET;
        reset_subtype = CFE_ES_RESET_COMMAND;
    }

    /*
    ** Initialize the reserved memory
    */
    CFE_PSP_InitProcessorReservedMemory(reset_type);

    /* Initialize the various local timers */
    CFE_PSP_InitLocalTimers();

    /*
    ** Call cFE entry point. This will return when cFE startup
    ** is complete.
    */
    CFE_ES_Main(reset_type,reset_subtype, 1, (uint8*)CFE_ES_NONVOL_STARTUP_FILE);

    /* Initialize the 1Hz Tone */
    CFE_PSP_Init1HzTone();

    /*
    ** Return back to VxWorks after the cFE is started
    */
}

