###############################################################################
# File: Makefile
#
# Purpose:
#   Main OFSW makefile for cFE core build and all apps
#
###############################################################################

include ../../../make/buildvars.mak

ifeq ($(strip $(WIND_HOME)),)
wrenv:
	$(OFSW_WRENV) $(MAKE) all
endif

all: cfe_core cfs_apps hwio_apps csc_apps

install: install_cfe_core install_cfs_apps install_hwio_apps install_csc_apps

clean: clean_cfe_core clean_cfs_apps clean_hwio_apps clean_csc_apps
	rm -f exe/*.o exe/*.so exe/*.bin exe/*.tbl exe/ptbl/*.tbl

cfe_core:
	$(MAKE) -C cfe

cfs_apps:
#	$(MAKE) -C ci
	$(MAKE) -C ci -f ci_udp.mak
	$(MAKE) -C to
	$(MAKE) -C to -f totables.mak
#	$(MAKE) -C to -f to_udp.mak
	$(MAKE) -C sch
	$(MAKE) -C sch -f schtables.mak
	$(MAKE) -C hk
	$(MAKE) -C hk -f hktables.mak
	$(MAKE) -C hs
	$(MAKE) -C hs -f hstables.mak
	$(MAKE) -C sc
	$(MAKE) -C ds
	$(MAKE) -C fsw_lib

hwio_apps:
	$(MAKE) -C stio
	$(MAKE) -C thrio

csc_apps:
	$(MAKE) -C csc_cmp
	#$(MAKE) -C csc_cmp -f csc_cmp_tables.mak
	$(MAKE) -C csc_est
	#$(MAKE) -C csc_est -f csc_est_tables.mak
	$(MAKE) -C csc_gdn
	#$(MAKE) -C csc_gdn -f csc_gdn_tables.mak
	$(MAKE) -C csc_cnt
	#$(MAKE) -C csc_cnt -f csc_cnt_tables.mak
	$(MAKE) -C csc_act
	#$(MAKE) -C csc_act -f csc_act_tables.mak

install_cfe_core: cfe_core
	$(MAKE) -C cfe install

install_cfs_apps: cfs_apps
#	$(MAKE) -C ci
	$(MAKE) -C ci -f ci_udp.mak install
	$(MAKE) -C to install
	$(MAKE) -C to -f totables.mak install
#	$(MAKE) -C to -f to_udp.mak install
	$(MAKE) -C sch install
	$(MAKE) -C sch -f schtables.mak install
	$(MAKE) -C hk install
	$(MAKE) -C hk -f hktables.mak install
	$(MAKE) -C hs install
	$(MAKE) -C hs -f hstables.mak install
	$(MAKE) -C sc install
	$(MAKE) -C ds install
	$(MAKE) -C fsw_lib install

install_hwio_apps: hwio_apps
	$(MAKE) -C stio install
	$(MAKE) -C thrio install

install_csc_apps:
	$(MAKE) -C csc_cmp install
	#$(MAKE) -C csc_cmp -f csc_cmp_tables.mak install
	$(MAKE) -C csc_est install
	#$(MAKE) -C csc_est -f csc_est_tables.mak install
	$(MAKE) -C csc_gdn install
	#$(MAKE) -C csc_gdn -f csc_gdn_tables.mak install
	$(MAKE) -C csc_cnt install
	#$(MAKE) -C csc_cnt -f csc_cnt_tables.mak install
	$(MAKE) -C csc_act install
	#$(MAKE) -C csc_act -f csc_act_tables.mak install

clean_cfe_core:
	$(MAKE) -C cfe clean

clean_cfs_apps:
#	$(MAKE) -C ci
	$(MAKE) -C ci -f ci_udp.mak clean
	$(MAKE) -C to clean
#	$(MAKE) -C to -f to_udp.mak clean
	$(MAKE) -C sch clean
	$(MAKE) -C hk clean
	$(MAKE) -C hs clean
	$(MAKE) -C sc clean
	$(MAKE) -C ds clean
	$(MAKE) -C fsw_lib clean

clean_hwio_apps:
	$(MAKE) -C stio clean
	$(MAKE) -C thrio clean

clean_csc_apps:
	$(MAKE) -C csc_cmp clean
	$(MAKE) -C csc_est clean
	$(MAKE) -C csc_gdn clean
	$(MAKE) -C csc_cnt clean
	$(MAKE) -C csc_act clean
