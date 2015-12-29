#include "cfe_tbl_filedef.h"  /* Required to obtain the CFE_TBL_FILEDEF macro definition */
#include "lc_task.h"

#include "app_msgids.h"
#include "cfe_msgids.h"

#include <stdio.h>
#include <stddef.h>

/* Temporary direct include for samples -- will need to make overall bus header later */
#include "../../../../../wsim/mtv/csc_gdn_guidance/csc_gdn_guidance_types.h"
#include "../../../../../wsim/mtv/csc_cnt_attitude_control/csc_cnt_attitude_control_types.h"
#include "../../../../../wsim/mtv/csc_est_state_est_mtv/csc_est_state_est_mtv_types.h"

/* Temporary include for CMP enumerated types until we can get these out of code gen */
#include "cmp_types.h"

LC_WatchpointDefinitionTable_t watchpoint_def_table =
{
    {
        {
            /****       WP # 1          ****/
            .data_type = LC_UINT8,
            .operator_id = EQUAL_TO,
            .message_id = CMP_MTV_MID,
            .offset = BUS_OFFSET(cmp_mtv_msg, mode),
            .bitmask = 0,
            .value.u8 = MODE__STARTUP,
        },
        {
            /****       WP # 2          ****/
            .data_type = LC_UINT8,
            .operator_id = EQUAL_TO,
            .message_id = CMP_MTV_MID,
            .offset = BUS_OFFSET(cmp_mtv_msg, mode),
            .bitmask = 0,
            .value.u8 = MODE__LANDING,
        },
        {
            /****       WP # 3          ****/
            .data_type = LC_UINT8,
            .operator_id = EQUAL_TO,
            .message_id = CMP_MTV_MID,
            .offset = BUS_OFFSET(cmp_mtv_msg, submode),
            .bitmask = 0,
            .value.u8 = SUBMODE__LANDING_TERMINAL,
        },{
            /****       WP # 4          ****/
        },{
            /****       WP # 5          ****/
        },{
            /****       WP # 6          ****/
            .data_type = LC_UINT8,
            .operator_id = EQUAL_TO,
            .message_id = CMP_MTV_MID,
            .offset = BUS_OFFSET(cmp_mtv_msg, mode),
            .bitmask = 0,
            .value.u8 = MODE__SURFACE,
        },{
            /****       WP # 7          ****/
            .data_type = LC_UINT8,
            .operator_id = NOT_EQUAL_TO,
            .message_id = EST_MTV_MID,
            .offset = BUS_OFFSET(est_mtv_msg, landed),
            .bitmask = 0,
            .value.u8 = 0,
        },{
            /****       WP # 8          ****/
            .data_type = LC_UINT8,
            .operator_id = EQUAL_TO,
            .message_id = CMP_MTV_MID,
            .offset = BUS_OFFSET(cmp_mtv_msg, takeoff_enable),
            .bitmask = 0,
            .value.u8 = 1,
        },{
            /****       WP # 9          ****/
        },{
            /****       WP # 10         ****/
        },{
            /****       WP # 11          ****/
        },{
            /****       WP # 12          ****/
            .data_type = LC_DOUBLE,
            .operator_id = LESS_THAN,
            .message_id = EST_MTV_MID ,
            .offset = BUS_OFFSET(est_mtv_msg, pos[0]),
            .bitmask = 0,
            .value.f64 = -0.5,
        },{
            /****       WP # 13          ****/
            .data_type = LC_DOUBLE,
            .operator_id = GREATER_THAN,
            .message_id = EST_MTV_MID ,
            .offset = BUS_OFFSET(est_mtv_msg, pos[0]),
            .bitmask = 0,
            .value.f64 = 0.5,
        },{
            /****       WP # 14          ****/
            .data_type = LC_DOUBLE,
            .operator_id = LESS_THAN,
            .message_id = EST_MTV_MID ,
            .offset = BUS_OFFSET(est_mtv_msg, pos[1]),
            .bitmask = 0,
            .value.f64 = -0.5,
        },{
            /****       WP # 15          ****/
            .data_type = LC_DOUBLE,
            .operator_id = GREATER_THAN,
            .message_id = EST_MTV_MID ,
            .offset = BUS_OFFSET(est_mtv_msg, pos[1]),
            .bitmask = 0,
            .value.f64 = 0.5,
        },{
            /****       WP # 16          ****/
            .data_type = LC_DOUBLE,
            .operator_id = LESS_THAN,
            .message_id = EST_MTV_MID ,
            .offset = BUS_OFFSET(est_mtv_msg, altitude),
            .bitmask = 0,
            .value.f64 = -0.5,
        },{
            /****       WP # 17          ****/
            .data_type = LC_DOUBLE,
            .operator_id = GREATER_THAN,
            .message_id = EST_MTV_MID ,
            .offset = BUS_OFFSET(est_mtv_msg, altitude),
            .bitmask = 0,
            .value.f64 = 1.5,
        },{
            /****       WP # 18          ****/
            .data_type = LC_UINT8,
            .operator_id = EQUAL_TO,
            .message_id = CMP_MTV_MID,
            .offset = BUS_OFFSET(cmp_mtv_msg, est_ref_frame),
            .bitmask = 0,
            .value.u8 = REFERENCE_FRAME__TOPOCENTRIC,
       },{
            /****       WP # 19          ****/
            .data_type = LC_DOUBLE,
            .operator_id = LESS_THAN,
            .message_id = EST_MTV_MID ,
            .offset = BUS_OFFSET(est_mtv_msg, vel[0]),
            .bitmask = 0,
            .value.f64 = -0.3,
        },{
            /****       WP # 20          ****/
            .data_type = LC_DOUBLE,
            .operator_id = GREATER_THAN,
            .message_id = EST_MTV_MID ,
            .offset = BUS_OFFSET(est_mtv_msg, vel[0]),
            .bitmask = 0,
            .value.f64 = 0.3,
        },{
            /****       WP # 21          ****/
            .data_type = LC_DOUBLE,
            .operator_id = LESS_THAN,
            .message_id = EST_MTV_MID ,
            .offset = BUS_OFFSET(est_mtv_msg, vel[1]),
            .bitmask = 0,
            .value.f64 = -0.3,
        },{
            /****       WP # 22          ****/
            .data_type = LC_DOUBLE,
            .operator_id = GREATER_THAN,
            .message_id = EST_MTV_MID ,
            .offset = BUS_OFFSET(est_mtv_msg, vel[1]),
            .bitmask = 0,
            .value.f64 = 0.3,
        },{
            /****       WP # 23          ****/
            .data_type = LC_DOUBLE,
            .operator_id = LESS_THAN,
            .message_id = EST_MTV_MID ,
            .offset = BUS_OFFSET(est_mtv_msg, vel[2]),
            .bitmask = 0,
            .value.f64 = -1.0,
        },{
            /****       WP # 24          ****/
            .data_type = LC_DOUBLE,
            .operator_id = GREATER_THAN,
            .message_id = EST_MTV_MID ,
            .offset = BUS_OFFSET(est_mtv_msg, vel[2]),
            .bitmask = 0,
            .value.f64 = 1.0,
        },{
            /****       WP # 25          ****/
            .data_type = LC_DOUBLE,
            .operator_id = GREATER_THAN,
            .message_id = EST_MTV_MID ,
            .offset = BUS_OFFSET(est_mtv_msg, angle_off_vertical),
            .bitmask = 0,
            .value.f64 = 5,
        },{
            /****       WP # 26          ****/
            .data_type = LC_DOUBLE,
            .operator_id = LESS_THAN,
            .message_id = EST_MTV_MID ,
            .offset = BUS_OFFSET(est_mtv_msg, rate[0]),
            .bitmask = 0,
            .value.f64 = -0.6981,
        },{
            /****       WP # 27          ****/
            .data_type = LC_DOUBLE,
            .operator_id = GREATER_THAN,
            .message_id = EST_MTV_MID ,
            .offset = BUS_OFFSET(est_mtv_msg, rate[0]),
            .bitmask = 0,
            .value.f64 = 0.6981,
        },{
            /****       WP # 28          ****/
            .data_type = LC_DOUBLE,
            .operator_id = LESS_THAN,
            .message_id = EST_MTV_MID ,
            .offset = BUS_OFFSET(est_mtv_msg, rate[1]),
            .bitmask = 0,
            .value.f64 = -0.6981,
        },{
            /****       WP # 29          ****/
            .data_type = LC_DOUBLE,
            .operator_id = GREATER_THAN,
            .message_id = EST_MTV_MID ,
            .offset = BUS_OFFSET(est_mtv_msg, rate[1]),
            .bitmask = 0,
            .value.f64 = 0.6981,
        },{
            /****       WP # 30          ****/
            .data_type = LC_DOUBLE,
            .operator_id = LESS_THAN,
            .message_id = EST_MTV_MID ,
            .offset = BUS_OFFSET(est_mtv_msg, rate[2]),
            .bitmask = 0,
            .value.f64 = -0.6981,
        },{
            /****       WP # 31          ****/
            .data_type = LC_DOUBLE,
            .operator_id = GREATER_THAN,
            .message_id = EST_MTV_MID ,
            .offset = BUS_OFFSET(est_mtv_msg, rate[2]),
            .bitmask = 0,
            .value.f64 = 0.6981,
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
CFE_TBL_FILEDEF(watchpoint_def_table, LC_APP.WDT, LC Default Watchpoints, lc_def_wdt.tbl)
