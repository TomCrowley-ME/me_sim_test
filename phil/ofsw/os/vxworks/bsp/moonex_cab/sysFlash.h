#ifndef SYS_FLASH_H
#define SYS_FLASH_H

#include <vxWorks.h>

/* Command Codes */
#define FLASH_WRITE_ENABLE  0x06
#define FLASH_WRITE_DISABLE 0x04
#define FLASH_GET_STATUS    0x05

/* Status bits */
#define FLASH_STATUS_BUSY   0x01

/* Flash Parameters */
#define FLASH_SECTOR_SIZE    (64*1024)
#define FLASH_SUBSECTOR_SIZE  (4*1024)

/* Don't declare function prototypes for assembly language includes */
#ifndef _ASMLANGUAGE
void sysFlashWriteEnable();
void sysFlashWriteDisable();

int sysFlashWrite(volatile void* dest, const void* buffer, int length);
int sysFlashSectorErase(volatile void *start_address);
int sysFlashSubsectorErase(volatile void *start_address);

STATUS sysFlashGet(char *buf, int length, int offset);
STATUS sysFlashSet (char *buf, int length, int offset);

#endif

#endif
