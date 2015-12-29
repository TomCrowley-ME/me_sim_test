#ifndef _EEPROM_H_
#define _EEPROM_H_

#include <vxWorks.h>

#define EEPROM_NAME "eeprom_at24c256"
#define EEPROM_MAGIC 0xEE3355AA
#define EEPROM_NAME_LEN 8

typedef struct {
    UINT32 magic;
    char   name[EEPROM_NAME_LEN];
    char   version[4];
    char   serial[12];
    char   config[32];
    char   mac_addr[3][6];
} eeprom_header;

int eepromRead(UINT32 srcAddr, UINT8*  dstAddr, UINT32 len);
int eepromReadHeader(eeprom_header *header);
BOOL eepromIsBone(eeprom_header *header);
BOOL eepromIsBoneBlack(eeprom_header *header);

#endif /*_EEPROM_H_*/
