// *****************************************************************************/
// file:     imu.p
//
// purpose:  IMU Microcontroller Interface Functions
//
// *****************************************************************************/

#include "../puppetmaster.hp"
#include "../puppetmaster_interface.h"
#include "../gpio.hp"
#include "../mcspi.hp"

#include "imu.hp"

//******************************************************************************
//*
//* imu_init - Sets up IMU pins and registers
//*
imu_init:
    // Back up the call register
    mov  r22.w0, r30.w0

    // Take high and enable the three slave select lines
    mov  gpio_pin.base, IMU_GPIO_BASE
    mov  gpio_pin.mask, IMU_GPIO_MASK
    sbbo gpio_pin.mask, gpio_pin.base, GPIO_SETDATAOUT, 4
    call gpio_output_enable

    mov  r30.w0, r22.w0
    ret

//******************************************************************************
//*
//* imu_write - Sends out IMU data once it is available
//*
imu_write:
    // Back up the call register
    mov  r22.w0, r30.w0

    // Wait until IMU data is available for writing
    mov  r2.w0, PRU_INTC_SRSR0
    wcbs r1, CONST_PRU_INTC, r2.w0, IMU_WRITE_EVENT

    // Set up transfer parameters
    mov  spi_buffer.mode, MCSPI_WRITE

    mov  spi_buffer.cmd, IMU_WRITE_CMD
    mov  spi_buffer.length, IMU_WRITE_LENGTH

    // Write out the IMU buffer
    mov  spi_buffer.address, IMU_BUFFER_ADDR
    mov  gpio_pin.base, IMU_GPIO_BASE
    mov  gpio_pin.mask, IMU_GPIO_MASK
    call mcspi_transfer

    // Clear the input event to let the host know we're done
    mov  r1, IMU_WRITE_EVENT
    mov  r2.w0, PRU_INTC_SICR
    sbco r1, CONST_PRU_INTC, r2.w0, 4

    mov  r30.w0, r22.w0
    ret
