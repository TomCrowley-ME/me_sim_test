/* romInit.s - TI AM335X ROM initialization module */

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
01b,29jun12,my_  correct cache disable code sequence (WIND00357169)
01a,08may12,my_  created from ti_dm81xx_evm 01a
*/

/*
DESCRIPTION
This module contains the entry code for VxWorks images that start
running from ROM, such as 'bootrom' and 'vxWorks_rom'.  The entry
point, romInit(), is the first code executed on power-up.  It performs
the minimal setup needed to call the generic C routine romStart() with
parameter BOOT_COLD.

romInit() masks interrupts in the processor and the interrupt
controller and sets the initial stack pointer (to STACK_ADRS which is
defined in configAll.h).  Other hardware and device initialization is
performed later in the sysHwInit routine in sysLib.c.

The routine sysToMonitor() jumps to a location after the beginning of
romInit, (defined by ROM_WARM_ADRS) to perform a "warm boot".  This
entry point allows a parameter to be passed to romStart().

The routines in this module don't use the "C" frame pointer %r11@ ! or
establish a stack frame.

INCLUDE FILES:

SEE ALSO:
\tb "ARMv7-A Architecture Reference Manual,"
\tb "AM335x ARM Cortex-A8 Microprocessors (MPUs) Technical Reference Manual"
*/

#define _ASMLANGUAGE
#include <vxWorks.h>
#include <sysLib.h>
#include <asm.h>
#include <regs.h>
#include <config.h>
#include <arch/arm/mmuArmLib.h>
#include <hwif/intCtlr/vxbOmap35xxIntCtlr.h>

/* internals */

    .globl  FUNC(romInit)       /* start of system code */
    .globl  VAR(sdata)      /* start of data */
    .globl  _sdata

/* externals */

    .extern FUNC(romStart)  /* system initialization routine */

    /* externals */

#ifdef BOOTROM_FAST_BOOT
    .globl FUNC(sysBspBootCacheSync)
    .globl FUNC(sysBspBootCacheSyncPost)
#endif

    .data
_sdata:
VAR_LABEL(sdata)
    .asciz  "start of data"
    .balign 4

/* variables */

    .text
    .balign 4

/*******************************************************************************
*
* romInit - entry point for VxWorks in ROM
*
* SYNOPSIS
* \ss
* romInit
*     (
*     int startType /@ only used by 2nd entry point @/
*     )
* \se
*
* RETURNS: N/A
*
* INTERNAL
* sysToMonitor examines the ROM for the first instruction and the string
* "Copy" in the third word so if this changes, sysToMonitor must be updated.
*/

_ARM_FUNCTION(romInit)
_romInit:
cold:
    MOV r0, #BOOT_COLD  /* fall through to warm boot entry */
warm:
    B   start

    /* copyright notice appears at beginning of ROM (in TEXT segment) */

    .ascii   "\nCopyright 2011 Wind River Systems, Inc."
    .balign 4

start:

    MOV r12, r0

    /*
     * Set processor and MMU to known state as follows (we may have not
     * been entered from a reset). We must do this before setting the CPU
     * mode as we must set PROG32/DATA32.
     *
     * MMU Control Register layout.
     *
     * bit
     *  0    M 0 MMU disabled
     *  1    A 0 Address alignment fault disabled, initially
     *  2    C 0 Data cache disabled
     *  6:3  - 0xf Should Be One
     * 10:7  - 0x0 Should Be Zero
     * 11    Z 0 Branch Prediction disabled
     * 12    I 0 Instruction cache disabled
     * 13    V 0 Exception Vectors at 0x0
     * 24:14 - 0x0  (read as b01100010100)
     * 25   EE 0 CPSR E=0 on exception
     * 26    - 0 Should Be Zero
     * 27 NMFI 0 FIQ maskable (Read-only)
     * 28  TRE 0 TEX remap disabled
     * 29  AFE 0 set to AP[0] behavior
     * 30   TE 0 Thumb exception disabled (enable ARM handling)
     * 31    - 0 Should Be Zero
     */

     MRC CP_MMU, 0, r1, c1, c0, 0     /* Read control register into r1 */
     LDR r2, =CACHE_DC_ENABLE
     AND r1, r1, r2
     TEQ r1, r2
     BNE cacheClearPass

    _CORTEX_AR_ENTIRE_DATA_CACHE_OP (c14)

    MOV r0, #0
    MCR CP_MMU , 0, r0, c7, c5, 0      /* Invalidate I-cache */

    ISB
    DSB

    /* Setup MMU Control Register */
    
cacheClearPass:
    LDR r1, =MMU_INIT_VALUE        /* Defined in mmuArmLib.h */
    ORR r1, r1, #0x00000800        /* Enable Branch Prediction */
    MCR CP_MMU, 0, r1, c1, c0, 0   /* Write to MMU CR */

    /*
     * If MMU was on before this, then we'd better hope it was set
     * up for flat translation or there will be problems. The next
     * 2/3 instructions will be fetched "translated" (number depends
     * on CPU).
     *
     * We would like to discard the contents of the Write-Buffer
     * altogether, but there is no facility to do this. Failing that,
     * we do not want any pending writes to happen at a later stage,
     * so drain the Write-Buffer, i.e. force any pending writes to
     * happen now.
     */

    DSB

    MOV r0, r12 /* restore startType */

    /* disable interrupts in CPU */

    MRS r1, cpsr
    BIC r1, r1, #MASK_MODE
    ORR r1, r1, #I_BIT | F_BIT
    MSR cpsr, r1

    mov r1, #0xFFFFFFFF             /* Set All 16 domains to mgr access*/
    mcr CP_MMU, 0, r1, c3, c0, 0    /* Set Domain Permissions */

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

    LDR r2, L$_AM335X_MPU_INTC          /* R2->interrupt controller */
    MVN r1, #0                          /* 0xFFFFFFFF */

    /* disable all interrupts */

    STR r1, [r2, #OMAP_INTCPS_MIR(0)]
    STR r1, [r2, #OMAP_INTCPS_MIR(1)]
    STR r1, [r2, #OMAP_INTCPS_MIR(2)]
    STR r1, [r2, #OMAP_INTCPS_MIR(3)]

#ifdef BOOTROM_FAST_BOOT

    LDR r3, =SYS_MMU_PAGE_TABLE_BASE

    /* get the address offset of descriptor for DRAM memory region */

    LDR r2, =LOCAL_MEM_LOCAL_ADRS
    MOV r2, r2, LSR ARM_IMM 20  /* get the index of DRAM memory base address */
    MOV r2, r2, LSL ARM_IMM 2   /* size of MMU descriptor is 4 Bytes */
    ADD r3, r3, r2

    LDR r12, =LOCAL_MEM_SIZE_TOTAL
    MOV r12, r12, LSR ARM_IMM 20 /* the maximum descriptor index for DRAM */

    MOV r1, #0

sysFastBootMmuCfg:
    LDR r2, =MMU_SECTION_DESC_AP_READ_WRITE     | \
             MMU_SECTION_DESC_SECTION_INDICATE  | \
             MMU_SECTION_DESC_CACHE_WRITE_BACK  | \
             LOCAL_MEM_LOCAL_ADRS

    ORR r2, r2, r1, LSL ARM_IMM 20

    STR r2, [r3]
    ADD r3, r3, #4      /* increase MMU descriptor address */
    ADD r1, r1, #1      /* increase MMU descriptor index */
    CMP r1, r12
    BLT sysFastBootMmuCfg

    LDR r1, =0xffffffff
    MCR CP_MMU, 0, r1, c3, c0, 0    /* write DACR */

    MOV r1, #0
    MCR CP_MMU, 0, r1, c7, c5, 0    /* invalidate BTB */
    ISB
    DSB

    LDR r1, =SYS_MMU_PAGE_TABLE_BASE
    MCR CP_MMU, 0, r1, c2, c0, 0    /* load the TTBR */
    MOV r1, #0
    MCR CP_MMU, 0, r1, c8, c7, 0    /* invalidate all I & D TLBs */
    ISB
    DSB

    MRC CP_MMU, 0, r1, c1, c0, 0    /* read control register */
    LDR r2, =MMUCR_I_ENABLE | MMUCR_C_ENABLE | MMUCR_M_ENABLE | MMUCR_W_ENABLE
    ORR r1, r1, r2                  /* enable MMU and I/D cache */
    MCR CP_MMU, 0, r1, c1, c0, 0    /* write control register */

#endif /* BOOTROM_FAST_BOOT */

    /* start romStart in RAM */

    LDR     sp, L$_STACK_ADDR
    MOV     fp, #0                  /* zero frame pointer */

    /* jump to C entry point in ROM: routine - entry point + ROM base */

#if (ARM_THUMB)
    LDR r12, L$_rStrtInRom
    ORR r12, r12, #1        /* force Thumb state */
    BX  r12
#else
    LDR pc, L$_rStrtInRom
#endif  /* (ARM_THUMB) */

#ifdef BOOTROM_FAST_BOOT

_ARM_FUNCTION_CALLED_FROM_C(sysBspBootCacheSync)

    STMFD sp!, {r0-r8}                      /* save registers */

    _CORTEX_AR_ENTIRE_DATA_CACHE_OP(c14)    /* flush+invalidate all D-cache */

    MOV r4, #0                              /* data SBZ */
    MCR CP_MMU, 0, r4, c7, c5, 0            /* invalidate all I-cache and BTB */
    ISB
    DSB

    LDMIA sp!, {r0-r8}                      /* restore registers */;

    MOV pc, lr

_ARM_FUNCTION_CALLED_FROM_C(sysBspBootCacheSyncPost)

    STMFD sp!, {r0-r8}		/* save registers */

    MRC CP_MMU, 0, r4, c1, c0, 0 /* read control register */
    LDR r5, =MMUCR_I_ENABLE | MMUCR_C_ENABLE | MMUCR_M_ENABLE
    BIC r4, r4, r5               /* disable MMU and I/D cache */
    MCR CP_MMU, 0, r4, c1, c0, 0 /* write control register */

    _CORTEX_AR_ENTIRE_DATA_CACHE_OP(c14)    /* flush+invalidate all D-cache */

    LDMIA sp!, {r0-r8}		/* restore registers */;

    MOV pc, lr

#endif /* BOOTROM_FAST_BOOT */

/******************************************************************************/

/*
 * PC-relative-addressable pointers - LDR Rn,=sym is broken
 * note "_" after "$" to stop preprocessor performing substitution
 */

    .balign 4

L$_rStrtInRom:
    .long   ROM_TEXT_ADRS + FUNC(romStart) - FUNC(romInit)

L$_STACK_ADDR:
    .long   STACK_ADRS

L$_AM335X_MPU_INTC:
    .long   AM335X_MPU_INTC
