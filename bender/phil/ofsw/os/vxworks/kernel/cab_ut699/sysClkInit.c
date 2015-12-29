/* sysClkInit.c - initialize the system clock */

/* Copyright 1984-1998 Wind River Systems, Inc. */

/*
modification history
--------------------
01a,21apr98,ms   take from usrConfig.c
*/

/*
DESCRIPTION
Initialize the system clock
*/

/******************************************************************************
*
* usrClock - user-defined system clock interrupt routine.
*/
UINT32 sysClkIntTicks = 0;
UINT32 sysIdleTicks = 0;
UINT32 sys1HzTickCounter = 0;
VOIDFUNCPTR _func_sysClk1HzCallback = NULL;


void usrClock (void)
    {
    tickAnnounce();

    /* Increment CPU utilization counters for HS */
    if (kernelIsIdle) {
    	/* We interrupted the idle state */
    	sysIdleTicks++;
    }
    sysClkIntTicks++;

    /* Call user-supplied local 1Hz callback function */
    sys1HzTickCounter++;
    if (sys1HzTickCounter == SYS_CLK_RATE) {
    	sys1HzTickCounter = 0;
    	if (_func_sysClk1HzCallback != NULL) {
    		(*_func_sysClk1HzCallback)();
    	}
    }

    }

/******************************************************************************
*
* sysClk1HzCallbackAttach - attaches 1Hz callback routine to sysclk
*/

void sysClk1HzCallbackAttach (VOIDFUNCPTR callback)
    {
	_func_sysClk1HzCallback = callback;
    }



/******************************************************************************
*
* sysClkInit - initialize the system clock
*/

void sysClkInit (void)
    {
    /* set up the system timer */

    sysClkConnect ((FUNCPTR) usrClock, 0);      /* connect clock ISR */
    sysClkRateSet (SYS_CLK_RATE);               /* set system clock rate */
    sysClkEnable ();                            /* start it */
    }

