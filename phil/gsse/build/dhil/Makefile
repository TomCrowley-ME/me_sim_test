###############################################################################
# File: Makefile
#
# Purpose:
#   Main GSSE makefile for cFE core build and all apps
#
###############################################################################

include ../../../make/buildvars.mak

ifeq ($(strip $(WIND_HOME)),)
wrenv:
	$(GSSE_WRENV) $(MAKE) all
endif

all: cfe_core cfs_apps hwsim_apps csc_apps

install: install_cfe_core install_cfs_apps install_hwsim_apps install_csc_apps

clean: clean_cfe_core clean_cfs_apps clean_hwsim_apps clean_csc_apps
	rm -f exe/*.o exe/*.so exe/*.bin exe/*.tbl exe/ptbl/*.tbl

cfe_core:
	$(MAKE) -C cfe

cfs_apps:
	$(MAKE) -C sch
	$(MAKE) -C sch -f sch_tables.mak
	$(MAKE) -C simci
	$(MAKE) -C simto
	$(MAKE) -C simto -f simto_tables.mak

hwsim_apps:
	$(MAKE) -C thrsim
	$(MAKE) -C stsim

csc_apps:
	$(MAKE) -C csc_sim
	#$(MAKE) -C csc_sim -f csc_sim_tables.mak

install_cfe_core: cfe_core
	$(MAKE) -C cfe install

install_cfs_apps: cfs_apps
	$(MAKE) -C sch install
	$(MAKE) -C sch -f sch_tables.mak install
	$(MAKE) -C simci install
	$(MAKE) -C simto install
	$(MAKE) -C simto -f simto_tables.mak install

install_hwsim_apps: hwsim_apps
	$(MAKE) -C thrsim install
	$(MAKE) -C stsim install

install_csc_apps: csc_apps
	$(MAKE) -C csc_sim install
	#$(MAKE) -C csc_sim -f csc_sim_tables.mak install

clean_cfe_core:
	$(MAKE) -C cfe clean

clean_cfs_apps:
	$(MAKE) -C sch clean
	$(MAKE) -C simci clean
	$(MAKE) -C simto clean

clean_hwsim_apps:
	$(MAKE) -C thrsim clean
	$(MAKE) -C stsim clean

clean_csc_apps:
	$(MAKE) -C csc_sim clean
