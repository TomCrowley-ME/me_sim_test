#include "cfe_tbl_filedef.h"  /* Required to obtain the CFE_TBL_FILEDEF macro definition */
#include "sch_task.h"

/*
 * Each slot has up to 5 entries. Each entry is as folows:
 * { Enable State, Activity Type, Period (in ticks), Remainder (in ticks), Index into Message Table, Group }
 * */
SCH_ScheduleTable_t schedule_table =
{
    {
        {   /* Slot 0 -- Time Sync */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* TIME tone sync */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 1, SCH_GROUP_CFS_HK }, /* 1Hz Tick */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 2, SCH_GROUP_CFS_HK }, /* 10Hz Tick */
        },{ /* Slot 1 -- cFE HK */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 5, 0, 4, SCH_GROUP_CFS_HK },
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 5, 1, 5, SCH_GROUP_CFS_HK },
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 5, 2, 6, SCH_GROUP_CFS_HK },
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 5, 3, 7, SCH_GROUP_CFS_HK },
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 5, 4, 8, SCH_GROUP_CFS_HK },
        },{ /* Slot 2 -- cFS HK */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 3, 0,  9, SCH_GROUP_CFS_HK },
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 3, 1, 10, SCH_GROUP_CFS_HK },
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 3, 2, 11, SCH_GROUP_CFS_HK },
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 12, SCH_GROUP_CFS_HK },
        },{ /* Slot 3 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 13, SCH_GROUP_CFS_HK },
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 14, SCH_GROUP_CFS_HK },
        },{ /* Slot 4 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 2, SCH_GROUP_CFS_HK }, /* 10Hz Tick */
        },{ /* Slot 5 */
            { SCH_UNUSED },
        },{ /* Slot 6 */
            { SCH_UNUSED },
        },{ /* Slot 7 */
            { SCH_UNUSED },
        },{ /* Slot 8 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 2, SCH_GROUP_CFS_HK }, /* 10Hz Tick */
        },{ /* Slot 9 */
            { SCH_UNUSED },
        },{ /* Slot 10 */
            { SCH_UNUSED },
        },{ /* Slot 11 */
            { SCH_UNUSED },
        },{ /* Slot 12 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 2, SCH_GROUP_CFS_HK }, /* 10Hz Tick */
        },{ /* Slot 13 */
            { SCH_UNUSED },
        },{ /* Slot 14 */
            { SCH_UNUSED },
        },{ /* Slot 15 */
            { SCH_UNUSED },
        },{ /* Slot 16 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 2, SCH_GROUP_CFS_HK }, /* 10Hz Tick */
        },{ /* Slot 17 */
            { SCH_UNUSED },
        },{ /* Slot 18 */
            { SCH_UNUSED },
        },{ /* Slot 19 */
            { SCH_UNUSED },
        },{ /* Slot 20 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 2, SCH_GROUP_CFS_HK }, /* 10Hz Tick */
        },{ /* Slot 21 */
            { SCH_UNUSED },
        },{ /* Slot 22 */
            { SCH_UNUSED },
        },{ /* Slot 23 */
            { SCH_UNUSED },
        },{ /* Slot 24 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 2, SCH_GROUP_CFS_HK }, /* 10Hz Tick */
        },{ /* Slot 25 */
            { SCH_UNUSED },
        },{ /* Slot 26 */
            { SCH_UNUSED },
        },{ /* Slot 27 */
            { SCH_UNUSED },
        },{ /* Slot 28 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 2, SCH_GROUP_CFS_HK }, /* 10Hz Tick */
        },{ /* Slot 29 */
            { SCH_UNUSED },
        },{ /* Slot 30 */
            { SCH_UNUSED },
        },{ /* Slot 31 */
            { SCH_UNUSED },
        },{ /* Slot 32 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 2, SCH_GROUP_CFS_HK }, /* 10Hz Tick */
        },{ /* Slot 33 */
            { SCH_UNUSED },
        },{ /* Slot 34 */
            { SCH_UNUSED },
        },{ /* Slot 35 */
            { SCH_UNUSED },
        },{ /* Slot 36 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 2, SCH_GROUP_CFS_HK }, /* 10Hz Tick */
        },{ /* Slot 37 */
            { SCH_UNUSED },
        },{ /* Slot 38 */
            { SCH_UNUSED },
        },{ /* Slot 39 */
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
