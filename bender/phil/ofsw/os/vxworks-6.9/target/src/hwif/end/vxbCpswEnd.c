/* vxbCpswEnd.c - TI 3 port gigabit switch VxBus END driver */

/*
 * Copyright (c) 2011-2014 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify or otherwise make use
 * of this software may be licensed only pursuant to the terms
 * of an applicable Wind River license agreement.
 */

/*
modification history
--------------------
23oct14,m_w  fixed polling statistics error. (VXW6-83668)
19may14,g_x  get the MAC port number if exists. (VXW6-82625)
08apr14,d_l  update MAC address in cpswEndIoctl.(VX6-73520)
17mar14,g_x  specify the PHY address if the BSP define it
01q,25oct13,d_l  Fix cpswLinkUpdate wrong parameter. (WIND00439527)
01p,26sep13,xms  Fix multicast test fail issue. (WIND00434181)
                 Fix compile warnings
01o,18sep13,xms  Fix frame padding issue. (WIND00431862)
01n,12aug13,c_l  Add 10M support for am335x. (WIND00407010)
01m,24jun13,c_l  Fix big packet failure. (WIND00422970)
01l,27may13,g_x  Create cpswMacSem and make its semTake/Give matched.
                 (WIND00392285)
01k,01apr13,c_l  Remove build warnings. (WIND00409411)
01j,23oct12,my_  workaround for am335x errata 1.0.9 (WIND00384090)
01i,19oct12,my_  fix wdb system mode failure (WIND00383259)
01h,24sep12,my_  fix coverity warnings (WIND00378296)
01g,13sep12,my_  add documentation about promisc mode
                 add default port vlan definition
                 correct the documentation about regBase4 and
                 regBase5; re-implement dual emac support by using
                 vlan table rather than putting ALE into
                 bypass mode thus accord with the manual; add
                 basic promisc mode support; improve error output
                 in cpswEndErrHandle()
                 improve cpswAleEntryShow() to show more
                 information; change the prototype of
                 cpswAleAddMultiCast() and cpswAleAddUniCast()
01f,02jul12,my_  modify cpswEndStop() to give rx/tx handler a
                 chance to finish during reboot (WIND00357187)
01e,20may12,my_  add support for am335x
01d,19apr12,clx  add "\ce" to fix error with documentation generation
                 (WIND00345783)
01c,19apr12,fao  fix apigen build error. (WIND00346008)
01b,07mar12,my_  fix a typo which causes second gmac not working
                 under certain conditions (WIND00337783).
                 fix rx misqueue handling
01a,01aug11,my_  written
*/

/*
DESCRIPTION
This module implements an END driver for the TI 3 port gigabit switch
(CPSW) network interface. The TI CPSW is a layer 2 ethernet switch.
The TI CPSW combines 2 10/100/1000 MAC ports and a DMA/CPU port.

However this driver doesn't support CPSW operating in switch mode.
Instead this driver configures the CPSW to operate in dual EMAC mode
by disabling address learning on the 2 GMAC ports and constructing
the MAC address look-up table manually during intialization.

To VxBus, there will only be one device instance, however
to support two devices, we need two END objects, as well as two private
device contexts. To implement this, the pDrvCtrl structure attached to
the VxBus device instance for a dual link device is actually an array of
two pDrvCtrls. Note that this means that it's not possible to unload
a single network interface on a dual link device: if the VxBus device
instance is deleted, that will cause both interfaces to be removed.

This driver supports promisc mode by setting ALE (Address Lookup Engine)
into bypass mode. In bypass mode, all packets received will be forwarded
only to host port and ingress checking is ignored. Because there are two
ethernet ports inside the CPSW, so there are two END objects showing up
when calling ifconfig shell command and because ALE is a shared resouce
so if one port is put into promisc mode then the other will also be put
into promisc mode automatically, but interface capability flags don't change
automactically. For example, calling:
\cs
ifconfig "cpsw0 inet promisc"
\ce
will put both cpsw0 and cpsw1 into promisc mode, but only cpsw0's
capability flags will show:

\cs
UP RUNNING SIMPLEX BROADCAST MULTICAST PROMISC ALLMULTI
\ce

cpsw1's capability flags will not be changed, the following command
must be called for cpsw1 to show up correctly:

\cs
ifconfig "cpsw1 inet promisc"
\ce

This same is true when removing promisc mode.

BOARD LAYOUT
The network interfaces are internal to the CPU. All configurations
are jumperless. See target.ref for connector locations.

EXTERNAL INTERFACE
The driver provides the standard VxBus external interface,
vxbCpswEndRegister(). This function registers the driver with the VxBus
subsystem, and instances will be created as needed. Since this is
a processor local bus device, each device instance must be specified
in the hwconf.c file in a BSP. The hwconf entry must specify the following
parameters (NOTE: this driver does require many sub-module register offset
specified as the offfset may be different on other boards, eg. on TI DM647/DM648
the offset of various sub-modules and port number assignments
are different from this one):

\is

\i <regBase>
Specifies the base address where Network control module registers are mapped
into the host's address space. All register offsets are computed relative to
this address

\i <hostPortNr>
Specifies the host(cpu or dma) port number.

\i <regBase1>
Specifies the offset of host port register set.

\i <regBase2>
Specifies the offset of DMA register set.

\i <regBase3>
Specifies the offset of statictics register set.

\i <regBase4>
Specifies the offset of ALE register set.

\i <regBase5>
Specifies the offset of MDIO register set.

\i <regBase6>
Specifies the offset of CPSW WR register set. For backward
compability, this resource can be ignored by BSP. In that
case, chipVersion is used to determin the offset of WR
register set. If chipVersion is not specified by BSP, then
this resource will be defaults to 814x

\i <dualEmac>
If this is set to 1, then the ethernet port operates in dual
emac mode. (Currently, only dual emac mode is supported, switch
mode is not supported)

\i <chipVersion>
Speficies the function that returusn SoC chip version. This
information is used to set different features of different SoC.

\i <gmacOffset>
Specifies the offset of GMAC register set. This parameter has the
following form:

typedef struct
    {
    UINT32 portOffset;  @ offset of the mac port reister set
    UINT32 gmacOffset;  @ offset of the mac control register set
    int    portnr    ;  @ mac port number
    };
\ie

An example hwconf entry is shown below:

\cs
struct gmacOffsets[2] =  {
        {0xxxxx, 0xxxxx, 0x1};
        {0xxxxx, 0xxxxx, 0x2};
};

struct hcfResource cpswEndResources[] = {
    { "regBase"    ,    HCF_RES_INT,    {(void *)0xxxxx} },
    { "regBase1"   ,    HCF_RES_INT,    {(void *)0xxxxx} },
    { "regBase2"   ,    HCF_RES_INT,    {(void *)0xxxxx} },
    { "regBase3"   ,    HCF_RES_INT,    {(void *)0xxxxx} },
    { "regBase4"   ,    HCF_RES_INT,    {(void *)0xxxxx} },
    { "regBase5"   ,    HCF_RES_INT,    {(void *)0xxxxx} },
    { "regBase6"   ,    HCF_RES_INT,    {(void *)0xxxxx} },
    { "hostPortNr" ,    HCF_RES_INT,    {(void *)0} },
    { "dualEmac"   ,    HCF_RES_INT,    {(void *)1} },
    { "chipVersion",    HCR_RES_ADDR,   {(void *)sysChipVerGet },
    { "gmacOffset" ,    HCF_RES_ADDR,   {(void *)gmacOffsets} },
};

#define cpswEndNum NELEMENTS(cpswEndResources)
\ce

\cs
This driver requires one external support function from the BSP.
\ce

\is

\i sysNetMacNVRamAddrGet()

\ie

\cs

STATUS sysNetMacNVRamAddrGet (ifName, ifUnit, ifMacAddr, ifMacAddrLen)

\ce

\cs

This routine queries the BSP to provide the ethernet address for a given MAC.

\ce

Note: This driver only supports dual emac mode, switch mode is not supported.

RESTRICTIONS

SEE ALSO: VxBus, miiBus, ifLib
*/

#include <vxWorks.h>
#include <string.h>
#include <intLib.h>
#include <stdio.h>
#include <logLib.h>
#include <muxLib.h>
#include <netLib.h>
#include <netBufLib.h>
#include <semLib.h>
#include <sysLib.h>
#include <vxBusLib.h>
#include <wdLib.h>
#include <etherMultiLib.h>
#include <end.h>
#define END_MACROS
#include <endLib.h>
#include <endMedia.h>
#include <cacheLib.h>
#include <spinLockLib.h>

#include <hwif/vxbus/vxBus.h>
#include <hwif/vxbus/hwConf.h>
#include <hwif/util/vxbDmaBufLib.h>
#include <hwif/util/vxbParamSys.h>
#include <../src/hwif/h/mii/miiBus.h>
#include <../src/hwif/h/vxbus/vxbAccess.h>
#include <../src/hwif/h/hEnd/hEnd.h>
#include <../src/hwif/h/end/vxbCpswEnd.h>

#undef CPSW_END_DEBUG

#ifdef CPSW_END_DEBUG
#   define CPSW_DEBUG(fmt,a,b,c,d,e,f) \
       if (_func_logMsg) \
           (* _func_logMsg) (fmt,a,b,c,d,e,f)
#else
#   define CPSW_DEBUG(fmt,a,b,c,d,e,f)
#endif

/* accessor definitions */

#define CPSW_BAR(p)      ((CPSW_HOST_CTRL *)(p)->pDrvCtrl)->regBase
#define CPSW_DMA_BAR(p)  ((CPSW_HOST_CTRL *)(p)->pDrvCtrl)->cpdmaOffset
#define CPSW_HANDLE(p)   ((CPSW_HOST_CTRL *)(p)->pDrvCtrl)->handle

#define CSR_READ_4(pDev, addr)          \
    vxbRead32(CPSW_HANDLE(pDev),     \
              (UINT32 *)((char *)CPSW_BAR(pDev) + (addr)))

#define CSR_WRITE_4(pDev, addr, data)   \
    vxbWrite32(CPSW_HANDLE(pDev),    \
               (UINT32 *)((char *)CPSW_BAR(pDev) + (addr)), (data))

#define CSR_SET_BIT(pDev, offset, val) \
    CSR_WRITE_4(pDev, offset, CSR_READ_4(pDev, offset) | (val))

#define CSR_CLR_BIT(pDev, offset, val) \
    CSR_WRITE_4(pDev, offset, CSR_READ_4(pDev, offset) & ~(val))

/* DMA manipulation macros */

#define CPDMA_REG_READ(pDev, addr) \
    vxbRead32(CPSW_HANDLE(pDev), \
                    (UINT32 *)((UINT32)CPSW_BAR(pDev) + \
                     (UINT32)CPSW_DMA_BAR(pDev) + (addr)))

#define CPDMA_REG_WRITE(pDev, addr, data) \
    vxbWrite32(CPSW_HANDLE(pDev), \
                    (UINT32 *)((UINT32)CPSW_BAR(pDev) + \
                     (UINT32)CPSW_DMA_BAR(pDev) + (addr)), (data))

#define CPDMA_TX_EN(pDev) \
    CSR_WRITE_4(pDev, CPSW_DMA_BAR(pDev) + CPDMA_TX_CONTROL, 0x1)

#define CPDMA_RX_EN(pDev) \
    CSR_WRITE_4(pDev, CPSW_DMA_BAR(pDev) + CPDMA_RX_CONTROL, 0x1)

#define CPDMA_RX_DIS(pDev) \
    CSR_WRITE_4(pDev, CPSW_DMA_BAR(pDev) + CPDMA_RX_CONTROL, 0x0)

#define CPDMA_TX_DIS(pDev) \
    CSR_WRITE_4(pDev, CPSW_DMA_BAR(pDev) + CPDMA_TX_CONTROL, 0x0)

#define CPDMA_HOSTERR_INT_EN(pDev) \
    CSR_WRITE_4(pDev, CPSW_DMA_BAR(pDev) + CPDMA_INTMASK_SET, 0x2)

#define CPDMA_HOSTERR_INT_DIS(pDev) \
    CSR_WRITE_4(pDev, CPSW_DMA_BAR(pDev) + CPDMA_INTMASK_CLR, 0x2)

#define CPDMA_TX_INT_EN(pDev, tx) \
    CSR_WRITE_4(pDev, CPSW_DMA_BAR(pDev) + CPDMA_TX_INTMASK_SET, (0x1 << (tx)))

#define CPDMA_TX_INT_DIS(pDev, tx) \
    CSR_WRITE_4(pDev, CPSW_DMA_BAR(pDev) + CPDMA_TX_INTMASK_CLR, (0x1 << (tx)))

#define CPDMA_RX_INT_EN(pDev, rx) \
    CSR_WRITE_4(pDev, CPSW_DMA_BAR(pDev) + CPDMA_RX_INTMASK_SET, (0x1 << (rx)))

#define CPDMA_RX_INT_DIS(pDev, rx) \
    CSR_WRITE_4(pDev, CPSW_DMA_BAR(pDev) + CPDMA_RX_INTMASK_CLR, (0x1 << (rx)))

#define CPDMA_TX_HOST_ERR_CODE(n) (((n) & 0xf00000) >> 20)
#define CPDMA_RX_HOST_ERR_CODE(n) (((n) & 0xf000)   >> 12)
#define CPDMA_TX_HOST_ERR_CHAN(n) (((n) & 0xf0000)  >> 16)
#define CPDMA_RX_HOST_ERR_CHAN(n) (((n) & 0xf00)    >> 8)

#define CPSW_DESC_INC(index, cnt) (index) = (((index) + 1) % (cnt))

LOCAL UINT32 cpdmaHDPoffset = 0;

/* import functions */

IMPORT FUNCPTR  _func_m2PollStatsIfPoll;
IMPORT STATUS   sysNetMacNVRamAddrGet (char *, int, UINT8 *, int);
IMPORT void     vxbUsDelay            (int);

/* VxBus interfaces */

LOCAL void      cpswInstInit    (VXB_DEVICE_ID);
LOCAL void      cpswInstInit2   (VXB_DEVICE_ID);
LOCAL void      cpswInstConnect (VXB_DEVICE_ID);
LOCAL STATUS    cpswInstUnlink  (VXB_DEVICE_ID, void *);
LOCAL STATUS    cpswPhyRead     (VXB_DEVICE_ID, UINT8, UINT8, UINT16 *);
LOCAL STATUS    cpswPhyWrite    (VXB_DEVICE_ID, UINT8, UINT8, UINT16);
LOCAL STATUS    cpswLinkUpdate  (VXB_DEVICE_ID);
LOCAL void      cpswMuxConnect  (VXB_DEVICE_ID, void *);

/* driver utility functions */

LOCAL struct drvBusFuncs cpswFuncs = {
    cpswInstInit,   /* devInstanceInit */
    cpswInstInit2,  /* devInstanceInit2 */
    cpswInstConnect /* devConnect */
};

LOCAL struct vxbDeviceMethod cpswMethods[] = {
    DEVMETHOD(miiRead,       cpswPhyRead),
    DEVMETHOD(miiWrite,      cpswPhyWrite),
    DEVMETHOD(miiMediaUpdate,cpswLinkUpdate),
    DEVMETHOD(muxDevConnect, cpswMuxConnect),
    DEVMETHOD(vxbDrvUnlink,  cpswInstUnlink),
    { 0, 0 }
};

/* default queue parameters */

LOCAL HEND_RX_QUEUE_PARAM cpswRxQueueDefault = {
    NULL,                       /* jobQueId */
    0,                          /* priority */
    0,                          /* rbdNum */
    0,                          /* rbdTupleRatio */
    0,                          /* rxBufSize */
    NULL,                       /* pBufMemBase */
    0,                          /* rxBufMemSize */
    0,                          /* rxBufMemAttributes */
    NULL,                       /* rxBufMemFreeMethod */
    NULL,                       /* pRxBdBase */
    0,                          /* rxBdMemSize */
    0,                          /* rxBdMemAttributes */
    NULL                        /* rxBdMemFreeMethod */
};

LOCAL HEND_TX_QUEUE_PARAM cpswTxQueueDefault = {
    NULL,                       /* jobQueId */
    0,                          /* priority */
    0,                          /* tbdNum */
    0,                          /* allowedFrags */
    NULL,                       /* pTxBdBase */
    0,                          /* txBdMemSize */
    0,                          /* txBdMemAttributes */
    NULL                        /* txBdMemFreeMethod */
};

LOCAL VXB_PARAMETERS cpswParamDefaults[] = {
    {"rxQueue00", VXB_PARAM_POINTER, {(void *)&cpswRxQueueDefault}},
    {"txQueue00", VXB_PARAM_POINTER, {(void *)&cpswTxQueueDefault}},
    {NULL       , VXB_PARAM_END_OF_LIST, {NULL}}
};

LOCAL struct vxbDevRegInfo cpswDevPlbRegistration = {
    NULL,                       /* pNext */
    VXB_DEVID_DEVICE,           /* devID */
    VXB_BUSID_PLB,              /* busID = PLB */
    VXB_VER_4_0_0,              /* VxBus Version */
    CPSW_NAME,                  /* drvName */
    &cpswFuncs,                 /* pDrvBusFuncs */
    cpswMethods,                /* pMethods */
    NULL,                       /* devProbe */
    cpswParamDefaults           /* pParamDefaults */
};

/* END functions */

LOCAL END_OBJ *  cpswEndLoad           (char *, void *);
LOCAL STATUS     cpswEndUnload         (END_OBJ *);
LOCAL int        cpswEndIoctl          (END_OBJ *, int, caddr_t);
LOCAL STATUS     cpswEndMCastAddrAdd   (END_OBJ *, char *);
LOCAL STATUS     cpswEndMCastAddrDel   (END_OBJ *, char *);
LOCAL STATUS     cpswEndMCastAddrGet   (END_OBJ *, MULTI_TABLE *);
LOCAL STATUS     cpswEndStart          (END_OBJ *);
LOCAL STATUS     cpswEndStop           (END_OBJ *);
LOCAL int        cpswEndEncap          (CPSW_MAC_CTRL *, M_BLK_ID);
LOCAL int        cpswEndSend           (END_OBJ *, M_BLK_ID);
LOCAL STATUS     cpswEndPollSend       (END_OBJ *, M_BLK_ID);
LOCAL int        cpswEndPollReceive    (END_OBJ *, M_BLK_ID);
LOCAL void       cpswEndRxHandle       (CPSW_MAC_CTRL *);
LOCAL void       cpswEndTxHandle       (CPSW_MAC_CTRL *);
LOCAL void       cpswEndErrHandle      (CPSW_HOST_CTRL *);
LOCAL STATUS     cpswHostPortInit      (VXB_DEVICE_ID);
LOCAL STATUS     cpswGmacPortInit      (CPSW_MAC_CTRL *);
LOCAL void       cpswEndInt            (CPSW_HOST_CTRL *);
LOCAL STATUS     cpswSoftReset         (VXB_DEVICE_ID, UINT32, UINT32);
LOCAL void       cpswIntHandle         (void *);

/* CPDMA routines */

LOCAL STATUS     cpdmaInit             (VXB_DEVICE_ID);
LOCAL STATUS     cpdmaChanRelease      (VXB_DEVICE_ID, BOOL, int);
LOCAL STATUS     cpdmaChanRequest      (VXB_DEVICE_ID, BOOL, int);

/* ALE routines */

LOCAL int        cpswAleAddMultiCast   (VXB_DEVICE_ID, unsigned char *, int,\
                                        int, int, int) __attribute__((unused));
LOCAL int        cpswAleAddUniCast     (VXB_DEVICE_ID, unsigned char *, int, int, int, int);
LOCAL void       cpswAleRead           (VXB_DEVICE_ID, CPSW_ALE_TBL * , UINT32);
LOCAL void       cpswAleWrite          (VXB_DEVICE_ID, CPSW_ALE_TBL * , UINT32);
LOCAL int        cpswAleFind           (VXB_DEVICE_ID);
LOCAL int        cpswAleMatch          (VXB_DEVICE_ID, unsigned char *);
LOCAL int        cpswAleMatchVlan      (VXB_DEVICE_ID, int);
LOCAL int        cpswAleAddVlan        (VXB_DEVICE_ID, int, int, int, int, int);

void             cpswAleEntryShow      (CPSW_ALE_TBL *);
void             cpswAleDump           (void);

LOCAL NET_FUNCS cpswNetFuncs =
    {
    cpswEndStart,             /* start func. */
    cpswEndStop,              /* stop func. */
    cpswEndUnload,            /* unload func. */
    cpswEndIoctl,             /* ioctl func. */
    cpswEndSend,              /* send func. */
    cpswEndMCastAddrAdd,      /* multicast add func. */
    cpswEndMCastAddrDel,      /* multicast delete func. */
    cpswEndMCastAddrGet,      /* multicast get fun. */
    cpswEndPollSend,          /* cpswPolling send func. */
    cpswEndPollReceive,       /* cpswPolling receive func. */
    endEtherAddressForm,      /* put address info into a NET_BUFFER */
    endEtherPacketDataGet,    /* get pointer to data in NET_BUFFER */
    endEtherPacketAddrGet     /* Get packet addresses */
    };

/******************************************************************************
*
* vxbCpswEndRegister - register with the VxBus subsystem
*
* This routine registers the CPSW driver with VxBus as a
* PLB bus type.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

void vxbCpswEndRegister(void)
    {
    vxbDevRegister ((struct vxbDevRegInfo *)&cpswDevPlbRegistration);
    }

/*******************************************************************************
*
* cpswInstInit - VxBus instInit handler
*
* This function implements the VxBus instInit handler for an CPSW
* device instance. The only thing done here is to select a unit
* number for the device.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void cpswInstInit
    (
    VXB_DEVICE_ID pDev
    )
    {
    const struct hcfDevice * pHcf;

    /* Always use the unit number allocated to us in the hwconf file. */

    pHcf = hcfDeviceGet (pDev);
    if (pHcf == NULL)
        {
        return;
        }

    (void) vxbInstUnitSet (pDev, pHcf->devUnit);
    }

/*******************************************************************************
*
* cpswInstInit2 - VxBus instInit2 handler
*
* This function implements the VxBus instInit2 handler for a CPSW
* device instance. Once we reach this stage of initialization, it's
* safe for us to allocate memory, so we can create our pDrvCtrl
* structure and do some initial hardware setup. The important
* steps we do here are to create a child miiBus instance, get the station
* address from the BSP, and set up our vxbDma tags and memory
* regions. We need to allocate a memory region for the RX DMA window
* here.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void cpswInstInit2
    (
    VXB_DEVICE_ID pDev
    )
    {
    int i, cnt;
    STATUS ret;
    UINT32 val;
    FUNCPTR chipVersion;
    FUNCPTR chipRevision;
    CPSW_HOST_CTRL * pHost;
    CPSW_MAC_CTRL  * pMacCtrl;
    CPSW_GMAC_REGS * gmacRegs;
    UINT32         * pPhyAddrs;
    const struct hcfDevice * pHcf = hcfDeviceGet (pDev);

    if (pHcf == NULL)
        {
        return;
        }

    pHost = malloc (sizeof (CPSW_HOST_CTRL));
    if (!pHost)
        {
        CPSW_DEBUG ("cpswInstInit2: error - not enough memory!\n",0,0,0,0,0,0);
        return;
        }
    memset (pHost, 0, sizeof (CPSW_HOST_CTRL));

    pHost->pDev    = pDev;
    pDev->pDrvCtrl = pHost;

    /* get sub-module register offsets */

    pHost->regBase     = pDev->pRegBase[0];
    pHost->portOffset  = (UINT32)pDev->pRegBase[1];
    pHost->cpdmaOffset = (UINT32)pDev->pRegBase[2];
    pHost->statsOffset = (UINT32)pDev->pRegBase[3];
    pHost->aleOffset   = (UINT32)pDev->pRegBase[4];
    pHost->mdioOffset  = (UINT32)pDev->pRegBase[5];
    pHost->wrOffset    = (UINT32)pDev->pRegBase[6];

    if (devResourceGet (pHcf,
                        "hostPortNr", HCF_RES_INT, (void *)&val) != OK)
        {
        CPSW_DEBUG ("cpswInstInit2: error - can not get port \
                     number!\n",0,0,0,0,0,0);
        goto failed;
        }
    pHost->portnr = val;

    if (devResourceGet (pHcf,
                        "dualEmac", HCF_RES_INT, (void *)&val) != OK)
        {
        CPSW_DEBUG ("cpswInstInit2: error - can not get resource!\n"
                    ,0,0,0,0,0,0);
        goto failed;
        }
    if (val == 0)
        {
        CPSW_DEBUG ("cpswInstInit2: error - currently only dual emac \
             mode is supported. Please set dualEmac to 1 \
             in hwconf.c",0,0,0,0,0,0);

        goto failed;
        }
    else
        {
        pHost->nrMacPorts = 2;
        pHost->dualEmac = TRUE;
        }

    if (devResourceGet (pHcf,
                    "macPortNr", HCF_RES_INT, (void *)&val) == OK)
        {
        pHost->nrMacPorts = (int)val;
        }

    if (devResourceGet (pHcf,
                        "gmacRegs", HCF_RES_ADDR, (void *)&gmacRegs) != OK)
        {
        CPSW_DEBUG ("cpswInstInit2: error - can not get gmac resource!\n"
                    ,0,0,0,0,0,0);
        goto failed;
        }

    if (devResourceGet (pHcf,
                        "phyAddrs", HCF_RES_ADDR, (void *)&pPhyAddrs) != OK)
        {
        pPhyAddrs = NULL;
        }

    if (devResourceGet (pHcf,
                        "chipVersion", HCF_RES_ADDR, (void *)&chipVersion) != OK)
        {
        /* if chip version is missing, default to 814x */

        cpdmaHDPoffset = 0x100;
        if (!pHost->wrOffset)
            pHost->wrOffset = 0x900;
        }
    else
        {
        pHost->chipVersion = chipVersion ();

        if (pHost->chipVersion == TI814X_DEV_ID)
            {
            cpdmaHDPoffset = 0x100;
            pHost->wrOffset = 0x900;
            }
        else if (pHost->chipVersion == TIAM335X_DEV_ID)
            {
            cpdmaHDPoffset = 0x200;
            pHost->wrOffset = 0x1200;
            }
        else
            {
            CPSW_DEBUG ("cpswInstInit2: error - SoC not supported!\n"
                    ,0,0,0,0,0,0);
            goto failed;
            }
        }

    if (devResourceGet (pHcf,
                        "chipRevision", HCF_RES_ADDR, (void *)&chipRevision) != OK)
        {
            /* If no specified revision, assume 1.0 */
            pHost->chipRevision = TI_CHIP_REV_1_0;
        }
    else
        {
        pHost->chipRevision = chipRevision ();
        }

    vxbRegMap(pDev, 0, &pHost->handle);
    SPIN_LOCK_ISR_INIT (&pHost->aleLock, 0);

    pHost->cpswHostSem =
        semMCreate (SEM_Q_PRIORITY | SEM_DELETE_SAFE | SEM_INVERSION_SAFE);
    if (!pHost->cpswHostSem)
        {
        CPSW_DEBUG ("cpswInstInit2: error - \
                can not create semaphore!\n",0,0,0,0,0,0);
        goto failed;
        }

    /* initialize host(cpu) port */

    if (cpswHostPortInit (pDev) != OK)
        goto failed;

    for (i = 0; i < pHost->nrMacPorts; i++)
        {
        pMacCtrl = malloc (sizeof (CPSW_MAC_CTRL));
        if (!pMacCtrl)
            {
            CPSW_DEBUG ("cpswInstInit2: error - \
                    not enough memory!\n",0,0,0,0,0,0);
            goto failed;
            }
        memset (pMacCtrl, 0, sizeof (CPSW_MAC_CTRL));

        pHost->ports[i]  = pMacCtrl;
        pMacCtrl->pHost  = pHost;

        /* get gmac resources */

        pMacCtrl->portnr     = gmacRegs[i].portnr;
        pMacCtrl->gmacOffset = gmacRegs[i].gmacOffset;
        pMacCtrl->portOffset = gmacRegs[i].portOffset;

        /* set mii phy addrs */

        if (pPhyAddrs != NULL)
            {
            pMacCtrl->cpswMiiPhyAddr = pPhyAddrs[i];
            }
        else
            {
            pMacCtrl->cpswMiiPhyAddr = (UINT32)(-1);
            }

        pMacCtrl->cpswParentTag = vxbDmaBufTagParentGet (pDev, 0);

        /* allocating TX DMA buffer */

        pMacCtrl->cpswTxDescTag = vxbDmaBufTagCreate (
            pDev,
            pMacCtrl->cpswParentTag,
            CPSW_DESC_ALIGNMENT,
            0,
            0xFFFFFFFF,
            0xFFFFFFFF,
            NULL,
            NULL,
            sizeof (CPSW_DESC) * CPSW_DESC_CNT,
            1,
            sizeof (CPSW_DESC) * CPSW_DESC_CNT,
            VXB_DMABUF_ALLOCNOW | VXB_DMABUF_NOCACHE,
            NULL,
            NULL,
            NULL
            );
        if (!pMacCtrl->cpswTxDescTag)
            {
            CPSW_DEBUG ("cpswInstInit2: error - \
                    can not create tx tag!\n",0,0,0,0,0,0);
            goto failed;
            }

        pMacCtrl->cpswTxDescMem = vxbDmaBufMemAlloc (
            pDev,
            pMacCtrl->cpswTxDescTag,
            NULL,
            0,
            &pMacCtrl->cpswTxDescMap
            );
        if (!pMacCtrl->cpswTxDescMem)
            {
            CPSW_DEBUG ("cpswInstInit2: error  \
                    - can not create tx desc!\n",0,0,0,0,0,0);
            goto failed;
            }
        memset (pMacCtrl->cpswTxDescMem, 0,
                (sizeof (CPSW_DESC)) * CPSW_DESC_CNT);

        /* map the buffer to physical address */

        ret = vxbDmaBufMapLoad (
            pDev,
            pMacCtrl->cpswTxDescTag,
            pMacCtrl->cpswTxDescMap,
            pMacCtrl->cpswTxDescMem,
            sizeof(CPSW_DESC) * CPSW_DESC_CNT,
            0
            );
        if (ret != OK)
            {
            CPSW_DEBUG ("cpswInstInit2: error  \
                    - can not map dma buffer!\n",0,0,0,0,0,0);
            goto failed;
            }

        for (cnt = 0; cnt < CPSW_DESC_CNT; cnt++)
            {
            pMacCtrl->cpswTxDescMem[cnt].phys =
                (UINT32)((char *)(intptr_t)pMacCtrl->cpswTxDescMap->fragList[0].frag +
                (cnt * sizeof (CPSW_DESC)));
            }

        /* allocating RX DMA buffer */

        pMacCtrl->cpswRxDescTag = vxbDmaBufTagCreate (
            pDev,
            pMacCtrl->cpswParentTag,
            CPSW_DESC_ALIGNMENT,
            0,
            0xFFFFFFFF,
            0xFFFFFFFF,
            NULL,
            NULL,
            sizeof (CPSW_DESC) * CPSW_DESC_CNT,
            1,
            sizeof (CPSW_DESC) * CPSW_DESC_CNT,
            VXB_DMABUF_ALLOCNOW | VXB_DMABUF_NOCACHE,
            NULL,
            NULL,
            NULL
            );
        if (!pMacCtrl->cpswRxDescTag)
            {
            CPSW_DEBUG ("cpswInstInit2: error - \
                    can not create rx tag!\n",0,0,0,0,0,0);
            goto failed;
            }

        pMacCtrl->cpswRxDescMem = vxbDmaBufMemAlloc (
            pDev,
            pMacCtrl->cpswRxDescTag,
            NULL,
            0,
            &pMacCtrl->cpswRxDescMap
            );
        if (!pMacCtrl->cpswRxDescMem)
            {
            CPSW_DEBUG ("cpswInstInit2: error  \
                    - can not create rx desc!\n",0,0,0,0,0,0);
            goto failed;
            }
        memset (pMacCtrl->cpswRxDescMem, 0,
               (sizeof (CPSW_DESC)) * CPSW_DESC_CNT);

        ret = vxbDmaBufMapLoad (
            pDev,
            pMacCtrl->cpswRxDescTag,
            pMacCtrl->cpswRxDescMap,
            pMacCtrl->cpswRxDescMem,
            sizeof(CPSW_DESC) * CPSW_DESC_CNT,
            0
            );
        if (ret != OK)
            {
            CPSW_DEBUG ("cpswInstInit2: error  \
                    - can not map dma buffer!\n",0,0,0,0,0,0);
            goto failed;
            }

        for (cnt = 0; cnt < CPSW_DESC_CNT; cnt++)
            {
            pMacCtrl->cpswRxDescMem[cnt].phys =
                (UINT32)((char *)(intptr_t)pMacCtrl->cpswRxDescMap->fragList[0].frag +
                (cnt * sizeof (CPSW_DESC)));
            }

        /* create mblk dma tags */

        pMacCtrl->cpswMblkTag = vxbDmaBufTagCreate (pDev,
            pMacCtrl->cpswParentTag,
            1,
            0,
            0xFFFFFFFF,
            0xFFFFFFFF,
            NULL,
            NULL,
            END_JUMBO_CLSIZE,
            16,
            END_JUMBO_CLSIZE,
            VXB_DMABUF_ALLOCNOW,
            NULL,
            NULL,
            NULL
            );
        if (!pMacCtrl->cpswMblkTag)
            {
            CPSW_DEBUG ("cpswInstInit2: error  \
                    - can not create mblk tags!\n",0,0,0,0,0,0);
            goto failed;
            }

        for (cnt = 0; cnt < CPSW_DESC_CNT; cnt++)
            {
            if (!vxbDmaBufMapCreate (pDev,
                pMacCtrl->cpswMblkTag, 0, &pMacCtrl->cpswTxMblkMap[cnt]))
                goto failed;
            }

        for (cnt = 0; cnt < CPSW_DESC_CNT; cnt++)
            {
            if (!vxbDmaBufMapCreate (pDev,
                pMacCtrl->cpswMblkTag, 0, &pMacCtrl->cpswRxMblkMap[cnt]))
                goto failed;
            }

        pMacCtrl->cpswTxQHead = CPSW_TXQ_INVALID;
        pMacCtrl->cpswTxFree = CPSW_DESC_CNT;
        pMacCtrl->cpswTxstall = FALSE;

        pMacCtrl->cpswMacSem = semMCreate (SEM_Q_PRIORITY | SEM_DELETE_SAFE | SEM_INVERSION_SAFE);
        if (!pMacCtrl->cpswMacSem)
            {
            CPSW_DEBUG ("cpswInstInit2: error - \
                    can not create Mac semaphore!\n",0,0,0,0,0,0);
            goto failed;
            }

        /* create the MII bus */

        pMacCtrl->cpswMiiParent = vxbDevStructAlloc (WAIT_FOREVER);
        if (!pMacCtrl->cpswMiiParent)
            {
            CPSW_DEBUG ("cpswInstInit2: error  \
                    - can not create miiParent!\n",0,0,0,0,0,0);
            goto failed;
            }
        memcpy (pMacCtrl->cpswMiiParent, pDev, sizeof (VXB_DEVICE));

        pMacCtrl->cpswMiiParent->pDrvCtrl   = pMacCtrl;
        pMacCtrl->cpswMiiParent->unitNumber = i;
        pMacCtrl->index = i;
        pMacCtrl->portVlan = (i == 0 ? \
                CPSW_DEFAULT_PORT1_VLAN : CPSW_DEFAULT_PORT2_VLAN);

        if (miiBusCreate (pMacCtrl->cpswMiiParent, &pMacCtrl->cpswMiiBus) != OK)
            {
            CPSW_DEBUG ("cpswInstInit2: error  \
                    - can not create mii bus!\n",0,0,0,0,0,0);
            goto failed;
            }

        miiBusMediaListGet (pMacCtrl->cpswMiiBus, &pMacCtrl->cpswMediaList);
        miiBusModeSet (pMacCtrl->cpswMiiBus,
            pMacCtrl->cpswMediaList->endMediaListDefault);

        /* initialize mac port(s) */

        if (cpswGmacPortInit (pMacCtrl) != OK)
            goto failed;
        }

     vxAtomicSet (&pHost->cpswIntPending, FALSE);

    /* initialize CPDMA */

    if (cpdmaInit (pDev) != OK)
        goto failed;

    return;

failed:
    for (i = 0; i < pHost->nrMacPorts; i++)
        {
        pMacCtrl = pHost->ports[i];

        if (pMacCtrl)
            {
            for (cnt = 0; cnt < CPSW_DESC_CNT; cnt++)
                {
                vxbDmaBufMapDestroy (pMacCtrl->cpswMblkTag,
                    pMacCtrl->cpswRxMblkMap[cnt]);
                vxbDmaBufMapDestroy (pMacCtrl->cpswMblkTag,
                    pMacCtrl->cpswTxMblkMap[cnt]);
                }

            vxbDmaBufTagDestroy (pMacCtrl->cpswMblkTag);

            vxbDmaBufMemFree (pMacCtrl->cpswRxDescTag, 0,
                pMacCtrl->cpswTxDescMap);

            vxbDmaBufMemFree (pMacCtrl->cpswTxDescTag, 0,
                pMacCtrl->cpswRxDescMap);

            vxbDmaBufTagDestroy (pMacCtrl->cpswTxDescTag);
            vxbDmaBufTagDestroy (pMacCtrl->cpswRxDescTag);

            if (pMacCtrl->cpswMiiParent)
                vxbDevStructFree (pMacCtrl->cpswMiiParent);

            if (pMacCtrl->cpswMacSem)
                {
                (void) semDelete (pMacCtrl->cpswMacSem);
                }

            free (pMacCtrl);
            }
        }

    if (pHost->cpswHostSem)
        (void) semDelete (pHost->cpswHostSem);

    free (pHost);
    pDev->pDrvCtrl = NULL;
    }

/*******************************************************************************
*
* cpswInstConnect -  VxBus instConnect handler
*
* This function implements the VxBus instConnect handler for an CPSW
* device instance. This routine connects the CPSW ISR routines here.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void cpswInstConnect
    (
    VXB_DEVICE_ID pDev
    )
    {
    /* Attach our ISR */

    CPSW_HOST_CTRL * pHost = pDev->pDrvCtrl;

    if (vxbIntConnect (pDev, 0, cpswEndInt, pHost) != OK)
        {
        CPSW_DEBUG ("cpswInstConnect error : \
                can not connect ISR!\n",0,0,0,0,0,0);
        return ;
        }
    if (vxbIntConnect (pDev, 1, cpswEndInt, pHost) != OK)
        {

        CPSW_DEBUG ("cpswInstConnect error : \
                can not connect ISR!\n",0,0,0,0,0,0);
        return ;
        }

    if (vxbIntConnect (pDev, 3, cpswEndInt, pHost) != OK)
        {

        CPSW_DEBUG ("cpswInstConnect error : \
                can not connect ISR!\n",0,0,0,0,0,0);
        return ;
        }

    if (vxbIntEnable  (pDev, 0, cpswEndInt, pHost) != OK)
        {

        CPSW_DEBUG ("cpswInstConnect error : \
                can not enable ISR!\n",0,0,0,0,0,0);
        return ;
        }
    if (vxbIntEnable  (pDev, 1, cpswEndInt, pHost) != OK)
        {

        CPSW_DEBUG ("cpswInstConnect error : \
                can not enable ISR!\n",0,0,0,0,0,0);
        return ;
        }
    if (vxbIntEnable  (pDev, 3, cpswEndInt, pHost) != OK)
        {

        CPSW_DEBUG ("cpswInstConnect error : \
                can not enable ISR!\n",0,0,0,0,0,0);
        return ;
        }
    }

/*******************************************************************************
*
* cpswHostPortInit - initialize CPSW host port
*
* This routine initializes the CPSW host port. It performs a soft reset, clears &
* enables the ALE module (NOTE: ALE must be enabled otherwise all packets will be
* dropped), and puts port in forward state. MDIO module is enabled in this routine
* (NOTE: if soft reset fails, the routine won't proceed. An error message will be
* print out if debug mode is enabled)
*
* RETURNS: OK or ERROR if reset timeout
*
* ERRNO: N/A
*/

LOCAL STATUS cpswHostPortInit
    (
    VXB_DEVICE_ID pDev
    )
    {
    CPSW_HOST_CTRL * pHost = pDev->pDrvCtrl;
    UINT32 base, val;

    if (cpswSoftReset (pDev, CPSW_SOFT_RESET, CPSW_TIMEOUT_VAL) != OK)
        {
        CPSW_DEBUG ("cpswHostPortInit : error - \
                host port soft reset timeout!\n",0,0,0,0,0,0);
        return ERROR;
        }

    base = pHost->aleOffset;

    val = CPSW_ALE_EN_TABLE | CPSW_ALE_CLR_TABLE;
    if (pHost->dualEmac == TRUE)
        val |= CPSW_ALE_VLAN_AWARE;

    CSR_WRITE_4 (pDev, base + CPSW_ALE_CONTROL, val);
    CSR_WRITE_4 (pDev, base + CPSW_ALE_PORTCTL(pHost->portnr),
                    CPSW_ALE_PORT_FW | CPSW_ALE_CTL_NO_LEARN);

    /* enable statistics for all ports */

    CSR_WRITE_4 (pDev, CPSW_STAT_PORT_EN, 7);

    base = pHost->portOffset;
    CSR_WRITE_4 (pDev, base + CPSW_TX_PRI_MAP, CPSW_TX_PRI_MAP_DFTL);
    CSR_WRITE_4 (pDev, base + CPSW_CPDMA_TX_PRI_MAP, CPDMA_TX_PRI_MAP_DFTL);

    if (pHost->dualEmac == TRUE)
        {
        /* set tx fifo into dual emac mode */

        val = CSR_READ_4 (pDev, base + CPSW_TX_IN_CTL);
        val = val & ~(CPSW_TX_IN_SEL_MSK << CPSW_TX_IN_SEL_SHIFT);
        CSR_WRITE_4 (pDev, base + CPSW_TX_IN_CTL,
                val | (CPSW_TX_FIFO_DUAL_EMAC << CPSW_TX_IN_SEL_SHIFT));
        }

    base = pHost->mdioOffset;
    CSR_WRITE_4 (pDev, base + CPSW_MDIO_CONTROL,
                    CPSW_MDIO_EN | CPSW_MDIO_CLK_DIV);

    return OK;
    }

/*******************************************************************************
*
* cpswMacPortInit - initialize CPSW GMAC port
*
* This routine initializes the CPSW GMAC port. It performs a soft reset, sets up
* neccessary reigsters, and finally get MAC address from BSP. (NOTE: if soft
* reset fails, the routine won't proceed. An error message will be print out if
* debug mode is enabled)
*
* RETURNS: OK or ERROR if reset timeout
*
* ERRNO: N/A
*/

LOCAL STATUS cpswGmacPortInit
    (
    CPSW_MAC_CTRL * pMacCtrl
    )
    {
    UINT32  lo, hi;
    VXB_DEVICE_ID pDev = pMacCtrl->pHost->pDev;
    CPSW_HOST_CTRL * pHost = pMacCtrl->pHost;
    UINT32 base;

    /*
     * put MAC port into forward state and
     * disable learning on this port, because
     * we are operating in dual emac mode,
     * not switch mode. We add our MAC
     * address manually.
     */

    base = pHost->aleOffset;
    CSR_WRITE_4 (pDev, base + CPSW_ALE_PORTCTL(pMacCtrl->portnr),
                    CPSW_ALE_PORT_FW | CPSW_ALE_CTL_NO_LEARN);

    base = pMacCtrl->portOffset;
    CSR_WRITE_4 (pDev, base + CPSW_TX_PRI_MAP, CPSW_TX_PRI_MAP_DFTL);

    /*
     * get our MAC address from BSP. In dual emac mode
     * every gmac port has its own MAC address
     */

    sysNetMacNVRamAddrGet (pDev->pName,
                    pMacCtrl->index, pMacCtrl->macaddr, ETHER_ADDR_LEN);

    lo = (pMacCtrl->macaddr[0] << 8)  | pMacCtrl->macaddr[1];
    hi = (pMacCtrl->macaddr[2] << 24) | (pMacCtrl->macaddr[3] << 16) |
         (pMacCtrl->macaddr[4] << 8)  | pMacCtrl->macaddr[5];

    CSR_WRITE_4 (pDev, pMacCtrl->portOffset + CPSW_SL_SA_L0, lo);
    CSR_WRITE_4 (pDev, pMacCtrl->portOffset + CPSW_SL_SA_HI, hi);

    /* reset the gmac module */

    base = pMacCtrl->gmacOffset;
    if (cpswSoftReset (pDev, base + CPSW_SL_MAC_SOFT_RESET, CPSW_TIMEOUT_VAL) != OK)
        {
        CPSW_DEBUG("cpswGmacPortInit : error - \
                gmac port soft reset timeout!\n",0,0,0,0,0,0);
        return ERROR;
        }

    CSR_WRITE_4 (pDev, base + CPSW_SL_RX_PRI_MAP, CPDMA_TX_PRI_MAP_DFTL);
    CSR_WRITE_4 (pDev, base + CPSW_SL_RX_MAXLEN , CPSW_MTU);
    CSR_WRITE_4 (pDev, base + CPSW_SL_MAC_CTL   , CPSW_GMII_EN);

    if (pHost->dualEmac == TRUE)
        {
        CSR_WRITE_4 (pDev, pMacCtrl->portOffset + CPSW_PORT_VLAN,
                pMacCtrl->portVlan);

        cpswAleAddVlan (pDev, (0x1 << pHost->portnr) | (0x1 << pMacCtrl->portnr),
                0, 0, 0, pMacCtrl->portVlan);
        cpswAleAddUniCast (pDev, pMacCtrl->macaddr, pMacCtrl->portVlan,
                0, 0, pHost->portnr);
        }

    return OK;
    }

/*******************************************************************************
*
* cpdmaChanRequest - request a DMA channel
*
* This routine allocates a DMA resource for a given request. The requested
* channel number is specified through the parameter "idx". If "rx" is TRUE, then
* it is asssumed the allocation is for rx channel otherwise it is assumed for
* tx channle. DMA is shared resource, so this routine must be called with
* semaphore taken.
*
* RETURNS: OK or ERROR if allocation fails.
*
* ERRNO: N/A
*/

LOCAL STATUS cpdmaChanRequest
    (
    VXB_DEVICE_ID pDev,
    BOOL rx,
    int idx
    )
    {
    CPSW_HOST_CTRL * pHost = pDev->pDrvCtrl;
    unsigned char * chan = rx == TRUE ? pHost->cpswRxDmaChans \
               : pHost->cpswTxDmaChans;

    if (0 <= idx && idx < NR_DMA_CHANS)
        {
        if (!chan[idx])
            {
            chan[idx] = 1;
            return OK;
            }
        }

    return ERROR;
    }

/*******************************************************************************
*
* cpdmaChanRelease - release a DMA channel
*
* This routine releases a DMA resource for a given request. The requested
* channel number is specified through the parameter "idx". If "rx" is TRUE, then
* it is asssumed the release operation is for rx channel otherwise it is assumed
* for tx channle. If a already-free channel is given for release, this routine
* also returns OK. DMA is shared resource, so this routine must be called with
* semaphore taken.
*
* RETURNS: OK or ERROR if release operation fails.
*
* ERRNO: N/A
*/

LOCAL STATUS cpdmaChanRelease
    (
    VXB_DEVICE_ID pDev,
    BOOL rx,
    int idx
    )
    {
    CPSW_HOST_CTRL * pHost = pDev->pDrvCtrl;
    unsigned char * chan = rx == TRUE ? pHost->cpswRxDmaChans \
               : pHost->cpswTxDmaChans;

    if (0 <= idx && idx < NR_DMA_CHANS)
        {
        if (!chan[idx])
            {
            return OK;
            }
        else
            {
            chan[idx] = 0;
            return OK;
            }
        }
    return ERROR;
    }

/*******************************************************************************
*
* cpdmaInit - initialize CPDMA module
*
* This routine initializes the CPDMA module inside the NIC. This routine will
* perform a soft reset, clear all the rx/tx header decriptor pointer/completion
* header pointer, disable interrupts and set the CPDMA control register to
* default value:
*
*     frames containing overrun error are filtered
*     DMA writes offset/len field in the descritpor
*     DMA clears the owership bit
*     All 8 DMA queue uses the round-robin scheduling algorithm
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL STATUS cpdmaInit
    (
    VXB_DEVICE_ID pDev
    )
    {
    int i;
    CPSW_HOST_CTRL * pHost = pDev->pDrvCtrl;

    /* reset the cpdma module */

    if (cpswSoftReset (pDev, pHost->cpdmaOffset + CPDMA_SOFT_RESET,
                            CPSW_TIMEOUT_VAL) != OK)
        {
        CPSW_DEBUG("cpswDmaInit: error - \
                dma port soft reset timeout!\n",0,0,0,0,0,0);
        return ERROR;
        }

    /* initialize dma queue header pointers */

    for (i = 0; i < NR_DMA_CHANS; i++)
        {
        CPDMA_REG_WRITE (pDev, CPDMA_TX_HDP(i)    , 0);
        CPDMA_REG_WRITE (pDev, CPDMA_RX_HDP(i)    , 0);
        CPDMA_REG_WRITE (pDev, CPDMA_TX_CP(i)     , 0);
        CPDMA_REG_WRITE (pDev, CPDMA_RX_CP(i)     , 0);
        CPDMA_REG_WRITE (pDev, CPDMA_RX_FREEBUF(i), 0);
        }

    CPDMA_REG_WRITE (pDev, CPDMA_DMACONTROL    , CPDMA_CONTROL_DEFAULT);

    /* diable interrupts */

    CPDMA_REG_WRITE (pDev, CPDMA_RX_BUFOFFSET  , 0x0);
    CPDMA_REG_WRITE (pDev, CPDMA_TX_INTMASK_CLR, 0xffff);
    CPDMA_REG_WRITE (pDev, CPDMA_RX_INTMASK_CLR, 0xffff);
    CPDMA_REG_WRITE (pDev, CPDMA_INTMASK_CLR   , 0x3);

    return OK;
    }

/*******************************************************************************
*
* cpswSoftReset - perform soft reset on a given module
*
* This routine performs soft reset on a given module.
*
* RETURNS: OK or ERROR if timeout
*
* ERRNO: N/A
*/

LOCAL STATUS cpswSoftReset
    (
    VXB_DEVICE_ID pDev,
    UINT32 reg,
    UINT32 timeout
    )
    {
    UINT32 i = 0;
    UINT32 ret;

    CSR_WRITE_4 (pDev, reg, 0x1);
    do
        {
        ret = CSR_READ_4 (pDev, reg);
        } while ((ret & 0x1) && (i++ < timeout));

    if (i >= timeout)
        return ERROR;

    return OK;
    }

/*******************************************************************************
*
* cpswInstUnlink - unlink the device instance from VxBus subsystem
*
* This routine unlinks the device instance from VxBus subsystem
*
* RETURNS: OK or ERROR if operation failed.
*
* ERRNO: N/A
*/

LOCAL STATUS cpswInstUnlink
    (
    VXB_DEVICE_ID pDev,
    void * unused
    )
    {
    int i, cnt;
    CPSW_MAC_CTRL  * pMacCtrl;
    CPSW_HOST_CTRL * pHost = pDev->pDrvCtrl;

    CPDMA_TX_DIS (pDev);
    CPDMA_RX_DIS (pDev);

    (void)cpswSoftReset (pDev, CPSW_SOFT_RESET, CPSW_TIMEOUT_VAL);

    for (i = 0; i < pHost->nrMacPorts; i++)
        {
        (void)cpswSoftReset (pDev, pHost->ports[i]->gmacOffset + \
                       CPSW_SL_MAC_SOFT_RESET, CPSW_TIMEOUT_VAL);
        }

    (void) vxbIntDisable (pDev, 0, cpswEndInt, pHost);
    (void) vxbIntDisable (pDev, 1, cpswEndInt, pHost);
    (void) vxbIntDisable (pDev, 3, cpswEndInt, pHost);

    (void) vxbIntDisconnect (pDev, 0, cpswEndInt, pHost);
    (void) vxbIntDisconnect (pDev, 1, cpswEndInt, pHost);
    (void) vxbIntDisconnect (pDev, 3, cpswEndInt, pHost);

    for (i = 0; i < pHost->nrMacPorts; i++)
        {
        pMacCtrl = pHost->ports[i];

        if (pMacCtrl->cookie != NULL)
            {
            if (muxDevStop (pMacCtrl->cookie) != OK)
                return ERROR;

            if (muxDevUnload (CPSW_NAME, pMacCtrl->portnr - 1) != OK)
                return ERROR;
            }

       for (cnt = 0; cnt < CPSW_DESC_CNT; cnt++)
            {
            vxbDmaBufMapDestroy (pMacCtrl->cpswMblkTag,
                pMacCtrl->cpswRxMblkMap[cnt]);
            vxbDmaBufMapDestroy (pMacCtrl->cpswMblkTag,
                pMacCtrl->cpswTxMblkMap[cnt]);
            }

        vxbDmaBufTagDestroy (pMacCtrl->cpswMblkTag);

        vxbDmaBufMemFree (pMacCtrl->cpswTxDescTag, 0,
            pMacCtrl->cpswTxDescMap);

        vxbDmaBufMemFree (pMacCtrl->cpswRxDescTag, 0,
            pMacCtrl->cpswRxDescMap);

        vxbDmaBufTagDestroy (pMacCtrl->cpswTxDescTag);
        vxbDmaBufTagDestroy (pMacCtrl->cpswRxDescTag);

        (void) miiBusDelete (pMacCtrl->cpswMiiBus);
        (void) vxbDevStructFree (pMacCtrl->cpswMiiParent);
        (void) semDelete (pMacCtrl->cpswMacSem);

        free (pMacCtrl);
        }

    (void) semDelete (pHost->cpswHostSem);
    free (pHost);
    pDev->pDrvCtrl = NULL;

    return OK;
    }

/*******************************************************************************
*
* cpswAleRead - read an ALE entry
*
* This routine reads an ALE entry from the given index
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void cpswAleRead
    (
    VXB_DEVICE_ID pDev,
    CPSW_ALE_TBL * tbl,
    UINT32 entry
    )
    {
    CPSW_HOST_CTRL * pHost = pDev->pDrvCtrl;

    SPIN_LOCK_ISR_TAKE (&pHost->aleLock);

    CSR_WRITE_4 (pDev, pHost->aleOffset + CPSW_ALE_TBLCTL,
                 entry & CPSW_ALE_ENTRY_IDX_MASK);

    tbl->word0 = CSR_READ_4 (pDev, pHost->aleOffset + CPSW_ALE_WORD0);
    tbl->word1 = CSR_READ_4 (pDev, pHost->aleOffset + CPSW_ALE_WORD1);
    tbl->word2 = CSR_READ_4 (pDev, pHost->aleOffset + CPSW_ALE_WORD2) & 0xf;

    SPIN_LOCK_ISR_GIVE (&pHost->aleLock);
    }

/*******************************************************************************
*
* cpswAleWrite - write an ALE entry
*
* This routine writes data to an ALE entry with the given index
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void cpswAleWrite
    (
    VXB_DEVICE_ID pDev,
    CPSW_ALE_TBL * tbl,
    UINT32 entry
    )
    {
    CPSW_HOST_CTRL * pHost = pDev->pDrvCtrl;

    SPIN_LOCK_ISR_TAKE (&pHost->aleLock);

    CSR_WRITE_4 (pDev, pHost->aleOffset + CPSW_ALE_WORD0, tbl->word0);
    CSR_WRITE_4 (pDev, pHost->aleOffset + CPSW_ALE_WORD1, tbl->word1);
    CSR_WRITE_4 (pDev, pHost->aleOffset + CPSW_ALE_WORD2, tbl->word2 & 0xf);

    CSR_WRITE_4 (pDev, pHost->aleOffset + CPSW_ALE_TBLCTL,
                 (entry & CPSW_ALE_ENTRY_IDX_MASK) | CPSW_ALE_WRITE);

    SPIN_LOCK_ISR_GIVE (&pHost->aleLock);
    }

/*******************************************************************************
*
* cpswAleFind - find an emtpy ALE entry
*
* This routine finds an emtpy ALE entry.
*
* RETURNS: empty entry index or -1 if ALE is full
*
* ERRNO: N/A
*/

LOCAL int cpswAleFind
    (
    VXB_DEVICE_ID pDev
    )
    {
    int i;
    CPSW_ALE_TBL tbl;

    for (i = 0; i < CPSW_ALE_ENTRY_NR; i++)
        {
        cpswAleRead (pDev, &tbl, i);
        if ((tbl.word1 & CPSW_ALE_ENTRY_MASK) == 0x0)
            return i;
        }

    return -1;
    }

/*******************************************************************************
*
* cpswAleMatch - find the entry with the given MAC address
*
* This routine finds the entry with the given MAC address
*
* RETURNS: entry found or -1 if the MAC address has not entered into ALE yet.
*
* ERRNO: N/A
*/

LOCAL int cpswAleMatch
    (
    VXB_DEVICE_ID pDev,
    unsigned char * mac
    )
    {
    int i;
    CPSW_ALE_TBL t;
    unsigned int word0, word1;

    word0 = (mac[2] << 24) | (mac[3] << 16) | (mac[4] << 8) | (mac[5]);
    word1 = (mac[0] << 8) | (mac[1]);

    for (i = 0; i < CPSW_ALE_ENTRY_NR; i++)
        {
        cpswAleRead (pDev, &t, i);
        if ((t.word0 == word0) && ((t.word1 & 0xffff) == word1))
            return i;
        }
    return -1;
    }

/*******************************************************************************
*
* cpswAleEntryShow - show an ALE entry
*
* This routine outputs verbose message of an ALE entry
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

void cpswAleEntryShow
    (
    CPSW_ALE_TBL * tbl
    )
    {
    unsigned char * macaddr;
    unsigned char * macaddr1;
    int block = 0, secure = 0, port = 0, portmask = 0;
    int fwstate = 0, super = 0;
    int unicasttype = 0;
    int vmem = 0, umf = 0, rmf = 0, fue = 0;
    char * str = NULL;

    static char * unicast [] =
        {
        "u/na",
        "u/a/nt",
        "oui",
        "u/a/t"
        };

    macaddr = (unsigned char *)&tbl->word0;
    macaddr1 = (unsigned char *)&tbl->word1;
    int vid = (tbl->word1 >> 16) & 0xfff;
    int type = (tbl->word1 >> 28) & 0x3;
    int multicast = tbl->word1 & 0x100;

    if (type == 0x0)
        return;

    if (type == 1)
        {
        if (multicast)
            str = "multicast";
        else
            str = "unicast";
        }
    else if (type == 0x3)
        {
        if (multicast)
            str = "multi/vlan";
        else
            str = "uni/vlan";
        }

    if (type == 0x2)
        {
        str = "vlan";
        fue = (tbl->word0 >> 24) & 0x7;
        rmf = (tbl->word0 >> 16) & 0x7;
        umf = (tbl->word0 >> 8) & 0x7;
        vmem = tbl->word0  & 0x7;
        }
    else
        {
        if (!multicast)
            {
            unicasttype = (tbl->word1 >> 30) & 0x3;
            secure = (tbl->word2 & 0x1);
            block = (tbl->word2 & 0x2) >> 1;
            port = (tbl->word2 >> 0x2) & 0x3;
            }
        else
            {
            fwstate = (tbl->word1 >> 30) & 0x3;
            super = (tbl->word2 >> 1) & 0x1;
            portmask = (tbl->word2 >> 2) & 0x7;
            }
        }

    if (type == 0x3 || type == 0x1)
        {

        /* multicast entry */

        if (multicast)
            {
            printf ("%-20s%-20s%-20s%-20s%-20s%-20s\n", "mac",
                    "ent type", "state", "super", "portmask", "vid");

            printf ("---------------------------------------------"
                    "---------------------------------------------"
                    "-----------------------------------\n");

            printf ("%02x:%02x:%02x:%02x:%02x:%02x   %-20s%"
                    "-20d%-20d%-20d%-20d\n\n", macaddr1[1],
                    macaddr1[0], macaddr[3], macaddr[2], macaddr[1], macaddr[0],
                    str, fwstate, super, portmask, vid);
            }

        /* unicast entry */

        else
            {
            printf ("%-20s%-20s%-20s%-20s%-20s%-20s%-20s\n",
                    "mac", "ent type", "type", "secure",
                    "block", "port", "vid");

            printf ("---------------------------------------------"
                    "---------------------------------------------"
                    "-----------------------------------\n");

            printf ("%02x:%02x:%02x:%02x:%02x:%02x   %-20s%"
                    "-20s%-20d%-20d%-20d%-20d\n\n", macaddr1[1],
                    macaddr1[0], macaddr[3], macaddr[2], macaddr[1], macaddr[0],
                    str, unicast[unicasttype], secure, block, port, vid);
            }

        /* vlan entry */
        }
    else if (type == 0x2)
        {
        printf ("%-20s%-20s%-20s%-20s%-20s%-20s%-20s\n", "mac",
                "ent type", "fue", "rmf", "umf", "vmem", "vid");
        printf ("---------------------------------------------"
                "---------------------------------------------"
                "-----------------------------------\n");

        printf ("%-20s%-20s%-20d%-20d%-20d%-20d%-20d\n\n", "N/A",
            str, fue, rmf, umf, vmem, vid);
        }
    }

/*******************************************************************************
*
* cpswAleDump - show all the ALE entries
*
* This routine outputs verbose message of all the ALE entries
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

void cpswAleDump (void)
    {
    int i;
    VXB_DEVICE_ID pInst;
    CPSW_ALE_TBL tbl;

    pInst = vxbInstByNameFind ("cpsw", 0);
    if (pInst)
        {
        for (i = 0; i < CPSW_ALE_ENTRY_NR; i++)
            {
            cpswAleRead (pInst, &tbl, i);
            cpswAleEntryShow (&tbl);
            }
        }
    }

/*******************************************************************************
*
* cpswAleAddMultiCast - add a multicast MAC address into ALE table
*
* This routine adds a multicast MAC address into ALE table. First, this routine
* will try to find a match. If the MAC address is already in the table, it
* overwrites the entry content with new values. If it can not find a match, a empty
* entry will be allocated and the MAC address will be added.
*
* RETURNS: 0 on success, ENOMEM if can not find a emtpy entry
*
* ERRNO: N/A
*/

LOCAL int cpswAleAddMultiCast
    (
    VXB_DEVICE_ID   pDev,
    unsigned char * mac,
    int             vid,
    int             fwstate,
    int             super,
    int             portmask
    )
    {
    unsigned int word0, word1;
    CPSW_ALE_TBL tbl;
    int entry;

    word0 = (mac[2] << 24) | (mac[3] << 16) | (mac[4] << 8) | (mac[5]);
    word1 = (mac[0] << 8) | (mac[1]);

    entry = cpswAleMatch (pDev, mac);
    if (entry < 0)
        {
        entry = cpswAleFind (pDev);
        if (entry < 0)
            return ENOMEM;
        }

    tbl.word0 = word0;

    /* multicast with vlan */

    if (vid > 0)
        tbl.word1 = word1 | ((vid & 0xfff) << 16) |
                    ((fwstate & 0x3) << 30) | (0x3 << 28);
    else
        tbl.word1 = word1 | ((fwstate & 0x3) << 30) | (0x1 << 28);

    tbl.word2 = ((super & 0x1) << 1) | ((portmask & 0x7) << 2);

    cpswAleWrite (pDev, &tbl, entry);

    return 0;
    }

/*******************************************************************************
*
* cpswAleAddUniCast - add a unicast MAC address into ALE table
*
* This routine adds a unicast MAC address into ALE table. First, this routine
* will try to find a match. If the MAC address is already in the table, it overwrites
* that entry content with new values. If it can not find a match,
* a empty entry will be allocated and the MAC address will be added.
*
* RETURNS: 0 on success or ENOMEM if can not find a emtpy entry
*
* ERRNO: N/A
*/

LOCAL int cpswAleAddUniCast
    (
    VXB_DEVICE_ID   pDev,
    unsigned char * mac,
    int             vid,
    int             secure,
    int             block,
    int             port
    )
    {
    unsigned int word0, word1;
    CPSW_ALE_TBL tbl;
    int entry;

    word0 = (mac[2] << 24) | (mac[3] << 16) | (mac[4] << 8) | (mac[5]);
    word1 = (mac[0] << 8) | (mac[1]);

    tbl.word0 = word0;
    tbl.word1 = word1;
    tbl.word2 = 0x0;

    entry = cpswAleMatch (pDev, mac);
    if (entry < 0)
        {
        entry = cpswAleFind (pDev);
        if (entry < 0)
            return ENOMEM;
        }

    tbl.word0 = word0;

    /* unicast with vlan*/

    if (vid > 0)
        tbl.word1 = word1 | (0x3 << 28) |
                    CPSW_ALE_UNICAST_AGEABLE_NOT |
                    ((vid & 0xfff) << 16);
    else
        tbl.word1 = word1 | (0x1 << 28) |
                    CPSW_ALE_UNICAST_AGEABLE_NOT;

    tbl.word2 = ((block & 0x1) << 1) | (secure & 0x1) |
                ((port & 0x3) << 2);

    cpswAleWrite (pDev, &tbl, entry);

    return 0;
    }

/*******************************************************************************
*
* cpswAleMatchVlan - find the ALE entry with the given vid
*
* This routine finds the ALE entry index with the given vid
*
* RETURNS: ALE entry index on success or -1 if entry not found
*
* ERRNO: N/A
*/

LOCAL int cpswAleMatchVlan
    (
    VXB_DEVICE_ID pDev,
    int vid
    )
    {
    int i;
    CPSW_ALE_TBL t;

    for (i = 0; i < CPSW_ALE_ENTRY_NR; i++)
        {
        cpswAleRead (pDev, &t, i);
        if (((t.word1 >> 28) & 0x3) == 0x2)
            {
            if (((t.word1 >> 16 ) & 0xfff)  == vid)
                return i;
            }
        }
    return -1;
    }

/*******************************************************************************
*
* cpswAleAddVlan - add a vlan entry into ALE table
*
* This routine adds a vlan entry into ALE table
*
* RETURNS: 0 on success,  ENOMEM if can not find a emtpy entry or
*          EEXIST if the given vlan is alreay in ALE table
*
* ERRNO: N/A
*/

LOCAL int cpswAleAddVlan
    (
    VXB_DEVICE_ID pDev,
    int vlanMemberList,
    int unregFloodMask,
    int regFloodMask,
    int forceUntaggedEgress,
    int vid
    )
    {
    CPSW_ALE_TBL t;
    int entry;

    if (vid <= 0 || vid >= 4095)
        return EINVAL;

    entry = cpswAleMatchVlan (pDev, vid);
    if (entry < 0)
        {
        entry = cpswAleFind (pDev);
        if (entry < 0)
            return ENOMEM;
        }

    t.word0 = ((vlanMemberList & 0x7))      |
              ((unregFloodMask & 0x7) << 8) |
              ((regFloodMask & 0x7) << 16)  |
              ((forceUntaggedEgress & 0x7) << 24);
    t.word1 = ((vid & 0xfff) << 16) | (0x2 << 28);
    t.word2 = 0;
    cpswAleWrite (pDev, &t, entry);

    return 0;
    }

/*******************************************************************************
*
* cpswPhyRead - miiBus miiRead method
*
* This function implements an miiRead() method that allows PHYs
* on the miiBus to access our MII management registers.
*
* RETURNS: ERROR if invalid PHY addr, else OK
*
* ERRNO: N/A
*/

LOCAL STATUS cpswPhyRead
    (
    VXB_DEVICE_ID pMiiParent,
    UINT8 phyAddr,
    UINT8 regAddr,
    UINT16 *dataVal
    )
    {
    UINT32 ret;
    CPSW_MAC_CTRL * pMacCtrl = pMiiParent->pDrvCtrl;
    CPSW_HOST_CTRL * pHost = pMacCtrl->pHost;
    VXB_DEVICE_ID pDev = pHost->pDev;
    int index = pMiiParent->unitNumber;

    /*
     * The first condition (pMacCtrl->cpswMiiPhyAddr != (UINT32)(-1)) is used
     * to check whether BSP specifies PHY address, if not, it probes one.
     * Otherwise, The second codition (cpswMiiPhyAddr != phyAddr) is used to
     * make the phyRead routine use the PHY address specified by BSP.
     */

    if ((pMacCtrl->cpswMiiPhyAddr != (UINT32)(-1)) &&
        (pMacCtrl->cpswMiiPhyAddr != phyAddr))
        return ERROR;

    if (phyAddr >= 32)
        {
        return ERROR;
        }

    do
        {
        ret = CSR_READ_4 (pDev, pHost->mdioOffset + CPSW_USERACCESSn(index));
        } while (ret & CPSW_MDIO_GO);

    ret = phyAddr << CPSW_PHY_ADDR_SHIFT |
          regAddr << CPSW_REG_ADDR_SHIFT |
          CPSW_MDIO_GO;

    CSR_WRITE_4 (pDev, pHost->mdioOffset + CPSW_USERACCESSn(index), ret);

    do
        {
        ret = CSR_READ_4 (pDev, pHost->mdioOffset + CPSW_USERACCESSn(index));
        } while (ret & CPSW_MDIO_GO);

    *dataVal = ret & 0xffff;

    return OK;
    }

/*******************************************************************************
*
* cpswPhyWrite - miiBus miiWrite method
*
* This function implements an miiWrite() method that allows PHYs
* on the miiBus to access our MII management registers. This routine
* works in much the same way as cpswPhyRead(), using the shortcut
* PHY management registers to make it look like there's a single
* PHY at MII address 0.
*
* RETURNS: ERROR if invalid PHY addr, else OK
*
* ERRNO: N/A
*/

LOCAL STATUS cpswPhyWrite
    (
    VXB_DEVICE_ID pMiiParent,
    UINT8 phyAddr,
    UINT8 regAddr,
    UINT16 dataVal
    )
    {
    UINT32 ret;
    CPSW_MAC_CTRL * pMacCtrl = pMiiParent->pDrvCtrl;
    CPSW_HOST_CTRL * pHost = pMacCtrl->pHost;
    VXB_DEVICE_ID pDev = pHost->pDev;
    int index = pMiiParent->unitNumber;

    if (phyAddr >= 32)
        {
        return ERROR;
        }

    do
        {
        ret = CSR_READ_4 (pDev, pHost->mdioOffset + CPSW_USERACCESSn(index));
        } while (ret & CPSW_MDIO_GO);

    ret = phyAddr << CPSW_PHY_ADDR_SHIFT |
          regAddr << CPSW_REG_ADDR_SHIFT |
          CPSW_MDIO_GO | CPSW_MDIO_WRITE | dataVal;

    CSR_WRITE_4 (pDev, pHost->mdioOffset + CPSW_USERACCESSn(index), ret);

    do
        {
        ret = CSR_READ_4 (pDev, pHost->mdioOffset + CPSW_USERACCESSn(index));
        } while (ret & CPSW_MDIO_GO);

    return OK;
    }

/*****************************************************************************
*
* cpswLinkUpdate - miiBus miiLinkUpdate method
*
* This function implements an miiLinkUpdate() method that allows
* miiBus to notify us of link state changes. This routine will be
* invoked by the miiMonitor task when it detects a change in link
* status. Normally, the miiMonitor task checks for link events every
* two seconds.
*
* Once we determine the new link state, we will announce the change
* to any bound protocols via muxError(). We also update the ifSpeed
* fields in the MIB2 structures so that SNMP queries can detect the
* correct link speed.
*
* RETURNS: ERROR if obtaining the new media setting fails, else OK
*
* ERRNO: N/A
*/

LOCAL STATUS cpswLinkUpdate
    (
    VXB_DEVICE_ID pMiiParent
    )
    {
    CPSW_MAC_CTRL * pMacCtrl;
    CPSW_HOST_CTRL * pHost;
    VXB_DEVICE_ID pDev;
    UINT32 oldStatus;
    int index;
    UINT32 val;

    if (pMiiParent->pDrvCtrl == NULL)
        return ERROR;

    pMacCtrl = pMiiParent->pDrvCtrl;
    pDev = pMacCtrl->pHost->pDev;
    pHost = pMacCtrl->pHost;

    if (pMacCtrl->cpswMiiBus == NULL)
        return ERROR;

    index = pMiiParent->unitNumber;

    semTake (pMacCtrl->cpswMacSem, WAIT_FOREVER);

    oldStatus = pMacCtrl->cpswCurStatus;

    if (miiBusModeGet(pMacCtrl->cpswMiiBus,
        &pMacCtrl->cpswCurMedia, &pMacCtrl->cpswCurStatus) == ERROR)
        {
        semGive(pMacCtrl->cpswMacSem);
        return ERROR;
        }

    if (!(pMacCtrl->cpswEndObj.flags & IFF_UP))
        {
        semGive(pMacCtrl->cpswMacSem);
        return OK;
        }

    val = CSR_READ_4 (pDev, pMacCtrl->gmacOffset + CPSW_SL_MAC_CTL);
    switch(IFM_SUBTYPE(pMacCtrl->cpswCurMedia))
        {
        case(IFM_1000_T):
        case(IFM_1000_SX):
            val &= ~CPSW_EXT_EN;
            CSR_WRITE_4 (pDev, pMacCtrl->gmacOffset + CPSW_SL_MAC_CTL,
                    GAMC_CTL_GIG | val);

            pMacCtrl->cpswEndObj.mib2Tbl.ifSpeed = 1000000000;
            if (pMacCtrl->cpswEndObj.pMib2Tbl != NULL)
                pMacCtrl->cpswEndObj.pMib2Tbl->m2Data.mibIfTbl.ifSpeed =
                    1000000000;
            break;
        case(IFM_100_TX):
            val &= ~CPSW_EXT_EN;
            CSR_WRITE_4 (pDev, pMacCtrl->gmacOffset + CPSW_SL_MAC_CTL,
                    val & ~GAMC_CTL_GIG);

            pMacCtrl->cpswEndObj.mib2Tbl.ifSpeed = 100000000;
            if (pMacCtrl->cpswEndObj.pMib2Tbl != NULL)
                pMacCtrl->cpswEndObj.pMib2Tbl->m2Data.mibIfTbl.ifSpeed =
                    100000000;
            break;
        case(IFM_10_T):
            val |= CPSW_EXT_EN;
            CSR_WRITE_4 (pDev, pMacCtrl->gmacOffset + CPSW_SL_MAC_CTL,
                    val & ~GAMC_CTL_GIG);

            pMacCtrl->cpswEndObj.mib2Tbl.ifSpeed = 10000000;
            if (pMacCtrl->cpswEndObj.pMib2Tbl != NULL)
                pMacCtrl->cpswEndObj.pMib2Tbl->m2Data.mibIfTbl.ifSpeed =
                    10000000;
            break;
        default:
            pMacCtrl->cpswEndObj.mib2Tbl.ifSpeed = 0;
            pMacCtrl->cpswEndObj.pMib2Tbl->m2Data.mibIfTbl.ifSpeed = 0;
            break;
        }

    val = CSR_READ_4 (pDev, pMacCtrl->gmacOffset + CPSW_SL_MAC_CTL);
    if ((pMacCtrl->cpswCurMedia & IFM_GMASK) == IFM_FDX)
        CSR_WRITE_4 (pDev, pMacCtrl->gmacOffset + \
                        CPSW_SL_MAC_CTL, val | GMAC_CTL_FULLDUPLEX);
    else
        CSR_WRITE_4 (pDev, pMacCtrl->gmacOffset + CPSW_SL_MAC_CTL,
                     val &~ GMAC_CTL_FULLDUPLEX);

    if (pMacCtrl->cpswEndObj.pMib2Tbl != NULL)
        pMacCtrl->cpswEndObj.pMib2Tbl->m2Data.mibIfTbl.ifSpeed =
            pMacCtrl->cpswEndObj.mib2Tbl.ifSpeed;

    if (!(pMacCtrl->cpswEndObj.flags & IFF_UP))
        {
        semGive (pMacCtrl->cpswMacSem);
        return (OK);
        }

    /* If status went from down to up, announce link up. */

    if (pMacCtrl->cpswCurStatus & IFM_ACTIVE && !(oldStatus & IFM_ACTIVE))
        {
        cpswPhyWrite (pMiiParent, 0, 22, 0x20);
        cpswPhyWrite (pMiiParent, 1, 22, 0x20);

        jobQueueStdPost (pHost->cpswJobQueue,
                         NET_TASK_QJOB_PRI, muxLinkUpNotify,
                         &pMacCtrl->cpswEndObj, NULL, NULL, NULL, NULL);
        }

    /* If status went from up to down, announce link down. */

    if (!(pMacCtrl->cpswCurStatus & IFM_ACTIVE) && oldStatus & IFM_ACTIVE)
        jobQueueStdPost (pHost->cpswJobQueue,
                         NET_TASK_QJOB_PRI, muxLinkDownNotify,
                         &pMacCtrl->cpswEndObj, NULL, NULL, NULL, NULL);

    semGive(pMacCtrl->cpswMacSem);

    return (OK);
    }

/*******************************************************************************
*
* cpswMuxConnect - muxConnect method handler
*
* This function handles muxConnect() events, which may be triggered
* manually or(more likely) by the bootstrap code. Most VxBus
* initialization occurs before the MUX has been fully initialized,
* so the usual muxDevLoad()/muxDevStart() sequence must be defered
* until the networking subsystem is ready. This routine will ultimately
* trigger a call to cpswEndLoad() to create the END interface instance.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void cpswMuxConnect
    (
    VXB_DEVICE_ID pDev,
    void * unused
    )
    {
    int i;
    CPSW_MAC_CTRL  * pMacCtrl;
    CPSW_HOST_CTRL * pHost = pDev->pDrvCtrl;

    for (i = 0; i < pHost->nrMacPorts; i++)
        {
        pMacCtrl = pHost->ports[i];

        pMacCtrl->cookie =
                muxDevLoad (pMacCtrl->index, cpswEndLoad, "", TRUE, pDev);

        if (pMacCtrl->cookie)
            muxDevStart (pMacCtrl->cookie);

        if (_func_m2PollStatsIfPoll != NULL)
            endPollStatsInit (pMacCtrl->cookie,  _func_m2PollStatsIfPoll);
        }
    }

/*******************************************************************************
*
* cpswEndLoad - END driver entry point
*
* This routine initializes the END interface instance associated
* with this device. In traditional END drivers, this function is
* the only public interface, and it's typically invoked by a BSP
* driver configuration stub. With VxBus, the BSP stub code is no
* longer needed, and this function is now invoked automatically
* whenever this driver's muxConnect() method is called.
*
* For older END drivers, the load string would contain various
* configuration parameters, but with VxBus this use is deprecated.
* The load string should just be an empty string. The second
* argument should be a pointer to the VxBus device instance
* associated with this device. Like older END drivers, this routine
* will still return the device name if the init string is empty,
* since this behavior is still expected by the MUX. The MUX will
* invoke this function twice: once to obtain the device name,
* and then again to create the actual END_OBJ instance.
*
* When this function is called the second time, it will initialize
* the END object, perform MIB2 setup, allocate a buffer pool, and
* initialize the supported END capabilities. The only special
* capability we support is VLAN_MTU, since we can receive slightly
* larger than normal frames.
*
* RETURNS: An END object pointer, or NULL on error, or 0 and the name
* of the device if the <loadStr> was empty.
*
* ERRNO: N/A
*/

LOCAL END_OBJ * cpswEndLoad
    (
    char * loadStr,
    void * pArg
    )
    {
    CPSW_HOST_CTRL * pHost;
    CPSW_MAC_CTRL * pMacCtrl;
    VXB_DEVICE_ID pDev;
    int unit;

    if (loadStr == NULL)
        return NULL;

    if (loadStr[0] == 0)
        {
        bcopy (CPSW_NAME, loadStr, sizeof (CPSW_NAME));
        return NULL;
        }

    pDev = pArg;
    pHost = pDev->pDrvCtrl;

    /* get our instance number from load string */

    unit = atoi (loadStr);

    pMacCtrl = pHost->ports[unit];

    if (END_OBJ_INIT (&pMacCtrl->cpswEndObj, NULL, pDev->pName,
        unit, &cpswNetFuncs, "CPSW END") != OK)
        {
        return NULL;
        }

    endM2Init (&pMacCtrl->cpswEndObj, M2_ifType_ethernet_csmacd,
        pMacCtrl->macaddr,
        ETHER_ADDR_LEN, ETHERMTU, 100000000, IFF_NOTRAILERS | IFF_SIMPLEX |
        IFF_MULTICAST | IFF_BROADCAST);

    pMacCtrl->cpswMtu = CPSW_MTU;

    if (endPoolCreate (
                (CPSW_DESC_CNT * 3), &pMacCtrl->cpswEndObj.pNetPool) != OK)
        {
        return NULL;
        }
    pMacCtrl->cpswPollbuf = endPoolTupleGet (pMacCtrl->cpswEndObj.pNetPool);

    /* Set up cpswPolling stats. */

    pMacCtrl->cpswStatsConf.ifPollInterval = sysClkRateGet();
    pMacCtrl->cpswStatsConf.ifEndObj = &pMacCtrl->cpswEndObj;
    pMacCtrl->cpswStatsConf.ifWatchdog = NULL;
    pMacCtrl->cpswStatsConf.ifValidCounters = (
        END_IFINMULTICASTPKTS_VALID | END_IFINBROADCASTPKTS_VALID |
        END_IFINOCTETS_VALID | END_IFINERRORS_VALID | END_IFINDISCARDS_VALID |
        END_IFOUTMULTICASTPKTS_VALID |
        END_IFOUTBROADCASTPKTS_VALID | END_IFOUTOCTETS_VALID |
        END_IFOUTERRORS_VALID);

    /* Set up capabilities. */

    pMacCtrl->cpswCaps.cap_available = IFCAP_VLAN_MTU;
    pMacCtrl->cpswCaps.cap_enabled   = IFCAP_VLAN_MTU;

    return (&pMacCtrl->cpswEndObj);
    }

/*******************************************************************************
*
* cpswEndUnload - unload END driver instance
*
* This routine undoes the effects of cpswEndLoad(). The END object
* is destroyed, our network pool is released, the endM2 structures
* are released, and the cpswPolling stats watchdog is terminated.
*
* Note that the END interface instance can't be unloaded if the
* device is still running. The device must be stopped with muxDevStop()
* first.
*
* RETURNS: ERROR if device is still in the IFF_UP state, otherwise OK
*
* ERRNO: N/A
*/

LOCAL STATUS cpswEndUnload
    (
    END_OBJ * pEnd
    )
    {
    CPSW_MAC_CTRL * pMacCtrl;

    if (pEnd->flags & IFF_UP)
        return ERROR;

    pMacCtrl = (CPSW_MAC_CTRL *)pEnd;

    netMblkClChainFree (pMacCtrl->cpswPollbuf);
    endPoolDestroy (pMacCtrl->cpswEndObj.pNetPool);
    endM2Free (&pMacCtrl->cpswEndObj);
    END_OBJECT_UNLOAD (&pMacCtrl->cpswEndObj);

    return EALREADY;
    }

/*****************************************************************************
 *
 * cpswEndHashTblPopulate - set the Multicast table entry
 *
 * This function programs the CPSW controller's multicast table entry
 * to receive frames sent to the multicast groups specified.
 * If VLAN ID is greater than zero then VLAN LLDP/Multicast is added.
 * If the interface is in IFF_ALLMULTI or IFF_PROMISC mode, the filter
 * will be programmed to receive all multicast packets by setting to the
 * bypass mode.The packet with a matching multicast destination address
 * set to be a supervisory packet.
 *
 * RETURNS: N/A
 *
 * ERRNO: N/A
 */

LOCAL void cpswEndHashTblPopulate
    (
    CPSW_MAC_CTRL  * pMacCtrl
    )
    {
    int i, type, multicast, rt;
    CPSW_HOST_CTRL * pHost = pMacCtrl->pHost;
    VXB_DEVICE_ID    pDev = pHost->pDev;
    ETHER_MULTI *    mCastNode = NULL;
    CPSW_ALE_TBL     tbl;
    UINT32           aleCtl;

    /* If flags & (IFF_ALLMULTI | IFF_PROMISC) is true, set to bypass mode. */

    if (pMacCtrl->cpswEndObj.flags & (IFF_ALLMULTI|IFF_PROMISC))
        {
        aleCtl = CSR_READ_4 (pDev, pHost->aleOffset + CPSW_ALE_CONTROL);
        aleCtl |= CPSW_ALE_BYPASS;
        CSR_WRITE_4 (pDev, pHost->aleOffset + CPSW_ALE_CONTROL, aleCtl);
        return;
        }

    /* First, clear out all multicast ALEs. */

    for (i = 0; i < CPSW_ALE_ENTRY_NR; i++)
        {
        cpswAleRead (pDev, &tbl, i);
        type = (tbl.word1 >> 28) & 0x3;
        multicast = tbl.word1 & 0x100;

        if (multicast &&
            ((type == CPSW_ALE_TYPE_ADDR) || (type == CPSW_ALE_TYPE_VLAN_ADDR)))
            {
            memset ((char *)&tbl, 0, sizeof(tbl));
            cpswAleWrite (pDev, &tbl, i);
            }
        }

    /* Otherwise, add multicast ALEs */

    for (mCastNode =
        (ETHER_MULTI *) lstFirst (&pMacCtrl->cpswEndObj.multiList);
         mCastNode != NULL;
         mCastNode = (ETHER_MULTI *) lstNext (&mCastNode->node))
        {
        rt = cpswAleAddMultiCast (pDev, (unsigned char *)mCastNode->addr, pMacCtrl->portVlan,
                                CPSW_ALE_MCAST_FWD_2, CPSW_ALE_MCAST_SUPER, 1 << pHost->portnr);
        if ( rt != 0 )
            break;
        }
    }

/*******************************************************************************
*
* cpswEndMCastAddrAdd - add a multicast address for the device
*
* This routine adds a multicast address to whatever the driver
* is already listening for. It then resets the address filter.
*
* RETURNS: OK, always.
*
* ERRNO: N/A
*/

LOCAL STATUS cpswEndMCastAddrAdd
    (
    END_OBJ * pEnd,
    char * pAddr
    )
    {
    int retVal;
    CPSW_MAC_CTRL * pMacCtrl =(CPSW_MAC_CTRL *)pEnd;

    semTake (pMacCtrl->cpswMacSem, WAIT_FOREVER);

    if (!(pMacCtrl->cpswEndObj.flags & IFF_UP))
        {
        semGive (pMacCtrl->cpswMacSem);
        return OK;
        }

    retVal = etherMultiAdd (&pEnd->multiList, pAddr);

    if (retVal == ENETRESET)
        {
        pEnd->nMulti++;
        cpswEndHashTblPopulate (pMacCtrl);
        }

    semGive (pMacCtrl->cpswMacSem);

    return OK;
    }

/*******************************************************************************
*
* cpswEndMCastAddrDel - delete a multicast address for the device
*
* This routine removes a multicast address from whatever the driver
* is listening for. It then resets the address filter.
*
* RETURNS: OK, always.
*
* ERRNO: N/A
*/

LOCAL STATUS cpswEndMCastAddrDel
    (
    END_OBJ * pEnd,
    char * pAddr
    )
    {
    int retVal;
    CPSW_MAC_CTRL * pMacCtrl =(CPSW_MAC_CTRL *) pEnd;

    semTake (pMacCtrl->cpswMacSem, WAIT_FOREVER);

    if (!(pMacCtrl->cpswEndObj.flags & IFF_UP))
        {
        semGive (pMacCtrl->cpswMacSem);
        return OK;
        }

    retVal = etherMultiDel (&pEnd->multiList, pAddr);

    if (retVal == ENETRESET)
        {
        pEnd->nMulti--;
        cpswEndHashTblPopulate (pMacCtrl);
        }

    semGive (pMacCtrl->cpswMacSem);

    return OK;
    }

/*******************************************************************************
*
* cpswEndMCastAddrGet - get the multicast address list for the device
*
* This routine gets the multicast list of whatever the driver
* is already listening for.
*
* RETURNS: OK, always.
*
* ERRNO: N/A
*/

LOCAL STATUS cpswEndMCastAddrGet
    (
    END_OBJ * pEnd,
    MULTI_TABLE * pTable
    )
    {
    int retVal;
    CPSW_MAC_CTRL * pMacCtrl =(CPSW_MAC_CTRL *) pEnd;

    semTake (pMacCtrl->cpswMacSem, WAIT_FOREVER);

    if (!(pMacCtrl->cpswEndObj.flags & IFF_UP))
        {
        semGive (pMacCtrl->cpswMacSem);
        return OK;
        }

    retVal = etherMultiGet (&pEnd->multiList, pTable);

    if (retVal == ENETRESET)
        {
        pEnd->nMulti++;
        }

    semGive (pMacCtrl->cpswMacSem);

    return OK;
    }

/*******************************************************************************
*
* cpswEndStatsDump - return polled statistics counts
*
* This routine is automatically invoked periodically by the polled
* statistics watchdog.
*
* RETURNS: always OK
*
* ERRNO: N/A
*/

LOCAL STATUS cpswEndStatsDump
    (
    CPSW_MAC_CTRL * pMacCtrl
    )
    {
    int i;
    CPSW_HOST_CTRL * pHost = pMacCtrl->pHost;
    VXB_DEVICE_ID pDev = pHost->pDev;
    UINT32 * temp = (UINT32 *)&pHost->cpswStat;
    END_IFCOUNTERS * pEndStatsCounters;

    /*
     * hardware statistic counters are write-to-decrement,
     * after a read, we write the value read to clear
     * the counters
     */

    for (i = 0; i < sizeof (CPSW_STAT) / sizeof (UINT32); i++)
        {
        *temp = CSR_READ_4 (pDev, pHost->statsOffset + i*4);
        CSR_WRITE_4 (pDev, pHost->statsOffset + i*4, *temp);
        temp++;
        }

    pEndStatsCounters = &pMacCtrl->cpswStatsCounters;

    pEndStatsCounters->ifInOctets = pHost->cpswStat.rxoctets;
    pEndStatsCounters->ifInMulticastPkts = pHost->cpswStat.rxmulticast;
    pEndStatsCounters->ifInBroadcastPkts = pHost->cpswStat.rxbroadcast;
    pEndStatsCounters->ifInErrors = pHost->cpswStat.rxpause +
        pHost->cpswStat.rxcrcerros +
        pHost->cpswStat.rxalignmenterrors +
        pHost->cpswStat.rxoversized +
        pHost->cpswStat.rxjabber +
        pHost->cpswStat.rxundersized;
    pEndStatsCounters->ifInDiscards = pMacCtrl->cpswInDropped;

    pEndStatsCounters->ifOutOctets = pHost->cpswStat.txoctets;
    pEndStatsCounters->ifOutMulticastPkts = pHost->cpswStat.txmulticast;
    pEndStatsCounters->ifOutBroadcastPkts = pHost->cpswStat.txbroadcast;

    pEndStatsCounters->ifOutErrors = pHost->cpswStat.txpause +
        pHost->cpswStat.txdefered +
        pHost->cpswStat.txcollision +
        pHost->cpswStat.txexceesive +
        pHost->cpswStat.txsinglecol+
        pHost->cpswStat.txmulticol +
        pHost->cpswStat.txlatecol +
        pHost->cpswStat.txunderrun;

    return OK;
    }

/*******************************************************************************
*
* cpswEndIoctl - the driver I/O control routine
*
* This function processes ioctl requests supplied via the muxIoctl()
* routine. In addition to the normal boilerplate END ioctls, this
* driver supports the IFMEDIA ioctls, END capabilities ioctls, and
* polled stats ioctls.
*
* RETURNS: A command specific response, usually OK or ERROR.
*
* ERRNO: N/A
*/

LOCAL int cpswEndIoctl
    (
    END_OBJ * pEnd,
    int cmd,
    caddr_t data
    )
    {
    CPSW_MAC_CTRL * pMacCtrl = (CPSW_MAC_CTRL *)pEnd;
    CPSW_HOST_CTRL * pHost = pMacCtrl->pHost;
    VXB_DEVICE_ID pDev = pHost->pDev;
    END_MEDIALIST * mediaList;
    END_CAPABILITIES * hwCaps;
    END_MEDIA * pMedia;
    END_RCVJOBQ_INFO * qinfo;
    UINT32 nQs;

    INT32 value;
    int error = OK;

    if (cmd != EIOCPOLLSTART && cmd != EIOCPOLLSTOP)
        semTake (pMacCtrl->cpswMacSem, WAIT_FOREVER);

    switch (cmd)
        {
        case EIOCSADDR:
            if (data == NULL)
                error = EINVAL;
            else
                {
                UINT32 lo, hi;
                int i = -1;
                CPSW_ALE_TBL t;
                unsigned char oldmac[ETHER_ADDR_LEN];
                bcopy((char *)pMacCtrl->macaddr, (char *)oldmac, ETHER_ADDR_LEN);
                bcopy ((char *)data, (char *)pMacCtrl->macaddr, ETHER_ADDR_LEN);
                bcopy ((char *)data,
                    (char *)pEnd->mib2Tbl.ifPhysAddress.phyAddress,
                    ETHER_ADDR_LEN);
                if (pEnd->pMib2Tbl != NULL)
                    bcopy ((char *)data,
                    (char *)pEnd->pMib2Tbl->m2Data.mibIfTbl.ifPhysAddress.phyAddress,
                    ETHER_ADDR_LEN);

                if ((i = cpswAleMatch(pDev, oldmac)) < 0)
                    {

                    /*
                     * This shall not happen, but we still handle it.
                     * Add mac addres in ALE table.
                     */

                    cpswAleAddUniCast (pDev, pMacCtrl->macaddr, pMacCtrl->portVlan,
                        0, 0, pHost->portnr);
                    }
                else
                    {

                    /* Read the old mac entry, replace it with the new one */

                    cpswAleRead (pDev, &t, i);
                    lo = (pMacCtrl->macaddr[0] << 8)  | pMacCtrl->macaddr[1];
                    hi = (pMacCtrl->macaddr[2] << 24) | (pMacCtrl->macaddr[3] << 16) |
                         (pMacCtrl->macaddr[4] << 8)  | pMacCtrl->macaddr[5];
                    t.word0 = hi;
                    t.word1 &= ~0xFFFF;
                    t.word1 |= lo;
                    cpswAleWrite (pDev, &t, i);
                    }
               }
            break;

        case EIOCGADDR:
            if (data == NULL)
                error = EINVAL;
            else
                bcopy ((char *)pMacCtrl->macaddr, (char *)data, ETHER_ADDR_LEN);
            break;

        case EIOCSFLAGS:
            {
            long oldFlags;
            long newFlags;

            oldFlags = END_FLAGS_GET (pEnd);
            value = (INT32) data;
            if (value < 0)
                {
                value = -value;
                value--;
                END_FLAGS_CLR (pEnd, value);
                }
            else
                {
                END_FLAGS_SET (pEnd, value);
                }

            newFlags = END_FLAGS_GET (pEnd);

            if (!(newFlags & IFF_PROMISC) && (oldFlags & IFF_PROMISC))
                {
                UINT32 tmp = CPSW_ALE_EN_TABLE | CPSW_ALE_CLR_TABLE;
                if (pHost->dualEmac == TRUE)
                    tmp |= CPSW_ALE_VLAN_AWARE;
                CSR_WRITE_4 (pDev, pHost->aleOffset + CPSW_ALE_CONTROL, tmp);

                cpswAleAddVlan (pDev,
                        (0x1 << pHost->portnr) |
                        (0x1 << pHost->ports[0]->portnr),
                        0, 0, 0, pHost->ports[0]->portVlan);
                cpswAleAddUniCast (pDev, pHost->ports[0]->macaddr,
                        pHost->ports[0]->portVlan,
                        0, 0, pHost->portnr);

                cpswAleAddVlan (pDev, (0x1 << pHost->portnr) |
                        (0x1 << pHost->ports[1]->portnr),
                        0, 0, 0, pHost->ports[1]->portVlan);
                cpswAleAddUniCast (pDev, pHost->ports[1]->macaddr,
                        pHost->ports[1]->portVlan,
                        0, 0, pHost->portnr);
                }
            if ((newFlags & IFF_PROMISC) && !(oldFlags & IFF_PROMISC))
                {
                CSR_WRITE_4 (pDev, pHost->aleOffset + CPSW_ALE_CONTROL,
                       CPSW_ALE_EN_TABLE | CPSW_ALE_CLR_TABLE | CPSW_ALE_BYPASS);
                }
            }

            break;

        case EIOCGFLAGS:
            if (data == NULL)
                error = EINVAL;
            else
                *(long *)data = END_FLAGS_GET(pEnd);

            break;

        case EIOCMULTIADD:
            error = cpswEndMCastAddrAdd (pEnd,(char *) data);
            break;

        case EIOCMULTIDEL:
            error = cpswEndMCastAddrDel (pEnd,(char *) data);
            break;

        case EIOCMULTIGET:
            error = cpswEndMCastAddrGet (pEnd,(MULTI_TABLE *) data);
            break;

        case EIOCPOLLSTART:

            pMacCtrl->cpswPolling = TRUE;

            CPDMA_RX_INT_DIS (pDev, pMacCtrl->cpswRxDmaChan);
            CPDMA_TX_INT_DIS (pDev, pMacCtrl->cpswTxDmaChan);

            while (pMacCtrl->cpswTxFree < CPSW_DESC_CNT)
                {
                M_BLK_ID pMblk;
                volatile CPSW_DESC * desc;

                desc = &pMacCtrl->cpswTxDescMem[pMacCtrl->cpswTxQHead];

                 if (desc->flags & CPSW_EOQ)
                    {
                    CSR_WRITE_4(pDev, CPDMA_TX_CP(pMacCtrl->cpswTxDmaChan),
                        desc->phys);
                    if (desc->link)
                        {
                        CSR_WRITE_4(pDev, CPDMA_TX_HDP(pMacCtrl->cpswTxDmaChan),
                            desc->link);
                        }
                    }

                 while (desc->flags & CPSW_OWNERSHIP)
                     ;

                pMblk = pMacCtrl->cpswTxblk[pMacCtrl->cpswTxQHead];

                if (pMblk != NULL)
                    {
                    endPoolTupleFree (pMblk);
                    pMacCtrl->cpswTxblk[pMacCtrl->cpswTxQHead] = NULL;
                    }

                pMacCtrl->cpswTxFree++;
                CPSW_DESC_INC (pMacCtrl->cpswTxQHead, CPSW_DESC_CNT);
                }
            break;

        case EIOCPOLLSTOP:

            pMacCtrl->cpswPolling = FALSE;

            CPDMA_TX_INT_EN(pDev, pMacCtrl->cpswTxDmaChan);
            CPDMA_RX_INT_EN(pDev, pMacCtrl->cpswRxDmaChan);

            break;

        case EIOCGMIB2233:
        case EIOCGMIB2:
            error = endM2Ioctl (&pMacCtrl->cpswEndObj, cmd, data);
            break;

        case EIOCGPOLLCONF:
            if (data == NULL)
                error = EINVAL;
            else
                *((END_IFDRVCONF **)data) = &pMacCtrl->cpswStatsConf;
            break;

        case EIOCGPOLLSTATS:
            if (data == NULL)
                error = EINVAL;
            else
                {
                error = cpswEndStatsDump (pMacCtrl);
                if (error == OK)
                    *((END_IFCOUNTERS **)data) = &pMacCtrl->cpswStatsCounters;
                }
            break;

        case EIOCGMEDIALIST:
            if (data == NULL)
                {
                error = EINVAL;
                break;
                }
            if (pMacCtrl->cpswMediaList->endMediaListLen == 0)
                {
                error = ENOTSUP;
                break;
                }

            mediaList =(END_MEDIALIST *)data;
            if (mediaList->endMediaListLen <
                pMacCtrl->cpswMediaList->endMediaListLen)
                {
                mediaList->endMediaListLen =
                    pMacCtrl->cpswMediaList->endMediaListLen;
                error = ENOSPC;
                break;
                }

            bcopy ((char *)pMacCtrl->cpswMediaList, (char *)mediaList,
                  sizeof (END_MEDIALIST) + (sizeof (UINT32) *
                  pMacCtrl->cpswMediaList->endMediaListLen));
            break;

        case EIOCGIFMEDIA:
            if (data == NULL)
                error = EINVAL;
            else
                {
                pMedia =(END_MEDIA *)data;
                pMedia->endMediaActive = pMacCtrl->cpswCurMedia;
                pMedia->endMediaStatus = pMacCtrl->cpswCurStatus;
                }
            break;

        case EIOCSIFMEDIA:
            if (data == NULL)
                error = EINVAL;
            else
                {
                pMedia =(END_MEDIA *)data;
                miiBusModeSet (pMacCtrl->cpswMiiBus, pMedia->endMediaActive);
                cpswLinkUpdate (pMacCtrl->cpswMiiParent);
                error = OK;
                }
            break;

        case EIOCGIFCAP:
            hwCaps =(END_CAPABILITIES *)data;
            if (hwCaps == NULL)
                {
                error = EINVAL;
                break;
                }
            hwCaps->cap_available = pMacCtrl->cpswCaps.cap_available;
            hwCaps->cap_enabled = pMacCtrl->cpswCaps.cap_enabled;
            break;

        case EIOCSIFCAP:
            error = ENOTSUP;
            break;

        case EIOCGIFMTU:
            if (data == NULL)
                error = EINVAL;
            else
                *(INT32 *)data = pEnd->mib2Tbl.ifMtu;
            break;

        case EIOCSIFMTU:
            value =(INT32)data;
            if (value <= 0 || value > pMacCtrl->cpswMtu)
                {
                error = EINVAL;
                break;
                }
            pEnd->mib2Tbl.ifMtu = value;
            if (pEnd->pMib2Tbl != NULL)
                pEnd->pMib2Tbl->m2Data.mibIfTbl.ifMtu = value;
            break;

        case EIOCGRCVJOBQ:
            if (data == NULL)
                {
                error = EINVAL;
                break;
                }

            qinfo = (END_RCVJOBQ_INFO *)data;
            nQs = qinfo->numRcvJobQs;
            qinfo->numRcvJobQs = 1;
            if (nQs < 1)
                error = ENOSPC;
            else
                qinfo->qIds[0] = pMacCtrl->pHost->cpswJobQueue;
            break;

        default:
            error = EINVAL;
            break;
        }

    if (cmd != EIOCPOLLSTART && cmd != EIOCPOLLSTOP)
        semGive (pMacCtrl->cpswMacSem);

    return (error);
    }

/*******************************************************************************
*
* cpswEndStart - start the device
*
* This function resets the device to put it into a known state and
* then configures it for RX and TX operation. The RX and TX configuration
* registers are initialized, and the address of the RX DMA window is
* loaded into the device. Interrupts are then enabled, and the initial
* link state is configured.
*
* Note that this routine also checks to see if an alternate jobQueue
* has been specified via the vxbParam subsystem. This allows the driver
* to divert its work to an alternate processing task, such as may be
* done with TIPC. This means that the jobQueue can be changed while
* the system is running, but the device must be stopped and restarted
* for the change to take effect.
*
* RETURNS: ERROR if device initialization failed, otherwise OK
*
* ERRNO: N/A
*/

LOCAL STATUS cpswEndStart
    (
    END_OBJ * pEnd
    )
    {
    int i;
    CPSW_DESC * desc;
    STATUS ret = OK;
    CPSW_MAC_CTRL * pMacCtrl = (CPSW_MAC_CTRL *)pEnd;
    CPSW_HOST_CTRL * pHost = pMacCtrl->pHost;
    VXB_DEVICE_ID pDev = pHost->pDev;
    VXB_DMA_MAP_ID pMap;
    UINT32 val;

    semTake(pMacCtrl->cpswMacSem, WAIT_FOREVER);
    END_TX_SEM_TAKE (pEnd, WAIT_FOREVER);

    if (pEnd->flags & IFF_UP)
        {
        ret = ERROR;
        CPSW_DEBUG ("cpswEndStart: end already startup!\n",0,0,0,0,0,0);

        goto out;
        }

    /* we use the port index for DMA channel number */

    /* request for rx dma channel */

    if (cpdmaChanRequest (pDev, TRUE, pMacCtrl->index) != OK)
        {
        ret = ERROR;
        CPSW_DEBUG ("cpswEndStart: alloc rx dma chan failed!\n",0,0,0,0,0,0);

        goto failed;
        }
    pMacCtrl->cpswRxDmaChan = pMacCtrl->index;

    /* request for tx dma channel */

    if (cpdmaChanRequest (pDev, FALSE, pMacCtrl->index) != OK)
        {
        ret = ERROR;
        CPSW_DEBUG ("cpswEndStart: alloc tx dma chan failed!\n",0,0,0,0,0,0);

        goto failed;
        }
    pMacCtrl->cpswTxDmaChan = pMacCtrl->index;

    /* setup channel dma priority mapping for dual emac mode */

    val = CSR_READ_4 (pDev, pHost->portOffset + CPDMA_RX_CH_MAP);
    if (pMacCtrl->index == 0)
        {
        val = val & 0xffff0000;
        val |= (pMacCtrl->cpswRxDmaChan | (pMacCtrl->cpswRxDmaChan << 4) |
               (pMacCtrl->cpswRxDmaChan << 8) | (pMacCtrl->cpswRxDmaChan << 12));
        }
    else
        {
        val = val & 0xffff;
        val |= (pMacCtrl->cpswRxDmaChan | (pMacCtrl->cpswRxDmaChan << 4) |
               (pMacCtrl->cpswRxDmaChan << 8) | (pMacCtrl->cpswRxDmaChan << 12)) << 16;
        }

    CSR_WRITE_4 (pDev, pHost->portOffset + CPDMA_RX_CH_MAP, val);

    pHost->cpswJobQueue = netJobQueueId;
    QJOB_SET_PRI(&pHost->cpswQJob, NET_TASK_QJOB_PRI);
    pHost->cpswQJob.func = (QJOB_FUNC)cpswIntHandle;

    /* set up rx mblks */

    for (i = 0; i < CPSW_DESC_CNT; i++)
        {
        pMacCtrl->cpswRxblk[i] =
                endPoolTupleGet (pMacCtrl->cpswEndObj.pNetPool);
        if (!pMacCtrl->cpswRxblk[i])
            {
            ret = ERROR;
            CPSW_DEBUG ("cpswEndStart: alloc end truple failed!\n",0,0,0,0,0,0);

            goto failed;
            }

        pMap = pMacCtrl->cpswRxMblkMap[i];
        if (vxbDmaBufMapMblkLoad (pDev, pMacCtrl->cpswMblkTag,
            pMap, pMacCtrl->cpswRxblk[i], 0) != OK)
            {
            ret = ERROR;
            goto failed;
            }

        desc = pMacCtrl->cpswRxDescMem + i;
        desc->buf    = (UINT32)pMap->fragList[0].frag;
        desc->len    = CPSW_MTU;
        desc->offset = 0;
        desc->flags  = CPSW_OWNERSHIP;
        }

    /* link all the RX descriptors, here we need physical address */

    desc = (CPSW_DESC *)(intptr_t)pMacCtrl->cpswRxDescMap->fragList[0].frag;
    for (i = 0; i < CPSW_DESC_CNT - 1; i++)
        pMacCtrl->cpswRxDescMem[i].link = (UINT32)(desc + (i + 1));
    pMacCtrl->cpswRxDescTail = &pMacCtrl->cpswRxDescMem [CPSW_DESC_CNT - 1];

    CPDMA_REG_WRITE (pDev, CPDMA_RX_FREEBUF(pMacCtrl->cpswRxDmaChan),
                    CPSW_DESC_CNT);

    CPDMA_REG_WRITE (pDev, CPDMA_RX_HDP(pMacCtrl->cpswRxDmaChan),
                    (UINT32)pMacCtrl->cpswRxDescMap->fragList[0].frag);

    /* enable channel interrupts */

    CPDMA_TX_INT_EN (pDev, pMacCtrl->cpswTxDmaChan);
    CPDMA_RX_INT_EN (pDev, pMacCtrl->cpswRxDmaChan);
    CSR_WRITE_4 (pDev, pHost->wrOffset + CPSW_WR_C0_TX_EN, 0xff);
    CSR_WRITE_4 (pDev, pHost->wrOffset + CPSW_WR_C0_RX_EN, 0xff);
    CSR_WRITE_4 (pDev, pHost->wrOffset + CPSW_WR_C0_MISC_EN, 0x1f);

    /* if we are the first one, enable global resources */

    if (pHost->nrActivePorts == 0)
        {
        /* enable global interrupts */

        CPDMA_HOSTERR_INT_EN (pDev);

        /* enable tx and rx */

        CPDMA_TX_EN (pDev);
        CPDMA_RX_EN (pDev);
        }

    pHost->nrActivePorts++;

    /* tell the stack that we are on-line */

    pMacCtrl->cpswCurMedia = IFM_ETHER | IFM_NONE;
    pMacCtrl->cpswCurStatus = IFM_AVALID;

    miiBusModeSet (pMacCtrl->cpswMiiBus,
                   pMacCtrl->cpswMediaList->endMediaListDefault);

    END_FLAGS_SET (pEnd, (IFF_UP | IFF_RUNNING));

    goto out;

failed:
    if (pMacCtrl->cpswRxDmaChan >= 0)
        cpdmaChanRelease (pDev, TRUE, pMacCtrl->cpswRxDmaChan);
    if (pMacCtrl->cpswTxDmaChan >= 0)
        cpdmaChanRelease (pDev, FALSE, pMacCtrl->cpswTxDmaChan);

    for (i = 0; i < CPSW_DESC_CNT; i++)
        {
        if (pMacCtrl->cpswRxblk[i])
            endPoolTupleFree (pMacCtrl->cpswRxblk[i]);
        pMacCtrl->cpswRxblk[i] = NULL;
        }

    for (i = 0; i < CPSW_DESC_CNT; i++)
        vxbDmaBufMapUnload (pMacCtrl->cpswMblkTag, pMacCtrl->cpswRxMblkMap[i]);

out:
    END_TX_SEM_GIVE (pEnd);
    semGive (pMacCtrl->cpswMacSem);

    return ret;
    }

/*******************************************************************************
*
* cpswEndStop - stop the device
*
* This function undoes the effects of cpswEndStart(). The device is shut
* down and all resources are released. Note that the shutdown process
* pauses to wait for all pending RX, TX and link event jobs that may have
* been initiated by the interrupt handler to complete. This is done
* to prevent tNetTask from accessing any data that might be released by
* this routine.
*
* RETURNS: ERROR if device shutdown failed, otherwise OK
*
* ERRNO: N/A
*/

LOCAL STATUS cpswEndStop
    (
    END_OBJ * pEnd
    )
    {
    int i;
    CPSW_MAC_CTRL * pMacCtrl = (CPSW_MAC_CTRL *)pEnd;
    CPSW_HOST_CTRL * pHost = pMacCtrl->pHost;
    VXB_DEVICE_ID pDev = pHost->pDev;

    semTake (pMacCtrl->cpswMacSem, WAIT_FOREVER);
    END_TX_SEM_TAKE (pEnd, WAIT_FOREVER);

    if (!(pEnd->flags & IFF_UP))
        {
        END_TX_SEM_GIVE (pEnd);
        semGive (pMacCtrl->cpswMacSem);
        return OK;
        }

    END_FLAGS_CLR (pEnd,(IFF_UP | IFF_RUNNING));

    CPDMA_RX_DIS (pDev);
    CPDMA_TX_DIS (pDev);
    CPDMA_HOSTERR_INT_DIS (pDev);

    CSR_WRITE_4 (pDev, pHost->wrOffset + CPSW_WR_C0_TX_EN, 0x0);
    CSR_WRITE_4 (pDev, pHost->wrOffset + CPSW_WR_C0_RX_EN, 0x0);
    CSR_WRITE_4 (pDev, pHost->wrOffset + CPSW_WR_C0_MISC_EN, 0x0);

    /* give rx/tx handler a chance to finish */

    while (vxAtomicGet (&pHost->cpswIntPending) == TRUE)
        taskDelay (10);

    CPDMA_TX_INT_DIS (pDev, pMacCtrl->cpswTxDmaChan);
    CPDMA_RX_INT_DIS (pDev, pMacCtrl->cpswRxDmaChan);

    for (i = 0; i < CPSW_DESC_CNT; i++)
        {
        if (pMacCtrl->cpswRxblk[i])
            {
            vxbDmaBufMapUnload (pMacCtrl->cpswMblkTag,
                pMacCtrl->cpswRxMblkMap[i]);

            endPoolTupleFree (pMacCtrl->cpswRxblk[i]);
            }
        }

    cpdmaChanRelease (pDev, TRUE, pMacCtrl->cpswRxDmaChan);
    cpdmaChanRelease (pDev, FALSE, pMacCtrl->cpswTxDmaChan);

    END_TX_SEM_GIVE (pEnd);
    semGive (pMacCtrl->cpswMacSem);

    return OK;
    }

/*******************************************************************************
*
* cpswEndErrHandle - handle CPDMA channel errors
*
* This routine is scheduled by the ISR to run in the context of tNetTask
* whenever a CPDMA error interrupt is received. This routine will reset all the
* descriptors to their default value.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void cpswEndErrHandle
    (
    CPSW_HOST_CTRL * pHost
    )
    {
    int i, cnt;
    VXB_DEVICE_ID pDev = pHost->pDev;
    UINT32 txErr, rxErr, rxChan, txChan, val;
    CPSW_DESC * desc;
    VXB_DMA_MAP_ID pMap;
    CPSW_MAC_CTRL * pMacCtrl;

    static char __attribute__((unused)) * txChanErrMsg [] =
        {
        "NO error",
        "SOP errpr",
        "Ownership bit not set in SOP buffer",
        "Zero next buffer descriptor pointer without EOP",
        "Zero buffer pointer",
        "Zero buffer length",
        "packet length error"
        };

    static char __attribute__((unused))  * rxChanErrMsg [] =
        {
        "NO error",
        "reserved",
        "Ownership bit not set in input buffer",
        "reserved",
        "Zero buffer pointer",
        "Zero buffer on non-SOP descriptor",
        "SOP buffer length not greater than offset"
        };

    /* get error code */

    val = CPDMA_REG_READ (pDev, CPDMA_DMASTATUS);
    rxErr  = CPDMA_RX_HOST_ERR_CODE(val);
    txErr  = CPDMA_TX_HOST_ERR_CODE(val);
    rxChan = CPDMA_RX_HOST_ERR_CHAN(val);
    txChan = CPDMA_TX_HOST_ERR_CHAN(val);

    /* log the error message */

    CPSW_DEBUG ("cpswEndErrHandle - error\n" \
                "rx chan = %d\nrx err code = %d (%s)\n" \
                "tx chan = %d\ntx err code = %d (%s)\n" \
                "reset hardware.\n",
                rxChan, rxErr, (_Vx_usr_arg_t)rxChanErrMsg [rxErr],
                txChan, txErr, (_Vx_usr_arg_t)txChanErrMsg [txErr]);

    /* dma errors require hardware reset to recover */

    if (cpswHostPortInit (pDev) != OK)
        return;

    if (pHost->ports[0])
        {
        if (cpswGmacPortInit (pHost->ports[0]) != OK)
            return;
        }

    if (pHost->ports[1])
        {
        if (cpswGmacPortInit (pHost->ports[1]) != OK)
            return;
        }

    if (cpdmaInit (pDev) != OK)
        return;

    for (i = 0; i < pHost->nrMacPorts; i++)
        {
        pMacCtrl = pHost->ports[i];

        for (cnt = 0; cnt < CPSW_DESC_CNT; cnt++)
            {
            pMacCtrl->cpswTxDescMem[cnt].link   = 0;
            pMacCtrl->cpswTxDescMem[cnt].buf    = 0;
            pMacCtrl->cpswTxDescMem[cnt].len    = 0;
            pMacCtrl->cpswTxDescMem[cnt].flags  = 0;

            if (pMacCtrl->cpswTxblk[pMacCtrl->cpswTxQHead])
                {
                vxbDmaBufMapUnload (pMacCtrl->cpswMblkTag,
                    pMacCtrl->cpswTxMblkMap[pMacCtrl->cpswTxQHead]);

                endPoolTupleFree (pMacCtrl->cpswTxblk[pMacCtrl->cpswTxQHead]);
                pMacCtrl->cpswTxblk[pMacCtrl->cpswTxQHead] = NULL;
                }
            }
        pMacCtrl->cpswTxQHead = CPSW_TXQ_INVALID;

        for (cnt = 0; cnt < CPSW_DESC_CNT; cnt++)
            {
            pMap = pMacCtrl->cpswRxMblkMap[cnt];

            vxbDmaBufMapUnload (pMacCtrl->cpswMblkTag, pMap);
            if (vxbDmaBufMapMblkLoad (pDev,
                            pMacCtrl->cpswMblkTag,
                            pMap, pMacCtrl->cpswRxblk[cnt], 0) != OK)
                goto mapFailed;

            desc = pMacCtrl->cpswRxDescMem + cnt;

            desc->buf    = (UINT32)pMap->fragList[0].frag;
            desc->len    = CPSW_MTU;
            desc->offset = 0;
            desc->flags  = CPSW_OWNERSHIP;
            }

        pMacCtrl->cpswRxIdx = 0;
        pMacCtrl->cpswTxFree = CPSW_DESC_CNT;
        pMacCtrl->cpswTxstall = FALSE;

        /* link all the RX descriptors, here we need physical address */

        desc = (CPSW_DESC *)(intptr_t)pMacCtrl->cpswRxDescMap->fragList[0].frag;
        for (cnt  = 0; cnt < CPSW_DESC_CNT - 1; cnt++)
            pMacCtrl->cpswRxDescMem[cnt].link = (UINT32)(desc + (cnt + 1));
        pMacCtrl->cpswRxDescTail = &pMacCtrl->cpswRxDescMem [CPSW_DESC_CNT - 1];

        /* reset the rx queue head */

        CPDMA_REG_WRITE (pDev, CPDMA_RX_FREEBUF(pMacCtrl->cpswRxDmaChan),
                        CPSW_DESC_CNT);
        CPDMA_REG_WRITE (pDev, CPDMA_RX_HDP(pMacCtrl->cpswRxDmaChan),
                        (UINT32)pMacCtrl->cpswRxDescMap->fragList[0].frag);

        /* enable interrupts */

        CPDMA_RX_INT_EN (pDev, pMacCtrl->cpswRxDmaChan);
        CPDMA_TX_INT_EN (pDev, pMacCtrl->cpswTxDmaChan);
        CSR_WRITE_4 (pDev, pHost->wrOffset + CPSW_WR_C0_TX_EN, 0xff);
        CSR_WRITE_4 (pDev, pHost->wrOffset + CPSW_WR_C0_TX_EN, 0xff);
        CSR_WRITE_4 (pDev, pHost->wrOffset + CPSW_WR_C0_MISC_EN, 0x1f);
        }

    CPDMA_HOSTERR_INT_EN (pDev);
    CPDMA_TX_EN (pDev);
    CPDMA_RX_EN (pDev);

    return;

mapFailed:
    for (i = 0; i < CPSW_DESC_CNT; i++)
        {
        if (pMacCtrl->cpswRxblk[i])
            endPoolTupleFree (pMacCtrl->cpswRxblk[i]);
        pMacCtrl->cpswRxblk[i] = NULL;
        }

    for (i = 0; i < CPSW_DESC_CNT; i++)
        vxbDmaBufMapUnload (pMacCtrl->cpswMblkTag, pMacCtrl->cpswRxMblkMap[i]);
    }

/*******************************************************************************
*
* cpswEndInt - handle device interrupts
*
* This function is invoked whenever the device's interrupt line is asserted
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void cpswEndInt
    (
    CPSW_HOST_CTRL * pHost
    )
    {
    VXB_DEVICE_ID pDev = pHost->pDev;

    /* disable interrupts */

    CPDMA_HOSTERR_INT_DIS (pDev);
    CPDMA_REG_WRITE (pDev, CPDMA_RX_INTMASK_CLR, 0xff);
    CPDMA_REG_WRITE (pDev, CPDMA_TX_INTMASK_CLR, 0xff);

    CSR_WRITE_4 (pDev, pHost->wrOffset + CPSW_WR_C0_TX_EN, 0x0);
    CSR_WRITE_4 (pDev, pHost->wrOffset + CPSW_WR_C0_RX_EN, 0x0);
    CSR_WRITE_4 (pDev, pHost->wrOffset + CPSW_WR_C0_MISC_EN, 0x0);

    /* ack the interrupts */

    CPDMA_REG_WRITE (pDev, CPDMA_DMA_EOI, 0x3);
    CPDMA_REG_WRITE (pDev, CPDMA_DMA_EOI, 0x2);
    CPDMA_REG_WRITE (pDev, CPDMA_DMA_EOI, 0x1);

    if (pHost->chipVersion == TIAM335X_DEV_ID && pHost->chipRevision == TI_CHIP_REV_1_0)
        {
        vxbWrite32 (CPSW_HANDLE(pDev), (UINT32 *)(GPTIMER5_BASE + GPTIMER_IRQ_STATUS),
                TCAR_IF_FLAG);

        vxbWrite32 (CPSW_HANDLE(pDev), (UINT32 *)(GPTIMER6_BASE + GPTIMER_IRQ_STATUS),
                TCAR_IF_FLAG);
        }

    if (vxAtomicCas (&pHost->cpswIntPending, FALSE, TRUE) == TRUE)
        {

        /* post the job */

        jobQueuePost (pHost->cpswJobQueue, &pHost->cpswQJob);
        }
    }

/*******************************************************************************
*
* cpswIntHandle - handle network events
*
* This routine handles network events (send, receive, err)
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void cpswIntHandle
    (
    void * pArg
    )
    {
    int i;
    QJOB * job = pArg;
    CPSW_HOST_CTRL * pHost = member_to_object (job, CPSW_HOST_CTRL, cpswQJob);
    VXB_DEVICE_ID pDev = pHost->pDev;
    UINT32 txSts, rxSts, errSts, rxErr, txErr;

    /* read interrupt status */

    errSts = CPDMA_REG_READ (pDev, CPDMA_DMASTATUS);
    rxSts  = CPDMA_REG_READ (pDev, CPDMA_RX_INTSTAT_RAW) & 0xff;
    txSts  = CPDMA_REG_READ (pDev, CPDMA_TX_INTSTAT_RAW) & 0xff;

    /* handle error first */

    rxErr = CPDMA_RX_HOST_ERR_CODE(errSts);
    txErr = CPDMA_TX_HOST_ERR_CODE(errSts);
    if (rxErr || txErr)
        {
        cpswEndErrHandle (pHost);
        }

    /* looking for rx events */

    for (i = 0; i < NR_DMA_CHANS; i++)
        {
        if (rxSts & (0x1 << i))
            {
            if (i == pHost->ports[0]->cpswRxDmaChan)
                cpswEndRxHandle (pHost->ports[0]);
            else if (pHost->ports[1] && (pHost->ports[1]->cpswRxDmaChan == i))
                cpswEndRxHandle (pHost->ports[1]);
            }
        }

    /* looking for tx events */

    for (i = 0; i < NR_DMA_CHANS; i++)
        {
        if (txSts & (0x1 << i))
            {
            if (i == pHost->ports[0]->cpswTxDmaChan)
                cpswEndTxHandle (pHost->ports[0]);
            else if (pHost->ports[1] && (pHost->ports[1]->cpswTxDmaChan == i))
                cpswEndTxHandle (pHost->ports[1]);
            }
        }

    errSts = CPDMA_REG_READ (pDev, CPDMA_DMASTATUS);
    rxSts  = CPDMA_REG_READ (pDev, CPDMA_RX_INTSTAT_RAW) & 0xff;
    txSts  = CPDMA_REG_READ (pDev, CPDMA_TX_INTSTAT_RAW) & 0xff;

    if ((errSts & ~0x80000000) || rxSts || txSts)
        {
        jobQueuePost (pHost->cpswJobQueue, &pHost->cpswQJob);
        return;
        }

    vxAtomicSet (&pHost->cpswIntPending, FALSE);

    CPDMA_HOSTERR_INT_EN (pDev);
    CPDMA_REG_WRITE (pDev, CPDMA_RX_INTMASK_SET, 0xff);
    CPDMA_REG_WRITE (pDev, CPDMA_TX_INTMASK_SET, 0xff);
    CSR_WRITE_4 (pDev, pHost->wrOffset + CPSW_WR_C0_TX_EN, 0xff);
    CSR_WRITE_4 (pDev, pHost->wrOffset + CPSW_WR_C0_RX_EN, 0xff);
    CSR_WRITE_4 (pDev, pHost->wrOffset + CPSW_WR_C0_MISC_EN, 0x1f);

    return;
    }

/*******************************************************************************
*
* cpswEndRxHandle - process received frames
*
* This function is scheduled by the ISR to run in the context of tNetTask
* whenever an RX interrupt is received. It processes packets from the
* RX window and encapsulates them into mBlk tuples which are handed up
* to the MUX.
*
* There may be several packets waiting in the window to be processed.
* We take care not to process too many packets in a single run through
* this function so as not to monopolize tNetTask and starve out other
* jobs waiting in the jobQueue. If we detect that there's still more
* packets waiting to be processed, we queue ourselves up for another
* round of processing.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void cpswEndRxHandle
    (
    CPSW_MAC_CTRL * pMacCtrl
    )
    {
    CPSW_HOST_CTRL * pHost = pMacCtrl->pHost;
    VXB_DEVICE_ID pDev = pHost->pDev;
    UINT32 inPktLen;
    CPSW_DESC * desc;
    VXB_DMA_MAP_ID pMap;
    M_BLK_ID blk = NULL;
    M_BLK_ID newblk;
    UINT32 val;
    int loopCounter = CPSW_DESC_CNT;
    int status;

    val = CPDMA_REG_READ (pDev, CPDMA_RX_CP(pMacCtrl->cpswRxDmaChan));
    CPDMA_REG_WRITE (pDev, CPDMA_RX_CP(pMacCtrl->cpswRxDmaChan), val);

    while (loopCounter--)
        {
        desc = &pMacCtrl->cpswRxDescMem[pMacCtrl->cpswRxIdx];
        if (desc->flags & CPSW_OWNERSHIP)
            {
            break;
            }

        inPktLen = desc->flags & CPSW_PKT_LEN_MASK;
        status = desc->flags & CPSW_EOQ;

        if ((desc->flags & CPSW_PKT_ERROR) || !inPktLen)
            {
            desc->len = CPSW_MTU;
            desc->offset = 0;
            desc->flags = CPSW_OWNERSHIP;
            pMacCtrl->cpswInDropped++;

            CPDMA_REG_WRITE (pDev,
                CPDMA_RX_CP(pMacCtrl->cpswRxDmaChan), desc->phys);

            CPSW_DESC_INC (pMacCtrl->cpswRxIdx, CPSW_DESC_CNT);

            goto addToTail;
            }

        newblk = endPoolTupleGet (pMacCtrl->cpswEndObj.pNetPool);
        if (!newblk)
            {
            pMacCtrl->cpswInDropped++;
            pMacCtrl->cpswLastError.errCode = END_ERR_NO_BUF;
            muxError (&pMacCtrl->cpswEndObj, &pMacCtrl->cpswLastError);

            desc->len = CPSW_MTU;
            desc->offset = 0;
            desc->flags = CPSW_OWNERSHIP;

            CPDMA_REG_WRITE (pDev,
                CPDMA_RX_CP(pMacCtrl->cpswRxDmaChan), desc->phys);

            CPSW_DESC_INC (pMacCtrl->cpswRxIdx, CPSW_DESC_CNT);

            goto addToTail;
            }

        blk  = pMacCtrl->cpswRxblk[pMacCtrl->cpswRxIdx];
        pMacCtrl->cpswRxblk[pMacCtrl->cpswRxIdx] = newblk;
        newblk->m_next = NULL;

        pMap = pMacCtrl->cpswRxMblkMap[pMacCtrl->cpswRxIdx];
        vxbDmaBufSync (pDev, pMacCtrl->cpswMblkTag,
            pMap, VXB_DMABUFSYNC_PREREAD);

        vxbDmaBufMapUnload (pMacCtrl->cpswMblkTag, pMap);

        if (vxbDmaBufMapMblkLoad (pDev, pMacCtrl->cpswMblkTag,
            pMap, newblk, 0) != OK)
            {
            /* if new mblk can't be mapped, then reset */

            cpswEndErrHandle (pHost);
            return;
            }

        if (desc->flags & CPSW_PASS_CRC)
            blk->m_len = blk->m_pkthdr.len = inPktLen - ETHER_CRC_LEN;
        else
            blk->m_len = blk->m_pkthdr.len = inPktLen;
        blk->m_flags = M_PKTHDR | M_EXT;

        CPDMA_REG_WRITE (pDev,
            CPDMA_RX_CP(pMacCtrl->cpswRxDmaChan), desc->phys);

        desc->buf = (UINT32)pMap->fragList[0].frag;
        desc->len = CPSW_MTU;
        desc->offset = 0;
        desc->flags = CPSW_OWNERSHIP;

        CPSW_DESC_INC (pMacCtrl->cpswRxIdx, CPSW_DESC_CNT);

addToTail:
        desc->link = 0;
        pMacCtrl->cpswRxDescTail->link = desc->phys;
        pMacCtrl->cpswRxDescTail = desc;

        desc = &pMacCtrl->cpswRxDescMem[pMacCtrl->cpswRxIdx];
        if (status)
            {
            CPDMA_REG_WRITE (pDev,
                CPDMA_RX_HDP(pMacCtrl->cpswRxDmaChan), desc->phys);
            }

        if (blk)
            END_RCV_RTN_CALL (&pMacCtrl->cpswEndObj, blk);
        }
    }

/*******************************************************************************
*
* cpswEndTxHandle - process TX completion events
*
* This function is scheduled by the ISR to run in the context of tNetTask
* whenever an TX interrupt is received. It runs through all of the
* TX register pairs and checks the TX status to see how many have
* completed. For each completed transmission, the associated TX mBlk
* is released, and the outbound packet stats are updated.
*
* If the transmitter has stalled, this routine will also call muxTxRestart()
* to drain any packets that may be waiting in the protocol send queues,
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void cpswEndTxHandle
    (
    CPSW_MAC_CTRL * pMacCtrl
    )
    {
    CPSW_HOST_CTRL * pHost = pMacCtrl->pHost;
    VXB_DEVICE_ID pDev = pHost->pDev;
    BOOL restart = FALSE;
    CPSW_DESC * desc;
    M_BLK_ID blk;
    VXB_DMA_MAP_ID pMap;

    END_TX_SEM_TAKE (&pMacCtrl->cpswEndObj, WAIT_FOREVER);

    if (pMacCtrl->cpswTxQHead == CPSW_TXQ_INVALID)
        {
        goto out;
        }

    pMap  = pMacCtrl->cpswTxDescMap;

    while (pMacCtrl->cpswTxFree < CPSW_DESC_CNT)
        {
        desc  = pMacCtrl->cpswTxDescMem + pMacCtrl->cpswTxQHead;
        if (desc->flags & CPSW_OWNERSHIP)
            {
            break;
            }

        if ((desc->flags & CPSW_EOQ) && (desc->link))
            {
            CPDMA_REG_WRITE (pDev,
                CPDMA_TX_HDP(pMacCtrl->cpswTxDmaChan), desc->link);
            }

        CPDMA_REG_WRITE (pDev,
            CPDMA_TX_CP(pMacCtrl->cpswTxDmaChan), desc->phys);

        blk = pMacCtrl->cpswTxblk[pMacCtrl->cpswTxQHead];
        if (blk)
            {
            vxbDmaBufMapUnload (pMacCtrl->cpswMblkTag,
                pMacCtrl->cpswTxMblkMap[pMacCtrl->cpswTxQHead]);
            endPoolTupleFree (blk);
            pMacCtrl->cpswTxblk[pMacCtrl->cpswTxQHead] = NULL;
            }
        pMacCtrl->cpswTxFree++;
        CPSW_DESC_INC (pMacCtrl->cpswTxQHead, CPSW_DESC_CNT);
        }
out:
    if (pMacCtrl->cpswTxstall == TRUE)
        {
        pMacCtrl->cpswTxstall = FALSE;
        restart = TRUE;
        }
    END_TX_SEM_GIVE (&pMacCtrl->cpswEndObj);

    if (restart == TRUE)
        muxTxRestart (pMacCtrl);
   }

/*******************************************************************************
*
* cpswEndEncap - encpswCapsulate an outbound packet in the TX ring
*
* This function transmits the packet specified in <pMblk>.
*
* RETURNS: EAGAIN if ring is full, otherwise OK.
*
* ERRNO: N/A
*/

LOCAL int cpswEndEncap
    (
    CPSW_MAC_CTRL * pMacCtrl,
    M_BLK_ID pMblk
    )
    {
    int i;
    CPSW_HOST_CTRL * pHost = pMacCtrl->pHost;
    VXB_DEVICE_ID pDev = pHost->pDev;
    CPSW_DESC * desc, * head, * prev = NULL;
    VXB_DMA_MAP_ID pMap;
    UINT32 headIndex;

    if (pMacCtrl->cpswTxFree == 0)
        {
        CPSW_DEBUG ("cpswEndEncap: warning - not enough tx descriptor!\n",
                     0,0,0,0,0,0);
        return EAGAIN;
        }

    pMap = pMacCtrl->cpswTxMblkMap[pMacCtrl->cpswTxIdx];

    if (vxbDmaBufMapMblkLoad
        (pDev, pMacCtrl->cpswMblkTag, pMap, pMblk, 0) != OK ||
        (pMap->nFrags > pMacCtrl->cpswTxFree))
        {
        vxbDmaBufMapUnload (pMacCtrl->cpswMblkTag, pMap);

        CPSW_DEBUG ("cpswEndEncap: warning - not enough tx descriptor!\n",
                     0,0,0,0,0,0);
        return ENOSPC;
        }

   pMacCtrl->cpswTxblk[pMacCtrl->cpswTxIdx] = pMblk;
   headIndex = pMacCtrl->cpswTxIdx;
   head = &pMacCtrl->cpswTxDescMem[headIndex];

   /* setup descriptors for all the segments */

   for (i = 0; i < pMap->nFrags; i++)
        {
        desc = &pMacCtrl->cpswTxDescMem[pMacCtrl->cpswTxIdx];

        desc->buf = (UINT32)pMap->fragList[i].frag;
        desc->offset = 0;

        /*
         * According to ethernet standard, minimum frame size is 64 bytes,
         * including packet data and FCS(frame check sequence).
         * When packet size + FCS(4bytes) is smaller than minimum frame size,
         * some padding bytes need to be added.
         * Here insure packet size is equal to or larger than 60 bytes.
         */

        desc->len =
            pMap->fragList[i].fragLen < CPSW_MIN_PKT_PADDING ? CPSW_MIN_PKT_PADDING : pMap->fragList[i].fragLen;
        desc->flags = CPSW_SOP | CPSW_EOP | CPSW_OWNERSHIP | CPSW_TO_PORT_EN |
            (pMacCtrl->portnr << CPSW_TO_PORT_SHIFT) | desc->len ;

        if (prev)
            prev->link = desc->phys;

        prev = desc;

        CPSW_DESC_INC (pMacCtrl->cpswTxIdx, CPSW_DESC_CNT);
        pMacCtrl->cpswTxFree--;
        }
    prev->link= 0;

    /* make sure data is coherent */

    (void) vxbDmaBufSync (pDev, pMacCtrl->cpswMblkTag,
                          pMap, VXB_DMABUFSYNC_POSTWRITE);

    /* if current tx queue is empty, trigger a new transfer */

    if (pMacCtrl->cpswTxQHead == CPSW_TXQ_INVALID)
        {
        pMacCtrl->cpswTxQHead = headIndex;
        CPDMA_REG_WRITE (pDev,
            CPDMA_TX_HDP(pMacCtrl->cpswTxDmaChan), head->phys);
        }

    /* else add the packet to current queue also detect mis queue event */

    else
        {
        prev = &pMacCtrl->cpswTxDescMem[headIndex == 0 ? \
            CPSW_DESC_CNT - 1 : headIndex - 1];
        prev->link = head->phys;

        if ((prev->flags & (CPSW_OWNERSHIP | CPSW_EOQ)) == CPSW_EOQ)
            {
            prev->flags &= ~CPSW_EOQ;
            CPDMA_REG_WRITE (pDev,
                CPDMA_TX_HDP(pMacCtrl->cpswTxDmaChan), head->phys);
            }
        }

    return OK;
    }

/*******************************************************************************
*
* cpswEndSend - transmit a packet
*
* This function transmits the packet specified in <pMblk>.
*
* RETURNS: OK, ERROR, or END_ERR_BLOCK.
*
* ERRNO: N/A
*/

LOCAL int cpswEndSend
    (
    END_OBJ * pEnd,
    M_BLK_ID  pMblk
    )
    {
    CPSW_MAC_CTRL * pMacCtrl;
    VXB_DEVICE_ID pDev;
    UINT32 rval;
    M_BLK_ID pTmp;

    pMacCtrl =(CPSW_MAC_CTRL *)pEnd;
    pDev = pMacCtrl->pHost->pDev;

    semTake (pMacCtrl->cpswMacSem, WAIT_FOREVER);

    END_TX_SEM_TAKE (pEnd, WAIT_FOREVER);

    if (pMacCtrl->cpswPolling == TRUE)
        {
        endPoolTupleFree (pMblk);
        END_TX_SEM_GIVE (pEnd);
        semGive (pMacCtrl->cpswMacSem);

        CPSW_DEBUG ("cpswEndSend: sending while in polling mode!\n"
                    ,0,0,0,0,0,0);
        return ERROR;
        }

    if (pMblk->m_next != NULL)
        {
        if ((pTmp = endPoolTupleGet (pMacCtrl->cpswEndObj.pNetPool)) == NULL)
            goto blocked;
        pTmp->m_len = pTmp->m_pkthdr.len =
            netMblkToBufCopy (pMblk, mtod(pTmp, char *), NULL);
        pTmp->m_flags = pMblk->m_flags;

        rval = cpswEndEncap(pMacCtrl, pTmp);
        if (rval == OK)
            endPoolTupleFree(pMblk);
        else
            endPoolTupleFree(pTmp);
        }
    else
        {
        rval = cpswEndEncap (pMacCtrl, pMblk);
        }

    if (rval != OK)
        {
        goto blocked;
        }

    END_TX_SEM_GIVE(pEnd);
    semGive (pMacCtrl->cpswMacSem);

    return (OK);

blocked:
    pMacCtrl->cpswTxstall = TRUE;
    END_TX_SEM_GIVE(pEnd);
    semGive (pMacCtrl->cpswMacSem);

    return (END_ERR_BLOCK);
    }

/*******************************************************************************
*
* cpswEndPollSend - polled mode transmit routine
*
* This function is similar to the cpswEndSend() routine shown above, except
* it performs transmissions synchronously with interrupts disabled. After
* the transmission is initiated, the routine will poll the state of the
* TX status register associated with the current slot until transmission
* completed.
*
* RETURNS: OK, EAGAIN, or ERROR
*
* ERRNO: N/A
*/

LOCAL STATUS cpswEndPollSend
    (
    END_OBJ * pEnd,
    M_BLK_ID  pMblk
    )
    {
    int i;
    M_BLK_ID blk;
    UINT32 ret;
    CPSW_MAC_CTRL * pMacCtrl = (CPSW_MAC_CTRL *)pEnd;
    CPSW_HOST_CTRL * pHost = pMacCtrl->pHost;
    VXB_DEVICE_ID pDev = pHost->pDev;
    CPSW_DESC * desc;

    if (pMacCtrl->cpswPolling == FALSE)
        return ERROR;

    blk = pMacCtrl->cpswPollbuf;
    blk->m_len = blk->m_pkthdr.len =
        netMblkToBufCopy (pMblk, mtod(blk, char *), NULL);
    blk->m_pkthdr.csum_flags = pMblk->m_pkthdr.csum_flags;
    blk->m_pkthdr.csum_data = pMblk->m_pkthdr.csum_data;
    blk->m_pkthdr.vlan = pMblk->m_pkthdr.vlan;

    if (cpswEndEncap (pMacCtrl, blk) != OK)
        {
        return EAGAIN;
        }

    for (i = 0; i < CPSW_TIMEOUT_VAL; i++)
        {
        ret = CPDMA_REG_READ (pDev,
            CPDMA_TX_HDP(pMacCtrl->cpswTxDmaChan));
        if (ret == 0)
            break;
        }

    if (i >= CPSW_TIMEOUT_VAL)
        CPSW_DEBUG ("cpswEndPollSend: error - timeout!\n",0,0,0,0,0,0);

    desc = &pMacCtrl->cpswTxDescMem[pMacCtrl->cpswTxQHead];
    blk = pMacCtrl->cpswTxblk[pMacCtrl->cpswTxQHead];
    if (blk)
        {
        vxbDmaBufMapUnload (pMacCtrl->cpswMblkTag,
            pMacCtrl->cpswTxMblkMap[pMacCtrl->cpswTxQHead]);
        pMacCtrl->cpswTxblk[pMacCtrl->cpswTxQHead] = NULL;
        }
    pMacCtrl->cpswTxFree++;

    CPDMA_REG_WRITE (pDev,
        CPDMA_TX_CP(pMacCtrl->cpswTxDmaChan), desc->phys);

    CPSW_DESC_INC (pMacCtrl->cpswTxQHead, CPSW_DESC_CNT);

    return OK;
    }

/*******************************************************************************
*
* cpswEndPollReceive - polled mode receive routine
*
* This function receives a packet in polled mode, with interrupts disabled.
* It's similar in operation to the cpswEndRxHandle() routine, except it
* doesn't process more than one packet at a time and does not load out
* buffers. Instead, the caller supplied an mBlk tuple into which this
* function will place the received packet.
*
* RETURNS: OK, or ERROR if operation failed.
*
* ERRNO: N/A
*/

LOCAL int cpswEndPollReceive
    (
    END_OBJ * pEnd,
    M_BLK_ID  pMblk
    )
    {
    CPSW_MAC_CTRL * pMacCtrl = (CPSW_MAC_CTRL *)pEnd;
    VXB_DEVICE_ID pDev = pMacCtrl->pHost->pDev;
    CPSW_DESC * desc;
    VXB_DMA_MAP_ID pMap;
    M_BLK_ID pPkt;
    UINT32 inPktLen;
    STATUS ret = OK;
    UINT32 val;
    UINT32 status;

    if (pMacCtrl->cpswPolling == FALSE)
        {
        return ERROR;
        }

    if (!(pMblk->m_flags & M_EXT))
        {
        return ERROR;
        }

    for (;;)
        {
        desc = &pMacCtrl->cpswRxDescMem[pMacCtrl->cpswRxIdx];
        _WRS_BARRIER("");
        if ((desc->flags & CPSW_OWNERSHIP) == 0x0)
            {
            val = CPDMA_REG_READ (pDev,
                CPDMA_RX_CP(pMacCtrl->cpswRxDmaChan));
            break;
            }
        }

    inPktLen = desc->flags & CPSW_PKT_LEN_MASK;
    status = desc->flags & CPSW_EOQ;
    if (!(desc->flags & CPSW_PKT_ERROR) && inPktLen)
        {
        pMap = pMacCtrl->cpswRxMblkMap[pMacCtrl->cpswRxIdx];
        pPkt = pMacCtrl->cpswRxblk[pMacCtrl->cpswRxIdx];
        vxbDmaBufSync (pDev, pMacCtrl->cpswMblkTag,
            pMap, VXB_DMABUFSYNC_PREREAD);
        if (desc->flags & CPSW_PASS_CRC)
            pMblk->m_len = pMblk->m_pkthdr.len = inPktLen - ETHER_CRC_LEN;
        else
            pMblk->m_len = pMblk->m_pkthdr.len = inPktLen;
        pMblk->m_flags |= M_PKTHDR;
        bcopy (mtod(pPkt, char *),  mtod(pMblk, char *), pMblk->m_len);
        }
    else
        {
        ret = ERROR;
        }

    CPDMA_REG_WRITE (pDev, CPDMA_RX_CP(pMacCtrl->cpswRxDmaChan), val);

    desc->len = CPSW_MTU;
    desc->offset = 0;
    desc->flags = CPSW_OWNERSHIP;

    CPSW_DESC_INC (pMacCtrl->cpswRxIdx, CPSW_DESC_CNT);

    desc->link = 0;
    pMacCtrl->cpswRxDescTail->link = desc->phys;
    pMacCtrl->cpswRxDescTail = desc;
    desc = &pMacCtrl->cpswRxDescMem[pMacCtrl->cpswRxIdx];
    if (status)
        {
        CPDMA_REG_WRITE (pDev,
            CPDMA_RX_HDP(pMacCtrl->cpswRxDmaChan), desc->phys);
        }

    return ret;
    }
