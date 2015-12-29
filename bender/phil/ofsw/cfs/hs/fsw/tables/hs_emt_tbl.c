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
#include "cfe_tbl_filedef.h"  /* Required to obtain the CFE_TBL_FILEDEF macro definition */
#include "hs_tables.h"
#include "hs_task.h"

HS_EventMonitorTable_t EventMonitorTable =
{
    {
        {
            /**** Monitored Event 1 ****/
            .AppName = "SCH",
            .EventId = 2,
            .ActionType = HS_ACTION_APP_RESTART,
        },{
            /**** Monitored Event 2 ****/
            .AppName = "TO",
            .EventId = 7,
            .ActionType = HS_ACTION_SEND_EVENT,
        }
    }
};

/*
** The macro below identifies:
**    1) the data structure type to use as the table image format
**    2) the name of the table to be placed into the cFE Table File Header
**    3) a brief description of the contents of the file image
**    4) the desired name of the table image binary file that is cFE compatible
*/
CFE_TBL_FILEDEF(EventMonitorTable, HS.EMT, HS Event Monitors, hs_emt_tbl.tbl)
