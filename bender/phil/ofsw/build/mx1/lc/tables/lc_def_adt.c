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
            .default_state = ACTIVE,
            .rts_id = 10,
            .max_fail_before_rts = 1,
            .rpn_equation = { 4 },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 22,
            .event_text = "Transition to Approach Targeting",
        },{
            /****       AP # 3          ****/
            /* this AP number is available */
            
        },{
            /****       AP # 4          ****/
            .default_state = ACTIVE,
            .rts_id = 12,
            .max_fail_before_rts = 1,
            .rpn_equation = { 4, 5, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 24,
            .event_text = "Transition to Terminal Descent",
        },{
            /****       AP # 5          ****/
            .default_state = ACTIVE,
            .rts_id = 13,
            .max_fail_before_rts = 1,
            .rpn_equation = { 2, 3, AND, 7, AND, 8, NOT, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 25,
            .event_text = "Transition to surface mode!",
        },{
            /****       AP # 6          ****/
            .default_state = ACTIVE,
            .rts_id = 16,
            .max_fail_before_rts = 1,
            .rpn_equation = { 9 },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 26,
            .event_text = "Main Engine Fire! -> Gimbal Steer Biprop, Vernier Roll",
        },{
            /****       AP # 7          ****/
            .default_state = PASSIVE,
            .rts_id = 15,
            .max_fail_before_rts = 1,
            .rpn_equation = { 10, 11, NOT, AND, 3, NOT, AND, 6, NOT, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 27,
            .event_text = "Coast in Vernier ACS",        
        },{
            /****       AP # 8          ****/
            .default_state = ACTIVE,
            .rts_id = 15,
            .max_fail_before_rts = 1,
            .rpn_equation = { 3, 9, NOT, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 28,
            .event_text = "Terminal, Vernier ACS",   
        },{
           /****       AP # 9          ****/
            .default_state = ACTIVE,
            .rts_id = 17,
            .max_fail_before_rts = 1,
            .rpn_equation = { 14, 12, AND, 13, NOT, AND, 11, NOT, AND, 6, NOT, AND, 3, NOT, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 29,
            .event_text = "Landing Hold",   
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
CFE_TBL_FILEDEF(actionpoint_def_table, LC.ADT, LC Default Actionpoints, lc_def_adt.tbl)
