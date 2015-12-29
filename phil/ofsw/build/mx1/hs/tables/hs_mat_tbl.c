#include "cfe_tbl_filedef.h"  /* Required to obtain the CFE_TBL_FILEDEF macro definition */
#include "hs_tables.h"

HS_MessageActionTable_t MessageActionTable =
{
    {
        {
            /**** Message Action 1 ****/
            .EnableState = HS_STATE_ENABLED,
            .Cooldown = 0,
            .MsgData = {0x18, 0x80, 0xC0, 0x00, 0x00, 0x01, 0x00, 0xA6},
        },{
            /**** Message Action 2 ****/
            .EnableState = HS_STATE_ENABLED,
            .Cooldown = 5,
            .MsgData = {0x18, 0x82, 0xC0, 0x00, 0x00, 0x01, 0x00, 0xA4},
        },{
            /**** Message Action 3 ****/
            .EnableState = HS_STATE_DISABLED,
        },{
            /**** Message Action 4 ****/
            .EnableState = HS_STATE_DISABLED,
        },{
            /**** Message Action 5 ****/
            .EnableState = HS_STATE_DISABLED,
        },{
            /**** Message Action 6 ****/
            .EnableState = HS_STATE_DISABLED,
        },{
            /**** Message Action 7 ****/
            .EnableState = HS_STATE_DISABLED,
        },{
            /**** Message Action 8 ****/
            .EnableState = HS_STATE_DISABLED,
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
CFE_TBL_FILEDEF(MessageActionTable, HS.MAT, HS Message Actions, hs_mat_tbl.tbl)
