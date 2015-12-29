/* pipeDrv.h - header file for pipeDrv.c */

/* Copyright 1984-2003 Wind River Systems, Inc. */

/*
modification history
--------------------
01g,03nov03,dat  adding const to char arguments, remove old decl's
01f,05oct01,dcb  Fix SPR 9434.  Add pipeDevDelete() call.  Code merged back
                 from the AE tree (created for AE under SPR 26204).
01e,22sep92,rrr  added support for c++
01d,04jul92,jcf  cleaned up.
01c,26may92,rrr  the tree shuffle
01b,04oct91,rrr  passed through the ansification filter
		  -fixed #else and #endif
		  -changed copyright notice
01a,05oct90,shl created.
*/

#ifndef __INCpipeDrvh
#define __INCpipeDrvh

#ifdef __cplusplus
extern "C" {
#endif

/* defines */

/* default maximum number of open fds for each pipe device */

#define PIPE_DEF_MAX_FDS        16

/* function declarations */

extern STATUS 	pipeDevCreate (const char *name, size_t nMessages, size_t nBytes);
extern STATUS   pipeDevDelete (const char *name, BOOL force);
extern STATUS 	pipeDrv (void);

#ifdef __cplusplus
}
#endif

#endif /* __INCpipeDrvh */
