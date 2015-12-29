/* configNet.h - network configuration header for wrSbcPowerQuiccII */

/* Copyright 2003 Wind River Systems, Inc. */

/*
modification history
--------------------
01f,08aug03,scm  remove references to GEI for release...
01e,05aug03,scm  update to support basic PCI-to-PCI bridging...
01d,22may03,jb3  Add multiple motfcc to DevTbl.
01c,09may03,scm  add fei support...
01b,01may03,jb3  add multi FCC suport AGAIN!
01a,01apr03,j_b  adapted from wrSbc8260Atm (ver 01c).

*/

#ifndef __INCconfigNeth
#define __INCconfigNeth

#ifdef __cplusplus
    extern "C" {
#endif

#include "vxWorks.h"
#include "end.h"
#include "lstLib.h"

#include "config.h"

#ifdef INCLUDE_GRETH_END
# ifndef GRETH_MAC_ADDRESS
#  define GRETH_MAC_ADDRESS "0:0:7a:cc:0:14"
# endif
# include <drv/amba/gaisler/greth.h>      
#endif

#ifdef INCLUDE_LAN91C111_END

# include <drv/end/lan91c111End.h>
# define LAN91C111_BUFF_LOAN 1
# define LAN91C111_OFFSET "2"

/* Use PIO channel 1, for altera debug board */
/*#define LAN91C111_PIO 1*/

# ifndef LAN91C111_PIO
/* defaults to GR-CPCI-AT697
 * #define LAN91C111_INTVEC "0x14"
 * #define LAN91C111_INTLEVEL "4"
*/
#  define LAN91C111_PIO 4
# endif

# define LAN91C111_TOSTR(num) LAN91C111_TOSTR2(num)
# define LAN91C111_TOSTR2(num) #num

# define LAN91C111_INTLEVEL LAN91C111_TOSTR(LAN91C111_PIO)

# ifndef LAN91C111_IO_ADDR
/* default to GR-CPCI-AT697 address */
#  define LAN91C111_IO_ADDR "0x20000300"
# endif

/* Duplex config:
 *  0 = Default
 *  1 = auto detect
 *  2 = Full duplex
 *  3 = Half duplex 
 */ 
# ifndef LAN91C111_CFG_DUPLEX
#  define LAN91C111_CFG_DUPLEX 1
# endif

/* Speed config:
 *  0 = Default
 *  1 = 100Mbps
 *  2 = 10Mbps
 *  3 = auto detect
 */
# ifndef LAN91C111_CFG_SPEED
#  define LAN91C111_CFG_SPEED 3
# endif

# ifndef LAN91C111_CFG
#  if defined(LAN91C111_CFG_DUPLEX) && defined(LAN91C111_CFG_SPEED)
#   define LAN91C111_CFG "0x" LAN91C111_TOSTR(LAN91C111_CFG_SPEED) LAN91C111_TOSTR(LAN91C111_CFG_DUPLEX) "00"
#  else
    /* default to auto duplex & speed detect */
#   define LAN91C111_CFG "0x3100"
#  endif
# endif

# ifndef LAN91C111_HWADDR
#  define LAN91C111_HWADDR "0:0:7a:cc:0:15" 
/*"0:0:0:0:0:0"*/
# endif 

# define END_LAN91C111_LOAD_STRING  LAN91C111_IO_ADDR ":"\
																		LAN91C111_INTLEVEL ":" \
																		LAN91C111_OFFSET ":"\
																		LAN91C111_CFG ":" \
																		LAN91C111_HWADDR

#endif

/* End Driver Table */
END_TBL_ENTRY endDevTbl [] =
{
#if defined(INCLUDE_GRETH_END) 
    { 0, GRETH_LOAD_FUNC    		, GRETH_MAC_ADDRESS    	  , 1 									, NULL, FALSE},
#elif defined(INCLUDE_LAN91C111_END)
		{ 0, END_LAN91C111_LOAD_FUNC, END_LAN91C111_LOAD_STRING , LAN91C111_BUFF_LOAN , NULL, FALSE},
#endif
    { 0, END_TBL_END      , NULL               , 0, NULL, FALSE},
    
};

/* max number of SENS ipAttachments we can have */
#ifndef IP_MAX_UNITS
#define IP_MAX_UNITS (NELEMENTS (endDevTbl) - 1)
#endif

#ifdef __cplusplus
    }
#endif

#endif /* __INCconfigNeth */
