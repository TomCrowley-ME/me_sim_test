// *****************************************************************************/
// file:     gpio.p
//
// purpose:  GPIO Module Controller
//
// *****************************************************************************/

#include "gpio.hp"

//******************************************************************************
//*
//* gpio_output_enable - Enables the specified output pins
//*
gpio_output_enable:
    // Load in the module's OE register and set the pin's bit
    lbbo r1, gpio_pin.base, GPIO_OE, 4
    not  r2, gpio_pin.mask
    and  r1, r1, r2
    sbbo r1, gpio_pin.base, GPIO_OE, 4
    ret
