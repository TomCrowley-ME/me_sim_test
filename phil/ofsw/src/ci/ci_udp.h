/*
**
**   Name:     ci_udp.h
**   Purpose: This file contains all of the data structures and defines
**            for Command Ingest interfaces to the data system.
**            This file is organized into major sections.
**            1. Defines
**            2. Command Ingest Structure Typedefs
**            3. Command Ingest Telemetry Packet Definitions
**
**
** $Date  $
** $Revision  $
** $Log  $
**   Modification History:
**        04/02/90            A. Cudmore, NASA/GSFC 735.3
**             - Include file written
**
**        04/12/94            A. Cudmore, NASA/GSFC 735.3
**             - Added a tlm point for counting aborted transfer
**               frames.
**
**        12/10/1996          E. Stagmer, Litton Amecom
**             - added conditional compilation define REDUNDANT_TRANSPONDERS
**
**        12/30/1998          J. Pepoy, ATSC
**             - modify ci_special_cmd_type structure to conform to MAP structure
**
**        May-9-2004          E.Yeheskeli
**             - modified for SDO and new SB inteface
**
**   Assumptions and External Effects:
**        i. The include file types.h must be included before this file
**           is included.
**
**        iii. The structures are organized to work with CCSDS packets
**            that are stored as arrays of unigned short integers.
**            An array of bytes would not map to these CCSDS structures.
**            All structures are designed to be in multiples of 16 bits.
**
*/

/****************************************************************************/

/*
** Ensure that header is included only once...
*/

#ifndef _ci_udp_
#define _ci_udp_

/*
** Required header files...
*/
#include "network_includes.h"
#include "common_types.h"
#include "cfe_error.h"
#include "cfe_evs.h"
#include "cfe_sb.h"
#include "cfe_es.h"

#include "osapi.h"
#include "ccsds.h"

#include "app_msgids.h"

#include <string.h>
#include <errno.h>

/****************************************************************************/

/*
** Event message ID's...
*/
#define CI_RESERVED_EID                    0

#define CI_STARTUP_INF_EID                 3    /* start up message "informational"  */

#define CI_COMMANDNOP_INF_EID              5    /* processed command "informational" */
#define CI_COMMANDRST_INF_EID              6
#define CI_INGEST_INF_EID                  7

#define CI_SOCKETCREATE_ERR_EID            1    /* invalid command packet "error"    */
#define CI_SOCKETBIND_ERR_EID              2
#define CI_COMMAND_ERR_EID                 4
#define CI_INGEST_ERR_EID                  8

#define cfgCI_PORT                      1234
#define CI_MAX_INGEST                    256
#define CI_PIPE_DEPTH                     32

/*
** CI command packet command codes...
*/
#define CI_NO_OPERATION_CC                 1
#define CI_RESET_COUNTERS_CC               3

/****************************************************************************/

/*
**  Command Ingest Structure Typedefs
*/
typedef struct {

    CFE_SB_TlmHdr_t    TlmHeader;
    uint8              ci_command_error_count;
    uint8              ci_command_count;
    uint8              ci_xsums_enabled;
    uint8              spare[1];
    uint32             IngestPackets;
    uint32             IngestErrors;
    uint8              SocketConnected;
    uint8              unused[3];

}   OS_PACK ci_hk_tlm_t  ;

#define CI_HK_TLM_LNGTH           sizeof ( ci_hk_tlm_t )

/****************************************************************************/

/*
** Local function prototypes...
**
** Note: Except for the entry point (CI_TaskMain), these
**       functions are not called from any other source module.
*/
void CI_TaskMain(void);
void CI_TaskInit(void);
void CI_ProcessCommandPacket(void);
void CI_ProcessGroundCommand(void);
void CI_ReportHousekeeping(void);
void CI_ResetCounters(void);
void CI_ReadUpLink(void);


#endif /* _ci_udp_ */
