###############################################################################
# File: link-rules.mak
#
# Purpose:
#   Makefile for linking code and producing the cFE Core executable image.
#
# History:
#
###############################################################################
##
## Executable target. This is target specific
##
EXE_TARGET=cfe-core.o
CORE_INSTALL_FILES = $(EXE_TARGET)


##
## Linker flags that are needed
##
LDFLAGS =
MUNCHED_LDFLAGS = -r -nostdlib -Wl,-X -T$(WIND_BASE)/target/h/tool/gnu/ldscripts/link.OUT

##
## Libraries to link in
##
LIBS =

##
## cFE Core Link Rule
##
$(EXE_TARGET): $(CORE_OBJS)
	$(COMPILER) -nostdlib -r -o $(EXE_TARGET) $(CORE_OBJS)

##
## Application Link Rule
##
$(APPTARGET).$(APP_EXT): $(OBJS)
ifeq ($(APP_HAS_CPP), TRUE)
	$(LINKER) -r $(OBJS) -o $(APPTARGET).premunch.o
	$(NM) $(APPTARGET).premunch.o | $(MUNCH) > ctdt.c
	$(COMPILER) $(COPTS) -fdollars-in-identifiers -c ctdt.c
	$(COMPILER) $(MUNCHED_LDFLAGS) -o $@ $(APPTARGET).premunch.o ctdt.o
else
	$(LINKER) -r $(OBJS) -o $@
endif


