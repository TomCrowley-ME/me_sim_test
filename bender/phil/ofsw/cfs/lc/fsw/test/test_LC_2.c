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
/* File: test_LC_2.c
 * 
 */

#include "test_LC_common.h"
#include <stddef.h>

extern LC_AppData_t LC_AppData;

void gen_test_msgs(void);

typedef struct {
  uint8_T cfe_tlm_header_align[4];
  uint8_T landed;
  uint8_T integrating;
  uint8_T gps_meas_valid;
  uint8_T samples_since_valid_imu;
  uint8_T convergence_state;
  uint8_T pad1[7];
  real_T pos[3];
  real_T altitude;
  real_T vel[3];
} test_t;

void gen_test_msgs(){
	CmpMtvPacket_t cmpMtvPacket;
	EstMtvPacket_t estMtvPacket;
	CCSDS_CmdPkt_t cmdPkt;

    CFE_SB_InitMsg(&cmpMtvPacket, CMP_MTV_MID, sizeof(CmpMtvPacket_t), TRUE);
    CFE_SB_TimeStampMsg((CFE_SB_MsgPtr_t) &cmpMtvPacket);
    cmpMtvPacket.cmpMtvMsg.est_ref_frame = REFERENCE_FRAME__TOPOCENTRIC;
    dump_msg("CMP_MTV_MID", (uint8*) &cmpMtvPacket, sizeof(CmpMtvPacket_t));

    CFE_SB_InitMsg(&estMtvPacket, EST_MTV_MID, sizeof(EstMtvPacket_t), TRUE);
    CFE_SB_TimeStampMsg((CFE_SB_MsgPtr_t) &estMtvPacket);
    estMtvPacket.estMtvMsg.vel[0] = -0.6;
    estMtvPacket.estMtvMsg.integrating = TRUE;
    dump_msg("EST_MTV_MID", (uint8*) &estMtvPacket, sizeof(EstMtvPacket_t));

	init_cmd_pkt(&cmdPkt, LC_SEND_HK_MID, TRUE);
    dump_msg("LC_SEND_HK_MID", (uint8*) &cmdPkt, sizeof(cmdPkt));

	init_cmd_pkt(&cmdPkt, LC_EVAL_WPAP_MID, TRUE);
    dump_msg("LC_EVAL_WPAP_MID", (uint8*) &cmdPkt, sizeof(cmdPkt));
}

int main(void) {
    char AppName[10];
    strcpy(AppName, LC_APP_NAME);

    /* gen_test_msgs(); */

    UTF_set_output_filename("test_LC_2.ActualOutput");

    UTF_put_text("test_LC_2: START\n");

    /********************************/
    /* Set up to read in script      */
    /********************************/

    UTF_add_input_file(CFE_LC_CMD_PIPE, "lc_script_2_cmd.in");
    UTF_add_input_file(CFE_LC_TLM_PIPE, "lc_script_2_tlm.in");

    LC_AppData.CmdPipe = CFE_LC_CMD_PIPE;
    LC_AppData.TlmPipe = CFE_LC_TLM_PIPE;

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

