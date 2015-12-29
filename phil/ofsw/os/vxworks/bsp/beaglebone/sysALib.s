/* sysALib.s - Mistral AM335X system-dependent routines */

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
01a,19sep11,clx  created from mst_omap3530evm BSP.
*/

/*
DESCRIPTION
This module contains system-dependent routines written in assembly
language.  It contains the entry code, sysInit(), for VxWorks images
that start running from RAM, such as 'vxWorks'.  These images are
loaded into memory by some external program (e.g., a boot ROM) and then
started.  The routine sysInit() must come first in the text segment.
Its job is to perform the minimal setup needed to call the generic C
routine usrInit().

sysInit() masks interrupts in the processor and the interrupt
controller and sets the initial stack pointer.  Other hardware and
device initialization is performed later in the sysHwInit routine in
sysLib.c.

NOTE
The routines in this module don't use the "C" frame pointer %r11@ ! or
establish a stack frame.

INCLUDE FILES:

SEE ALSO:
\tb "ARMv7-A Architecture Reference Manual,"
\tb "AM335X ARM(r) Cortex(tm)-A8 Microprocessors (MPUs) Technical Reference Manual"
*/

#define _ASMLANGUAGE
#include <vxWorks.h>
#include <asm.h>
#include <regs.h>
#include <sysLib.h>
#include "config.h"
#include <arch/arm/mmuArmLib.h>
#include <hwif/intCtlr/vxbOmap35xxIntCtlr.h>

/* internals */
    .globl  FUNC(sysInit)           /* start of system code */
#ifndef _ARCH_SUPPORTS_PROTECT_INTERRUPT_STACK
    .globl  FUNC(sysIntStackSplit)  /* routine to split interrupt stack */
#endif  /* !_ARCH_SUPPORTS_PROTECT_INTERRUPT_STACK */

    .globl  FUNC(archPwrDown)       /* power down callback */

/* externals */

    .extern FUNC(usrInit)       /* system initialization routine */

#ifndef _ARCH_SUPPORTS_PROTECT_INTERRUPT_STACK
    .extern FUNC(vxSvcIntStackBase) /* base of SVC-mode interrupt stack */
    .extern FUNC(vxSvcIntStackEnd)  /* end of SVC-mode interrupt stack */
    .extern FUNC(vxIrqIntStackBase) /* base of IRQ-mode interrupt stack */
    .extern FUNC(vxIrqIntStackEnd)  /* end of IRQ-mode interrupt stack */
#endif  /* !_ARCH_SUPPORTS_PROTECT_INTERRUPT_STACK */

    .text
    .balign 4

/*******************************************************************************
*
* sysInit - start after boot
*
* This routine is the system start-up entry point for VxWorks in RAM, the
* first code executed after booting.  It disables interrupts, sets up
* the stack, and jumps to the C routine usrInit() in usrConfig.c.
*
* The initial stack is set to grow down from the address of sysInit().  This
* stack is used only by usrInit() and is never used again.  Memory for the
* stack must be accounted for when determining the system load address.
*
* SYNOPSIS
* \ss
* sysInit
*     (
*     int startType     /@ THIS IS NOT A CALLABLE ROUTINE @/
*     )
* \se
*
* NOTE: This routine should not be called by the user.
*
* RETURNS: N/A
*
* sysInit ()              /@ THIS IS NOT A CALLABLE ROUTINE @/
*
*/

_ARM_FUNCTION(sysInit)

    /*
     * Set processor and MMU to known state as follows (we may have not
     * been entered from a reset). We must do this before setting the CPU
     * mode as we must set PROG32/DATA32.
     *
     * MMU Control Register layout.
     *
     * bit
     *  0 M 0 MMU disabled
     *  1 A 0 Address alignment fault disabled, initially
     *  2 C 0 Data cache disabled
     *  3 W 0 Write Buffer disabled
     *  4 P 1 PROG32
     *  5 D 1 DATA32
     *  6 L 1 Should Be One (Late abort on earlier CPUs)
     *  7 B ? Endianness (1 => big)
     *  8 S 0 System bit to zero } Modifies MMU protections, not really
     *  9 R 1 ROM bit to one     } relevant until MMU switched on later.
     * 10 F 0 Should Be Zero
     * 11 Z 0 Should Be Zero (Branch prediction control on 810)
     * 12 I 0 Instruction cache control
     */

    /* Setup MMU Control Register */

    LDR r1, =MMU_INIT_VALUE        /* Defined in mmuArmLib.h */
    ORR r1, r1, #0x00000800        /* Enable Branch Prediction */
    MCR CP_MMU, 0, r1, c1, c0, 0   /* Write to MMU CR */

    MOV r1, #0                     /* data SBZ */
    MCR CP_MMU, 0, r1, c7, c10, 4  /* drain write-buffer */

    /* disable interrupts in CPU */

    MRS r1, cpsr
    BIC r1, r1, #MASK_MODE
    ORR r1, r1, #I_BIT | F_BIT
    MSR cpsr, r1

    mov r1, #0xFFFFFFFF            /* Set All 16 domains to mgr access*/
    mcr CP_MMU, 0, r1, c3, c0, 0   /* Set Domain Permissions */

    /*
     * Set Process ID Register to zero, this effectively disables
     * the process ID remapping feature.
     */

    MOV r1, #0
    MCR CP_MMU, 0, r1, c13, c0, 0

    /* Set Context ID Register to zero, including Address Space ID */

    MCR CP_MMU, 0, r1, c13, c0, 1

    /* disable interrupts in CPU and switch to SVC32 mode */

    MRS r1, cpsr
    BIC r1, r1, #MASK_MODE
    ORR r1, r1, #MODE_SVC32 | I_BIT | F_BIT
    MSR cpsr, r1

    /*
     * CPU INTERRUPTS DISABLED
     *
     * disable individual interrupts in the interrupt controller
     */

    LDR r2, L$_AM335X_MPU_INTC        /* R2->interrupt controller */
    MVN r1, #0                          /* 0xFFFFFFFF */

    /* disable all interrupts */

    STR r1, [r2, #OMAP_INTCPS_MIR(0)]
    STR r1, [r2, #OMAP_INTCPS_MIR(1)]
    STR r1, [r2, #OMAP_INTCPS_MIR(2)]
    STR r1, [r2, #OMAP_INTCPS_MIR(3)]

    /* set initial stack pointer so stack grows down from start of code */

    ADR sp, FUNC(sysInit)           /* initialize stack pointer */
    mov fp, #0                      /* initialize frame pointer */

#if defined(__ARM_NEON__)

    /* Allow full access to all coprocessors including Neon */

    mvn r1, #0
    MCR CP_MMU, 0, r1, c1, c0, 2
    ISB

    /* enable neon coprocessor */

    FMRX    r1, FPEXC
    orr r1, r1, #0x40000000
    FMXR    FPEXC, r1

#endif

#if defined(INCLUDE_BOOT_APP)
    /* Force boot type to be cold if coming into a RAM bootloader */
    mov r0,#BOOT_CLEAR
#endif

    /* Make sure Boot type is set correctly. visionClick doesn't */
    mov r1,#BOOT_NORMAL
    cmp r1,r0
    beq L$_Good_Boot

    mov r1,#BOOT_NO_AUTOBOOT
    cmp r1,r0
    beq L$_Good_Boot

    mov r1,#BOOT_CLEAR
    cmp r1,r0
    beq L$_Good_Boot

    mov r1,#BOOT_QUICK_AUTOBOOT
    cmp r1,r0
    beq L$_Good_Boot

    mov r0, #BOOT_NORMAL /* default startType */

L$_Good_Boot:

    /* now call usrInit (startType) */

#if (ARM_THUMB)
    LDR r12, L$_usrInit
    BX  r12
#else
    B   FUNC(usrInit)
#endif  /* (ARM_THUMB) */

#ifndef _ARCH_SUPPORTS_PROTECT_INTERRUPT_STACK
/*******************************************************************************
*
* sysIntStackSplit - split interrupt stack and set interrupt stack pointers
*
* This routine is called, via a function pointer, during kernel
* initialization.  It splits the allocated interrupt stack into IRQ and
* SVC-mode stacks and sets the processor's IRQ stack pointer. Note that
* the pointer passed points to the bottom of the stack allocated i.e.
* highest address+1.
*
* IRQ stack needs 6 words per nested interrupt;
* SVC-mode will need a good deal more for the C interrupt handlers.
* For now, use ratio 1:7 with any excess allocated to the SVC-mode stack
* at the lowest address.
*
* Note that FIQ is not handled by VxWorks so no stack is allocated for it.
*
* The stacks and the variables that describe them look like this.
* \cs
*
*         - HIGH MEMORY -
*     ------------------------ <--- vxIrqIntStackBase (r0 on entry)
*     |                      |
*     |       IRQ-mode       |
*     |    interrupt stack   |
*     |                      |
*     ------------------------ <--{ vxIrqIntStackEnd
*     |                      |    { vxSvcIntStackBase
*     |       SVC-mode       |
*     |    interrupt stack   |
*     |                      |
*     ------------------------ <--- vxSvcIntStackEnd
*         - LOW  MEMORY -
* \ce
*
* NOTE: This routine should not be called by the user.
*
* SYNOPSIS
* \ss
* void sysIntStackSplit
*     (
*     char *pBotStack   /@ pointer to bottom of interrupt stack @/
*     long size     /@ size of stack @/
*     )
* \se
*
* RETURNS:
*/

    .balign 4

_ARM_FUNCTION_CALLED_FROM_C(sysIntStackSplit)

    /*
     * r0 = base of space allocated for stacks (i.e. highest address)
     * r1 = size of space
     */

    SUB r2, r0, r1          /* r2->lowest usable address */
    LDR r3, L$_vxSvcIntStackEnd
    STR r2, [r3]            /*  == end of SVC-mode stack */
    SUB r2, r0, r1, ASR #3      /* leave 1/8 for IRQ */
    LDR r3, L$_vxSvcIntStackBase
    STR r2, [r3]

    /* now allocate IRQ stack, setting irq_sp */

    LDR r3, L$_vxIrqIntStackEnd
    STR r2, [r3]
    LDR r3, L$_vxIrqIntStackBase
    STR r0, [r3]

    MRS r2, cpsr
    BIC r3, r2, #MASK_MODE
    ORR r3, r3, #MODE_IRQ32 | I_BIT /* set irq_sp */
    MSR cpsr, r3
    MOV sp, r0

    /* switch back to original mode and return */

    MSR cpsr, r2

#if (ARM_THUMB)
    BX  lr
#else
    MOV pc, lr
#endif  /* (ARM_THUMB) */
#endif  /* !_ARCH_SUPPORTS_PROTECT_INTERRUPT_STACK */

/*******************************************************************************
*
* archPwrDown - turn the processor into reduced power mode
*
* SYNOPSIS
* \ss
* void archPwrDown
*   (
*   void
*   )
* \se
*
* This routine activates the reduced power mode.
* It is called by the scheduler when the kernel enters the idle loop.
* This function is called by default. Overload it by using routine
* vxArchPowerDownRtnSet().
*
* RETURNS: void
*
* SEE ALSO: vxArchPowerDownRtnSet().
*/
_ARM_FUNCTION_CALLED_FROM_C(archPwrDown)

/*
 * NB debugger doesn't like powering down.  Use foreverloop for debug.
 * foreverLoop:
 *       B     foreverLoop
 */

/* TODO: set processor to idle mode */

/* Return after waking up */

#if (ARM_THUMB)
    BX  lr
#else
    MOV pc, lr
#endif

/******************************************************************************/

/*
 * PC-relative-addressable pointers - LDR Rn,=sym is broken
 * note "_" after "$" to stop preprocessor performing substitution
 */

    .balign 4

#ifndef _ARCH_SUPPORTS_PROTECT_INTERRUPT_STACK
L$_vxSvcIntStackBase:
    .long   VAR(vxSvcIntStackBase)

L$_vxSvcIntStackEnd:
    .long   VAR(vxSvcIntStackEnd)

L$_vxIrqIntStackBase:
    .long   VAR(vxIrqIntStackBase)

L$_vxIrqIntStackEnd:
    .long   VAR(vxIrqIntStackEnd)
#endif  /* !_ARCH_SUPPORTS_PROTECT_INTERRUPT_STACK */

#if (ARM_THUMB)
L$_usrInit:
    .long   FUNC(usrInit)
#endif  /* (ARM_THUMB) */

L$_AM335X_MPU_INTC:
    .long AM335X_MPU_INTC

