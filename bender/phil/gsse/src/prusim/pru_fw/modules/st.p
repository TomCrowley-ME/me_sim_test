// *****************************************************************************/
// file:     st.p
//
// purpose:  Star Tracker  Microcontroller Interface Functions
//
// *****************************************************************************/

#include "../puppetmaster.hp"
#include "../puppetmaster_interface.h"
#include "../gpio.hp"
#include "../mcspi.hp"

#include "st.hp"

//******************************************************************************
//*
//* st_init - Sets up ST pins and registers
//*
st_init:
    // Back up the call register
    mov  r22.w0, r30.w0

    // Take high and enable the three slave select lines
    mov  gpio_pin.base, ST_GPIO_BASE
    mov  gpio_pin.mask, ST_GPIO_MASK
    sbbo gpio_pin.mask, gpio_pin.base, GPIO_SETDATAOUT, 4
    call gpio_output_enable

    mov  r30.w0, r22.w0
    ret


//******************************************************************************
//*
//* st_write - Sends out ST data once it is available
//*
st_write:
    // Back up the call register
    mov  r22.w0, r30.w0

    // Wait until ST data is available for writing
    mov  r2.w0, PRU_INTC_SRSR0
    wcbs r1, CONST_PRU_INTC, r2.w0, ST_WRITE_EVENT

    mov  spi_buffer.address, ST_BUFFER_ADDR

    // Only transmit if either of the update flags are set
    lbbo r1.w0, spi_buffer.address, 1, 2
    qbeq st_write_complete, r1.w0, 0

    // Set up transfer parameters
    mov  gpio_pin.base, ST_GPIO_BASE
    mov  gpio_pin.mask, ST_GPIO_MASK

    mov  spi_buffer.mode, MCSPI_WRITE

    mov  spi_buffer.cmd, ST_WRITE_CMD
    mov  spi_buffer.length, ST_WRITE_LENGTH

    // Perform the write operation
    call mcspi_transfer

st_write_complete:
    // Clear the input event to let the host know we're done
    mov  r1, ST_WRITE_EVENT
    mov  r2.w0, PRU_INTC_SICR
    sbco r1, CONST_PRU_INTC, r2.w0, 4

    mov  r30.w0, r22.w0
    ret
