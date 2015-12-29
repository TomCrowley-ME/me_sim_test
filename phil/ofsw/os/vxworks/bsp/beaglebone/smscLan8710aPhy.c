/* smscLan8710aPhy.c - Support routines for the SMSC LAN8710A PHY on the BeagleBone */
#include <vxWorks.h>
#include <mii/miiBus.h>
#include "smscLan8710aPhy.h"

#undef SMSC_LAN8710A_DEBUG
#ifdef SMSC_LAN8710A_DEBUG

IMPORT FUNCPTR _func_logMsg;

#   define SMSC_LAN8710A_LOG(fmt,a,b,c,d,e,f)  \
        if (_func_logMsg != NULL) \
            (* _func_logMsg)(fmt,a,b,c,d,e,f)
#else
#   define SMSC_LAN8710A_LOG(fmt,a,b,c,d,e,f)
#endif


STATUS smscLan8710aPhyInit(void) {
    VXB_DEVICE_ID pDev;
    unsigned short ctrl;
    unsigned short mode;

    /*
     * All beaglebone revisions A6 and earlier have a hardware bug related to the
     * PHY -- its MODE pins are set up such that it starts up in 100BaseTX mode
     * without auto-negotiation enabled. To get around this, we need to manually
     * set the mode
     */

    pDev = vxbInstByNameFind("genericPhy",0);
    if (pDev == NULL) {
        SMSC_LAN8710A_LOG("Cannot get the PHY instance\n", 0, 0, 0, 0, 0, 0);
        return ERROR;
    }

    /* Read in the special modes register and set the needed mode bits */
    miiBusRead(pDev, 0, LAN8710A_MODE, &mode);
    if ((mode & LAN8710A_MODE_MASK) == LAN8710A_MODE_ALL_CAPABLE) {
        SMSC_LAN8710A_LOG("PHY already in correct mode\n", 0, 0, 0, 0, 0, 0);
        return OK;
    }

    mode |= LAN8710A_MODE_ALL_CAPABLE;
    miiBusWrite(pDev, 0, LAN8710A_MODE, mode);

    /* Now that we're in the correct mode, restart auto-negotiation */
    miiBusRead(pDev, 0, LAN8710A_CTRL, &ctrl);
    ctrl |= LAN8710A_CTRL_ANEG_RESTART;
    miiBusWrite(pDev, 0, LAN8710A_CTRL, ctrl);

    return OK;
}
