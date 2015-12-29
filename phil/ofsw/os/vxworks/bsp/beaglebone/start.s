/* start.s - startup routine for TI AM335X */

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
01a,05jul11,my_  written.
*/

/*
DESCRIPTION
This file contains the entry code of ti_dm81xx_evm bootloader .
When building bootrom.bin (or other types of vxWorks bootloader)
this piece of code will be put at the beginning of the
final binary image.
*/


#define _ASMLANGUAGE
#include "beaglebone.h"

    .extern wrs_kernel_bss_end
    .globl _start

    .text
    .balign 4

_start:

    .word _wrs_kernel_bss_end - _start - AM335X_ROM_HEADER_SIZE
    .word AM335X_NANDBOOT_RAM_ADRS

    LDR pc, TEXT_ENTRY

TEXT_ENTRY:
    .word reset

    .fill AM335X_INIT_STACK_SIZE - AM335X_ROM_HEADER_SIZE, 1, 0

reset:

    /* disable interrupts in CPU and switch to SVC32 mode */

    MRS    r0, cpsr
    BIC    r0, r0, #0x1f
    ORR    r0, r0, #0xd3
    MSR    cpsr, r0

    /* Invalidate L1 I/D */
    MOV    r0, #0
    MCR    p15, 0, r0, c8, c7, 0
    MCR    p15, 0, r0, c7, c5, 0
    MCR    p15, 0, r0, c7, c5, 6
    MCR    p15, 0, r0, c7, c10, 4
    MCR    p15, 0, r0, c7, c5, 4

    /* disable MMU stuff and caches */
    MRC    p15, 0, r0, c1, c0, 0
    BIC    r0, r0, #0x00002000
    BIC    r0, r0, #0x00000007
    ORR    r0, r0, #0x00000002
    ORR    r0, r0, #0x00000800
    ORR    r0, r0, #0x00001000
    MCR    p15, 0, r0, c1, c0, 0

    _CORTEX_AR_ENTIRE_DATA_CACHE_OP(c14)    /* flush+invalidate all D-cache */

    MRC    p15, 0, r0, c1, c0, 1
    BIC    r0, r0, #0x2
    MCR    p15, 0, r0, c1, c0, 1

    /* load stack and run C routines */

    LDR    sp, L3RAM_STACK

    BL     sysHwInit

    /* deadloop, in case we return from errors.*/

dead:
    B   dead            /* loop here forever */

L3RAM_STACK:
    .word (AM335X_NANDBOOT_RAM_ADRS + AM335X_INIT_STACK_SIZE - 0x4)

