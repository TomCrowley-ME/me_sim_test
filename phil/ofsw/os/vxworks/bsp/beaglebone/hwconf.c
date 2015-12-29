/* hwconf.c - hardware configuration support module */

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
01c,23oct12,my_  workround for am335x errata advisory 1.0.9:
                 C0_TX_PEND and C0_RX_PEND interrupts not
                 connected to ARM Cortex-A8
01b,10jul12,my_  fix build error when including USB (WIND00161537).
01a,08may12,my_  created from ti_dm81xx_evm BSP 01a.
*/

/* includes */

#include <vxWorks.h>
#include <vxBusLib.h>
#include <hwif/vxbus/vxBus.h>
#include <hwif/vxbus/vxbPlbLib.h>
#include <hwif/vxbus/hwConf.h>
#include <hwif/vxbus/vxbIntrCtlr.h>
#include <hwif/util/vxbParamSys.h>

#include "config.h"

/* imports */

IMPORT void sysIntAck (int vector);
UINT32 sysTimerIsDM81xx (void);
UINT32 sysTimerIsOMAP35xx (void);
unsigned int sysGetChipVer (void);
unsigned int sysGetChipRev (void);

#ifdef  DRV_SIO_NS16550
struct hcfResource am335x16550DevResources[] = {
    { "regBase",     HCF_RES_INT, { (void *)AM335X_UART1_BASE } },
    { "clkFreq",     HCF_RES_INT, { (void *)UART_CLK_FREQ } },
    { "regInterval", HCF_RES_INT, { (void *)4} },
    { "fifoLen",     HCF_RES_INT, { (void *)64} }
};
#define am335x16550DevNum NELEMENTS(am335x16550DevResources)
#endif /* DRV_SIO_NS16550 */

LOCAL const struct hcfResource am335xTimer2Resources[] = {
    { "regBase",     HCF_RES_INT,  { (void *)AM335X_GPTIMER2_BASE } },
    { "clkRateMin",  HCF_RES_INT,  { (void *)SYS_CLK_RATE_MIN } },
    { "clkRateMax",  HCF_RES_INT,  { (void *)SYS_CLK_RATE_MAX } },
    { "clkFreq",     HCF_RES_INT,  { (void *)AM335X_SYS_TIMER_CLK_FREQ } },
    { "chipCheck",   HCF_RES_ADDR, { (void *)sysTimerIsDM81xx } },
};
#define am335xTimer2Num NELEMENTS(am335xTimer2Resources)

#ifdef INCLUDE_AUX_CLK
LOCAL const struct hcfResource am335xTimer4Resources[] = {
    { "regBase",     HCF_RES_INT,  { (void *)AM335X_GPTIMER4_BASE } },
    { "clkRateMin",  HCF_RES_INT,  { (void *)AUX_CLK_RATE_MIN } },
    { "clkRateMax",  HCF_RES_INT,  { (void *)AUX_CLK_RATE_MAX } },
    { "clkFreq",     HCF_RES_INT,  { (void *)AM335X_AUX_TIMER_CLK_FREQ } },
    { "chipCheck",   HCF_RES_ADDR, { (void *)sysTimerIsDM81xx } },
};
#define am335xTimer4Num NELEMENTS(am335xTimer4Resources)
#endif /* INCLUDE_AUX_CLK */

#ifdef INCLUDE_TIMESTAMP
LOCAL const struct hcfResource am335xTimer3Resources[] = {
    { "regBase",     HCF_RES_INT,  { (void *)AM335X_GPTIMER3_BASE } },
    { "clkRateMin",  HCF_RES_INT,  { (void *) 1 } },
    { "clkRateMax",  HCF_RES_INT,  { (void *) 8000 } },
    { "clkFreq",     HCF_RES_INT,  { (void *)AM335X_TIMESTAMP_TIMER_CLK_FREQ } },
    { "chipCheck",   HCF_RES_ADDR, { (void *)sysTimerIsDM81xx } },
};
#define am335xTimer3Num NELEMENTS(am335xTimer3Resources)
#endif /* INCLUDE_TIMESTAMP */

LOCAL const struct hcfResource am335xTimer5Resources[] = {
    { "regBase",     HCF_RES_INT,  { (void *)AM335X_GPTIMER5_BASE } },
    { "clkRateMin",  HCF_RES_INT,  { (void *) 1 } },
    { "clkRateMax",  HCF_RES_INT,  { (void *) 8000 } },
    { "clkFreq",     HCF_RES_INT,  { (void *) AM335X_GP_TIMER_CLK_FREQ } },
    { "chipCheck",   HCF_RES_ADDR, { (void *)sysTimerIsDM81xx } },
};
#define am335xTimer5Num NELEMENTS(am335xTimer5Resources)

LOCAL const struct hcfResource am335xTimer6Resources[] = {
    { "regBase",     HCF_RES_INT,  { (void *)AM335X_GPTIMER6_BASE } },
    { "clkRateMin",  HCF_RES_INT,  { (void *) 1 } },
    { "clkRateMax",  HCF_RES_INT,  { (void *) 8000 } },
    { "clkFreq",     HCF_RES_INT,  { (void *) AM335X_GP_TIMER_CLK_FREQ } },
    { "chipCheck",   HCF_RES_ADDR, { (void *)sysTimerIsDM81xx } },
};
#define am335xTimer6Num NELEMENTS(am335xTimer6Resources)

#if defined (INCLUDE_USB_MHDRC_OCD) || \
    defined (INCLUDE_USB_MHDRC_HCD) || \
    defined (INCLUDE_USB_MHDRC_TCD)

#   ifndef USB_MHDRC_PLATFORM_CENTAURUS
#       define USB_MHDRC_PLATFORM_CENTAURUS  0x3
#   endif /* USB_MHDRC_PLATFORM_CENTAURUS */

const struct hcfResource vxbPlbUsbMhdrcDev0Resources[]= {
    { "regBase",            HCF_RES_INT , {(void *)AM335X_USB0_BASE} },
    { "irq",                HCF_RES_INT , {(void *)AM335X_USBINT0} },
    { "irqLevel",           HCF_RES_INT , {(void *)AM335XINT_PRI_MHCI} },
    { "rootHubNumPorts",    HCF_RES_INT , {(void *)1} },
    { "numDmaChannels",     HCF_RES_INT , {(void *)15} },
    { "numEndpoints",       HCF_RES_INT , {(void *)15} },
    { "dmaEnabled",         HCF_RES_INT , {(void *)0} },
    { "usbssRegBase",       HCF_RES_INT , {(void *)AM335X_USBSS_BASE} },
    { "platformType",       HCF_RES_INT , {(void *)USB_MHDRC_PLATFORM_CENTAURUS} }
};
#define vxbPlbUsbMhdrcDev0Num NELEMENTS(vxbPlbUsbMhdrcDev0Resources)

const struct hcfResource vxbPlbUsbMhdrcDev1Resources[]= {
    { "regBase",            HCF_RES_INT , {(void *)AM335X_USB1_BASE} },
    { "irq",                HCF_RES_INT , {(void *)AM335X_USBINT1} },
    { "irqLevel",           HCF_RES_INT , {(void *)AM335XINT_PRI_MHCI} },
    { "rootHubNumPorts",    HCF_RES_INT , {(void *)1} },
    { "numDmaChannels",     HCF_RES_INT , {(void *)15} },
    { "numEndpoints",       HCF_RES_INT , {(void *)15} },
    { "dmaEnabled",         HCF_RES_INT , {(void *)0} },
    { "usbssRegBase",       HCF_RES_INT , {(void *)AM335X_USBSS_BASE} },
    { "platformType",       HCF_RES_INT , {(void *)USB_MHDRC_PLATFORM_CENTAURUS} }
};
#define vxbPlbUsbMhdrcDev1Num NELEMENTS(vxbPlbUsbMhdrcDev1Resources)

#endif /* USB OCD || USB HCD || USB TCD */

#ifdef DRV_TI_EDMA3
#include <hwif/util/vxbDmaLib.h>
#include <../src/hwif/h/util/vxbDmaDriverLib.h>
#include <../src/hwif/h/dmaCtlr/vxbTiEdma3.h>

/*
 * This parameter specifies each DAM transmit queue's priority. There are
 * 4 transmit queues in the TI EDMA3 controller with priority range in
 * [0-3].
 */

unsigned char priTable[4] = {0, 0, 0, 0};

/*
 * This parameter specifies the channel-to-queue mappings. There are 64 dma
 * channels in the TI EDMA3 controller and 4 DMA transmit queues. Each of
 * the 64 channels can make use any of the 4 transmit queue.
 */

TI_EDMA3_CHAN_MAP chanMapping[8] = {
    { { 0, 0, 0, 0, 0, 0, 0, 0 }},
    { { 0, 0, 0, 0, 0, 0, 0, 0 }},
    { { 1, 1, 1, 1, 1, 1, 1, 1 }},
    { { 1, 1, 1, 1, 1, 1, 1, 1 }},
    { { 2, 2, 2, 2, 2, 2, 2, 2 }},
    { { 2, 2, 2, 2, 2, 2, 2, 2 }},
    { { 3, 3, 3, 3, 3, 3, 3, 3 }},
    { { 3, 3, 3, 3, 3, 3, 3, 3 }}
};
const struct hcfResource am335xDmaResources[] = {
    { "regBase",            HCF_RES_INT,      { (void *)AM335X_EDMA_BASE} },
    { "prorityTable",       HCF_RES_ADDR,     { (void *)priTable} },
    { "chanMapping",        HCF_RES_ADDR,     { (void *)chanMapping } },
    };
#define am335xDmaNum NELEMENTS(am335xDmaResources)
#endif /* DRV_TI_EDMA3 */

struct intrCtlrInputs am335xIntCtlrInputs[] = {
    /* pin,                 driver,         unit,   index */

    { AM335X_TINT2,          "omap35xxTimer",  0, 0},
#ifdef INCLUDE_AUX_CLK
    { AM335X_TINT4,          "omap35xxTimer",  1, 0},
#endif /* INCLUDE_AUX_CLK */
#ifdef INCLUDE_TIMESTAMP
    { AM335X_TINT3,          "omap35xxTimer",  2, 0},
#endif /* INCLUDE_TIMESTAMP */
    { AM335X_TINT5,          "omap35xxTimer",  3, 0},
    { AM335X_TINT6,          "omap35xxTimer",  4, 0},

    { AM335X_GPIOINT0B,      "legacy"       ,  0, AM335X_GPIOINT0B},

#if defined (INCLUDE_USB_MHDRC_OCD) || \
    defined (INCLUDE_USB_MHDRC_HCD) || \
    defined (INCLUDE_USB_MHDRC_TCD)
    { AM335X_USBINT0,        "vxbPlbUsbMhdrcTcd",      0,      0},
    { AM335X_USBSSINT,       "vxbPlbUsbMhdrcTcd",      0,      1},
    { AM335X_USBINT1,        "vxbPlbUsbMhdrcHcd",      0,      0},
#endif

#ifdef DRV_TI_EDMA3
    { AM335X_EDMACOMPINT,    "tiedma3"      ,  0, 0},
    { AM335X_EDMAMAPERR,     "tiedma3"      ,  0, 1},
    { AM335X_EDMAERRINT,     "tiedma3"      ,  0, 2},
#endif /* DRV_TI_EDMA3 */

#ifdef DRV_STORAGE_OMAP35XX_MMCHS
    { AM335X_GPIOINT0A,      "legacy"       ,  0, AM335X_GPIOINT0A},
    { AM335X_SDINT0,         "omap35xxMmchs",  0, 0},
    { AM335X_SDINT1,         "omap35xxMmchs",  1, 0},
#endif

#ifdef DRV_SIO_NS16550
    { AM335X_UARTINT0,       "ns16550"      ,  0, 0},
#endif /* DRV_SIO_NS16550 */

#ifdef DRV_VXBEND_TI_CPSW
    { AM335X_3PGSWTXINT0,    "cpsw"         ,  0, 0},
    { AM335X_3PGSWRXINT0,    "cpsw"         ,  0, 1},
    { AM335X_3PGSWRXTHR0,    "cpsw"         ,  0, 2},
    { AM335X_3PGSWMISC0,     "cpsw"         ,  0, 3},
#endif /* DRV_VXBEND_TI_CPSW */

#ifdef DRV_I2C_AM38XX
    { AM335X_I2CINT0,        "am38xxI2c"    ,  0, 0},
    { AM335X_I2CINT1,        "am38xxI2c"    ,  0, 0},
    { AM335X_I2CINT2,        "am38xxI2c"    ,  0, 0},
#endif /*DRV_I2C_AM38XX */
};
const int am335xIntCtlrInputsNum =  NELEMENTS(am335xIntCtlrInputs);

struct intrCtlrPriority am335xIntCtlrPriority[] = {
    /* pin,                  priority */

    { AM335X_TINT2,          AM335XINT_PRI_TIMER_2},
#ifdef INCLUDE_AUX_CLK
    { AM335X_TINT4,          AM335XINT_PRI_TIMER_4},
#endif /* INCLUDE_AUX_CLK */
#ifdef INCLUDE_TIMESTAMP
    { AM335X_TINT3,          AM335XINT_PRI_TIMER_3},
#endif /* INCLUDE_TIMESTAMP */
    { AM335X_TINT5,          AM335XINT_PRI_TIMER_5},
    { AM335X_TINT6,          AM335XINT_PRI_TIMER_6},

    { AM335X_GPIOINT0B,      AM335XINT_PRI_GPIO0B},

#if defined (INCLUDE_USB_MHDRC_OCD) || \
    defined (INCLUDE_USB_MHDRC_HCD) || \
    defined (INCLUDE_USB_MHDRC_TCD)
    { AM335X_USBINT0,        AM335XINT_PRI_MHCI},
    { AM335X_USBSSINT,       AM335XINT_PRI_MHCI},
    { AM335X_USBINT1,        AM335XINT_PRI_MHCI},
#endif

#ifdef DRV_STORAGE_OMAP35XX_MMCHS
    { AM335X_GPIOINT0A,      AM335XINT_PRI_MMC},
    { AM335X_SDINT0,         AM335XINT_PRI_MMC},
    { AM335X_SDINT1,         AM335XINT_PRI_MMC},
#endif /* DRV_STORAGE_OMAP35XX_MMCHS */

#ifdef DRV_TI_EDMA3
    { AM335X_EDMACOMPINT,    AM335XINT_PRI_EDMACOMP},
    { AM335X_EDMAMAPERR,     AM335XINT_PRI_EDMAMAPERR},
    { AM335X_EDMAERRINT,     AM335XINT_PRI_EDMAERRINT},
#endif /* DRV_TI_EDMA3 */

#ifdef DRV_SIO_NS16550
    { AM335X_UARTINT0,       AM335XINT_PRI_UART_2 },
#endif /* DRV_SIO_NS16550 */

#ifdef DRV_VXBEND_TI_CPSW
    { AM335X_3PGSWTXINT0,    AM335XINT_PRI_ENET },
    { AM335X_3PGSWRXINT0,    AM335XINT_PRI_ENET },
    { AM335X_3PGSWRXTHR0,    AM335XINT_PRI_ENET },
    { AM335X_3PGSWMISC0,     AM335XINT_PRI_ENET },
#endif /* DRV_VXBEND_TI_CPSW */

#ifdef DRV_I2C_AM38XX
    { AM335X_I2CINT0,        AM335XINT_PRI_I2C},
    { AM335X_I2CINT1,        AM335XINT_PRI_I2C},
    { AM335X_I2CINT2,        AM335XINT_PRI_I2C},
#endif /*DRV_I2C_AM38XX */

};
const int am335xIntPriInputsNum = NELEMENTS(am335xIntCtlrPriority);

/* interrupt controller driver resources.  */

const struct hcfResource am335xIntCtlrResources[] = {
    { "regBase",             HCF_RES_INT,   { (void *)AM335X_MPU_INTC } },
    { "intMode",             HCF_RES_INT,   { (void *)INT_MODE } },
    { "input",               HCF_RES_ADDR,  { (void *)&am335xIntCtlrInputs[0] } },
    { "inputTableSize",      HCF_RES_INT,   { (void *)NELEMENTS(am335xIntCtlrInputs) } },
    { "priority",            HCF_RES_ADDR,  { (void *)&am335xIntCtlrPriority[0] } },
    { "priorityTableSize",   HCF_RES_INT,   { (void *)NELEMENTS(am335xIntCtlrPriority) } },
    { "numInterruptSources", HCF_RES_INT,   { (void *)MPU_INTERRUPT_NUM } },
    { "prcmEnable",          HCF_RES_INT,   { (void *)FALSE} },
    { "sysIntAck",           HCF_RES_ADDR,  { (void *)NULL} }
};

#define am335xIntCtlrNum NELEMENTS(am335xIntCtlrResources)

#ifdef DRV_STORAGE_OMAP35XX_MMCHS
#include <../src/hwif/h/storage/vxbSdMmcLib.h>

IMPORT BOOL   sysCardDetect       (void);
IMPORT BOOL   sysCardWpCheck      (void);
IMPORT BOOL   sysCardPowerOn      (void);
IMPORT BOOL   sysCardPowerInit    (void);
IMPORT STATUS sysCardDmaStart     (SDMMC_HOST * , SDMMC_CMD *);
IMPORT STATUS sysCardDmaChanAlloc (void *);
IMPORT void   sysCardDmaChanFree  (void *);

struct hcfResource am335xMmchsResources[] =  {
    { "regBase",             HCF_RES_INT,    { (void *)AM335X_MMC0_SDHC_BASE  } },
    { "cardDetect",          HCF_RES_ADDR,   { (void *)sysCardDetect } },
    { "cardWpCheck",         HCF_RES_ADDR,   { (void *)sysCardWpCheck } },
    { "cardPowerOn",         HCF_RES_ADDR,   { (void *)sysCardPowerOn } },
    { "dmaMode",             HCF_RES_INT,    { (void *)0 } },
    { "dmaStart",            HCF_RES_ADDR,   { (void *)sysCardDmaStart } },
    { "dmaAlloc",            HCF_RES_ADDR,   { (void *)sysCardDmaChanAlloc } },
    { "dmaFree",             HCF_RES_ADDR,   { (void *)sysCardDmaChanFree } },
};
#define am335xMmchsNum  NELEMENTS(am335xMmchsResources)

IMPORT BOOL   sysEmmcDetect       (void);
IMPORT BOOL   sysEmmcWpCheck      (void);
IMPORT BOOL   sysEmmcPowerOn      (void);
IMPORT BOOL   sysEmmcPowerInit    (void);
IMPORT STATUS sysEmmcDmaStart     (SDMMC_HOST * , SDMMC_CMD *);
IMPORT STATUS sysEmmcDmaChanAlloc (void *);
IMPORT void   sysEmmcDmaChanFree  (void *);

struct hcfResource am335xEmmcResources[] =  {
    { "regBase",             HCF_RES_INT,    { (void *)AM335X_MMC1_SDHC_BASE  } },
    { "cardDetect",          HCF_RES_ADDR,   { (void *)sysEmmcDetect } },
    { "cardWpCheck",         HCF_RES_ADDR,   { (void *)sysEmmcWpCheck } },
    { "cardPowerOn",         HCF_RES_ADDR,   { (void *)sysEmmcPowerOn } },
    { "dmaMode",             HCF_RES_INT,    { (void *)0 } },
    { "dmaStart",            HCF_RES_ADDR,   { (void *)sysEmmcDmaStart } },
    { "dmaAlloc",            HCF_RES_ADDR,   { (void *)sysEmmcDmaChanAlloc } },
    { "dmaFree",             HCF_RES_ADDR,   { (void *)sysEmmcDmaChanFree } },
};
#define am335xEmmcNum  NELEMENTS(am335xEmmcResources)
#endif /* DRV_STORAGE_OMAP35XX_MMCHS */

#ifdef DRV_VXBEND_TI_CPSW
typedef struct cpsw_gmac_regs {
      UINT32 portoff;
      UINT32 gmacoff;
      int    port;
}CPSW_GMAC_REGS;

LOCAL CPSW_GMAC_REGS gmacRegs[2] = {
        {0x208, 0xd80, 1},  /* portOffset 0x100 + 0x108 */
        {0x308, 0xdc0, 2}   /* 0x100 + 0x208 */
};
struct hcfResource am335xCpsw0Resources[] =  {
    { "regBase",      HCF_RES_INT,   {(void *)AM335X_EMAC0_BASE} },
    { "regBase1",     HCF_RES_INT,   {(void *)0x108} },  /* portOffset */
    { "regBase2",     HCF_RES_INT,   {(void *)0x800} },  /* cpdmaOffset */
    { "regBase3",     HCF_RES_INT,   {(void *)0x400} },  /* statsOffset */
    { "regBase4",     HCF_RES_INT,   {(void *)0xd00} },  /* aleOffset */
    { "regBase5",     HCF_RES_INT,   {(void *)0x1000} }, /* mdioOffset */
    { "hostPortNr",   HCF_RES_INT,   {(void *)0x0} },
    { "dualEmac",     HCF_RES_INT,   {(void *)0x1} },
    { "chipVersion",  HCF_RES_ADDR,  {(void *)sysGetChipVer} },
    { "chipRevision", HCF_RES_ADDR,  {(void *)sysGetChipRev} },
    { "gmacRegs",     HCF_RES_ADDR,  {(void *)gmacRegs} },
};
#define am335xCpswNum NELEMENTS(am335xCpsw0Resources)
#endif /* DRV_VXBEND_TI_CPSW */

#ifdef DRV_I2C_AM38XX
#include <hwif/vxbus/vxbI2cLib.h>

struct i2cDevInputs i2c0DevTbl[] = {
    /*  name                devAddr         flag */
    { "eeprom_at24c256",    0x50,           I2C_WORDADDR},
    { "tps65217c",          0x24,           0},
};

const struct hcfResource i2c0Resources[] = {
    { "regBase",            HCF_RES_INT,    { (void *)(AM335X_I2C0_BASE) } },
    { "fClkFreq",           HCF_RES_INT,    { (void *)48000000 } },
    { "iClkFreq",           HCF_RES_INT,    { (void *)24000000 } },
    { "busSpeed",           HCF_RES_INT,    { (void *)400000 } },
    { "polling",            HCF_RES_INT,    { (void *)1 } },
    { "i2cDev",             HCF_RES_ADDR,   { (void *)&i2c0DevTbl } },
    { "i2cDevNum",          HCF_RES_INT,    { (void *)NELEMENTS(i2c0DevTbl) } }
};
#define i2c0Num NELEMENTS(i2c0Resources)
#endif /* DRV_I2C_AM38XX */

const struct hcfDevice hcfDeviceList[] = {
    { "vxbOmapIntCtrl", 0, VXB_BUSID_PLB, 0, am335xIntCtlrNum  , am335xIntCtlrResources   },
    { "omap35xxTimer",  0, VXB_BUSID_PLB, 0, am335xTimer2Num   , am335xTimer2Resources    },
#ifdef INCLUDE_AUX_CLK
    { "omap35xxTimer",  1, VXB_BUSID_PLB, 0, am335xTimer4Num   , am335xTimer4Resources    },
#endif /* INCLUDE_AUX_CLK */
#ifdef INCLUDE_TIMESTAMP
    { "omap35xxTimer",  2, VXB_BUSID_PLB, 0, am335xTimer3Num   , am335xTimer3Resources    },
#endif /* INCLUDE_TIMESTAMP */
    { "omap35xxTimer",  3, VXB_BUSID_PLB, 0, am335xTimer5Num   , am335xTimer5Resources    },
    { "omap35xxTimer",  4, VXB_BUSID_PLB, 0, am335xTimer6Num   , am335xTimer6Resources    },

#if defined (INCLUDE_USB_MHDRC_OCD) || \
    defined (INCLUDE_USB_MHDRC_HCD) || \
    defined (INCLUDE_USB_MHDRC_TCD)

#ifdef INCLUDE_USB_MHDRC_TCD
    {"vxbPlbUsbMhdrcTcd", 0, VXB_BUSID_PLB, 0, vxbPlbUsbMhdrcDev0Num, vxbPlbUsbMhdrcDev0Resources},
#endif /* INCLUDE_USB_MHDRC_HCD */

#ifdef INCLUDE_USB_MHDRC_HCD
    {"vxbPlbUsbMhdrcHcd", 0, VXB_BUSID_PLB, 0, vxbPlbUsbMhdrcDev1Num, vxbPlbUsbMhdrcDev1Resources},
#endif /* INCLUDE_USB_MHDRC_HCD */

#endif

#ifdef DRV_TI_EDMA3
    { "tiedma3",       0, VXB_BUSID_PLB, 0, am335xDmaNum      , am335xDmaResources       },
#endif /* DRV_TI_EDMA3 */

#ifdef DRV_STORAGE_OMAP35XX_MMCHS
    { "omap35xxMmchs", 0, VXB_BUSID_PLB, 0, am335xMmchsNum    , am335xMmchsResources     },
    { "omap35xxMmchs", 1, VXB_BUSID_PLB, 0, am335xEmmcNum     , am335xEmmcResources      },
#endif /* DRV_STORAGE_OMAP35XX_MMCHS */

#ifdef DRV_SIO_NS16550
    { "ns16550",       0, VXB_BUSID_PLB, 0, am335x16550DevNum , am335x16550DevResources  },
#endif /* DRV_SIO_NS16550 */

#ifdef DRV_VXBEND_TI_CPSW
    { "cpsw",          0, VXB_BUSID_PLB, 0, am335xCpswNum     , am335xCpsw0Resources     },
#endif /* DRV_VXBEND_TI_CPSW */

#ifdef DRV_I2C_AM38XX
    { "am38xxI2c",     0, VXB_BUSID_PLB, 0, i2c0Num           , i2c0Resources            },
#endif /* DRV_I2C_AM38XX */
};
const int hcfDeviceNum = NELEMENTS(hcfDeviceList);

VXB_INST_PARAM_OVERRIDE sysInstParamTable[] = {
#ifdef DRV_I2C_EEPROM
    { "eeprom_at24c256",0,"writeDelay", VXB_PARAM_INT32, { (void *)10000 }},
#endif
    { NULL , 0,  NULL     , VXB_PARAM_END_OF_LIST, { (void *)0 } }
};

