// *****************************************************************************/
// file:     valves.p
//
// purpose:  Valve Microcontroller Interface Functions
//
// *****************************************************************************/

#include "../puppetmaster.hp"
#include "../puppetmaster_interface.h"
#include "../gpio.hp"
#include "../mcspi.hp"

#include "valves.hp"

//******************************************************************************
//*
//* valves_init - Sets up valves pins and registers
//*
valves_init:
    // Back up the call register
    mov  r22.w0, r30.w0

    // Set up the valves chip select line...
    mov  gpio_pin.base, VALVES_GPIO_BASE
    mov  gpio_pin.mask, VALVES_GPIO_MASK

    // Take the SS line high first to prevent toggling
    sbbo gpio_pin.mask, gpio_pin.base, GPIO_SETDATAOUT, 4

    // Enable output on the SS line
    call gpio_output_enable

    //... as well as the solenoids
    mov  gpio_pin.base, SOLENOIDS_GPIO_BASE
    mov  gpio_pin.mask, SOLENOIDS_GPIO_MASK

    // Take the SS line high first to prevent toggling
    sbbo gpio_pin.mask, gpio_pin.base, GPIO_SETDATAOUT, 4

    // Enable output on the SS line
    call gpio_output_enable

    mov  r30.w0, r22.w0
    ret

//******************************************************************************
//*
//* valves_read - Reads the current valve states from the microcontroller
//*               Blocks until receipt of the VALVES_READ_EVENT
//*
valves_read:
    // Back up the call register
    mov  r22.w0, r30.w0

    // Wait until we're synchronized and told to go ahead with the read
    mov  r2.w0, PRU_INTC_SRSR0
    wcbs r1, CONST_PRU_INTC, r2.w0, VALVES_READ_EVENT

    // Set up transfer parameters
    mov  gpio_pin.base, VALVES_GPIO_BASE
    mov  gpio_pin.mask, VALVES_GPIO_MASK

    mov spi_buffer.mode, MCSPI_READ

    mov spi_buffer.cmd, VALVES_READ_CMD
    mov spi_buffer.length, VALVES_READ_LENGTH
    mov spi_buffer.address, VALVES_BUFFER_ADDR

    // Perform the read operation
    call mcspi_transfer

    // Clear the input event to let the host know we're done
    mov  r1, VALVES_READ_EVENT
    mov  r2.w0, PRU_INTC_SICR
    sbco r1, CONST_PRU_INTC, r2.w0, 4

    mov  r30.w0, r22.w0
    ret
