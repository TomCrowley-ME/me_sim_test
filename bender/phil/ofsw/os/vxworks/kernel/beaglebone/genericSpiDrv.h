#ifndef GENERICSPI_DRV_H
#define GENERICSPI_DRV_H

#include <vxWorks.h>
#include "iosLib.h"

#define GENERIC_SPI_SET_CC (0x30000000)

typedef struct {
	DEV_HDR devHdr;
	int module;
	int channel;
	int csPin;
	char command_code;
	BOOL inUse;
} GENERICSPI_DEV;

STATUS genericSpiDrv(void);
STATUS genericSpiDevCreate(char *name, int spiChannel, int spiPort, int spiEnPin, char commandCode);
	

#endif /* GENERICSPI_DRV_H */
