#ifndef HS_CFG_H
#define HS_CFG_H

#define HS_STATE_ENABLED  1
#define HS_STATE_DISABLED 0

#define HS_ACTION_PROCESSOR_RESET 0xFFFF
#define HS_ACTION_APP_RESTART     0xFFFE
#define HS_ACTION_SEND_EVENT      0xFFFD

/* HS configuration parameters */
#define HS_AMT_FILENAME           "/cf/ptbl/hs_amt_tbl.tbl"
#define HS_APPMON_DEFAULT_STATE   HS_STATE_DISABLED
#define HS_CMD_PIPE_DEPTH         12
#define HS_EMT_FILENAME           "/cf/ptbl/hs_emt_tbl.tbl"
#define HS_EVENT_PIPE_DEPTH       32
#define HS_EVENTMON_DEFAULT_STATE HS_STATE_DISABLED
#define HS_MAT_FILENAME           "/cf/ptbl/hs_mat_tbl.tbl"
#define HS_MAX_CRITICAL_APPS      32
#define HS_MAX_CRITICAL_EVENTS    16
#define HS_MAX_EXEC_CNT_SLOTS     32
#define HS_MAX_MSG_ACT_SIZE       16
#define HS_MAX_MSG_ACT_TYPES      8
#define HS_MAX_RESTART_ACTIONS    3
#define HS_MISSION_REV            0
#define HS_RESET_TASK_DELAY       50
#define HS_STARTUP_SYNC_TIMEOUT   65000
#define HS_PEAK_NUM_INTERVALS     64
#define HS_WAKEUP_PIPE_DEPTH      1
#define HS_WAKEUP_TIMEOUT         5500
#define HS_WATCHDOG_TIMEOUT_VALUE 10000
#define HS_XCT_FILENAME           "/cf/ptbl/hs_xct_tbl.tbl"

#endif
