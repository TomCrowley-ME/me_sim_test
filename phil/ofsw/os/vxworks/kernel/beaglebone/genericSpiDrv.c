#include "genericSpiDrv.h"

#include <vxbTimerLib.h>
#include <errnoLib.h>
#include <stdlib.h>
#include <string.h>

#include "config.h"
#include "sysGpio.h"
#include "ti81xxMcSpi.h"

LOCAL GENERICSPI_DEV* genericSpiOpen(GENERICSPI_DEV* genericSpiDev, char *remainder, int flags, int mode);
LOCAL STATUS genericSpiClose(GENERICSPI_DEV* genericSpiDev);
LOCAL ssize_t genericSpiWrite(GENERICSPI_DEV* genericSpiDev, char *buffer, size_t size);
LOCAL ssize_t genericSpiRead(GENERICSPI_DEV* genericSpiDev, char *buffer, size_t size);
LOCAL STATUS genericSpiIoctl(GENERICSPI_DEV* genericSpiDev, int function, _Vx_ioctl_arg_t arg);

LOCAL int genericSpiDrvNum = 0;

STATUS genericSpiDrv(void) {
	/* First check to see if the driver is already installed */
	if (genericSpiDrvNum > 0) {
		return OK;
	}
	
	genericSpiDrvNum = iosDrvInstall((DRV_CREATE_PTR) NULL, (DRV_REMOVE_PTR) NULL,
			   (DRV_OPEN_PTR) genericSpiOpen, (DRV_CLOSE_PTR) genericSpiClose, 
			   (DRV_READ_PTR) genericSpiRead, (DRV_WRITE_PTR) genericSpiWrite,
			   (DRV_IOCTL_PTR) genericSpiIoctl);
	
	if (genericSpiDrvNum == ERROR) {
		errnoSet(S_ioLib_NO_DRIVER);
		return ERROR;
	}
	
	return OK;
}

STATUS genericSpiDevCreate(char *name, int spiModule, int spiChannel, int spiCSPin, char commandCode) {
	GENERICSPI_DEV *genericSpiDev = NULL;
	STATUS status = ERROR;
	
	if (genericSpiDrvNum < 1) {
		/* Driver has not yet initialized! */
		errnoSet(S_ioLib_NO_DRIVER);
		return ERROR;
	}
	
	/* allocate memory for the device */
	genericSpiDev = (GENERICSPI_DEV *)calloc(1, sizeof(GENERICSPI_DEV));
	if (genericSpiDev == NULL) {
		/* GENERICSPI_ERR */
		return ERROR;
	}
	
	genericSpiDev->module = spiModule;
	genericSpiDev->channel = spiChannel;
	genericSpiDev->csPin = spiCSPin;
	genericSpiDev->command_code = commandCode;
	
	status = iosDevAdd((DEV_HDR *)genericSpiDev, name, genericSpiDrvNum);
	if (status == ERROR) {
		/* GENERICSPI_ERR */
		free(genericSpiDev);
		return ERROR;
	}
	
	if (spiCSPin != TI81XX_SPI_AUTO_SPIEN) {
		/* Enable and set high the GPIO pin being used for chip select */
		sysGpioOutputEnable(spiCSPin);
		sysGpioSet(spiCSPin);
	}
	
	return OK;
}

LOCAL GENERICSPI_DEV* genericSpiOpen(GENERICSPI_DEV* genericSpiDev, char *remainder, int flags, int mode) {
	if (remainder != NULL && strlen(remainder) != 0) {
		errnoSet(ENODEV);
		return (GENERICSPI_DEV*)ERROR;
	}
	if (genericSpiDev->inUse) {
		/* Only permit one opening at a time */
		return (GENERICSPI_DEV*)ERROR;
	}
	
	genericSpiDev->inUse = TRUE;
	return genericSpiDev;
}

LOCAL STATUS genericSpiClose(GENERICSPI_DEV* genericSpiDev) {
	genericSpiDev->inUse = FALSE;
	return OK;
}

LOCAL ssize_t genericSpiWrite(GENERICSPI_DEV* genericSpiDev, char *buffer, size_t size) {
	STATUS status;
	
	ti81xxSpiStart(genericSpiDev->module, genericSpiDev->channel, genericSpiDev->csPin);
	status = ti81xxSpiXfer(genericSpiDev->module, genericSpiDev->channel, &genericSpiDev->command_code, 1, TI81XX_SPI_WRITE);
	vxbUsDelay(20);
	status = ti81xxSpiXfer(genericSpiDev->module, genericSpiDev->channel, buffer, size, TI81XX_SPI_WRITE);
	ti81xxSpiStop(genericSpiDev->module, genericSpiDev->channel, genericSpiDev->csPin);
	
	if (status == OK) {
		return size;
	} else {
		return ERROR;
	}
}

LOCAL ssize_t genericSpiRead(GENERICSPI_DEV* genericSpiDev, char *buffer, size_t size) {
	STATUS status;
	
	ti81xxSpiStart(genericSpiDev->module, genericSpiDev->channel, genericSpiDev->csPin);
	status = ti81xxSpiXfer(genericSpiDev->module, genericSpiDev->channel, &genericSpiDev->command_code, 1, TI81XX_SPI_WRITE);
	vxbUsDelay(20);
	status = ti81xxSpiXfer(genericSpiDev->module, genericSpiDev->channel, buffer, size, TI81XX_SPI_READ);
	ti81xxSpiStop(genericSpiDev->module, genericSpiDev->channel, genericSpiDev->csPin);
	
	if (status == OK) {
		return size;
	} else {
		return ERROR;
	}
}

LOCAL STATUS genericSpiIoctl(GENERICSPI_DEV* genericSpiDev, int function, _Vx_ioctl_arg_t arg) {
    STATUS status = OK;

    switch (function) {
        case GENERIC_SPI_SET_CC:
            genericSpiDev->command_code = arg;
            break;

        default:
            errnoSet(S_ioLib_UNKNOWN_REQUEST);
            status = ERROR;
            break;
    }
    return status;
}
