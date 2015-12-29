// *****************************************************************************/
// file:     pyros.p
//
// purpose:  Pyros Microcontroller Interface Functions
//
// *****************************************************************************/

#include "../puppetmaster.hp"
#include "../puppetmaster_interface.h"
#include "../gpio.hp"
#include "../mcspi.hp"

#include "pyros.hp"

//******************************************************************************
//*
//* pyros_init - Sets up Pyros pins and registers
//*
pyros_init:
    // Back up the call register
    mov  r22.w0, r30.w0

    // Take high and enable the three slave select lines
    mov  gpio_pin.base, PYROS_GPIO_BASE
    mov  gpio_pin.mask, PYROS_GPIO_MASK
    sbbo gpio_pin.mask, gpio_pin.base, GPIO_SETDATAOUT, 4
    call gpio_output_enable

    mov  r30.w0, r22.w0
    ret
