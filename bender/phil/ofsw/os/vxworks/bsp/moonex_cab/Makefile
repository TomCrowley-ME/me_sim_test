SPARCLEON_MMU   = 1

CPU             = SPARC
TOOL            = gnu

TGT_DIR = $(WIND_BASE)/target
include $(TGT_DIR)/h/make/defs.bsp

##
## Only redefine make definitions below this point, or your definitions will
## be overwritten by the makefile stubs above.
##

TARGET_DIR	= moonex_cab
VENDOR		= Moon Express
BOARD		= CAB

RELEASE         += bootrom_uncmp.hex

USR_ENTRY	= usrInit

## The constants ROM_TEXT_ADRS, ROM_SIZE, and RAM_HIGH_ADRS are defined
## in config.h, MakeSkel, Makefile, and Makefile.*
## All definitions for these constants must be identical.

ROM_TEXT_ADRS   = 00000000  # ROM entry address
ROM_SIZE        = 00200000  # number of bytes of ROM space 2 MB

RAM_LOW_ADRS    = 40003000  # RAM text/data address
RAM_HIGH_ADRS   = 48003000  # RAM text/data address, for 64Meg 01D00000 and for 16Meg 00D00000

## Uncomment the following line to enable debugging
## EXTRA_DEFINE    = -g

MACH_EXTRA	=
EXTRA_MODULES   =

EXTRACT_STAGE1=text_addr=`sparc-wrs-vxworks-objdump -h $(1) | grep .text | awk '{ print toupper($$4) }' `;\
        stage1_addr=`sparc-wrs-vxworks-objdump -t $(1) | grep _stage1 | awk '{ print toupper($$1) }'` ;\
	stage2_addr=`sparc-wrs-vxworks-objdump -t $(1) | grep _stage2 | awk '{ print toupper($$1) }'` ;\
	stage1_size=`echo "ibase=16;$$stage2_addr - $$stage1_addr" | bc` ;\
	stage1_offset=`echo "ibase=16;$$stage1_addr - $$text_addr" | bc` ;\
	echo "Extracting stage1 bootloader from $(2):" ;\
	echo "   Offset: $$stage1_offset" ;\
	echo "   Size:   $$stage1_size bytes" ;\
	echo "size:$$stage1_size" > bootrom_stage1.desc ;\
	dd if=$(2) of=bootrom_stage1.bin bs=1 count=$$stage1_size skip=$$stage1_offset

bootrom_stage1.bin: bootrom.bin bootrom
	- @ $(RM) $@
	$(call EXTRACT_STAGE1,$(word 2,$^),$<)

bootrom.bin: bootrom
	- @ $(RM) $@
	$(EXTRACT_BIN) $< $@
	$(MAKE) bootrom_stage1.bin

## Only redefine make definitions above this point, or the expansion of
## makefile target dependencies may be incorrect.

include $(TGT_DIR)/h/make/rules.bsp
