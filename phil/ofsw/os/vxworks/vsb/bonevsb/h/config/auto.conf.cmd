deps_config := \
	/home/mstewart/bender/phil/ofsw/os/vxworks/vsb/bonevsb/vsb.vxconfig

include/config/auto.conf: \
	$(deps_config)

$(deps_config): ;
