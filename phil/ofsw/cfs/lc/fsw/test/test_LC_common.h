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
/*
 * test_LC_common.h
 *
 *  Created on: Nov 2, 2014
 *      Author: tklaus
 */

#ifndef CFS_LC_FSW_TEST_TEST_LC_COMMON_H_
#define CFS_LC_FSW_TEST_TEST_LC_COMMON_H_


#include <sys/fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include "cfe.h"
#include "cfe_tbl_task.h"
#include "app_msgids.h"

#include "utf_custom.h"      /* defines UTF_QUEUE_SIZE */
#include "utf_types.h"       /*defines UTF_queue_add() */

#include "cfe_time_utils.h"
#include "utf_cfe_sb.h"          /*defines UTF_set_sb_receive_return_status */
#include "string.h"
#include "cfe_tbl_internal.h"
#include "cfe_es_cds.h"	/* for CFE_ES_CDS_EarlyInit */
#include "utf_osapi.h"
#include "utf_cfe.h"
#include "utf_cfe_sb.h"

#include "lc_task.h"

#include "../tables/cmp_types.h"
#include "../tables/csc_egc_earth_grv_cancel_types.h"

/*
#define CFE_LC_INVALID_CC 55
#define CFE_LC_INVALID_MID 0x12
#define MESSAGE_FORMAT_IS_CCSDS
#define CFE_TBL_NUMBER_OF_TABLES 16
*/

#define CFE_LC_CMD_PIPE     1
#define CFE_LC_TLM_PIPE     2

/* LC_EVAL_WPAP_MID */
typedef struct {
    uint8 cmdHeader[CFE_SB_CMD_HDR_SIZE];
}OS_PACK LC_EvalWpApPacket_t;


/* LC_SEND_HK_MID */
typedef struct {
    uint8 cmdHeader[CFE_SB_CMD_HDR_SIZE];
}OS_PACK LC_RequestHkPacket_t;

/* 4 subtracted to account for SPARC padding added to codegen structs that is removed in csc_sl_interface.h */
#define TLM_HDR_SIZE (CFE_SB_TLM_HDR_SIZE - 4)

/* CMP_BUS_MID */
typedef struct {
    uint8 tlmHeader[TLM_HDR_SIZE];
    cmp_mtv_msg cmpMtvMsg;
}OS_PACK CmpMtvPacket_t;

/* EST_BUS_MID */
typedef struct {
    uint8 tlmHeader[TLM_HDR_SIZE];
    est_mtv_msg estMtvMsg;
}OS_PACK EstMtvPacket_t;

void UTF_SCRIPT_LoadTableFromGround(int argc, char *argv[]);
void print_lc_housekeeping(uint8 source, void *packet);
void time_hook(void);
void dump_msg(char *label, uint8 *msg, int count);
void init_cmd_pkt(CCSDS_CmdPkt_t *packet, uint16 mid, uint16 cmd_code);
void print_uint16_array(char *label, uint16 *array, uint16 count);


#endif /* CFS_LC_FSW_TEST_TEST_LC_COMMON_H_ */
