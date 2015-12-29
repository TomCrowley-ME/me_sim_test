/* beaglebone.h - header files for Beaglebone */

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
01e,22nov12,y_c  add LCDC register base definition. (WIND00382478)
01d,23oct12,my_  correct gptimer clock sel offset
01c,20sep12,my_  add watchdog timer registers definition (WIND00377592)
01b,17aug12,my_  correct PRCM DLL registers offset
01a,09may12,my_  written from ti_dm81xx_evm 01b
*/

#ifndef __INCbeagleboneh
#define __INCbeagleboneh

#include "am335xIRQ.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Handy sizes */

#define SZ_4K                           (0x00001000)
#define SZ_8K                           (0x00002000)
#define SZ_16K                          (0x00004000)
#define SZ_32K                          (0x00008000)
#define SZ_64K                          (0x00010000)
#define SZ_128K                         (0x00020000)
#define SZ_256K                         (0x00040000)
#define SZ_512K                         (0x00080000)

#define SZ_1M                           (0x00100000)
#define SZ_2M                           (0x00200000)
#define SZ_4M                           (0x00400000)
#define SZ_8M                           (0x00800000)
#define SZ_16M                          (0x01000000)
#define SZ_32M                          (0x02000000)
#define SZ_64M                          (0x04000000)
#define SZ_128M                         (0x08000000)
#define SZ_256M                         (0x10000000)
#define SZ_512M                         (0x20000000)

#define SZ_1G                           (0x40000000)
#define SZ_2G                           (0x80000000)

/* 48 MHz input clock */

#define UART_CLK_FREQ                   (48000000)
#define SYS_32K_CLK_FREQ                (32000)
#define SYS_CLK_FREQ                    (24000000)


#define AM335X_CLK_SOURCE               AM335X_CLK_SOURCE_32K
#define AM335X_SYS_TIMER_CLK_FREQ       (24000000)
#define AM335X_AUX_TIMER_CLK_FREQ       (24000000)
#define AM335X_TIMESTAMP_TIMER_CLK_FREQ (24000000)
#define AM335X_GP_TIMER_CLK_FREQ        (24000000)

#define MPU_INTERRUPT_NUM               (128)

/* TI AM335X Board Registers Offset */

#define AM335X_L3RAM_BASE               (0x40300000)
#define AM335X_L3RAM_SIZE               (0x00010000)

#define AM335X_GPTIMER0_BASE            (0x44E05000)
#define AM335X_GPTIMER1_BASE            (0x44E31000)  /* 1ms timer */
#define AM335X_GPTIMER2_BASE            (0x48040000)
#define AM335X_GPTIMER3_BASE            (0x48042000)
#define AM335X_GPTIMER4_BASE            (0x48044000)
#define AM335X_GPTIMER5_BASE            (0x48046000)
#define AM335X_GPTIMER6_BASE            (0x48048000)
#define AM335X_GPTIMER7_BASE            (0x4804A000)

#define AM335X_GPIO0_BASE               (0x44E07000)
#define AM335X_GPIO1_BASE               (0x4804C000)
#define AM335X_GPIO2_BASE               (0x481AC000)
#define AM335X_GPIO3_BASE               (0x481AE000)

#define AM335X_ELM_BASE                 (0x48080000)
#define AM335X_EMIF4_0_CFG_BASE         (0x4C000000)
#define AM335X_EMIF4_1_CFG_BASE         (0x4D000000)
#define AM335X_DMM_BASE                 (0x4E000000)
#define AM335X_GPMC_BASE                (0x50000000)
#define AM335X_PLL_SUBSYS_BASE          (0x481C5000)

#define AM335X_PRCM_BASE                (0x44E00000)
#define AM335X_PRCM_SIZE                (0x00004000)

#define AM335X_CM_WKUP_BASE             (0x44E00400)
#define AM335X_CM_WKUP_SIZE             (0x00000100)

#define AM335X_PRM_PER_BASE             (0x44E00C00)
#define AM335X_PRM_PER_SIZE             (0x00000100)

#define AM335X_SDRC_NCS0                (0x80000000)
#define AM335X_SDRC_NCS0_END            (0xffffffff)
#define AM335X_SDRC_NCS0_SIZE           (SZ_2G)

#define AM335X_UART0_BASE               (0x48020000)
#define AM335X_UART0_END                (0x48021fff)
#define AM335X_UART0_SIZE               (SZ_8K)

#define AM335X_UART1_BASE               (0x44e09000)
#define AM335X_UART1_END                (0x44e0afff)
#define AM335X_UART1_SIZE               (SZ_8K)

#define AM335X_UART2_BASE               (0x48024000)
#define AM335X_UART2_END                (0x48025fff)
#define AM335X_UART2_SIZE               (SZ_8K)

#define AM335X_I2C0_BASE                (0x44e0b000)
#define AM335X_I2C0_END                 (0x44e0bfff)
#define AM335X_I2C0_SIZE                (SZ_4K)

#define AM335X_I2C1_BASE                (0x4802a000)
#define AM335X_I2C1_END                 (0x4802afff)
#define AM335X_I2C1_SIZE                (SZ_4K)

#define AM335X_I2C2_BASE                (0x4819c000)
#define AM335X_I2C2_END                 (0x4819cfff)
#define AM335X_I2C2_SIZE                (SZ_4K)

#define AM335X_RTC_BASE                 (0x44E3E000)
#define AM335X_RTC_SIZE                 (0x00002000)

#define AM335X_SPI0_BASE                (0x48030000)
#define AM335X_SPI0_END                 (0x480301ff)
#define AM335X_SPI0_SIZE                (256)

#define AM335X_SPI1_BASE                (0x481A0000)
#define AM335X_SPI1_END                 (0x481A01ff)
#define AM335X_SPI1_SIZE                (256)

#define AM335X_MMC0_BASE                (0x48060000)
#define AM335X_MMC0_SDHC_BASE           (AM335X_MMC0_BASE + 0x100)
#define AM335X_MMC0_END                 (0x48060fff)
#define AM335X_MMC0_SIZE                (SZ_4K)

#define AM335X_MMC1_BASE                (0x481d8000)
#define AM335X_MMC1_SDHC_BASE           (AM335X_MMC1_BASE + 0x100)
#define AM335X_MMC1_END                 (0x481d8fff)
#define AM335X_MMC1_SIZE                (SZ_4K)

#define AM335X_USBSS_BASE               (0x47400000)
#define AM335X_USB0_BASE                (AM335X_USBSS_BASE + 0x1000)
#define AM335X_USB1_BASE                (AM335X_USBSS_BASE + 0x1800)

#define AM335X_MPU_INTC                 (0x48200000)

#define AM335X_CTRL_BASE                (0x44E10000)

#define AM335X_GPMC_BASE                (0x50000000)
#define AM335X_GPMC_END                 (0x50ffffff)
#define AM335X_GPMC_SIZE                (SZ_16M)

#define AM335X_EMAC0_BASE               (0x4A100000)
#define AM335X_EMAC0_END                (0x4A11ffff)
#define AM335X_EMAC0_SIZE               (SZ_128K)

#define AM335X_EMAC1_BASE               (0x4A120000)
#define AM335X_EMAC1_END                (0x4A13ffff)
#define AM335X_EMAC1_SIZE               (SZ_128K)

#define AM335X_SGX_BASE                 (0x56000000)
#define AM335X_SGX_SIZE                 (SZ_64K)

#define AM335X_EDMA_BASE                (0x49000000)
#define AM335X_EDMA_SIZE                (SZ_16M)

#define AM335X_MAILBOX_BASE             (0x480C8000)
#define AM335X_MAILBOX_SIZE             (SZ_8K)

#define AM335X_SPINLOCK_BASE            (0x480CA000)
#define AM335X_SPINLOCK_SIZE            (SZ_8K)

#define AM335X_LCDC_BASE                (0x4830E000)
#define AM335X_LCDC_SIZE                (SZ_8K)

#define AM335X_PRU_ICSS_BASE            (0x4a300000)
#define AM335X_PRU_ICSS_SIZE            (SZ_512K)

/* OMAP GPMC domain definitions, mainly for NAND */

#define OMAP_GPMC_BASE                  (AM335X_GPMC_BASE)
#define OMAP_GPMC_REVISION              (0x0)
#define OMAP_GPMC_SYSCONFIG             (0x10)
#define OMAP_GPMC_IRQSTATUS             (0x18)
#define OMAP_GPMC_IRQENABLE             (0x1C)
#define OMAP_GPMC_TIMEOUT               (0x40)
#define OMAP_GPMC_CONFIG                (0x50)
#define OMAP_GPMC_STATUS                (0x54)

#define OMAP_GPMC_CS_CONFIG1(cs)        (0x60 + (0x30 * (cs)))
#define OMAP_GPMC_CS_CONFIG2(cs)        (0x64 + (0x30 * (cs)))
#define OMAP_GPMC_CS_CONFIG3(cs)        (0x68 + (0x30 * (cs)))
#define OMAP_GPMC_CS_CONFIG4(cs)        (0x6C + (0x30 * (cs)))
#define OMAP_GPMC_CS_CONFIG5(cs)        (0x70 + (0x30 * (cs)))
#define OMAP_GPMC_CS_CONFIG6(cs)        (0x74 + (0x30 * (cs)))
#define OMAP_GPMC_CS_CONFIG7(cs)        (0x78 + (0x30 * (cs)))

#define OMAP_GPMC_CS_NAND_CMD(cs)       (0x7C + (0x30 * (cs)))
#define OMAP_GPMC_CS_NAND_ADDR(cs)      (0x80 + (0x30 * (cs)))
#define OMAP_GPMC_CS_NAND_DATA(cs)      (0x84 + (0x30 * (cs)))

#define GPMC_NO_IDLE                    (0x8)
#define CPMC_IRQ_WAIT0EDGE              (0x100)
#define CPMC_IRQ_WAIT1EDGE              (0x200)
#define CPMC_CONFIG_WP                  (0x10)
#define CPMC_CONFIG_LIMITED_ADDR        (0x2)
#define GPMC_CS_VALID                   (0x40)

/* TI AM335X specific settings */

#define OMAP_NAND_GPMC_CONFIG1          (0x00000800)
#define OMAP_NAND_GPMC_CONFIG2          (0x001e1e00)
#define OMAP_NAND_GPMC_CONFIG3          (0x001e1e00)
#define OMAP_NAND_GPMC_CONFIG4          (0x16051807)
#define OMAP_NAND_GPMC_CONFIG5          (0x00151e1e)
#define OMAP_NAND_GPMC_CONFIG6          (0x16000f80)
#define OMAP_NAND_GPMC_CONFIG7          (0x00000008)

/* GPIO Registers Offset */

#define AM335X_GPIO_REVISION            (0x000)
#define AM335X_GPIO_SYSCONFIG           (0x010)
#define AM335X_GPIO_EOI                 (0x020)
#define AM335X_GPIO_IRQSTATUS0_RAW      (0x024)
#define AM335X_GPIO_IRQSTATUS1_RAW      (0x028)
#define AM335X_GPIO_IRQSTATUS0          (0x02C)
#define AM335X_GPIO_IRQSTATUS1          (0x030)
#define AM335X_GPIO_IRQSTATUS_SET0      (0x034)
#define AM335X_GPIO_IRQSTATUS_SET1      (0x038)
#define AM335X_GPIO_IRQSTATUS_CLR0      (0x03C)
#define AM335X_GPIO_IRQSTATUS_CLR1      (0x040)
#define AM335X_GPIO_IRQWAKEN0           (0x044)
#define AM335X_GPIO_IRQWAKEN1           (0x048)

#define AM335X_GPIO_CTRL                (0x130)
#define AM335X_GPIO_OE                  (0x134)
#define AM335X_GPIO_DATAIN              (0x138)
#define AM335X_GPIO_DATAOUT             (0x13C)
#define AM335X_GPIO_LEVELDETECT0        (0x140)
#define AM335X_GPIO_LEVELDETECT1        (0x144)
#define AM335X_GPIO_RISINGDETECT        (0x148)
#define AM335X_GPIO_FALLINGDETECT       (0x14C)
#define AM335X_GPIO_DEBOUNCENABLE       (0x150)
#define AM335X_GPIO_DEBOUNCINGTIME      (0x154)
#define AM335X_GPIO_CLEARIRQENABLE1     (0x160)
#define AM335X_GPIO_SETIRQENABLE1       (0x164)
#define AM335X_GPIO_CLEARIRQENABLE2     (0x170)
#define AM335X_GPIO_SETIRQENABLE2       (0x174)
#define AM335X_GPIO_CLEARWKUENA         (0x180)
#define AM335X_GPIO_SETWKUENA           (0x184)
#define AM335X_GPIO_CLEARDATAOUT        (0x190)
#define AM335X_GPIO_SETDATAOUT          (0x194)

/* TI AM335X Board Configuration Stuff */

#define CONFIG_NAND_SIZE_256MB          (0x0) /* 256MB */
#define NAND_SIZE_256MB                 (256 * 1024 * 1024)
#define CONFIG_NAND_BASE                (0x08000000)
#define GPMC_MAX_CS                     (8)

#define CONFIG_ROM_SIZE                 (0x65000)
#define CONFIG_ROM_OFFSET               (0x20000)

#ifndef BIT
#define BIT(x)                          (1 << (x))
#endif

#define CM_DPLL_OFFSET                  (AM335X_PRCM_BASE + 0x0500)

#define AM335X_CM_TIMER1_CLKSEL         (CM_DPLL_OFFSET + 0x24)
#define AM335X_CM_TIMER2_CLKSEL         (CM_DPLL_OFFSET + 0x08)
#define AM335X_CM_TIMER3_CLKSEL         (CM_DPLL_OFFSET + 0x0C)
#define AM335X_CM_TIMER4_CLKSEL         (CM_DPLL_OFFSET + 0x10)
#define AM335X_CM_TIMER5_CLKSEL         (CM_DPLL_OFFSET + 0x18)
#define AM335X_CM_TIMER6_CLKSEL         (CM_DPLL_OFFSET + 0x1C)
#define AM335X_CM_TIMER7_CLKSEL         (CM_DPLL_OFFSET + 0x04)

#define RMII_REFCLK_SRC                 (AM335X_PLL_SUBSYS_BASE + 0x2E8)
#define GMII_SEL                        (AM335X_CTRL_BASE + 0x650)
#define CPTS_RFT_CLK_SOURCE             (0x4)
#define REFCLK_SOURCE                   (0x0)

/* cache maintence operation */

#define ARM_IMM #

#define ARM_LOC_MASK #0x7000000     /* level of coherency mask of CLIDR */


#define CACHE_DC_ENABLE   (1<<2)    /* (data) cache enable */
#define CACHE_IC_ENABLE   (1<<12)   /* Instruction cache enable */

/*
 * Common code for cache operations on entire data/unified caches,
 * performed by set/way to the point of coherency (PoC).
 * This code is based on 'Example code for cache maintenance operations'
 * provided in "ARM Architecture Reference Manual ARMv7-A and ARMv7-R edition
 * (ARM DDI 0406)" .
 *
 * Registers used: r0-r8, though r4-r8 are saved/restored
 * Also, note that r0 is 0 when this code completes
 */

#define _CORTEX_AR_ENTIRE_DATA_CACHE_OP(crm) \
                    \
    MRC    p15, 1, r0, c0, c0, 1    /* r0 = Cache Lvl ID register info */;\
    ANDS   r3, r0, ARM_LOC_MASK     /* get level of coherency (LoC) */;\
    MOV    r3, r3, LSR ARM_IMM 23   /* r3 = LoC << 1 */;\
    BEQ    5f            ;\
                    \
    MOV    r7, ARM_IMM 0            /* r7 = cache level << 1; start at 0 */;\
                    \
1:                    ;\
    AND    r1, r0, ARM_IMM 0x7      /* r1 = cache type(s) for this level */;\
    CMP    r1, ARM_IMM 2        ;\
    BLT    4f                       /* no data cache at this level */;\
                    \
    MCR    p15, 2, r7, c0, c0, 0    /* select the Cache Size ID register */;\
    MCR    p15, 0, r7, c7, c5, 4    /* ISB: sync change to Cache Size ID */;\
    MRC    p15, 1, r1, c0, c0, 0    /* r1 = current Cache Size ID info */;\
    AND    r2, r1, ARM_IMM 0x7      /* r2 = line length */;\
    ADD    r2, r2, ARM_IMM 4        /* add line length offset = log2(16 bytes) */;\
    LDR    r4, =0x3FF        ;\
    ANDS   r4, r4, r1, LSR ARM_IMM 3 /* r4 = (# of ways - 1); way index */;\
    CLZ    r5, r4                    /* r5 = bit position of way size increment */;\
    LDR    r6, =0x00007FFF        ;\
    ANDS    r6, r6, r1, LSR ARM_IMM 13/* r6 = (# of sets - 1); set index */;\
                    \
2:                    ;\
    MOV    r1, r4                 /* r1 = working copy of way number */;\
3:                    ;\
    ORR    r8, r7, r1, LSL r5     /* r8 = set/way operation data word: */;\
    ORR    r8, r8, r6, LSL r2     /* cache level, way and set info */;\
                    \
    MCR    p15, 0, r8, c7, crm, 2 /* dcache operation by set/way */;\
                    \
    SUBS   r1, r1, ARM_IMM 1      /* decrement the way index */;\
    BGE    3b            ;\
    SUBS   r6, r6, ARM_IMM 1      /* decrement the set index */;\
    BGE    2b            ;\
                    \
4:                    ;\
    ADD    r7, r7, ARM_IMM 2      /* increment cache index = level << 1 */;\
    CMP    r3, r7                 /* done when LoC is reached */;\
    MOVGT  r0, r0, LSR ARM_IMM 3  /* rt-align type of next cache level */;\
    BGT    1b            ;\
                    \
5:                    ;\

/* EMAC Control Module Registers offset */

#define WRAPPER_OFFSET                      (0x0900)

/* DMA_RAM offset */

#define WRAPPER_RAM_OFFSET                  (0x2000)
#define MDIO_OFFSET                         (0x0800)
#define EMAC_CLK                            (250000000)

/* Control Module related registers */

#define AM335X_DEV_ID                       (AM335X_CTRL_BASE + 0x600)
#define AM335X_MACID0_LO                    (AM335X_CTRL_BASE + 0x630)
#define AM335X_MACID0_HI                    (AM335X_CTRL_BASE + 0x634)
#define AM335X_MACID1_LO                    (AM335X_CTRL_BASE + 0x638)
#define AM335X_MACID1_HI                    (AM335X_CTRL_BASE + 0x63C)
#define AM335X_TIMER_EVT_CAP                (AM335X_CTRL_BASE + 0xFD0)

#define AM335X_INIT_STACK_SIZE              (0x3000)
#define AM335X_ROM_HEADER_SIZE              (0x8)
#define AM335X_NANDBOOT_RAM_ADRS            (AM335X_L3RAM_BASE)

#define MAC_MII_SEL                         (AM335X_CTRL_BASE + 0x650)
#define GMII_MODE_ENABLE                    (0x0)
#define RGMII_MODE_ENABLE                   (0xA)

#define am335xInLong(a)                     (*(volatile unsigned int *)(a))
#define am335xOutLong(a, v)                 (*(volatile unsigned int *)(a) = (v))
#define am335xInWord(a)                     (*(volatile unsigned short *)(a))
#define am335xOutWord(a, v)                 (*(volatile unsigned short *)(a) = (v))
#define am335xInByte(a)                     (*(volatile unsigned char *)(a))
#define am335xOutByte(a, v)                 (*(volatile unsigned char *)(a) = (v))

/* definitions for delay timer */

#define TIMER_SYNC_WRITE(reg, val, syncReg, bit) \
    do { \
        unsigned int __v;\
        am335xOutLong (reg, val); \
        do { \
            __v = am335xInLong (syncReg); \
        } while (__v & bit); \
    } while (0)

#define TIMER_SYNC_READ(reg, syncReg, bit, data) \
    do { \
        unsigned int __v; \
        do { \
            __v = am335xInLong (syncReg); \
        } while (__v & bit); \
        data = am335xInLong (reg); \
    } while (0)

#define TIDR              (0x0)
#define TIOCP_CFG         (0x10)
#define IRQ_EIQ           (0x20)
#define IRQSTATUS_RAW     (0x24)
#define IRQSTATUS         (0x28)
#define IRQENABLE_SET     (0x2C)
#define IRQENABLE_CLR     (0x30)
#define IRQWAKEEN         (0x34)
#define TCLR              (0x38)
#define TCRR              (0x3C)
#define TLDR              (0x40)
#define TTGR              (0x44)
#define TWPS              (0x48)
#define TMAR              (0x4C)
#define TCAR1             (0x50)
#define TSICR             (0x54)
#define TCAR2             (0x58)

#define TCAR_EN_FLAG      (0x1 << 2)
#define CAPT_MODE         (0x1 << 13)
#define CAPT_LOW_TO_HIGH  (0x1 << 8)
#define CAPT_HIGH_TO_LOW  (0x2 << 8)
#define CAPT_BOTH         (0x3 << 8)

#define W_PEND_TMAR       (0x10)
#define W_PEND_TTGR       (0x8)
#define W_PEND_TLDR       (0x4)
#define W_PEND_TCRR       (0x2)
#define W_PEND_TCLR       (0x1)

/* watch dog timer */

#define AM335X_WDT_BASE   (0x44E35000)
#define WDT_WIDR          (0x0)
#define WDT_WDSC          (0x10)
#define WDT_WDST          (0x14)
#define WDT_WISR          (0x18)
#define WDT_WIER          (0x1c)
#define WDT_WCLR          (0x24)
#define WDT_WCRR          (0x28)
#define WDT_WLDR          (0x2c)
#define WDT_WTGR          (0x30)
#define WDT_WWPS          (0x34)
#define WDT_WDLY          (0x44)
#define WDT_WSPR          (0x48)
#define WDT_WIRQSTATRAW   (0x54)
#define WDT_WIRQSTAT      (0x58)
#define WDT_WIRQENSET     (0x5c)
#define WDT_WIRQENCLR     (0x60)

#ifdef __cplusplus
}
#endif

#endif /* __INCbeagleboneh */
