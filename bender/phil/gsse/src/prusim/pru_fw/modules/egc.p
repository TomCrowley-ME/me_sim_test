// *****************************************************************************/
// file:     egc.p
//
// purpose:  EGC Microcontroller Interface Functions
//
// *****************************************************************************/

#include "../puppetmaster.hp"
#include "../puppetmaster_interface.h"
#include "../gpio.hp"
#include "../mcspi.hp"

#include "egc.hp"

//******************************************************************************
//*
//* egc_init - Currently unneeded as this device shares a microcontroller
//*            with the star tracker. Microcontroller initialization is in
//*            the file st.p.
//*
//egc_init:
//   ret

//******************************************************************************
//*
//* egc_read - Reads the current EGC throttle setting from the microcontroller
//*            Blocks until receipt of the EGC_READ_EVENT
//*
egc_read:
    // Back up the call register
    mov  r22.w0, r30.w0

    // Wait until we're synchronized and told to go ahead with the read
    mov  r2.w0, PRU_INTC_SRSR0
    wcbs r1, CONST_PRU_INTC, r2.w0, EGC_READ_EVENT

    // Set up transfer parameters
    mov  gpio_pin.base, EGC_GPIO_BASE
    mov  gpio_pin.mask, EGC_GPIO_MASK

    mov spi_buffer.mode, MCSPI_READ

    mov spi_buffer.cmd, EGC_READ_CMD
    mov spi_buffer.length, EGC_READ_LENGTH
    mov spi_buffer.address, EGC_BUFFER_ADDR

    // Perform the read operation
    call mcspi_transfer

    // Clear the input event to let the host know we're done
    mov  r1, EGC_READ_EVENT
    mov  r2.w0, PRU_INTC_SICR
    sbco r1, CONST_PRU_INTC, r2.w0, 4

    mov  r30.w0, r22.w0
    ret
