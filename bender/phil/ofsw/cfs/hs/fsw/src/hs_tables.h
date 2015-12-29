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
#ifndef HS_TABLES_H
#define HS_TABLES_H

#include "hs_cfg.h"

/* Validation error codes */
#define HS_MAT_INVALID_STATE    (-1)
#define HS_MAT_INVALID_CHECKSUM (-2)
#define HS_AMT_INVALID_ACTION   (-3)
#define HS_EMT_INVALID_ACTION   (-4)

typedef struct {
    uint16 EnableState;
    uint16 Cooldown;
    uint8  MsgData[HS_MAX_MSG_ACT_SIZE];
} HS_MessageAction_t;

typedef struct {
    HS_MessageAction_t MessageAction[HS_MAX_MSG_ACT_TYPES];
} HS_MessageActionTable_t;

typedef struct {
    char AppName[OS_MAX_API_NAME];
    uint16 CycleCount;
    uint16 ActionType;
} HS_AppMonitorEntry_t;

typedef struct {
    HS_AppMonitorEntry_t MonitoredApp[HS_MAX_CRITICAL_APPS];
} HS_AppMonitorTable_t;

typedef struct {
    char AppName[OS_MAX_API_NAME];
    uint16 EventId;
    uint16 ActionType;
} HS_EventMonitorEntry_t;

typedef struct {
    HS_EventMonitorEntry_t MonitoredEvent[HS_MAX_CRITICAL_EVENTS];
} HS_EventMonitorTable_t;

#endif
