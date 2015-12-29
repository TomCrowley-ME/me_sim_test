###############################################################################
## compiler-opts.mak - compiler definitions and options for building the cFE
##
## Target: MoonEx CAB running VxWorks 6.7
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
$(FIXED_WIND_BASE)/target/config/moonex_cab \
$(OS_SRC)/vxworks/kernel/cab_ut699 \

SYSINCS = $(VXINCDIR:%=-I%)

##
## Target Defines for the OS, Hardware Arch, etc..
##
TARGET_DEFS = -D_VXWORKS_OS_ -D_SPARC_ -D__SPARC__ $(CFE_SB_NET) -D$(OS) -D_EMBED_ \
	     -DTOOL_FAMILY=gnu -DTOOL=gnuv8 -D_WRS_KERNEL -DCPU=SPARC

##
## Endian Defines
##
ENDIAN_DEFS=-D_EB -DENDIAN=_EB -DSOFTWARE_BIG_BIT_ORDER

##
## Compiler Architecture Switches
##
ARCH_OPTS = -ffloat-int-mode -mv8 -m32 -mcpu=ut699 -mtune=ut699 -fno-builtin -fvolatile -Wcast-align

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
COMPILER   = ccsparc
ASSEMBLER  = ccsparc
LINKER	   = ldsparc
AR	   = arsparc
NM         = nmsparc
OBJCPY     = objcopysparc
TABLE_BIN  = elf2cfetbl
MUNCH      = wtxtcl $(WIND_HOME)/vxworks-6.7/host/resource/hutils/tcl/munch.tcl -c sparc
