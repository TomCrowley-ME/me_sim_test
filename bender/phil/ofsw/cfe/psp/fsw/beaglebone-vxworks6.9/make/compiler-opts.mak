###############################################################################
## compiler-opts.mak - compiler definitions and options for building the cFE
##
## Target: Beaglebone running VxWorks 6.9
##
## Modifications:
##
###############################################################################
##
## Warning Level Configuration
##
## WARNINGS=-Wall -ansi -pedantic -Wstrict-prototypes
WARNINGS	= -Wall  -ansi

##
## A fix for Windows systems on vxWorks 6.4
## When generating dependancies, the Windows GCC cannot seem to deal
## with the Windows style path separators in the WIND_BASE macro.
##
FIXED_WIND_BASE = $(subst \,/,$(WIND_BASE))

##
## vxWorks system includes
##
VXINCDIR = $(FIXED_WIND_BASE)/target/h \
$(FIXED_WIND_BASE)/target/h/wrn/coreip \
$(FIXED_WIND_BASE)/target/h/drv \
$(FIXED_WIND_BASE)/target/src/config \
$(FIXED_WIND_BASE)/target/src/drv \
$(FIXED_WIND_BASE)/target/config/comps/src \
$(FIXED_WIND_BASE)/target/config/comps/src/dosfs2 \
$(FIXED_WIND_BASE)/target/config/beaglebone \
$(OS_SRC)/vxworks/kernel/all \

SYSINCS = $(VXINCDIR:%=-I%)

##
## Target Defines for the OS, Hardware Arch, etc..
##
TARGET_DEFS = -D_VXWORKS_OS_ -D_ARM_ -D__ARM__ $(CFE_SB_NET) -D$(OS) -D_EMBED_ \
	     -DTOOL_FAMILY=gnu -DTOOL=gnu -D_WRS_KERNEL -DCPU_CORTEXA8 -DARMMMU=ARMMMU_CORTEXA8 -DARMCACHE=ARMCACHE_CORTEXA8 -DVFPVARIANT=VFPV3

##
## Endian Defines
##
ENDIAN_DEFS=-D_EL -DENDIAN=_EL -DSOFTWARE_LITTLE_BIT_ORDER

##
## Compiler Architecture Switches
##
ARCH_OPTS = -fno-builtin -mcpu=cortex-a8 -march=armv7-a -mfpu=neon -mfloat-abi=softfp -mlong-calls

##
## Application specific compiler switches
##
ifeq ($(BUILD_TYPE),CFE_APP)
   APP_COPTS =
   APP_ASOPTS   =
else
   APP_COPTS =
   APP_ASOPTS   =
endif

##
## Extra Cflags for Assembly listings, etc.
##
LIST_OPTS    = -Wa,-a=$*.lis

##
## gcc options for dependancy generation
##
COPTS_D = $(APP_COPTS) $(ENDIAN_DEFS) $(TARGET_DEFS) $(ARCH_OPTS) $(SYSINCS) $(WARNINGS)

##
## General gcc options that apply to compiling and dependency generation.
##
COPTS=$(LIST_OPTS) $(COPTS_D)

##
## Extra defines and switches for assembly code
##
ASOPTS = $(APP_ASOPTS) -P -xassembler-with-cpp

##---------------------------------------------------------
## Application file extention type
## This is the defined application extention.
## Known extentions: Mac OS X: .bundle, Linux: .so, RTEMS:
##   .s3r, vxWorks: .o etc..
##---------------------------------------------------------
APP_EXT = o

####################################################
## Host Development System and Toolchain defintions
##
## Host OS utils
##
RM=rm -f
CP=cp

##
## Compiler tools
##
COMPILER   = ccarm
ASSEMBLER  = ccarm
LINKER	   = ldarm
AR	   = ararm
NM         = nmarm
OBJCPY     = objcopyarm
TABLE_BIN  = elf2cfetbl
MUNCH      = wtxtcl $(WIND_HOME)/vxworks-6.9/host/resource/hutils/tcl/munch.tcl -c arm
