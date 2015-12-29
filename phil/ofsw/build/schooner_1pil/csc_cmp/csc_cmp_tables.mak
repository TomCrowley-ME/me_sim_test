###############################################################################
# File: CSC Table Makefile
#
#
# History:
#
###############################################################################
#
# Subsystem that owns the tables produced by this makefile.
#
APPTARGET = csc_cmp

EXEDIR = ../exe

########################################################################
# Should not have to change below this line, except for customized
# Mission and cFE directory structures
########################################################################

##
## Include all necessary cFE make rules
## Any of these can be copied to a local file and
## changed if needed.
##
##
##       cfe-config.mak contians arch, BSP, and OS selection
##
include ../cfe/cfe-config.mak

##
##       debug-opts.mak contains debug switches
##
include ../cfe/debug-opts.mak

##
##       compiler-opts.mak contains compiler definitions and switches/defines
##
include $(CFE_PSP_SRC)/$(PSP)/make/compiler-opts.mak


#########################################################################
# Table buile rules
#########################################################################
$(APPTARGET)_params.tbl:
	elf2cfetbl $(APPTARGET).$(APP_EXT)

install:
	cp $(APPTARGET)_params.tbl $(EXEDIR)
