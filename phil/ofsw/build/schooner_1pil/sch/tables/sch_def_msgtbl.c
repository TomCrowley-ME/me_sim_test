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
        { MSGID_BYTES(SC_SEND_HK_MID),        0xC0, 0x00, 0x00, 0x01, 0x8C, 0x00 },
        { MSGID_BYTES(CSC_CMP_SEND_HK_MID),   0xC0, 0x00, 0x00, 0x01, 0x22, 0x00 },
        { MSGID_BYTES(CSC_EST_SEND_HK_MID),   0xC0, 0x00, 0x00, 0x01, 0x20, 0x00 },
        { MSGID_BYTES(CSC_GDN_SEND_HK_MID),   0xC0, 0x00, 0x00, 0x01, 0x2E, 0x00 },
        { MSGID_BYTES(CSC_CNT_SEND_HK_MID),   0xC0, 0x00, 0x00, 0x01, 0x2C, 0x00 },
        { MSGID_BYTES(CSC_ACT_SEND_HK_MID),   0xC0, 0x00, 0x00, 0x01, 0x2A, 0x00 },
        { MSGID_BYTES(CSC_EGC_SEND_HK_MID),   0xC0, 0x00, 0x00, 0x01, 0x25, 0x00 },
        { MSGID_BYTES(CSC_SIM_SEND_HK_MID),   0xC0, 0x00, 0x00, 0x01, 0x20, 0x00 },
        { MSGID_BYTES(HS_SEND_HK_MID),        0xC0, 0x00, 0x00, 0x01, 0x89, 0x00 },
        { MSGID_BYTES(EGCIO_SEND_HK_MID),     0xC0, 0x00, 0x00, 0x01, 0x55, 0x00 },
        { MSGID_BYTES(IMUIO_SEND_HK_MID),     0xC0, 0x00, 0x00, 0x01, 0x51, 0x00 },
        { MSGID_BYTES(THRIO_SEND_HK_MID),     0xC0, 0x00, 0x00, 0x01, 0x54, 0x00 },
        { MSGID_BYTES(ADIO_SEND_HK_MID),      0xC0, 0x00, 0x00, 0x01, 0x50, 0x00 },
        { MSGID_BYTES(SCH_SEND_HK_MID),       0xC0, 0x00, 0x00, 0x01, 0xB4, 0x00 },
        { MSGID_BYTES(SIMCI_SEND_HK_MID),     0xC0, 0x00, 0x00, 0x01, 0xB2, 0x00 },
        { MSGID_BYTES(SIMTO_SEND_HK_MID),     0xC0, 0x00, 0x00, 0x01, 0xB4, 0x00 },
        { MSGID_BYTES(LC_EVAL_WPAP_MID),      0xC0, 0x00, 0x00, 0x01, 0xB8, 0x00 },
        { MSGID_BYTES(LC_SEND_HK_MID),        0xC0, 0x00, 0x00, 0x01, 0xBB, 0x00 },
        { MSGID_BYTES(CSC_PCS_SEND_HK_MID),   0xC0, 0x00, 0x00, 0x01, 0x28, 0x00 },
        { MSGID_BYTES(CSC_TCS_SEND_HK_MID),   0xC0, 0x00, 0x00, 0x01, 0x36, 0x00 },
        { MSGID_BYTES(GPSIO_SEND_HK_MID),     0xC0, 0x00, 0x00, 0x01, 0x57, 0x00 },
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
