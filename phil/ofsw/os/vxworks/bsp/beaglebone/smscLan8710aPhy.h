/* smscLan8701aPhy.h - SMSC LAN8710A PHY register definitions */

#ifndef __INCsmscLan8710aPhyh
#define __INCsmscLan8710aPhyh

/* Basic control register */
#define LAN8710A_CTRL     0x00

#define LAN8710A_CTRL_ANEG_RESTART  0x0200 /* Restart the auto-negotiation process */

/* Special modes register */
#define LAN8710A_MODE     0x12

#define LAN8710A_MODE_MASK          0x00e0 /* Mask of the MODE bits in the mode register */
#define LAN8710A_MODE_ALL_CAPABLE   0x00e0 /* All-capable, autonegotiation enabled */

#endif
