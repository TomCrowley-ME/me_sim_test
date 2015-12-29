#include "cfe_tbl_filedef.h"  /* Required to obtain the CFE_TBL_FILEDEF macro definition */
#include "lc_task.h"

#include "app_msgids.h"
#include "cfe_msgids.h"

#include <stdio.h>
#include <stddef.h>

/* Temporary direct include for samples -- will need to make overall bus header later */
#include "../../../../../wsim/csc_gdn_guidance/csc_gdn_guidance_types.h"
#include "../../../../../wsim/csc_cnt_attitude_control/csc_cnt_attitude_control_types.h"

/* Temporary include for CMP enumerated types until we can get these out of code gen */
#include "cmp_types.h"

LC_WatchpointDefinitionTable_t watchpoint_def_table =
{
    {
        {
            /****       WP # 1          ****/
            .data_type = LC_UINT8,
            .operator_id = EQUAL_TO,
            .message_id = CMP_BUS_MID,
            .offset = BUS_OFFSET(cmp_bus_msg, mode),
            .bitmask = 0,
            .value.u8 = MODE__STARTUP,
        },
        {
            /****       WP # 2          ****/
            .data_type = LC_UINT8,
            .operator_id = EQUAL_TO,
            .message_id = CMP_BUS_MID,
            .offset = BUS_OFFSET(cmp_bus_msg, mode),
            .bitmask = 0,
            .value.u8 = MODE__LANDING,
        },
        {
            /****       WP # 3          ****/
            .data_type = LC_UINT8,
            .operator_id = EQUAL_TO,
            .message_id = CMP_BUS_MID,
            .offset = BUS_OFFSET(cmp_bus_msg, submode),
            .bitmask = 0,
            .value.u8 = SUBMODE__LANDING_TERMINAL,
        },{
            /****       WP # 4          ****/
            .data_type = LC_UINT8,
            .operator_id = NOT_EQUAL_TO,
            .message_id = GDN_BUS_MID,
            .offset = BUS_OFFSET(gdn_bus_msg, hold_complete),
            .bitmask = 0,
            .value.u8 = 0,
        },{
            /****       WP # 5          ****/
            .data_type = LC_UINT8,
            .operator_id = NOT_EQUAL_TO,
            .message_id = GDN_BUS_MID,
            .offset = BUS_OFFSET(gdn_bus_msg, targeting_complete),
            .bitmask = 0,
            .value.u8 = 0,
        },{
            /****       WP # 6          ****/
            .data_type = LC_UINT8,
            .operator_id = EQUAL_TO,
            .message_id = CMP_BUS_MID,
            .offset = BUS_OFFSET(cmp_bus_msg, mode),
            .bitmask = 0,
            .value.u8 = MODE__SURFACE,
        },{
            /****       WP # 7          ****/
            .data_type = LC_UINT8,
            .operator_id = NOT_EQUAL_TO,
            .message_id = EST_BUS_MID,
            .offset = BUS_OFFSET(est_bus_msg, landed),
            .bitmask = 0,
            .value.u8 = 0,
        },{
            /****       WP # 8          ****/
            .data_type = LC_UINT8,
            .operator_id = EQUAL_TO,
            .message_id = CMP_BUS_MID,
            .offset = BUS_OFFSET(cmp_bus_msg, takeoff_enable),
            .bitmask = 0,
            .value.u8 = 1,
        },{
            /****       WP # 9          ****/
            .data_type = LC_UINT8,
            .operator_id = EQUAL_TO,
            .message_id = CNT_BUS_MID,
            .offset = BUS_OFFSET(cnt_bus_msg, main_thruster_cmd),
            .bitmask = 0,
            .value.u8 = 100,
        },{
            /****       WP # 10         ****/
            .data_type = LC_UINT8,
            .operator_id = EQUAL_TO,
            .message_id = CNT_BUS_MID,
            .offset = BUS_OFFSET(cnt_bus_msg, main_thruster_cmd),
            .bitmask = 0,
            .value.u8 = 0,
        },{
            /****       WP # 11          ****/
            .data_type = LC_UINT8,
            .operator_id = EQUAL_TO,
            .message_id = CMP_BUS_MID,
            .offset = BUS_OFFSET(cmp_bus_msg, submode),
            .bitmask = 0,
            .value.u8 = SUBMODE__LANDING_TARGETING,
        }
    }
};

/* Set .data_type = {LC_UINT8, LC_UINT16, LC_UINT32,
 *                   LC_INT8,  LC_INT16,  LC_INT32,
 *                   LC_FLOAT, LC_DOUBLE }
 *
 * Change .value.** {.u8,      .u16,      .u32,
 *                   .i8,      .i16,      .i32,
 *                   .f32,     .f64 }
 *
 *  Possible operators:     EQUAL_TO,
                            NOT_EQUAL_TO,
                            LESS_THAN,
                            LESS_THAN_OR_EQUAL_TO,
                            GREATER_THAN_OR_EQUAL_TO,
                            GREATER_THAN
 */


/*
** The macro below identifies:
**    1) the data structure type to use as the table image format
**    2) the name of the table to be placed into the cFE Table File Header
**    3) a brief description of the contents of the file image
**    4) the desired name of the table image binary file that is cFE compatible
*/
CFE_TBL_FILEDEF(watchpoint_def_table, LC.WDT, LC Default Watchpoints, lc_def_wdt.tbl)
