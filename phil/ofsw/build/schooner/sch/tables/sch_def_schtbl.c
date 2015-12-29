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
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 2, SCH_GROUP_CFS_HK }, /* 10Hz Tick */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 25, SCH_GROUP_CFS_HK }, /* LC eval */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 17, SCH_GROUP_CFS_HK }, /* HS HK */
        },{ /* Slot 1 -- Some cFE HK */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 5, 0, 5, SCH_GROUP_CFS_HK },
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 5, 1, 6, SCH_GROUP_CFS_HK },
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 5, 2, 7, SCH_GROUP_CFS_HK },
        },{ /* Slot 2 -- Some more cFE HK*/
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 5, 3, 8, SCH_GROUP_CFS_HK },
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 5, 4, 9, SCH_GROUP_CFS_HK },
            { SCH_UNUSED },
        },{ /* Slot 3 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 10, SCH_GROUP_CFS_HK }, /* SC HK */
        },{ /* Slot 4 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 11, SCH_GROUP_CFS_HK }, /* CMP HK */
        },{ /* Slot 5 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 12, SCH_GROUP_CFS_HK }, /* EST HK */
        },{ /* Slot 6 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 13, SCH_GROUP_CFS_HK }, /* GDN HK */
        },{ /* Slot 7 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 14, SCH_GROUP_CFS_HK }, /* CNT HK */
        },{ /* Slot 8 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 15, SCH_GROUP_CFS_HK }, /* ACT HK */
        },{ /* Slot 9 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 16, SCH_GROUP_CFS_HK }, /* EGC HK */
        },{ /* Slot 10 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 2, SCH_GROUP_CFS_HK }, /* 10Hz Tick */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 25, SCH_GROUP_CFS_HK }, /* LC eval */
        },{ /* Slot 11 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 18, SCH_GROUP_CFS_HK }, /* EGCIO HK */
        },{ /* Slot 12 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 19, SCH_GROUP_CFS_HK }, /* IMUIO HK */
        },{ /* Slot 13 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 20, SCH_GROUP_CFS_HK }, /* THRIO HK */
        },{ /* Slot 14 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 21, SCH_GROUP_CFS_HK }, /* ADIO HK */
        },{ /* Slot 15 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 22, SCH_GROUP_CFS_HK }, /* SCH HK */
        },{ /* Slot 16 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 23, SCH_GROUP_CFS_HK }, /* SCH HK */
        },{ /* Slot 17 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 24, SCH_GROUP_CFS_HK }, /* SCH HK */
        },{ /* Slot 18 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 26, SCH_GROUP_CFS_HK }, /* LC HK */
        },{ /* Slot 19 */
            { SCH_UNUSED },
        },{ /* Slot 20 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 2, SCH_GROUP_CFS_HK }, /* 10Hz Tick */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 25, SCH_GROUP_CFS_HK }, /* LC eval */
        },{ /* Slot 21 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 27, SCH_GROUP_CFS_HK }, /* PCS HK */
        },{ /* Slot 22 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 28, SCH_GROUP_CFS_HK }, /* TCS HK */
        },{ /* Slot 23 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 29, SCH_GROUP_CFS_HK }, /* GPSIO HK */
        },{ /* Slot 24 */
            { SCH_UNUSED },
        },{ /* Slot 25 */
            { SCH_UNUSED },
        },{ /* Slot 26 */
            { SCH_UNUSED },
        },{ /* Slot 27 */
            { SCH_UNUSED },
        },{ /* Slot 28 */
            { SCH_UNUSED },
        },{ /* Slot 29 */
            { SCH_UNUSED },
        },{ /* Slot 30 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 2, SCH_GROUP_CFS_HK }, /* 10Hz Tick */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 25, SCH_GROUP_CFS_HK }, /* LC eval */
        },{ /* Slot 31 */
            { SCH_UNUSED },
        },{ /* Slot 32 */
            { SCH_UNUSED },
        },{ /* Slot 33 */
            { SCH_UNUSED },
        },{ /* Slot 34 */
            { SCH_UNUSED },
        },{ /* Slot 35 */
            { SCH_UNUSED },
        },{ /* Slot 36 */
            { SCH_UNUSED },
        },{ /* Slot 37 */
            { SCH_UNUSED },
        },{ /* Slot 38 */
            { SCH_UNUSED },
        },{ /* Slot 39 */
            { SCH_UNUSED },
        },{ /* Slot 40 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 2, SCH_GROUP_CFS_HK }, /* 10Hz Tick */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 25, SCH_GROUP_CFS_HK }, /* LC eval */
        },{ /* Slot 41 */
            { SCH_UNUSED },
        },{ /* Slot 42 */
            { SCH_UNUSED },
        },{ /* Slot 43 */
            { SCH_UNUSED },
        },{ /* Slot 44 */
            { SCH_UNUSED },
        },{ /* Slot 45 */
            { SCH_UNUSED },
        },{ /* Slot 46 */
            { SCH_UNUSED },
        },{ /* Slot 47 */
            { SCH_UNUSED },
        },{ /* Slot 48 */
            { SCH_UNUSED },
        },{ /* Slot 49 */
            { SCH_UNUSED },
        },{ /* Slot 50 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 2, SCH_GROUP_CFS_HK }, /* 10Hz Tick */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 25, SCH_GROUP_CFS_HK }, /* LC eval */
        },{ /* Slot 51 */
            { SCH_UNUSED },
        },{ /* Slot 52 */
            { SCH_UNUSED },
        },{ /* Slot 53 */
            { SCH_UNUSED },
        },{ /* Slot 54 */
            { SCH_UNUSED },
        },{ /* Slot 55 */
            { SCH_UNUSED },
        },{ /* Slot 56 */
            { SCH_UNUSED },
        },{ /* Slot 57 */
            { SCH_UNUSED },
        },{ /* Slot 58 */
            { SCH_UNUSED },
        },{ /* Slot 59 */
            { SCH_UNUSED },
        },{ /* Slot 60 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 2, SCH_GROUP_CFS_HK }, /* 10Hz Tick */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 25, SCH_GROUP_CFS_HK }, /* LC eval */
        },{ /* Slot 61 */
            { SCH_UNUSED },
        },{ /* Slot 62 */
            { SCH_UNUSED },
        },{ /* Slot 63 */
            { SCH_UNUSED },
        },{ /* Slot 64 */
            { SCH_UNUSED },
        },{ /* Slot 65 */
            { SCH_UNUSED },
        },{ /* Slot 66 */
            { SCH_UNUSED },
        },{ /* Slot 67 */
            { SCH_UNUSED },
        },{ /* Slot 68 */
            { SCH_UNUSED },
        },{ /* Slot 69 */
            { SCH_UNUSED },
        },{ /* Slot 70 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 2, SCH_GROUP_CFS_HK }, /* 10Hz Tick */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 25, SCH_GROUP_CFS_HK }, /* LC eval */
        },{ /* Slot 71 */
            { SCH_UNUSED },
        },{ /* Slot 72 */
            { SCH_UNUSED },
        },{ /* Slot 73 */
            { SCH_UNUSED },
        },{ /* Slot 74 */
            { SCH_UNUSED },
        },{ /* Slot 75 */
            { SCH_UNUSED },
        },{ /* Slot 76 */
            { SCH_UNUSED },
        },{ /* Slot 77 */
            { SCH_UNUSED },
        },{ /* Slot 78 */
            { SCH_UNUSED },
        },{ /* Slot 79 */
            { SCH_UNUSED },
        },{ /* Slot 80 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 2, SCH_GROUP_CFS_HK }, /* 10Hz Tick */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 25, SCH_GROUP_CFS_HK }, /* LC eval */
        },{ /* Slot 81 */
            { SCH_UNUSED },
        },{ /* Slot 82 */
            { SCH_UNUSED },
        },{ /* Slot 83 */
            { SCH_UNUSED },
        },{ /* Slot 84 */
            { SCH_UNUSED },
        },{ /* Slot 85 */
            { SCH_UNUSED },
        },{ /* Slot 86 */
            { SCH_UNUSED },
        },{ /* Slot 87 */
            { SCH_UNUSED },
        },{ /* Slot 88 */
            { SCH_UNUSED },
        },{ /* Slot 89 */
            { SCH_UNUSED },
        },{ /* Slot 90 */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 2, SCH_GROUP_CFS_HK }, /* 10Hz Tick */
            { SCH_ENABLED,  SCH_ACTIVITY_SEND_MSG, 1, 0, 25, SCH_GROUP_CFS_HK }, /* LC eval */
        },{ /* Slot 91 */
            { SCH_UNUSED },
        },{ /* Slot 92 */
            { SCH_UNUSED },
        },{ /* Slot 93 */
            { SCH_UNUSED },
        },{ /* Slot 94 */
            { SCH_UNUSED },
        },{ /* Slot 95 */
            { SCH_UNUSED },
        },{ /* Slot 96 */
            { SCH_UNUSED },
        },{ /* Slot 97 */
            { SCH_UNUSED },
        },{ /* Slot 98 */
            { SCH_UNUSED },
        },{ /* Slot 99 */
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
