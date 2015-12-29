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
	$(GSSE_WRENV) $(MAKE) all
endif

all: tools cfe_core cfs_apps hwio_apps csc_apps

install: install_cfe_core install_cfs_apps install_hwio_apps install_csc_apps

clean: clean_tools clean_cfe_core clean_cfs_apps clean_hwio_apps clean_csc_apps
	rm -f exe/*.o exe/*.so exe/*.bin exe/*.tbl exe/ptbl/*.tbl

cfe_core:
	$(MAKE) -C cfe

tools:
	$(MAKE) -C elf2cfetbl

cfs_apps: tools
	$(MAKE) -C sch
	$(MAKE) -C sch -f schtables.mak
	$(MAKE) -C sc
	$(MAKE) -C hs
	$(MAKE) -C hs -f hstables.mak
	$(MAKE) -C lc
	$(MAKE) -C lc -f lctables.mak

hwio_apps: tools
	$(MAKE) -C thrio
	$(MAKE) -C thrsim
	#$(MAKE) -C memsio
	$(MAKE) -C imuio
	#$(MAKE) -C memssim
	$(MAKE) -C imusim
	$(MAKE) -C adio
	$(MAKE) -C adsim
	$(MAKE) -C egcio
	$(MAKE) -C egcsim
	$(MAKE) -C gpsio
	$(MAKE) -C gpssim
	$(MAKE) -C simci
	$(MAKE) -C simto
	$(MAKE) -C simto -f simto_tables.mak

csc_apps: tools
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
	$(MAKE) -C csc_egc
	#$(MAKE) -C csc_egc -f csc_egc_tables.mak
	$(MAKE) -C csc_pcs
	#$(MAKE) -C csc_pcs -f csc_pcs_tables.mak
	$(MAKE) -C csc_tcs
	#$(MAKE) -C csc_tcs -f csc_tcs_tables.mak
	$(MAKE) -C csc_sim
	#$(MAKE) -C csc_sim -f csc_sim_tables.mak

install_cfe_core: cfe_core
	$(MAKE) -C cfe install

install_cfs_apps: cfs_apps
	$(MAKE) -C sch install
	$(MAKE) -C sch -f schtables.mak install
	$(MAKE) -C sc install
	$(MAKE) -C hs install
	$(MAKE) -C hs -f hstables.mak install
	$(MAKE) -C lc install
	$(MAKE) -C lc -f lctables.mak install

install_hwio_apps: hwio_apps
	$(MAKE) -C thrio install
	$(MAKE) -C thrsim install
	#$(MAKE) -C memsio install
	$(MAKE) -C imuio install
	#$(MAKE) -C memssim install
	$(MAKE) -C imusim install
	$(MAKE) -C adio install
	$(MAKE) -C adsim install
	$(MAKE) -C egcio install
	$(MAKE) -C egcsim install
	$(MAKE) -C gpsio install
	$(MAKE) -C gpssim install
	$(MAKE) -C simci install
	$(MAKE) -C simto install
	$(MAKE) -C simto -f simto_tables.mak install

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
	$(MAKE) -C csc_egc install
	#$(MAKE) -C csc_egc -f csc_egc_tables.mak install
	$(MAKE) -C csc_pcs install
	#$(MAKE) -C csc_pcs -f csc_pcs_tables.mak install
	$(MAKE) -C csc_tcs install
	#$(MAKE) -C csc_tcs -f csc_tcs_tables.mak install
	$(MAKE) -C csc_sim install
	#$(MAKE) -C csc_sim -f csc_sim_tables.mak install

clean_cfe_core:
	$(MAKE) -C cfe clean

clean_tools:
	$(MAKE) -C elf2cfetbl clean

clean_cfs_apps:
	$(MAKE) -C sch clean
	$(MAKE) -C sc clean
	$(MAKE) -C hs clean
	$(MAKE) -C lc clean

clean_hwio_apps:
	$(MAKE) -C thrio clean
	$(MAKE) -C thrsim clean
	#$(MAKE) -C memsio clean
	$(MAKE) -C imuio clean
	#$(MAKE) -C memssim clean
	$(MAKE) -C imusim clean
	$(MAKE) -C adio clean
	$(MAKE) -C adsim clean
	$(MAKE) -C egcio clean
	$(MAKE) -C egcsim clean
	$(MAKE) -C gpsio clean
	$(MAKE) -C gpssim clean
	$(MAKE) -C simci clean
	$(MAKE) -C simto clean

clean_csc_apps:
	$(MAKE) -C csc_cmp clean
	$(MAKE) -C csc_est clean
	$(MAKE) -C csc_gdn clean
	$(MAKE) -C csc_cnt clean
	$(MAKE) -C csc_act clean
	$(MAKE) -C csc_egc clean
	$(MAKE) -C csc_pcs clean
	$(MAKE) -C csc_tcs clean
	$(MAKE) -C csc_sim clean
