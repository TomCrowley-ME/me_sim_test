/* vsbConfig.h - VSB Configuration header */

/*
 * Copyright (c) 2008 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify or otherwise make use
 * of this software may be licensed only pursuant to the terms
 * of an applicable Wind River license agreement.
 */

/*
modification history
--------------------
01c,16sep08,jpb  Defect 133519.  Added check for _VSB_CONFIG_FILE.
01b,04sep08,jpb  Added ignore macro.
01a,15aug08,kk  created base on private/vsbConfigP.h
*/

/*
 * This file is used by any source code which utilizes VSB configuration
 * macros such as _WRS_CONFIG_SMP.
 */

#ifndef __INCvsbConfig_h
#define __INCvsbConfig_h

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/*
 * If the macro _VSB_CONFIG_FILE is not defined (in a case such as where a user
 * application is built not using WorkBench), issue a warning and include
 * the default UP vsbConfig.h header file.  If it is defined, use the file
 * set to _VSB_CONFIG_FILE.
 */

#ifndef _VSB_CONFIG_FILE

#include <../lib/h/config/vsbConfig.h>

/*
#warning "VxWorks Source Build (VSB) project not specified; using default VxWorks UP configuration under $WIND_BASE/target/lib/h/config"
*/

#else
#include _VSB_CONFIG_FILE
#endif /* ! _VSB_CONFIG_FILE */

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /*__INCvsbConfig_h */

