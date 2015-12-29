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
#define TO_CMD_MID          APP_CMD_MID_BASE_CPU1 + TO_CMD_MSG          /* 0x1880 */
#define CI_CMD_MID          APP_CMD_MID_BASE_CPU1 + CI_CMD_MSG          /* 0x1881 */
#define SCH_CMD_MID         APP_CMD_MID_BASE_CPU1 + SCH_CMD_MSG         /* 0x1882 */
#define HK_CMD_MID          APP_CMD_MID_BASE_CPU1 + HK_CMD_MSG          /* 0x188A */
#define LC_CMD_MID          APP_CMD_MID_BASE_CPU1 + LC_CMD_MSG          /* 0x188D */
#define SC_CMD_MID          APP_CMD_MID_BASE_CPU1 + SC_CMD_MSG          /* 0x18A9 */
#define HS_CMD_MID          APP_CMD_MID_BASE_CPU1 + HS_CMD_MSG          /* 0x18AE */
#define DS_CMD_MID          APP_CMD_MID_BASE_CPU1 + DS_CMD_MSG          /* 0x18BB */

/*
** Test Application Command Message Id's
*/
#define TST_EVS_CMD_MID     APP_TST_CMD_MID_BASE_CPU1 + TST_EVS_CMD_MSG     /* 0X1882 */
#define TST_TIME_CMD_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_TIME_CMD_MSG    /* 0X1883 */
#define TST_SB_CMD_MID      APP_TST_CMD_MID_BASE_CPU1 + TST_SB_CMD_MSG      /* 0X1885 */
#define TST_TBL_CMD_MID     APP_TST_CMD_MID_BASE_CPU1 + TST_TBL_CMD_MSG     /* 0X1886 */
#define TST_TBL2_CMD_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_TBL2_CMD_MSG    /* 0X1887 */
#define QQ_CMD_MID          APP_TST_CMD_MID_BASE_CPU1 + QQ_CMD_MSG          /* 0X1888 */
#define TST_ES_CMD_MID      APP_TST_CMD_MID_BASE_CPU1 + TST_ES_CMD_MSG      /* 0X1889 */
#define TST_ES2_CMD_MID     APP_TST_CMD_MID_BASE_CPU1 + TST_ES2_CMD_MSG     /* 0X188A */
#define TST_ES3_CMD_MID     APP_TST_CMD_MID_BASE_CPU1 + TST_ES3_CMD_MSG     /* 0X188B */
#define TST_ES4_CMD_MID     APP_TST_CMD_MID_BASE_CPU1 + TST_ES4_CMD_MSG     /* 0X188C */
#define TST_ES5_CMD_MID     APP_TST_CMD_MID_BASE_CPU1 + TST_ES5_CMD_MSG     /* 0X188D */
#define TST_ES6_CMD_MID     APP_TST_CMD_MID_BASE_CPU1 + TST_ES6_CMD_MSG     /* 0X188E */
#define TST_ES7_CMD_MID     APP_TST_CMD_MID_BASE_CPU1 + TST_ES7_CMD_MSG     /* 0X188F */
#define TST_ES8_CMD_MID     APP_TST_CMD_MID_BASE_CPU1 + TST_ES8_CMD_MSG     /* 0X1892 */
#define TST_ES9_CMD_MID     APP_TST_CMD_MID_BASE_CPU1 + TST_ES9_CMD_MSG     /* 0X1898 */
#define TST_ES10_CMD_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES10_CMD_MSG    /* 0X1899 */
#define TST_ES11_CMD_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES11_CMD_MSG    /* 0X189A */
#define TST_ES12_CMD_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES12_CMD_MSG    /* 0X189B */
#define TST_ES13_CMD_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES13_CMD_MSG    /* 0X189C */
#define TST_ES14_CMD_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES14_CMD_MSG    /* 0X189D */
#define TST_ES15_CMD_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES15_CMD_MSG    /* 0X189E */
#define TST_ES16_CMD_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES16_CMD_MSG    /* 0X189F */
#define TST_ES17_CMD_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES17_CMD_MSG    /* 0X18A0 */
#define TST_ES18_CMD_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES18_CMD_MSG    /* 0X18A1 */
#define TST_ES19_CMD_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES19_CMD_MSG    /* 0X18A2 */
#define TST_ES20_CMD_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES20_CMD_MSG    /* 0X18A3 */
#define TST_ES21_CMD_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES21_CMD_MSG    /* 0X18A4 */
#define TST_ES22_CMD_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES22_CMD_MSG    /* 0X18A5 */
#define TST_ES23_CMD_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES23_CMD_MSG    /* 0X18A6 */
#define TST_ES24_CMD_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES24_CMD_MSG    /* 0X18A7 */


#define TO_SEND_HK_MID         APP_CMD_MID_BASE_CPU1 + TO_SEND_HK_MSG                 /* 0x1890 */
#define CI_SEND_HK_MID         APP_CMD_MID_BASE_CPU1 + CI_SEND_HK_MSG                 /* 0x1891 */
#define SCH_SEND_HK_MID        APP_CMD_MID_BASE_CPU1 + SCH_SEND_HK_MSG                /* 0x1892 */
#define HK_SEND_HK_MID         APP_CMD_MID_BASE_CPU1 + HK_SEND_HK_MSG                 /* 0x189A */
#define LC_SEND_HK_MID         APP_CMD_MID_BASE_CPU1 + LC_SEND_HK_MSG                 /* 0x189D */
#define LC_EVAL_WPAP_MID       APP_CMD_MID_BASE_CPU1 + LC_EVAL_WPAP_MSG               /* 0x189E */
#define SC_SEND_HK_MID         APP_CMD_MID_BASE_CPU1 + SC_SEND_HK_MSG                 /* 0x18AA */
#define HS_SEND_HK_MID         APP_CMD_MID_BASE_CPU1 + HS_SEND_HK_MSG                 /* 0x18AF */
#define DS_SEND_HK_MID         APP_CMD_MID_BASE_CPU1 + DS_SEND_HK_MSG                 /* 0x18BC */

#define TST_TIME_SEND_HK_MID   APP_TST_CMD_MID_BASE_CPU1 + TST_TIME_SEND_HK_MSG       /* 0x1884 */
#define TST_SB_SEND_HK_MID     APP_TST_CMD_MID_BASE_CPU1 + TST_SB_SEND_HK_MSG         /* 0x1893 */
#define TST_TBL_SEND_HK_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_TBL_SEND_HK_MSG        /* 0x1894 */
#define TST_TBL2_SEND_HK_MID   APP_TST_CMD_MID_BASE_CPU1 + TST_TBL2_SEND_HK_MSG       /* 0x1895 */
#define QQ_SEND_HK_MID         APP_TST_CMD_MID_BASE_CPU1 + QQ_SEND_HK_MSG             /* 0x1896 */
#define TST_ES_SEND_HK_MID     APP_TST_CMD_MID_BASE_CPU1 + TST_ES_SEND_HK_MSG         /* 0x1897 */
#define TST_ES2_SEND_HK_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES2_SEND_HK_MSG        /* 0x18A8 */
#define TST_ES3_SEND_HK_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES3_SEND_HK_MSG        /* 0x18A9 */
#define TST_ES4_SEND_HK_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES4_SEND_HK_MSG        /* 0x18AA */
#define TST_ES5_SEND_HK_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES5_SEND_HK_MSG        /* 0x18AB */
#define TST_ES6_SEND_HK_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES6_SEND_HK_MSG        /* 0x18AC */
#define TST_ES7_SEND_HK_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES7_SEND_HK_MSG        /* 0x18AD */
#define TST_ES8_SEND_HK_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES8_SEND_HK_MSG        /* 0x18AE */
#define TST_ES9_SEND_HK_MID    APP_TST_CMD_MID_BASE_CPU1 + TST_ES9_SEND_HK_MSG        /* 0x18AF */
#define TST_ES10_SEND_HK_MID   APP_TST_CMD_MID_BASE_CPU1 + TST_ES10_SEND_HK_MSG       /* 0x18B0 */
#define TST_ES11_SEND_HK_MID   APP_TST_CMD_MID_BASE_CPU1 + TST_ES11_SEND_HK_MSG       /* 0x18B1 */
#define TST_ES12_SEND_HK_MID   APP_TST_CMD_MID_BASE_CPU1 + TST_ES12_SEND_HK_MSG       /* 0x18B2 */
#define TST_ES13_SEND_HK_MID   APP_TST_CMD_MID_BASE_CPU1 + TST_ES13_SEND_HK_MSG       /* 0x18B3 */
#define TST_ES14_SEND_HK_MID   APP_TST_CMD_MID_BASE_CPU1 + TST_ES14_SEND_HK_MSG       /* 0x18B4 */
#define TST_ES15_SEND_HK_MID   APP_TST_CMD_MID_BASE_CPU1 + TST_ES15_SEND_HK_MSG       /* 0x18B5 */
#define TST_ES16_SEND_HK_MID   APP_TST_CMD_MID_BASE_CPU1 + TST_ES16_SEND_HK_MSG       /* 0x18B6 */
#define TST_ES17_SEND_HK_MID   APP_TST_CMD_MID_BASE_CPU1 + TST_ES17_SEND_HK_MSG       /* 0x18B7 */
#define TST_ES18_SEND_HK_MID   APP_TST_CMD_MID_BASE_CPU1 + TST_ES18_SEND_HK_MSG       /* 0x18B8 */
#define TST_ES19_SEND_HK_MID   APP_TST_CMD_MID_BASE_CPU1 + TST_ES19_SEND_HK_MSG       /* 0x18B9 */
#define TST_ES20_SEND_HK_MID   APP_TST_CMD_MID_BASE_CPU1 + TST_ES20_SEND_HK_MSG       /* 0x18BA */
#define TST_ES21_SEND_HK_MID   APP_TST_CMD_MID_BASE_CPU1 + TST_ES21_SEND_HK_MSG       /* 0x18BB */
#define TST_ES22_SEND_HK_MID   APP_TST_CMD_MID_BASE_CPU1 + TST_ES22_SEND_HK_MSG       /* 0x18BC */
#define TST_ES23_SEND_HK_MID   APP_TST_CMD_MID_BASE_CPU1 + TST_ES23_SEND_HK_MSG       /* 0x18BD */
#define TST_ES24_SEND_HK_MID   APP_TST_CMD_MID_BASE_CPU1 + TST_ES24_SEND_HK_MSG       /* 0x18BE */

/*
** Application Telemetry Message Id's
*/
#define TO_HK_TLM_MID       APP_TLM_MID_BASE_CPU1 + TO_HK_TLM_MSG                     /* 0x0880 */
#define CI_HK_TLM_MID       APP_TLM_MID_BASE_CPU1 + CI_HK_TLM_MSG                     /* 0x0881 */
#define SCH_HK_TLM_MID      APP_TLM_MID_BASE_CPU1 + SCH_HK_TLM_MSG                    /* 0x0882 */
#define HK_HK_TLM_MID       APP_TLM_MID_BASE_CPU1 + HK_HK_TLM_MSG                     /* 0x088A */
#define LC_HK_TLM_MID       APP_TLM_MID_BASE_CPU1 + LC_HK_TLM_MSG                     /* 0x088B */
#define SC_HK_TLM_MID       APP_TLM_MID_BASE_CPU1 + SC_HK_TLM_MSG                     /* 0x08AA */
#define HS_HK_TLM_MID       APP_TLM_MID_BASE_CPU1 + HS_HK_TLM_MSG                     /* 0x08AD */
#define DS_HK_TLM_MID       APP_TLM_MID_BASE_CPU1 + DS_HK_TLM_MSG                     /* 0x08B8 */

#define TST_TIME_HK_TLM_MID       APP_TST_TLM_MID_BASE_CPU1 + TST_TIME_HK_TLM_MSG        /* 0X0700 */
#define TST_TIME_TAI_TLM_MID      APP_TST_TLM_MID_BASE_CPU1 + TST_TIME_TAI_TLM_MSG       /* 0X0701 */
#define TST_TIME_UTC_TLM_MID      APP_TST_TLM_MID_BASE_CPU1 + TST_TIME_UTC_TLM_MSG       /* 0X0702 */
#define TST_TIME_ST_TLM_MID       APP_TST_TLM_MID_BASE_CPU1 + TST_TIME_ST_TLM_MSG        /* 0X0703 */
#define TST_TIME_MET_TLM_MID      APP_TST_TLM_MID_BASE_CPU1 + TST_TIME_MET_TLM_MSG       /* 0X0704 */
#define TST_TIME_METSEC_TLM_MID   APP_TST_TLM_MID_BASE_CPU1 + TST_TIME_METSEC_TLM_MSG    /* 0X0705 */
#define TST_TIME_METSUB_TLM_MID   APP_TST_TLM_MID_BASE_CPU1 + TST_TIME_METSUB_TLM_MSG    /* 0X0706 */
#define TST_TIME_STCF_TLM_MID     APP_TST_TLM_MID_BASE_CPU1 + TST_TIME_STCF_TLM_MSG      /* 0X0707 */
#define TST_TIME_LPSEC_TLM_MID    APP_TST_TLM_MID_BASE_CPU1 + TST_TIME_LPSEC_TLM_MSG     /* 0X0708 */
#define TST_TIME_CLKST_TLM_MID    APP_TST_TLM_MID_BASE_CPU1 + TST_TIME_CLKST_TLM_MSG     /* 0X0709 */
#define TST_TIME_ADD_TLM_MID      APP_TST_TLM_MID_BASE_CPU1 + TST_TIME_ADD_TLM_MSG       /* 0X070A */
#define TST_TIME_SUBTIME_TLM_MID  APP_TST_TLM_MID_BASE_CPU1 + TST_TIME_SUBTIME_TLM_MSG   /* 0X070B */
#define TST_TIME_COMP_TLM_MID     APP_TST_TLM_MID_BASE_CPU1 + TST_TIME_COMP_TLM_MSG      /* 0X070C */
#define TST_TIME_SUBMICRO_TLM_MID APP_TST_TLM_MID_BASE_CPU1 + TST_TIME_SUBMICRO_TLM_MSG  /* 0X070D */
#define TST_TIME_MICROSUB_TLM_MID APP_TST_TLM_MID_BASE_CPU1 + TST_TIME_MICROSUB_TLM_MSG  /* 0X070E */


#define TST_SB_HK_TLM_MID         APP_TST_TLM_MID_BASE_CPU1 + TST_SB_HK_TLM_MSG          /* 0X070F */
#define TST_SB_PIPE0_TLM_MID      APP_TST_TLM_MID_BASE_CPU1 + TST_SB_PIPE0_TLM_MSG       /* 0x0710 */

#define TST_TBL_HK_TLM_MID        APP_TST_TLM_MID_BASE_CPU1 + TST_TBL_HK_TLM_MSG         /* 0X0711 */
#define TST_TBL_MAXTBLST_TLM_MID  APP_TST_TLM_MID_BASE_CPU1 + TST_TBL_MAXTBLST_TLM_MSG   /* 0X0712 */
#define TST_TBL2_HK_TLM_MID       APP_TST_TLM_MID_BASE_CPU1 + TST_TBL2_HK_TLM_MSG        /* 0X0713 */
#define QQ_HK_TLM_MID             APP_TLM_MID_BASE_CPU1 + QQ_HK_TLM_MSG                  /* 0X0714 */
#define TST_TBL2_MAXTBLST_TLM_MID APP_TLM_MID_BASE_CPU1 + TST_TBL2_MAXTBLST_TLM_MSG      /* 0x0715 */
#define TST_TBL_INFO_TLM_MID      APP_TST_TLM_MID_BASE_CPU1 + TST_TBL_TBLINFO_TLM_MSG    /* 0x0716 */

#define TST_ES_HK_TLM_MID         APP_TST_TLM_MID_BASE_CPU1 + TST_ES_HK_TLM_MSG          /* 0x0717 */
#define TST_ES2_HK_TLM_MID        APP_TST_TLM_MID_BASE_CPU1 + TST_ES2_HK_TLM_MSG         /* 0x0718 */
#define TST_ES3_HK_TLM_MID        APP_TST_TLM_MID_BASE_CPU1 + TST_ES3_HK_TLM_MSG         /* 0x0719 */
#define TST_ES4_HK_TLM_MID        APP_TST_TLM_MID_BASE_CPU1 + TST_ES4_HK_TLM_MSG         /* 0x071A */
#define TST_ES5_HK_TLM_MID        APP_TST_TLM_MID_BASE_CPU1 + TST_ES5_HK_TLM_MSG         /* 0x071B */
#define TST_ES6_HK_TLM_MID        APP_TST_TLM_MID_BASE_CPU1 + TST_ES6_HK_TLM_MSG         /* 0x071C */
#define TST_ES7_HK_TLM_MID        APP_TST_TLM_MID_BASE_CPU1 + TST_ES7_HK_TLM_MSG         /* 0x071D */
#define TST_ES8_HK_TLM_MID        APP_TST_TLM_MID_BASE_CPU1 + TST_ES8_HK_TLM_MSG         /* 0x071E */
#define TST_ES9_HK_TLM_MID        APP_TST_TLM_MID_BASE_CPU1 + TST_ES9_HK_TLM_MSG         /* 0x071F */
#define TST_ES10_HK_TLM_MID       APP_TST_TLM_MID_BASE_CPU1 + TST_ES10_HK_TLM_MSG        /* 0x0720 */
#define TST_ES11_HK_TLM_MID       APP_TST_TLM_MID_BASE_CPU1 + TST_ES11_HK_TLM_MSG        /* 0x0721 */
#define TST_ES12_HK_TLM_MID       APP_TST_TLM_MID_BASE_CPU1 + TST_ES12_HK_TLM_MSG        /* 0x0722 */
#define TST_ES13_HK_TLM_MID       APP_TST_TLM_MID_BASE_CPU1 + TST_ES13_HK_TLM_MSG        /* 0x0723 */
#define TST_ES14_HK_TLM_MID       APP_TST_TLM_MID_BASE_CPU1 + TST_ES14_HK_TLM_MSG        /* 0x0724 */
#define TST_ES15_HK_TLM_MID       APP_TST_TLM_MID_BASE_CPU1 + TST_ES15_HK_TLM_MSG        /* 0x0725 */
#define TST_ES16_HK_TLM_MID       APP_TST_TLM_MID_BASE_CPU1 + TST_ES16_HK_TLM_MSG        /* 0x0726 */
#define TST_ES17_HK_TLM_MID       APP_TST_TLM_MID_BASE_CPU1 + TST_ES17_HK_TLM_MSG        /* 0x0727 */
#define TST_ES18_HK_TLM_MID       APP_TST_TLM_MID_BASE_CPU1 + TST_ES18_HK_TLM_MSG        /* 0x0728 */
#define TST_ES19_HK_TLM_MID       APP_TST_TLM_MID_BASE_CPU1 + TST_ES19_HK_TLM_MSG        /* 0x0729 */
#define TST_ES20_HK_TLM_MID       APP_TST_TLM_MID_BASE_CPU1 + TST_ES20_HK_TLM_MSG        /* 0x072A */
#define TST_ES21_HK_TLM_MID       APP_TST_TLM_MID_BASE_CPU1 + TST_ES21_HK_TLM_MSG        /* 0x072B */
#define TST_ES22_HK_TLM_MID       APP_TST_TLM_MID_BASE_CPU1 + TST_ES22_HK_TLM_MSG        /* 0x072C */
#define TST_ES23_HK_TLM_MID       APP_TST_TLM_MID_BASE_CPU1 + TST_ES23_HK_TLM_MSG        /* 0x072D */
#define TST_ES24_HK_TLM_MID       APP_TST_TLM_MID_BASE_CPU1 + TST_ES24_HK_TLM_MSG        /* 0x072E */


#define TO_DATA_TYPES_MID         APP_TLM_MID_BASE_CPU1 + TO_DATA_TYPES_MSG   /* 0X0890 */
#define SCH_DIAG_TLM_MID          APP_TLM_MID_BASE_CPU1 + SCH_DIAG_TLM_MSG      /* 0x0892 */

#define TICK_1HZ_MID    0x1909
#define TICK_10HZ_MID   0x190A
#define TICK_100HZ_MID  0x190D

/* Temporary placement of MSGIDs for the CSC apps */
#define CSC_CMD_MID          0x1883
#define CSC_SEND_HK_MID      0x1893
#define CSC_HK_TLM_MID       0x0883


#define CSC_EST_CMD_MID      0x1885
#define CSC_EST_SEND_HK_MID  0x1895
#define CSC_EST_HK_TLM_MID   0x0884

#define CSC_PFB_CMD_MID      0x1886
#define CSC_PFB_SEND_HK_MID  0x1896
#define CSC_PFB_HK_TLM_MID   0x0886

#define CSC_GDN_CMD_MID      0x1887
#define CSC_GDN_SEND_HK_MID  0x1897
#define CSC_GDN_HK_TLM_MID   0x0887

#define CSC_MGT_CMD_MID      0x1887
#define CSC_MGT_SEND_HK_MID  0x1897
#define CSC_MGT_HK_TLM_MID   0x0887

#define CSC_CNT_CMD_MID      0x1888
#define CSC_CNT_SEND_HK_MID  0x1898
#define CSC_CNT_HK_TLM_MID   0x0888

#define CSC_ACT_CMD_MID      0x188F
#define CSC_ACT_SEND_HK_MID  0x189F
#define CSC_ACT_HK_TLM_MID   0x088F

#define CSC_SIM_CMD_MID      0x1889
#define CSC_SIM_SEND_HK_MID  0x1899
#define CSC_SIM_HK_TLM_MID   0x0889

#define CSC_CMP_CMD_MID      0x188B
#define CSC_CMP_SEND_HK_MID  0x189B
#define CSC_CMP_HK_TLM_MID   0x088B
#define CMP_SL_CMD_MID       0x1901
#define MGT_SL_CMD_MID       0x1901

#define CSC_HIO_CMD_MID      0x188D
#define CSC_HIO_SEND_HK_MID  0x189D
#define CSC_HIO_HK_TLM_MID   0x088D

#define CSC_SC_CMD_MID       0x188E
#define CSC_SC_SEND_HK_MID   0x189E
#define CSC_SC_HK_TLM_MID    0x088E

#define GROUND_CMD_MID       0x1920

#define EST_BUS_MID          0x0921
#define GDN_BUS_MID          0x0922
#define GDN_TLM_MID          0x0923
#define CNT_BUS_MID          0x0924
#define CNT_TLM_MID          0x0926
#define ACT_BUS_MID          0x0934
#define SIM_DATA_BUS_MID     0x0928
#define CMP_BUS_MID          0x0929
#define SIM_TLM_MID          0x092A

#define STA_MID              0x0931
#define LDR_MID              0x0932
#define CFP_MID              0x0935
#define MEM_MID              0x0936

#define STPUS_TC_MID         0x18a0
#define STIO_CMD_MID         0x1940
#define STIO_SEND_HK_MID     0x1941
#define STIO_HK_TLM_MID      0x0940

#define THRIO_CMD_MID        0x1942
#define THRIO_SEND_HK_MID    0x1943
#define THRIO_HK_TLM_MID     0x0942

#endif
