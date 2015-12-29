#ifndef MOONEX_CAB_H
#define MOONEX_CAB_H

#include <vxWorks.h>

/* Utility macros */
#define cabInByte(a) (*(volatile unsigned char *)(a))
#define cabOutByte(a, v) (*(volatile unsigned char *)(a) = (v))

/* Base address for FPGA access */
#define CAB_FPGA_BASE ((UINT8*)0x20000000)

/* CAB Pages */
#define FPGA_PAGE_STATUS      0x00
#define FPGA_PAGE_CTRL        0x01
#define FPGA_PAGE_RADIO       0x02
#define FPGA_PAGE_STARTRACKER 0x03
#define FPGA_PAGE_FLASH       0x08
#define FPGA_PAGE_VALVES_LOW  0x0B
#define FPGA_PAGE_VALVES_HIGH 0x1B

/* FIFO Flags */
#define FPGA_FIFO_EMPTY            (1<<6)

/* CAB Registers */
#define FPGA_PAGE_SELECT           (CAB_FPGA_BASE + 0x00)

/* Page 0 */
#define CAB_FPGA1_STATUS           (CAB_FPGA_BASE + 0x01)
#define CAB_FPGA2_STATUS           (CAB_FPGA_BASE + 0x02)
#define CAB_MET_0                  (CAB_FPGA_BASE + 0x03)
#define CAB_MET_1                  (CAB_FPGA_BASE + 0x04)
#define CAB_MET_2                  (CAB_FPGA_BASE + 0x05)
#define CAB_MET_3                  (CAB_FPGA_BASE + 0x06)

/* Page 2 */
#define CAB_RADIO_STATUS             (CAB_FPGA_BASE + 0x01)
#define CAB_RADIO_DL_FIFO_0          (CAB_FPGA_BASE + 0x1F)
#define CAB_RADIO_DL_FIFO_1          (CAB_FPGA_BASE + 0x20)

/* Page 3 */
#define CAB_STARTRACKER_TLM_FIFO_DATA  (CAB_FPGA_BASE + 0x04)
#define CAB_STARTRACKER_TLM_STATUS     (CAB_FPGA_BASE + 0x06)
#define CAB_STARTRACKER_TLM_CNT_L      (CAB_FPGA_BASE + 0x07)
#define CAB_STARTRACKER_TLM_CNT_H      (CAB_FPGA_BASE + 0x08)
#define CAB_STARTRACKER_TLM_FIFO_FEED  (CAB_FPGA_BASE + 0x0F)

/* Page 8 */
#define CAB_FLASH_DATA_BYTE               (CAB_FPGA_BASE + 0x01)
#define CAB_FLASH_ADDR_0                  (CAB_FPGA_BASE + 0x01)
#define CAB_FLASH_ADDR_1                  (CAB_FPGA_BASE + 0x02)
#define CAB_FLASH_ADDR_2                  (CAB_FPGA_BASE + 0x03)
#define CAB_FLASH_ADDR_3                  (CAB_FPGA_BASE + 0x04)
#define CAB_FLASH_CMD                     (CAB_FPGA_BASE + 0x05)
#define CAB_FLASH_CMD_W_TLM               (CAB_FPGA_BASE + 0x06)
#define CAB_FLASH_READ_3_ADDR             (CAB_FPGA_BASE + 0x07)
#define CAB_FLASH_PROGRAM_3_ADDR          (CAB_FPGA_BASE + 0x09)
#define CAB_FLASH_SUBSECTOR_ERASE_3_ADDR  (CAB_FPGA_BASE + 0x20)
#define CAB_FLASH_SECTOR_ERASE_3_ADDR     (CAB_FPGA_BASE + 0x23)
#define CAB_FLASH_FPGA_STATUS             (CAB_FPGA_BASE + 0x25)

/* Pages 0x0B and 0x1B */
#define CAB_VALVES_TRIGGER             (CAB_FPGA_BASE + 0x01)
#define CAB_VALVES_DURATION_1          (CAB_FPGA_BASE + 0x10)
#define CAB_VALVES_DURATION_2          (CAB_FPGA_BASE + 0x12)
#define CAB_VALVES_DURATION_3          (CAB_FPGA_BASE + 0x14)
#define CAB_VALVES_DURATION_4          (CAB_FPGA_BASE + 0x16)
#define CAB_VALVES_DURATION_5          (CAB_FPGA_BASE + 0x18)
#define CAB_VALVES_DURATION_6          (CAB_FPGA_BASE + 0x1A)
#define CAB_VALVES_DURATION_7          (CAB_FPGA_BASE + 0x1C)
#define CAB_VALVES_DURATION_8          (CAB_FPGA_BASE + 0x1E)
#define CAB_VALVES_DURATION_9          (CAB_FPGA_BASE + 0x20)
#define CAB_VALVES_DURATION_10         (CAB_FPGA_BASE + 0x22)
#define CAB_VALVES_DURATION_11         (CAB_FPGA_BASE + 0x24)
#define CAB_VALVES_DURATION_12         (CAB_FPGA_BASE + 0x26)
#define CAB_VALVES_DURATION_13         (CAB_FPGA_BASE + 0x28)
#define CAB_VALVES_DURATION_14         (CAB_FPGA_BASE + 0x2A)

STATUS sysFpgaInit(void);
UINT8  sysFpgaGetPage(void);
void   sysFpgaSetPage(UINT8 page);
UINT8  sysFpgaLockPage(UINT8 page);
void   sysFpgaUnlockPage(UINT8 old_page);
UINT32 cabGetMET(void);
void   cabSetMET(UINT32 seconds);
UINT8  cabGetSCID(void);

#endif /* MOONEX_CAB_H */
