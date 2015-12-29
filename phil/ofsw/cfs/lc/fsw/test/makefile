##############################################################################
## GNU Makefile for building UTF unit tests
## 11/23/05 nschweiss Revised to be compatible with directory structure
##                    found in MKS repository.
## 11/28/05 nschweiss Changed uu_app.o -> tt_app.o.
##                    Changed driver name -> test_tbl_api2.


UTF_SRC=../../../../cfe/tools/utf/
CFE_CORE_SRC=../../../../cfe/fsw/cfe-core/src
CFS_SRC=../../..
OSAL_SRC=../../../../osal/src/os
CFE_PSP_SRC=../../../../cfe/psp/fsw
CFE_MISSION_INC=../../../../cfe/fsw/mission_inc
CFE_PLATFORM_INC=../../../../cfe/fsw/platform_inc
OFSW_BUILD=../../../../build
OFSW_SRC=../../../../src

# path to source files not in build directory
VPATH := $(UTF_SRC)/src
VPATH += $(CFE_CORE_SRC)/sb
VPATH += $(CFE_CORE_SRC)/time
VPATH += $(CFE_CORE_SRC)/es
VPATH += $(CFE_CORE_SRC)/fs
VPATH += $(CFE_PSP_SRC)/pc-linux/src
VPATH += ../src
VPATH += ../tables

# include paths
INCLUDES := -I.
INCLUDES += -I$(UTF_SRC)/inc
INCLUDES += -I$(CFE_CORE_SRC)/inc
INCLUDES += -I$(CFE_CORE_SRC)/sb
INCLUDES += -I$(CFE_CORE_SRC)/time
INCLUDES += -I$(CFE_CORE_SRC)/es
INCLUDES += -I$(CFE_CORE_SRC)/evs
INCLUDES += -I$(CFE_CORE_SRC)/tbl
#INCLUDES += -I../../../../osal/src/bsp/pc-linux/config/
INCLUDES += -I$(OSAL_SRC)/inc
INCLUDES += -I$(OFSW_SRC)/inc
#INCLUDES += -I$(OFSW_BUILD)/mx1/inc
#INCLUDES += -I$(OFSW_BUILD)/schooner/inc
INCLUDES += -I$(CFE_PSP_SRC)/inc
INCLUDES += -I$(CFE_PSP_SRC)/pc-linux/inc
INCLUDES += -I$(CFE_MISSION_INC)
INCLUDES += -I$(CFE_PLATFORM_INC)/pc-linux
INCLUDES += -I../src
INCLUDES += -I../tables
INCLUDES += -I$(CFS_SRC)/sc/fsw/src

# UTF object files
UTF_OBJS := utf_osapi.o
UTF_OBJS += utf_cfe_psp_eeprom.o
UTF_OBJS += utf_cfe_psp_memory.o
UTF_OBJS += utf_cfe_psp_memrange.o
UTF_OBJS += utf_cfe_psp_memutils.o
UTF_OBJS += utf_cfe_psp_port.o
UTF_OBJS += utf_cfe_psp_ram.o
UTF_OBJS += utf_cfe_psp_support.o
UTF_OBJS += utf_osfilesys.o
UTF_OBJS += utf_osfileapi.o
UTF_OBJS += utf_cfe_sb_api.o
UTF_OBJS += utf_cfe_time_api.o
UTF_OBJS += utf_cfe_time_utils.o
UTF_OBJS += utf_cfe_sb.o
UTF_OBJS += utf_sim.o
UTF_OBJS += utf_cfe_es_api.o
UTF_OBJS += utf_cfe_es_cds.o
UTF_OBJS += utf_cfe_esmempool.o
UTF_OBJS += utf_cfe_evs.o
UTF_OBJS += utf_cfe_tbl_api.o
UTF_OBJS += utf_cfe_tbl_internal.o

# flight code object files
UTF_OBJS += ccsds.o
UTF_OBJS += cfe_sb_util.o
UTF_OBJS += cfe_es_cds_mempool.o
UTF_OBJS += cfe_fs_api.o
UTF_OBJS += cfe_psp_timer.o
UTF_OBJS += cfe_psp_watchdog.o

# test specific
UTF_OBJS += lc_task.o
UTF_OBJS += lc_task_process_commands.o
UTF_OBJS += lc_task_process_tlm.o
UTF_OBJS += lc_task_watchpoint_table.o
UTF_OBJS += lc_task_actionpoint_table.o
UTF_OBJS += test_LC_common.o

###############################################################################

COMPILER=gcc
LINKER=gcc

DEFAULT_COPT = -Wall -Wstrict-prototypes -ansi -g

COPT = -DSOFTWARE_LITTLE_BIT_ORDER -D_EL -D_ix86_ -m32 -DDEBUG_LOG -D_LINUX_OS_

LOPT = -m32

##
## Target Defines for the OS, Hardware Arch, etc..
## These settings are assuming that the tool is being run on an x86 processor
## with a linux (or linux-like) operating system
ELF2CFETBL_DEFS=-D__ix86__ -D_ix86_ -D_LINUX_OS_ -DHWARCH=x86 -Dx86 -Dlinux -DX86PC -DBUILD=$(BUILD) -D_REENTRANT -D _EMBED_

##
## Endian Defines
##
ELF2CFETBL_ENDIAN_DEFS=-D_EL -DENDIAN=_EL -DSOFTWARE_LITTLE_BIT_ORDER

#echo "Building src in = " $INCLUDE

###############################################################################
##  "C" COMPILER RULE
##
%.o: %.c
	$(COMPILER) -c $(COPT) $(DEFAULT_COPT) $(INCLUDES) $<

##############################################################################
##1

all: test_LC_1 test_LC_2 tables

elf2cfetbl:
	$(COMPILER) $(TARGET_DEFS) $(ENDIAN_DEFS) $(INCLUDES) -m32 -g -o elf2cfetbl ../../../../cfe/tools/elf2cfetbl/elf2cfetbl.c

tables: elf2cfetbl
	$(COMPILER) -c $(COPT) $(DEFAULT_COPT) $(INCLUDES) ../tables/lc_def_wdt.c
	./elf2cfetbl lc_def_wdt.o ptbl/
	$(COMPILER) -c $(COPT) $(DEFAULT_COPT) $(INCLUDES) ../tables/lc_def_adt.c
	./elf2cfetbl lc_def_adt.o ptbl/

test_LC_1: test_LC_1.o $(UTF_OBJS)
	$(LINKER) $(LOPT) $^ -o $@ 

test_LC_2: test_LC_2.o $(UTF_OBJS)
	$(LINKER) $(LOPT) $^ -o $@ 

clean ::
	rm -f *.o test_LC_1 test_LC_2 ptbl/*.tbl elf2cfetbl

# end of file
