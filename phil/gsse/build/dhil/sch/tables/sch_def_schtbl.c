#include "cfe_tbl_filedef.h"  /* Required to obtain the CFE_TBL_FILEDEF macro definition */
#include "sch_task.h"

/*
 * Each slot has up to 5 entries. Each entry is as folows:
 * { Enable State, Activity Type, Period (in ticks), Remainder (in ticks), Index into Message Table, Group }
 * */
SCH_ScheduleTable_t schedule_table =
{
    {
        {   /* Slot 0 -- time sync commands */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 4, SCH_GROUP_CFS_HK }, /* TIME tone sync */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 1, SCH_GROUP_CFS_HK }, /* 1Hz Tick */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 1 -- Some cFE HK */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 5, 0, 5, SCH_GROUP_CFS_HK },
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 5, 1, 6, SCH_GROUP_CFS_HK },
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 5, 2, 7, SCH_GROUP_CFS_HK },
        },{ /* Slot 2 -- Some more cFE HK*/
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 5, 3, 8, SCH_GROUP_CFS_HK },
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 5, 4, 9, SCH_GROUP_CFS_HK },
            { SCH_UNUSED },
        },{ /* Slot 3 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 4 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 5 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 6 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 7 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 8 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 9 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 10 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 11 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 12 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 13 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 14 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 15 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 16 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 17 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 18 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 19 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 20 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 21 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 22 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 23 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 24 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 25 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 26 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 27 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 28 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 29 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 30 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 31 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 32 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 33 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 34 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 35 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 36 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 37 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 38 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 39 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 40 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 41 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 42 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 43 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 44 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 45 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 46 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 47 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 48 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 49 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 50 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 51 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 52 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 53 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 54 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 55 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 56 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 57 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 58 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 59 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 60 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 61 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 62 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 63 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 64 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 65 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 66 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 67 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 68 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 69 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 70 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 71 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 72 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 73 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 74 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 75 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 76 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 77 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 78 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 79 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 80 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 81 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 82 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 83 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 84 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 85 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 86 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 87 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 88 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 89 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 90 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 91 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 92 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 93 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 94 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 95 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 96 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 97 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 98 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
        },{ /* Slot 99 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 3, SCH_GROUP_CFS_HK }, /* 100Hz Tick */
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
