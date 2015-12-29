/******************************************************************************
** File: app_mission_cfg.h
** $Id: app_mission_cfg.h 1.1 2008/04/17 08:02:33EDT ruperera Exp  $
**
** Purpose:
**   This header file contains the mission configuration parameters related
**   to the mission applications.
**
** Author:   R.McGraw/SSI
**
** Notes:
**
** $Date: 2008/04/17 08:02:33EDT $
** $Revision: 1.1 $
** $Log: app_mission_cfg.h  $
** Revision 1.1 2008/04/17 08:02:33EDT ruperera
** Initial revision
** Member added to project c:/MKSDATA/MKS-REPOSITORY/MKS-CFE-PROJECT/fsw/build/inc/project.pj
** Revision 1.1.1.10 2006/11/14 09:19:49EST kkaudra
** Added TST_ES MID's
** Revision 1.1.1.9 2006/02/24 08:17:26EST kkaudra
** Added TST_TBL2_MAXTBLST_TLM_MSG
** Revision 1.1.1.8 2006/02/06 16:19:31EST rjmcgraw
** Member moved from app_mission_cfg.h in project d:/mksdata/MKS-CFE-PROJECT/fsw/cfe-apps/inc/project.pj to app_mission_cfg.h in project d:/mksdata/MKS-CFE-PROJECT/fsw/build/inc/project.pj.
** Revision 1.1.1.6 2006/01/13 15:37:38EST rjmcgraw
** Member moved from app_mission_cfg.h in project d:/mksdata/MKS-CFE-REPOSITORY/config/all/inc/project.pj to app_mission_cfg.h in project d:/mksdata/MKS-CFE-PROJECT/fsw/cfe-apps/inc/project.pj.
** Revision 1.1.1.4 2005/11/10 13:27:14EST kkaudra
** Added TST_TBL2 MSG definitions
** Revision 1.1.1.3 2005/09/21 16:42:20EDT kkaudra
** Added tst_tbl msg definitions
** Revision 1.1.1.2 2005/06/28 08:45:10EDT kkaudra
** Added application command message numbers and new TLM CPU1|2|3 bases numbers
** Revision 1.1.1.1 2005/06/09 10:57:57EDT kkaudra
** Duplicate revision
** Revision 1.5  2005/05/19 11:22:48  kaudra
** changed command message name from BTA_CMD_MSG to TST_EVS_CMD_MSG
**
** Revision 1.4  2005/05/17 19:33:27  kaudra
** log message
**
** Revision 1.3  2005/04/28 20:30:10  rmcgraw
** Renamed BOXx to CPUx
**
** Revision 1.2  2005/03/23 19:12:38  rmcgraw
** Added #endif at end of file
**
** Revision 1.1  2005/03/23 18:47:18  rmcgraw
** Initial Release
**
**
******************************************************************************/

#ifndef _app_mission_cfg_
#define _app_mission_cfg_


/* Message Id base numbers for the Application messages */
#define APP_CMD_MID_BASE_CPU1   0x1880
#define APP_TLM_MID_BASE_CPU1   0x0880

#define APP_CMD_MID_BASE_CPU2   0x18A0
#define APP_TLM_MID_BASE_CPU2   0x08A0

#define APP_CMD_MID_BASE_CPU3   0x18C0
#define APP_TLM_MID_BASE_CPU3   0x08C0

#define APP_CMD_MID_BASE_GLOB   0x18E0
#define APP_TLM_MID_BASE_GLOB   0x08E0

/* Message Id base numbers for the Test Application messages */
#define APP_TST_CMD_MID_BASE_CPU1   0x1880
#define APP_TST_TLM_MID_BASE_CPU1   0x0700

#define APP_TST_CMD_MID_BASE_CPU2   0x18A0
#define APP_TST_TLM_MID_BASE_CPU2   0x0720

#define APP_TST_CMD_MID_BASE_CPU3   0x18C0
#define APP_TST_TLM_MID_BASE_CPU3   0x0740


/*
** Application Command Message Numbers
** Note: These are not MsgIds, application message ids
**       are located in app_msgids.h
*/
#define TO_CMD_MSG              0
#define CI_CMD_MSG              1
#define SCH_CMD_MSG             2
#define HK_CMD_MSG              10
#define LC_CMD_MSG              13
#define SC_CMD_MSG              41
#define HS_CMD_MSG              46
#define DS_CMD_MSG              59

#define TST_EVS_CMD_MSG         2
#define TST_TIME_CMD_MSG        3
#define TST_SB_CMD_MSG          5
#define TST_TBL_CMD_MSG         6
#define TST_TBL2_CMD_MSG        7
#define QQ_CMD_MSG              8
#define TST_ES_CMD_MSG          9
#define TST_ES2_CMD_MSG         10
#define TST_ES3_CMD_MSG         11
#define TST_ES4_CMD_MSG         12
#define TST_ES5_CMD_MSG         13
#define TST_ES6_CMD_MSG         14
#define TST_ES7_CMD_MSG         15
#define TST_ES8_CMD_MSG         18
#define TST_ES9_CMD_MSG         24
#define TST_ES10_CMD_MSG        25
#define TST_ES11_CMD_MSG        26
#define TST_ES12_CMD_MSG        27
#define TST_ES13_CMD_MSG        28
#define TST_ES14_CMD_MSG        29
#define TST_ES15_CMD_MSG        30
#define TST_ES16_CMD_MSG        31
#define TST_ES17_CMD_MSG        32
#define TST_ES18_CMD_MSG        33
#define TST_ES19_CMD_MSG        34
#define TST_ES20_CMD_MSG        35
#define TST_ES21_CMD_MSG        36
#define TST_ES22_CMD_MSG        37
#define TST_ES23_CMD_MSG        38
#define TST_ES24_CMD_MSG        39


#define TO_SEND_HK_MSG         16
#define CI_SEND_HK_MSG         17
#define SCH_SEND_HK_MSG        18
#define HK_SEND_HK_MSG         26
#define LC_SEND_HK_MSG         29
#define LC_EVAL_WPAP_MSG       30
#define SC_SEND_HK_MSG         42
#define HS_SEND_HK_MSG         47
#define DS_SEND_HK_MSG         60


#define TST_TIME_SEND_HK_MSG    4
#define TST_SB_SEND_HK_MSG     19
#define TST_TBL_SEND_HK_MSG    20
#define TST_TBL2_SEND_HK_MSG   21
#define QQ_SEND_HK_MSG         22
#define TST_ES_SEND_HK_MSG     23
#define TST_ES2_SEND_HK_MSG    40
#define TST_ES3_SEND_HK_MSG    41
#define TST_ES4_SEND_HK_MSG    42
#define TST_ES5_SEND_HK_MSG    43
#define TST_ES6_SEND_HK_MSG    44
#define TST_ES7_SEND_HK_MSG    45
#define TST_ES8_SEND_HK_MSG    46
#define TST_ES9_SEND_HK_MSG    47
#define TST_ES10_SEND_HK_MSG   48
#define TST_ES11_SEND_HK_MSG   49
#define TST_ES12_SEND_HK_MSG   50
#define TST_ES13_SEND_HK_MSG   51
#define TST_ES14_SEND_HK_MSG   52
#define TST_ES15_SEND_HK_MSG   53
#define TST_ES16_SEND_HK_MSG   54
#define TST_ES17_SEND_HK_MSG   55
#define TST_ES18_SEND_HK_MSG   56
#define TST_ES19_SEND_HK_MSG   57
#define TST_ES20_SEND_HK_MSG   58
#define TST_ES21_SEND_HK_MSG   59
#define TST_ES22_SEND_HK_MSG   60
#define TST_ES23_SEND_HK_MSG   61
#define TST_ES24_SEND_HK_MSG   62


/*
** Application Telemetry Message Numbers
** Note: These are not MsgIds, application message ids
**       are located in app_msgids.h
*/
#define TO_HK_TLM_MSG       0
#define CI_HK_TLM_MSG       1
#define SCH_HK_TLM_MSG      2
#define HK_HK_TLM_MSG      10
#define LC_HK_TLM_MSG      13
#define SC_HK_TLM_MSG      42
#define HS_HK_TLM_MSG      45
#define DS_HK_TLM_MSG      56


/*
** Test Application Telemetry Message Numbers
** Note: These are not MsgIds, application message ids
**       are located in app_msgids.h
*/
#define TST_TIME_HK_TLM_MSG       0
#define TST_TIME_TAI_TLM_MSG      1
#define TST_TIME_UTC_TLM_MSG      2
#define TST_TIME_ST_TLM_MSG       3
#define TST_TIME_MET_TLM_MSG      4
#define TST_TIME_METSEC_TLM_MSG   5
#define TST_TIME_METSUB_TLM_MSG   6
#define TST_TIME_STCF_TLM_MSG     7
#define TST_TIME_LPSEC_TLM_MSG    8
#define TST_TIME_CLKST_TLM_MSG    9
#define TST_TIME_ADD_TLM_MSG      10
#define TST_TIME_SUBTIME_TLM_MSG  11
#define TST_TIME_COMP_TLM_MSG     12
#define TST_TIME_SUBMICRO_TLM_MSG 13
#define TST_TIME_MICROSUB_TLM_MSG 14

#define TST_SB_HK_TLM_MSG         15
#define TST_SB_PIPE0_TLM_MSG      16

#define TST_TBL_HK_TLM_MSG        17
#define TST_TBL_MAXTBLST_TLM_MSG  18
#define TST_TBL2_HK_TLM_MSG       19
#define QQ_HK_TLM_MSG             20
#define TST_TBL2_MAXTBLST_TLM_MSG 21
#define TST_TBL_TBLINFO_TLM_MSG   22
#define TST_ES_HK_TLM_MSG         23
#define TST_ES2_HK_TLM_MSG        24
#define TST_ES3_HK_TLM_MSG        25
#define TST_ES4_HK_TLM_MSG        26
#define TST_ES5_HK_TLM_MSG        27
#define TST_ES6_HK_TLM_MSG        28
#define TST_ES7_HK_TLM_MSG        29
#define TST_ES8_HK_TLM_MSG        30
#define TST_ES9_HK_TLM_MSG        31
#define TST_ES10_HK_TLM_MSG       32
#define TST_ES11_HK_TLM_MSG       33
#define TST_ES12_HK_TLM_MSG       34
#define TST_ES13_HK_TLM_MSG       35
#define TST_ES14_HK_TLM_MSG       36
#define TST_ES15_HK_TLM_MSG       37
#define TST_ES16_HK_TLM_MSG       38
#define TST_ES17_HK_TLM_MSG       39
#define TST_ES18_HK_TLM_MSG       40
#define TST_ES19_HK_TLM_MSG       41
#define TST_ES20_HK_TLM_MSG       42
#define TST_ES21_HK_TLM_MSG       43
#define TST_ES22_HK_TLM_MSG       44
#define TST_ES23_HK_TLM_MSG       45
#define TST_ES24_HK_TLM_MSG       46


#define TO_DATA_TYPES_MSG         16
#define SCH_DIAG_TLM_MSG          18

#endif

