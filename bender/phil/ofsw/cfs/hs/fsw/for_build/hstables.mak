###############################################################################
# File: cFE Table Makefile
#
#
# History:
#
###############################################################################
#
# Subsystem that owns the tables produced by this makefile.
#
APPTARGET = hs

#
# Tables produced by this makefile.
#
TABLES = hs_mat_tbl.tbl hs_amt_tbl.tbl hs_emt_tbl.tbl

#
# Object files required to build tables.
#
OBJS = hs_mat_tbl.o hs_amt_tbl.o hs_emt_tbl.o

#
# Source files required to build tables; used to generate dependencies.
#
SOURCES = $(OBJS:.o=.c)

##
## Specify extra C Flags needed to build these tables
##
LOCAL_COPTS =

##
## EXEDIR is defined here, just in case it needs to be different for a custom
## build
##
EXEDIR = ../exe/ptbl

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
include ../make/cfe-config.mak

##
##       debug-opts.mak contains debug switches
##
include ../make/debug-opts.mak

##
##       compiler-opts.mak contains compiler definitions and switches/defines
##
include $(CFE_PSP_SRC)/$(PSP)/make/compiler-opts.mak

##
## Setup the include path for these tables
## The OS specific includes are in the build-rules.make file
##
## If the tables needs include files from another app, add the path here.
##
INCLUDE_PATH = \
-I$(OSAL_SRC)/inc \
-I$(CFE_CORE_SRC)/inc \
-I$(CFE_PSP_SRC)/inc \
-I$(CFE_PSP_SRC)/$(PSP)/inc \
-I$(CFS_APP_SRC)/inc \
-I$(CFS_APP_SRC)/$(APPTARGET)/fsw/src \
-I$(CFS_MISSION_INC) \
-I$(CFS_PLATFORM_INC)/$(PSP) \
-I../cfe/inc \
-I../inc

##
## Define the VPATH make variable.
## This can be modified to include source from another directory.
## If there is no corresponding app in the cfe-apps directory, then this can be discarded, or
## if the mission chooses to put the src in another directory such as "src", then that can be
## added here as well.
##
VPATH = tables

##
## Include the common make rules for building cFE tables
##
include $(CFE_CORE_SRC)/make/table-rules.mak
