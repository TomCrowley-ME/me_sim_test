###############################################################################
# File: cFE Application Makefile
#
#
# History:
#
###############################################################################
#
# Subsystem produced by this makefile.
#
APPTARGET = csc_gdn

#
# Entry Point for task
#
ENTRY_PT = csc_gdn_main

#
# Object files required to build subsystem.
#
OBJS = csl_app.o csc_gdn_guidance.o rtGetInf.o rtGetNaN.o rt_nonfinite.o

CSC_PATH = $(SL_MODEL_PATH)/csc_gdn_guidance
CSC_INCS = -I$(CSC_PATH) -I$(SL_MODEL_PATH)/inc

## This should be added to INCLUDE_PATH (below) if needed
##
## MATLAB Note: Need Def for Matlab Headers, MATLAB_MEX_FILE = Mex file,
##	NRT = Non RT, RT = Real Time Executable
##

MATLAB_INCS = -I$(MATLAB_PATH)/extern/include \
	-I$(MATLAB_PATH)/simulink/include -I$(MATLAB_PATH)/rtw/c/src \
	-I$(MATLAB_PATH)/rtw/c/libsrc/

#
# Defines which tables are needed by this app. Options are -DNEED_STATE_TBL and -DNEED_PARAMETER_TBL
#
TABLE_DEFS = -DNEED_STATE_TBL

#
# Source files required to build subsystem; used to generate dependencies.
# As long as there are no assembly files this can be automated.
#
SOURCES = $(OBJS:.o=.c)

##
## Specify extra C Flags needed to build this subsystem
##
LOCAL_COPTS = $(TABLE_DEFS)

##
## EXEDIR is defined here, just in case it needs to be different for a custom
## build
##
EXEDIR=../exe

##
## Certain OSs and Application Loaders require the following option for
## Shared libraries. Currently only needed for vxWorks 5.5 and RTEMS.
## For each shared library that this app depends on, you need to have an
## entry like the following:
##  -R../tst_lib/tst_lib.elf
##
SHARED_LIB_LINK =

########################################################################
# Should not have to change below this line, except for customized
# Mission and cFE directory structures
########################################################################

#
# Set build type to CFE_APP. This allows us to
# define different compiler flags for the cFE Core and Apps.
#
BUILD_TYPE = CFE_APP

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
## Setup the include path for this subsystem
## The OS specific includes are in the build-rules.make file
##
## If this subsystem needs include files from another app, add the path here.
##
INCLUDE_PATH = \
-I$(OSAL_SRC)/inc \
-I$(CFE_CORE_SRC)/inc \
-I$(CFE_PSP_SRC)/inc \
-I$(CFE_PSP_SRC)/$(PSP)/inc \
-I$(CFS_MISSION_INC) \
-I$(CFS_PLATFORM_INC)/$(PSP) \
-I$(OFSW_SRC)/csl $(CSC_INCS) \
-I../inc $(MATLAB_INCS)

##
## Define the VPATH make variable.
## This can be modified to include source from another directory.
## If there is no corresponding app in the cfe-apps directory, then this can be discarded, or
## if the mission chooses to put the src in another directory such as "src", then that can be
## added here as well.
##
VPATH = $(OFSW_SRC)/csl $(CSC_PATH)

##
## Include the common make rules for building a cFE Application
##
include $(CFE_CORE_SRC)/make/app-rules.mak
