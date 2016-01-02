/* sysNvRam.c - x86 nvram api for block devices */

/*
 * Copyright (c) 2002, 2005-2007, 2009-2011 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify or otherwise make use
 * of this software may be licensed only pursuant to the terms
 * of an applicable Wind River license agreement.
 */

/*
modification history
--------------------
01j,15dec11,j_l  WIND00282406 - sysNvRamGet() needs a delay loop for
                 opening nvram.txt.
01i,22nov10,sye  fix permission issue of nvram file creating. (WIND00224991)
01h,05may09,jpb  Updated logMsg() agruments for LP64 support.
01g,28feb07,pgh  Fix WIND00078862
01f,18oct06,tor  Added lseek(offset) in set and get routines
01f,08aug06,dmh  respect value of offset parameter
01e,11aug05,pcm  corrected NVRAMFILE pathname
01d,29jul05,pcm  changed INCLUDE_DOSFS to INCLUDE_DOSFS_MAIN
01c,15jun05,pcm  dosFs is now removable
01b,18jul02,rhe  Remove possible compile time warning message. SPR 79857
01a,20jun02,dmh  created. now even without eeprom peecees have storage for the
                 bootline
*/

/*
DESCRIPTION:

This file implements the nvram api using standard io system calls
for non-volatile media such as flash ram, floppy disks and hard disk
drives.  It is primarily intended for saving and modifying boot parameters
but could in theory be used for general purpose information.  A file of
NV_RAM_SIZE size is used for storing the "nvram" data.
*/

/* includes */

#include <vxWorks.h>
#include <logLib.h>
#include <string.h>
#include "config.h"

/* defines */

/*
 * Allow for multiple attempts to load a file.
 * May have to wait for Filesystem to mount.
 */

#define NUMBER_OF_ATTEMPTS     2
#define DELAY_BETWEEN_ATTEMPTS (5*sysClkRateGet ())

#define NVRAMFILE  "/nvram.txt"
#define NVRAMPATH  "/mmc0:1" NVRAMFILE

/******************************************************************************
*
* sysNvRamGet - get the contents of non-volatile RAM
*
* This routine copies the contents of non-volatile memory into a specified
* string.  The string is terminated with an EOS.
*
* RETURNS: OK, or ERROR if access is outside the non-volatile RAM range.
*
* ERRNO: N/A
*
* SEE ALSO: sysNvRamSet()
*/

STATUS sysNvRamGet
    (
    char *string,    /* where to copy non-volatile RAM    */
    int strLen,      /* maximum number of bytes to copy   */
    int offset       /* byte offset into non-volatile RAM */
    )
    {
    int fd=ERROR, bytes;
    int unsuccessfulAttempts = 0;

    if ((offset < 0) || (strLen < 0) || ((offset + strLen) > NV_RAM_SIZE))
        return (ERROR);

    while ((fd == ERROR) && (unsuccessfulAttempts < NUMBER_OF_ATTEMPTS))
        {
        if ((fd = open (NVRAMPATH, O_RDWR, 0)) == ERROR)
            {
            if (++unsuccessfulAttempts < NUMBER_OF_ATTEMPTS)
                {
                logMsg ("sysNvRamGet: '%s' open failed.  Attempt %x of %x.\n",
                        (int)NVRAMPATH,
                        unsuccessfulAttempts,
                        NUMBER_OF_ATTEMPTS,
                        0, 0, 0);
                taskDelay (DELAY_BETWEEN_ATTEMPTS);
                }
            else
                {
                logMsg ("sysNvRamGet: '%s' open failed\n", (int)NVRAMPATH,
                        0, 0, 0, 0, 0);
                return (ERROR);
                }
            }
        }

    if (lseek (fd, offset, SEEK_SET) != offset)
        {
        close (fd);
        return (ERROR);
        }

    bytes = read (fd, string, strLen);
    if (bytes == ERROR)
        {
        logMsg ("sysNvRamGet: '%s' read failed\n", (int)NVRAMPATH,
                0, 0, 0, 0, 0);
        close (fd);
        return (ERROR);
        }
    else
        {
        string[bytes] = EOS;
        close (fd);
        return (OK);
        }
    }

/******************************************************************************
*
* sysNvRamSet - write to non-volatile RAM
*
* This routine copies a specified string into non-volatile RAM.
*
* RETURNS: OK, or ERROR if access is outside the non-volatile RAM range.
*
* ERRNO: N/A
*
* SEE ALSO: sysNvRamGet()
*/

STATUS sysNvRamSet
    (
    char *string,     /* string to be copied into non-volatile RAM */
    int strLen,       /* maximum number of bytes to copy           */
    int offset        /* byte offset into non-volatile RAM         */
    )
    {
    int fd;

    if ((offset < 0) || (strLen < 0) || ((offset + strLen) > NV_RAM_SIZE))
        return (ERROR);

    fd = open (NVRAMPATH, O_RDWR | O_CREAT, DEFFILEMODE);
    if (fd == ERROR)
        {
        logMsg ("sysNvRamSet: '%s' open failed\n", (int)NVRAMPATH,
                0, 0, 0, 0, 0);
        return (ERROR);
        }

    if (lseek (fd, offset, SEEK_SET) != offset)
        {
        close (fd);
        return (ERROR);
        }

    if (write (fd, string, strLen) != strLen)
        {
        logMsg ("sysNvRamSet: '%s' write failed\n", (int)NVRAMPATH,
                0, 0, 0, 0, 0);
        close (fd);
        return (ERROR);
        }
    else
        {
        close (fd);
        return (OK);
        }
    }