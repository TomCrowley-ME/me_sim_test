/* Boot loader configuration
 *
 *  --------------------------------------------------------------------------
 *  --  This file is a part of GAISLER RESEARCH source code.
 *  --  Copyright (C) 2008, Gaisler Research AB - all rights reserved.
 *  --
 *  -- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
 *  -- ACCORDANCE WITH THE GAISLER LICENSE AGREEMENT AND MUST BE APPROVED
 *  -- IN ADVANCE IN WRITING.
 *  --
 *  -- BY DEFAULT, DISTRIBUTION OR DISCLOSURE IS NOT PERMITTED.
 *  --------------------------------------------------------------------------
 *
 * author: Daniel Hellstr�m, Gaisler Research
 */

Folder	FOLDER_BOOTCFG {
	NAME		LEON ROM boot setup
	SYNOPSIS	LEON Boot configuration, only used when starting from ROM. \
			Note that you must rebuild project for settings to take effect.
	CHILDREN 	INCLUDE_BOOTCFG_GRCG SAVE_NVRAM_REGION
	_CHILDREN	FOLDER_BSP_CONFIG
}

/******* libmkprom selection *******/


Component INCLUDE_BOOTCFG_CODE {
	NAME		Use initRom.S code
}

Component INCLUDE_BOOTCFG_LIBMKPROM {
	NAME		MKPROM3 directory
	CFG_PARAMS	BOOTCFG_LIBMKPROM_MKPROM_DIR
	CHILDREN        FOLDER_MKPROM
}

Parameter BOOTCFG_LIBMKPROM_MKPROM_DIR {
	NAME		Libmkprom dir
	SYNOPSIS	Path to the MKPROM3 installation directory or the directory where libmkprom resides.
	TYPE		string
	DEFAULT		"${WIND_BASE}/target/src/arch/sparc/"
}

Selection        SELECT_MKPROM_CODE    {
        NAME         Type of mkprom to use
        SYNOPSIS     Select INCLUDE_BOOTCFG_LIBMKPROM_FIXED to use a fixed configuration.
        COUNT        1-1
	REQUIRES     INCLUDE_BOOTCFG_LIBMKPROM
        CHILDREN     INCLUDE_BOOTCFG_LIBMKPROM_FIXED \
                     INCLUDE_BOOTCFG_LIBMKPROM_AUTO
        DEFAULTS     INCLUDE_BOOTCFG_LIBMKPROM_AUTO
	_CHILDREN    FOLDER_MKPROM
} 

Component INCLUDE_BOOTCFG_LIBMKPROM_FIXED {
	NAME		MKPROM3 directory
	CFG_PARAMS	BOOTCFG_LIBMKPROM_MKPROM_CONFIG
	REQUIRES     INCLUDE_BOOTCFG_LIBMKPROM
}

Parameter BOOTCFG_LIBMKPROM_MKPROM_CONFIG {
	NAME		mkprom_config.h dir
	SYNOPSIS	Directory where the mkprom_config.h file is located.
	TYPE		string
	DEFAULT		"/opt/mkprom3/board-configs/tsim-generic/"
	REQUIRES        INCLUDE_BOOTCFG_LIBMKPROM_FIXED
}

Component INCLUDE_BOOTCFG_LIBMKPROM_AUTO {
	NAME		MKPROM3 directory
	REQUIRES     INCLUDE_BOOTCFG_LIBMKPROM
}

Selection        SELECT_BOOTCFG_CODE    {
        NAME         Initcode to use
        SYNOPSIS     Select INCLUDE_BOOTCFG_CODE to use code from \
		     romInit.S, select INCLUDE_BOOTCFG_LIBMKPROM to use mkprom3's libmkprom code. \
		     DIAB requires INCLUDE_BOOTCFG_CODE.
        COUNT        1-1
        CHILDREN     INCLUDE_BOOTCFG_LIBMKPROM \
                     INCLUDE_BOOTCFG_CODE
        DEFAULTS     INCLUDE_BOOTCFG_CODE
	_CHILDREN	FOLDER_BOOTCFG
} 

Folder	FOLDER_MKPROM {
	NAME		mkprom setup
	SYNOPSIS	mkprom setup. 
	SELECT_BOOTCFG_CODE 
	_CHILDREN	FOLDER_BOOTCFG
}

/********* INCLUDE_BOOTCFG_CODE *******/


Folder	FOLDER_BOOTCFG_LEON3 {
	NAME		LEON3 specific setup
	SYNOPSIS	LEON3 Boot configuration, only used when starting from ROM.
	_CHILDREN	FOLDER_BOOTCFG
}


/******* COMMON PARAMETERS *******/

Component INCLUDE_BOOTCFG_SYSTEM {
	NAME		System Parameters
	SYNOPSIS	System Parameters
	CFG_PARAMS	BOOTCFG_FREQ_KHZ
	_CHILDREN	FOLDER_BOOTCFG
}
Parameter BOOTCFG_FREQ_KHZ {
	NAME		System Frequency
	SYNOPSIS	System/CPU Frequency [kHz]
	DEFAULT		40000
	TYPE		uint
}

Component INCLUDE_BOOTCFG_UART {
	NAME		UART Parameters
	SYNOPSIS	UART Parameters
	CFG_PARAMS	BOOTCFG_UART_BAUDRATE BOOTCFG_UART_FLOWCTRL BOOTCFG_UART_DEBUG
	_CHILDREN	FOLDER_BOOTCFG
}

Parameter BOOTCFG_UART_BAUDRATE {
	NAME		UART Baudrate
	SYNOPSIS	UART baudrate [bits/s]
	DEFAULT		38400
	TYPE		uint
}

Parameter BOOTCFG_UART_FLOWCTRL {
	NAME		UART Flowcontrol
	SYNOPSIS	Enable Flowcontrol [1], Disable [0]
	TYPE		BOOL
	DEFAULT		FALSE
}

Parameter BOOTCFG_UART_DEBUG {
	NAME		UART Debug
	SYNOPSIS	Enable Inherit Debug Enable UART it [1], Disable [0]. \
			This option can not be used after power-up on an ASIC, \
			since the debug bit is not reset. Enable this to make \
			the UART data tunnelled over the debug link after \
			reboot or on boot.
	TYPE		BOOL
	DEFAULT		FALSE
}

Component INCLUDE_BOOTCFG_LEONFT {
	NAME		LEON-FT CPU options
	SYNOPSIS	ROM Fault Tolerant options
	CFG_PARAMS	BOOTCFG_LEONFT_WASH_MEM
	_CHILDREN	FOLDER_BOOTCFG
}

Parameter BOOTCFG_LEONFT_WASH_MEM {
	NAME		Wash Memory
	SYNOPSIS	Enable/Disable Washing of all main memory.
	TYPE		BOOL
	DEFAULT		FALSE
}

/******* GRLIB PARAMETERS *******/

/* GRLIB GRCLKGATE - Clock gating unit */
Component INCLUDE_BOOTCFG_GRCG {
	NAME		Clock gating unit
	SYNOPSIS	Clock gating unit (GRCLKGATE)
	CFG_PARAMS	BOOTCFG_GRCG_ENABLED
}

Parameter BOOTCFG_GRCG_ENABLED {
	NAME		Core clocks enabled
	SYNOPSIS	Bitmask specifying which clock-gated cores to enable at boot 
	DEFAULT		0x7F
	TYPE		uint
}

Component SAVE_NVRAM_REGION {
	NAME		Save NVRAM region on flash
	SYNOPSIS	Use the last memory block on flash to store NVRAM settings
}

/* FTMCTRL */
Component INCLUDE_BOOTCFG_FTMCTRL {
	NAME		FT-Memory Controller
	SYNOPSIS	FT-Memory controller (FTMCTRL)
	CFG_PARAMS	BOOTCFG_FTMCTRL_MCFG1 BOOTCFG_FTMCTRL_MCFG2 BOOTCFG_FTMCTRL_MCFG3
/* \
			BOOTCFG_FTMCTRL_EDAC_RAM BOOTCFG_FTMCTRL_EDAC_PROM */
	_CHILDREN	FOLDER_BOOTCFG_LEON3
	REQUIRES	INCLUDE_BOOTCFG_CODE
}
/* GRLIB FTMCTRL Memcfg1 */
Parameter BOOTCFG_FTMCTRL_MCFG1 {
	NAME		GRLIB FTMCFG1
	SYNOPSIS	FT Memory Configuration Register 1 - PROM set up
	DEFAULT		0x10f880ff
	TYPE		uint
}
/* GRLIB FTMCTRL Memcfg2 */
Parameter BOOTCFG_FTMCTRL_MCFG2 {
	NAME		GRLIB FTMCFG2
	SYNOPSIS	FT Memory Configuration Register 2 - SRAM/SDRAM set up
	DEFAULT		0x82205260
	TYPE		uint
}
/* GRLIB FTMCTRL Memcfg3 */
Parameter BOOTCFG_FTMCTRL_MCFG3 {
	NAME		GRLIB FTMCFG3
	SYNOPSIS	FT Memory Configuration Register 3 - EDAC set up
	DEFAULT		0x0809a000
	TYPE		uint
}


/* UNIMPLEMENTED */
Parameter BOOTCFG_FTMCTRL_EDAC_RAM {
	NAME		EDAC RAM
	SYNOPSIS	Enable/Disable EDAC for RAM
	TYPE		BOOL
	DEFAULT		FALSE
}
Parameter BOOTCFG_FTMCTRL_EDAC_PROM {
	NAME		EDAC PROM
	SYNOPSIS	Enable/Disable EDAC for PROM.
	TYPE		BOOL
	DEFAULT		FALSE
}

/******* LEON3 PARAMETERS *******/

/* DSU3 */
Component INCLUDE_BOOTCFG_DSU3 {
	NAME		DSU on startup
	SYNOPSIS	Enable the Debug Support Unit (DSU3) instruction and AHB trace \
			facility on startup (ONLY FOR DEBUGGING).
	CFG_PARAMS	BOOTCFG_DSU3_ADDRESS
	_CHILDREN	FOLDER_BOOTCFG_LEON3
}
Parameter BOOTCFG_DSU3_ADDRESS {
	NAME		LEON3 DSU3 Address
	SYNOPSIS	Debug Support unit (DSU3) Base address
	DEFAULT		0x90000000
	TYPE		uint
}



