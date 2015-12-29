/**************************************************************************
* Copyright 2010 - 2015 Moon Express, Inc.
* All Rights Reserved.
*
* PROPRIETARY DATA NOTICE:
* The data herein include Proprietary Data and are restricted under the
* Data Rights provisions of Lunar CATALYST Space Act Agreement
* No. SAAM ID# 18251 and Reimbursable Space Act Agreement No.SAA2-402930.
* All information contained herein is and remains proprietary to and the
* property of Moon Express, Inc. Dissemination of this information or
* reproduction of this material is strictly forbidden unless prior
* written permission is obtained from Moon Express, Inc.
**************************************************************************/
#ifndef SIMCI_H
#define SIMCI_H

#include "cfe_sb.h"
#include "cfe_evs.h"

/*
** Event message ID's
*/
#define SIMCI_STARTUP_INF_EID                 0
#define SIMCI_NOOP_INF_EID                    1
#define SIMCI_COMMANDRST_INF_EID              2

#define SIMCI_SOCKETCREATE_ERR_EID           20
#define SIMCI_SOCKETBIND_ERR_EID             21
#define SIMCI_CRCMDPIPE_ERR_EID              22
#define SIMCI_MSGID_ERR_EID                  23
#define SIMCI_CC1_ERR_EID                    24
#define SIMCI_UPLINK_ERR_EID                 25
#define SIMCI_INGEST_ERR_EID                 26
#define SIMCI_UPLINKDEV_ERR_EID              27
#define SIMCI_SUBSCRIBE_ERR_EID              28
#define SIMCI_PIPE_ERR_EID                   29
#define SIMCI_HWIF_ERR_EID                   30

#define SIMCI_FILTERED_EVT_COUNT              8

/*
** SimCI Configuration Parameters
*/
#define SIMCI_UPLINK_PORT                  1234
#define SIMCI_INGEST_PORT                  1235
#define SIMCI_MAX_INGEST                   1186
#define SIMCI_PIPE_DEPTH                      4
#define SIMCI_PERIOD_USEC                500000

/*
** SimCI command packet command codes
*/
#define SIMCI_NOOP_CC                          0
#define SIMCI_RESETCTRS_CC                     1

/****************************************************************************/

/*
**  SimCI Structure Typedefs
*/
typedef struct {
    CFE_SB_TlmHdr_t    TlmHeader;
    uint8              command_count;
    uint8              error_count;
    uint8              uplink_socket_connected;
    uint8              ingest_socket_connected;
    uint32             uplink_packets;
    uint32             ingest_packets;
    uint32             uplink_errors;
    uint32             ingest_errors;
}   OS_PACK SIMCI_HkPacket_t;

typedef struct {
    CFE_SB_PipeId_t    CommandPipe;

    CFE_SB_MsgPtr_t    MsgPtr;
    SIMCI_HkPacket_t   HkPacket;

    int32              UplinkSocketID;
    int32              IngestSocketID;

    boolean            UplinkSocketConnected;
    boolean            IngestSocketConnected;

    CFE_EVS_BinFilter_t EventFilters[SIMCI_FILTERED_EVT_COUNT];
} SIMCI_AppData_t;

/****************************************************************************/

/*
** Local function prototypes
*/
void  SIMCI_TaskMain(void);
int32 SIMCI_TaskInit(void);
int32 SIMCI_HWIF_Init(void);
void  SIMCI_AppPipe(void);
void  SIMCI_ProcessGroundCommand(void);
void  SIMCI_ReportHousekeeping(void);
void  SIMCI_ResetCounters(void);
void  SIMCI_ForwardUplinkPacket(void);
void  SIMCI_IngestPacket(void);

/*
** Global data
*/
extern SIMCI_AppData_t SIMCI_AppData;

#endif /* SIMCI_H */
