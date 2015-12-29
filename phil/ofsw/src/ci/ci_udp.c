/******************************************************************************************
** File: ci_udp.c
** $Id: ci_udp.c 1.3 2008/08/01 20:56:02BST apcudmore Exp  $
**
** Purpose:
**   This file contains the source code for the Command Ingest task.
**
** $Date: 2008/08/01 20:56:02BST $
** $Revision: 1.3 $
** $Log: citask.c  $
** Revision 1.3 2008/08/01 20:56:02BST apcudmore
** updated debug code for startup sync tests
** Revision 1.2 2008/07/30 14:51:07EDT apcudmore
** Added CFE_ES_RunLoop call to CI
** Revision 1.1 2008/04/17 08:02:35EDT ruperera
** Initial revision
** Member added to project c:/MKSDATA/MKS-REPOSITORY/MKS-CFE-PROJECT/fsw/cfe-apps/ci/project.pj
** Revision 1.15 2008/02/14 13:18:43EST apcudmore
** Added task delete callbacks for CI and TO. If CI and TO get killed, the network
** socket will be closed.
** Revision 1.14 2006/06/21 13:10:18EDT kkaudra
** Removed cfe_es_perf.h
** Revision 1.13 2006/06/20 13:42:50EDT rjmcgraw
** Added performance markers
** Revision 1.12 2006/03/03 16:28:39GMT apcudmore
** Created conditional compilation for systems that dont have the fcntl function
** Revision 1.11 2006/03/03 15:11:04GMT apcudmore
** Fixed non-blocking socket problem with CI
** Revision 1.10 2006/02/10 22:41:05GMT kkaudra
** CI Clean-up
** Revision 1.9 2005/11/17 10:11:39EST rjmcgraw
** Renamed CI cmd pipe
**
*******************************************************************************************/

/*
**   Include Files:
*/

#include "ci_udp.h"
#include "app_perfids.h"

/*
** CI global data...
*/

struct sockaddr_in CI_SocketAddress;
uint8              CI_IngestBuffer[CI_MAX_INGEST];
boolean            CI_SocketConnected = FALSE;
ci_hk_tlm_t        CI_HkTelemetryPkt;
CFE_SB_PipeId_t    CI_CommandPipe;
CFE_SB_Msg_t      *CIMsgPtr;
int                CI_SocketID;
CFE_SB_Msg_t       *CI_IngestPointer   = (CFE_SB_Msg_t *) &CI_IngestBuffer[0];

static CFE_EVS_BinFilter_t  CI_EventFilters[] =
          {  /* Event ID    mask */
            {CI_SOCKETCREATE_ERR_EID,  0x0000},
            {CI_SOCKETBIND_ERR_EID,    0x0000},
            {CI_STARTUP_INF_EID,       0x0000},
            {CI_COMMAND_ERR_EID,       0x0000},
            {CI_COMMANDNOP_INF_EID,    0x0000},
            {CI_COMMANDRST_INF_EID,    0x0000},
            {CI_INGEST_INF_EID,        0x0000},
            {CI_INGEST_ERR_EID,        0x0000}
          };

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* CI_TaskMain() -- Application entry point and main process loop                       */
/* Purpose: This is the Main task event loop for the Command Ingest Task                 */
/*            The task handles all interfaces to the data system through                 */
/*            the software bus. There is one pipeline into this task                     */
/*            The task is sceduled by input into this pipeline.                          */
/*            It can receive Commands, or Codeblocks over this pipeline                  */
/*            and acts accordingly to process them.                                      */
/*                                                                                       */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  * *  * * * * * * * * * * */

void CI_TaskMain( void )
{
    int32   status;
    uint32  RunStatus = CFE_ES_APP_RUN;

    CFE_ES_PerfLogEntry(CI_MAIN_TASK_PERF_ID);

    CI_TaskInit();

#ifdef _CI_DELAY_TEST
    OS_printf("CI going to delay for 40 seconds before calling runloop\n");
    OS_TaskDelay(40000);
#endif

    /*
    ** CI Runloop
    */
    while (CFE_ES_RunLoop(&RunStatus) == TRUE)
    {
        CFE_ES_PerfLogExit(CI_MAIN_TASK_PERF_ID);

        /* Pend on receipt of command packet -- timeout set to 500 millisecs */
        status = CFE_SB_RcvMsg(&CIMsgPtr, CI_CommandPipe, 500);
        CFE_ES_PerfLogEntry(CI_MAIN_TASK_PERF_ID);

        if (status == CFE_SUCCESS)
        {
            CI_ProcessCommandPacket();
        }

        /* Regardless of packet vs timeout, always process uplink queue      */
        if (CI_SocketConnected)
        {
            CI_ReadUpLink();
        }
    }
    CFE_ES_ExitApp(RunStatus);

} /* End of CI_TaskMain() */
/*
** CI delete callback function.
** This function will be called in the event that the CI app is killed.
** It will close the network socket for CI
*/
void CI_delete_callback(void)
{
    OS_printf("CI delete callback -- Closing CI Network socket.\n");
    close(CI_SocketID);
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                                       */
/* CI_TaskInit() -- CI initialization                                                    */
/*                                                                                       */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

void CI_TaskInit(void)
{
    CFE_ES_RegisterApp() ;

    CFE_EVS_Register(CI_EventFilters,
                     sizeof(CI_EventFilters)/sizeof(CFE_EVS_BinFilter_t),
                     CFE_EVS_BINARY_FILTER);

    CFE_SB_CreatePipe(&CI_CommandPipe, CI_PIPE_DEPTH,"CI_CMD_PIPE");
    CFE_SB_Subscribe(CI_CMD_MID, CI_CommandPipe);
    CFE_SB_Subscribe(CI_SEND_HK_MID, CI_CommandPipe);

    if ( (CI_SocketID = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0)
    {
        CFE_EVS_SendEvent(CI_SOCKETCREATE_ERR_EID,CFE_EVS_ERROR,"CI: create socket failed = %d", errno);
    }
    else
    {
       bzero((char *) &CI_SocketAddress, sizeof(CI_SocketAddress));
       CI_SocketAddress.sin_family      = AF_INET;
       CI_SocketAddress.sin_addr.s_addr = htonl(INADDR_ANY);
       CI_SocketAddress.sin_port        = htons(cfgCI_PORT);

       if ( (bind(CI_SocketID, (struct sockaddr *) &CI_SocketAddress, sizeof(CI_SocketAddress)) < 0) )
       {
           CFE_EVS_SendEvent(CI_SOCKETBIND_ERR_EID,CFE_EVS_ERROR,"CI: bind socket failed = %d", errno);
       }
       else
       {
           CI_SocketConnected = TRUE;
           #ifdef _HAVE_FCNTL_
              /*
              ** Set the socket to non-blocking
              ** This is not available to vxWorks, so it has to be
              ** Conditionally compiled in
              */
              fcntl(CI_SocketID, F_SETFL, O_NONBLOCK);
           #endif
       }
    }

    CI_ResetCounters();

    CFE_SB_InitMsg(&CI_HkTelemetryPkt,
                   CI_HK_TLM_MID,
                   CI_HK_TLM_LNGTH, TRUE);
    /*
    ** Install the delete handler
    */
    OS_TaskInstallDeleteHandler((void*)&CI_delete_callback);


    CFE_EVS_SendEvent(CI_STARTUP_INF_EID,CFE_EVS_INFORMATION, "CI App Initialized");
} /* End of CI_TaskInit() */

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*  Name:  CI_ProcessCommandPacket                                                       */
/*                                                                                       */
/*  Purpose:                                                                             */
/*     This routine will process any packet that is received on the CI command pipe.     */
/*     The packets received on the CI command pipe are listed here:                      */
/*                                                                                       */
/*        1. NOOP command (from ground)                                                  */
/*        2. Request to reset telemetry counters (from ground)                           */
/*        3. Request for housekeeping telemetry packet (from HS task)                    */
/*                                                                                       */
/* * * * * * * * * * * * * * * * * * * * * * * *  * * * * * * *  * *  * * * * * *  * * * */
void CI_ProcessCommandPacket(void)
{

    CFE_SB_MsgId_t  MsgId;

    MsgId = CFE_SB_GetMsgId(CIMsgPtr);

    switch (MsgId)
    {
        case CI_CMD_MID:
            CI_ProcessGroundCommand();
            break;

        case CI_SEND_HK_MID:
            CI_ReportHousekeeping();
            break;

        default:
            CI_HkTelemetryPkt.ci_command_error_count++;
            CFE_EVS_SendEvent(CI_COMMAND_ERR_EID,CFE_EVS_ERROR,"CI: invalid command packet,MID = 0x%x",
                              MsgId);
            break;
    }

    return;

} /* End CI_ProcessCommandPacket */

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                                       */
/* CI_ProcessGroundCommand() -- CI ground commands                                       */
/*                                                                                       */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

void CI_ProcessGroundCommand(void)
{
    uint16 CommandCode;

    CommandCode = CFE_SB_GetCmdCode(CIMsgPtr);

    /* Process "known" CI task ground commands */
    switch (CommandCode)
    {
        case CI_NO_OPERATION_CC:

            CI_HkTelemetryPkt.ci_command_count++;
            CFE_EVS_SendEvent(CI_COMMANDNOP_INF_EID,CFE_EVS_INFORMATION, "CI: NOP command");
            break;

        case CI_RESET_COUNTERS_CC:

            CI_ResetCounters();
            CFE_EVS_SendEvent(CI_COMMANDRST_INF_EID,CFE_EVS_INFORMATION, "CI: RESET command");
            break;


        /* default case already found during FC vs length test */
        default:
            break;
    }


    return;

} /* End of CI_ProcessGroundCommand() */

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*  Name:  CI_ReportHousekeeping                                                         */
/*                                                                                       */
/*  Purpose:                                                                             */
/*         This function is triggered in response to a task telemetry request            */
/*         from the housekeeping task. This function will gather the CI task             */
/*         telemetry, packetize it and send it to the housekeeping task via              */
/*                                                                                       */
/* * * * * * * * * * * * * * * * * * * * * * * *  * * * * * * *  * *  * * * * * *  * * * */

void CI_ReportHousekeeping(void)
{
    CI_HkTelemetryPkt.SocketConnected = CI_SocketConnected;
    CFE_SB_TimeStampMsg((CFE_SB_Msg_t *) &CI_HkTelemetryPkt);
    CFE_SB_SendMsg((CFE_SB_Msg_t *) &CI_HkTelemetryPkt);
    return;

} /* End of CI_ReportHousekeeping() */

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*  Name:  CI_ResetCounters                                                              */
/*                                                                                       */
/*  Purpose:                                                                             */
/*         This function resets all the global counter variables that are                */
/*         part of the task telemetry.                                                   */
/*                                                                                       */
/* * * * * * * * * * * * * * * * * * * * * * * *  * * * * * * *  * *  * * * * * *  * * * */

void CI_ResetCounters(void)
{
    /* Status of commands processed by CI task */
    CI_HkTelemetryPkt.ci_command_count  = 0;
    CI_HkTelemetryPkt.ci_command_error_count  = 0;

    /* Status of packets ingested by CI task */
    CI_HkTelemetryPkt.IngestPackets   = 0;
    CI_HkTelemetryPkt.IngestErrors    = 0;

    return;

} /* End of CI_ResetCounters() */

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                                                       */
/* CI_ReadUpLink() --                                                                    */
/*                                                                                       */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

void CI_ReadUpLink(void)
{
    socklen_t addr_len;
    int i;
    int status;

    addr_len = sizeof(CI_SocketAddress);

    bzero((char *) &CI_SocketAddress, sizeof(CI_SocketAddress));

    for (i = 0; i <= 10; i++)
    {
        status = recvfrom(CI_SocketID, (char *)&CI_IngestBuffer[0], sizeof(CI_IngestBuffer), MSG_DONTWAIT,
                         (struct sockaddr *) &CI_SocketAddress, &addr_len);

        if ( (status < 0) && (errno == EWOULDBLOCK) )
            break; /* no (more) messages */
        else
        {
            if (status <= CI_MAX_INGEST)
            {
                CCSDS_PriHdr_t *PrimaryHeader = NULL;

                CFE_ES_PerfLogEntry(CI_SOCKET_RCV_PERF_ID);
                CI_HkTelemetryPkt.IngestPackets++;

#ifdef SOFTWARE_LITTLE_BIT_ORDER
                PrimaryHeader = (CCSDS_PriHdr_t*)CI_IngestPointer;
                PrimaryHeader->StreamId = ntohs(PrimaryHeader->StreamId);
                PrimaryHeader->Sequence = ntohs(PrimaryHeader->Sequence);
                PrimaryHeader->Length = ntohs(PrimaryHeader->Length);

                if (CCSDS_SID_TYPE(PrimaryHeader->StreamId) == CCSDS_CMD) {
                    CCSDS_CmdPkt_t *CmdPkt = (CCSDS_CmdPkt_t*)PrimaryHeader;

                    CmdPkt->SecHdr.Command = ntohs(CmdPkt->SecHdr.Command);
                } else {
                    CCSDS_TlmPkt_t *TlmPkt = (CCSDS_TlmPkt_t*)PrimaryHeader;
                    uint32 *SecondsPtr = ((uint32 *)&TlmPkt->SecHdr.Time[0]);
                    uint16 *SubsecondsPtr = ((uint16 *)&TlmPkt->SecHdr.Time[4]);

                    *SecondsPtr = ntohs(*SecondsPtr);
                    *SubsecondsPtr = ntohs(*SubsecondsPtr);
                }
#endif

#ifdef DO_DEBUG
                {
                    /*LOGAN - print out hex command message exactly as it was sent */
                    int i;
                    unsigned char *mpp = (unsigned char*) &CI_IngestPointer[0];
                    for( i=0; i< CFE_SB_GetTotalMsgLength(CI_IngestPointer);  i++ ) { printf("%02x ",  mpp[i] ); }
                    printf("\n");
                }
#endif

                CFE_SB_SendMsg(CI_IngestPointer);
                CFE_ES_PerfLogExit(CI_SOCKET_RCV_PERF_ID);
            }
            else
            {
                CI_HkTelemetryPkt.IngestErrors++;
                CFE_EVS_SendEvent(CI_INGEST_ERR_EID,CFE_EVS_ERROR, "CI: L%d, cmd %0x %0x dropped, too long\n", __LINE__, *(long *)CI_IngestBuffer, *(long *)(CI_IngestBuffer+4) );
            }
        }
    }

    return;

} /* End of CI_ReadUpLink() */





