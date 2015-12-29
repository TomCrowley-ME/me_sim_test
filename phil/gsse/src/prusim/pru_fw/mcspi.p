// *****************************************************************************/
// file:     mcpspi.p
//
// purpose:  MCSPI Module Controller
//
// *****************************************************************************/

#include "mcspi.hp"

//******************************************************************************
//*
//* mcspi_init - Initializes the MCSPI module and sets up default registers
//*
mcspi_init:
    // Store the frequently used channel register offsets into upper registers
    mov  spi_regs.ch0conf, MCSPI_CH0CONF
    mov  spi_regs.ch0stat, MCSPI_CH0STAT
    mov  spi_regs.ch0ctrl, MCSPI_CH0CTRL
    mov  spi_regs.tx0, MCSPI_TX0
    mov  spi_regs.rx0, MCSPI_RX0

    // Initialize a module soft reset
    mov  r1, MCSPI_SYSCFG_SOFTRESET
    mov  r2.w0, MCSPI_SYSCONFIG
    sbco r1, CONST_MCSPI1, r2.w0, 4

    // Wait for the reset to be done
    mov  r2.w0, MCSPI_SYSSTATUS
    wcbs r1, CONST_MCSPI1, r2.w0, MCSPI_SYSSTAT_RESETDONE

    // Configure the SPI module in 3-pin single-channel master mode
    mov  r1, MCSPI_MODUL_SINGLE | MCSPI_MODUL_3PIN
    mov  r2.w0, MCSPI_MODULCTRL
    sbco r1, CONST_MCSPI1, r2.w0, 4

    // Configure channel 0 with the following:
    //   * Transmission on data line 0
    //   * Turbo Mode
    //   * 16 MHz clock speed
    //   * Word length of 8 (one byte)
    //   * POL=0, PHA=1
    //   * SS active low
    mov  r1, MCSPI_CHCONF_DPE0 | MCSPI_CHCONF_TURBO | MCSPI_CHCONF_CLKG | MCSPI_CHCONF_CLKD_2 | MCSPI_CHCONF_WL_8 | MCSPI_CHCONF_EPOL | MCSPI_CHCONF_PHA
    sbco r1, CONST_MCSPI1, spi_regs.ch0conf, 4

    ret

//******************************************************************************
//*
//* mcspi_transfer - Performs an SPI transfer
//*
mcspi_transfer:
    // Start by setting the FORCE_SPIEN bit for the channel and putting the
    // channel into transmit-only mode. Keep the value around in r1 so we
    // can clear the bits without a load later
    lbco r1, CONST_MCSPI1, spi_regs.ch0conf, 4
    set  r1, MCSPI_CHCONF_FORCE_SPIEN
    sbco r1, CONST_MCSPI1, spi_regs.ch0conf, 4

    // Enable the channel
    mov  r3, MCSPI_CHCTRL_EN
    sbco r3, CONST_MCSPI1, spi_regs.ch0ctrl, 4

    // Initialize a 0-based count register (r2.w0) and constant 0 register (r2.b3)
    mov  r2, 0

    // Take our slave select line low
    sbbo gpio_pin.mask, gpio_pin.base, GPIO_CLEARDATAOUT, 4

    // Wait for the TX register to be empty
    wcbs r3, CONST_MCSPI1, spi_regs.ch0stat, MCSPI_CHSTAT_TXS

    // Write out the transmission's command code
    sbco spi_buffer.cmd, CONST_MCSPI1, spi_regs.tx0, 1

    // Wait for the command to be complete
    wcbs r3, CONST_MCSPI1, spi_regs.ch0stat, MCSPI_CHSTAT_EOT

    // Wait for a bit (20us) to let the MCU think
    mov  r4, 4000 // 4000 * 5ns = 20us
    loop delay_20us, r4
    nop0 r4, r4, r4

delay_20us:
    qbeq transfer_read, spi_buffer.mode, MCSPI_READ

transfer_write:
    loop write_complete, spi_buffer.length

    // Empty out the receive register
    lbco r3.b0, CONST_MCSPI1, spi_regs.rx0, 1

    // Pull in a byte from the buffer and write it out to the transmit register
    lbbo r3.b0, spi_buffer.address, r2.w0, 1
    sbco r3.b0, CONST_MCSPI1, spi_regs.tx0, 1

    // Increment our buffer counter
    add  r2.w0, r2.w0, 1

    // Wait for the TX register to be empty again
    wcbs r3, CONST_MCSPI1, spi_regs.ch0stat, MCSPI_CHSTAT_TXS

write_complete:
    // Empty out the receive register
    wcbs r3, CONST_MCSPI1, spi_regs.ch0stat, MCSPI_CHSTAT_RXS
    lbco r3.b0, CONST_MCSPI1, spi_regs.rx0, 1

    qba  transfer_cleanup

transfer_read:
    // Empty out the receive register
    lbco r3.b0, CONST_MCSPI1, spi_regs.rx0, 1

    loop transfer_cleanup, spi_buffer.length

    // Write out a 0 to start a transmit cycle
    sbco r2.b3, CONST_MCSPI1, spi_regs.tx0, 1

    // Wait for the byte to be ready to read
    wcbs r3, CONST_MCSPI1, spi_regs.ch0stat, MCSPI_CHSTAT_RXS

    // Copy from the receive register into the buffer
    lbco r3.b0, CONST_MCSPI1, spi_regs.rx0, 1
    sbbo r3.b0, spi_buffer.address, r2.w0, 1

    // Increment our buffer counter
    add  r2.w0, r2.w0, 1

transfer_cleanup:
    // Wait for the transmission to complete
    wcbs r3, CONST_MCSPI1, spi_regs.ch0stat, MCSPI_CHSTAT_EOT

    // Disable the channel
    mov  r3, MCSPI_CHCTRL_DIS
    sbco r3, CONST_MCSPI1, spi_regs.ch0ctrl, 4


    // Turn off SPIEN and write out to the channel config register
    clr  r1, MCSPI_CHCONF_FORCE_SPIEN
    sbco r1, CONST_MCSPI1, spi_regs.ch0conf, 4

    // Finish by taking the slave select line high again
    sbbo gpio_pin.mask, gpio_pin.base, GPIO_SETDATAOUT, 4

    ret
