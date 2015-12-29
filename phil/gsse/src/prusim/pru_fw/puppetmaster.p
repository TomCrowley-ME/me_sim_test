// *****************************************************************************/
// file:     puppetmaster.p
//
// purpose:  Coprocessor firmware for microcontroller communications
//
// *****************************************************************************/

.origin 0
.entrypoint puppetmaster

#include "puppetmaster.hp"
#include "gpio.hp"
#include "mcspi.hp"

puppetmaster:
    // Enable OCP master ports
    lbco r1, CONST_PRU_CFG, PRU_SYSCFG, 4
    clr  r1, PRU_SYSCFG_STANDBY_INIT
    sbco r1, CONST_PRU_CFG, PRU_SYSCFG, 4

    // Initialize SPI
    call mcspi_init

    // Perform device initialization
#ifdef INCLUDE_GPS
    call gps_init
#else
    call radio_init
#endif
    call valves_init
    call st_init
#ifdef INCLUDE_IMU
    call imu_init
#else
    call pyros_init
#endif
    call mems_init
    call thermpow_init
    call payloads_init
    call heaters_init
    call altimeter_init
    call bmb_init

    // Globally enable interrupts
    mov  r2, 1
    mov  r1.w0, PRU_INTC_GER
    sbco r2, CONST_PRU_INTC, r1.w0, 4

    // Enter into infinite device IO loop
main_loop:
#ifdef INCLUDE_EGC
    // Start off with a synchronized EGC reading
    call egc_read
#endif

#ifdef INCLUDE_VALVES
    // Do a synchronized valve reading
    call valves_read
#endif

#ifdef INCLUDE_RADIO
    // Downlink a radio frame if one is available
    call radio_downlink

    // Send an uplink frame if one is pending
    call radio_uplink
#endif

#ifdef INCLUDE_STARTRACKER
    // Send ST data out once it becomes available
    call st_write
#endif

#ifdef INCLUDE_IMU
    // Send IMU data out once it becomes available
    call imu_write
#endif

#ifdef INCLUDE_MEMS
    // Send MEMS data out once it becomes available
    call mems_write
#endif

#ifdef INCLUDE_GPS
    // Send GPS data out once it becomes available
    call gps_write
#endif

#ifdef INCLUDE_AD
    // Send A/D data out once it becomes available
    call thermpow_ad_write
#endif

    jmp  main_loop

    halt

// Include support sources
#include "mcspi.p"
#include "gpio.p"

// Include device modules -- currently all are included
// because each module takes care of its own slave select
// line initialization, and we need all of them to be
// set up to prevent bus contention
#ifdef INCLUDE_GPS
#include "modules/gps.p"
#else
#include "modules/radio.p"
#endif
#include "modules/valves.p"
#include "modules/st.p"
#ifdef INCLUDE_IMU
#include "modules/imu.p"
#else
#include "modules/pyros.p"
#endif
#include "modules/mems.p"
#include "modules/thermpow.p"
#include "modules/egc.p"
#include "modules/payloads.p"
#include "modules/heaters.p"
#include "modules/altimeter.p"
#include "modules/bmb.p"
