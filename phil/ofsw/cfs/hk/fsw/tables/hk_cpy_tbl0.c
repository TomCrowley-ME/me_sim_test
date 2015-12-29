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
#include "cfe_tbl_filedef.h"
#include "hk_task.h"
#include "cfe_msgids.h"
#include "app_msgids.h"

/* Input MsgId, Input Offset, Output MsgId, Output Offset, Bytes to copy */
HK_CopyTable_t copy_table =
{
    {
        {EST_BUS_MID,  36, 0x0950, 12, 24},
        {GDN_TLM_MID, 124, 0x0950, 36,  8},
    }
};

CFE_TBL_FILEDEF(copy_table, HK.CopyTable, HK Default Copy Table, hk_cpy_tbl0.tbl)
