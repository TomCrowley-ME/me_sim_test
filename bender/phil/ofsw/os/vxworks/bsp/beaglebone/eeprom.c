#include <vxWorks.h>
#include <stdlib.h>
#include <string.h>
#include <hwif/util/vxbParamSys.h> /* for vxbInstByNameFind */

#include "eeprom.h"

IMPORT STATUS vxbI2cEepromRead (VXB_DEVICE_ID, UINT32, UINT8*, UINT32, UINT32*);

int eepromRead(UINT32 srcAddr, UINT8*  dstAddr, UINT32 len) {
    VXB_DEVICE_ID pDev;

    pDev = vxbInstByNameFind(EEPROM_NAME, 0);

    if (pDev != NULL) {
        UINT32 realBytes;
        vxbI2cEepromRead(pDev, srcAddr, dstAddr, len, &realBytes);
        return realBytes;
    } else {
        return ERROR;
    }
}

int eepromReadHeader(eeprom_header *header) {
    int status;

    status = eepromRead(0, (UINT8*) header, sizeof(eeprom_header));
    if (status == sizeof(eeprom_header)) {
        if (header->magic != EEPROM_MAGIC) {
            status = ERROR;
        }
        return status;
    } else {
        return ERROR;
    }
}

BOOL eepromIsBone(eeprom_header *header) {
    return !strncmp(header->name, "A335BONE", EEPROM_NAME_LEN);
}

BOOL eepromIsBoneBlack(eeprom_header *header) {
    return !strncmp(header->name, "A335BNLT", EEPROM_NAME_LEN);
}
