/* sysNet.c - system-dependent network library */

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
01b,17aug12,my_  use sysNvRamGet/Set instead of sysFlashGet/Set
01a,10may12,my_  written from ti_dm81xx_evm 01b
*/

/*
DESCRIPTION

This module provides BSP functionality to support the
bootrom 'M' command to modify MAC addresses of on-board
network interfaces.

MAC address routines provided by the BSP in this file are:
    sysNetMacNVRamAddrGet()
    sysNetMacAddrGet()
    sysNetMacAddrSet()

This board provides storage in flash for the MAC addresses of the tiemac
interface.  This library also implements a RAM buffer to represent the
contents of the flash. The RAM buffer contains eight entries, which is more
than currently needed by this board, but can be considered as room for
expansion in future boards using a derivative of this BSP.  This RAM buffer is
contained in the array glbEnetAddr[][].
*/

#include <vxWorks.h>
#include <stdio.h>
#include <string.h>
#include "config.h"
#include "sysNet.h"

/* Globals */

const char * sysNetDevName[MAX_MAC_DEVS] = {"cpsw", "cpsw"};

/* Locals */

LOCAL UINT8 glbEnetAddr[MAX_MAC_ADRS][MAC_ADRS_LEN] =
    {
    { WR_ENET0, WR_ENET1, WR_ENET2, CUST_ENET3, CUST_ENET4, CUST_ENET5},
    { WR_ENET0, WR_ENET1, WR_ENET2, CUST_ENET3, CUST_ENET4, CUST_ENET5 + 2},
    };

/* externs */

extern STATUS sysNvRamSet (char *, int, int);
extern STATUS sysNvRamGet (char *, int, int);

/*******************************************************************************
*
* sysMACAddrROMRead - get mac address from rom.
*
* This function reads the mac address of ROM.
*
* mac address buffer(ifMacAddr value) setting example.
* When Mac Address 00:11:22:33:44:55 :
*  ifMacAddr[0] = 0x00
*  ifMacAddr[1] = 0x11
*  ifMacAddr[2] = 0x22
*  ifMacAddr[3] = 0x33
*  ifMacAddr[4] = 0x44
*  ifMacAddr[5] = 0x55
*
* RETURNS: OK or ERROR
*/

STATUS sysMACAddrROMRead
    (
    int     ifUnit,
    UINT8 * ifMacAddr
    )
    {
    unsigned int idLo, idHi;

    if (ifUnit == 0)
        {
        idLo = am335xInLong (AM335X_MACID0_LO);
        idHi = am335xInLong (AM335X_MACID0_HI);
        }
    else if (ifUnit == 1)
        {
        idLo = am335xInLong (AM335X_MACID1_LO);
        idHi = am335xInLong (AM335X_MACID1_HI);
        }
    else
        return ERROR;

    ifMacAddr[0] = (idHi & 0xff);
    ifMacAddr[1] = ((idHi & 0xff00) >> 8);
    ifMacAddr[2] = ((idHi & 0xff0000) >> 16);
    ifMacAddr[3] = ((idHi & 0xff000000) >> 24);
    ifMacAddr[4] = (idLo & 0xff);
    ifMacAddr[5] = ((idLo & 0xff00) >> 8); 

    /* 
     * beacuse cpemac has two ethernet ports, but the two mac address 
     * register locations will return the same value, if we want to use 
     * dual emac mode, then we have to have two different mac
     * addresses, so add 1 here.
     */

    if (ifUnit == 1)
        ifMacAddr[5]++;

    return OK;
    }

/*******************************************************************************
*
* sysMacOffsetGet - calculate table offset
*
* This routine calculates which table entry corresponds to
* the specified interface.
*
* Two values are calculated and returned in the parameters
* pointed to by ppEnet and pOffset.
*
* RETURNS: ERROR if the interface is not known; OK otherwise
*
* ERRNO: OK, always
*/

STATUS sysMacOffsetGet
    (
    char *  ifName,     /* interface name */
    int     ifUnit,     /* interface unit */
    char ** ppEnet,     /* pointer to glbEnetAddr[][] entry */
    int *   pOffset     /* offset in NVRAM */
    )
    {
    int ret;

    if ((ifUnit < 0) || (ifUnit >= MAX_MAC_DEVS))
        return (ERROR);

    ret = strcmp (ifName, sysNetDevName[ifUnit]);

    if (ret == 0)
        {
        *pOffset = ifUnit * MAC_ADRS_LEN;
        *ppEnet  = (char*)glbEnetAddr[ifUnit];

        return (OK);
        }

    return (ERROR);
    }

/*******************************************************************************
*
* sysNetMacNVRamAddrGet - get interface MAC address
*
* This routine gets the current MAC address from the
* Non Volatile RAM, and store it in the ifMacAddr
* buffer provided by the caller.
*
* It is not required for the BSP to provide NVRAM to store
* the MAC address.  Also, some interfaces do not allow
* the MAC address to be set by software.  In either of
* these cases, this routine simply returns ERROR.
*
* Given a MAC address m0:m1:m2:m3:m4:m5, the byte order
* of ifMacAddr is:
* m0 @ ifMacAddr
* m1 @ ifMacAddr + 1
* m2 @ ifMacAddr + 2
* m3 @ ifMacAddr + 3
* m4 @ ifMacAddr + 4
* m5 @ ifMacAddr + 5
*
* RETURNS: OK if MAC address available, ERROR otherwise
*
* ERRNO: N/A
*/

STATUS sysNetMacNVRamAddrGet
    (
    char *  ifName,
    int     ifUnit,
    UINT8 * ifMacAddr,
    int     ifMacAddrLen
    )
    {
    /* get mac address from rom */

    return sysMACAddrROMRead(ifUnit, ifMacAddr);
    }

/*******************************************************************************
*
* sysNetMacAddrGet - get interface MAC address
*
* This routine gets the current MAC address from the
* network interface, and stores it in the ifMacAddr
* buffer provided by the caller.
*
* If the network interface cannot be queried about the
* MAC address, this routine returns ERROR.
*
* RETURNS: ERROR
*
* ERRNO: N/A
*/

STATUS sysNetMacAddrGet
    (
    char *  ifName,
    int     ifUnit,
    UINT8 * ifMacAddr,
    int     ifMacAddrLen
    )
    {
    /*
     * None of our interfaces can be queried directly.
     * Return ERROR to indicate that we need to use
     * RAM/NVRAM instead.
     */

    return (ERROR);
    }

/*******************************************************************************
*
* sysNetMacAddrSet - save interface MAC address
*
* This routine saves the MAC address specified in
* ifMacAddr to the appropriate location in NVRam (if
* possible) and update the specified interface to use
* the specified MAC address.
*
* If the network interface MAC address cannot be set,
* this routine returns ERROR.
*
* RETURNS: OK if MAC address is set, ERROR otherwise
*
* ERRNO: N/A
*/

STATUS sysNetMacAddrSet
    (
    char *  ifName,
    int     ifUnit,
    UINT8 * ifMacAddr,
    int     ifMacAddrLen
    )
    {
    int    offset;
    char * pEnet;
    STATUS retval;

    /* fetch address line & offset from glbEnetAddr[] table */

    if (sysMacOffsetGet (ifName, ifUnit, &pEnet, &offset) != OK )
        return (ERROR);

    retval = sysNvRamSet ((char *)ifMacAddr, ifMacAddrLen,
                    (NV_MAC_ADRS_OFFSET + (MAC_ADRS_LEN * ifUnit)));

    return (retval);
    }

/*******************************************************************************
*
* sysMacIndex2Dev - convert index range to device string
*
* This routine converts an index range 0..MAX_MAC_ADRS-1
* to a device string index e.g. motfcc.
*
* RETURNS: index access device name in sysNetDevName
*
* ERRNO: N/A
*/

int sysMacIndex2Dev
    (
    int index
    )
    {
    return (0);
    }

/*******************************************************************************
*
* sysMacIndex2Unit - convert index range to unit number
*
* This routine converts an index range 0..MAX_MAC_ADRS-1
* to a unit number.
*
* RETURNS: index
*
* ERRNO: N/A
*/

int sysMacIndex2Unit
    (
    int index
    )
    {
    return (index);
    }

#undef  ENET_MAC_DEBUG
#ifdef  ENET_MAC_DEBUG
/*******************************************************************************
*
* sysNetMacAddrClear - clear MAC address in FLASH/NVRAM
*
* This routine clears the storage locations in NVRAM
* reserved for the MAC address of the specified interface.
*
* This is useful for debugging the 'M' command.  To use
* this, boot vxWorks and run sysNetMacAddrClear() from
* the shell. After running this command, you can test
* the bootrom 'M' command under conditions similar to a
* new, unprogrammed board.
*
* RETURNS: OK, if MAC address available, ERROR otherwise
*
* ERRNO: N/A
*/

STATUS sysNetMacAddrClear
    (
    char * ifName,
    int    ifUnit
    )
    {
    UINT8  ifMacAddr[6] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
    int    offset;
    char * pEnet;
    STATUS retval;

    if (sysMacOffsetGet (ifName, ifUnit, &pEnet, &offset) != OK)
        return (ERROR);

    retval = sysNaRamSet ((char *)ifMacAddr, MAC_ADRS_LEN,
                    (NV_MAC_ADRS_OFFSET + (MAC_ADRS_LEN * ifUnit)));

    memcpy (ifMacAddr, pEnet, 6);

    return (retval);
    }
#endif /* ENET_MAC_DEBUG */

/*******************************************************************************
*
* sysEnetAddrGet - get ethernet mac address
*
* This routine is used to get mac address from NVRAM for the EMAC.
*
* RETURNS: OK
*
* ERRNO: N/A
*/

STATUS sysEnetAddrGet
    (
    UINT32  unit,
    UINT8 * pAddr
    )
    {
    STATUS retval;

    printf ("sysEnetAddrGet : unit 0x%x.\n", unit);

    retval = sysNetMacNVRamAddrGet ("cpsw", unit, pAddr, MAC_ADRS_LEN);

    return retval;
    }
