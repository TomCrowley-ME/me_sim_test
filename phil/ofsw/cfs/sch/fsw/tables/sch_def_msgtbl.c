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

#include "app_msgids.h"
#include "cfe_msgids.h"

SCH_MessageTable_t message_table =
{
    {
        { SCH_UNUSED_MID },
        { CFE_ES_SEND_HK_MID,    0xC000, 0x0001, 0x002E },
        { CFE_EVS_SEND_HK_MID,   0xC000, 0x0001, 0x002F },
        { CFE_SB_SEND_HK_MID,    0xC000, 0x0001, 0x002D },
        { CFE_TBL_SEND_HK_MID,   0xC000, 0x0001, 0x002A },
        { CFE_TIME_SEND_HK_MID,  0xC000, 0x0001, 0x002B },
        { SCH_SEND_HK_MID,       0xC000, 0x0001, 0x00B4 },
        { HK_SEND_HK_MID,        0xC000, 0x0003, 0x003C, HK_HK_TLM_MID},
        { TO_SEND_HK_MID,        0xC000, 0x0001, 0x00B6 },
        { CFE_TIME_SEND_CMD_MID, 0xC000, 0x0001, 0x0044 },
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
