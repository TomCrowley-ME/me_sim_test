/* hwconf.c - Hardware configuration support module
 *
 *  --------------------------------------------------------------------------
 *  --  This file is a part of GAISLER RESEARCH source code.
 *  --  Copyright (C) 2010, Gaisler Research AB - all rights reserved.
 *  --
 *  -- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
 *  -- ACCORDANCE WITH THE GAISLER LICENSE AGREEMENT AND MUST BE APPROVED
 *  -- IN ADVANCE IN WRITING.
 *  --
 *  -- BY DEFAULT, DISTRIBUTION OR DISCLOSURE IS NOT PERMITTED.
 *  --------------------------------------------------------------------------
 *
 *
 * modification history
 * --------------------
 * 01h,15jan14,danhel, Added GRSPWPKT driver
 * 2013/3/20: Konrad Eisele <konrad@gaisler.com>, strip down to UT699 only parts
 * 01f,14apr11,danhel, Changed GRPCI I/O and MEM declaration
 * 01e,13apr11,danhel, Added GRPCI2 driver
 * 01d,08mar10,danhel, Added LEON2 UART, APBUART, GRETH
 * 01c,05jun09,danhel  Added GRCAN and GPIO drivers
 * 01b,02okt08,danhel  Added LEON2 and GRLIB AMBA PnP resources and init routine
 * 01a,18aug08,danhel  Created.
 *
 *
 * Overview
 * --------
 * This is used to configure the non Plug and Play hardware resources. LEON3 uses all plug and play
 * by adding a AMBA Plug&Play bus on the PLB. Standard LEON2 designs doesn't use Plug and Play which
 * means that all hardware resources for LEON2 CPUs must be hardcoded into this file (only for 
 * hardware that used vxBus drivers).
 *
 * Since the vxBus subsystem assumes that hcfDeviceList is an constant array and LEON2 and LEON3 differ
 * we simply set the bus type to NONE to avoid vxBus to use the unavailable resources.
 *
 */

#include <vxWorks.h>
#include <vxBusLib.h>
#include <hwif/vxbus/vxBus.h>
#include <hwif/vxbus/hwConf.h>
#include <hwif/util/vxbParamSys.h>
#include <endMedia.h>
#include "config.h"

#include <arch/sparc/leon.h>

#define VXB_BUSID_NONE 0

/* GRLIB resources */
struct hcfResource grlibAmbaResources0[] = {
	{ "regBase", HCF_RES_INT, {(void *)0} },
	{ "ambaBus", HCF_RES_ADDR, {(void *)&amba_conf} },
};
#define grlibAmbaNum0 NELEMENTS(grlibAmbaResources0)

/* GRLIB GRPCI PCI Driver resources */
#ifdef INCLUDE_GRLIB_GRPCI_PCI
extern STATUS grlibGrpciAutoconfigInclude ();
extern UCHAR grlibGrpciAutoconfigIntrAssign ();
struct hcfResource grlibGrpciPciResources[] = {
    /* prefetchable-memory is mapped to the same AHB region as MEMIO */
    { "mem32Addr", HCF_RES_ADDR, { (void *)0 } },
    { "mem32Size", HCF_RES_INT, { (void *)0 } },
    { "memIo32Addr", HCF_RES_ADDR, { (void *)PCI_MSTR_MEMIO_BUS } },
    { "memIo32Size", HCF_RES_INT, { (void *)PCI_MSTR_MEMIO_SIZE } },
    { "io32Addr", HCF_RES_ADDR, { (void *)0 } },
    { "io32Size", HCF_RES_INT, { (void *)0 } },
    /* Since GRPCI I/O is only 64KByte we define only I/O-16. The low 256Byte
     * is not used due to some devices have problem with address 0 on I/O.
     *
     * AMBA accesses to GRPCI I/O Window are translated to PCI I/O low 64KB 
     * automatically by hardware.
     */
    { "io16Addr", HCF_RES_ADDR, { (void *)0x100 } },
    { "io16Size", HCF_RES_INT, { (void *)(0x10000 - 0x100) } },
    { "cacheSize", HCF_RES_INT, { (void *)0 } },
    { "maxBusSet", HCF_RES_INT, { (void *)0 } },
    { "maxLatAllSet", HCF_RES_INT, { (void *)64 } },
    { "autoIntRouteSet", HCF_RES_INT, { (void *)TRUE } },
    { "includeFuncSet", HCF_RES_ADDR, { (void *)grlibGrpciAutoconfigInclude } },
    { "intAssignFuncSet", HCF_RES_ADDR, {(void *)grlibGrpciAutoconfigIntrAssign }},
    { "autoConfig", HCF_RES_INT, { (void *)TRUE }},
};
#define grlibGrpciPciNum NELEMENTS(grlibGrpciPciResources)
#endif


#ifdef DRV_TIMER_GRLIB_GPTIMER
/* GRLIB OCCAN resources */
struct hcfResource grlibGpTimer0Resources[] = {
    { "scalarReload",     HCF_RES_INT, {(void *)(GPTIMER_SCALAR_RELOAD)} },
#ifdef GPTIMER_MASKED_OUT_TIMERS
    { "timermask",     HCF_RES_INT, { (void *)GPTIMER_MASKED_OUT_TIMERS } }
#endif
};
#define grlibGpTimer0Num NELEMENTS(grlibGpTimer0Resources)
#endif

#ifdef DRV_GRLIB_GRETH
/* GRLIB GRETH Ethernet MAC resources */
struct hcfResource grethCtrl0Resources[] = {
	{ "enetAddr",    HCF_RES_STRING, {(void *)(GRETH0_CFG_MAC_ADDR)} },
	{ "txBdCnt",     HCF_RES_INT, {(void *)(GRETH0_CFG_TXBDNUM)} },
	{ "rxBdCnt",     HCF_RES_INT, {(void *)(GRETH0_CFG_RXBDNUM)} },
	{ "edclMedia",   HCF_RES_INT, {(void *)(
#if (GRETH0_CFG_EDCL_FD == TRUE)
		IFM_FDX |
#else
		IFM_HDX |
#endif
#if (GRETH0_CFG_EDCL_SPEED == 1)
		1 /* Auto probe */
#elif (GRETH0_CFG_EDCL_SPEED == 10)
		IFM_10_T
#elif (GRETH0_CFG_EDCL_SPEED == 100)
		IFM_100_TX
#elif (GRETH0_CFG_EDCL_SPEED == 1000)
		IFM_1000_T
#else
		0
#endif
		)} },
};
struct hcfResource grethCtrl1Resources[] = {
	{ "enetAddr",    HCF_RES_STRING, {(void *)(GRETH1_CFG_MAC_ADDR)} },
	{ "txBdCnt",     HCF_RES_INT, {(void *)(GRETH1_CFG_TXBDNUM)} },
	{ "rxBdCnt",     HCF_RES_INT, {(void *)(GRETH1_CFG_RXBDNUM)} },
	{ "edclMedia",   HCF_RES_INT, {(void *)(
#if (GRETH1_CFG_EDCL_FD == TRUE)
		IFM_FDX |
#else
		IFM_HDX |
#endif
#if (GRETH1_CFG_EDCL_SPEED == 1)
		1 /* Auto probe */
#elif (GRETH1_CFG_EDCL_SPEED == 10)
		IFM_10_T
#elif (GRETH1_CFG_EDCL_SPEED == 100)
		IFM_100_TX
#elif (GRETH1_CFG_EDCL_SPEED == 1000)
		IFM_1000_T
#else
		0
#endif
		)} },
};
#define grethCtrl0Num NELEMENTS(grethCtrl0Resources)
#define grethCtrl1Num NELEMENTS(grethCtrl1Resources)
#endif

#ifdef DRV_GRLIB_GRSPW
/* GRLIB GRSPW SpaceWire resources */
struct hcfResource grlibGrspw0Resources[] = {
    { "txBdCnt",     HCF_RES_INT, {(void *)(GRSPW0_TXBUFS_NR)} },
    { "rxBdCnt",     HCF_RES_INT, {(void *)(GRSPW0_RXBUFS_NR)} },
    { "txDataSize",  HCF_RES_INT, {(void *)(GRSPW0_TXD_SIZE)} },
    { "txHdrSize",   HCF_RES_INT, {(void *)(GRSPW0_TXH_SIZE)} },
    { "rxPktSize",   HCF_RES_INT, {(void *)(GRSPW0_RXPCK_SIZE)} }
};
struct hcfResource grlibGrspw1Resources[] = {
    { "txBdCnt",     HCF_RES_INT, {(void *)(GRSPW1_TXBUFS_NR)} },
    { "rxBdCnt",     HCF_RES_INT, {(void *)(GRSPW1_RXBUFS_NR)} },
    { "txDataSize",  HCF_RES_INT, {(void *)(GRSPW1_TXD_SIZE)} },
    { "txHdrSize",   HCF_RES_INT, {(void *)(GRSPW1_TXH_SIZE)} },
    { "rxPktSize",   HCF_RES_INT, {(void *)(GRSPW1_RXPCK_SIZE)} }
};
struct hcfResource grlibGrspw2Resources[] = {
    { "txBdCnt",     HCF_RES_INT, {(void *)(GRSPW2_TXBUFS_NR)} },
    { "rxBdCnt",     HCF_RES_INT, {(void *)(GRSPW2_RXBUFS_NR)} },
    { "txDataSize",  HCF_RES_INT, {(void *)(GRSPW2_TXD_SIZE)} },
    { "txHdrSize",   HCF_RES_INT, {(void *)(GRSPW2_TXH_SIZE)} },
    { "rxPktSize",   HCF_RES_INT, {(void *)(GRSPW2_RXPCK_SIZE)} }
};
struct hcfResource grlibGrspw3Resources[] = {
    { "txBdCnt",     HCF_RES_INT, {(void *)(GRSPW3_TXBUFS_NR)} },
    { "rxBdCnt",     HCF_RES_INT, {(void *)(GRSPW3_RXBUFS_NR)} },
    { "txDataSize",  HCF_RES_INT, {(void *)(GRSPW3_TXD_SIZE)} },
    { "txHdrSize",   HCF_RES_INT, {(void *)(GRSPW3_TXH_SIZE)} },
    { "rxPktSize",   HCF_RES_INT, {(void *)(GRSPW3_RXPCK_SIZE)} }
};
#define grlibGrspw0Num NELEMENTS(grlibGrspw0Resources)
#define grlibGrspw1Num NELEMENTS(grlibGrspw1Resources)
#define grlibGrspw2Num NELEMENTS(grlibGrspw2Resources)
#define grlibGrspw3Num NELEMENTS(grlibGrspw3Resources)
#endif

#ifdef DRV_GRLIB_GRSPWPKT
/* GRLIB GRSPW SpaceWire Packet driver resources */
struct hcfResource grspwPkt0Resources[] = {
    { "nDMA",      HCF_RES_INT, {(void *)(GRSPWPKT0_NDMA)} },
#if GRSPWPKT0_BD_ADR != 0
    { "bdDmaArea", HCF_RES_INT, {(void *)(GRSPWPKT0_BD_ADR)} },
#endif
};
struct hcfResource grspwPkt1Resources[] = {
    { "nDMA",      HCF_RES_INT, {(void *)(GRSPWPKT1_NDMA)} },
#if GRSPWPKT1_BD_ADR != 0
    { "bdDmaArea", HCF_RES_INT, {(void *)(GRSPWPKT1_BD_ADR)} },
#endif
};
struct hcfResource grspwPkt2Resources[] = {
    { "nDMA",      HCF_RES_INT, {(void *)(GRSPWPKT2_NDMA)} },
#if GRSPWPKT2_BD_ADR != 0
    { "bdDmaArea", HCF_RES_INT, {(void *)(GRSPWPKT2_BD_ADR)} },
#endif
};
struct hcfResource grspwPkt3Resources[] = {
    { "nDMA",      HCF_RES_INT, {(void *)(GRSPWPKT3_NDMA)} },
#if GRSPWPKT3_BD_ADR != 0
    { "bdDmaArea", HCF_RES_INT, {(void *)(GRSPWPKT3_BD_ADR)} },
#endif
};

#define grspwPkt0Num NELEMENTS(grspwPkt0Resources)
#define grspwPkt1Num NELEMENTS(grspwPkt1Resources)
#define grspwPkt2Num NELEMENTS(grspwPkt2Resources)
#define grspwPkt3Num NELEMENTS(grspwPkt3Resources)
#endif

#ifdef DRV_GRLIB_B1553BRM
/* GRLIB B1553-BRM resources */
struct hcfResource grlibB1553Brm0Resources[] = {
    { "clkSel",     HCF_RES_INT, {(void *)(B1553BRM_CLK_SEL)} },
    { "clkDiv",     HCF_RES_INT, {(void *)(B1553BRM_CLK_DIV)} },
    { "coreFreq",   HCF_RES_INT, {(void *)(B1553BRM_CLKFREQ_MHZ)} },
    { "dmaBaseAdr", HCF_RES_ADDR, {(void *)(B1553BRM_DMA_MEM_AREA)} }
};
#define grlibB1553Brm0Num NELEMENTS(grlibB1553Brm0Resources)
#endif

#ifdef DRV_GRLIB_OCCAN
/* GRLIB OCCAN resources */
struct hcfResource grlibOcCan0Resources[] = {
    { "txFifoLen",     HCF_RES_INT, {(void *)(OCCAN_TXFIFO_LEN)} },
    { "rxFifoLen",     HCF_RES_INT, {(void *)(OCCAN_RXFIFO_LEN)} },
};
#define grlibOcCan0Num NELEMENTS(grlibOcCan0Resources)
#endif

#ifdef DRV_GRLIB_GRCAN
/* GRLIB GRCAN resources */
struct hcfResource grlibGrcan0Resources[] = {
    { "txBufAdr",     HCF_RES_INT, {(void *)(GRCAN0_TXBUF_ADDR)} },
    { "txBufSize",    HCF_RES_INT, {(void *)(GRCAN0_TXBUF_SIZE)} },
    { "rxBufAdr",     HCF_RES_INT, {(void *)(GRCAN0_RXBUF_ADDR)} },
    { "rxBufSize",    HCF_RES_INT, {(void *)(GRCAN0_RXBUF_SIZE)} },
    { "samplingPoint",HCF_RES_INT, {(void *)(GRCAN0_BAUDRATE_SAMPPOINT)} },
    { "baudRate",     HCF_RES_INT, {(void *)(GRCAN0_DEF_BAUDRATE)} },
};
struct hcfResource grlibGrcan1Resources[] = {
    { "txBufAdr",     HCF_RES_INT, {(void *)(GRCAN1_TXBUF_ADDR)} },
    { "txBufSize",    HCF_RES_INT, {(void *)(GRCAN1_TXBUF_SIZE)} },
    { "rxBufAdr",     HCF_RES_INT, {(void *)(GRCAN1_RXBUF_ADDR)} },
    { "rxBufSize",    HCF_RES_INT, {(void *)(GRCAN1_RXBUF_SIZE)} },
    { "samplingPoint",HCF_RES_INT, {(void *)(GRCAN1_BAUDRATE_SAMPPOINT)} },
    { "baudRate",     HCF_RES_INT, {(void *)(GRCAN1_DEF_BAUDRATE)} },
};
#define grlibGrcan0Num NELEMENTS(grlibGrcan0Resources)
#define grlibGrcan1Num NELEMENTS(grlibGrcan1Resources)
#endif

#ifdef DRV_GRLIB_GRGPIO
/* GRLIB GRGPIO resources */
struct hcfResource grlibGrGpio0Resources[] = {
    { "nBits",     HCF_RES_INT, {(void *)(GRGPIO0_NUM_PORTS)} },
    { "bypass",    HCF_RES_INT, {(void *)(GRGPIO0_BYPASS)} },
};
struct hcfResource grlibGrGpio1Resources[] = {
    { "nBits",     HCF_RES_INT, {(void *)(GRGPIO1_NUM_PORTS)} },
    { "bypass",    HCF_RES_INT, {(void *)(GRGPIO1_BYPASS)} },
};
#define grlibGrGpio0Num NELEMENTS(grlibGrGpio0Resources)
#define grlibGrGpio1Num NELEMENTS(grlibGrGpio1Resources)
#endif

#ifdef DRV_GRLIB_GRTM
/* GRLIB GRTM resources */
struct hcfResource grlibGrtm0Resources[] = {
    { "bdTabAdr",     HCF_RES_INT, {(void *)(GRTM1_BD_TABLE_ADRS)} },
};
struct hcfResource grlibGrtm1Resources[] = {
    { "bdTabAdr",     HCF_RES_INT, {(void *)(GRTM2_BD_TABLE_ADRS)} },
};
#define grlibGrtm0Num NELEMENTS(grlibGrtm0Resources)
#define grlibGrtm1Num NELEMENTS(grlibGrtm1Resources)
#endif



struct hcfDevice hcfDeviceList[] =
{
	/* LEON3 resources */
	{ "ambaCtrl", 0, VXB_BUSID_PLB, 0, grlibAmbaNum0, grlibAmbaResources0 },

	/* GRPCI PCI driver resources */
#ifdef INCLUDE_GRLIB_GRPCI_PCI
	{ "grlibGrpciCtrl", 0, VXB_BUSID_AMBA, 0, grlibGrpciPciNum, grlibGrpciPciResources},
#endif

	/* GRLIB Local AMBA bus resources */
#ifdef DRV_TIMER_GRLIB_GPTIMER
	{ "grlibGpTimerDev", 0, VXB_BUSID_AMBA, 0, grlibGpTimer0Num, grlibGpTimer0Resources},
#endif

	/* GRETH Ethernet MAC driver resources */
#ifdef DRV_GRLIB_GRETH
	{ "grethCtrl", 0, VXB_BUSID_AMBA, 0, grethCtrl0Num, grethCtrl0Resources},
	{ "grethCtrl", 1, VXB_BUSID_AMBA, 0, grethCtrl0Num, grethCtrl1Resources},
#endif

#ifdef DRV_GRLIB_GRSPW
	{ "grlibGrspwDev", 0, VXB_BUSID_AMBA, 0, grlibGrspw0Num, grlibGrspw0Resources},
	{ "grlibGrspwDev", 1, VXB_BUSID_AMBA, 0, grlibGrspw1Num, grlibGrspw1Resources},
	{ "grlibGrspwDev", 2, VXB_BUSID_AMBA, 0, grlibGrspw2Num, grlibGrspw2Resources},
	{ "grlibGrspwDev", 3, VXB_BUSID_AMBA, 0, grlibGrspw3Num, grlibGrspw3Resources},
#endif
#ifdef DRV_GRLIB_GRSPWPKT
	{ "grspwPktDev", 0, VXB_BUSID_AMBA, 0, grspwPkt0Num, grspwPkt0Resources},
	{ "grspwPktDev", 1, VXB_BUSID_AMBA, 0, grspwPkt1Num, grspwPkt1Resources},
	{ "grspwPktDev", 2, VXB_BUSID_AMBA, 0, grspwPkt2Num, grspwPkt2Resources},
	{ "grspwPktDev", 3, VXB_BUSID_AMBA, 0, grspwPkt3Num, grspwPkt3Resources},
#endif
#ifdef DRV_GRLIB_B1553BRM
	{ "grlibB1553BrmDev", 0, VXB_BUSID_AMBA, 0, grlibB1553Brm0Num, grlibB1553Brm0Resources},
#endif
#ifdef DRV_GRLIB_GRCAN
	{ "grlibGrcanDev", 0, VXB_BUSID_AMBA, 0, grlibGrcan0Num, grlibGrcan0Resources},
	{ "grlibGrcanDev", 1, VXB_BUSID_AMBA, 0, grlibGrcan1Num, grlibGrcan1Resources},
#endif
#ifdef DRV_GRLIB_OCCAN
	{ "grlibOcCanDev", 0, VXB_BUSID_AMBA, 0, grlibOcCan0Num, grlibOcCan0Resources},
#endif
#ifdef DRV_GRLIB_GRGPIO
	{ "grlibGrGpioDev", 0, VXB_BUSID_AMBA, 0, grlibGrGpio0Num, grlibGrGpio0Resources},
	{ "grlibGrGpioDev", 1, VXB_BUSID_AMBA, 0, grlibGrGpio1Num, grlibGrGpio1Resources},
#endif
#ifdef DRV_GRLIB_GRTM
	{ "grlibGrtmDev", 0, VXB_BUSID_AMBA, 0, grlibGrtm0Num, grlibGrtm0Resources},
	{ "grlibGrtmDev", 1, VXB_BUSID_AMBA, 0, grlibGrtm1Num, grlibGrtm1Resources},
#endif

};

const int hcfDeviceNum = NELEMENTS(hcfDeviceList);

VXB_INST_PARAM_OVERRIDE sysInstParamTable[] =
    {
    { NULL, 0, NULL, VXB_PARAM_END_OF_LIST, {(void *)0} }
    };

/* Init hardware resources depending on processor type */
STATUS sysHwConfInit(void)
{
	struct hcfDevice *hcf;

	switch(LEONCOMPAT_VERSION) {

		case 2:	/* LEON2 CPU */
#ifndef LEON2_AMBA_PNP
		/* Mark GRLIB resources unavailable for systems without the AMBA bus */
		hcfDeviceList[0].busType = VXB_BUSID_NONE;
#endif
		break;

		default:
		case 3:	/* LEON3 CPU */
		/* Mark LEON2 resources unavailable */
		hcf = &hcfDeviceList[1];
		while((hcf < &hcfDeviceList[hcfDeviceNum]) && (hcf->busType == VXB_BUSID_PLB) ) {
			hcf->busType = VXB_BUSID_NONE;
			hcf++;
		}
		break;
	}
	return OK;
}


