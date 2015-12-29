/* sysNet.h - system-dependent Network Header File */

/*
 * Copyright (c) 2010, 2012 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify or otherwise make use
 * of this software may be licensed only pursuant to the terms
 * of an applicable Wind River license agreement.
 */

/*
modification history
--------------------
01b,10jan12,my_  fix profile bootapp build error (WIND00326605)
01a,01nov10,hcl  written.
*/

#ifndef  __INCsysNeth
#define  __INCsysNeth

#ifdef __cplusplus
extern "C" {
#endif

#include <vxWorks.h>
#include "config.h"

extern const char * sysNetDevName[];

/* Prototypes */

int sysMacIndex2Dev (int index);
int sysMacIndex2Unit (int index);

STATUS sysMacOffsetGet (char * ifName, int ifUnit, char ** ppEnet,
            int * pOffset);
STATUS sysNetMacNVRamAddrGet (char * ifName, int ifUnit, UINT8 * ifMacAddr,
            int ifMacAddrLen);
STATUS sysNetMacAddrGet (char * ifName, int ifUnit, UINT8 * ifMacAddr,
            int ifMacAddrLen);
STATUS sysNetMacAddrSet (char * ifName, int ifUnit, UINT8 * ifMacAddr,
            int ifMacAddrLen);

#ifdef __cplusplus
}
#endif

#endif /* __INCsysNeth */
