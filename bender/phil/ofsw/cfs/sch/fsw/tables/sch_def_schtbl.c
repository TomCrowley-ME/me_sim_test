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
#include "sch_task.h"

/*
 * Each slot has up to 5 entries. Each entry is as folows:
 * { Enable State, Activity Type, Period (in ticks), Remainder (in ticks), Index into Message Table, Group }
 * */
SCH_ScheduleTable_t schedule_table =
{
    {
        {   /* Slot 0 -- cFE core service HK */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 9, SCH_GROUP_CFS_HK },
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 5, 1, 2, SCH_GROUP_CFS_HK },
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 5, 2, 3, SCH_GROUP_CFS_HK },
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 5, 3, 4, SCH_GROUP_CFS_HK },
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 5, 4, 5, SCH_GROUP_CFS_HK },
        },{ /* Slot 1 -- cFS apps */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 2, 0, 6, SCH_GROUP_CFS_HK },
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 3, 1, 7, SCH_GROUP_CFS_HK },
        },{ /* Slot 2*/
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 2, 1, 8, SCH_GROUP_CFS_HK },
        },{ /* Slot 3 */
            { SCH_UNUSED },
        },
    }
};

/*
** The macro below identifies:
**    1) the data structure type to use as the table image format
**    2) the name of the table to be placed into the cFE Table File Header
**    3) a brief description of the contents of the file image
**    4) the desired name of the table image binary file that is cFE compatible
*/
CFE_TBL_FILEDEF(schedule_table, SCH.schedule_tbl, SCH Schedule Table Defaults, sch_def_schtbl.tbl)
