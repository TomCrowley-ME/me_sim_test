/* ti81xxMcSpi.h - TI DM81XX McSPI register definitions */

/*
 * Copyright (c) 2011, 2012 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify or otherwise make use
 * of this software may be licensed only pursuant to the terms
 * of an applicable Wind River license agreement.
 */

/*
modification history
--------------------
01b,14aug12,my_ add 335x support
01a,15aug11,clx created from mst_omap3530evm BSP
*/

#ifndef __INCti81XXMcSpih
#define __INCti81XXMcSpih

#ifdef __cplusplus
extern "C" {
#endif

/* register definitions for McSpi */

#define MCSPI_SYSCONFIG             (0x10) /* system configuration register */
#define MCSPI_SYSSTATUS             (0x14) /* system status register */
#define MCSPI_IRQSTATUS             (0x18) /* interrupt status register */
#define MCSPI_IRQENABLE             (0x1C) /* interrupt enable register */
#define MCSPI_WAKEUPENABL           (0x20)
#define MCSPI_SYST                  (0x24) /* system register */
#define MCSPI_MODULCTRL             (0x28) /* module control register */
#define MCSPI_XFERLEVEL             (0x7C)
#define MCSPI_CHxCONF(i)            (0x2C + (0x14 * (i)))
#define MCSPI_CHxSTAT(i)            (0x30 + (0x14 * (i)))
#define MCSPI_CHxCTRL(i)            (0x34 + (0x14 * (i)))
#define MCSPI_TXx(i)                (0x38 + (0x14 * (i)))
#define MCSPI_RXx(i)                (0x3C + (0x14 * (i)))

#define TI81XX_SPI_ENABLE           (0x1)
#define TI81XX_SPI_DISABLE          (0x0)

#define TI81XX_SPI_READ             (0x1 << 2)
#define TI81XX_SPI_WRITE            (0x1 << 3)

#define TI81XX_SPI_AUTO_SPIEN       (0xFFFFFFFF)

#define TI81XX_SOFTRESET            (0x1 << 1)

#define TI81XX_SPI_SLAVE            (0x1 << 2)
#define TI81XX_SPI_MASTER           (0x0 << 2)
#define TI81XX_SPI_SYSTEST          (0x1 << 3)
#define TI81XX_SPI_FUNC             (0x0 << 3)
#define TI81XX_SPI_SINGLE           (0x1 << 0)
#define TI81XX_SPI_MULTI            (0x0 << 0)
#define TI81XX_SPI_3PIN             (0x1 << 1)
#define TI81XX_SPI_4PIN             (0x0 << 1)

#define TI81XX_SPI_CHSTAT_RXS       (0x1 << 0)
#define TI81XX_SPI_CHSTAT_TXS       (0x1 << 1)
#define TI81XX_SPI_CHSTAT_EOT       (0x1 << 2)
#define TI81XX_SPI_CHSTAT_TXFFE     (0x1 << 3)
#define TI81XX_SPI_CHSTAT_TXFFF     (0x1 << 4)
#define TI81XX_SPI_CHSTAT_RXFFE     (0x1 << 5)
#define TI81XX_SPI_CHSTAT_RXFFF     (0x1 << 6)

#define TI81XX_SPI_TURBO            (0x1 << 19)

/* Data Line 0 (spim_somi) selected for reception */

#define TI81XX_SPI_IS_DL0           (0x0 << 18)

/* Data Line 1 (spim_simo) selected for reception */

#define TI81XX_SPI_IS_DL1           (0x1 << 18)

/* No transmission on data Line 0 (spim_somi) */

#define TI81XX_SPI_DPE0             (0x1 << 16)

/* No transmission on data Line 1 (spim_simo) */

#define TI81XX_SPI_DPE1             (0x1 << 17)

#define TI81XX_SPI_CLKG             (0x1 << 29)
#define TI81XX_SPI_FORCE_SPIEN      (0x1 << 20)
#define TI81XX_SPI_XFER             (0x0 << 12)
#define TI81XX_SPI_RXONLY_MODE      (0x1 << 12)
#define TI81XX_SPI_TXONLY_MODE      (0x2 << 12)
#define TI81XX_SPI_EPOL             (0x1 << 6)
#define TI81XX_SPI_POL              (0x1 << 1)
#define TI81XX_SPI_PHA              (0x1 << 0)
#define TI81XX_SPI_TCS(x)           ((x & 3) << 25)
#define TI81XX_SPI_WL(x)            (((x - 1) & 0x1F) << 7) /* word length */
#define TI81XX_SPI_CLKD(x)          ((x & 0xF) << 2)  /* divided by 2^x */

#define TI81XX_SPI_CLKD_1           (0x0 << 2)
#define TI81XX_SPI_CLKD_2           (0x1 << 2)
#define TI81XX_SPI_CLKD_4           (0x2 << 2)
#define TI81XX_SPI_CLKD_8           (0x3 << 2)
#define TI81XX_SPI_CLKD_16          (0x4 << 2)
#define TI81XX_SPI_CLKD_32          (0x5 << 2)
#define TI81XX_SPI_CLKD_64          (0x6 << 2)
#define TI81XX_SPI_CLKD_128         (0x7 << 2)
#define TI81XX_SPI_CLKD_256         (0x8 << 2)
#define TI81XX_SPI_CLKD_512         (0x9 << 2)
#define TI81XX_SPI_CLKD_1024        (0xa << 2)
#define TI81XX_SPI_CLKD_2048        (0xb << 2)
#define TI81XX_SPI_CLKD_4096        (0xc << 2)

#define TI81XX_SPI_WLEN_MSK         (0x1f << 7)

#define TI81XX_MCSPI_REF_FREQ       (48000000)

#define MCSPI_TIMEOUT               (10000)

#define SPI_MODE_0                  (0)
#define SPI_MODE_1                  (1)
#define SPI_MODE_2                  (2)
#define SPI_MODE_3                  (3)

#ifdef TI81XX_SPI_DEBUG
#define TI81XX_SPI_LOG(fmt,a,b,c,d,e,f)  \
    if (_func_logMsg != NULL) \
        (* _func_logMsg)(fmt,a,b,c,d,e,f)
#else
#define TI81XX_SPI_LOG(fmt,a,b,c,d,e,f)
#endif

#define TI81XX_SPI_REGISTER_READ(module, reg) \
    (*(volatile UINT32 *)((ti81xxSpiBase[module]) + reg))

#define TI81XX_SPI_REGISTER_WRITE(module, reg, data) \
    (*((volatile UINT32 *)(ti81xxSpiBase[module] + reg)) = (data))

/* declarations */

STATUS ti81xxMcSpiInit
    (
    int module,      /* SPI module number */
    int cfgValue      /* value used to configure the channel */
    );

STATUS ti81xxSpiChannelConfig
    (
    int module,       /* SPI module number */
    int channel,      /* SPI channel number */
    int cfgValue      /* SPI channel configure value */
    );

void ti81xxSpiStart
    (
    int      module,    /* SPI module number */
    int      channel,   /* SPI channel number */
    UINT32   csPin      /* sysGpio-compatible pin number */
    );

void ti81xxSpiStop
    (
    int      module,    /* SPI module number */
    int      channel,   /* SPI channel number */
    UINT32   csPin      /* sysGpio-compatible pin number */
    );

STATUS ti81xxSpiXfer
    (
    int      module,  /* SPI module number */
    int      channel, /* SPI channel number */
    char *   data,    /* data to be transferred */
    UINT32   len,     /* data length */
    int      flag     /* read or write */
    );

#ifdef __cplusplus
}
#endif

#endif /* __INCti81XXMcSpih */

