###############################################################################
# File: Makefile
#
# Purpose:
#   Main makefile for WSIM code generation
#
###############################################################################

MATLAB_ARGS=
comma:=,

ifneq ($(strip $(TARGETS)),)
    MATLAB_ARGS = '$(subst $(comma),'$(comma)',$(TARGETS))'
endif

all: gen_code
mtv: gen_mtv_code

gen_code:
	@echo "Generating Nimbus code..."
	matlab -nojvm -nosplash -nodesktop -logfile gen_csc_code.log -r "nimbus_gen_code($(MATLAB_ARGS))"
	@stty echo
	@make move_csc_dirs

gen_mtv_code:
	@echo "Generating MTV-1 code..."
	matlab -nojvm -nosplash -nodesktop -logfile gen_csc_code.log -r "cd mtv; mtv_gen_code($(MATLAB_ARGS)); cd .."
	@stty echo
	@make move_csc_dirs

move_csc_dirs:
	@for dir in `find . -iname "*_ert_rtw"`; do \
	    mv $${dir} `sed 's/_ert_rtw//' <<< $${dir}`; \
	done

clean: clean_csc_dirs clean_matlab_files
	@rm -f mtv/inc/*.h
	@rm -f inc/*.h
	@rm -f *.log

clean_csc_dirs:
	@for dir in `find . -iname "csc_sl_interface.h"`; do \
	    rm -rf `rev <<< $${dir} | cut -f2- -d'/' | rev`; \
	done

clean_matlab_files:
	@find . -iname 'slprj' -print0 | xargs -0 rm -rf
	@rm -f *.mex*
	@rm -f mtv/*.mex*
