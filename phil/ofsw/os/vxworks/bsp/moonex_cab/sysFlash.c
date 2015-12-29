#include "sysFlash.h"
#include "moonex_cab.h"

/*******************************************************************************
*
* flashWaitUntilReady - wait for the flash to become ready
*
* Waits for the flash to become ready to receive the next command.
*
* RETURNS: N/A
*/

static void flashWaitUntilReady() {
    UINT8 status;
    do {
        status = cabInByte(CAB_FLASH_FPGA_STATUS);
    } while (status != 0);

    /* TODO: this will be unnecessary when the status register actually works */
    vxbUsDelay(20);
}

/*******************************************************************************
*
* sysFlashWriteEnable - enable writing to flash memory
*
* This routine enables writing to flash.
*
* RETURNS: N/A
*
* SEE ALSO: sysFlashWriteDisable()
*/

void sysFlashWriteEnable() {
    UINT8 old_page = sysFpgaLockPage(FPGA_PAGE_FLASH);

    cabOutByte(CAB_FLASH_CMD, FLASH_WRITE_ENABLE);

    flashWaitUntilReady();

    sysFpgaUnlockPage(old_page);
}

/*******************************************************************************
*
* sysFlashWriteDisable - enable writing to flash memory
*
* This routine disables writing to flash.
*
* RETURNS: N/A
*
* SEE ALSO: sysFlashWriteEnable()
*/

void sysFlashWriteDisable() {
    UINT8 old_page = sysFpgaLockPage(FPGA_PAGE_FLASH);

    cabOutByte(CAB_FLASH_CMD, FLASH_WRITE_DISABLE);

    flashWaitUntilReady();

    sysFpgaUnlockPage(old_page);
}

/******************************************************************************
*
* sysFlashSectorErase - erase a sector of flash memory
*
* This routine clears the contents of a sector of flash memory.
*
* RETURNS: OK, or ERROR if the contents of flash memory cannot be erased.
*/

STATUS sysFlashSectorErase(volatile void *start_address) {
    UINT8 old_page;
    UINT8 status;

    if ((UINT32)start_address >= FLASH_SIZE) {
        return ERROR;
    }

    old_page = sysFpgaLockPage(FPGA_PAGE_FLASH);

    cabOutByte(CAB_FLASH_ADDR_0, (UINT8)(((UINT32)start_address) & 0xFF));
    cabOutByte(CAB_FLASH_ADDR_1, (UINT8)(((UINT32)start_address >> 8) & 0xFF));
    cabOutByte(CAB_FLASH_ADDR_2, (UINT8)(((UINT32)start_address >> 16) & 0xFF));

    cabOutByte(CAB_FLASH_SECTOR_ERASE_3_ADDR, 1);

    flashWaitUntilReady();

    /* Wait for the command to finish */
    do {
        cabOutByte(CAB_FLASH_CMD_W_TLM, FLASH_GET_STATUS);
        flashWaitUntilReady();
        status = cabInByte(CAB_FLASH_DATA_BYTE);
    } while (status & FLASH_STATUS_BUSY);

    sysFpgaUnlockPage(old_page);
    return OK;
}

/******************************************************************************
*
* sysFlashSubsectorErase - erase a subsector of flash memory
*
* This routine clears the contents of a subsector of flash memory.
*
* RETURNS: OK, or ERROR if the contents of flash memory cannot be erased.
*/

STATUS sysFlashSubsectorErase(volatile void *start_address) {
    UINT8 old_page;
    UINT8 status;

    if ((UINT32)start_address >= FLASH_SIZE) {
        return ERROR;
    }

    old_page = sysFpgaLockPage(FPGA_PAGE_FLASH);

    cabOutByte(CAB_FLASH_ADDR_0, (UINT8)(((UINT32)start_address) & 0xFF));
    cabOutByte(CAB_FLASH_ADDR_1, (UINT8)(((UINT32)start_address >> 8) & 0xFF));
    cabOutByte(CAB_FLASH_ADDR_2, (UINT8)(((UINT32)start_address >> 16) & 0xFF));

    cabOutByte(CAB_FLASH_SUBSECTOR_ERASE_3_ADDR, 1);

    flashWaitUntilReady();

    /* Wait for the command to finish */
    do {
        cabOutByte(CAB_FLASH_CMD_W_TLM, FLASH_GET_STATUS);
        flashWaitUntilReady();
        status = cabInByte(CAB_FLASH_DATA_BYTE);
    } while (status & FLASH_STATUS_BUSY);

    sysFpgaUnlockPage(old_page);
    return OK;
}

/******************************************************************************
*
* sysFlashWrite - write data to flash memory
*
* This routine copies specified data of a specified length into a
* specified offset in the flash memory.
*
* RETURNS: OK, or ERROR if the write operation fails.
*
* SEE ALSO: sysFlashSet()
*/

int sysFlashWrite(volatile void* dest, const void* buffer, int length) {
    UINT8 old_page;
    UINT8 status;
    UINT32 i;

    if ((length <= 0) || (((UINT32)dest + length) > FLASH_SIZE)) {
        return ERROR;
    }

    old_page = sysFpgaLockPage(FPGA_PAGE_FLASH);

    for (i = 0; i < length; i++) {
        UINT32 dest_address = (UINT32)dest + i;
        cabOutByte(CAB_FLASH_ADDR_0, (UINT8)((dest_address) & 0xFF));
        cabOutByte(CAB_FLASH_ADDR_1, (UINT8)((dest_address >> 8) & 0xFF));
        cabOutByte(CAB_FLASH_ADDR_2, (UINT8)((dest_address >> 16) & 0xFF));

        cabOutByte(CAB_FLASH_PROGRAM_3_ADDR, ((UINT8*)buffer)[i]);
        flashWaitUntilReady();

        /* Wait for the command to finish */
        do {
            cabOutByte(CAB_FLASH_CMD_W_TLM, FLASH_GET_STATUS);
            flashWaitUntilReady();
            status = cabInByte(CAB_FLASH_DATA_BYTE);
        } while (status & FLASH_STATUS_BUSY);
    }

    sysFpgaUnlockPage(old_page);
    return OK;
}

/******************************************************************************
*
* sysFlashGet - get the contents of flash memory
*
* This routine copies the contents of flash memory into a specified
* string.  The string is terminated with an EOS.
*
* RETURNS: OK, or ERROR if access is outside the flash memory range.
*
* SEE ALSO: sysFlashSet()
*
*/

STATUS sysFlashGet(char *buf, int length, int offset) {
    UINT8 old_page;
    UINT32 i;

    if ((offset < 0) || (length < 0) || ((offset + length) > FLASH_SIZE)) {
        return ERROR;
    }

    old_page = sysFpgaLockPage(FPGA_PAGE_FLASH);

    for (i = 0; i < length; i++) {
        UINT32 src_address = (UINT32)offset + i;
        cabOutByte(CAB_FLASH_ADDR_0, (UINT8)((src_address) & 0xFF));
        cabOutByte(CAB_FLASH_ADDR_1, (UINT8)((src_address >> 8) & 0xFF));
        cabOutByte(CAB_FLASH_ADDR_2, (UINT8)((src_address >> 16) & 0xFF));

        cabOutByte(CAB_FLASH_READ_3_ADDR, 1);
        flashWaitUntilReady();

        buf[i] = cabInByte(CAB_FLASH_DATA_BYTE);
    }

    sysFpgaUnlockPage(old_page);
    return OK;
}

/******************************************************************************
*
* sysFlashSet - write to flash memory
*
* This routine copies a specified string into flash memory after calling
* sysFlashSubsectorErase().
*
* RETURNS: OK, or ERROR if the write fails or the input parameters are
* out of range.
*
* SEE ALSO: sysFlashSubsectorErase(), sysFlashGet(), sysFlashWrite()
*
*/

STATUS sysFlashSet (char *buf, int length, int offset) {
    char *tempBuffer;
    UINT32 subsector_addr;

    /* Calculate the start address of the target subsector */
    subsector_addr = offset & (~(FLASH_SUBSECTOR_SIZE-1));

    /* Limit to one subsector */
    if ((offset < 0) || (length < 0) || ((offset + length) > FLASH_SIZE) ||
            ((offset - subsector_addr + length) > FLASH_SUBSECTOR_SIZE)) {
        return ERROR;
    }

    /* Read the contents of the target subsector into a temporary buffer */
    tempBuffer = malloc(FLASH_SUBSECTOR_SIZE);
    sysFlashGet(tempBuffer, length, subsector_addr);

    /* Copy the new data over the temporary buffer */
    bcopyBytes(buf, (tempBuffer+offset-subsector_addr), length);

    /* Erase the target subsector... */
    sysFlashWriteEnable();
    sysFlashSubsectorErase((void*)subsector_addr);

    /* ...and write the updated data out */
    sysFlashWriteEnable();
    sysFlashWrite((void*)subsector_addr, tempBuffer, FLASH_SUBSECTOR_SIZE);

    free(tempBuffer);

    return OK;
}
