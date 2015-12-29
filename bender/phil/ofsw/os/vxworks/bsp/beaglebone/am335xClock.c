/* sysClock.c - PRCM support routines for TI OMAP series */

/* * Copyright (c) 2012 Wind River Systems, Inc.  *
 * The right to copy, distribute, modify or otherwise make use
 * of this software may be licensed only pursuant to the terms
 * of an applicable Wind River license agreement.
 */
/*
modification history
--------------------
01c,23oct12,my_  add timer 6 support
01b,27aug12,my_  add delay timer support
01a,10may12,my_  written.
*/

/*
DESCRIPTION
This file contains routines and data to minipulate clock and
pin multiplex on OMAP devices.
*/

#include "beaglebone.h"
#include "tps65217c.h"
#include <stdio.h>

#define AM335X_CONF_MODE0           0
#define AM335X_CONF_MODE1           1
#define AM335X_CONF_MODE2           2
#define AM335X_CONF_MODE3           3
#define AM335X_CONF_MODE4           4
#define AM335X_CONF_MODE5           5
#define AM335X_CONF_MODE6           6
#define AM335X_CONF_MODE7           7

#define AM335X_PUPD_DIS             (0x1 << 3)
#define AM335X_PUPD_EN              (0x0 << 3)
#define AM335X_PU                   (0x1 << 4)
#define AM335X_INPUT                (0x1 << 5)
#define AM335X_OUTPUT               (0x0 << 5)
#define AM335X_SLOW_SLEW            (0x1 << 6)
#define AM335X_PAD_END              (0xffffffff)

#define AM335X_IDLEST_DPLL_MPU      (AM335X_CM_WKUP_BASE + 0x20)
#define AM335X_CLKSEL_DPLL_MPU      (AM335X_CM_WKUP_BASE + 0x2C)
#define AM335X_CLKMODE_DPLL_MPU     (AM335X_CM_WKUP_BASE + 0x88)
#define AM335X_DIV_M2_DPLL_MPU      (AM335X_CM_WKUP_BASE + 0xA8)
#define AM335X_DPLL_EN_MASK         (0xf)
#define AM335X_DPLL_MN_BYP_MODE     (0x4)
#define AM335X_DPLL_LOCK_MODE       (0x7)
#define AM335X_ST_MN_BYPASS         (0x100)
#define AM335X_ST_DPLL_CLK          (0x1)
#define AM335X_DPLL_MULT_MASK       (0x7ff00)
#define AM335X_DPLL_DIV_MASK        (0x7f)
#define AM335X_DPLL_MULT_SHIFT      (8)
#define AM335X_DPLL_CLKOUT_DIV_MASK (0xf)

/* static variables */

struct omap_clock
    {
    unsigned int reg;
    unsigned int v;  /* value to be written */
    unsigned int mask;
    unsigned int wait_bit;
    };

struct omap_reset
    {
    unsigned int reg;
    unsigned int mask;
    };

/* various module clocks */

struct omap_clock l3ram = {
    (AM335X_PRCM_BASE + 0x2c),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock timer2 = {
    (AM335X_PRCM_BASE + 0x80),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock timer3 = {
    (AM335X_PRCM_BASE + 0x84),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock timer4 = {
    (AM335X_PRCM_BASE + 0x88),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock timer5 = {
    (AM335X_PRCM_BASE + 0xec),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock timer6 = {
    (AM335X_PRCM_BASE + 0xf0),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock timer7 = {
    (AM335X_PRCM_BASE + 0x7c),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock pru_icss = {
    (AM335X_PRCM_BASE + 0xe8),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock uart0 = {
    (AM335X_PRCM_BASE + 0x4b4),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock cmwkup = {
    (AM335X_PRCM_BASE + 0x400),
    0x2,
    0x0,
    0x0
};

struct omap_clock control = {
    (AM335X_PRCM_BASE + 0x404),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock cpgmac0 = {
    (AM335X_PRCM_BASE + 0x14),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock emif = {
    (AM335X_PRCM_BASE + 0x28),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock gpmc = {
    (AM335X_PRCM_BASE + 0x30),
    0x2,
    0x00030000,
    0x0
};


struct omap_clock l4ls = {
    (AM335X_PRCM_BASE + 0x60),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock l4fw = {
    (AM335X_PRCM_BASE + 0x64),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock l4hs = {
    (AM335X_PRCM_BASE + 0x120),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock l3instr = {
    (AM335X_PRCM_BASE + 0xdc),
    0x2,
    0x00030000,
    0x0
};
struct omap_clock l3 = {
    (AM335X_PRCM_BASE + 0xe0),
    0x2,
    0x00030000,
    0x0
};
struct omap_clock l3wkup = {
    (AM335X_PRCM_BASE + 0xc),
    0x2,
    0x0,
    0x0
};
struct omap_clock l3swkup = {
    (AM335X_PRCM_BASE + 0x4),
    0x2,
    0x0,
    0x0
};

struct omap_clock l4lswkup = {
    (AM335X_PRCM_BASE + 0xc),
    0x2,
    0x0,
    0x0
};

struct omap_clock usb = {
    (AM335X_PRCM_BASE + 0x1c),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock spi0 = {
    (AM335X_PRCM_BASE + 0x4c),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock spi1 = {
    (AM335X_PRCM_BASE + 0x50),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock cpsw = {
    (AM335X_PRCM_BASE + 0x144),
    0x2,
    0x0,
    0x0
};

struct omap_clock gpio0 = {
    (AM335X_PRCM_BASE + 0x400 + 0x8),
    0x2,
    0x00030000,
    0x0
};


struct omap_clock gpio1 = {
    (AM335X_PRCM_BASE + 0xac),
    0x2,
    0x00030000,
    0x0
};
struct omap_clock gpio2 = {
    (AM335X_PRCM_BASE + 0xb0),
    0x2,
    0x00030000,
    0x0
};
struct omap_clock gpio3 =  {
    (AM335X_PRCM_BASE + 0xb4),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock mmc0 = {
    (AM335X_PRCM_BASE + 0x3c),
    0x2,
    0x00030000,
    0x0

};

struct omap_clock mmc1 = {
    (AM335X_PRCM_BASE + 0xf4),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock mmc2 = {
    (AM335X_PRCM_BASE + 0xf8),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock tpcc = {
    (AM335X_PRCM_BASE + 0xbc),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock tptc0 = {
    (AM335X_PRCM_BASE + 0x24),
    0x2,
    0x00030000,
    0x0
};
struct omap_clock tptc1 = {
    (AM335X_PRCM_BASE + 0xfc),
    0x2,
    0x00030000,
    0x0
};
struct omap_clock tptc2 = {
    (AM335X_PRCM_BASE + 0x100),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock rtc = {
    (AM335X_PRCM_BASE + 0x1000),
    0x2,
    0x00030000,
    0x0
};

struct omap_clock i2c0 = {
    (AM335X_PRCM_BASE + 0x4b8),  /* this clock is in CM_WKUP domain */
    0x2,
    0x00030000,
    0x0
};
struct omap_clock i2c1 = {
    (AM335X_PRCM_BASE + 0x48),
    0x2,
    0x00030000,
    0x0
};
struct omap_clock i2c2 = {
    (AM335X_PRCM_BASE + 0x44),
    0x2,
    0x00030000,
    0x0
};

/* reset control */
struct omap_reset pru_icss_reset = {
    (AM335X_PRM_PER_BASE + 0x00),
    0x00000002
};

/* pin mux */

struct omap_pad_conf
    {
    unsigned int reg;
    unsigned int val;
    };

#define AM335X_PADS_OFFSET(x) (AM335X_CTRL_BASE + (x))

#define spi0_sclk             0x950
#define spi0_d0               0x954
#define spi0_d1               0x958
#define spi0_cs0              0x95C
#define spi0_cs1              0x960
#define ecap0_in_pwm0_out     0x964

#define mcasp0_aclkx          0x990
#define mcasp0_fsx            0x994
#define mcasp0_axr0           0x998
#define mcasp0_ahclkr         0x99c
#define mcasp0_fsr            0x9a4
#define mcasp0_ahclkx         0x9ac

#define mmc0_dat3             0x8f0
#define mmc0_dat2             0x8f4
#define mmc0_dat1             0x8f8
#define mmc0_dat0             0x8fc
#define mmc0_clk              0x900
#define mmc0_cmd              0x904

#define mcasp0_aclkr          0x9a0
#define spi0_cs1              0x960

#define xdma_intr0            0x9b0
#define xdma_intr1            0x9b4

#define usb0_drvvbus          0xa1c
#define usb1_drvvbus          0xa34

#define uart0_rxd             0x970
#define uart0_txd             0x974

#define gpmc_ad0              0x800
#define gpmc_ad1              0x804
#define gpmc_ad2              0x808
#define gpmc_ad3              0x80c
#define gpmc_ad4              0x810
#define gpmc_ad5              0x814
#define gpmc_ad6              0x818
#define gpmc_ad7              0x81c
#define gpmc_ad10             0x828
#define gpmc_ad11             0x82c
#define gpmc_ad12             0x830
#define gpmc_ad13             0x834
#define gpmc_ad14             0x838
#define gpmc_ad15             0x83C
#define gpmc_wait0            0x870
#define gpmc_wpn              0x874
#define gpmc_ben1             0x878
#define gpmc_advn_ale         0x890
#define gpmc_oen_ren          0x894
#define gpmc_wen              0x898
#define gpmc_be0n_cle         0x89c

#define mii1_txen             0x914
#define mii1_rxdv             0x918
#define mii1_txd3             0x91c
#define mii1_txd2             0x920
#define mii1_txd1             0x924
#define mii1_txd0             0x928
#define mii1_txclk            0x92c
#define mii1_rxclk            0x930
#define mii1_rxd3             0x934
#define mii1_rxd2             0x938
#define mii1_rxd1             0x93c
#define mii1_rxd0             0x940

#define gpmc_a0               0x840
#define gpmc_a1               0x844
#define gpmc_a2               0x848
#define gpmc_a3               0x84c
#define gpmc_a4               0x850
#define gpmc_a5               0x854
#define gpmc_a6               0x858
#define gpmc_a7               0x85c
#define gpmc_a8               0x860
#define gpmc_a9               0x864
#define gpmc_a10              0x868
#define gpmc_a11              0x86c
#define gpmc_csn0             0x87c
#define gpmc_csn1             0x880
#define gpmc_csn2             0x884
#define gpmc_clk              0x88c
#define mdio_data             0x948
#define mdio_clk              0x94c

#define lcd_data0             0x8a0
#define lcd_data1             0x8a4
#define lcd_data3             0x8ac
#define lcd_data5             0x8b4
#define lcd_data7             0x8bc
#define lcd_ac_bias_en        0x8ec

struct  omap_pad_conf spi0_pads [] =
    {
        {
        AM335X_PADS_OFFSET(spi0_sclk),
        AM335X_CONF_MODE0 | AM335X_PUPD_EN | AM335X_INPUT
        },

        {
        AM335X_PADS_OFFSET(spi0_d0),
        AM335X_CONF_MODE0 | AM335X_PUPD_EN | AM335X_PU | AM335X_INPUT
        },

        {
        AM335X_PADS_OFFSET(spi0_d1),
        AM335X_CONF_MODE0 | AM335X_PUPD_EN | AM335X_INPUT
        },

        {
        AM335X_PADS_OFFSET(spi0_cs0),
        AM335X_CONF_MODE0 | AM335X_PUPD_EN | AM335X_PU | AM335X_INPUT
        },
        { AM335X_PAD_END, AM335X_PAD_END }
    };

struct  omap_pad_conf spi1_pads [] =
    {
    /* mcasp0_aclkx is muxed with spi1_sclk */
        {
        AM335X_PADS_OFFSET(mcasp0_aclkx),
        AM335X_CONF_MODE3 | AM335X_PUPD_EN | AM335X_INPUT
        },

    /* mcasp0_fsx is muxed with spi1_d0 */
        {
        AM335X_PADS_OFFSET(mcasp0_fsx),
        AM335X_CONF_MODE3 | AM335X_PUPD_EN | AM335X_PU | AM335X_INPUT
        },

    /* mcasp0_axr0 is muxed with spi1_d1 */
        {
        AM335X_PADS_OFFSET(mcasp0_axr0),
        AM335X_CONF_MODE3 | AM335X_PUPD_EN | AM335X_INPUT
        },

    /* gpmc_csn0 is muxed with gpio1_29 */
        {
        AM335X_PADS_OFFSET(gpmc_csn0),
        AM335X_CONF_MODE7 | AM335X_PUPD_DIS | AM335X_OUTPUT
        },

    /* lcd_data3 is muxed with gpio2_9 */
        {
        AM335X_PADS_OFFSET(lcd_data3),
        AM335X_CONF_MODE7 | AM335X_PUPD_DIS | AM335X_OUTPUT
        },

    /* lcd_data5 is muxed with gpio2_11 */
        {
        AM335X_PADS_OFFSET(lcd_data5),
        AM335X_CONF_MODE7 | AM335X_PUPD_DIS | AM335X_OUTPUT
        },

    /* lcd_data7 is muxed with gpio2_13 */
        {
        AM335X_PADS_OFFSET(lcd_data7),
        AM335X_CONF_MODE7 | AM335X_PUPD_DIS | AM335X_OUTPUT
        },

    /* gpmc_clk is muxed with gpio2_1 */
        {
        AM335X_PADS_OFFSET(gpmc_clk),
        AM335X_CONF_MODE7 | AM335X_PUPD_DIS | AM335X_OUTPUT
        },

    /* gpmc_ad13 is muxed with gpio1_13 */
        {
        AM335X_PADS_OFFSET(gpmc_ad13),
        AM335X_CONF_MODE7 | AM335X_PUPD_DIS | AM335X_OUTPUT
        },

    /* gpmc_ad14 is muxed with gpio1_14 */
        {
        AM335X_PADS_OFFSET(gpmc_ad14),
        AM335X_CONF_MODE7 | AM335X_PUPD_DIS | AM335X_OUTPUT
        },

    /* gpmc_ad15 is muxed with gpio1_15 */
        {
        AM335X_PADS_OFFSET(gpmc_ad15),
        AM335X_CONF_MODE7 | AM335X_PUPD_DIS | AM335X_OUTPUT
        },

    /* gpmc_ad10 is muxed with gpio0_26 */
        {
        AM335X_PADS_OFFSET(gpmc_ad10),
        AM335X_CONF_MODE7 | AM335X_PUPD_DIS | AM335X_OUTPUT
        },

    /* gpmc_ad11 is muxed with gpio0_27 */
        {
        AM335X_PADS_OFFSET(gpmc_ad11),
        AM335X_CONF_MODE7 | AM335X_PUPD_DIS | AM335X_OUTPUT
        },

    /* gpmc_ad12 is muxed with gpio1_12 */
        {
        AM335X_PADS_OFFSET(gpmc_ad12),
        AM335X_CONF_MODE7 | AM335X_PUPD_DIS | AM335X_OUTPUT
        },

    /* lcd_ac_bias_en is muxed with gpio2_25 */
        {
        AM335X_PADS_OFFSET(lcd_ac_bias_en),
        AM335X_CONF_MODE7 | AM335X_PUPD_DIS | AM335X_OUTPUT
        },

    /* gpmc_a0 is muxed with gpio1_16 */
        {
        AM335X_PADS_OFFSET(gpmc_a0),
        AM335X_CONF_MODE7 | AM335X_PUPD_DIS | AM335X_OUTPUT
        },

    /* gpmc_a1 is muxed with gpio1_17 */
        {
        AM335X_PADS_OFFSET(gpmc_a1),
        AM335X_CONF_MODE7 | AM335X_PUPD_DIS | AM335X_OUTPUT
        },
        { AM335X_PAD_END, AM335X_PAD_END }
    };

struct omap_pad_conf gpio_pads[] =
    {
    /* ecap0_in_pwm0_out is muxed with gpio0_7 */
        {
        AM335X_PADS_OFFSET(ecap0_in_pwm0_out),
        AM335X_CONF_MODE7 | AM335X_INPUT | AM335X_PUPD_EN
        },
        /* mcasp0_aclkr is muxed with gpio3_18 */
        {
        AM335X_PADS_OFFSET( mcasp0_aclkr),
        AM335X_CONF_MODE7 | AM335X_INPUT | AM335X_PUPD_EN
        },
        /* mcasp0_fsr is muxed with gpio3_19 */
        {
        AM335X_PADS_OFFSET( mcasp0_fsr),
        AM335X_CONF_MODE7 | AM335X_INPUT | AM335X_PUPD_EN
        },
        /* mcasp0_ahclkx is muxed with gpio3_21 */
        {
        AM335X_PADS_OFFSET( mcasp0_ahclkx),
        AM335X_CONF_MODE7 | AM335X_INPUT | AM335X_PUPD_EN
        },
        /* gpmc_ben1 is muxed with gpio1_28 */
        {
        AM335X_PADS_OFFSET(gpmc_ben1),
        AM335X_CONF_MODE7 | AM335X_PUPD_DIS | AM335X_OUTPUT
        },
        { AM335X_PAD_END, AM335X_PAD_END }
    };

struct  omap_pad_conf mmc0_pads[] =
    {
        {
        AM335X_PADS_OFFSET(mmc0_dat3),
        AM335X_CONF_MODE0 | AM335X_INPUT | AM335X_PU
        },

        {
        AM335X_PADS_OFFSET(mmc0_dat2),
        AM335X_CONF_MODE0 | AM335X_INPUT | AM335X_PU
        },

        {
        AM335X_PADS_OFFSET(mmc0_dat1),
        AM335X_CONF_MODE0 | AM335X_INPUT | AM335X_PU
        },

        {
        AM335X_PADS_OFFSET(mmc0_dat0),
        AM335X_CONF_MODE0 | AM335X_INPUT | AM335X_PU
        },

        {
        AM335X_PADS_OFFSET(mmc0_clk),
        AM335X_CONF_MODE0 | AM335X_INPUT | AM335X_PU
        },

        {
        AM335X_PADS_OFFSET(mmc0_cmd),
        AM335X_CONF_MODE0 | AM335X_INPUT | AM335X_PU
        },
        /* spi0_cs is muxed with mmc0_sdcd */
        {
        AM335X_PADS_OFFSET(spi0_cs1),
        AM335X_CONF_MODE7 | AM335X_INPUT | AM335X_PU
        },
        { AM335X_PAD_END, AM335X_PAD_END }
    };

struct  omap_pad_conf mmc1_pads[] =
    {
        {
        AM335X_PADS_OFFSET(gpmc_ad3),
        AM335X_CONF_MODE1 | AM335X_INPUT | AM335X_PU
        },

        {
        AM335X_PADS_OFFSET(gpmc_ad2),
        AM335X_CONF_MODE1 | AM335X_INPUT | AM335X_PU
        },

        {
        AM335X_PADS_OFFSET(gpmc_ad1),
        AM335X_CONF_MODE1 | AM335X_INPUT | AM335X_PU
        },

        {
        AM335X_PADS_OFFSET(gpmc_ad0),
        AM335X_CONF_MODE1 | AM335X_INPUT | AM335X_PU
        },

        {
        AM335X_PADS_OFFSET(gpmc_csn1),
        AM335X_CONF_MODE2 | AM335X_INPUT | AM335X_PU
        },

        {
        AM335X_PADS_OFFSET(gpmc_csn2),
        AM335X_CONF_MODE2 | AM335X_INPUT | AM335X_PU
        },
        { AM335X_PAD_END, AM335X_PAD_END }
    };

struct  omap_pad_conf xdma_pads[] =
    {
        {
        AM335X_PADS_OFFSET(xdma_intr1),
        AM335X_CONF_MODE3
        },
        { AM335X_PAD_END, AM335X_PAD_END }
    };

struct  omap_pad_conf usb0_pads[] =
    {
        {
        AM335X_PADS_OFFSET(usb0_drvvbus),
        AM335X_CONF_MODE0 | AM335X_OUTPUT
        },
        { AM335X_PAD_END, AM335X_PAD_END }
    };

struct  omap_pad_conf usb1_pads[] =
    {
        {
        AM335X_PADS_OFFSET(usb1_drvvbus),
        AM335X_CONF_MODE0 | AM335X_OUTPUT
        },
        { AM335X_PAD_END, AM335X_PAD_END }
    };

struct omap_pad_conf i2c0_pads[] = {
    {
    AM335X_PADS_OFFSET(0x988),
    AM335X_CONF_MODE0 | AM335X_INPUT | AM335X_PU | AM335X_SLOW_SLEW
    } ,

    {
    AM335X_PADS_OFFSET(0x98c),
    AM335X_CONF_MODE0 | AM335X_INPUT | AM335X_PU | AM335X_SLOW_SLEW
    },
    { AM335X_PAD_END, AM335X_PAD_END }
};

struct omap_pad_conf i2c1_pads[] = {
    {
    AM335X_PADS_OFFSET(0x958),
    AM335X_CONF_MODE0 | AM335X_INPUT | AM335X_PU | AM335X_SLOW_SLEW
    },

    {
    AM335X_PADS_OFFSET(0x95c),
    AM335X_CONF_MODE0 | AM335X_INPUT | AM335X_PU | AM335X_SLOW_SLEW
    },
    { AM335X_PAD_END, AM335X_PAD_END }
};

struct omap_pad_conf uart0_pads [] = {
    { AM335X_PADS_OFFSET(uart0_rxd),      AM335X_CONF_MODE0 | AM335X_PU | AM335X_INPUT},
    { AM335X_PADS_OFFSET(uart0_txd),      AM335X_CONF_MODE0 | AM335X_PUPD_EN },
    { AM335X_PAD_END, AM335X_PAD_END },
};

struct omap_pad_conf rgmii1_pads[] = {
    { AM335X_PADS_OFFSET(mii1_txen),  AM335X_CONF_MODE2},
    { AM335X_PADS_OFFSET(mii1_rxdv),  AM335X_CONF_MODE2 | AM335X_INPUT},
    { AM335X_PADS_OFFSET(mii1_txd3),  AM335X_CONF_MODE2},
    { AM335X_PADS_OFFSET(mii1_txd2),  AM335X_CONF_MODE2},
    { AM335X_PADS_OFFSET(mii1_txd1),  AM335X_CONF_MODE2},
    { AM335X_PADS_OFFSET(mii1_txd0),  AM335X_CONF_MODE2},
    { AM335X_PADS_OFFSET(mii1_txclk), AM335X_CONF_MODE2},
    { AM335X_PADS_OFFSET(mii1_rxclk), AM335X_CONF_MODE2 | AM335X_INPUT},
    { AM335X_PADS_OFFSET(mii1_rxd3),  AM335X_CONF_MODE2 | AM335X_INPUT},
    { AM335X_PADS_OFFSET(mii1_rxd2),  AM335X_CONF_MODE2 | AM335X_INPUT},
    { AM335X_PADS_OFFSET(mii1_rxd1),  AM335X_CONF_MODE2 | AM335X_INPUT},
    { AM335X_PADS_OFFSET(mii1_rxd0),  AM335X_CONF_MODE2 | AM335X_INPUT},
    { AM335X_PADS_OFFSET(mdio_data),  AM335X_CONF_MODE0 | AM335X_INPUT | AM335X_PU},
    { AM335X_PADS_OFFSET(mdio_clk),   AM335X_CONF_MODE0 | AM335X_PU},
    { AM335X_PAD_END, AM335X_PAD_END }
};

/* OPP Mappings */
struct omap_opp {
    UINT32 mhz;
    UINT32 mv;
};

struct omap_opp omap_freq_mv_map[] = {
    { 300,  1100 },
    { 600,  1100 },
    { 720,  1200 },
    { 800,  1275 },
    { 1000, 1325 },
    { 1200, 1350 }
};

/******************************************************************************
*
* omapPadConfig - configure module pad settings
*
* This routine configures module pad settings
*
* RETURNS: N/A
*
* ERRNO: N/A
*
*/

void omapPadConfig
    (
    struct omap_pad_conf c[]
    )
    {
    int i;
    unsigned int val;

    for (i = 0; c[i].reg != AM335X_PAD_END; i++)
        {
        am335xOutLong (c[i].reg, c[i].val);
        val = am335xInLong (c[i].reg);
        }
    }

/******************************************************************************
*
* omapEnableClockNoWait - enable module clock specified by 'c'
*
* This routine enables module clock specified by 'c'. This routine does
* not wait for completion.
*
* RETURNS: N/A
*
* ERRNO: N/A
*
*/

void omapClockEnableNoWait
    (
    struct omap_clock * c
    )
    {
    if (!c)
        return;

    am335xOutLong (c->reg, c->v);
    }

/******************************************************************************
*
* omapEnableClock - enable module clock specified by 'c'
*
* This routine enables module clock specified by 'c'
*
* RETURNS: N/A
*
* ERRNO: N/A
*
*/

void omapClockEnable
    (
    struct omap_clock * c
    )
    {
    unsigned int val;

    if (!c)
        return;

    am335xOutLong (c->reg, c->v);

    do
        {
        val = am335xInLong (c->reg);
        } while ((val & c->mask) != c->wait_bit);
    }

/******************************************************************************
*
* omapResetClear - clears the module reset bit specified by 'r'
*
* This routine clears the module reset bit specified by 'r'
*
* RETURNS: N/A
*
* ERRNO: N/A
*
*/

void omapResetClear
    (
    struct omap_reset * r
    )
    {
    unsigned int val;

    if (!r)
        return;

    val = am335xInLong(r->reg);
    am335xOutLong(r->reg, val & (~r->mask));
    }

/******************************************************************************
*
* omapResetAssert - asserts the module reset bit specified by 'r'
*
* This routine asserts the module reset bit specified by 'r'
*
* RETURNS: N/A
*
* ERRNO: N/A
*
*/

void omapResetAssert
    (
    struct omap_reset * r
    )
    {
    unsigned int val;

    if (!r)
        return;

    val = am335xInLong(r->reg);
    am335xOutLong(r->reg, val | r->mask);
    }

#if defined(DRV_I2C_AM38XX)
/******************************************************************************
*
* omapMpuPllSet - set the MPU PLL
*
* This routine enables module clock specified by 'c'
*
* RETURNS: N/A
*
* ERRNO: N/A
*
*/

void omapMpuPllSet
    (
    UINT32 mhz
    )
    {
    UINT32 val;
    UINT32 multiplier = mhz;
    UINT32 m2 = 1;
    UINT32 osc_mhz = (SYS_CLK_FREQ/1000000);
    UINT32 divider = osc_mhz-1;
    UINT32 new_mv = 0;
    UINT32 old_freq;
    UINT32 i;

    /* Don't try to go somewhere we can't */
    if (mhz < 300 || mhz > 1200) {
        return;
    }

    /* Calculate the current operating frequency */
    val = am335xInLong(AM335X_CLKSEL_DPLL_MPU);
    old_freq = osc_mhz * ((val & AM335X_DPLL_MULT_MASK)>>AM335X_DPLL_MULT_SHIFT) / ((val & AM335X_DPLL_DIV_MASK) + 1);

    /* Look up the new required MPU voltage */
    for (i = 0; i < sizeof(omap_freq_mv_map)/sizeof(struct omap_opp); i++) {
        if (mhz <= omap_freq_mv_map[i].mhz) {
            new_mv = omap_freq_mv_map[i].mv;
            break;
        }
    }

    /* Voltage lookup failed, abort */
    if (new_mv == 0) {
        return;
    }

    if (old_freq < mhz) {
        /* Frequency is going up, so increase MPU voltage first */
        tps65217c_set_mpu_mv(new_mv);
    }

    /* Force the MPU PLL into bypass mode */
    val = am335xInLong(AM335X_CLKMODE_DPLL_MPU);
    val &= ~AM335X_DPLL_EN_MASK;
    val |= AM335X_DPLL_MN_BYP_MODE;

    am335xOutLong(AM335X_CLKMODE_DPLL_MPU, AM335X_DPLL_MN_BYP_MODE);

    /* Wait for bypass mode to become set */
    do
        {
        val = am335xInLong (AM335X_IDLEST_DPLL_MPU);
        } while (!(val & AM335X_ST_MN_BYPASS));

    /* Set the multiplier and divider -- in our case, we're
     * dividing by the crystal's frequency in MHz to get down
     * to 1Mhz, and then multiplying by our desired frequency */
    val = (divider | (multiplier << AM335X_DPLL_MULT_SHIFT));
    am335xOutLong(AM335X_CLKSEL_DPLL_MPU, val);

    /* Set the M2 multiplier to 1 */
    val = am335xInLong(AM335X_DIV_M2_DPLL_MPU);
    val &= ~AM335X_DPLL_CLKOUT_DIV_MASK;
    val |= m2;
    am335xOutLong(AM335X_DIV_M2_DPLL_MPU, val);

    /* Switch back to PLL Lock mode */
    val = am335xInLong(AM335X_CLKMODE_DPLL_MPU);
    val &= ~AM335X_DPLL_EN_MASK;
    val |= AM335X_DPLL_LOCK_MODE;

    am335xOutLong(AM335X_CLKMODE_DPLL_MPU, val);

    /* Wait for the PLL to lock */
    do
        {
        val = am335xInLong (AM335X_IDLEST_DPLL_MPU);
        } while (!(val & AM335X_ST_DPLL_CLK));

    if (old_freq > mhz) {
        /* Frequency is going down, so decrease MPU voltage last */
        tps65217c_set_mpu_mv(new_mv);
    }

    }
#endif
