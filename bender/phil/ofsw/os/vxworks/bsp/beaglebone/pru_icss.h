#ifndef _PRU_ICSS_H_
#define _PRU_ICSS_H_

#include "beaglebone.h"

#define PRU0_DRAM_BASE            (AM335X_PRU_ICSS_BASE + 0x00000000)
#define PRU1_DRAM_BASE            (AM335X_PRU_ICSS_BASE + 0x00002000)
#define PRU_ICSS_SHARED_DRAM_BASE (AM335X_PRU_ICSS_BASE + 0x00010000)
#define PRU_ICSS_INTC_BASE        (AM335X_PRU_ICSS_BASE + 0x00020000)
#define PRU0_CTRL_BASE            (AM335X_PRU_ICSS_BASE + 0x00022000)
#define PRU0_DBG_BASE             (AM335X_PRU_ICSS_BASE + 0x00022400)
#define PRU1_CTRL_BASE            (AM335X_PRU_ICSS_BASE + 0x00024000)
#define PRU1_DBG_BASE             (AM335X_PRU_ICSS_BASE + 0x00024400)
#define PRU_ICSS_CFG_BASE         (AM335X_PRU_ICSS_BASE + 0x00026000)
#define PRU_ICSS_UART0_BASE       (AM335X_PRU_ICSS_BASE + 0x00028000)
#define PRU_ICSS_IEP_BASE         (AM335X_PRU_ICSS_BASE + 0x0002E000)
#define PRU_ICSS_ECAP0_BASE       (AM335X_PRU_ICSS_BASE + 0x00030000)
#define PRU_ICSS_MII_CFG_BASE     (AM335X_PRU_ICSS_BASE + 0x00032000)
#define PRU_ICSS_MII_MDIO_BASE    (AM335X_PRU_ICSS_BASE + 0x00032400)
#define PRU0_IRAM_BASE            (AM335X_PRU_ICSS_BASE + 0x00034000)
#define PRU1_IRAM_BASE            (AM335X_PRU_ICSS_BASE + 0x00038000)

#define PRU_IRAM_SIZE             (SZ_8K)

#define PRU_CTRL_CONTROL_OFFSET   (0x00)
#define PRU_CTRL_STATUS_OFFSET    (0x04)
#define PRU_CTRL_WAKEUP_EN_OFFSET (0x08)
#define PRU_CTRL_CYCLE_OFFSET     (0x0C)
#define PRU_CTRL_STALL_OFFSET     (0x10)
#define PRU_CTRL_CTBIR0_OFFSET    (0x20)
#define PRU_CTRL_CTBIR1_OFFSET    (0x24)
#define PRU_CTRL_CTPPR0_OFFSET    (0x28)
#define PRU_CTRL_CTPPR1_OFFSET    (0x2C)

#define PRU_ICSS_INTC_SISR        (PRU_ICSS_INTC_BASE + 0x20)
#define PRU_ICSS_INTC_SICR        (PRU_ICSS_INTC_BASE + 0x24)
#define PRU_ICSS_INTC_SRSR0       (PRU_ICSS_INTC_BASE + 0x200)
#define PRU_ICSS_INTC_SRSR1       (PRU_ICSS_INTC_BASE + 0x204)

#define PRU_ENABLE                (0x00000002)
#define PRU_DISABLE               (0x00000000)

#define PRU_ICSS_EVTOUT0          (20)
#define PRU_ICSS_EVTOUT1          (21)
#define PRU_ICSS_EVTOUT2          (22)
#define PRU_ICSS_EVTOUT3          (23)
#define PRU_ICSS_EVTOUT4          (24)
#define PRU_ICSS_EVTOUT5          (25)
#define PRU_ICSS_EVTOUT6          (26)
#define PRU_ICSS_EVTOUT7          (27)

#ifdef PRU_ICSS_DEBUG
#define PRU_ICSS_LOG(fmt,a,b,c,d,e,f)  \
    if (_func_logMsg != NULL) \
        (* _func_logMsg)(fmt,a,b,c,d,e,f)
#else
#define PRU_ICSS_LOG(fmt,a,b,c,d,e,f)
#endif

STATUS pru_icss_pru_enable(UINT32 pru_num);
STATUS pru_icss_pru_disable(UINT32 pru_num);
STATUS pru_icss_pru_load(UINT32 pru_num, char *buffer, size_t length);
STATUS pru_icss_set_event(UINT8 event);
STATUS pru_icss_clear_event(UINT8 event);
STATUS pru_icss_wait_event_set(UINT8 event, _Vx_ticks_t timeout);
STATUS pru_icss_wait_event_clear(UINT8 event, _Vx_ticks_t timeout);
INT32  pru_icss_check_event(UINT8 event);

#endif /*_PRU_ICSS_H_*/
