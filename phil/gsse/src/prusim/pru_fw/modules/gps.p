// *****************************************************************************/
// file:     gps.p
//
// purpose:  GPS Microcontroller Interface Functions (piggybacking off of Radio)
//
// *****************************************************************************/

#include "../puppetmaster.hp"
#include "../puppetmaster_interface.h"
#include "../gpio.hp"
#include "../mcspi.hp"

#include "gps.hp"

//******************************************************************************
//*
//* gps_init - Sets up GPS pins and registers
//*
gps_init:
    // Back up the call register
    mov  r22.w0, r30.w0

    mov  gpio_pin.base, GPS_GPIO_BASE
    mov  gpio_pin.mask, GPS_GPIO_MASK

    // Take the SS line high first to prevent toggling
    sbbo gpio_pin.mask, gpio_pin.base, GPIO_SETDATAOUT, 4

    // Enable output on the SS line
    call gpio_output_enable

    mov  r30.w0, r22.w0
    ret

//******************************************************************************
//*
//* gps_write - Writes out current GPS data
//*
gps_write:
    // Back up the call register
    mov  r22.w0, r30.w0

    // Wait until GPS data is available for writing
    mov  r2.w0, PRU_INTC_SRSR0
    wcbs r1, CONST_PRU_INTC, r2.w0, GPS_WRITE_EVENT

    // Set up transfer parameters
    mov  gpio_pin.base, GPS_GPIO_BASE
    mov  gpio_pin.mask, GPS_GPIO_MASK

    mov spi_buffer.mode, MCSPI_WRITE

    mov spi_buffer.cmd, GPS_WRITE_CMD
    mov spi_buffer.address, GPS_BUFFER_ADDR

    mov  spi_buffer.length, GPS_WRITE_LENGTH

    // Perform the send operation
    call mcspi_transfer

    // Clear the input event to let the host know we're done
    mov  r1, GPS_WRITE_EVENT
    mov  r2.w0, PRU_INTC_SICR
    sbco r1, CONST_PRU_INTC, r2.w0, 4

    mov  r30.w0, r22.w0
    ret
