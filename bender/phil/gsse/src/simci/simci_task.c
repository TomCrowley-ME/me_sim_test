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
#include "simci.h"

#include "cfe_error.h"
#include "cfe_evs.h"
#include "cfe_sb.h"
#include "cfe_es.h"

#include "network_includes.h"

#include "app_msgids.h"
#include "app_perfids.h"

#include <string.h>
#include <errno.h>

/*
** SimCI global data
*/

SIMCI_AppData_t SIMCI_AppData;

void SIMCI_TaskMain( void ) {
    int32  Status = CFE_SUCCESS;
    uint32 RunStatus = CFE_ES_APP_RUN;
    struct timeval tv_timeout;
    fd_set readfds;
    int32  max_fd;

    CFE_ES_PerfLogEntry(SIMCI_MAIN_TASK_PERF_ID);

    Status = SIMCI_TaskInit();
    if (Status != CFE_SUCCESS) {
        RunStatus = CFE_ES_APP_ERROR;
    }

    /* Set up information for select */
    max_fd = max(SIMCI_AppData.UplinkSocketID, SIMCI_AppData.IngestSocketID);
    max_fd++;

    tv_timeout.tv_sec = 0;
    tv_timeout.tv_usec = SIMCI_PERIOD_USEC;

    /* Runloop */
    while (CFE_ES_RunLoop(&RunStatus) == TRUE)
    {
        FD_ZERO(&readfds);

        FD_SET(SIMCI_AppData.UplinkSocketID, &readfds);
        FD_SET(SIMCI_AppData.IngestSocketID, &readfds);

        CFE_ES_PerfLogExit(SIMCI_MAIN_TASK_PERF_ID);

        /* Select on the two sockets + SB pipe */
        Status = select(max_fd, &readfds, NULL, NULL, &tv_timeout);

        CFE_ES_PerfLogEntry(SIMCI_MAIN_TASK_PERF_ID);

        if (Status == 0) {
            /* Timed out, process some commands if available */
            uint32 i;

            for (i = 0; i < SIMCI_PIPE_DEPTH; i++) {
                Status = CFE_SB_RcvMsg(&SIMCI_AppData.MsgPtr, SIMCI_AppData.CommandPipe, CFE_SB_POLL);
                if (Status == CFE_SUCCESS) {
                    /* We have a message to process */
                    SIMCI_AppPipe();
                } else if (Status == CFE_SB_NO_MESSAGE) {
                    /* Nothing to do, go back to sleep */
                    break;
                } else {
                    SIMCI_AppData.HkPacket.error_count++;
                    CFE_EVS_SendEvent(SIMCI_PIPE_ERR_EID, CFE_EVS_ERROR, "SIMCI: Error reading command pipe, RC=%08X", Status);
                }
            }
        } else {
            if (FD_ISSET(SIMCI_AppData.UplinkSocketID, &readfds)) {
                SIMCI_ForwardUplinkPacket();
            }
            if (FD_ISSET(SIMCI_AppData.IngestSocketID, &readfds)) {
                SIMCI_IngestPacket();
            }
        }
    }
    CFE_ES_ExitApp(RunStatus);

}

void SIMCI_DeleteCallback(void) {
    OS_printf("SIMCI delete callback -- Closing SIMCI Network sockets.\n");
    close(SIMCI_AppData.UplinkSocketID);
    close(SIMCI_AppData.IngestSocketID);
}

int32 SIMCI_TaskInit(void) {
    int32 Status = CFE_SUCCESS;

    CFE_ES_RegisterApp();

    SIMCI_AppData.CommandPipe = 0;
    SIMCI_AppData.MsgPtr = NULL;
    SIMCI_AppData.UplinkSocketID = 0;
    SIMCI_AppData.IngestSocketID = 0;
    SIMCI_AppData.UplinkSocketConnected = FALSE;
    SIMCI_AppData.IngestSocketConnected = FALSE;

    /* Set up and register events */
    SIMCI_AppData.EventFilters[0].EventID = SIMCI_COMMANDRST_INF_EID;
    SIMCI_AppData.EventFilters[0].Mask    = CFE_EVS_NO_FILTER;
    SIMCI_AppData.EventFilters[1].EventID = SIMCI_UPLINK_ERR_EID;
    SIMCI_AppData.EventFilters[1].Mask    = CFE_EVS_NO_FILTER;
    SIMCI_AppData.EventFilters[2].EventID = SIMCI_INGEST_ERR_EID;
    SIMCI_AppData.EventFilters[2].Mask    = CFE_EVS_NO_FILTER;
    SIMCI_AppData.EventFilters[3].EventID = SIMCI_CRCMDPIPE_ERR_EID;
    SIMCI_AppData.EventFilters[3].Mask    = CFE_EVS_NO_FILTER;
    SIMCI_AppData.EventFilters[4].EventID = SIMCI_SOCKETCREATE_ERR_EID;
    SIMCI_AppData.EventFilters[4].Mask    = CFE_EVS_NO_FILTER;
    SIMCI_AppData.EventFilters[5].EventID = SIMCI_SOCKETBIND_ERR_EID;
    SIMCI_AppData.EventFilters[5].Mask    = CFE_EVS_NO_FILTER;
    SIMCI_AppData.EventFilters[6].EventID = SIMCI_MSGID_ERR_EID;
    SIMCI_AppData.EventFilters[6].Mask    = CFE_EVS_NO_FILTER;
    SIMCI_AppData.EventFilters[7].EventID = SIMCI_CC1_ERR_EID;
    SIMCI_AppData.EventFilters[7].Mask    = CFE_EVS_NO_FILTER;

    CFE_EVS_Register(SIMCI_AppData.EventFilters, SIMCI_FILTERED_EVT_COUNT, CFE_EVS_BINARY_FILTER);
    if (Status != CFE_SUCCESS) {
        CFE_ES_WriteToSysLog("SIMCI: Error registering events, RC = 0x%08X\n", Status);
        return Status;
    }

    /* Initialize Housekeeping */
    CFE_SB_InitMsg(&SIMCI_AppData.HkPacket, SIMCI_HK_TLM_MID, sizeof(SIMCI_HkPacket_t), TRUE);
    SIMCI_ResetCounters();
    SIMCI_AppData.HkPacket.ingest_socket_connected = FALSE;
    SIMCI_AppData.HkPacket.uplink_socket_connected = FALSE;

    /* Create a command pipe and subscribe to its messages */
    Status =  CFE_SB_CreatePipe(&SIMCI_AppData.CommandPipe, SIMCI_PIPE_DEPTH, "SIMCI_CMD_PIPE");
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(SIMCI_CRCMDPIPE_ERR_EID, CFE_EVS_ERROR, "SIMCI: Can't create command pipe, RC=%08X", Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(SIMCI_CMD_MID, SIMCI_AppData.CommandPipe);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(SIMCI_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "SIMCI: Error subscribing to SIMCI_CMD_MID(0x%04X), RC=%08X", SIMCI_CMD_MID, Status);
        return Status;
    }
    Status = CFE_SB_Subscribe(SIMCI_SEND_HK_MID, SIMCI_AppData.CommandPipe);
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(SIMCI_SUBSCRIBE_ERR_EID, CFE_EVS_ERROR, "SIMCI: Error subscribing to SIMCI_SEND_HK_MID(0x%04X), RC=%08X", SIMCI_SEND_HK_MID, Status);
        return Status;
    }

    /* Set up Uplink socket */
    SIMCI_AppData.UplinkSocketID = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (SIMCI_AppData.UplinkSocketID < 0) {
        CFE_EVS_SendEvent(SIMCI_SOCKETCREATE_ERR_EID, CFE_EVS_ERROR, "SIMCI: Error creating uplink socket, errno=%08X", errno);
        return ERROR;
    } else {
        struct sockaddr_in socket_address;
        CFE_PSP_MemSet((void*)&socket_address, 0, sizeof(socket_address));

        socket_address.sin_family      = AF_INET;
        socket_address.sin_addr.s_addr = htonl(INADDR_ANY);
        socket_address.sin_port        = htons(SIMCI_UPLINK_PORT);

        Status = bind(SIMCI_AppData.UplinkSocketID, (struct sockaddr *)&socket_address, sizeof(socket_address));
        if (Status == ERROR) {
            CFE_EVS_SendEvent(SIMCI_SOCKETBIND_ERR_EID, CFE_EVS_ERROR, "SIMCI: Error binding uplink socket, errno=%08X", errno);
            return Status;
        } else {
            SIMCI_AppData.UplinkSocketConnected = TRUE;
        }
    }

    /* Set up Ingest socket */
    SIMCI_AppData.IngestSocketID = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (SIMCI_AppData.IngestSocketID < 0) {
        CFE_EVS_SendEvent(SIMCI_SOCKETCREATE_ERR_EID, CFE_EVS_ERROR, "SIMCI: Error creating ingest socket, errno=%08X", errno);
        return ERROR;
    } else {
        struct sockaddr_in socket_address;
        CFE_PSP_MemSet((void*)&socket_address, 0, sizeof(socket_address));

        socket_address.sin_family      = AF_INET;
        socket_address.sin_addr.s_addr = htonl(INADDR_ANY);
        socket_address.sin_port        = htons(SIMCI_INGEST_PORT);

        Status = bind(SIMCI_AppData.IngestSocketID, (struct sockaddr *)&socket_address, sizeof(socket_address));
        if (Status == ERROR) {
            CFE_EVS_SendEvent(SIMCI_SOCKETBIND_ERR_EID, CFE_EVS_ERROR, "SIMCI: Error binding ingest socket, errno=%08X", errno);
            return Status;
        } else {
            SIMCI_AppData.IngestSocketConnected = TRUE;
        }
    }

    Status = SIMCI_HWIF_Init();
    if (Status != CFE_SUCCESS) {
        CFE_EVS_SendEvent(SIMCI_HWIF_ERR_EID, CFE_EVS_ERROR, "Error initializing HWIF, RC=0x%08X", Status);
        return Status;
    }

    /* Install the delete handler */
    OS_TaskInstallDeleteHandler((void*)&SIMCI_DeleteCallback);

    CFE_EVS_SendEvent(SIMCI_STARTUP_INF_EID, CFE_EVS_INFORMATION, "SIMCI App Initialized");
    return CFE_SUCCESS;
}

void SIMCI_AppPipe(void) {
    CFE_SB_MsgId_t  MsgId;
    MsgId = CFE_SB_GetMsgId(SIMCI_AppData.MsgPtr);

    switch (MsgId)
    {
        case SIMCI_CMD_MID:
            SIMCI_ProcessGroundCommand();
            break;

        case SIMCI_SEND_HK_MID:
            SIMCI_ReportHousekeeping();
            break;

        default:
            SIMCI_AppData.HkPacket.error_count++;
            CFE_EVS_SendEvent(SIMCI_MSGID_ERR_EID, CFE_EVS_ERROR, "SIMCI: received invalid MID=0x%08X", MsgId);
            break;
    }
}

void SIMCI_ProcessGroundCommand(void) {
    uint16 CommandCode;

    CommandCode = CFE_SB_GetCmdCode(SIMCI_AppData.MsgPtr);

    switch (CommandCode)
    {
        case SIMCI_NOOP_CC:
            SIMCI_AppData.HkPacket.command_count++;
            CFE_EVS_SendEvent(SIMCI_NOOP_INF_EID, CFE_EVS_INFORMATION, "SIMCI: NOOP command");
            break;

        case SIMCI_RESETCTRS_CC:
            SIMCI_ResetCounters();
            CFE_EVS_SendEvent(SIMCI_COMMANDRST_INF_EID,CFE_EVS_INFORMATION, "SIMCI: RESET command");
            break;

        default:
            SIMCI_AppData.HkPacket.error_count++;
            CFE_EVS_SendEvent(SIMCI_CC1_ERR_EID, CFE_EVS_ERROR, "SIMCI: received invalid command code, CC=%02u", CommandCode);
            break;
    }
}

void SIMCI_ReportHousekeeping(void) {
    SIMCI_AppData.HkPacket.uplink_socket_connected = SIMCI_AppData.UplinkSocketConnected;
    SIMCI_AppData.HkPacket.ingest_socket_connected = SIMCI_AppData.IngestSocketConnected;

    CFE_SB_TimeStampMsg((CFE_SB_MsgPtr_t)&SIMCI_AppData.HkPacket);
    CFE_SB_SendMsg((CFE_SB_MsgPtr_t)&SIMCI_AppData.HkPacket);
}

void SIMCI_ResetCounters(void) {
    SIMCI_AppData.HkPacket.command_count = 0;
    SIMCI_AppData.HkPacket.error_count = 0;
    SIMCI_AppData.HkPacket.uplink_packets = 0;
    SIMCI_AppData.HkPacket.ingest_packets = 0;
    SIMCI_AppData.HkPacket.uplink_errors = 0;
    SIMCI_AppData.HkPacket.ingest_errors = 0;
}

void SIMCI_IngestPacket(void) {
    int32 bytes_received;
    uint8 buffer[SIMCI_MAX_INGEST];

    bytes_received = recvfrom(SIMCI_AppData.IngestSocketID, buffer, SIMCI_MAX_INGEST, MSG_DONTWAIT, 0, 0);

    if (bytes_received == ERROR) {
        SIMCI_AppData.HkPacket.ingest_errors++;
        CFE_EVS_SendEvent(SIMCI_INGEST_ERR_EID, CFE_EVS_ERROR, "SIMCI: Error receiving from ingest socket, errno=0x%08X", errno);
    } else if (bytes_received <= SIMCI_MAX_INGEST) {
        CFE_ES_PerfLogEntry(SIMCI_INGEST_RCV_PERF_ID);
        SIMCI_AppData.HkPacket.ingest_packets++;

        /* Send the prepared command out to SB */
        CFE_SB_SendMsg((CFE_SB_MsgPtr_t)buffer);

        CFE_ES_PerfLogExit(SIMCI_INGEST_RCV_PERF_ID);
    } else {
        SIMCI_AppData.HkPacket.ingest_errors++;
        CFE_EVS_SendEvent(SIMCI_INGEST_ERR_EID, CFE_EVS_ERROR, "SIMCI: Dropped problematically lengthy ingest frame of %u bytes", bytes_received);
    }
}
