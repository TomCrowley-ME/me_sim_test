#ifndef DMOABDRIVER_H
#define DMOABDRIVER_H

#include <vxWorks.h>

#define BRE_VENDOR_ID   0x4252
#define DMOAB_DEVICE_ID 0x002A

/* PCI SRAM Memory Offsets */
#define DMOAB_SWDL1_T_BUFF 0x20000
#define DMOAB_SWDL2_T_BUFF 0x28000

/* PCI Register Offsets */
#define DMOAB_STATUS1       0x200200
#define DMOAB_STATUS2       0x200204
#define DMOAB_INT_ENABLE_1  0x200208
#define DMOAB_INT_PENDING_1 0x20020C
#define DMOAB_INT_ENABLE_2  0x200210
#define DMOAB_INT_PENDING_2 0x200214
#define DMOAB_SOH_WD_RESET  0x200400
#define DMOAB_TIMELW        0x200A00
#define DMOAB_TIMEUW        0x200A04
#define DMOAB_TIMEUW_SET    0x200A08
#define DMOAB_TLM_DLSND     0x200B00
#define DMOAB_TLM_COUNT     0x200B04
#define DMOAB_TLM_DLRATE    0x200B08

/* PCI Register Bitfield Definitions */
#define DMOAB_INT_1PPS (1 << 10)
#define DMOAB_INT_DWN2 (1 << 4)
#define DMOAB_INT_DWN1 (1 << 3)
#define DMOAB_INT_UP2R (1 << 2)
#define DMOAB_INT_UP1R (1 << 1)

STATUS dmoabInit(void);
STATUS dmoabEnableInterrupt(UINT32 intRegister, UINT32 intMask);
STATUS dmoabDisableInterrupt(UINT32 intRegister, UINT32 intMask);
void   dmoabInstall1HzISR(VOIDFUNCPTR isr);
STATUS dmoabGetTime(UINT32 *seconds, UINT32 *microseconds);
void   dmoabSetTime(UINT32 seconds);
UINT8  dmoabGetSCID(void);
STATUS dmoabSetDownlinkRate(UINT16 kbps);

#endif
