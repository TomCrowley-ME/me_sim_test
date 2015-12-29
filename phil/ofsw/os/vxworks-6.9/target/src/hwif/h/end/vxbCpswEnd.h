/* vxbCpswEnd.h - TI 3 port switch VxBus END driver header file */

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
17mar14,g_x  add cpswMiiPhyAddr to the driver control structure.
01h,26sep13,xms  Handle adding multicast address. (WIND00434181)
01g,18sep13,xms  Fix frame padding issue. (WIND00431862)
01f,12aug13,c_l  Add 10M support for am335x. (WIND00407010)
01e,24oct12,my_  hw errata workarounds for am335x
01d,12sep12,my_  add port vlan definitions
01c,20may12,my_  add support for am335x
01b.08mar12,my_  fix rx misqueue handling
01a,01aug11,my_  written
*/

#ifndef __INCvxbCpswEndh
#define __INCvxbCpswEndh

#ifdef __cplusplus
extern "C" {
#endif

#define CPSW_NAME                    "cpsw"

#define TI814X_DEV_ID                0xb8f2
#define TIAM335X_DEV_ID              0xb944

#define TI_CHIP_REV_1_0              0
#define TI_CHIP_REV_2_0              1

/* global settings */

#define CPSW_DESC_CNT                (128)
#define NR_MAC_PORTS                 (2)
#define NR_DMA_CHANS                 (8)
#define NR_HDP                       (8)
#define CPSW_MTU                     (1522)
#define CPSW_TIMEOUT_VAL             (0x0fffffff)
#define CPSW_TXQ_INVALID             (0xffffffff)

/* BD descriptions */

#define CPSW_SOP                     (0x80000000)
#define CPSW_EOP                     (0x40000000)
#define CPSW_OWNERSHIP               (0x20000000)
#define CPSW_EOQ                     (0x10000000)
#define CPSW_TO_PORT_EN              (0x100000)
#define CPSW_TO_PORT_SHIFT           (16)
#define CPSW_DESC_ALIGNMENT          (4096)
#define CPSW_TO_PORT_EN              (0x100000)
#define CPSW_PASS_CRC                (0x4000000)
#define CPSW_PKT_LEN_MASK            (0x7ff)
#define OVERSIZE                     (0x01000000)
#define JABBER                       (0x02000000)
#define MAC_CTL                      (0x00800000)
#define OVERRUN                      (0x00400000)
#define PKT_ERROR                    (0x00300000)
#define CPSW_PKT_ERROR               (OVERSIZE | JABBER | MAC_CTL | OVERRUN | PKT_ERROR)
#define CPSW_MIN_PKT_PADDING         (60)

/* MDIO register offset and bit definitions */

#define CPSW_MDIO_CONTROL            (0x4)
#define CPSW_USERACCESSn(n)          (0x80 + (n) * 0x8)
#define CPSW_MDIO_CLK_DIV            (0xff)
#define CPSW_MDIO_EN                 (0x40000000)
#define CPSW_MDIO_GO                 (0x80000000)
#define CPSW_MDIO_WRITE              (0x40000000)
#define CPSW_MDIO_ACK                (0x20000000)
#define CPSW_PHY_ADDR_SHIFT          (16)
#define CPSW_REG_ADDR_SHIFT          (21)

/* global register offset and bit definitions */

#define CPSW_ID_VER                  (0x0)
#define CPSW_CONTROL                 (0x4)
#define CPSW_SOFT_RESET              (0x8)
#define CPSW_STAT_PORT_EN            (0xC)

/* host/gmac port*/

#define CPSW_MAX_BLKS                (0x0)
#define CPSW_BLK_CNT                 (0x4)
#define CPSW_TX_IN_CTL               (0x8)
#define CPSW_PORT_VLAN               (0xc)
#define CPSW_TX_PRI_MAP              (0x10)
#define CPSW_CPDMA_TX_PRI_MAP        (0x14)
#define CPDMA_RX_CH_MAP              (0x18)
#define CPSW_SL_SA_L0                (0x20)
#define CPSW_SL_SA_HI                (0x24)

#define CPSW_GMII_EN                 (0x20)
#define GMAC_CTL_FULLDUPLEX          (0x1)
#define GAMC_CTL_GIG                 (0x80)
#define CPSW_TX_PRI_MAP_DFTL         (0x33221100)
#define CPDMA_TX_PRI_MAP_DFTL        (0x76543210)
#define CPSW_TX_IN_SEL_MSK           (0x3)
#define CPSW_TX_IN_SEL_SHIFT         (16)
#define CPSW_TX_FIFO_DUAL_EMAC       (0x1)
#define CPSW_EXT_EN                  (0x40000)

#define CPSW_DEFAULT_PORT1_VID       (1)
#define CPSW_DEFAULT_PORT2_VID       (2)
#define CPSW_DEFAULT_PORT_CFI        (0)
#define CPSW_DEFAULT_PORT_PRI        (0)

#define CPSW_DEFAULT_PORT1_VLAN       ((CPSW_DEFAULT_PORT_CFI << 12) | \
                                      (CPSW_DEFAULT_PORT_PRI << 13) | \
                                      (CPSW_DEFAULT_PORT1_VID))

#define CPSW_DEFAULT_PORT2_VLAN       ((CPSW_DEFAULT_PORT_CFI << 12) | \
                                      (CPSW_DEFAULT_PORT_PRI << 13) | \
                                      (CPSW_DEFAULT_PORT2_VID))

/* CPDMA register offset */

#define CPDMA_TX_IDVER               (0x00)
#define CPDMA_RX_IDVER               (0x10)
#define CPDMA_DMACONTROL             (0x20)
#define CPDMA_DMASTATUS              (0x24)
#define CPDMA_TX_INTMASK_SET         (0x88)
#define CPDMA_TX_INTMASK_CLR         (0x8C)
#define CPDMA_RX_INTMASK_SET         (0xA8)
#define CPDMA_RX_INTMASK_CLR         (0xAC)
#define CPDMA_INTMASK_SET            (0xB8)
#define CPDMA_INTMASK_CLR            (0xBC)
#define CPDMA_TX_INTSTAT_RAW         (0x80)
#define CPDMA_TX_INTSTAT_MASKED      (0x84)
#define CPDMA_RX_INTSTAT_RAW         (0xA0)
#define CPDMA_RX_INTSTAT_MASKED      (0xA4)
#define CPDMA_DMA_INTSTAT_RAW        (0xB0)
#define CPDMA_DMA_INTSTAT_MASKED     (0xB4)
#define CPDMA_DMA_EOI                (0x94)
#define CPDMA_TX_CONTROL             (0x04)
#define CPDMA_RX_CONTROL             (0x14)
#define CPDMA_TX_TEARDOWN            (0x08)
#define CPDMA_RX_TEARDOWN            (0x18)
#define CPDMA_SOFT_RESET             (0x1C)
#define CPDMA_RX_BUFOFFSET           (0x28)
#define CPDMA_RX_FREEBUF(n)          (0x0E0 + (n) * 0x4)

#define CPDMA_TX_HDP(n)              (cpdmaHDPoffset + 0x00 + (n) * 0x4)
#define CPDMA_RX_HDP(n)              (cpdmaHDPoffset + 0x20 + (n) * 0x4)
#define CPDMA_TX_CP(n)               (cpdmaHDPoffset + 0x40 + (n) * 0x4)
#define CPDMA_RX_CP(n)               (cpdmaHDPoffset + 0x60 + (n) * 0x4)

#define CPDMA_TX_RR                  (0x0)
#define CPDMA_TX_FIXED               (0x1)
#define CPDMA_RX_OWNERSHIP           (0x0)
#define CPDMA_CONTROL_DEFAULT        (0x0)

/* ALE register offset */

#define CPSW_ALE_TBLCTL              (0x20)
#define CPSW_ALE_WORD0               (0x3C)
#define CPSW_ALE_WORD1               (0x38)
#define CPSW_ALE_WORD2               (0x34)
#define CPSW_ALE_CONTROL             (0x08)
#define CPSW_ALE_UNKNOWN_VLAN        (0x18)
#define CPSW_ALE_PORTCTL(n)          (0x40 + (n) * 0x4)
#define CPSW_ALE_ENTRY_IDX_MASK      (0x3ff)
#define CPSW_ALE_ENTRY_NR            (1024)
#define CPSW_ALE_PORT_FW             (0x3)
#define CPSW_ALE_MULTICAST           (0x10000000)
#define CPSW_ALE_MULTICAST_FW        (0x40000000)
#define CPSW_ALE_SUPER               (0x2)
#define CPSW_ALE_ENTRY_MASK          (0x30000000)
#define CPSW_ALE_BLOCK               (0x2)
#define CPSW_ALE_SECURE              (0x1)
#define CPSW_ALE_UNICAST             (0x10000000)
#define CPSW_ALE_VLAN                (0x20000000)
#define CPSW_ALE_UNICAST_AGEABLE_NOT (0x0)
#define CPSW_ALE_UNICAST_AGEABLE     (0x4)
#define CPSW_ALE_BYPASS              (0x10)
#define CPSW_ALE_CTL_NO_LEARN        (0x10)
#define CPSW_ALE_CLR_TABLE           (0x40000000)
#define CPSW_ALE_EN_TABLE            (0x80000000)
#define CPSW_ALE_VLAN_AWARE          (0x4)
#define CPSW_ALE_WRITE               (0x80000000)
#define CPSW_ALE_ENRY_MASK           (0x3ff)

/* GMAC register offset and bit definitions */

#define CPGMAC_ID                    (0x00)
#define CPSW_SL_MAC_CTL              (0x04)
#define CPSW_SL_MAC_SOFT_RESET       (0x0C)
#define CPSW_SL_RX_MAXLEN            (0x10)
#define CPSW_SL_RX_PRI_MAP           (0x24)
#define CPSW_SL_RX_PRI_MAP_VAL       (0x12345678)

/* CPSW_WR register definitions */

#define CPSW_WR_IDVER                (0x0)
#define CPSW_WR_SOFTRESET            (0x04)
#define CPSW_WR_CONTROL              (0x08)
#define CPSW_WR_INTCONTROL           (0x0C)
#define CPSW_WR_C0_THRESH_EN         (0x10)
#define CPSW_WR_C0_RX_EN             (0x14)
#define CPSW_WR_C0_TX_EN             (0x18)
#define CPSW_WR_C0_MISC_EN           (0x1C)
#define CPSW_WR_C0_RX_IMAX           (0x70)
#define CPSW_WR_C0_TX_IMAX           (0x74)

/* statistics register offset and bit definitions */

#define CPSW_STAT_GOOD_RX            (0x00)
#define CPSW_STAT_RX_MUTICAST        (0x08)
#define CPSW_STAT_RX_BROADCAST       (0x0C)
#define CPSW_STAT_CRC_ERR            (0x10)
#define CPSW_STAT_AGLIEN_ERR         (0x14)
#define CPSW_STAT_OVER_ERR           (0x18)
#define CPSW_STAT_JABBER_ERR         (0x1C)
#define CPSW_STAT_UNDER_ERR          (0x20)
#define CPSW_STAT_RXOCTETS           (0x30)
#define CPSW_SATA_GOOD_TX            (0x34)
#define CPSW_STAT_TX_MUTICAST        (0x38)
#define CPSW_STAT_TX_BROADCAST       (0x3C)
#define CPSW_STAT_TX_PAUSE           (0x40)
#define CPSW_STAT_TX_DEFER           (0x44)
#define CPSW_STAT_TX_COLLISIONS      (0x48)
#define CPSW_STAT_TX_UNDERRUN        (0x5C)
#define CPSW_STAT_TX_CSE             (0x60)
#define CPSW_STAT_TXOCTETS           (0x64)

/* multicast forward state definitions */

#define CPSW_ALE_MCAST_FWD                (0)
#define CPSW_ALE_MCAST_BLOCK_LEARN_FWD    (1)
#define CPSW_ALE_MCAST_FWD_LEARN          (2)
#define CPSW_ALE_MCAST_FWD_2              (3)

/* multicast super packet definitions */

#define CPSW_ALE_MCAST_SUPER              (1)
#define CPSW_ALE_MCAST_NOT_SUPER          (0)

/* table entry type definitions */

#define CPSW_ALE_TYPE_FREE                (0)
#define CPSW_ALE_TYPE_ADDR                (1)
#define CPSW_ALE_TYPE_VLAN                (2)
#define CPSW_ALE_TYPE_VLAN_ADDR           (3)

/* workarounds for am335x */

#define GPTIMER5_BASE                (0x48046000)
#define GPTIMER6_BASE                (0x48048000)
#define GPTIMER_IRQ_STATUS           (0x28)
#define TCAR_IF_FLAG                 (0x1 << 2)

typedef struct cpsw_desc             CPSW_DESC;
typedef struct cpsw_drv_ctrl         CPSW_MAC_CTRL;
typedef struct cpsw_host_ctrl        CPSW_HOST_CTRL;

typedef struct cpsw_gmac_res
{
    UINT32              portOffset;
    UINT32              gmacOffset;
    int                 portnr;
}CPSW_GMAC_REGS;

struct cpsw_desc
    {
    /* hardware required fields */

    UINT32              link;
    UINT32              buf;
    UINT16              len;
    UINT16              offset;
    UINT32              flags;

    /*
     * Software pointers. We also add paddings to
     * make sure that every descriptor start
     * on 32 byte boundary.
     */
    UINT32              phys;
    UINT32              pad[3];
    };

typedef struct cpswAleTbl
    {
    UINT32 word0;
    UINT32 word1;
    UINT8  word2;
    } CPSW_ALE_TBL;

typedef struct cpsw_hw_statistics
    {
    /* rx hw statitics */

    UINT32 rxgood;
    UINT32 rxbroadcast;
    UINT32 rxmulticast;
    UINT32 rxpause;
    UINT32 rxcrcerros;
    UINT32 rxalignmenterrors;
    UINT32 rxoversized;
    UINT32 rxjabber;
    UINT32 rxundersized;
    UINT32 rxfrags;
    UINT32 unused0;
    UINT32 unused1;
    UINT32 rxoctets;

    /* tx hw statitics */

    UINT32 txgood;
    UINT32 txbroadcast;
    UINT32 txmulticast;
    UINT32 txpause;
    UINT32 txdefered;
    UINT32 txcollision;
    UINT32 txsinglecol;
    UINT32 txmulticol;
    UINT32 txexceesive;
    UINT32 txlatecol;
    UINT32 txunderrun;
    UINT32 txcariersense;
    UINT32 txoctets;

    UINT32 sz64octets;
    UINT32 sz65_127octets;
    UINT32 sz128_255octets;
    UINT32 sz256_511octets;
    UINT32 sz512_1023octets;
    UINT32 sz1024octets;

    UINT32 netoctets;
    UINT32 rxfifooverrun[3];
    } CPSW_STAT;

struct cpsw_drv_ctrl
    {
    END_OBJ            cpswEndObj;
    CPSW_HOST_CTRL *   pHost;
    UINT32             portOffset;
    UINT32             gmacOffset;

    unsigned char      macaddr[ETHER_ADDR_LEN];
    int                cpswMtu;
    int                index;
    int                portnr;
    int                portVlan;
    int                cpswRxDmaChan;
    int                cpswTxDmaChan;
    SEM_ID             cpswMacSem;

    VXB_DMA_TAG_ID     cpswParentTag;
    VXB_DMA_TAG_ID     cpswTxDescTag;
    VXB_DMA_MAP_ID     cpswTxDescMap;
    CPSW_DESC      *   cpswTxDescMem;

    UINT32             cpswTxQHead;
    UINT32             cpswTxIdx;
    UINT32             cpswTxFree;

    VXB_DMA_TAG_ID     cpswRxDescTag;
    VXB_DMA_MAP_ID     cpswRxDescMap;
    CPSW_DESC      *   cpswRxDescMem;
    UINT32             cpswRxIdx;
    CPSW_DESC      *   cpswRxDescTail;

    VXB_DMA_MAP_ID     cpswRxMblkMap[CPSW_DESC_CNT];
    VXB_DMA_MAP_ID     cpswTxMblkMap[CPSW_DESC_CNT];
    VXB_DMA_TAG_ID     cpswMblkTag;

    M_BLK_ID           cpswRxblk[CPSW_DESC_CNT];
    M_BLK_ID           cpswTxblk[CPSW_DESC_CNT];

    VXB_DEVICE_ID      cpswMiiParent;
    VXB_DEVICE_ID      cpswMiiBus;
    END_MEDIALIST  *   cpswMediaList;
    UINT32             cpswCurMedia;
    UINT32             cpswCurStatus;
    END_CAPABILITIES   cpswCaps;
    UINT32             cpswMiiPhyAddr;

    BOOL               cpswTxstall;
    BOOL               cpswPolling;
    M_BLK_ID           cpswPollbuf;

    END_ERR            cpswLastError;
    END_IFDRVCONF      cpswStatsConf;
    END_IFCOUNTERS     cpswStatsCounters;

    endCounter         cpswInDropped;
    void           *   cookie;
    };

struct cpsw_host_ctrl
    {
    VXB_DEVICE_ID      pDev;
    SEM_ID             cpswHostSem;
    unsigned char      cpswRxDmaChans[NR_DMA_CHANS];
    unsigned char      cpswTxDmaChans[NR_DMA_CHANS];
    CPSW_MAC_CTRL *    ports[NR_MAC_PORTS];
    void          *    handle;

    UINT32             chipVersion;
    UINT32             chipRevision;

    BOOL               dualEmac;
    int                portnr;
    spinlockIsr_t      aleLock;

    /* various sub-component register offsets */

    int                nrMacPorts;
    int                nrActivePorts;
    void          *    regBase;
    UINT32             portOffset;
    UINT32             cpdmaOffset;
    UINT32             cpdamHDPOffset;
    UINT32             statsOffset;
    UINT32             aleOffset;
    UINT32             mdioOffset;
    UINT32             wrOffset;

    JOB_QUEUE_ID       cpswJobQueue;
    QJOB               cpswQJob;
    atomic_t           cpswIntPending;

    CPSW_STAT          cpswStat;
    };

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __INCvxbCpswEndh */
