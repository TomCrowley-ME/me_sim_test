/*
** File: app_perfids.h
**
** Purpose: This file contains the application performance ids
**
**      Copyright � 2004-2006, United States government as represented by the
**      administrator of the National Aeronautics Space Administration.
**      All rights reserved. This software(cFE) was created at NASA's Goddard
**      Space Flight Center pursuant to government contracts.
**
**      This software may be used only pursuant to a United States government
**      sponsored project and the United States government may not be charged
**      for use thereof.
**
**
** Design Notes:
**   Each performance id is used to identify something that needs to be
**   measured.  Performance ids are limited to the range of 0 to
**   CFE_ES_PERF_MAX_IDS - 1.  Any performance ids outside of this range
**   will be ignored and will be flagged as an error.  Note that
**   performance ids 0-31 are reserved for the cFE Core.
**
** References:
**
** $Log: app_perfids.h  $
** Revision 1.1 2008/04/17 08:01:41EDT ruperera
** Initial revision
** Member added to project c:/MKSDATA/MKS-REPOSITORY/MKS-CFE-PROJECT/fsw/build/cpu1/inc/project.pj
** Revision 1.7 2007/09/24 11:13:39EDT rjmcgraw
** DCR5039 Updated comments
** Revision 1.6 2007/07/16 10:30:22EDT wfmoleski
** Added a performance analyzer ID for TST_ES.
** Revision 1.5 2007/04/19 14:30:42EDT rjmcgraw
** Fixed all perf ids they were out of range
** Revision 1.4 2006/06/21 16:20:28EDT kkaudra
** Reserved cFE Perf ID range note
** Revision 1.3 2006/06/20 13:16:15EDT rjmcgraw
** Renumbered performance ids
** Revision 1.2 2006/06/14 14:14:37GMT kkaudra
** Added perf markers for test apps
** Revision 1.1 2006/06/13 16:05:15EDT rjmcgraw
** Initial revision
** Member added to MKS-CFE-PROJECT
**
*/

#ifndef _app_perfids_
#define _app_perfids_

/*
** The first 32 Performance Monitor IDs are reserved for the cFE Core
*/

/*
** Application Performance Ids
*/
#define SCH_MAIN_TASK_PERF_ID           0x00000020
#define CI_MAIN_TASK_PERF_ID            0x00000021
#define TO_MAIN_TASK_PERF_ID            0x00000022
#define TO_SOCKET_SEND_PERF_ID          0x00000023
#define CI_SOCKET_RCV_PERF_ID           0x00000024
#define HK_MAIN_TASK_PERF_ID            0x00000025
#define SC_MAIN_TASK_PERF_ID            0x00000026
#define LC_MAIN_TASK_PERF_ID            0x00000027
#define HS_MAIN_TASK_PERF_ID            0x00000028
#define DS_MAIN_TASK_PERF_ID            0x00000029

/*
** Test Application Performance Ids
*/
#define TST_EVS_MAIN_TASK_PERF_ID       0x00000030
#define TST_SB_MAIN_TASK_PERF_ID        0x00000031
#define TST_TIME_MAIN_TASK_PERF_ID      0x00000032
#define TST_TBL_MAIN_TASK_PERF_ID       0x00000033
#define TST_TBL2_MAIN_TASK_PERF_ID      0x00000034
#define TST_QQ_APPMAIN_PERF_ID          0x00000035
#define TST_ES_MAIN_PERF_ID             0x00000036

/*
** CSC Application Performance Ids
*/
#define CSC_EST_PERF_ID                 0x00000041
#define CSC_GDN_PERF_ID                 0x00000043
#define CSC_CNT_PERF_ID                 0x00000044
#define CSC_SIM_PERF_ID                 0x00000045
#define CSC_CMP_PERF_ID                 0x00000046
#define CSC_ACT_PERF_ID                 0x00000047
#define CSC_EGC_PERF_ID                 0x00000048
#define CSC_PCS_PERF_ID                 0x00000049
#define CSC_TCS_PERF_ID                 0x0000004A

#define STIO_MAIN_TASK_PERF_ID          0x00000060
#define THRIO_MAIN_TASK_PERF_ID         0x00000061
#define MEMSIO_MAIN_TASK_PERF_ID        0x00000062
#define EGCIO_MAIN_TASK_PERF_ID         0x00000063
#define ADIO_MAIN_TASK_PERF_ID          0x00000064
#define GPSIO_MAIN_TASK_PERF_ID         0x00000065
#define IMUIO_MAIN_TASK_PERF_ID         0x00000066

/*
** Sim Application Performance Ids
*/
#define SIMSCH_MAIN_TASK_PERF_ID        0x00000100
#define SIMCI_MAIN_TASK_PERF_ID         0x00000101
#define SIMCI_UPLINK_RCV_PERF_ID        0x00000102
#define SIMCI_INGEST_RCV_PERF_ID        0x00000102
#define SIMTO_MAIN_TASK_PERF_ID         0x00000103

#define STSIM_MAIN_TASK_PERF_ID         0x00000110
#define THRSIM_MAIN_TASK_PERF_ID        0x00000111
#define IMUSIM_MAIN_TASK_PERF_ID        0x00000112
#define MEMSSIM_MAIN_TASK_PERF_ID       0x00000113
#define EGCSIM_MAIN_TASK_PERF_ID        0x00000114
#define PRUSIM_MAIN_TASK_PERF_ID        0x00000115
#define ADSIM_MAIN_TASK_PERF_ID         0x00000116
#define GPSSIM_MAIN_TASK_PERF_ID        0x00000117

#endif   /* _app_perfids_ */
