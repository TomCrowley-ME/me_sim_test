#include <vxWorks.h>
#include <tickLib.h>
#include "pru_icss.h"

/*******************************************************************************
*
* pru_icss_pru_enable - Enables the specified PRU unit
*
* This routine enables the specified PRU unit, causing it to start executing
*
* RETURNS: OK or ERROR if invalid PRU selected
*/
STATUS pru_icss_pru_enable(UINT32 pru_num) {
    UINT32 *pru_ctrl_reg = 0;

    /* Calculate the address of the PRU control register */
    if (pru_num == 0) {
        pru_ctrl_reg = (UINT32*)(PRU0_CTRL_BASE + PRU_CTRL_CONTROL_OFFSET);
    } else if (pru_num == 1) {
        pru_ctrl_reg = (UINT32*)(PRU1_CTRL_BASE + PRU_CTRL_CONTROL_OFFSET);
    } else {
        return ERROR;
    }

    /*
    ** Start it off! For now we want all the other bits in the control
    ** register to stay zero, so we just set everything at once
    */
    am335xOutLong(pru_ctrl_reg, PRU_ENABLE);

    return OK;
}

/*******************************************************************************
*
* pru_icss_pru_disable - Disables the specified PRU unit
*
* This routine disables the specified PRU unit, causing it to stop executing
*
* RETURNS: OK or ERROR if invalid PRU selected
*/
STATUS pru_icss_pru_disable(UINT32 pru_num) {
    UINT32 *pru_ctrl_reg = 0;

    /* Calculate the address of the PRU control register */
    if (pru_num == 0) {
        pru_ctrl_reg = (UINT32*)(PRU0_CTRL_BASE + PRU_CTRL_CONTROL_OFFSET);
    } else if (pru_num == 1) {
        pru_ctrl_reg = (UINT32*)(PRU1_CTRL_BASE + PRU_CTRL_CONTROL_OFFSET);
    } else {
        return ERROR;
    }

    /*
    ** Disable it. For now we want all the other bits in the control
    ** register to stay zero, so we just set everything at once
    */
    am335xOutLong(pru_ctrl_reg, PRU_DISABLE);

    return OK;
}

/*******************************************************************************
*
* pru_icss_pru_load - Loads firmware for a PRU
*
* This routine loads a firmware binary file into the instruction RAM of the
* specified PRU.
*
* RETURNS: OK or ERROR if initialisation fails
*/
STATUS pru_icss_pru_load(UINT32 pru_num, char *buffer, size_t length) {
    char *pru_iram_base = 0;

    /* We need a real pointer to do this, damnit */
    if (buffer == NULL) {
        return ERROR;
    }

    /* Check the length of the buffer */
    if (length > PRU_IRAM_SIZE) {
        PRU_ICSS_LOG("Specified PRU firmware length %u is greater than the size of the instruction RAM (%u)!\n",length,PRU_IRAM_SIZE,0,0,0,0);
        return ERROR;
    }
    if (length % sizeof(UINT32) != 0) {
        PRU_ICSS_LOG("Specified PRU firmware length %u is not an even multiple of 4",length,0,0,0,0,0);
        return ERROR;
    }

    /* Select the instruction RAM for the specified PRU */
    if (pru_num == 0) {
        pru_iram_base = (char*)PRU0_IRAM_BASE;
    } else if (pru_num == 1) {
        pru_iram_base = (char*)PRU1_IRAM_BASE;
    } else {
        PRU_ICSS_LOG("Invalid PRU #%uspecified!\n",pru_num,0,0,0,0,0);
        return ERROR;
    }

    /* Make sure the PRU is disabled so we can access its instruction RAM. */
    pru_icss_pru_disable(pru_num);

    /* Copy the buffer into the instruction RAM! */
    bcopyLongs(buffer, pru_iram_base, length / sizeof(UINT32));

    return OK;
}

/*******************************************************************************
*
* pru_icss_set_event - Sets the specified system event in the INTC
*
* This routine sets the corresponding INTC system event bit
*
* RETURNS: OK or ERROR if invalid event number
*/
STATUS pru_icss_set_event(UINT8 event) {
    if (event >= 64) {
        return ERROR;
    }
    am335xOutLong(PRU_ICSS_INTC_SISR, event);
    return OK;
}

/*******************************************************************************
*
* pru_icss_clear_event - Clears the specified system event in the INTC
*
* This routine clears the corresponding INTC system event bit
*
* RETURNS: OK or ERROR if invalid event number
*/
STATUS pru_icss_clear_event(UINT8 event) {
    if (event >= 64) {
        return ERROR;
    }
    am335xOutLong(PRU_ICSS_INTC_SICR, event);
    return OK;
}

/*******************************************************************************
*
* pru_icss_wait_event_set - Waits for the specified system event in the INTC
*
* This routine waits indefinitely for the corresponding INTC system event bit
* to become set in the PRU-ICSS INTC
*
* RETURNS: OK or ERROR if invalid event number
*/
STATUS pru_icss_wait_event_set(UINT8 event, _Vx_ticks_t timeout) {
    UINT32 reg = 0;
    UINT32 val = 0;
    _Vx_ticks_t   startTicks;
    _Vx_ticks_t   currentTicks;

    if (event < 64) {
        if (event < 32) {
            reg = PRU_ICSS_INTC_SRSR0;
            val = 1 << event;
        } else {
            reg = PRU_ICSS_INTC_SRSR1;
            val = 1 << (event - 32);
        }

        startTicks = tickGet();
        currentTicks = startTicks;

        while ((am335xInLong(reg) & val) == 0) {
            currentTicks = tickGet();
            if ((timeout != WAIT_FOREVER) && ((currentTicks - startTicks) >= timeout)) {
                return ERROR;
            }
        }
    } else {
        return ERROR;
    }
    return OK;
}

/*******************************************************************************
*
* pru_icss_wait_event_clear - Waits for the specified system event in the INTC
*
* This routine waits indefinitely for the corresponding INTC system event bit
* to become clear in the PRU-ICSS INTC
*
* RETURNS: OK or ERROR if invalid event number
*/
STATUS pru_icss_wait_event_clear(UINT8 event, _Vx_ticks_t timeout) {
    UINT32 reg = 0;
    UINT32 val = 0;
    _Vx_ticks_t   startTicks;
    _Vx_ticks_t   currentTicks;

    if (event < 64) {
        if (event < 32) {
            reg = PRU_ICSS_INTC_SRSR0;
            val = 1 << event;
        } else {
            reg = PRU_ICSS_INTC_SRSR1;
            val = 1 << (event - 32);
        }

        startTicks = tickGet();
        currentTicks = startTicks;

        while ((am335xInLong(reg) & val) != 0) {
            currentTicks = tickGet();
            if ((timeout != WAIT_FOREVER) && ((currentTicks - startTicks) >= timeout)) {
                return ERROR;
            }
        }
    } else {
        return ERROR;
    }
    return OK;
}

/*******************************************************************************
*
* pru_icss_check_event - Checks for the specified system event in the INTC
*
* This routine checks to see if the corresponding INTC system event bit
* is set in the PRU-ICSS INTC
*
* RETURNS: OK or ERROR if invalid event number
*/
INT32 pru_icss_check_event(UINT8 event) {
    INT32 status = ERROR;
    if (event < 32) {
        status = (am335xInLong(PRU_ICSS_INTC_SRSR0) & (1 << event)) != 0;
    } else if (event < 64) {
        status = (am335xInLong(PRU_ICSS_INTC_SRSR1) & (1 << (event - 32))) != 0;
    }
    return status;
}
