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

HS_AppMonitorTable_t AppMonitorTable =
{
    {
        {
            /**** Monitored App 1 ****/
            .AppName = "CSC_EST",
            .CycleCount = 5,
            .ActionType = HS_ACTION_APP_RESTART,
        },{
            /**** Monitored App 2 ****/
            .AppName = "CSC_GDN",
            .CycleCount = 2,
            .ActionType = HS_ACTION_SEND_EVENT,
        },{
            /**** Monitored App 3 ****/
            .AppName = "CSC_CNT",
            .CycleCount = 1,
            .ActionType = HS_ACTION_PROCESSOR_RESET,
        },{
            /**** Monitored App 4 ****/
            .AppName = "THRIO",
            .CycleCount = 3,
            .ActionType = 1,
        },{
            /**** Monitored App 5 ****/
            .AppName = "CSC_SC",
            .CycleCount = 5,
            .ActionType = 2,
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
CFE_TBL_FILEDEF(AppMonitorTable, HS.AMT, HS App Monitors, hs_amt_tbl.tbl)
