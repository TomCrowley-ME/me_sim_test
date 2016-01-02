#include "cfe_tbl_filedef.h"  /* Required to obtain the CFE_TBL_FILEDEF macro definition */
#include "sch_task.h"

#include "app_msgids.h"
#include "cfe_msgids.h"

SCH_MessageTable_t message_table =
{
    {
        { SCH_UNUSED_MID },
        { TICK_1HZ_MID,          0xC000, 0x0001, 0x002E },
        { TICK_10HZ_MID,         0xC000, 0x0001, 0x002D },
        { CFE_TIME_SEND_CMD_MID, 0xC000, 0x0001, 0x0044 },
        { CFE_ES_SEND_HK_MID,    0xC000, 0x0001, 0x002E },
        { CFE_EVS_SEND_HK_MID,   0xC000, 0x0001, 0x002F },
        { CFE_SB_SEND_HK_MID,    0xC000, 0x0001, 0x002D },
        { CFE_TBL_SEND_HK_MID,   0xC000, 0x0001, 0x002A },
        { CFE_TIME_SEND_HK_MID,  0xC000, 0x0001, 0x002B },
        { SCH_SEND_HK_MID,       0xC000, 0x0001, 0x00B4 },
        { HK_SEND_HK_MID,        0xC000, 0x0003, 0x003C, HK_HK_TLM_MID},
        { TO_SEND_HK_MID,        0xC000, 0x0001, 0x00B6 },
        { HS_SEND_HK_MID,        0xC000, 0x0001, 0x0089 },
        { SC_SEND_HK_MID,        0xC000, 0x0001, 0x008C },
        { DS_SEND_HK_MID,        0xC000, 0x0001, 0x009A },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
        { SCH_UNUSED_MID },
    }
};

/*
** The macro below identifies:
**    1) the data structure type to use as the table image format
**    2) the name of the table to be placed into the cFE Table File Header
**    3) a brief description of the contents of the file image
**    4) the desired name of the table image binary file that is cFE compatible
*/
CFE_TBL_FILEDEF(message_table, SCH.message_tbl, SCH Message Table Defaults, sch_def_msgtbl.tbl)