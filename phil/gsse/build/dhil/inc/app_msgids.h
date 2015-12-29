/******************************************************************************
** File: app_msgids.h
** $Id: app_msgids.h 1.1 2008/04/17 08:01:41EDT ruperera Exp  $
**
** Purpose:
**   This file contains application message id defines for a single processor
**
** Author:
**   R. McGraw/SSI
**
** $Date: 2008/04/17 08:01:41EDT $
** $Revision: 1.1 $
** $Log: app_msgids.h  $
** Revision 1.1 2008/04/17 08:01:41EDT ruperera
** Initial revision
** Member added to project c:/MKSDATA/MKS-REPOSITORY/MKS-CFE-PROJECT/fsw/build/cpu1/inc/project.pj
** Revision 1.1.1.10 2006/11/14 09:18:09EST kkaudra
** Added TST_ES MID's
** Revision 1.1.1.9 2006/02/24 08:16:42EST kkaudra
** Added TST_TBL2_MAXTBLST_TLM_MID
** Revision 1.1.1.8 2006/02/06 16:24:47EST rjmcgraw
** Member moved from app_msgids.h in project d:/mksdata/MKS-CFE-PROJECT/fsw/cfe-apps/inc/project.pj to app_msgids.h in project d:/mksdata/MKS-CFE-PROJECT/fsw/build/cpu1/inc/project.pj.
** Revision 1.1.1.6 2006/01/13 15:36:17EST rjmcgraw
** Member moved from app_msgids.h in project d:/mksdata/MKS-CFE-REPOSITORY/config/cpu1/inc/project.pj to app_msgids.h in project d:/mksdata/MKS-CFE-PROJECT/fsw/cfe-apps/inc/project.pj.
** Revision 1.1.1.4 2005/11/10 13:31:26EST kkaudra
** Added TST_TBL2 MID definitions
** Revision 1.1.1.3 2005/09/21 16:43:28EDT kkaudra
** Added tst_tbl MID definitions
** Revision 1.1.1.2 2005/06/28 08:52:48EDT kkaudra
** Added test application command and telemetry message Id's
** Revision 1.1.1.1 2005/06/09 10:57:58EDT kkaudra
** Duplicate revision
** Revision 1.5  2005/05/26 12:29:01  kaudra
** changed APP_CMD_MID_BASE_CPU1 to APP_TST_CMD_MID_BASE_CPU1
**
** Revision 1.4  2005/05/19 11:27:58  kaudra
** changed test application command message id from BTA_CMD_MID to TST_EVS_CMD_MID
**
** Revision 1.3  2005/05/17 19:37:55  kaudra
** log message
**
** Revision 1.2  2005/04/28 20:30:34  rmcgraw
** Renamed BOXx to CPUx
**
** Revision 1.1  2005/04/04 19:42:00  acudmore
** added cpu1 config
**
** Revision 1.2  2005/03/23 19:11:24  rmcgraw
** Re-ordered top few lines
**
** Revision 1.1  2005/03/23 18:53:11  rmcgraw
** Initial Release
**
**
******************************************************************************/
#ifndef _app_msgids_
#define _app_msgids_

/*
** Includes
*/
#include "app_mission_cfg.h"


/*
** Application Command Message Id's
*/
#define SIMCI_CMD_MID        0x1a02
#define SIMCI_SEND_HK_MID    0x1a03
#define SIMCI_HK_TLM_MID     0x0a02

#define SIMTO_CMD_MID        0x1a04
#define SIMTO_SEND_HK_MID    0x1a05
#define SIMTO_HK_TLM_MID     0x0a04

/*
** Application Telemetry Message Id's
*/
#define TICK_1HZ_MID         0x1909
#define TICK_10HZ_MID        0x190A
#define TICK_100HZ_MID       0x190D

/* Temporary placement of MSGIDs for the CSC apps */
#define CSC_CMD_MID          0x1883
#define CSC_SEND_HK_MID      0x1893
#define CSC_HK_TLM_MID       0x0883

#define CSC_SIM_CMD_MID      0x1889
#define CSC_SIM_SEND_HK_MID  0x1899
#define CSC_SIM_HK_TLM_MID   0x0889

#define SIM_DATA_BUS_MID     0x0928
#define SIM_TLM_MID          0x092A

#define SCH_CMD_MID          0x1a00
#define SCH_SEND_HK_MID      0x1a01
#define SCH_HK_TLM_MID       0x0a00
#define SCH_DIAG_TLM_MID     0x0a01

#define LNS_VEH_MID          0x0940
#define STA_VEH_MID          0x0941
#define LDR_VEH_MID          0x0942
#define MAGIC_SENSOR_VEH_MID 0x0943
#define CFP_VEH_MID          0x0945
#define THR_SIM_MID          0x0946
#define MEM_VEH_MID          0x0947

#define THRSIM_HK_TLM_MID    0x0999
#define THRSIM_CMD_MID       0x1999
#define THRSIM_SEND_HK_MID   0x199a

#define FUSED_ATTITUDE_MID   0x09A0
#define MIRU_DATA_MID        0x09A1

#define STSIM_HK_TLM_MID     0x099b
#define STSIM_CMD_MID        0x199b
#define STSIM_SEND_HK_MID    0x199c

#define IMUSIM_HK_TLM_MID    0x099d
#define IMUSIM_CMD_MID       0x199d
#define IMUSIM_SEND_HK_MID   0x199e

#endif
