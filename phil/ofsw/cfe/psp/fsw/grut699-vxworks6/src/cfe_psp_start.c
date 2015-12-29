/******************************************************************************
** File:  cfe_psp_start.c
**
**
**      Copyright (c) 2004-2006, United States government as represented by the
**      administrator of the National Aeronautics Space Administration.
**      All rights reserved. This software(cFE) was created at NASA Goddard
**      Space Flight Center pursuant to government contracts.
**
**      This software may be used only pursuant to a United States government
**      sponsored project and the United States government may not be charged
**      for use thereof.
**
**
** Purpose:
**   cFE PSP main entry point.
**
** History:
**   2004/09/23  J.P. Swinski    | Initial version,
**   2004/10/01  P.Kutt          | Replaced OS API task delay with VxWorks functions
**                                 since OS API is initialized later.
**   2014/07/24  S.Duran	 	 | Updated for ut699 for BFS prototype
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
#include "errnoLib.h"
#include "usrLib.h"
#include "cacheLib.h"

/*
** cFE includes
*/
#include "common_types.h"
#include "osapi.h"
#include "cfe.h"
#include "cfe_es.h"            /* For reset types */
#include "cfe_platform_cfg.h"  /* for processor ID */

/*
** Types and prototypes for this module
*/
#include "cfe_psp.h"
#include "cfe_psp_memory.h"


#define CFE_PSP_TASK_PRIORITY    (30)
#define CFE_PSP_TASK_STACK_SIZE  (20 * 1024)


void CFE_PSP_Start( int ModeId, char *StartupFilePath );

/*
**  External Declarations
*/
extern void CFE_PSP_InitLocalTime(void);
extern void CFE_PSP_Init1HzTimer(void);
extern void CFE_TIME_SetState(int16);

uint32 ResetType;
uint32 ResetSubtype;

extern CFE_PSP_ReservedMemory_t *CFE_PSP_ReservedMemoryPtr;


/******************************************************************************
**  Function:  CFE_PSP_Main()
**
**  Purpose:
**    vxWorks/PSP Application entry point.
**
**  Arguments:
**    ModeId          - not currently used
**    StartupFilePath - path to cFE startup file to use
**
**  Return:
**    (none)
*/
void CFE_PSP_Main( int ModeId, char *StartupFilePath )
{
  int root_task_id;

  root_task_id = taskSpawn("PSP_START", CFE_PSP_TASK_PRIORITY,
                            0, CFE_PSP_TASK_STACK_SIZE,
                            (FUNCPTR) (void *)CFE_PSP_Start, ModeId,
                            (int)StartupFilePath,0,0,0,0,0,0,0,0);

  if ( root_task_id == ERROR )
  {
     printf("CFE_PSP_Main: ERROR - unable to spawn PSP_START task");
  }

}

/******************************************************************************
**  Function:  CFE_PSP_SysInit()
**
**  Purpose:
**    Initializes core PSP functionality.  This is called by both the primary
**      CFE_PSP_Main startup, as well as the alternative initialization in the
**      Startup Manager (SM) component.  The SM uses the PSP and OSAL but does
**      not start cFE or initialize all components of the PSP.
**
**  Arguments:
**    psp_reset_type - output
**    psp_reset_subtype - output
**    last_bsp_reset_type  - input - TBD - do we need to keep this?
**
**  Return:
**    (none)
**
*/
void CFE_PSP_SysInit(uint32* psp_reset_type, uint32* psp_reset_subtype, uint32 last_bsp_reset_type)
{
   int TicksPerSecond = 0;
   uint32 mcfg2 = 0;

   /*
   ** Delay for one second.
   */
   TicksPerSecond = sysClkRateGet();
   (void) taskDelay( TicksPerSecond );


   /* This register should be initialized by the Kernel or Bootloader.  It's value
   **  is verified here to ensure correct operation of the system.  This section may
   **  be tweaked as necessary for project requirements if not set directly in the
   **  bootloader.
   ** Rick - Need to verify this solves the memory access exceptions.  SPARC is
   **        very touchy about this, more so than PPC or coldfire.
   **
   ** Brute force...  Make sure the read-modify-write bit is set in mcfg2 register
   ** The bit is 0x00000040 in mcfg2 reg, and should probably always be set.  If there
   ** is a performance hit, that's still better than random crashes.
   */
   mcfg2 = *(uint32*)0x80000004;

   if(!(mcfg2 & 0x00000040))
   {
      /*
      ** Set the rmw bit now and print something saying you did so...
      */

      mcfg2 = *(uint32*)0x80000004 = mcfg2 | 0x00000040;

      OS_printf("\nNOTE: Set the rmw bit MCFG2 reg. Current value = %08X\n\n", mcfg2);
   }
   else
   {
      OS_printf("\nNOTE: The rmw bit in MCFG2 reg is already set. Current value = %08X\n\n", mcfg2);
   }

   /* Assign the reset cause */
   /* for now always start up in a power on reset */
   *psp_reset_type    = CFE_ES_POWERON_RESET;
   *psp_reset_subtype = CFE_ES_POWER_CYCLE;

   ResetType = *psp_reset_type;
   ResetSubtype = *psp_reset_subtype;

}



/******************************************************************************
**  Function:  CFE_PSP_Start()
**
**  Purpose:
**    Initialize the PSP and start cFE
**
**  Arguments:
**    ModeId          - Used to indicate which bank of non-volatile memory
**                      was used to boot.  If the bank used to boot this time
**                      is different from the previous boot, then we re-initialize
**                      reserved memory.
**    StartupFilePath - path to cFE startup file to use
**
**  Return:
**    (none)
*/
void CFE_PSP_Start( int ModeId, char *StartupFilePath )
{
   uint32 reset_type = 0;
   uint32 reset_subtype = 0;
   uint32 status = 0;


   /*
    ** Initialize the hardware timer for the local time source
    ** On VxWorks, the default config sets the sysClk to 200 Hz (default 60Hz)
    ** OS_API_Init() calls OS_TimerAPIInit() which gets the
    ** clock resolution of the realtime clock, which is based on the sysClk
    ** and determines the clock accuracy which is used by the scheduler
    ** timers later.  sysClk needs to be at least 200Hz for a 100Hz minor
    ** frame rate.
    */
   CFE_PSP_InitLocalTime();

   /*
   ** Initialize the OS API data structures
   */
   status = OS_API_Init();
   if(status != OS_SUCCESS)
   {
     printf("CFE_PSP_Start() - OS_API_Init() fail, RC = 0x%x\n", status);
   }

   /*
   ** Setup the pointer to the reserved area in vxWorks.
   ** This must be done before any of the reset variables are used.
   */
   CFE_PSP_ReservedMemoryPtr = (CFE_PSP_ReservedMemory_t *) sysMemTop();

   printf("CFE_PSP_Main: Reserved Memory Address %08X\n", (uint32)CFE_PSP_ReservedMemoryPtr);

   /* PSP System Initialization */
   CFE_PSP_SysInit(&reset_type, &reset_subtype, CFE_PSP_ReservedMemoryPtr->bsp_reset_type);

   /*
   ** Initialize the watchdog, it's left disabled
   */
   CFE_PSP_WatchdogInit();

   /*
   ** Initialize the reserved memory
   */
   CFE_PSP_InitProcessorReservedMemory(reset_type);

    /*
     * Adjust system task priorities so that tasks such as the shell are
     * at a lower priority that the CFS apps
     */
    SetSysTasksPrio();

   /*
   ** Call cFE entry point. This will return when cFE startup
   ** is complete.
   */
   CFE_ES_Main(reset_type, reset_subtype, ModeId, StartupFilePath);

   /*
    * Initializing the 1Hz timer connects the cFE 1Hz ISR for providing the
    * CFS 1Hz time sync, sync the scheduler's 1Hz major frame start to the
    * 1Hz timer.  This call can only occur after CFE_ES_Main() because the
    * 1Hz ISR uses a semaphore that is created when timer services are
    * initialized.
    */
   CFE_PSP_Init1HzTimer();
   CFE_TIME_SetState(CFE_TIME_VALID);

   /*
   ** Enable the watchdog
   */
/* CFE_PSP_WatchdogEnable(); really should be enabled in HS */

    printf("CFE_PSP_Start done, exiting.\n");

   return;

}  /* End CFE_PSP_Main */


/******************************************************************************
**  Function:  CFE_PSP_GetRestartType()
**
**  Purpose:
**    Retrieve the CFE PSP reset type and subtype.
**
**  Arguments:
**    restartSubType [out] Reset Sub Type
**
**  Return:
**    Reset Type
*/
uint32        CFE_PSP_GetRestartType(uint32 *restartSubType )
{
  *restartSubType = ResetSubtype;
  return ResetType;
}

/* default priority adjustment functions */
void SetTaskPrio(const char* tName, const int tgtPrio)
{
    int tid=0, curPrio=0, newPrio=0;

    if ((tName != NULL) && (strlen(tName) > 0))
    {
        newPrio = tgtPrio;
        if (newPrio < 0)
        {
            newPrio = 0;
        }
        else if (newPrio > 255)
        {
            newPrio = 255;
        }

        tid = taskNameToId(tName);
        if (tid != ERROR)
        {
            if (taskPriorityGet(tid, &curPrio) != ERROR)
            {
                printf("Setting %s priority from %d to %d\n", tName, curPrio, newPrio);
                taskPrioritySet(tid, newPrio);
            }
        }
    }
}

void ResetSysTasksPrio(void)
{
    printf("\nResetting system tasks' priority to default\n");
    SetTaskPrio("tLogTask", 0);
    SetTaskPrio("tShell0", 1);
    SetTaskPrio("tWdbTask", 3);
    SetTaskPrio("tVxdbgTask", 25);
    SetTaskPrio("tNet0", 50);
    SetTaskPrio("ipftps", 50);
    SetTaskPrio("ipcom_syslogd", 50);
    SetTaskPrio("ipcom_telnetd", 50);
    SetTaskPrio("tWvrBuffMgr", 100);
}

void SetSysTasksPrio(void)
{
    printf("\Setting system tasks' priorities\n");
    SetTaskPrio("tLogTask", 0);
    SetTaskPrio("tShell0", 201);
    SetTaskPrio("tWdbTask", 203);
    SetTaskPrio("tVxdbgTask", 200);
    SetTaskPrio("tNet0", 130); /****** should be set right below CI/TO */
    SetTaskPrio("ipftps", 202);
    SetTaskPrio("ipcom_syslogd", 205);
    SetTaskPrio("ipcom_telnetd", 204);
    SetTaskPrio("tWvrBuffMgr", 206);
}





