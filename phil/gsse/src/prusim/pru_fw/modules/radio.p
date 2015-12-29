// *****************************************************************************/
// file:     radio.p
//
// purpose:  Radio Microcontroller Interface Functions
//
// *****************************************************************************/

#include "../puppetmaster.hp"
#include "../puppetmaster_interface.h"
#include "../gpio.hp"
#include "../mcspi.hp"

#include "radio.hp"

//******************************************************************************
//*
//* radio_init - Sets up radio pins and registers
//*
radio_init:
    // Back up the call register
    mov  r22.w0, r30.w0

    mov  gpio_pin.base, RADIO_GPIO_BASE
    mov  gpio_pin.mask, RADIO_GPIO_MASK

    // Take the SS line high first to prevent toggling
    sbbo gpio_pin.mask, gpio_pin.base, GPIO_SETDATAOUT, 4

    // Enable output on the SS line
    call gpio_output_enable

    // Enable the interrupt for the downlink event
    mov  r1.w0, PRU_INTC_EISR
    mov  r2, RADIO_DOWNLINK_EVENT
    sbco r2, CONST_PRU_INTC, r1.w0, 4

    // Map INTC channel 2 to host interrupt 2
    mov  r1.w0, PRU_INTC_HMR0
    mov  r3, (2 << 16)
    sbco r3, CONST_PRU_INTC, r1.w0, 4

    // Map RADIO_DOWNLINK_EVENT to INTC channel 2
    mov  r1.w0, PRU_INTC_CMR4
    mov  r2, 2
    sbco r2, CONST_PRU_INTC, r1.w0, 4

    // Enable host interrupt 2
    mov  r1.w0, PRU_INTC_HIEISR
    sbco r2, CONST_PRU_INTC, r1.w0, 4

    mov  r30.w0, r22.w0
    ret

//******************************************************************************
//*
//* radio_uplink - Sends out an uplink frame if one is available
//*
radio_uplink:
    // Back up the call register
    mov  r22.w0, r30.w0

    // Check to see if there is a pending uplink frame
    mov  r2.w0, PRU_INTC_SRSR0
    lbco r1, CONST_PRU_INTC, r2.w0, 4

    qbbc uplink_complete, r1, RADIO_UPLINK_EVENT

    // Set up transfer parameters
    mov  gpio_pin.base, RADIO_GPIO_BASE
    mov  gpio_pin.mask, RADIO_GPIO_MASK

    mov spi_buffer.mode, MCSPI_WRITE

    mov spi_buffer.cmd, RADIO_UPLINK_CMD
    mov spi_buffer.address, RADIO_UPLINK_BUFFER_ADDR

    // Get the uplink frame size from the uplink length register
    lbco spi_buffer.length, CONST_PRU_DRAM, PM_RADIO_UPLINK_LEN, 2

    // Perform the send operation
    call mcspi_transfer

    // Clear the input event to let the host know we're done
    mov  r1, RADIO_UPLINK_EVENT
    mov  r2.w0, PRU_INTC_SICR
    sbco r1, CONST_PRU_INTC, r2.w0, 4

uplink_complete:
    mov  r30.w0, r22.w0
    ret

//******************************************************************************
//*
//* radio_downlink - Grabs a (possibly empty) downlink frame from the radio MCU
//*
radio_downlink:
    // Back up the call register
    mov  r22.w0, r30.w0

    // Set up transfer parameters
    mov  gpio_pin.base, RADIO_GPIO_BASE
    mov  gpio_pin.mask, RADIO_GPIO_MASK

    mov  spi_buffer.mode, MCSPI_READ

    mov  spi_buffer.cmd, RADIO_DOWNLINK_CMD
    mov  spi_buffer.length, RADIO_DOWNLINK_LENGTH
    mov  spi_buffer.address, RADIO_DOWNLINK_BUFFER_ADDR

    // Perform the read operation
    call mcspi_transfer

    // Check to see if we got a valid frame marker
    lbbo r1, spi_buffer.address, 0, 4
    mov  r2, 0x1dfccf1a //Little-endian representation of sync pattern 0x1acffc1d

    qbne invalid_frame, r1, r2

    // Set the radio downlink event to notify the host we have a frame ready
    mov  r31.b0, RADIO_DOWNLINK_EVENT + R31_EVENT_SET

invalid_frame:
    mov  r30.w0, r22.w0
    ret

