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
/************************************************************************
** File:
**   $Id: sch_app_msgids.h  $
**
** Purpose:
**  Define SCH Message IDs
**
** Notes:
**
**
*************************************************************************/
#ifndef _sch_msgids_
#define _sch_msgids_

/*
** Includes
*/
#include "app_mission_cfg.h"


/*
** Application Command Message Id's
*/
#define SCH_CMD_MID          APP_CMD_MID_BASE_CPU1 + SCH_CMD_MSG          /* 0x1882 */
#define SCH_SEND_HK_MID      APP_CMD_MID_BASE_CPU1 + SCH_SEND_HK_MSG      /* 0x1892 */

/*
** Application Telemetry Message Id's
*/
#define SCH_HK_TLM_MID       APP_TLM_MID_BASE_CPU1 + SCH_HK_TLM_MSG       /* 0X0882 */


#endif

/************************/
/*  End of File Comment */
/************************/
