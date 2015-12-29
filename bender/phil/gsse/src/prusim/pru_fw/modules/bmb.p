// *****************************************************************************/
// file:     bmb.p
//
// purpose:  Battery Monitor Board Interface Functions
//
// *****************************************************************************/

#include "../puppetmaster.hp"
#include "../puppetmaster_interface.h"
#include "../gpio.hp"
#include "../mcspi.hp"

#include "bmb.hp"

//******************************************************************************
//*
//* bmb_init - Sets up bmb pins and registers
//*
bmb_init:
    // Back up the call register
    mov  r22.w0, r30.w0

    // Take high and enable the slave select lines
    mov  gpio_pin.base, BMB_4V_12V_GPIO_BASE
    mov  gpio_pin.mask, BMB_4V_12V_GPIO_MASK
    sbbo gpio_pin.mask, gpio_pin.base, GPIO_SETDATAOUT, 4
    call gpio_output_enable

    mov  gpio_pin.base, BMB_28V_GPIO_BASE
    mov  gpio_pin.mask, BMB_28V_GPIO_MASK
    sbbo gpio_pin.mask, gpio_pin.base, GPIO_SETDATAOUT, 4
    call gpio_output_enable

    mov  r30.w0, r22.w0
    ret
