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
#include "lc_task.h"

#include "app_msgids.h"
#include "cfe_msgids.h"

#include <stdio.h>
#include <stddef.h>

LC_ActionpointDefinitionTable_t actionpoint_def_table =
{
    {
        {
            /****       AP # 1          ****/
            .default_state = DISABLED,
            .rts_id = 1,
            .max_fail_before_rts = 1,
            .rpn_equation = { 1 },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 21,
            .event_text = "Executing startup RTS...",
        },{
            /****       AP # 2          ****/
        },{
            /****       AP # 3          ****/
            /* this AP number is available */

        },{
            /****       AP # 4          ****/
        },{
            /****       AP # 5          ****/
            .default_state = ACTIVE,
            .rts_id = 13,
            .max_fail_before_rts = 1,
            .rpn_equation = { 2, 3, AND, 7, AND, 8, NOT, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 25,
            .event_text = "Transitioning to surface mode!",
        },{
            /****       AP # 6          ****/
        },{
            /****       AP # 7          ****/
},{
            /****       AP # 8          ****/
            .default_state = ACTIVE,
            .rts_id = 86,
            .max_fail_before_rts = 1,
            .rpn_equation = { 12, 13, OR, 14, OR, 15, OR, 18, AND, 35, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 26,
            .event_text = "EST lateral posiiton error",
        },{
            /****       AP # 9          ****/
            .default_state = ACTIVE,
            .rts_id = 86,
            .max_fail_before_rts = 1,
            .rpn_equation = {  16, 17, OR, 18, AND, 35, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 27,
            .event_text = "EST altitude error",
        },{
            /****       AP # 10          ****/
            .default_state = ACTIVE,
            .rts_id = 86,
            .max_fail_before_rts = 1,
            .rpn_equation = { 19, 20, OR, 21, OR, 22, OR, 18, AND, 35, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 26,
            .event_text = "EST lateral velocity error",
        },{
            /****       AP # 11          ****/
            .default_state = ACTIVE,
            .rts_id = 86,
            .max_fail_before_rts = 1,
            .rpn_equation = {  23, 24, OR, 18, AND, 35, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 28,
            .event_text = "EST vertical velocity error",
        },{
            /****       AP # 12          ****/
            .default_state = ACTIVE,
            .rts_id = 86,
            .max_fail_before_rts = 1,
            .rpn_equation = { 25, 18, AND, 35, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 29,
            .event_text = "EST large vehicle tilt error",
        },{
            /****       AP # 13          ****/
            .default_state = ACTIVE,
            .rts_id = 86,
            .max_fail_before_rts = 1,
            .rpn_equation = { 26, 27, OR, 28, OR, 29, OR, 30, OR, 31, OR, 18, AND, 35, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 30,
            .event_text = "EST high angular rate error",
        },{
            /****       AP # 14          ****/
            .default_state = ACTIVE,
            .rts_id = 86,
            .max_fail_before_rts = 1,
            .rpn_equation = { 32, 18, AND, 35, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 31,
            .event_text = "No valid IMU data recd for 1 second",
        },{
            /****       AP # 15          ****/
            .default_state = ACTIVE,
            .rts_id = 86,
            .max_fail_before_rts = 1,
            .rpn_equation = { 33 },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 32,
            .event_text = "EGC throttle command at maximum",
        },{
            /****       AP # 16          ****/
            .default_state = ACTIVE,
            .rts_id = 86,
            .max_fail_before_rts = 1,
            .rpn_equation = { 34, 18, AND, 35, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 30,
            .event_text = "EST thrust-to-weight over op limits",
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
CFE_TBL_FILEDEF(actionpoint_def_table, LC_APP.ADT, LC Default Actionpoints, lc_def_adt.tbl)
