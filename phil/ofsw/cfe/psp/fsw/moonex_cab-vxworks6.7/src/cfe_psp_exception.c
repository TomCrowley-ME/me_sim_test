/******************************************************************************
**
** File:  cfe_psp_exception.c
**
**      UT699 vxWorks 6.7 Version
**
**      Copyright (c) 2004-2012, United States government as represented by the
**      administrator of the National Aeronautics Space Administration.
**      All rights reserved. This software(cFE) was created at NASA's Goddard
**      Space Flight Center pursuant to government contracts.
**
**      This is governed by the NASA Open Source Agreement and may be used,
**      distributed and modified only pursuant to the terms of that agreement.
**
**
**
** Purpose:
**   cFE PSP Exception related functions.
**
** History:
**   2007/05/29  A. Cudmore      | vxWorks 6.2 MCP750 version
**
******************************************************************************/

/*
**  Include Files
*/
#include <stdio.h>
#include <string.h>
#include <vxWorks.h>
#include <sysLib.h>
#include "excLib.h"
#include "taskLib.h"
#include "vxLib.h"
#include "esf.h"

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
** Types and prototypes for this module
*/


/*
** BSP Specific defines
*/

/*
**  External Declarations
*/

/*
** Global variables
*/

CFE_PSP_ExceptionContext_t CFE_PSP_ExceptionContext;
char                  CFE_PSP_ExceptionReasonString[256];

/*
**
** IMPORTED FUNCTIONS
**
*/

void CFE_ES_EXCEPTION_FUNCTION(uint32  HostTaskId,     uint8 *ReasonString,
                                 uint32 *ContextPointer, uint32 ContextSize);

/*
**
** LOCAL FUNCTION PROTOTYPES
**
*/

void CFE_PSP_ExceptionHook ( int task_id, int vector, uint8* pEsf );


/***************************************************************************
 **                        FUNCTIONS DEFINITIONS
 ***************************************************************************/

/*
**
**   Name: CFE_PSP_AttachExceptions
**
**   Purpose: This function Initializes the task execptions and adds a hook
**              into the VxWorks exception handling.  The below hook is called
**              for every exception that VxWorks catches.
**
**   Notes: if desired - to attach a custom handler put following code in
**          this function:  excConnect ((VOIDFUNCPTR*)VECTOR, ExceptionHandler);
**
*/

void CFE_PSP_AttachExceptions(void)
{
    excHookAdd((FUNCPTR)CFE_PSP_ExceptionHook);
    OS_printf("CFE_PSP: Attached cFE Exception Handler. Context Size = %d bytes.\n",CFE_PSP_CPU_CONTEXT_SIZE);
}


/*
** Name: CFE_PSP_ExceptionHook
**
** Purpose: Make the proper call to CFE_ES_ProcessCoreException
**
** Notes:   pEsf - pointer to exception stack frame.
**
*/
void CFE_PSP_ExceptionHook (int task_id, int vector, uint8* pEsf )
{

    char *TaskName;

    /*
    ** Get the vxWorks task name
    */
    TaskName = taskName(task_id);

    if ( TaskName == NULL )
    {
       sprintf(CFE_PSP_ExceptionReasonString, "Exception: Vector=0x%06X, vxWorks Task Name=NULL, Task ID=0x%08X",
               vector,task_id);
    }
    else
    {
       sprintf(CFE_PSP_ExceptionReasonString, "Exception: Vector=0x%06X, vxWorks Task Name=%s, Task ID=0x%08X",
                vector, TaskName, task_id);
    }

    /*
    ** Save Exception Stack frame (process trap registers)
    */
    memcpy(&(CFE_PSP_ExceptionContext.esf), pEsf, PT_REGS_SZ);

    /*
    ** Save floating point registers
    */
    fppSave(&CFE_PSP_ExceptionContext.fp);

    /*
    ** Call the Generic cFE routine to finish processing the exception and
    ** restart either the offending app or everything
    */
    CFE_ES_EXCEPTION_FUNCTION((uint32 )task_id, (uint8 *)CFE_PSP_ExceptionReasonString,
                                (uint32 *)&CFE_PSP_ExceptionContext, sizeof(CFE_PSP_ExceptionContext_t));

} /* end function */


/*
**
**   Name: CFE_PSP_SetDefaultExceptionEnvironment
**
**   Purpose: This function sets a default exception environment that can be used
**
**   Notes: The exception environment is local to each task Therefore this must be
**          called for each task that that wants to do floating point and catch exceptions
**          Currently, this is automatically called from CFE_ES_RegisterApp for every app
*/
void CFE_PSP_SetDefaultExceptionEnvironment(void)
{
    /* We very likely won't be setting the PSR.PIL field to anything, since we lose all interrupts before disabling any exceptions */
    /* TODO: Figure out which (if any) of the TEM bits of the FSR we want to set, add support routines to set/unset them, and call it from here */
}

