#include "cfe_tbl_filedef.h"  /* Required to obtain the CFE_TBL_FILEDEF macro definition */
#include "sch_task.h"

#include "app_msgids.h"
#include "cfe_msgids.h"

#define MSGID_BYTES(x) ((x)>>8), ((x)&0xff)

SCH_MessageTable_t message_table =
{
    {
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(TICK_1HZ_MID),          0xC0, 0x00, 0x00, 0x01, 0xD7, 0x00 },
        { MSGID_BYTES(TICK_10HZ_MID),         0xC0, 0x00, 0x00, 0x01, 0xD6, 0x00 },
        { MSGID_BYTES(TICK_100HZ_MID),        0xC0, 0x00, 0x00, 0x01, 0xD5, 0x00 },
        { MSGID_BYTES(CFE_TIME_SEND_CMD_MID), 0xC0, 0x00, 0x00, 0x01, 0x44, 0x00 },
        { MSGID_BYTES(CFE_ES_SEND_HK_MID),    0xC0, 0x00, 0x00, 0x01, 0x2E, 0x00 },
        { MSGID_BYTES(CFE_EVS_SEND_HK_MID),   0xC0, 0x00, 0x00, 0x01, 0x2F, 0x00 },
        { MSGID_BYTES(CFE_SB_SEND_HK_MID),    0xC0, 0x00, 0x00, 0x01, 0x2D, 0x00 },
        { MSGID_BYTES(CFE_TBL_SEND_HK_MID),   0xC0, 0x00, 0x00, 0x01, 0x2A, 0x00 },
        { MSGID_BYTES(CFE_TIME_SEND_HK_MID),  0xC0, 0x00, 0x00, 0x01, 0x2B, 0x00 },
        { MSGID_BYTES(CSC_SIM_SEND_HK_MID),   0xC0, 0x00, 0x00, 0x01, 0x20, 0x00 },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
        { MSGID_BYTES(SCH_UNUSED_MID) },
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