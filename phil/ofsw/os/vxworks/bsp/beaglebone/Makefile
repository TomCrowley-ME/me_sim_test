# Makefile - make rules for target/config/beaglebone
#
# Copyright (c) 2012 Wind River Systems, Inc.
#
# The right to copy, distribute, modify or otherwise make use
# of this software may be licensed only pursuant to the terms
# of an applicable Wind River license agreement.
#
# modification history
# --------------------
# 01a,12mar12,x_f  create from ti_dm81xx_evm/Makefile 01b.
#
# DESCRIPTION
# This file contains rules for building VxWorks for the BeagleBone
# board. This board features the Texas Instruments AM335X processor
# with an ARM Cortex-A8 core.
#
# INCLUDES
#     defs.bsp, rules.bsp
#

CPU           = ARMARCH7
TOOL          = diab
EXTRA_DEFINE  += -DCPU_CORTEXA8 \
                 -DARMMMU=ARMMMU_CORTEXA8 -DARMCACHE=ARMCACHE_CORTEXA8
VFPVARIANT = VFPV3

TGT_DIR = $(WIND_BASE)/target

include $(TGT_DIR)/h/make/defs.bsp

## Only redefine make definitions below this point, or your definitions will
## be overwritten by the makefile stubs above.

TARGET_DIR  = beaglebone
VENDOR      = TI
BOARD       = AM335X

RELEASE     += bootrom.bin

MACH_EXTRA  +=
LD_LINK_PATH  += -L$(TGT_DIR)/config/beaglebone

#
# The constants ROM_TEXT_ADRS and ROM_SIZE are defined in config.h and Makefile.
# All definitions for these constants must be identical.
#

ROM_TEXT_ADRS  = 00020000 # ROM entry address (bootrom)
ROM_SIZE       = 0000C000 # number of bytes of ROM space

RAM_LOW_ADRS   = 80100000 # RAM text/data address
RAM_HIGH_ADRS  = 81000000 # RAM text/data address

VMA_START    = 0x$(ROM_TEXT_ADRS)

bootrom.bin: bootrom
	- @ $(RM) $@
	$(EXTRACT_BIN) -O binary bootrom $@

bootrom_res.bin: bootrom_res
	- @ $(RM) $@
	$(EXTRACT_BIN) -O binary bootrom_res $@

bootrom_uncmp.bin: bootrom_uncmp
	- @ $(RM) $@
	$(EXTRACT_BIN) -O binary bootrom_uncmp $@

vxWorks_rom.bin: vxWorks_rom
	- @ $(RM) $@
	$(EXTRACT_BIN) -O binary vxWorks_rom $@

vxWorks.st_rom.bin: vxWorks.st_rom
	- @ $(RM) $@
	$(EXTRACT_BIN) -O binary vxWorks.st_rom $@

vxWorks.res_rom.bin: vxWorks.res_rom
	- @ $(RM) $@
	$(EXTRACT_BIN) -O binary vxWorks.res_rom $@

vxWorks.res_rom_nosym.bin: vxWorks.res_rom_nosym
	- @ $(RM) $@
	$(EXTRACT_BIN) -O binary vxWorks.res_rom_nosym $@

## Only redefine make definitions above this point, or the expansion of
## makefile target dependencies may be incorrect.

include $(TGT_DIR)/h/make/rules.bsp

