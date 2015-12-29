/* sysALib.s - LEON/SPARC locore */

#define _ASMLANGUAGE
#include "vxWorks.h"
#include <vsbConfig.h>
#include "sysLib.h"
#include "config.h"
#include "regs.h"
#include "asm.h"
#include "bootloader.h"
#include "arch/sparc/leon.h"
#include "arch/sparc/head.h"
#include "arch/sparc/asi.h"
#define _INSIDE_SYSALIB_S_

	.data
	/* globals */
#if 0
	DATA_EXPORT(_memory_top)
#endif
	DATA_EXPORT(_vxSparc_sm_anchor)
	DATA_EXPORT(_vxSparc_bootline)
	DATA_EXPORT(_vxSparc_exc_msg)

	FUNC_EXPORT(_sysInit)	/* start of system code */
	FUNC_EXPORT(_trap_table)
#ifdef  _WRS_CONFIG_SMP
	FUNC_EXPORT(_master_go)
#endif
	/* externals */
	FUNC_IMPORT(_slave_go)
	FUNC_IMPORT(usrInit)
	FUNC_IMPORT(_window_overflow)
	FUNC_IMPORT(_window_underflow)
	FUNC_IMPORT(_flush_windows)
	/*FUNC_IMPORT(_fpdis_enable)*/
	FUNC_IMPORT(_vxSparc_syscall)
	FUNC_IMPORT(_vxSparc_dbgtrap)
	FUNC_IMPORT(_irqcall)
	FUNC_IMPORT(_irqcall_disableirq)
#if 0
	FUNC_EXPORT(sparc_memcpy_half_dword)
#endif
#ifdef SPARC_MEMCPY_DWORD_HALF
	FUNC_EXPORT(sparc_memcpy_dword_half)
#endif

/* local CPU ID storage */
	.align 8
sysCpuId:
	.long 	(MAX_CPU_ID + 1)

	_WRS_TEXT_SEG_START


/***************************************************************************
*
* sysInit - start after boot
*
* This is the system start-up entry point for VxWorks in RAM, the
* first code executed after booting.  It disables interrupts, sets up
* the stack, and jumps to the C routine usrInit() in usrConfig.c.
*
* The initial stack is set to grow down from the address of sysInit().  This
* stack is used only by usrInit() and is never used again.  Memory for the
* stack must be accounted for when determining the system load address.
*/

FUNC_BEGIN(_sysInit)
FUNC_BEGIN(_trap_table)

  VXSPARC_TRAPL(_hardreset)		/* 00 reset trap */
  VXSPARC_SRMMU_TFAULT			/* 01 instruction_access_exception (in mmu_asm.S) */
  VXSPARC_BAD_TRAP(02)			/* 02 illegal_instruction */
  VXSPARC_BAD_TRAP(03)			/* 03 priveleged_instruction */
#ifndef VXSPARC_SOFT_FLOAT
  VXSPARC_BAD_TRAP(04)			/* 04 fp_disabled */
#else
  VXSPARC_BAD_TRAP(04)			/* 04 fp_disabled */
#endif
#ifndef VXSPARC_FLAT
  VXSPARC_TRAP(_window_overflow)	/* 05 window_overflow */
  VXSPARC_TRAP(_window_underflow)	/* 06 window_underflow */
#else
  VXSPARC_BAD_TRAP(05) VXSPARC_BAD_TRAP(06);
#endif
  VXSPARC_BAD_TRAP(0x7)/*VXSPARC_MNA*/	/* 07 memory_address_not_aligned */
  VXSPARC_BAD_TRAP(0x8)			/* 08 fp_exception */
  VXSPARC_BAD_TRAP(SPARCVX_TRAPNR_DATA_ACC_EXC)  /* 09 data_access_exception */
  VXSPARC_BAD_TRAP(0xa)			/* 0A tag_overflow */

  VXSPARC_BAD_TRAP(0xb)			/* 0B undefined */
  VXSPARC_BAD_TRAP(0xc)			/* 0C undefined */
  VXSPARC_BAD_TRAP(0xd)			/* 0D undefined */
  VXSPARC_BAD_TRAP(0xe)			/* 0E undefined */
  VXSPARC_BAD_TRAP(0xf)			/* 0F undefined */
  VXSPARC_BAD_TRAP(0x10)		/* 10 undefined */

  /* Interrupt entries */
  VXSPARC_TRAP_ENTRY_INTERRUPT(1)		/* 11 interrupt level 1 */
  VXSPARC_TRAP_ENTRY_INTERRUPT(2)		/* 12 interrupt level 2 */
  VXSPARC_TRAP_ENTRY_INTERRUPT(3)		/* 13 interrupt level 3 */
  VXSPARC_TRAP_ENTRY_INTERRUPT(4)		/* 14 interrupt level 4 */
  VXSPARC_TRAP_ENTRY_INTERRUPT(5)		/* 15 interrupt level 5 */
  VXSPARC_TRAP_ENTRY_INTERRUPT(6)		/* 16 interrupt level 6 */
  VXSPARC_TRAP_ENTRY_INTERRUPT(7)		/* 17 interrupt level 7 */
  VXSPARC_TRAP_ENTRY_INTERRUPT(8)		/* 18 interrupt level 8 */
  VXSPARC_TRAP_ENTRY_INTERRUPT(9)		/* 19 interrupt level 9 */
  VXSPARC_TRAP_ENTRY_INTERRUPT(10)		/* 1A interrupt level 1 */
  VXSPARC_TRAP_ENTRY_INTERRUPT(11)		/* 1B interrupt level 11 */
  VXSPARC_TRAP_ENTRY_INTERRUPT(12)		/* 1C interrupt level 12 */
  VXSPARC_TRAP_ENTRY_INTERRUPT(13)		/* 1D interrupt level 13 */
  VXSPARC_TRAP_ENTRY_INTERRUPT(14)		/* 1E interrupt level 14 */
  VXSPARC_TRAP_ENTRY_INTERRUPT_NMI(15)		/* 1F interrupt level 15 */
  VXSPARC_BAD_TRAP(0x20) VXSPARC_BAD_TRAP(0x21) VXSPARC_BAD_TRAP(0x22) VXSPARC_BAD_TRAP(0x23)	/* 20 - 23 undefined */
  VXSPARC_BAD_TRAP(0x24)					/* 24 cp_disabled */
  VXSPARC_BAD_TRAP(0x25) VXSPARC_BAD_TRAP(0x26) VXSPARC_BAD_TRAP(0x27)	/* 25 - 27 undefined */
  VXSPARC_BAD_TRAP(0x28)					/* 28 cp_exception */
  VXSPARC_BAD_TRAP(0x29) VXSPARC_BAD_TRAP(0x2a) VXSPARC_BAD_TRAP(0x2b)	/* 29 - 2B undefined */
  VXSPARC_BAD_TRAP(0x2c) VXSPARC_BAD_TRAP(0x2d) VXSPARC_BAD_TRAP(0x2e) VXSPARC_BAD_TRAP(0x2f)	/* 2C - 2F undefined */
  VXSPARC_BAD_TRAP(0x30) VXSPARC_BAD_TRAP(0x31) VXSPARC_BAD_TRAP(0x32) VXSPARC_BAD_TRAP(0x33)	/* 30 - 33 undefined */
  VXSPARC_BAD_TRAP(0x34) VXSPARC_BAD_TRAP(0x35) VXSPARC_BAD_TRAP(0x36) VXSPARC_BAD_TRAP(0x37)	/* 34 - 37 undefined */
  VXSPARC_BAD_TRAP(0x38) VXSPARC_BAD_TRAP(0x39) VXSPARC_BAD_TRAP(0x3a) VXSPARC_BAD_TRAP(0x3b)	/* 38 - 3B undefined */
  VXSPARC_BAD_TRAP(0x3c) VXSPARC_BAD_TRAP(0x3d) VXSPARC_BAD_TRAP(0x3e) VXSPARC_BAD_TRAP(0x3f)	/* 3C - 3F undefined */
  VXSPARC_BAD_TRAP(0x40) VXSPARC_BAD_TRAP(0x41) VXSPARC_BAD_TRAP(0x42) VXSPARC_BAD_TRAP(0x43)	/* 40 - 43 undefined */
  VXSPARC_BAD_TRAP(0x44) VXSPARC_BAD_TRAP(0x45) VXSPARC_BAD_TRAP(0x46) VXSPARC_BAD_TRAP(0x47)	/* 44 - 47 undefined */
  VXSPARC_BAD_TRAP(0x48) VXSPARC_BAD_TRAP(0x49) VXSPARC_BAD_TRAP(0x4a) VXSPARC_BAD_TRAP(0x4b)	/* 48 - 4B undefined */
  VXSPARC_BAD_TRAP(0x4c) VXSPARC_BAD_TRAP(0x4d) VXSPARC_BAD_TRAP(0x4e) VXSPARC_BAD_TRAP(0x4f)	/* 4C - 4F undefined */
  VXSPARC_BAD_TRAP(0x50) VXSPARC_BAD_TRAP(0x51) VXSPARC_BAD_TRAP(0x52) VXSPARC_BAD_TRAP(0x53)	/* 50 - 53 undefined */
  VXSPARC_BAD_TRAP(0x54) VXSPARC_BAD_TRAP(0x55) VXSPARC_BAD_TRAP(0x56) VXSPARC_BAD_TRAP(0x57)	/* 54 - 57 undefined */
  VXSPARC_BAD_TRAP(0x58) VXSPARC_BAD_TRAP(0x59) VXSPARC_BAD_TRAP(0x5a) VXSPARC_BAD_TRAP(0x5b)	/* 58 - 5B undefined */
  VXSPARC_BAD_TRAP(0x5c) VXSPARC_BAD_TRAP(0x5d) VXSPARC_BAD_TRAP(0x5e) VXSPARC_BAD_TRAP(0x5f)	/* 5C - 5F undefined */
  VXSPARC_BAD_TRAP(0x60) VXSPARC_BAD_TRAP(0x61) VXSPARC_BAD_TRAP(0x62) VXSPARC_BAD_TRAP(0x63)	/* 60 - 63 undefined */
  VXSPARC_BAD_TRAP(0x64) VXSPARC_BAD_TRAP(0x65) VXSPARC_BAD_TRAP(0x66) VXSPARC_BAD_TRAP(0x67)	/* 64 - 67 undefined */
  VXSPARC_BAD_TRAP(0x68) VXSPARC_BAD_TRAP(0x69) VXSPARC_BAD_TRAP(0x6a) VXSPARC_BAD_TRAP(0x6b)	/* 68 - 6B undefined */
  VXSPARC_BAD_TRAP(0x6c) VXSPARC_BAD_TRAP(0x6d) VXSPARC_BAD_TRAP(0x6e) VXSPARC_BAD_TRAP(0x6f)	/* 6C - 6F undefined */
  VXSPARC_BAD_TRAP(0x70) VXSPARC_BAD_TRAP(0x71) VXSPARC_BAD_TRAP(0x72) VXSPARC_BAD_TRAP(0x73)	/* 70 - 73 undefined */
  VXSPARC_BAD_TRAP(0x74) VXSPARC_BAD_TRAP(0x75) VXSPARC_BAD_TRAP(0x76) VXSPARC_BAD_TRAP(0x77)	/* 74 - 77 undefined */
  VXSPARC_BAD_TRAP(0x78) VXSPARC_BAD_TRAP(0x79) VXSPARC_BAD_TRAP(0x7a) VXSPARC_BAD_TRAP(0x7b)	/* 78 - 7B undefined */
  VXSPARC_BAD_TRAP(0x7c) VXSPARC_BAD_TRAP(0x7d) VXSPARC_BAD_TRAP(0x7e) VXSPARC_BAD_TRAP(0x7f)	/* 7C - 7F undefined */

  /* Software traps */
  VXSPARC_SOFT_TRAP(0x80) VXSPARC_SOFT_TRAP(0x81) VXSPARC_TRAP(_irqcall) 	/* 80 - 82  */
#ifndef VXSPARC_FLAT
  VXSPARC_TRAP_ENTRY(_flush_windows)			/* 83 */
#else
  VXSPARC_SOFT_TRAP(0x83)
#endif
  VXSPARC_DBRK_TRAP(0x84)                               /* 84 dbg call ta 0x4 */
  VXSPARC_IRQDIS_TRAP(0x85)                                                     /* 85 */
  /*VXSPARC_SOFT_TRAP(0x86) VXSPARC_SOFT_TRAP(0x87)*/	                        /* 86 - 87 */
#ifndef _WRS_CONFIG_SMP
  VXSPARC_SOFT_TRAP(0x86)                              /* 86 */
  VXSPARC_SOFT_TRAP(0x87)                              /* 87 */
#else
  VXSPARC_IRQDIS_TRAP_E(0x86)                          /* 86 */
  VXSPARC_SOFT_TRAP(0x87)                              /* 87 */
#endif
  VXSPARC_SYSCALL_TRAP(0x88)				                        /* 88 syscall ta 0x8 */
  VXSPARC_SOFT_TRAP(0x89)                              /* 89 */
  VXSPARC_PATCH_TRAP(0x8a)                             /* 8a scope tools patch trap "ta 0xa" */
  VXSPARC_IRQEN_TRAP(0x8b)                              /* 8B */
  VXSPARC_SOFT_TRAP(0x8c) VXSPARC_SOFT_TRAP(0x8d) VXSPARC_SOFT_TRAP(0x8e) VXSPARC_SOFT_TRAP(0x8f)	/* 8C - 8F */
  VXSPARC_SOFT_TRAP(0x90) VXSPARC_SOFT_TRAP(0x91) VXSPARC_SOFT_TRAP(0x92) VXSPARC_SOFT_TRAP(0x93)	/* 90 - 93 */
  VXSPARC_SOFT_TRAP(0x94) VXSPARC_SOFT_TRAP(0x95) VXSPARC_SOFT_TRAP(0x96) VXSPARC_SOFT_TRAP(0x97)	/* 94 - 97 */
  VXSPARC_SOFT_TRAP(0x98) VXSPARC_SOFT_TRAP(0x99) VXSPARC_SOFT_TRAP(0x9a) VXSPARC_SOFT_TRAP(0x9b)	/* 98 - 9B */
  VXSPARC_SOFT_TRAP(0x9c) VXSPARC_SOFT_TRAP(0x9d) VXSPARC_SOFT_TRAP(0x9e) VXSPARC_SOFT_TRAP(0x9f)	/* 9C - 9F */
  VXSPARC_SOFT_TRAP(0xa0) VXSPARC_SOFT_TRAP(0xa1) VXSPARC_SOFT_TRAP(0xa2) VXSPARC_SOFT_TRAP(0xa3)	/* A0 - A3 */
  VXSPARC_SOFT_TRAP(0xa4) VXSPARC_SOFT_TRAP(0xa5) VXSPARC_SOFT_TRAP(0xa6) VXSPARC_SOFT_TRAP(0xa7)	/* A4 - A7 */
  VXSPARC_SOFT_TRAP(0xa8) VXSPARC_SOFT_TRAP(0xa9) VXSPARC_SOFT_TRAP(0xaa) VXSPARC_SOFT_TRAP(0xab)	/* A8 - AB */
  VXSPARC_SOFT_TRAP(0xac) VXSPARC_SOFT_TRAP(0xad) VXSPARC_SOFT_TRAP(0xae) VXSPARC_SOFT_TRAP(0xaf)	/* AC - AF */
  VXSPARC_SOFT_TRAP(0xb0) VXSPARC_SOFT_TRAP(0xb1) VXSPARC_SOFT_TRAP(0xb2) VXSPARC_SOFT_TRAP(0xb3)	/* B0 - B3 */
  VXSPARC_SOFT_TRAP(0xb4) VXSPARC_SOFT_TRAP(0xb5) VXSPARC_SOFT_TRAP(0xb6) VXSPARC_SOFT_TRAP(0xb7)	/* B4 - B7 */
  VXSPARC_SOFT_TRAP(0xb8) VXSPARC_SOFT_TRAP(0xb9) VXSPARC_SOFT_TRAP(0xba) VXSPARC_SOFT_TRAP(0xbb)	/* B8 - BB */
  VXSPARC_SOFT_TRAP(0xbc) VXSPARC_SOFT_TRAP(0xbd) VXSPARC_SOFT_TRAP(0xbe) VXSPARC_SOFT_TRAP(0xbf)	/* BC - BF */
  VXSPARC_SOFT_TRAP(0xc0) VXSPARC_SOFT_TRAP(0xc1) VXSPARC_SOFT_TRAP(0xc2) VXSPARC_SOFT_TRAP(0xc3)	/* C0 - C3 */
  VXSPARC_SOFT_TRAP(0xc4) VXSPARC_SOFT_TRAP(0xc5) VXSPARC_SOFT_TRAP(0xc6) VXSPARC_SOFT_TRAP(0xc7)	/* C4 - C7 */
  VXSPARC_SOFT_TRAP(0xc8) VXSPARC_SOFT_TRAP(0xc9) VXSPARC_SOFT_TRAP(0xca) VXSPARC_SOFT_TRAP(0xcb)	/* C8 - CB */
  VXSPARC_SOFT_TRAP(0xcc) VXSPARC_SOFT_TRAP(0xcd) VXSPARC_SOFT_TRAP(0xce) VXSPARC_SOFT_TRAP(0xcf)	/* CC - CF */
  VXSPARC_SOFT_TRAP(0xd0) VXSPARC_SOFT_TRAP(0xd1) VXSPARC_SOFT_TRAP(0xd2) VXSPARC_SOFT_TRAP(0xd3)	/* D0 - D3 */
  VXSPARC_SOFT_TRAP(0xd4) VXSPARC_SOFT_TRAP(0xd5) VXSPARC_SOFT_TRAP(0xd6) VXSPARC_SOFT_TRAP(0xd7)	/* D4 - D7 */
  VXSPARC_SOFT_TRAP(0xd8) VXSPARC_SOFT_TRAP(0xd9) VXSPARC_SOFT_TRAP(0xda) VXSPARC_SOFT_TRAP(0xdb)	/* D8 - DB */
  VXSPARC_SOFT_TRAP(0xdc) VXSPARC_SOFT_TRAP(0xdd) VXSPARC_SOFT_TRAP(0xde) VXSPARC_SOFT_TRAP(0xdf)	/* DC - DF */
  VXSPARC_SOFT_TRAP(0xe0) VXSPARC_SOFT_TRAP(0xe1) VXSPARC_SOFT_TRAP(0xe2) VXSPARC_SOFT_TRAP(0xe3)	/* E0 - E3 */
  VXSPARC_SOFT_TRAP(0xe4) VXSPARC_SOFT_TRAP(0xe5) VXSPARC_SOFT_TRAP(0xe6) VXSPARC_SOFT_TRAP(0xe7)	/* E4 - E7 */
  VXSPARC_SOFT_TRAP(0xe8) VXSPARC_SOFT_TRAP(0xe9) VXSPARC_SOFT_TRAP(0xea) VXSPARC_SOFT_TRAP(0xeb)	/* E8 - EB */
  VXSPARC_SOFT_TRAP(0xec) VXSPARC_SOFT_TRAP(0xed) VXSPARC_SOFT_TRAP(0xew) VXSPARC_SOFT_TRAP(0xef)	/* EC - EF */
  VXSPARC_SOFT_TRAP(0xf0) VXSPARC_SOFT_TRAP(0xf1) VXSPARC_SOFT_TRAP(0xf2) VXSPARC_SOFT_TRAP(0xf3)	/* F0 - F3 */
  VXSPARC_SOFT_TRAP(0xf4) VXSPARC_SOFT_TRAP(0xf5) VXSPARC_SOFT_TRAP(0xf6) VXSPARC_SOFT_TRAP(0xf7)	/* F4 - F7 */
  VXSPARC_SOFT_TRAP(0xf8) VXSPARC_SOFT_TRAP(0xf9) VXSPARC_SOFT_TRAP(0xfa) VXSPARC_SOFT_TRAP(0xfb)	/* F8 - FB  */
  VXSPARC_SOFT_TRAP(0xfc) VXSPARC_SOFT_TRAP(0xfd) VXSPARC_SOFT_TRAP(0xfe) VXSPARC_SOFT_TRAP(0xff)	/* FC - FF */

	/* see config/comps/src/configAll.h */
	/* 0x40004000:	 SM_ANCHOR */
_vxSparc_sm_anchor:
	.skip 0x100
	/* 0x40004100:	 BOOT_LINE */
_vxSparc_bootline:
	.skip 0x100
	/* 0x40004200:	 EXC_MSG */
_vxSparc_exc_msg:
	.skip 0x100

	/* 0x40004300:	 _hardreset */
_hardreset:
	mov	BOOT_COLD, %g7		/* usrInit argument, startType */

  todo:
	mov	%sp, %g1
	mov	%fp, %g2
	wr	%g0, 0xfe0, %psr        /* disable irq */
	mov	%g0, %tbr
	set	2, %g3
	mov	%g3, %wim
	mov	%g1, %sp
	mov	%g0, %fp
	sub	%sp, 0x40, %sp

	set     _trap_table, %g1       	/* Initialize TBR */
	mov     %g1, %tbr

	/* Enable and Flush Cache */
	set	0xe1000f, %g2		/* Enable and Flush D/I, Enable D-snooping, IB */

	/* Disable snooping for UT-699 device */
	sethi	%hi(0xfffffff0), %g3
	ld	[%g3 + %lo(0xfffffff0)], %g3
	set	0x06990A04, %g4
	cmp	%g4, %g3
	bne	_leon3_set_cache_ctrl
	nop
	set	0x0061000f, %g2		/* Enable and Flush D/I, Disable D-snooping, IB */

_leon3_set_cache_ctrl:
	sta	%g2, [%g0] 2		/* init cache */
	nop
	nop
	nop

	/* Wait for D-Cache flush to complete */
_dcache_flush_wait:
	lda	[%g0] ASI_LEON3_SYSCTRL, %g2
	sll	%g2, 17, %g2	/* Get bit 14 (Data Cache Flush is pending) */
	srl	%g2, 31, %g2
	cmp	%g2, %g0
	bne	_dcache_flush_wait
	nop

/* ---------- */
/* initialize regs with values	 */
#ifdef VXSPARC_REGINIT
	mov      %psr, %g3
	mov      %wim, %g4
	mov      %sp, %g5
	mov      %fp, %g6
	mov      %g0, %wim
	set      0, %g1
	andn     %g3,0x1f,%l0
	mov      %l0,%psr
	nop;  nop; nop

3:	set     0x0001,%i0
	set     0x0101,%i1
	set     0x0201,%i2
	set     0x0301,%i3
	set     0x0401,%i4
	set     0x0501,%i5
	set     0x0601,%i6
	set     0x0701,%i7
	set     0x0801,%l0
	set     0x0901,%l1
	set     0x1001,%l2
	set     0x1101,%l3
	set     0x1201,%l4
	set     0x1301,%l5
	set     0x1401,%l6
	set     0x1501,%l7
	or      %g1,%i0,%i0
	or      %g1,%i1,%i1
	or      %g1,%i2,%i2
	or      %g1,%i3,%i3
	or      %g1,%i4,%i4
	or      %g1,%i5,%i5
	or      %g1,%i6,%i6
	or      %g1,%i7,%i7
	or      %g1,%l0,%l0
	or      %g1,%l1,%l1
	or      %g1,%l2,%l2
	or      %g1,%l3,%l3
	or      %g1,%l4,%l4
	or      %g1,%l5,%l5
	or      %g1,%l6,%l6
	or      %g1,%l7,%l7
	restore
	set 0x10000,%g2
	add %g1,%g2,%g1
	set NUMREGWINDOWS*0x10000,%g2
	cmp %g1,%g2
	bne 3b
	 nop

	mov      %g4,%wim
	nop; nop; nop;
	mov      %g3,%psr
	nop; nop; nop;
	mov      %g5, %sp
	mov      %g6, %fp

#endif

	/* amp: cpu1's start address is programmed by grmon,
	 * jump to wrload image here */
#if defined(_WRS_VX_AMP) && defined(INCLUDE_AMP_CPU_00)
	rd     	%asr17, %o0
	srl    	%o0, 28, %o0
	cmp	%g0, %o0
	beq	1f
	 nop

	set RAM_HIGH_ADRS, %g1
	jmp	%g1
	 nop
1:
#endif

#ifdef  _WRS_CONFIG_SMP
	lda [%g0] 2, %g1          /* cache cfg */
	set 0x800000, %g2         /* snoop enable */
        or %g2,%g1,%g1

	/*set 0xfffffff0, %g2*/         /*  disable */
        /*and %g1,%g2,%g1*/

        sta %g1, [%g0] 2          /* cache cfg */
	lda [%g0] 2, %g1          /* cache cfg */
	andcc %g2,%g1,%g1
	bne 1f
         nop

	/* you have to enable cache snooping in the vhdl model */
	ta	0x0

1:
/*#define VXWORKS_TEST_PHYSICAL_SNOOPING	*/
#ifdef VXWORKS_TEST_PHYSICAL_SNOOPING
	lda [%g0] ASI_M_MMUREGS, %g1
	set 1<<8, %g2         /* snoop enable */
	andcc %g2,%g1,%g1
	bne 2f
         nop

	/* you have to enable the seperate snooping tag feature in the vhdl model to enable physical snooping */
	ta	0x0

2:
#endif
	rd     	%asr17, %o0
	srl    	%o0, 28, %o0
	cmp	%g0, %o0
	beq	_master_go
	 nop

	call	sysGet_VEC_BASE_ADRS
	 nop
	mov     %o0, %tbr
	nop

	ba	_slave_go
	 nop

_master_go:
#endif

/* ---------- */

	/* --------------------------------------- */
        /* copy trap table to 0x1000, assuming image _trap_table at 0x3000 (0x40003000) */
	set 	_trap_table, %g1
	set	0x3000-0x1000, %g2
	sub 	%g1, %g2, %g2
	set	(0x100*4*4), %g3

tbrcopy_loop:
	sub 	%g3, 4, %g3
	ld	[%g1+%g3], %g4
	st	%g4, [%g2+%g3]
	cmp	%g0, %g3
	bne	tbrcopy_loop
	 nop

	mov     %g2, %tbr

	set 	_trap_table, %g1
	set	SF_REGS_SZ, %g2
	sub 	%g1, %g2, %fp
	sub 	%fp, SF_REGS_SZ, %sp
	/* --------------------------------------- */

#ifdef VXSPARC_FLAT
	mov	%g0, %wim
#endif

#ifdef INCLUDE_BOOTCFG_DSU3
	/* Init DSU instruction and AHB trace */
	set	BOOTCFG_DSU3_ADDRESS, %g1
        ld      [%g1], %g2
        or      %g2, 1, %g2
	st	%g2, [%g1]
	set	1, %g2
	st	%g2, [%g1+0x40]
#endif

        set VENDOR_GAISLER, %o0
        set GAISLER_APBMST, %o1
        call ahbslv_scan
        nop

        cmp %g0,%o0
        be _start
         nop

        ld [%o0+16],%g1
        set LEON3_IO_AREA,%o0
        and %g1,%o0,%g1            /*g1: apb base*/

        set LEON3_CONF_AREA,%o0
        or %g1,%o0,%g2             /*g2: apb conf base*/


	/* *********** irq ******************/
        mov %g2,%o0
        set VENDOR_GAISLER, %o1
        set GAISLER_IRQMP,%o2
        call apbslv_scan
         nop
        cmp %g0,%o0
        be _start
         nop

        call getbase
         mov %g1,%o1

        st    %g0, [%o1 + 0x0]  /*irq pri   */
        st    %g0, [%o1 + 0x4]  /*irq pend */
        st    %g0, [%o1 + 0x8]  /*irq force */
        st    %g0, [%o1 + 0xC]  /*irq clear */
        st    %g0, [%o1 + 0x40] /*irq mask */

	/* ************ timer *************/

        mov %g2,%o0
        set VENDOR_GAISLER, %o1
        set GAISLER_GPTIMER,%o2
        call apbslv_scan
         nop
        cmp %g0,%o0
        be _start
         nop

        call getbase
         mov %g1,%o1

	set	BOOTCFG_TIMER1_SCALER, %o0		/* Load timer scaler register */
	sub	%o0, 1, %o0
  	st	%o0, [%o1 + 0x00] /* scaler */
  	st	%o0, [%o1 + 0x04] /* scaler reload */
	st	%g0, [%o1 + 0x18] /* Disable timer if counting(if Warm boot), Timer0 control */


	/* ************ gaisler FT ctrl (FTMCTRL) ************ */
#ifdef INCLUDE_BOOTCFG_FTMCTRL
.LL1ftmctrl:
        mov %g2,%o0
        set VENDOR_GAISLER, %o1
        set GAISLER_FTMCTRL,%o2
        call apbslv_scan
         nop
        cmp %g0,%o0
        be docg
         nop

        call getbase
         mov %g1,%o1

	set	BOOTCFG_FTMCTRL_MCFG1, %o0		/* Load memory config register 1 */
	ld	[%o1+0x00], %o2
	and	%o2, 0x300, %o2				/* Preserve PROM width */
	or	%o0, %o2, %o0
  	st	%o0, [%o1 + 0x00]
	set	BOOTCFG_FTMCTRL_MCFG2, %o0		/* Load memory config register 2 */
	st	%o0, [%o1 + 0x04]

	set	BOOTCFG_FTMCTRL_MCFG3, %o0
	st	%o0, [%o1 + 0x08]

docg:

#ifdef INCLUDE_BOOTCFG_GRCG
/************ Clock gating *********************/
	mov %g2, %o0
	set VENDOR_GAISLER, %o1
	set GAISLER_CLKGATE, %o2
	call apbslv_scan
	 nop
	cmp %g0, %o0
	be cgdone
	 nop

	call getbase
	mov %g1, %o1

	/* Read in old enable register */
	ld		[%o1+0x4], %g3
	set		BOOTCFG_GRCG_ENABLED, %g6

disableenabled:
	/* Disable already enabled cores */
	andncc	%g3, %g6, %g4
	/* Jump if no cores to disable */
	be		enabledisabled
	 nop
	/* Unlock core bit */
	st		%g4, [%o1]
	/* Disable core bit */
	andn	%g3, %g4, %g5
	st		%g5, [%o1+4]
	/* Lock core bit */
	st		%g0, [%o1]
enabledisabled:
	/* disable already enabled cores */
	andncc	%g6, %g3, %g4
	/* Jump if no cores to disable */
	be		cgdone
	 nop
	/* Unlock core bit */
	st		%g4, [%o1]
	/* Set reset bit */
	ld		[%o1+8], %g5
	or		%g5, %g4, %g5
	st		%g5, [%o1+8]
	/* Enable core bit */
	or		%g4, %g3, %g3
	st		%g3, [%g2+4]
	/* Set reset bit */
	andn	%g5, %g4, %g5
	st		%g5, [%o1+8]
	/* Lock core bit */
	st		%g0, [%o1]
cgdone:
#endif /* INCLUDE_GRCG */


	/* ************ uart ************ */
#endif
.LL1mctlok:
        mov %g2,%o0
        set VENDOR_GAISLER, %o1
        set GAISLER_APBUART,%o2
        call apbslv_scan
         nop
        cmp %g0,%o0
        be _start
         nop

        call getbase
         mov %g1,%o1

        mov %o1,%g5             /* uart base address */

uart1:
        set	BOOTCFG_UART_SCALER, %g2			/* Load UART scaler register */
	st	%g2, [%g5 + 0x0c]				/* uart scalar*/
#if (BOOTCFG_UART_DEBUG == TRUE)
	ld	[%g5+0x08], %g4
	set	0x800, %g2
	and	%g4, %g2, %g4                                   /* Keep GRMON UART debug bit */
	set	BOOTCFG_UART_CTRL, %g2				/* Enable uarts, (flow ctrl), loopback */
	or	%g2, %g4, %g2
#else
	set	BOOTCFG_UART_CTRL, %g2				/* Enable uarts, (flow ctrl), loopback */
#endif
  	st	%g2, [%g5 + 0x08]

_start:
	set	_sp_on_boot,%l0
	ld      [%l0],%l1
	cmp     %g0,%l1
	bne,a	1f
	 st	%sp,[%l0]

1:	call    _leon23_checkcpu /* init _nwindows,_nwindows_min1 and _nwindows */
	 nop

	ba	usrInit		 /* never returns - starts up kernel */
                                /* (jumps to usrConfig.c )          */
	 mov	%g7, %o0	/* Set Start Type argument to usrInit() */

FUNC_END(_sysInit)

        .data
_sp_on_boot:
	.word 0


	.text
#if 0
/* Destination o0  (Aligned to 8Byte bounadry)
 * Source o1       (Aligned to 2Byte boundary, 0x2, 0x6, 0xA or 0xE)
 * Length o2       (MIN 32 Byte)
 *
 * Return number of bytes left to copy (number of bytes not copied).
 */
sparc_memcpy_half_dword:
	andcc 	%o1, 0x4, %g0
	bne	sparc_memcpy_half6_dword
	 nop
	/* Continue to sparc_memcpy_half2_dword */

/* Destination o0  (Aligned to 8Byte bounadry)
 * Source o1       (Aligned to 2Byte boundary, 2 up to 8Byte boundary: 0x6 or 0xE)
 * Length o2       (MIN 32 Byte)
 *
 * LSH = Least significant half
 * MSH = Most significant half
 */
sparc_memcpy_half2_dword:
	/* Prepare */
	lduh	[%o1], %o4	/* 0x2 */
	add	%o1, 2, %o1	/* At 8byte alignment */
sparc_memcpy_half2_dword_loop:
	/* COPY 8 BYTE */
	ldd	[%o1], %g2	/* Get 8byte into g2:g3 */
	/* Copy g2:LSH to %o4:MSH */
	sll	%g2, 16, %o5
	or	%o5, %o4, %o4
	/* Copy g3:LSH to %o5:MSH */
	sll	%g3, 16, %o5
	/* Copy g2:MSH to %o5:LSH */
	srl	%g2, 16, %g2
	or	%g2, %o5, %o5
	/* Store to memory */
	std	%o4, [%o0]
	/* Copy g3:MSH to %o4:LSH, and clear %o4:MSH */
	srl	%g3, 16, %o4

	/* COPY 8 BYTE */
	ldd	[%o1+8], %g2	/* Get 8byte into g2:g3 */
	/* Copy g2:LSH to %o4:MSH */
	sll	%g2, 16, %o5
	or	%o5, %o4, %o4
	/* Copy g3:LSH to %o5:MSH */
	sll	%g3, 16, %o5
	/* Copy g2:MSH to %o5:LSH */
	srl	%g2, 16, %g2
	or	%g2, %o5, %o5
	/* Store to memory */
	std	%o4, [%o0+8]
	/* Copy g3:MSH to %o4:LSH, and clear %o4:MSH */
	srl	%g3, 16, %o4

	/* Now that we have copied 16 byte, we take another spin */
	add	%o1, 16, %o1
	sub	%o2, 16, %o2
	cmp	%o2, 16
	bge	sparc_memcpy_half2_dword_loop
	 add	%o0, 16, %o0

	/* Nothing more to copy. We return number of bytes left */
	retl
	 mov	%o2, %o0


/* Destination o0  (Aligned to 8Byte bounadry)
 * Source o1       (Aligned to 2Byte boundary, 6 up to 8Byte boundary: 0x2 or 0xA)
 * Length o2       (MIN 32 Byte)
 *
 * LSH = Least significant half
 * MSH = Most significant half
 */
sparc_memcpy_half6_dword:
	/* Prepare */
	lduh	[%o1], %o4	/* 0x2 */
	lduh	[%o1+2], %o5	/* 0x4 */
	sll	%o5, 16, %o5
	or	%o5, %o4, %o4
	lduh	[%o1+4], %o5	/* 0x6 */
	add	%o1, 6, %o1	/* At 8byte alignment */
sparc_memcpy_half6_dword_loop:
	/* COPY 8 BYTE */
	ldd	[%o1], %g2	/* Get 8byte into g2:g3 */
	/* Copy g2:LSH to %o5:MSH */
	sll	%g2, 16, %o3
	or	%o3, %o5, %o5
	/* Store to memory */
	std	%o4, [%o0]
	/* Copy g3:LSH to %o4:MSH */
	sll	%g3, 16, %o4
	/* Copy g2:MSH to %o4:LSH */
	srl	%g2, 16, %g2
	or	%g2, %o4, %o4
	/* Copy g3:MSH to %o5:LSH, and clear %o5:MSH */
	srl	%g3, 16, %o5

	/* COPY 8 BYTE */
	ldd	[%o1+8], %g2	/* Get 8byte into g2:g3 */
	/* Copy g2:LSH to %o5:MSH */
	sll	%g2, 16, %o3
	or	%o3, %o5, %o5
	/* Store to memory */
	std	%o4, [%o0+8]
	/* Copy g3:LSH to %o4:MSH */
	sll	%g3, 16, %o4
	/* Copy g2:MSH to %o4:LSH */
	srl	%g2, 16, %g2
	or	%g2, %o4, %o4
	/* Copy g3:MSH to %o5:LSH, and clear %o5:MSH */
	srl	%g3, 16, %o5

	/* Now that we have copied 16 byte, we take another spin */
	add	%o1, 16, %o1
	sub	%o2, 16, %o2
	cmp	%o2, 16
	bge	sparc_memcpy_half6_dword_loop
	 add	%o0, 16, %o0

	/* There are more to copy, but we let caller take that. We return
	 * number of bytes left.
	 */
	retl
	 mov	%o2, %o0
#endif


#ifdef SPARC_MEMCPY_DWORD_HALF
/* Destination o0  (Aligned to 2Byte boundary, 0x2, 0x6, 0xA or 0xE)
 * Source o1       (Aligned to 8Byte bounadry)
 * Length o2       (MIN 32 Byte)
 *
 * Return number of bytes left to copy (number of bytes not copied).
 */
sparc_memcpy_dword_half:
	andcc 	%o0, 0x4, %g0
	beq	sparc_memcpy_dword_half6
	 nop
	/* Continue to sparc_memcpy_dword_half2 */

/* Destination o0  (Aligned to 2Byte boundary, 2 up to 8Byte boundary: 0x6 or 0xE)
 * Source o1       (Aligned to 8Byte bounadry)
 * Length o2       (MIN 32 Byte)
 *
 * LSH = Least significant half
 * MSH = Most significant half
 */
sparc_memcpy_dword_half2:
	/* Prepare loop */
	ldd	[%o1], %g2
	srl	%g2, 16, %o4	/* Write g2:MSH to mem */
	sth	%o4, [%o0]
	add	%o0, 2, %o0	/* 8 Byte alignment */
	sub	%o2, 2, %o2
	add	%o1, 8, %o1
sparc_memcpy_dword_half2_loop:
	/* g2:LSH and g3 contain loaded data */

	/* Copy g2:LSH to %o4:MSH */
	sll	%g2, 16, %o4
	/* Copy g3:MSH to %o4:LSH */
	srl	%g3, 16, %o5
	or	%o5, %o4, %o4
	/* Copy g3:LSH to %o5:MSH */
	sll	%g3, 16, %o5
	/* Get next 8-bytes */
	ldd	[%o1], %g2
	/* Copy g2:MSH to %o5:LSH */
	srl	%g2, 16, %o3
	or	%o3, %o5, %o5
	/* Store 8-bytes, we have three valid halfs in g2:LSH and g3 */
	std	%o4, [%o0]

	/* Copy g2:LSH to %o4:MSH */
	sll	%g2, 16, %o4
	/* Copy g3:MSH to %o4:LSH */
	srl	%g3, 16, %o5
	or	%o5, %o4, %o4
	/* Copy g3:LSH to %o5:MSH */
	sll	%g3, 16, %o5
	/* Get next 8-bytes */
	ldd	[%o1+8], %g2
	/* Copy g2:MSH to %o5:LSH */
	srl	%g2, 16, %o3
	or	%o3, %o5, %o5
	/* Store 8-bytes, we have three valid halfs in g2:LSH and g3 */
	std	%o4, [%o0+8]

	/* Now that we have copied 16 byte, we take another spin */
	add	%o1, 16, %o1
	sub	%o2, 16, %o2
	cmp	%o2, 16
	bge	sparc_memcpy_dword_half2_loop
	 add	%o0, 16, %o0

	cmp	%o2, 8
	bl	sparc_memcpy_dword_half2_ret
	 nop

	/* Copy g2:LSH to %o4:MSH */
	sll	%g2, 16, %o4
	/* Copy g3:MSH to %o4:LSH */
	srl	%g3, 16, %o5
	or	%o5, %o4, %o4
	/* Copy g3:LSH to %o5:MSH */
	sll	%g3, 16, %o5
	/* Get next 8-bytes */
	ld	[%o1], %g2
	/* Copy g2:MSH to %o5:LSH */
	srl	%g2, 16, %o3
	or	%o3, %o5, %o5
	/* Store 8-bytes, we have three valid halfs in g2:LSH and g3 */
	std	%o4, [%o0]
	sub	%o2, 8, %o2

sparc_memcpy_dword_half2_ret:
	retl
	 mov %o2, %o0

/* Destination o0  (Aligned to 2Byte boundary, 6 up to 8Byte boundary: 0x2 or 0xA)
 * Source o1       (Aligned to 8Byte bounadry)
 * Length o2       (MIN 32 Byte)
 *
 * LSH = Least significant half
 * MSH = Most significant half
 */
sparc_memcpy_dword_half6:
	/* Prepare */
	ldd	[%o1], %g2
	srl	%g2, 16, %o4
	sth	%o4, [%o0]
	sll	%g2, 16, %g2
	srl	%g2, 16, %g2
	sth	%g2, [%o0+2]
	srl	%g3, 16, %o4
	sth	%o4, [%o0+4]

	add	%o0, 6, %o0
	add	%o1, 8, %o1
	sub	%o2, 6, %o2

sparc_memcpy_dword_half6_loop:
	/* g3:LSH contain loaded data */

	/* Copy g3:LSH to %o4:MSH */
	sll	%g3, 16, %o4
	/* Get next 8 bytes */
	ldd	[%o1], %g2
	/* Copy g2:MSH to %o4:LSH */
	srl	%g2, 16, %o5
	or	%o5, %o4, %o4
	/* Copy g2:LSH to %o5:MSH */
	sll	%g2, 16, %o5
	/* Copy g3:MSH to %o5:LSH */
	srl	%g3, 16, %g2
	or	%g2, %o5, %o5
	std	%o4, [%o0]

	/* Copy g3:LSH to %o4:MSH */
	sll	%g3, 16, %o4
	/* Get next 8 bytes */
	ldd	[%o1+8], %g2
	/* Copy g2:MSH to %o4:LSH */
	srl	%g2, 16, %o5
	or	%o5, %o4, %o4
	/* Copy g2:LSH to %o5:MSH */
	sll	%g2, 16, %o5
	/* Copy g3:MSH to %o5:LSH */
	srl	%g3, 16, %g2
	or	%g2, %o5, %o5
	std	%o4, [%o0+8]

	/* Now that we have copied 16 byte, we take another spin */
	add	%o1, 16, %o1
	sub	%o2, 16, %o2
	cmp	%o2, 16
	bge	sparc_memcpy_dword_half6_loop
	 add	%o0, 16, %o0

	cmp	%o2, 8
	bl	sparc_memcpy_dword_half6_ret
	 nop

	/* Copy g3:LSH to %o4:MSH */
	sll	%g3, 16, %o4
	/* Get next 8 bytes */
	ldd	[%o1], %g2
	/* Copy g2:MSH to %o4:LSH */
	srl	%g2, 16, %o5
	or	%o5, %o4, %o4
	/* Copy g2:LSH to %o5:MSH */
	sll	%g2, 16, %o5
	/* Copy g3:MSH to %o5:LSH */
	srl	%g3, 16, %g2
	or	%g2, %o5, %o5
	std	%o4, [%o0]
	sub	%o2, 8, %o2

sparc_memcpy_dword_half6_ret:
	retl
	 mov %o2, %o0
#endif

/*********** AMBA Plug & Play Scan routines ***********/



/*unsigned int ahbslv_scan(register unsigned int vendor,register unsigned int driver) {
  register unsigned int conf, mbar,i, *confp;
  register unsigned int cfg_area = (unsigned int ) (LEON3_IO_AREA | LEON3_CONF_AREA | LEON3_AHB_SLAVE_CONF_AREA);
  for (i = 0; i < LEON3_AHB_SLAVES; i++)
  {
    confp = (unsigned int*)(cfg_area + (i * LEON3_AHB_CONF_WORDS * 4));
    conf = *confp;
    //mbar = *(unsigned int*)(i * LEON3_AHB_CONF_WORDS+ (4 * 4));
    if ((amba_vendor(conf) == vendor) && (amba_device(conf) == driver)) {
      return (unsigned int)confp;
    }
  }
  return 0;
} */

ahbslv_scan:
	mov	%o0, %g1
	mov	-2048, %o5
	mov	0, %o3
	sll	%o3, 5, %o0
.LL1122:
	add	%o5, %o0, %o4
	ld	[%o5+%o0], %o2
	srl	%o2, 24, %o0
	cmp	%o0, %g1
	bne,a	.LL1022
	add	%o3, 1, %o3
	srl	%o2, 12, %o0
	and	%o0, 4095, %o0
	cmp	%o0, %o1
	be	.LL122
	mov	%o4, %o2
	add	%o3, 1, %o3
.LL1022:
	cmp	%o3, 7
	bleu,a	.LL1122
	sll	%o3, 5, %o0
	mov	0, %o2
.LL122:
	retl
	mov	%o2, %o0


/*unsigned int apbslv_scan(register unsigned int base,register unsigned int vendor, register unsigned int driver) {
  register unsigned int conf, mbar,i, *confp;
  for (i = 0; i < LEON3_APB_SLAVES; i++)
  {
    confp = (unsigned int*)(base + (i * LEON3_APB_CONF_WORDS * 4));
    conf = *confp;
    //mbar = *(unsigned int*)(i * LEON3_AHB_CONF_WORDS+ (4 * 4));
    if ((amba_vendor(conf) == vendor) && (amba_device(conf) == driver)) {
      return (unsigned int)confp;
    }
  }
  return 0;
}*/

apbslv_scan:
	mov	%o0, %g1
	mov	0, %o4
	sll	%o4, 3, %o0
.LL22:
	add	%g1, %o0, %o5
	ld	[%g1+%o0], %o3
	srl	%o3, 24, %o0
	cmp	%o0, %o1
	bne,a	.LL21
	add	%o4, 1, %o4
	srl	%o3, 12, %o0
	and	%o0, 4095, %o0
	cmp	%o0, %o2
	be	.LL12
	mov	%o5, %o3
	add	%o4, 1, %o4
.LL21:
	cmp	%o4, 15
	bleu,a	.LL22
	sll	%o4, 3, %o0
	mov	0, %o3
.LL12:
	retl
	mov	%o3, %o0

/*unsigned int getbase(register unsigned int *mbar,register unsigned int iobase) {
  register unsigned int conf = mbar[1];
  return ((iobase & 0xfff00000) |
          ((conf & 0xfff00000)>> 12)) & (((conf & 0x0000fff0) <<4) | 0xfff00000);

}*/

getbase:
	ld	[%o0+4], %o2
	sethi	%hi(-1048576), %o3
	and	%o1, %o3, %o1
	and	%o2, %o3, %o0
	srl	%o0, 12, %o0
	or	%o1, %o0, %o1
	sethi	%hi(64512), %o0
	or	%o0, 1008, %o0
	and	%o2, %o0, %o2
	sll	%o2, 4, %o2
	or	%o2, %o3, %o2
	and	%o1, %o2, %o1
	retl
	mov	%o1, %o0

