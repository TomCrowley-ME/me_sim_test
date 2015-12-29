#include <vxWorks.h>
#include <rebootLib.h>
#include <sysLib.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "sysFlash.h"
#include "moonex_cab.h"

static void erase_bootloader_sectors(int num_sectors);
static void write_new_bootloader(FILE *fd, int size);
static void validate_stage1(FILE *fd);
static void validate_stage2(FILE *fd, int size);
static void start_progress_bar(void);
static void update_progress_bar(int progress, int max);
static void finish_progress_bar(void);

void flash_bootloader(void) {
    FILE *fd;

    /* Clear the screen, home the cursor, and make the text bright blue */
    printf("\33[2J\33[1;1H\33[1;34m");

    printf("            _______   ____   ____    _____  __      ___    _____  __   __\n"
           "           / _____/  /__ /  / __ /  / ___/ / /     /__ /  / ___/ / /  / /\n"
           "          / /      / /_/ / / /_/ / / /__  / /    / /_/ / / /__  / /__/ /\n"
           "         / /      / __  / / __ /  / ___/ / /    / __  / /__  / / ___  /\n"
           "        / /____  / / / / / /_/ / / /    / /__  / / / / ___/ / / /  / /\n"
           "       /______/ /_/ /_/ /____/  /_/    /____/ /_/ /_/ /____/ /_/  /_/\n\n");

    printf("\33[mPress ENTER to flash a bootloader, or press CTRL-X to reboot");
    getchar();

    fd = fopen("/romfs/bootrom.bin", "r");
    if (fd == NULL) {
        fprintf(stderr, "ERROR: Couldn't find /romfs/bootrom.bin!\n");
    } else {
        int size;

        /* Calculate the size of the bootloader, so we know how many sectors to erase */
        fseek(fd, 0, SEEK_END);
        size = ftell(fd);
        fseek(fd, 0, SEEK_SET);

        /* Round up to complete sectors when erasing */
        erase_bootloader_sectors((size + (FLASH_SECTOR_SIZE - 1))/ FLASH_SECTOR_SIZE);
        
        /* Now that the flash is empty, we can safely check stage1 to see if it's what we expect */
        validate_stage1(fd);

        /* Program the flash with the new bootloader */
        write_new_bootloader(fd, size);
        
        /* Validate the newly flashed bootloader image */
        validate_stage2(fd, size);

        printf("\n\nDone! Press ENTER to reboot...\n");
        getchar();
        reboot(BOOT_CLEAR);
    }
}

static void erase_bootloader_sectors(int num_sectors) {
    int i;
    printf("\33[32m\nErasing bootloader sectors...\33[m");
    start_progress_bar();

    for (i=0; i < num_sectors; i++) {
        /* Enable write and erase each sector */
        sysFlashWriteEnable();
        sysFlashSectorErase((void *)(FLASH_SECTOR_SIZE * i));

        update_progress_bar(i, num_sectors);
    }

    finish_progress_bar();
}

static void write_new_bootloader(FILE *fd, int size) {
    UINT8 *buf = NULL;
    int bytes_read = 0;
    int subsectors_written = 0;

    printf("\33[32m\nFlashing /romfs/bootrom.bin...\33[m");
    start_progress_bar();

    /* 
     * We'll be processing the data in subsector-sized chunks, for convenience.
     * Since all writes are currently single-byte only, there's no real
     * performance impact anyway. 
     */
    buf = malloc(FLASH_SUBSECTOR_SIZE);

    /* Read in each subsector-size chunk from the file and write it to the flash */
    bytes_read = fread(buf, 1, FLASH_SUBSECTOR_SIZE, fd);
    while (bytes_read != 0) {
        sysFlashWriteEnable();
        sysFlashWrite((void*)(subsectors_written*FLASH_SUBSECTOR_SIZE), buf, bytes_read);
        subsectors_written++;
        update_progress_bar(subsectors_written, size/FLASH_SUBSECTOR_SIZE);
        bytes_read = fread(buf, 1, FLASH_SUBSECTOR_SIZE, fd);
    }

    finish_progress_bar();

    free(buf);
}

static void validate_stage1(FILE *fd) {
    FILE *desc_fd;

    /* 
     * Since what we're flashing is a flat binary file, and not ELF, we need to look up
     * the size of the new stage1 from a file, and not be fancy and use symbols
     */
    desc_fd = fopen("/romfs/bootrom_stage1.desc", "r");
    if (desc_fd == NULL) {
        fprintf(stderr, "\33[1;31m\nWarning: couldn't open /romfs/bootrom_stage1.desc, not checking stage1\n\33[m");
    } else {
        int stage1_size;
        int i;
        UINT8 *buf;
        UINT32 *boot_inst;
        
        if (!fscanf(desc_fd, "size:%d", &stage1_size)) {
            fprintf(stderr, "\33[1;31m\nWarning: invalid /romfs/bootrom_stage1.desc, not checking stage1\n\33[m");
            return;
        }
        fclose(desc_fd);

        printf("\33[32m\nValidating stage1...\33[m");
        start_progress_bar();
        
        /*
         *  Check to see that the length of the current stage1 is what's expected.
         *  Erased flash holds 0xFFFFFFFF, which is not a valid SPARC instruction.
         *  We can therefore just keep reading instructions starting at address 0
         *  until we hit 0xFFFFFFFF, which will be the first address not provided
         *  the FPGAs.
         */
        boot_inst = 0;
        while (*boot_inst != 0xFFFFFFFF) {
            boot_inst++;
        }
        
        update_progress_bar(1, stage1_size+1);
        
        if ((int)boot_inst != stage1_size) {
            fprintf(stderr, "\33[1;31m\nWarning: detected incorrect stage1 size, CAB may not boot properly.\nPlease update your FPGAs!\33[m");
        } else {
            /* Read in the stage1 bytes but keep the file pointer at the beginning */
            buf = malloc(stage1_size);
            fseek(fd, 0, SEEK_SET);
            fread(buf, 1, stage1_size, fd);
            fseek(fd, 0, SEEK_SET);
            
            /* Check it byte-byte to make sure it hasn't changed on us */
            for (i = 0; i < stage1_size; i++) {
                if (buf[i] != cabInByte(i)) {
                    fprintf(stderr, "\33[1;31m\nWarning: detected stage1 differences, CAB may not boot properly.\nPlease update your FPGAs!\33[m");
                    break;
                }
                update_progress_bar(i+2, stage1_size+1);
            }

            free(buf);
        }

        finish_progress_bar();
    }
}

static void validate_stage2(FILE *fd, int size) {
    char *file_buf = NULL;
    char *flash_buf = NULL;
    int bytes_read = 0;
    int subsectors_checked = 0;

    printf("\33[32m\nValidating stage2...\33[m");
    start_progress_bar();

    /* Allocate buffers for both the file and the flash */
    file_buf = malloc(FLASH_SUBSECTOR_SIZE);
    flash_buf = malloc(FLASH_SUBSECTOR_SIZE);
    
    /* Rewind to the start of the file */
    fseek(fd, 0, SEEK_SET);

    /* Read in each subsector-size chunk from the file and check it against the flash */
    bytes_read = fread(file_buf, 1, FLASH_SUBSECTOR_SIZE, fd);
    while (bytes_read != 0) {
        sysFlashGet(flash_buf, bytes_read, subsectors_checked*FLASH_SUBSECTOR_SIZE);
        
        if (bcmp(file_buf, flash_buf, bytes_read) != 0) {
            fprintf(stderr, "\33[1;31m\nError detected in subsector %u while checking flash!\33[m", subsectors_checked);
            break;
        }
        
        subsectors_checked++;
        update_progress_bar(subsectors_checked, size/FLASH_SUBSECTOR_SIZE);
        bytes_read = fread(file_buf, 1, FLASH_SUBSECTOR_SIZE, fd);
    }

    finish_progress_bar();

    free(file_buf);
    free(flash_buf);
}

static void start_progress_bar(void) {
    /* 
     * Print out a 40-character-wide progress bar's bounds up against 
     * the right of the screen, and disable the cursor 
     */  
    printf("\33[?25l\33[39G[                                        ]");
}

static void update_progress_bar(int progress, int max) {
    int bars_done;
    int j;

    /* Translate the inputs into characters to print out of 40 */
    bars_done = min((40*(progress+1))/max, 40);
    /* Reset cursor to the start of the bar */
    printf("\33[40G");
    for (j=1; j <= bars_done; j++) {
        if (j < bars_done || j==40) {
            printf("=");
        } else {
            printf(">");
        }
    }
}

static void finish_progress_bar(void) {
    /* Re-enable the cursor */
    printf("\33[?25h");
}
