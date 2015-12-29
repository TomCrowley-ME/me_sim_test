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
#ifndef DS_TABLES_H
#define DS_TABLES_H

#include "ds_cfg.h"

typedef struct {
    uint8  FileTableIndex;
    uint8  FilterType;
    uint16 AlgN;
    uint16 AlgX;
    uint16 AlgO;
} DS_Filter_t;

typedef struct {
    uint16 MessageID;
    DS_Filter_t Filters[DS_FILTERS_PER_PACKET];
} DS_FilteredPacket_t;

typedef struct {
    char Descriptor[DS_DESCRIPTOR_BUFSIZE];
    DS_FilteredPacket_t Packets[DS_PACKETS_IN_FILTER_TABLE];
} DS_FilterTable_t;

typedef struct {
    char PathName[DS_PATHNAME_BUFSIZE];
    char BaseName[DS_BASENAME_BUFSIZE];
    char Extension[DS_EXTENSION_BUFSIZE];
    uint16 FileNameType;
    uint16 EnableState;
    uint32 MaxFileSize;
    uint32 MaxFileAge;
    uint32 SequenceCount;
} DS_File_t;

typedef struct {
    char Descriptor[DS_DESCRIPTOR_BUFSIZE];
    DS_File_t Files[DS_DEST_FILE_CNT];
} DS_AppMonitorTable_t;

#endif
