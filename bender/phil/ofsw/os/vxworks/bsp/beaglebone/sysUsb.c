/* sysUsb.c - TI AM335X USB initialization routines */

/*
 * Copyright (c) 2012 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify or otherwise make use
 * of this software may be licensed only pursuant to the terms
 * of an applicable Wind River license agreement.
 */

/*
modification history
--------------------
01a,09may12,my_  created.
*/

/* definitions */

#define CM_CLKDCOLDO_DPLL_PER    (0x47C)
#define DPLL_CLKDCOLDO_GATE_CTRL (0x100)

#define USBSS_EOI                (0x20)
#define USBSS_IRQSTAT            (0x28)
#define USB_CTRL                 (0x14)

#define USB_MODE                 (0xe8)
#define USB_UTMI                 (0xe0)
#define USB_IRQMSTAT             (0x20)
#define USB_IRQEOI               (0x24)

#define CTRL_USB0                (0x620)
#define CTRL_USB1                (0x628)

#define USBPHY_CM_PWRDN          (1 << 0)
#define USBPHY_OTG_PWRDN         (1 << 1)
#define USBPHY_CHGDET_DIS        (1 << 2)
#define USBPHY_CHGDET_RSTRT      (1 << 3)
#define USBPHY_SRCONDM           (1 << 4)
#define USBPHY_SINKONDP          (1 << 5)
#define USBPHY_CHGISINK_EN       (1 << 6)
#define USBPHY_CHGVSRC_EN        (1 << 7)
#define USBPHY_DMPULLUP          (1 << 8)
#define USBPHY_DPPULLUP          (1 << 9)
#define USBPHY_CDET_EXTCTL       (1 << 10)
#define USBPHY_GPIO_MODE         (1 << 12)
#define USBPHY_DPOPBUFCTL        (1 << 13)
#define USBPHY_DMOPBUFCTL        (1 << 14)
#define USBPHY_DPINPUT           (1 << 15)
#define USBPHY_DMINPUT           (1 << 16)
#define USBPHY_DPGPIO_PD         (1 << 17)
#define USBPHY_DMGPIO_PD         (1 << 18)
#define USBPHY_OTGVDET_EN        (1 << 19)
#define USBPHY_OTGSESSEND_EN     (1 << 20)
#define USBPHY_DATA_POLARITY     (1 << 23)

/******************************************************************************
*
* usbClkConf - configure USB control pad 
*
* This routine configures USB control pad 
*
* RETURNS: N/A 
*
* ERRNO: N/A
*
*/

LOCAL void usbClkConf(void)
    {

    omapClockEnable (&usb); 

    omapPadConfig (usb0_pads);
    omapPadConfig (usb1_pads);

    am335xOutLong (AM335X_PRCM_BASE + CM_CLKDCOLDO_DPLL_PER,
            DPLL_CLKDCOLDO_GATE_CTRL);
    }

/******************************************************************************
*
* usbInit1 - reset USB module 
*
* This routine resets USB module 
*
* RETURNS: N/A 
*
* ERRNO: N/A
*
*/

LOCAL void usbInit1(void)
    {
    UINT32 regBase = AM335X_USBSS_BASE;
    UINT32 buf;

    am335xOutLong (regBase + USBSS_EOI, 0x0);
    buf = am335xInLong (regBase + USBSS_IRQSTAT);
    am335xOutLong (regBase + USBSS_IRQSTAT, buf);
    
    regBase = AM335X_USB0_BASE;
    am335xOutLong (regBase + USB_CTRL, 0x1);

    /* wait USB0 sw reset done */

    while ((am335xInLong (regBase + USB_CTRL) & 0x1) != 0)
            ;

    regBase = AM335X_USB1_BASE;
    am335xOutLong (regBase + USB_CTRL, 0x1);

    /* wait USB1 sw reset done */

    while ((am335xInLong (regBase + USB_CTRL) & 0x1) != 0)
            ;
    }

/******************************************************************************
*
* usbPhyConf - configure USB phy 
*
* This routine configures USB phy 
*
* RETURNS: N/A 
*
* ERRNO: N/A
*
*/

LOCAL void usbPhyConf(void)
    {
    UINT32 temp;
    UINT32 regBase = AM335X_CTRL_BASE;

    /* USB_CTRL0 */

    temp = am335xInLong (regBase + CTRL_USB0);
    
    temp &= ~(USBPHY_CM_PWRDN | USBPHY_OTG_PWRDN);
    temp |= (USBPHY_OTGVDET_EN | USBPHY_OTGSESSEND_EN);
    am335xOutLong (regBase + CTRL_USB0, temp );
    
    /* USB_CTRL1 */
    
    temp = am335xInLong (regBase + CTRL_USB1);
 
    temp &= ~(USBPHY_CM_PWRDN | USBPHY_OTG_PWRDN);
    temp |= (USBPHY_OTGVDET_EN | USBPHY_OTGSESSEND_EN);
    am335xOutLong (regBase + CTRL_USB1, temp );
    }

/******************************************************************************
*
* usbInit2 - set USB mode 
*
* This routine sets USB mode 
*
* RETURNS: N/A 
*
* ERRNO: N/A
*
*/

void usbInit2(void)
    {
    UINT32 regBase = AM335X_USB0_BASE;

    /* USB 0 initialization */

    /* Host mode */

    am335xOutLong (regBase + USB_MODE, 0x100);
    am335xOutLong (regBase + USB_UTMI, 0x00200002);

    am335xOutLong (regBase + USB_IRQEOI,  0);
    am335xOutLong (regBase + USB_IRQMSTAT,0);

    regBase = AM335X_USB1_BASE;

    /* USB 1 initialization */

    /* Peripheral mode */

    am335xOutLong (regBase + USB_MODE, 0x0);
    am335xOutLong (regBase + USB_UTMI, 0x00200002);

    am335xOutLong (regBase + USB_IRQEOI,  0);
    am335xOutLong (regBase + USB_IRQMSTAT,0);
    }

/*******************************************************************************
*
* sysUsbInit - USB module initilization
*
* This routine initilizes the USB module related.
*
* RETURNS: N/A
*
* ERRNO: N/A
*/

LOCAL void sysUsbInit (void)
    {
    usbClkConf ();
    usbInit1   ();
    usbPhyConf ();
    usbInit2   ();
    }

