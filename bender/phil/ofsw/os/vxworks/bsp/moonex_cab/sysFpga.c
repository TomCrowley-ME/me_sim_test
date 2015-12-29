#include "moonex_cab.h"

#include <vxWorks.h>

/* Global mutex for paged FPGA access */
SEM_ID g_fpga_sem_id;

STATUS sysFpgaInit(void) {
    /* Start off by initializing the FPGA mutex, and take it for the remainder of initialization */
    g_fpga_sem_id = semMCreate(SEM_Q_PRIORITY | SEM_INVERSION_SAFE);

    semTake(g_fpga_sem_id, WAIT_FOREVER);

    /* Default to the status page */
    sysFpgaSetPage(FPGA_PAGE_STATUS);

    /* Initialize things! */

    /* FPGA and drivers are ready to go! */
    semGive(g_fpga_sem_id);

    return OK;
}

UINT8 sysFpgaGetPage(void) {
    return cabInByte(FPGA_PAGE_SELECT);
}

void sysFpgaSetPage(UINT8 page) {
    do {
        cabOutByte(FPGA_PAGE_SELECT, page);
    } while (cabInByte(FPGA_PAGE_SELECT) != page);
}

UINT8 sysFpgaLockPage(UINT8 page) {
	UINT8 old_page;

	if (!intContext()) {
		semTake(g_fpga_sem_id, WAIT_FOREVER);
	}
	old_page = sysFpgaGetPage();
	sysFpgaSetPage(page);

	return old_page;
}

void sysFpgaUnlockPage(UINT8 old_page) {
    sysFpgaSetPage(old_page);

    if (!intContext()) {
    	semGive(g_fpga_sem_id);
    }
}

UINT32 cabGetMET(void) {
    UINT8 old_page;
    UINT8 byte0, byte1, byte2, byte3;

    old_page = sysFpgaLockPage(FPGA_PAGE_STATUS);

    do {
        byte0 = cabInByte(CAB_MET_0);
        byte1 = cabInByte(CAB_MET_1);
        byte2 = cabInByte(CAB_MET_2);
        byte3 = cabInByte(CAB_MET_3);
    } while (byte0 != cabInByte(CAB_MET_0));

    sysFpgaUnlockPage(old_page);

    return (UINT32)byte3 << 24 | (UINT32)byte2 << 16 | (UINT32)byte1 << 8 | (UINT32)byte0;
}

void cabSetMET(UINT32 seconds) {
    UINT8 old_page;

    /* If we're not in an interrupt context, take the FPGA mutex */
    old_page = sysFpgaLockPage(FPGA_PAGE_STATUS);

    cabOutByte(CAB_MET_0, (UINT8)(seconds & 0xff));
    cabOutByte(CAB_MET_1, (UINT8)((seconds >>  8) & 0xff));
    cabOutByte(CAB_MET_2, (UINT8)((seconds >> 16) & 0xff));
    cabOutByte(CAB_MET_3, (UINT8)((seconds >> 24) & 0xff));

    sysFpgaUnlockPage(old_page);
}

UINT8 cabGetSCID(void) {
    /* no seriously we're ladee */
    return 0x35;
}
