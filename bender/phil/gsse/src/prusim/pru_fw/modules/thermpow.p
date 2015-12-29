// *****************************************************************************/
// file:     thermpow.p
//
// purpose:  Thermal/Power Microcontroller Interface Functions
//
// *****************************************************************************/

#include "../puppetmaster.hp"
#include "../puppetmaster_interface.h"
#include "../gpio.hp"
#include "../mcspi.hp"

#include "thermpow.hp"

//******************************************************************************
//*
//* thermpow_init - Sets up Thermal/Power pins and registers
//*
thermpow_init:
    // Back up the call register
    mov  r22.w0, r30.w0

    // Take high and enable the three slave select lines
    mov  gpio_pin.base, THERMPOW_GPIO_BASE
    mov  gpio_pin.mask, THERMPOW_GPIO_MASK
    sbbo gpio_pin.mask, gpio_pin.base, GPIO_SETDATAOUT, 4
    call gpio_output_enable

    mov  r30.w0, r22.w0
    ret

//******************************************************************************
//*
//* thermpow_ad_write - Writes out current A/D values
//*
thermpow_ad_write:
    // Back up the call register
    mov  r22.w0, r30.w0

    // Wait until AD data is available for writing
    mov  r2.w0, PRU_INTC_SRSR0
    wcbs r1, CONST_PRU_INTC, r2.w0, THERMPOW_AD_WRITE_EVENT

    // Set up transfer parameters
    mov  gpio_pin.base, THERMPOW_GPIO_BASE
    mov  gpio_pin.mask, THERMPOW_GPIO_MASK

    mov spi_buffer.mode, MCSPI_WRITE

    mov spi_buffer.cmd, THERMPOW_AD_WRITE_CMD
    mov spi_buffer.address, THERMPOW_AD_BUFFER_ADDR

    mov  spi_buffer.length, THERMPOW_AD_WRITE_LENGTH

    // Perform the send operation
    call mcspi_transfer

    // Clear the input event to let the host know we're done
    mov  r1, THERMPOW_AD_WRITE_EVENT
    mov  r2.w0, PRU_INTC_SICR
    sbco r1, CONST_PRU_INTC, r2.w0, 4

    mov  r30.w0, r22.w0
    ret
