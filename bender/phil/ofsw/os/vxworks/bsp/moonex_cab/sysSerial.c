#include "config.h"

/* Method for stopping UART IRQs */
METHOD_DECL(uartSioChanReset);

/* Initialize Serial channels */
void sysSerialHwInit(void)
{
}

void sysSerialHwInit2(void)
{
}

SIO_CHAN *bspSerialChanGet(int channel)
{
	return ((SIO_CHAN *) ERROR);
}

void sysSerialReset (void)
{
#if defined(DRV_GRLIB_APBUART) || defined(DRV_UART_LEON2)
	vxbDevMethodRun(DEVMETHOD_CALL(uartSioChanReset), 0);
#endif
}
