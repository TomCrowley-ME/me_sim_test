# Makefile - makefile for target/src/usr
#
# Copyright (c) 1996, 1998-2001, 2003-2008 Wind River Systems, Inc.
#
# The right to copy, distribute, modify or otherwise make use of this software
# may be licensed only pursuant to the terms of an applicable Wind River license
# agreement.
#
# modification history
# --------------------
# 02g,05jul08,jpb  Added flag to make line.
# 02f,19jul07,v_r  Added shell history save/load routines (req
#                  CQ:WIND00005098).
# 02e,05apr07,tkf  Use COMP_IPNET2 instead of dir name with hard-coded version
#                  number (WIND00092254).
# 02d,24apr07,tkf  Provide relative IPCOM path instead of hard-coded one. Also
#                  remove obsolete coreip pathes.
# 02c,30mar07,mmg  update for parallel make operation
# 02b,21mar07,pee  added support for LIB_ROOT
# 02a,08jul06,dlk  Added ipcom directory.
# 01z,26may06,tfo  Added tool path to statTbl.c to avoid conflicts on multiple
#                  builds
# 01y,13jan06,jeg  added missing directories to parse when running
#		   makeStatTbl script.
# 01x,10oct05,act  SPR#111792: documentation needs updating
# 01w,03mar05,lei  Removed netun from STATCODEDIRS.
# 01v,01oct04,jeg  Fixed build failing if VxWorksErrnoTbl.tcl is removed
# 01u,28sep04,jeg  Added rules to generate Tcl host shell errno table file
#                  automatically. Used makeStatTbl.sh script on windows
#                  instead of makeStatTbl.exe.
# 01t,24sep04,rfr  Added usrTransLib.o
# 01s,23sep04,bpn  Moved usrFsShellCmd.c under ostool/shell.
# 01r,11aug04,job  Added usrRtpStartup.c
# 01q,01jul04,dlk  Added $(TGT_DIR)/h/wrn/coreip to STATCODEDIRS.
# 01p,26mar04,dat  move memDrv,ramDrv to src/os/io
# 01o,26feb04,yvp  Added usrRtpStartup.o to OBJS.
# 01n,04feb04,pch  remove PPC32 hack, no longer needed
# 01m,24nov03,jn   Add usrRtpLib to build
# 01l,07nov03,c_c  Unified build rules with WIN32 hosts.
# 01k,22sep03,bpn  Added build of usrFsShellCmd.o.
# 01j,31jan03,pch  Add PPC32 support
# 01i,08dec01,jkf  fixing statTbl.c dependencies, per yogu's T3 work and
#		   SPR#8389.  adding memDrv.c and ramDrv.c into DOCS.
# 01h,06dec01,jkf  SPR#70580, makeStatTbl support readded for Windows host
# 01g,12oct01,tam  added repackaging support
# 01f,24sep01,jkf  moving tarLib.c into src/usr directory, removed
#		   DOC_DIR changes.
# 01e,28jul00,rec  changes to support multiple architectures for ARM
#		   added $(LIBDIR)/*.o to LOCAL_CLEAN
# 01e,21jun00,rsh  upgrade to dosFs 2.0
# 01g,26oct99,jkf  added DOC_OPTS = $(DOC_OPTS_MAN) -category DOSFS2
# 01f,08oct99,jkf  more doc kludges for T2 component, remove for T3
# 01e,08oct99,jkf  added a kludge to get these into the T2 component
#		   documentation directory "dosfs2".  This change should be
#		   be removed for T3, since dosfs2 will no longer be a
#		   component release.
# 01d,14oct98,lrn  added devSplit to OBJS, merged from ms.
# 01c,06jul98,lrn  added new dosFs files, separated I/O utils from usrLib.c
# 01b,02dec96,yp   made build of statTbl.o more reliable. We find makeStatTbl
#		   from search path now
# 01a,17aug96,yp   derived from 01e of MakeSkel
#
# DESCRIPTION
# This file contains the makefile rules for building the vx library
#
#*/

TGT_DIR=$(WIND_BASE)/target

LIB_BASE_NAME   = os

DOC_FILES= usrLib.c usrFsLib.c usrFdiskPartLib.c ramDiskCbio.c \
           tarLib.c usrRtpLib.c usrRtpStartup.c usrTransLib.c \
	   usrShellHistLib.c

# the files that contain status codes are listed here. To prevent
# the need to update this list every time a new file with status
# codes is added we wildcard all .h files from the directories
# specifed. The specified directory is expected to have a file
# that lists module numbers.

# XXX It would be better to either generate this list of
# directories automatically, or to require that errno codes always
# be defined in some small number of directories - perhaps target/h/errno?

STATCODEDIRS= $(TGT_DIR)/h $(TGT_DIR)/h/arch/arm $(TGT_DIR)/h/arch/coldfire   \
	$(TGT_DIR)/h/arch/i86 $(TGT_DIR)/h/arch/mc68k $(TGT_DIR)/h/arch/mips  \
	$(TGT_DIR)/h/arch/ppc $(TGT_DIR)/h/arch/sh $(TGT_DIR)/h/arch/simlinux \
	$(TGT_DIR)/h/arch/simnt $(TGT_DIR)/h/arch/simsolaris                  \
	$(TGT_DIR)/h/arch/sparc $(TGT_DIR)/h/drv/pcmcia $(TGT_DIR)/h/private  \
	$(TGT_DIR)/h/vxfusion $(TGT_DIR)/h/wdb $(TGT_DIR)/h/dsi               \
	$(TGT_DIR)/h/dsi/un                                                   \
	$(TGT_DIR)/h/wrn/coreip/net              \
	$(TGT_DIR)/h/usb $(TGT_DIR)/h/wrn/coreip $(TGT_DIR)/h/drv/erf 	      \
	$(TGT_DIR)/h/drv/usb \
	$(WIND_HOME)/components/$(COMP_IPNET2)/ipcom/port/vxworks/include

STATFILES= $(wildcard $(foreach dir, $(STATCODEDIRS), $(dir)/*.h))

BUILD_ALL_OBJS = TRUE

OBJS=statTbl.o devSplit.o usrDosFsOld.o usrFsLib.o usrFdiskPartLib.o \
     ramDiskCbio.o tarLib.o usrRtpLib.o usrRtpStartup.o usrLib.o \
     usrTransLib.o usrShellHistLib.o

VXWORKS_ERR_DB	= $(WIND_BASE)/host/resource/tcl/VxWorksErrnoTbl.tcl
ERR_DB_SCRIPT	= $(WIND_BASE)/host/resource/hutils/tcl/makeErrnoTbl.tcl

NODEPENDOBJS=$(LIBDIR)/statTbl.c $(LIBDIR)/statTbl.s $(LIBDIR)/statTbl.cpp

# FIXME remove statTbl.c statTbl.s statTbl.cpp statTbl.o in the future
LOCAL_CLEAN=$(NODEPENDOBJS) statTbl.c statTbl.s statTbl.cpp statTbl.o \
	$(LIBDIR)/statTbl.o $(LIBDIR)/statTbl.d

BUILD_ALL_OBJS=TRUE

include $(TGT_DIR)/h/make/rules.library

# To prevent build of statTbl, must keep make from seeing its dependencies
ifneq ($(NODEPENDOBJS),)

.INTERMEDIATE : statTbl.c

$(LIB_ROOT)/$(LIBNAME): statTbl.o

statTbl.o: statTbl.c $(VXWORKS_ERR_DB)

statTbl.c: $(LIBDIR) $(STATFILES) $(ERR_DB_SCRIPT)
	@ $(RM) $@
ifneq ($(WIND_HOST_TYPE),x86-win32)
	makeStatTbl $(STATCODEDIRS) > $@
else
	$(MAKESHELL) $(WIND_BASE)/host/$(WIND_HOST_TYPE)/bin/makeStatTbl \
		$(STATCODEDIRS) > $@
endif

# Note: -D_WRS_IGNORE_VSB is a temporary workaround to avoid needing
# to have the default VSB created before scgen can be run.

$(VXWORKS_ERR_DB): statTbl.c
	$(CPP) $(CFLAGS) -D_WRS_IGNORE_VSB statTbl.c > $(LIBDIR)/statTbl.cpp
	$(CC) $(CFLAGS) -D_WRS_IGNORE_VSB -S statTbl.c -o $(LIBDIR)/statTbl.s
	$(TCL) $(ERR_DB_SCRIPT) $(LIBDIR)/statTbl.cpp $(LIBDIR)/statTbl.s $(TOOL) $(WIND_BASE)
	$(RM) $(LIBDIR)/statTbl.cpp $(LIBDIR)/statTbl.s

endif
