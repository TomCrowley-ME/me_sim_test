HG_ROOT = $(shell hg root)

# These variables get passed down to all sub-make files.
export CFE_CORE_SRC     = $(HG_ROOT)/phil/ofsw/cfe/fsw/cfe-core/src
export OSAL_SRC         = $(HG_ROOT)/phil/ofsw/osal/src/os
export CFS_MISSION_INC  = $(HG_ROOT)/phil/ofsw/cfe/fsw/mission_inc
export CFS_PLATFORM_INC = $(HG_ROOT)/phil/ofsw/cfe/fsw/platform_inc
export CFE_PSP_SRC      = $(HG_ROOT)/phil/ofsw/cfe/psp/fsw
export CFS_APP_SRC      = $(HG_ROOT)/phil/ofsw/cfs
export OS_SRC           = $(HG_ROOT)/phil/ofsw/os
export SL_MODEL_PATH    = $(HG_ROOT)/phil/wsim
export OFSW_SRC         = $(HG_ROOT)/phil/ofsw/src
export GSSE_SRC         = $(HG_ROOT)/phil/gsse/src

export OFSW_WRENV       = /opt/WindRiver/wrenv.sh -p vxworks-6.7
export GSSE_WRENV       = /opt/WindRiver/wrenv.sh -p vxworks-6.9
