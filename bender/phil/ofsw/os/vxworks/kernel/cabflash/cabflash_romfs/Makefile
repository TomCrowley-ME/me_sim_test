# Wind River Workbench generated Makefile.
# Do not edit!!!

TRACE=0
TRACEON=$(TRACE:0=@)
TRACE_FLAG=$(TRACEON:1=)

all : subdirs_all main_all
	@echo "make: built file system contents"

main_all : _clean
	$(TRACE_FLAG)echo "building file system contents";\
	mkdir -p Contents
	$(TRACE_FLAG)cp -f "/opt/WindRiver/vxworks-6.7/target/config/moonex_cab/bootrom.bin" "Contents/bootrom.bin"
	$(TRACE_FLAG)cp -f "/opt/WindRiver/vxworks-6.7/target/config/moonex_cab/bootrom_stage1.desc" "Contents/bootrom_stage1.desc"
	$(TRACE_FLAG)mkromfs -o content.romfs Contents

clean : subdirs_clean _clean

_clean :
	$(TRACE_FLAG)echo "make: removing file system contents" ;\
	rm -rf content.romfs Contents

subdirs_all :

subdirs_clean :
