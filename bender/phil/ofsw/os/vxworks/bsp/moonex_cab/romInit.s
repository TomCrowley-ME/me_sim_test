/* romInit.s - ROM initialization module
 *
 * Copyright (C)
 * Gaisler Research 2008
 *
 *
 * modification history
 * --------------------
 * 2013/03/20: Konrad Eisele <konrad@gaisler.com> : create stripped down version with only ut699 parts.
 *             Remove unneeded RASTA/Leon2 parts
 * 002,08jun02,danielH   Added LEON2, FT and made bootloader configurable from Workbench (Daniel Hellstrom (daniel@gaisler.com))
 * 001,05sep06,eiselekd  initial implementation (Konrad Eisele (konrad@gaisler.com))
 *
 *
 * DESCRIPTION
 * This module contains the entry code for the VxWorks bootrom.
 * The entry point romInit, is the first code executed on power-up.
 * It sets the BOOT_COLD parameter to be passed to the generic
 * romStart() routine.
 *
 * The routine sysToMonitor() jumps to the location 24 bytes
 * past the beginning of romInit, to perform a "warm boot".
 * This entry point allows a parameter to be passed to romStart().
 *
 * For Leon3 the macro INCLUDE_BOOTCFG_LIBMKPROM triggers
 * inclusion of LIBMKPROM's code. Inclusion of libmkprom and mkprom_config.h expect
 * the include path to be given in the kernel configurator:
 * BOOTCFG_LIBMKPROM_MKPROM_DIR and BOOTCFG_LIBMKPROM_MKPROM_CONFIG are "-idirafter"-appended
 * to the command line in target/h/tool/gnu/defs.sparc and target/h/make/rules.vxWorks
 * (for PRJ_BUILD).
 */

#define INSIDE_ROMINIT_S
#define _ASMLANGUAGE
#include "vxWorks.h"
#include "asm.h"
#include "cacheLib.h"
#include "config.h"
#include "regs.h"
#include "sysLib.h"
#include <arch/sparc/leon.h>
#include <arch/sparc/asi.h>
#include <arch/sparc/winmacros.h>
#include "bootloader.h"

    .data
    /* internals */
    FUNC_EXPORT(_romInit)
    FUNC_EXPORT(romInit)
    DATA_EXPORT(_sdata)
    FUNC_EXPORT(sysInitAlt)
    FUNC_EXPORT(_start)
    FUNC_EXPORT(_stage1)
    FUNC_EXPORT(_stage2)

    /* externals */
    FUNC_IMPORT(romStart)

/* appears at linker macro VX_START_DATA=RAM_HIGH_ADDR */
    .align 4
sdata:
_sdata:
    .asciz  "start of data"
    .align 4

    _WRS_TEXT_SEG_START

/******************************************************************************
*
* romInit - entry point for VxWorks in ROM
*
*
* romInit
*     (
*     int startType /@ only used by 2nd entry point @/
*     )

*/
_romInit:
romInit:
_start:
_stage1:

/* PSR init value,
 * the Enable FPU is only for FPU detection
 */
#define PSR_INITVAL        0x10c0
#define PSR_INITVAL_NOFPU  0x00c0
_cold:
    /* Jam memory configuration register values before we branch */
    sethi %hi(0x80000000), %l0
    sethi %hi(BOOTCFG_FTMCTRL_MCFG1), %l1
    st  %l1, [%l0]

        /* set cold boot as start type */
    ba      _stage2
    set BOOT_COLD,%g7

_warm:
    /* Jam memory configuration register values before we branch */
    sethi %hi(0x80000000), %l0
    sethi %hi(BOOTCFG_FTMCTRL_MCFG1), %l1
    st  %l1, [%l0]

    /* Back up start type to g7 */
    mov     %i0, %g7

_stage2:
    wr  %g0, PSR_INITVAL, %psr
    mov %g0, %wim
    nop

/* We use g6 for leon version during startup */
    mov %psr, %g6
    srl %g6, 24, %g6
    and     %g6, 3, %g6
    subcc   %g6, 3, %g1     /* leon2: 0 or 2, leon3: 3 */
     nop

    /* Enable and Flush Cache */
    set 0xe1000f, %g2       /* Enable and Flush D/I, Enable D-snooping, IB */
    nop
    nop
    nop

    /* Disable snooping for UT-699 device */
    sethi   %hi(0xfffffff0), %g3
    ld  [%g3 + %lo(0xfffffff0)], %g3
    set 0x06990A04, %g4
    cmp %g4, %g3
    bne _leon3_set_cache_ctrl
     nop
    set 0x0061000f, %g2     /* Enable and Flush D/I, Disable D-snooping, IB */

_leon3_set_cache_ctrl:
    sta %g2, [%g0] 2        /* init cache */
    nop
    nop
    nop

    /* Wait for D-Cache flush to complete */
rom_dcache_flush_wait:
    lda [%g0] ASI_LEON3_SYSCTRL, %g2
    sll %g2, 17, %g2    /* Get bit 14 (Data Cache Flush is pending) */
    srl %g2, 31, %g2
    cmp %g2, %g0
    bne rom_dcache_flush_wait
     nop

/* LEON3 - Get number of register windows */
_leon3_get_nwindow:
    rd  %asr17, %g5     /* leon3 has nwindows and CPU-ID in %asr17 */
     nop

/* Init CPU - [g5 & 0x1f = nwindows-1] */
_leon_init_cpu:
    and %g5, 0x1f, %g5
    add %g5, 1, %g5

    mov %g0, %y
    clr %g1
    clr %g2
    clr %g3
    clr %g4
    /* g5 = nwindows */
    /* g6 = LEON CPU Version */
    /* g7 = WARM/HARD reset */

clear_window:
    mov %g0, %l0
    mov %g0, %l1
    mov %g0, %l2
    mov %g0, %l3
    mov %g0, %l4
    mov %g0, %l5
    mov %g0, %l6
    mov %g0, %l7
    mov %g0, %o0
    mov %g0, %o1
    mov %g0, %o2
    mov %g0, %o3
    mov %g0, %o4
    mov %g0, %o5
    mov %g0, %o6
    mov %g0, %o7
    subcc   %g5, 1, %g5
    bge clear_window
     save

/* Note: We must wait for Memory to be set up until clearing FPU registers */

    subcc   %g6, 3, %g1     /* leon2: 0 or 2, leon3/4: 3 */
     nop

#ifdef INCLUDE_BOOTCFG_LIBMKPROM
    ba  _leon3_init
     nop
# include <arch/sparc/libmkprom.h>
# include <libmkprom/ctrl.h>
# include <libmkprom/mctrl.S>
#endif

/***** LEON3 basic pheriperals and CPU initialization *****/
_leon3_init:

#ifdef ROM_RESIDENT_COPY
    rd      %asr17, %o0
    srl     %o0, 28, %o0
    cmp %g0, %o0
     beq _boot_master_go

    /* we are in rom bootloader, jump to the image that the
     * bootloader will hopefully have loaded */
    set     (RAM_LOW_ADRS & ~0xf000) + 0x1000, %o0
    jmpl    %o0,%g0
     nop

_boot_master_go:
#else
    /* todo : check rom_resigent case */
    rd      %asr17, %o0
    srl     %o0, 28, %o0
    cmp %g0, %o0
    beq _boot_master_go
         nop

    /* slave path */
#ifdef ROM_RESIDENT
    /* **** set %tbr to traptable in ram            **** */
        call    sysGet_VEC_BASE_ADRS                       /**/
         nop                                               /**/
    mov     %o0, %tbr                                  /**/
    jmpl    %o0, %g0                                   /**/
     nop                                               /**/
    /* **** set %tbr to traptable in ram            **** */
#endif

    /* we are in rom bootloader, jump to the image that the
     * bootloader will hopefully have loaded */
    set     (RAM_LOW_ADRS & ~0xf000) + 0x1000, %o0
    jmpl    %o0,%g0
     nop

_boot_master_go:
#endif


#ifdef INCLUDE_BOOTCFG_DSU3
    /* Init DSU instruction and AHB trace */
    set BOOTCFG_DSU3_ADDRESS, %g1
        ld      [%g1], %g2
        or      %g2, 1, %g2
    st  %g2, [%g1]
    set 1, %g2
    st  %g2, [%g1+0x40]
#endif

#ifdef INCLUDE_BOOTCFG_LIBMKPROM

/********************************* libmkprom code start ***********************/

# define DONT_CLEAR_G6
# define DONT_CLEAR_G7
# include <libmkprom/libmkprom_prominit_low.S>

# if defined(ROM_RESIDENT_COPY)
    /* bootrom case */
    set RAM_HIGH_ADRS-STACK_SAVE, %fp
# else
    /* vxWorks_rom + bootrom_res case */
    set STACK_ADRS, %fp
# endif
    mov %fp, %g6
# define WIM_INIT   2
# include <libmkprom/libmkprom_prominit.S>

/********************************* libmkprom code end ***********************/

#else /* INCLUDE_BOOTCFG_LIBMKPROM */

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

    set BOOTCFG_TIMER1_SCALER, %o0      /* Load timer scaler register */
    sub %o0, 1, %o0
    st  %o0, [%o1 + 0x00] /* scaler */
    st  %o0, [%o1 + 0x04] /* scaler reload */
    st  %g0, [%o1 + 0x18] /* Disable timer if counting(if Warm boot), Timer0 control */


    /* ************ gaisler FT ctrl (FTMCTRL) ************ */

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

    set BOOTCFG_FTMCTRL_MCFG1, %o0      /* Load memory config register 1 */
    ld  [%o1+0x00], %o2
    and %o2, 0x300, %o2             /* Preserve PROM width */
    or  %o0, %o2, %o0
    st  %o0, [%o1 + 0x00]
    set BOOTCFG_FTMCTRL_MCFG2, %o0      /* Load memory config register 2 */
    st  %o0, [%o1 + 0x04]

    set BOOTCFG_FTMCTRL_MCFG3, %o0
    st  %o0, [%o1 + 0x08]

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
    ld      [%o1+0x4], %g3
    set     BOOTCFG_GRCG_ENABLED, %g6

disableenabled:
    /* Disable already enabled cores */
    andncc  %g3, %g6, %g4
    /* Jump if no cores to disable */
    be      enabledisabled
     nop
    /* Unlock core bit */
    st      %g4, [%o1]
    /* Disable core bit */
    andn    %g3, %g4, %g5
    st      %g5, [%o1+4]
    /* Lock core bit */
    st      %g0, [%o1]
enabledisabled:
    /* disable already enabled cores */
    andncc  %g6, %g3, %g4
    /* Jump if no cores to disable */
    be      cgdone
     nop
    /* Unlock core bit */
    st      %g4, [%o1]
    /* Set reset bit */
    ld      [%o1+8], %g5
    or      %g5, %g4, %g5
    st      %g5, [%o1+8]
    /* Enable core bit */
    or      %g4, %g3, %g3
    st      %g3, [%g2+4]
    /* Set reset bit */
    andn    %g5, %g4, %g5
    st      %g5, [%o1+8]
    /* Lock core bit */
    st      %g0, [%o1]
cgdone:
#endif /* INCLUDE_GRCG */


    /* ************ uart ************ */

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
        set BOOTCFG_UART_SCALER, %g2            /* Load UART scaler register */
    st  %g2, [%g5 + 0x0c]               /* uart scalar*/
#if (BOOTCFG_UART_DEBUG == TRUE)
    ld  [%g5+0x08], %g4
    set 0x800, %g2
    and %g4, %g2, %g4                                   /* Keep GRMON UART debug bit */
    set BOOTCFG_UART_CTRL, %g2              /* Enable uarts, (flow ctrl), loopback */
    or  %g2, %g4, %g2
#else
    set BOOTCFG_UART_CTRL, %g2              /* Enable uarts, (flow ctrl), loopback */
#endif
    st  %g2, [%g5 + 0x08]


#endif /* INCLUDE_BOOTCFG_LIBMKPROM */

/* LEON3 FT and non-FT CPUs enter here */
_leon_ft_init:
        wr  %g0, PSR_INITVAL, %psr
    nop; nop; nop

#if (BOOTCFG_LEONFT_WASH_MEM == TRUE)
/* Wash RAM memory when EDAC is on, this is to make sure
 * that we get no CRC error when accessing memory
 *
 * It is assumed that the memory is aligned to a 128 bytes
 * boundary.
 */
    clr %g1
    set LOCAL_MEM_LOCAL_ADRS, %o0
    set LOCAL_MEM_LOCAL_ADRS+LOCAL_MEM_SIZE-128, %o1
leon_ft_wash_mem:
    std %g0, [%o0+0]
    std %g0, [%o0+8]
    std %g0, [%o0+16]
    std %g0, [%o0+24]
    std %g0, [%o0+32]
    std %g0, [%o0+40]
    std %g0, [%o0+48]
    std %g0, [%o0+56]
    std %g0, [%o0+64]
    std %g0, [%o0+72]
    std %g0, [%o0+80]
    std %g0, [%o0+88]
    std %g0, [%o0+96]
    std %g0, [%o0+104]
    std %g0, [%o0+112]
    std %g0, [%o0+120]
    cmp %o0, %o1
    bl  leon_ft_wash_mem
     add    %o0, 128, %o0
#endif

    /* Set up Stack */
stackp:

#if defined(ROM_RESIDENT_COPY)
    /* bootrom case */
    set RAM_HIGH_ADRS-STACK_SAVE, %fp
#else
    /* vxWorks_rom + bootrom_res case */
    set STACK_ADRS, %fp
#endif
    andn    %fp, 0x0f, %fp
    sub %fp, 64, %sp

/* Now that the stack has been set up we can start using it...
 *
 * Wash FPU registers only if a FPU is available.
 *
 * Remember that we did turn
 */
leon_fpu_wash:
    rd  %psr, %g2
    srl %g2, 12, %g2
    andcc   %g2, 0x01, %g2
    beq leon_fpu_off
     st %g0, [%sp]

    clr [%sp+0x4]
    ldd [%sp], %f0
    ldd [%sp], %f2
    ldd [%sp], %f4
    ldd [%sp], %f6
    ldd [%sp], %f8
    ldd [%sp], %f10
    ldd [%sp], %f12
    ldd [%sp], %f14
    ldd [%sp], %f16
    ldd [%sp], %f18
    ldd [%sp], %f20
    ldd [%sp], %f22
    ldd [%sp], %f24
    ldd [%sp], %f26
    ldd [%sp], %f28
    ldd [%sp], %f30
    ld  [%sp], %fsr

leon_fpu_off:
    wr  %g0, PSR_INITVAL_NOFPU, %psr

#ifdef ROM_RESIDENT
    /* **** setup the traptable in ram and set %tbr **** */
    call    sysGet_VEC_BASE_ADRS                       /**/
     nop                                               /**/
    set     _sysInit, %g1                              /**/
    mov %o0, %g2                                   /**/
    set (0x100*4*4), %g3                           /**/
                                                       /**/
romresident_tbrcopy_loop:                                  /**/
    sub     %g3, 4, %g3                                /**/
    ld  [%g1+%g3], %g4                             /**/
    st  %g4, [%g2+%g3]                             /**/
    cmp %g0, %g3                                   /**/
    bne romresident_tbrcopy_loop                   /**/
     nop                                               /**/
                                                           /**/
    mov     %g2, %tbr                                  /**/
    /* **** setup the traptable in ram and set %tbr **** */
#endif


callromStart:

        /* romStart will never return, so we can safely mark the current window as invalid */
        /* This allows the most headroom for romStart to execute in until sysALib sets up a trap table */
    set 1, %g3
    mov %g3, %wim

    set romStart,%g2  /* relative jump */
    set romInit,%g3
    sub %g2,%g3,%g2
    set ROM_BASE_ADRS, %g3
    add %g2, %g3, %g2

    call    %g2                 /* This call never returns */
     mov    %g7,%o0                 /* input Warm/Hard reset */

sysInitAlt:

    ba    _leon23_checkcpu /* init _nwindows,_nwindows_min1 and _nwindows */
     nop


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
    mov %o0, %g1
    mov -2048, %o5
    mov 0, %o3
    sll %o3, 5, %o0
.LL1122:
    add %o5, %o0, %o4
    ld  [%o5+%o0], %o2
    srl %o2, 24, %o0
    cmp %o0, %g1
    bne,a   .LL1022
    add %o3, 1, %o3
    srl %o2, 12, %o0
    and %o0, 4095, %o0
    cmp %o0, %o1
    be  .LL122
    mov %o4, %o2
    add %o3, 1, %o3
.LL1022:
    cmp %o3, 7
    bleu,a  .LL1122
    sll %o3, 5, %o0
    mov 0, %o2
.LL122:
    retl
    mov %o2, %o0


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
    mov %o0, %g1
    mov 0, %o4
    sll %o4, 3, %o0
.LL22:
    add %g1, %o0, %o5
    ld  [%g1+%o0], %o3
    srl %o3, 24, %o0
    cmp %o0, %o1
    bne,a   .LL21
    add %o4, 1, %o4
    srl %o3, 12, %o0
    and %o0, 4095, %o0
    cmp %o0, %o2
    be  .LL12
    mov %o5, %o3
    add %o4, 1, %o4
.LL21:
    cmp %o4, 15
    bleu,a  .LL22
    sll %o4, 3, %o0
    mov 0, %o3
.LL12:
    retl
    mov %o3, %o0

/*unsigned int getbase(register unsigned int *mbar,register unsigned int iobase) {
  register unsigned int conf = mbar[1];
  return ((iobase & 0xfff00000) |
          ((conf & 0xfff00000)>> 12)) & (((conf & 0x0000fff0) <<4) | 0xfff00000);

}*/

getbase:
    ld  [%o0+4], %o2
    sethi   %hi(-1048576), %o3
    and %o1, %o3, %o1
    and %o2, %o3, %o0
    srl %o0, 12, %o0
    or  %o1, %o0, %o1
    sethi   %hi(64512), %o0
    or  %o0, 1008, %o0
    and %o2, %o0, %o2
    sll %o2, 4, %o2
    or  %o2, %o3, %o2
    and %o1, %o2, %o1
    retl
    mov %o1, %o0

