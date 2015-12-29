#include "vxWorks.h"

/* Fills a buffer with a counting pattern */
INT32 countfill(UINT8* addr, INT32 length, UINT8 width, UINT32 start, INT32 increment) {
    UINT32 count = start;
    UINT8 *cur_addr;

    /* Address and length are absolutely required */
    if (addr == NULL || length <= 0) {
        return -1;
    }

    if (width == 0) {
        /* Assume single-byte width if no width is supplied */
        width = 1;
    } else if (width != 1 && width != 2 && width != 4) {
        /* Width must be 1, 2, or 4 */
        return -1;
    }

    /* Check that alignment makes sense */
    if (length % width != 0 || (UINT32)addr % width != 0) {
        return -1;
    }
    
    if (increment == 0) {
        /* Assume increment by 1 if not supplied */
        increment = 1;
    }

    /* Do the fill! */
    for (cur_addr = addr; cur_addr < (addr + length); cur_addr += width) {
        if (width == 1) {
            *(UINT8*)cur_addr = (UINT8)count;
        } else if (width == 2) {
            *(UINT16*)cur_addr = (UINT16)count;
        } else if (width == 4) {
            *(UINT32*)cur_addr = (UINT32)count;
        }
        count += increment;
    }
    return length;
}
