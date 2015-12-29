// *****************************************************************************/
// file:     mems.p
//
// purpose:  MEMS Microcontrollers Interface Functions
//
// *****************************************************************************/

#include "../puppetmaster.hp"
#include "../puppetmaster_interface.h"
#include "../gpio.hp"
#include "../mcspi.hp"

#include "mems.hp"

//******************************************************************************
//*
//* mems_init - Sets up MEMS pins and registers
//*
mems_init:
    // Back up the call register
    mov  r22.w0, r30.w0

    // Take high and enable the three slave select lines
    mov  gpio_pin.base, MEMS1_GPIO_BASE
    mov  gpio_pin.mask, MEMS1_GPIO_MASK
    sbbo gpio_pin.mask, gpio_pin.base, GPIO_SETDATAOUT, 4
    call gpio_output_enable

    mov  gpio_pin.base, MEMS2_GPIO_BASE
    mov  gpio_pin.mask, MEMS2_GPIO_MASK
    sbbo gpio_pin.mask, gpio_pin.base, GPIO_SETDATAOUT, 4
    call gpio_output_enable

    mov  gpio_pin.base, MEMS3_GPIO_BASE
    mov  gpio_pin.mask, MEMS3_GPIO_MASK
    sbbo gpio_pin.mask, gpio_pin.base, GPIO_SETDATAOUT, 4
    call gpio_output_enable

    mov  r30.w0, r22.w0
    ret

//******************************************************************************
//*
//* mems_write - Sends out MEMS IMU data once it is available
//*
mems_write:
    // Back up the call register
    mov  r22.w0, r30.w0

    // Wait until MEMS data is available for writing
    mov  r2.w0, PRU_INTC_SRSR0
    wcbs r1, CONST_PRU_INTC, r2.w0, MEMS_WRITE_EVENT

    // Set up transfer parameters
    mov  spi_buffer.mode, MCSPI_WRITE

    mov  spi_buffer.cmd, MEMS_WRITE_CMD
    mov  spi_buffer.length, MEMS_WRITE_LENGTH

    // Write out each of the MEMS buffers
    mov  spi_buffer.address, MEMS1_BUFFER_ADDR
    mov  gpio_pin.base, MEMS1_GPIO_BASE
    mov  gpio_pin.mask, MEMS1_GPIO_MASK
    call mcspi_transfer

    mov  spi_buffer.address, MEMS2_BUFFER_ADDR
    mov  gpio_pin.base, MEMS2_GPIO_BASE
    mov  gpio_pin.mask, MEMS2_GPIO_MASK
    call mcspi_transfer

    mov  spi_buffer.address, MEMS3_BUFFER_ADDR
    mov  gpio_pin.base, MEMS3_GPIO_BASE
    mov  gpio_pin.mask, MEMS3_GPIO_MASK
    call mcspi_transfer

    // Clear the input event to let the host know we're done
    mov  r1, MEMS_WRITE_EVENT
    mov  r2.w0, PRU_INTC_SICR
    sbco r1, CONST_PRU_INTC, r2.w0, 4

    mov  r30.w0, r22.w0
    ret
