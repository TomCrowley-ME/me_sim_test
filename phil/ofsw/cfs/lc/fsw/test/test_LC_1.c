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
/* File: test_LC_1.c
 * 
 */

#include "test_LC_common.h"

extern LC_AppData_t LC_AppData;

void gen_test_msgs(){
	CCSDS_CmdPkt_t cmdPkt;

	init_cmd_pkt(&cmdPkt, LC_SEND_HK_MID, 0);
    dump_msg("LC Send HK", (uint8 *) &cmdPkt, sizeof(cmdPkt));

	init_cmd_pkt(&cmdPkt, LC_CMD_MID, LC_NOOP_CC);
    dump_msg("LC NOOP", (uint8 *) &cmdPkt, sizeof(cmdPkt));
}

int main(void) {
    char AppName[10];
    strcpy(AppName, "LC");

    /* gen_test_msgs(); */

    UTF_set_output_filename("test_LC_1.ActualOutput");

    UTF_put_text("test_LC_1: TEST START\n");

    /********************************/
    /* Set up to read in script      */
    /********************************/

    UTF_add_input_file(CFE_LC_CMD_PIPE, "lc_script_1.in");
    LC_AppData.CmdPipe = CFE_LC_CMD_PIPE; /* Hook for application code */
    UTF_add_special_command("LOAD_TABLE_FROM_GROUND", UTF_SCRIPT_LoadTableFromGround);

    UTF_set_packet_handler(LC_HK_TLM_MID, print_lc_housekeeping);

    UTF_add_volume("./", "", FS_BASED, FALSE, FALSE, FALSE, "CF", "/cf", 0);

    /**************************************************/
    /* Initialize time data structures                */
    /**************************************************/
    UTF_init_sim_time(0.0);
    UTF_OSAPI_set_function_hook(OS_GETLOCALTIME_HOOK, time_hook);

    /**************************************************/
    /* Call utility to register task LC with          */
    /* 		Executive Services.                         */
    /**************************************************/
    UTF_ES_InitAppRecords();
    UTF_ES_AddAppRecord(LC_APP_NAME, 0);
    CFE_ES_RegisterApp();

    /**************************************************/
    /* Initialize Table Services data structures      */
    /**************************************************/
    /* Initialize the CDS */
    CFE_ES_CDS_EarlyInit();

    CFE_TBL_EarlyInit();

    /********************************/
    /* Call Main procedure for table owner application*/
    /********************************/
    LC_TaskMain();

    return 0;
}

