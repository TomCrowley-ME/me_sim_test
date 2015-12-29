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
