###############################################################################
# File: Makefile
#
# Purpose:
#   Main makefile for all of bender FSW
#
###############################################################################

all: wsim ofsw gsse

wsim: matlab_check
	make -C wsim

ofsw: matlab_check
	make -C ofsw/src

gsse: matlab_check
	make -C gsse/src

install:
	make -C ofsw/src install
	make -C gsse/src install

clean:
	make -C wsim clean
	make -C ofsw/src clean
	make -C gsse/src clean

matlab_check:
ifeq ($(MATLAB_PATH),)
	$(error No MATLAB_PATH defined!)
endif
