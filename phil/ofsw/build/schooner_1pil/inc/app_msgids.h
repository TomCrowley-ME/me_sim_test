/******************************************************************************
** File: app_msgids.h ** $Id: app_msgids.h 1.1 2008/04/17 08:01:41EDT ruperera Exp  $
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
#define SCH_CMD_MID         APP_CMD_MID_BASE_CPU1 + SCH_CMD_MSG         /* 0x1882 */
#define SC_CMD_MID          APP_CMD_MID_BASE_CPU1 + SC_CMD_MSG          /* 0x18A9 */
#define HS_CMD_MID          APP_CMD_MID_BASE_CPU1 + HS_CMD_MSG          /* 0x18AE */
#define LC_CMD_MID          APP_CMD_MID_BASE_CPU1 + LC_CMD_MSG          /* 0x188D */

#define SCH_SEND_HK_MID        APP_CMD_MID_BASE_CPU1 + SCH_SEND_HK_MSG                /* 0x1892 */
#define SC_SEND_HK_MID         APP_CMD_MID_BASE_CPU1 + SC_SEND_HK_MSG                 /* 0x18AA */
#define HS_SEND_HK_MID         APP_CMD_MID_BASE_CPU1 + HS_SEND_HK_MSG                 /* 0x18AF */
#define LC_SEND_HK_MID         APP_CMD_MID_BASE_CPU1 + LC_SEND_HK_MSG                 /* 0x189D */
#define LC_EVAL_WPAP_MID       APP_CMD_MID_BASE_CPU1 + LC_EVAL_WPAP_MSG               /* 0x189E */

/*
** Application Telemetry Message Id's
*/
#define SCH_HK_TLM_MID      APP_TLM_MID_BASE_CPU1 + SCH_HK_TLM_MSG                    /* 0x0882 */
#define SC_HK_TLM_MID       APP_TLM_MID_BASE_CPU1 + SC_HK_TLM_MSG                     /* 0x08AA */
#define SCH_DIAG_TLM_MID    APP_TLM_MID_BASE_CPU1 + SCH_DIAG_TLM_MSG      /* 0x0892 */
#define HS_HK_TLM_MID       APP_TLM_MID_BASE_CPU1 + HS_HK_TLM_MSG                     /* 0x08AD */
#define LC_HK_TLM_MID       APP_TLM_MID_BASE_CPU1 + LC_HK_TLM_MSG                     /* 0x088D */

#define TICK_1HZ_MID    0x19F0
#define TICK_10HZ_MID   0x19F1
#define TICK_100HZ_MID  0x19F2

/* Temporary placement of MSGIDs for the CSC apps */
#define CSC_CMD_MID          0x1902
#define CSC_SEND_HK_MID      0x1903
#define CSC_HK_TLM_MID       0x0902

#define CMP_SL_CMD_MID       0x1901
#define CSC_CMP_CMD_MID      0x1904
#define CSC_CMP_SEND_HK_MID  0x1905
#define CSC_CMP_HK_TLM_MID   0x0904

#define CSC_EST_CMD_MID      0x1906
#define CSC_EST_SEND_HK_MID  0x1907
#define CSC_EST_HK_TLM_MID   0x0906

#define CSC_GDN_CMD_MID      0x1908
#define CSC_GDN_SEND_HK_MID  0x1909
#define CSC_GDN_HK_TLM_MID   0x0908

#define CSC_CNT_CMD_MID      0x190A
#define CSC_CNT_SEND_HK_MID  0x190B
#define CSC_CNT_HK_TLM_MID   0x090A

#define CSC_ACT_CMD_MID      0x190C
#define CSC_ACT_SEND_HK_MID  0x190D
#define CSC_ACT_HK_TLM_MID   0x090C

#define PCS_SL_CMD_MID       0x1930
#define CSC_PCS_CMD_MID      0x190E
#define CSC_PCS_SEND_HK_MID  0x190F
#define CSC_PCS_HK_TLM_MID   0x090E

#define TCS_SL_CMD_MID       0x1931
#define CSC_TCS_CMD_MID      0x1910
#define CSC_TCS_SEND_HK_MID  0x1911
#define CSC_TCS_HK_TLM_MID   0x0910

#define CSC_SIM_CMD_MID      0x1F00
#define CSC_SIM_SEND_HK_MID  0x1F01
#define CSC_SIM_HK_TLM_MID   0x0F00

#define CSC_EGC_CMD_MID      0x1A00
#define CSC_EGC_SEND_HK_MID  0x1A01
#define CSC_EGC_HK_TLM_MID   0x0A00

#define CMP_BUS_MID          0x0920
#define EST_BUS_MID          0x0921
#define GDN_BUS_MID          0x0922
#define CNT_BUS_MID          0x0923
#define CNT_TLM_MID          0x0924
#define ACT_BUS_MID          0x0925
#define PCS_BUS_MID          0x0930
#define TCS_BUS_MID          0x0931

#define SIM_TLM_MID          0x0F20
#define SIM_DATA_BUS_MID     0x0F21

#define CMP_MTV_MID          0x0A20
#define ACT_MTV_MID          0x0A21
#define EST_MTV_MID          0x0A22
#define SIM_DATA_MTV_MID     0x0A30

#define STPUS_TC_MID         0x1946

#define STA_MID              0x0940
#define LDR_MID              0x0941
#define CFP_MID              0x0942
#define MEM_MID              0x0943
#define FUSED_ATTITUDE_MID   0x0944
#define MIRU_DATA_MID        0x0945
#define ADIO_MID             0x0946
#define THRIO_MID            0x0947
#define IMU_MID              0x0948


#define EGC_BUS_MID          0x0A40
#define EGCIO_MID            0x0A41
#define GPS_MID              0x0A50


#define STA_VEH_MID          0x0F40
#define LDR_VEH_MID          0x0F41
#define CFP_VEH_MID          0x0F42
#define MEM_VEH_MID          0x0F43
#define THR_SIM_MID          0x0F44
#define ADIO_VEH_MID         0x0F45
#define IMU_VEH_MID          0x0F46

#define EGC_VEH_MID          0x0A80
#define GPS_VEH_MID          0x0A81

#define STIO_CMD_MID         0x1970
#define STIO_SEND_HK_MID     0x1971
#define STIO_HK_TLM_MID      0x0970

#define THRIO_CMD_MID        0x1972
#define THRIO_SEND_HK_MID    0x1973
#define THRIO_HK_TLM_MID     0x0972

#define MEMSIO_CMD_MID       0x1974
#define MEMSIO_SEND_HK_MID   0x1975
#define MEMSIO_HK_TLM_MID    0x0974

#define ADIO_CMD_MID         0x1976
#define ADIO_SEND_HK_MID     0x1977
#define ADIO_HK_TLM_MID      0x0976

#define EGCIO_CMD_MID        0x1A70
#define EGCIO_SEND_HK_MID    0x1A71
#define EGCIO_HK_TLM_MID     0x0A70

#define GPSIO_CMD_MID        0x1A72
#define GPSIO_SEND_HK_MID    0x1A73
#define GPSIO_HK_TLM_MID     0x0A72

#define IMUIO_CMD_MID        0x1A74
#define IMUIO_SEND_HK_MID    0x1A75
#define IMUIO_HK_TLM_MID     0x0A74

#define THRSIM_CMD_MID       0x1F70
#define THRSIM_SEND_HK_MID   0x1F71
#define THRSIM_HK_TLM_MID    0x0F70

#define MEMSSIM_CMD_MID      0x1F72
#define MEMSSIM_SEND_HK_MID  0x1F73
#define MEMSSIM_HK_TLM_MID   0x0F72

#define EGCSIM_CMD_MID       0x1F74
#define EGCSIM_SEND_HK_MID   0x1F75
#define EGCSIM_HK_TLM_MID    0x0F74

#define ADSIM_CMD_MID        0x1F76
#define ADSIM_SEND_HK_MID    0x1F77
#define ADSIM_HK_TLM_MID     0x0F76

#define GPSSIM_CMD_MID       0x1F78
#define GPSSIM_SEND_HK_MID   0x1F79
#define GPSSIM_HK_TLM_MID    0x0F78

#define IMUSIM_CMD_MID       0x1F7A
#define IMUSIM_SEND_HK_MID   0x1F7B
#define IMUSIM_HK_TLM_MID    0x0F7A

#define SIMCI_CMD_MID        0x1F92
#define SIMCI_SEND_HK_MID    0x1F93
#define SIMCI_HK_TLM_MID     0x0F92

#define SIMTO_CMD_MID        0x1F94
#define SIMTO_SEND_HK_MID    0x1F95
#define SIMTO_HK_TLM_MID     0x0F94


#endif
