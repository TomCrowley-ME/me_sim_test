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
