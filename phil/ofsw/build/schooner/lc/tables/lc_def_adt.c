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
            .rts_id = 53,
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
            .default_state = PASSIVE,
            .rts_id = 86,
            .max_fail_before_rts = 1,
            .rpn_equation = { 12, 13, OR, 14, OR, 15, OR, 18, AND, 35, AND, 6, NOT, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 26,
            .event_text = "EST lateral posiiton error",
        },{
            /****       AP # 9          ****/
            .default_state = PASSIVE,
            .rts_id = 86,
            .max_fail_before_rts = 1,
            .rpn_equation = {  16, 17, OR, 18, AND, 35, AND, 6, NOT, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 27,
            .event_text = "EST altitude error",
        },{
            /****       AP # 10          ****/
            .default_state = PASSIVE,
            .rts_id = 86,
            .max_fail_before_rts = 1,
            .rpn_equation = { 19, 20, OR, 21, OR, 22, OR, 18, AND, 35, AND, 6, NOT, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 26,
            .event_text = "EST lateral velocity error",
        },{
            /****       AP # 11          ****/
            .default_state = PASSIVE,
            .rts_id = 86,
            .max_fail_before_rts = 1,
            .rpn_equation = {  23, 24, OR, 18, AND, 35, AND, 6, NOT, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 28,
            .event_text = "EST vertical velocity error",
        },{
            /****       AP # 12          ****/
            .default_state = PASSIVE,
            .rts_id = 86,
            .max_fail_before_rts = 1,
            .rpn_equation = { 25, 18, AND, 35, AND, 6, NOT, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 29,
            .event_text = "EST large vehicle tilt error",
        },{
            /****       AP # 13          ****/
            .default_state = PASSIVE,
            .rts_id = 86,
            .max_fail_before_rts = 1,
            .rpn_equation = { 26, 27, OR, 28, OR, 29, OR, 30, OR, 31, OR, 18, AND, 35, AND, 6, NOT, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 30,
            .event_text = "EST high angular rate error",
        },{
            /****       AP # 14          ****/
            .default_state = PASSIVE,
            .rts_id = 86,
            .max_fail_before_rts = 1,
            .rpn_equation = { 32, 18, AND, 35, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 31,
            .event_text = "No valid IMU data received for 1 second",
        },{
            /****       AP # 15          ****/
            .default_state = DISABLED,
            .rts_id = 86,
            .max_fail_before_rts = 5,
            .rpn_equation = { 33 },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 32,
            .event_text = "EGC throttle command at maximum",
        },{
            /****       AP # 16          ****/
            .default_state = DISABLED,
            .rts_id = 86,
            .max_fail_before_rts = 5,
            .rpn_equation = { 34, 18, AND, 35, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 30,
            .event_text = "EST thrust-to-weight over operational limits",
         },{
            /****       AP # 17          ****/
            .default_state = PASSIVE,
            .rts_id = 87,
            .max_fail_before_rts = 5,
            .rpn_equation = { 36 },
            .event_type = CFE_EVS_CRITICAL,
            .event_id = 34,
            .event_text = "HTP tank overpressure--DANGER--opening vent valve!",
          },{
            /****       AP # 18          ****/
            .default_state = PASSIVE,
            .rts_id = 86,
            .max_fail_before_rts = 5,
            .rpn_equation = { 37, 38, OR },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 36,
            .event_text = "EGC chamber pressure measurement failure",
          },{
            /****       AP # 19          ****/
            .default_state = ACTIVE,
            .rts_id = 88,
            .max_fail_before_rts = 100,
            .rpn_equation = { 39, 40, AND },
            .event_type = CFE_EVS_INFORMATION,
            .event_id = 37,
            .event_text = "Hazard bus disarmed, resetting prop deck valve states",
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
CFE_TBL_FILEDEF(actionpoint_def_table, LC_APP.ADT, LC Default Actionpoints, lc_def_adt.tbl)
