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
#ifndef DS_CFG_H
#define DS_CFG_H

/* DS configuration parameters */
#define DS_DESTINATION_TBL_NAME    "FILE_TBL"
#define DS_DEF_DEST_FILENAME       "/cf/ptbl/ds_file_tbl.tbl"
#define DS_DEST_FILE_CNT           16
#define DS_PATHNAME_BUFSIZE        OS_MAX_PATH_LEN
#define DS_BASENAME_BUFSIZE        OS_MAX_PATH_LEN
#define DS_EXTENSION_BUFSIZE       8
#define DS_FILTER_TBL_NAME         "FILTER_TBL"
#define DS_DEF_FILTER_FILENAME     "/cf/ptbl/ds_filter_tbl.tbl"
#define DS_PACKETS_IN_FILTER_TABLE 256
#define DS_FILTERS_PER_PACKET      4
#define DS_DESCRIPTOR_BUFSIZE      32
#define DS_SEQUENCE_DIGITS         8
#define DS_MAX_SEQUENCE_COUNT      99999999
#define DS_TOTAL_FNAME_BUFSIZE     OS_MAX_PATH_LEN
#define DS_FILE_HDR_SUBTYPE        12345
#define DS_FILE_HDR_DESCRIPTION    "DS data storage file"
#define DS_FILE_MIN_SIZE_LIMIT     1024
#define DS_FILE_MIN_AGE_LIMIT      60
#define DS_APP_PIPE_NAME           "DS_CMD_PIPE"
#define DS_APP_PIPE_DEPTH          256
#define DS_MAKE_TABLES_CRITICAL    0
#define DS_SECS_PER_HK_CYCLE       5

#endif
