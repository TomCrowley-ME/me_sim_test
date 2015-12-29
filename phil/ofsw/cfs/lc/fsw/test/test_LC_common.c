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
 * test_LC_common.c
 *
 *  Created on: Nov 2, 2014
 *      Author: tklaus
 */

#include "test_LC_common.h"

void UTF_SCRIPT_LoadTableFromGround(int argc, char *argv[]) {
    char Table_Name[30], File_Name[50];
    /*	UTF_put_text("Entered UTF_SCRIPT_LoadTableFromGround\n"); */
    if (argc != 3) {
        UTF_error("Error: Read %d args w/script cmd LOAD_TABLE_FROM_GROUND. Expected 2.\n", argc - 1);
        UTF_exit();
    }

    strcpy(Table_Name, argv[1]);
    strcpy(File_Name, argv[2]);
    UTF_put_text("Table_Name is %s\n", Table_Name);
    UTF_put_text("File_Name is %s\n", File_Name);
    UTF_TBL_LoadTableFromGround(Table_Name, File_Name);
    return;
}

void print_lc_housekeeping(uint8 source, void *packet) {

    LC_HkPacket_t *LC_HKStatusPkt = (LC_HkPacket_t *) packet;

    /* Output the LC housekeeping data */
    UTF_put_text("LC HOUSEKEEPING DATA:\n");

    UTF_put_text("CurrentLcState = %d\n", LC_HKStatusPkt->CurrentLcState);
    UTF_put_text("CmdCount = %d\n", LC_HKStatusPkt->CmdCount);
    UTF_put_text("ErrCount = %d\n", LC_HKStatusPkt->ErrCount);

    UTF_put_text("WpAllEvalTrueCount = %d\n", LC_HKStatusPkt->WpAllEvalTrueCount);
    UTF_put_text("WpAllEvalFalseCount = %d\n", LC_HKStatusPkt->WpAllEvalFalseCount);
    UTF_put_text("ApAllPassCount = %d\n", LC_HKStatusPkt->ApAllPassCount);
    UTF_put_text("ApAllFailCount = %d\n", LC_HKStatusPkt->ApAllFailCount);
    UTF_put_text("AllRTSExecCount = %d\n", LC_HKStatusPkt->AllRTSExecCount);

    print_uint16_array("WpLastEvalResult", LC_HKStatusPkt->WpLastEvalResult, LC_MAX_WATCHPOINTS);
    print_uint16_array("WpEvalCount", LC_HKStatusPkt->WpEvalCount, LC_MAX_WATCHPOINTS);
    print_uint16_array("WpFalseToTrueCount", LC_HKStatusPkt->WpFalseToTrueCount, LC_MAX_WATCHPOINTS);
    print_uint16_array("WpConsecutiveTrueCount", LC_HKStatusPkt->WpConsecutiveTrueCount, LC_MAX_WATCHPOINTS);
    print_uint16_array("WpCumulativeTrueCount", LC_HKStatusPkt->WpCumulativeTrueCount, LC_MAX_WATCHPOINTS);

    print_uint16_array("ApLastEvalResult", LC_HKStatusPkt->ApLastEvalResult, LC_MAX_ACTIONPOINTS);
    print_uint16_array("ApCurrentState", LC_HKStatusPkt->ApCurrentState, LC_MAX_ACTIONPOINTS);
    print_uint16_array("ApPassiveCount", LC_HKStatusPkt->ApPassiveCount, LC_MAX_ACTIONPOINTS);
    print_uint16_array("ApFailToPassCount", LC_HKStatusPkt->ApFailToPassCount, LC_MAX_ACTIONPOINTS);
    print_uint16_array("ApPassToFailCount", LC_HKStatusPkt->ApPassToFailCount, LC_MAX_ACTIONPOINTS);
    print_uint16_array("ApConsecutiveFailCount", LC_HKStatusPkt->ApConsecutiveFailCount, LC_MAX_ACTIONPOINTS);
    print_uint16_array("ApCumulativeFailCount", LC_HKStatusPkt->ApCumulativeFailCount, LC_MAX_ACTIONPOINTS);
    print_uint16_array("ApCumulativeRTSExecCount", LC_HKStatusPkt->ApCumulativeRTSExecCount, LC_MAX_ACTIONPOINTS);
}

void print_uint16_array(char *label, uint16 *array, uint16 count){
	int i;

	UTF_put_text("%s: ", label);
	for(i = 0; i < count; i++){
		if(array[i]){
			UTF_put_text("[%d]=%d,", i, array[i]);
		}
	}
	UTF_put_text("\n");
}

void time_hook(void) {
    UTF_set_sim_time(UTF_get_sim_time() + 1.0);
}

void dump_msg(char *label, uint8 *msg, int count){
    int index = 0;

    printf("%s: ", label);

    for (index = 0; index < count; index++) {
        uint8 i = msg[index];
        printf("%02x ", i);
    }
    printf("\n");
}

void init_cmd_pkt(CCSDS_CmdPkt_t *packet, uint16 mid, uint16 cmd_code){
    CFE_SB_InitMsg(packet, mid, sizeof(CCSDS_CmdPkt_t), TRUE);
    CFE_SB_SetCmdCode((CFE_SB_MsgPtr_t) packet, cmd_code);
}



