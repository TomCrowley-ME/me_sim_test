/* 00bsp.cdf - vxWorks GUI plugin, a selection of BSP config options
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
 * author: Daniel Hellstr�m
 * 2013/03/20: Konrad Eisele <konrad@gaisler.com> : create stripped down version with only ut699 parts.
 *             Remove unneeded RASTA/Leon2/drivers parts
 */

Bsp moonex_cab {
	NAME		Moon Express Core Avionics Board
	REQUIRES	INCLUDE_KERNEL INCLUDE_EXC_TASK
	CPU		SPARC
	ENDIAN		big
	FP		hard soft
}

/*  GRETH Ethernet Driver Config
 *
 */

Component DRV_GRLIB_GRETH {
	NAME		GRETH Ethernet 10/100/1000 MAC
	SYNOPSIS	Enables Gaisler GRETH END Ethernet Driver
	CONFIGLETTES	$(WIND_BASE)/target/src/hwif/end/grethVxbEnd.c
	CFG_PARAMS	GRETH0_CFG_MAC_ADDR GRETH0_CFG_TXBDNUM GRETH0_CFG_RXBDNUM \
			GRETH0_CFG_EDCL_FD GRETH0_CFG_EDCL_SPEED \
			GRETH1_CFG_MAC_ADDR GRETH1_CFG_TXBDNUM GRETH1_CFG_RXBDNUM \
			GRETH1_CFG_EDCL_FD GRETH1_CFG_EDCL_SPEED \
			GRETH_DEBUG_PHY_LEVEL
	INIT_RTN	grethDrvRegister();
	_INIT_ORDER	hardWareInterFaceBusInit
	REQUIRES	INCLUDE_VXBUS \
			INCLUDE_PLB_BUS \
			INCLUDE_AMBAPP_BUS \
			INCLUDE_MII_BUS \
			INCLUDE_GENERICPHY
}

Parameter GRETH_DEBUG_PHY_LEVEL {
	NAME		GRETH PHY debugging level
	SYNOPSIS	Used when debugging PHY setup. May record all PHY \
			transfers, and printout when link mode changed. \
			This is typically enabled when debugging a new PHY \
			driver. \
			Levels: \
			  0=disabled (default),\
			  1=log PHY transfers, \
			  2=1 & print out PHY detect status, \
			  3=2 & printout PHY transfers
	DEFAULT		0
	TYPE		uint
}

Parameter GRETH0_CFG_MAC_ADDR {
	NAME		Ethernet MAC Hardware Address
	SYNOPSIS	Set this to a unique 6 byte hex string, each byte separated with a colon.
	DEFAULT		"00:00:7a:cc:00:12"
	TYPE		string
}

Parameter GRETH0_CFG_TXBDNUM {
	NAME		Number of TX Descriptors
	SYNOPSIS	Number transmitt descriptors to use on GRETH, each descriptor take 1520bytes of RAM. GRETH supports a maximum of 128 descriptors, minimum is one descriptor.
	DEFAULT		16
	TYPE		uint
}

Parameter GRETH0_CFG_RXBDNUM {
	NAME		Number of RX Descriptors
	SYNOPSIS	Number receive descriptors to use on GRETH, each descriptor take 1520bytes of RAM. GRETH supports a maximum of 128 descriptors, minimum is one descriptor.
	DEFAULT		16
	TYPE		uint
}

Parameter GRETH0_CFG_EDCL_SPEED {
	NAME		Startup EDCL link speed
	SYNOPSIS	EDCL link is unavailable after the GRETH is reset and \
			before the MII-bus layer signals Link Up to GRETH driver. \
			When debugging the startup procedure with the EDCL this \
			option can be used to set the link speed during the \
			time the EDCL is normally unavailable. \
			The Full Duplex option must also be set. \
			0=No extra initialization, 1=Auto Probe(max 10s delay), \
			10=10Mbps, 100=100Mbps, 1000=Gbit mode.
	DEFAULT		1
	TYPE		uint
}

Parameter GRETH0_CFG_EDCL_FD {
	NAME		Startup EDCL link duplex mode
	SYNOPSIS	See the GRETH0_CFG_EDCL_SPEED option.\
			TRUE=Full Duplex, FALSE=Half Duplex mode. \
			Does not have an effect when GRETH0_CFG_EDCL_SPEED is \
			set to 0 or 1.
	DEFAULT		TRUE
	TYPE		bool
}

Parameter GRETH1_CFG_MAC_ADDR {
	NAME		Ethernet MAC Hardware Address
	SYNOPSIS	Set this to a unique 6 byte hex string, each byte separated with a colon.
	DEFAULT		"00:00:7a:cc:00:13"
	TYPE		string
}

Parameter GRETH1_CFG_TXBDNUM {
	NAME		Number of TX Descriptors
	SYNOPSIS	Number transmitt descriptors to use on GRETH, each descriptor take 1520bytes of RAM. GRETH supports a maximum of 128 descriptors, minimum is one descriptor.
	DEFAULT		16
	TYPE		uint
}

Parameter GRETH1_CFG_RXBDNUM {
	NAME		Number of RX Descriptors
	SYNOPSIS	Number receive descriptors to use on GRETH, each descriptor take 1520bytes of RAM. GRETH supports a maximum of 128 descriptors, minimum is one descriptor.
	DEFAULT		16
	TYPE		uint
}

Parameter GRETH1_CFG_EDCL_SPEED {
	NAME		Startup EDCL link speed
	SYNOPSIS	EDCL link is unavailable after the GRETH is reset and \
			before the MII-bus layer signals Link Up to GRETH driver. \
			When debugging the startup procedure with the EDCL this \
			option can be used to set the link speed during the \
			time the EDCL is normally unavailable. \
			The Full Duplex option must also be set. \
			0=No extra initialization, 1=Auto Probe(max 10s delay), \
			10=10Mbps, 100=100Mbps, 1000=Gbit mode.
	DEFAULT		1
	TYPE		uint
}

Parameter GRETH1_CFG_EDCL_FD {
	NAME		Startup EDCL link duplex mode
	SYNOPSIS	See the GRETH1_CFG_EDCL_SPEED option.\
			TRUE=Full Duplex, FALSE=Half Duplex mode. \
			Does not have an effect when GRETH1_CFG_EDCL_SPEED is \
			set to 0 or 1.
	DEFAULT		TRUE
	TYPE		bool
}


/*  PCI Driver Config
 *
 */

Component INCLUDE_PCI {
	NAME		LEON2/3 PCI Support driver
	SYNOPSIS	Enables LEON2/3 PCI Driver.
	CFG_PARAMS	USE_PCI_SHARED_IRQ PCI_INTA_IRQ \
			PCI_INTB_IRQ PCI_INTC_IRQ PCI_INTD_IRQ PCI_BUSFREQ
	_CHILDREN 	FOLDER_BUS
}

Parameter USE_PCI_SHARED_IRQ {
	NAME		Enable PCI IRQ sharing
	SYNOPSIS	Enable PCI IRQ sharing. In systems where multiple PCI IRQs are \
			connected to the same system IRQ. Set PCI_SHARED_IRQ to system IRQ \
			for LEON2 systems, in LEON3 system the shared IRQ is autodetected \
			using Plug & Play Information.
	DEFAULT		FALSE
	TYPE		bool
}

Parameter PCI_INTA_IRQ {
	NAME		PCI INTA System IRQ
	SYNOPSIS	Connect PCI INTA with system IRQ number. (1..15). \
			In LEON3 systems the IRQs are autodetected when the PCI interrupts \
			are shared by a single system interrupt, in such a case this parameter \
			has no effect. However, in LEON3 systems without interrupt sharing \
			GPIO is used to route one or more PCI IRQs, this parameter selects \
			system IRQ and GPIO pin used.
	DEFAULT		8
	TYPE		uint
}

Parameter PCI_INTB_IRQ {
	NAME		PCI INTB System IRQ
	SYNOPSIS	Connect PCI INTB with system IRQ number. (1..15). \
			In LEON3 systems the IRQs are autodetected when the PCI interrupts \
			are shared by a single system interrupt, in such a case this parameter \
			has no effect. However, in LEON3 systems without interrupt sharing \
			GPIO is used to route one or more PCI IRQs, this parameter selects \
			system IRQ and GPIO pin used.
	DEFAULT		9
	TYPE		uint
}

Parameter PCI_INTC_IRQ {
	NAME		PCI INTC System IRQ
	SYNOPSIS	Connect PCI INTC with system IRQ number. (1..15). \
			In LEON3 systems the IRQs are autodetected when the PCI interrupts \
			are shared by a single system interrupt, in such a case this parameter \
			has no effect. However, in LEON3 systems without interrupt sharing \
			GPIO is used to route one or more PCI IRQs, this parameter selects \
			system IRQ and GPIO pin used.
	DEFAULT		10
	TYPE		uint
}

Parameter PCI_INTD_IRQ {
	NAME		PCI INTD System IRQ
	SYNOPSIS	Connect PCI INTD with system IRQ number. (1..15). \
			In LEON3 systems the IRQs are autodetected when the PCI interrupts \
			are shared by a single system interrupt, in such a case this parameter \
			has no effect. However, in LEON3 systems without interrupt sharing \
			GPIO is used to route one or more PCI IRQs, this parameter selects \
			system IRQ and GPIO pin used.
	DEFAULT		11
	TYPE		uint
}

Parameter PCI_BUSFREQ {
	NAME		PCI Bus Frequency [Hz]
	SYNOPSIS	PCI Bus Frequency in Hertz
	DEFAULT		33000000
	TYPE		uint
}

/*************** VxBus COMPONENTS *********************/

/* Folder for GRLIB Drivers */
Folder INCLUDE_GRLIB {
	NAME		GRLIB vxBus Drivers
	SYNOPSIS	GRLIB vxBus Drivers
	_CHILDREN	FOLDER_DRIVERS
	CHILDREN	INCLUDE_GRLIB_AMBAPP_BUSCTRL \
			INCLUDE_GRLIB_GRPCI_PCI \
			DRV_TIMER_GRLIB_GPTIMER \
			DRV_INTCTRL_GRLIB_MPIRQ \
			DRV_GRLIB_OCCAN \
			DRV_GRLIB_GPIOLIB \
			DRV_GRLIB_GRGPIO \
			DRV_GRLIB_GRSPW \
			DRV_GRLIB_GRSPWPKT \
			DRV_GRLIB_GRETH \
			DRV_GRLIB_APBUART \
			DRV_GRLIB_FTMCTRL \
			DRV_GRLIB_AHBSTAT
	DEFAULTS	INCLUDE_GRLIB_AMBAPP_BUSCTRL \
			DRV_TIMER_GRLIB_GPTIMER \
			DRV_INTCTRL_GRLIB_MPIRQ \
			DRV_GRLIB_APBUART
}


/********************************************************************************
 * GRLIB AMBA Plug & Play vxBus
 *
 */
Component INCLUDE_AMBAPP_BUS {
	NAME		AMBA PnP vxBus
	SYNOPSIS	AMBA Plug & Play vxBus
	CONFIGLETTES	$(WIND_BASE)/target/src/hwif/vxbus/vxbAmba.c
	HDR_FILES	hwif/vxbus/vxBus.h hwif/vxbus/vxbAmbaLib.h
	INIT_RTN	ambaRegister();
	REQUIRES	INCLUDE_VXBUS \
			INCLUDE_PLB_BUS
	INCLUDE_WHEN	INCLUDE_PLB_BUS
	_CHILDREN	FOLDER_BUS
	INIT_AFTER	INCLUDE_PLB_BUS
	_INIT_ORDER	hardWareInterFaceBusInit
}

/********************************************************************************
 * GRLIB AMBA Plug & Play bus controller for vxBus
 *
 */
Component INCLUDE_GRLIB_AMBAPP_BUSCTRL {
	NAME		GRLIB AMBA PnP bus controller
	SYNOPSIS	GRLIB AMBA Plug&Play bus controller driver (vxBus)
	CONFIGLETTES	$(WIND_BASE)/target/src/hwif/busCtlr/grlibAmba.c
	REQUIRES	INCLUDE_VXBUS \
			INCLUDE_PLB_BUS \
			INCLUDE_AMBAPP_BUS
	INIT_RTN	grlibAmbaRegister();
	INCLUDE_WHEN	INCLUDE_AMBAPP_BUS
	INIT_AFTER	INCLUDE_AMBAPP_BUS
	_INIT_ORDER	hardWareInterFaceBusInit
}

/********************************************************************************
 * GRLIB GRPCI PCI bus controller for vxBus
 *
 */
Component INCLUDE_GRLIB_GRPCI_PCI {
	NAME		GRLIB GRPCI PCI Host vxBus driver
	SYNOPSIS	Enables Gaisler GRLIB GRPCI PCI vxBus Driver.
	CONFIGLETTES	$(WIND_BASE)/target/src/hwif/busCtlr/grlibGrpci.c
	CFG_PARAMS	GRPCI_VXBUS_DEBUG GRPCI_VXBUS_ENABLE_BYTETWISTING GRPCI_VXBUS_GPIO_INTERRUPT
	INIT_AFTER	INCLUDE_PCI_BUS
	INIT_RTN	grlibGrpciRegister();
	_INIT_ORDER	hardWareInterFaceBusInit
	REQUIRES	INCLUDE_VXBUS \
			INCLUDE_PLB_BUS \
			INCLUDE_AMBAPP_BUS \
			INCLUDE_PCI_BUS \
			INCLUDE_PCI \
			INCLUDE_PCI_BUS_AUTOCONF
}

Parameter GRPCI_VXBUS_GPIO_INTERRUPT {
	NAME		GPIO interrupt
	SYNOPSIS	Enable this if GPIO is used for generating PCI interrupts. The GPIO number used \
			for interrupt reception is configured using PCI_INTA_IRQ..PCI_INTD_IRQ. In LEON3 \
			systems GPIO[N] generate system IRQ[N].\
			\
			The default is that the GRPCI core has an assigned system IRQ shared between all \
			the PCI interrupts (INTA#..INTD#). The assigned IRQ is autodetected.
	DEFAULT		TRUE
	TYPE		bool
}

Parameter GRPCI_VXBUS_ENABLE_BYTETWISTING {
	NAME		Enable Byte Twisting
	SYNOPSIS	Set this to TRUE to enable byte twisting in hardware.
	DEFAULT		TRUE
	TYPE		bool
}

Parameter GRPCI_VXBUS_DEBUG {
	NAME		Enable Debug
	SYNOPSIS	Enable Debug console output
	DEFAULT		FALSE
	TYPE		bool
}

/********************************************************************************
 * GRLIB GPTIMER timer for vxBus
 *
 */
Component DRV_TIMER_GRLIB_GPTIMER {
	NAME		GRLIB timer driver for vxBus
	SYNOPSIS	Timer Driver support
	CONFIGLETTES	$(WIND_BASE)/target/src/hwif/timer/grlibGpTimer.c
	CFG_PARAMS	GPTIMER_SCALAR_RELOAD GPTIMER_MASKED_OUT_TIMERS
	INIT_RTN	grlibGpTimerDrvRegister();
	_INIT_ORDER	hardWareInterFaceBusInit
	REQUIRES	INCLUDE_VXBUS \
			INCLUDE_PLB_BUS \
			INCLUDE_TIMER_SYS
}

Parameter GPTIMER_SCALAR_RELOAD {
	NAME		Timer Prescaler
	SYNOPSIS	Configures the GPTIMER Scalar Reload parameter, it prescales the clock before it gets to \
			the timer. Min value is number of timers + 1. \
			NOTE: This value is decremented once before storing to the hardware.
	DEFAULT		8
	TYPE		uint
}

Parameter GPTIMER_MASKED_OUT_TIMERS {
	NAME		Disable timers
	SYNOPSIS	A bitmask representing timers not to be used by VxWorks. \
				Zero means that all timers can be used. 6 (0110 in binary) \
				means that timer 1 and 2 will not be used.
	TYPE		uint
	DEFAULT		0
}

/********************************************************************************
 * GRIRQMP irqctrl for vxBus
 *
 */
Component DRV_INTCTRL_GRLIB_MPIRQ {
	NAME		GRLIB multiprocessor irqctrl driver for vxBus
	SYNOPSIS	IRQMP Driver support
	CONFIGLETTES	$(WIND_BASE)/target/src/hwif/intCtlr/grlibMPIrq.c
	CFG_PARAMS	GR_MPIRQ_IPI
	INIT_RTN	grlibMPIrqDrvRegister();
	_INIT_ORDER	hardWareInterFaceBusInit
	REQUIRES	INCLUDE_VXBUS \
			INCLUDE_PLB_BUS
}

Parameter GR_MPIRQ_IPI {
	NAME		Ipi
	SYNOPSIS	Configures the Ipi to be used for interprocess communication.
	DEFAULT		5
	TYPE		uint
}

/********************************************************************************
 * GRLIB GRSPW SpaceWire for vxBus
 *
 */

Component DRV_GRLIB_GRSPW {
	NAME		GRSPW SpaceWire driver
	SYNOPSIS	Enables Gaisler GRSPW SpaceWire driver
	CONFIGLETTES	$(WIND_BASE)/target/src/hwif/io/grlibGrspw.c
	CFG_PARAMS	GRSPW0_TXBUFS_NR GRSPW0_RXBUFS_NR GRSPW0_TXD_SIZE GRSPW0_TXH_SIZE GRSPW0_RXPCK_SIZE \
			GRSPW1_TXBUFS_NR GRSPW1_RXBUFS_NR GRSPW1_TXD_SIZE GRSPW1_TXH_SIZE GRSPW1_RXPCK_SIZE \
			GRSPW2_TXBUFS_NR GRSPW2_RXBUFS_NR GRSPW2_TXD_SIZE GRSPW2_TXH_SIZE GRSPW2_RXPCK_SIZE \
			GRSPW3_TXBUFS_NR GRSPW3_RXBUFS_NR GRSPW3_TXD_SIZE GRSPW3_TXH_SIZE GRSPW3_RXPCK_SIZE
	INIT_RTN	grlibGrspwDrvRegister();
	_INIT_ORDER	hardWareInterFaceBusInit
	EXCLUDES	DRV_GRLIB_GRSPWPKT
}

Parameter GRSPW0_TXBUFS_NR {
	NAME		GRSPW0 TX Descriptor Count
	SYNOPSIS	Number of TX Descriptors in GRSPW driver. \
			Set to a number that is a power of two.
	DEFAULT		64
	TYPE		uint
}

Parameter GRSPW0_RXBUFS_NR {
	NAME		GRSPW0 RX Descriptor Count
	SYNOPSIS	Number of RX Descriptors in GRSPW driver. \
			Set to a number that is a power of two.
	DEFAULT		128
	TYPE		uint
}

Parameter GRSPW0_TXD_SIZE {
	NAME  		GRSPW0 Def Max TX packet size
	SYNOPSIS	Default Maximum allowed size of packets passed to write. \
			Can be changed during runtime by calling ioctl. \
			Set to a number that is a power of two.
	DEFAULT		1024
	TYPE		uint
}

Parameter GRSPW0_TXH_SIZE {
	NAME  		GRSPW0 Def Max TX header size
	SYNOPSIS	Default Maximum allowed size of header passed to write. \
			Can be changed during runtime by calling ioctl. \
			Set to a number that is a power of two.
	DEFAULT		64
	TYPE		uint
}

Parameter GRSPW0_RXPCK_SIZE {
	NAME		GRSPW0 Def Max RX packet size
	SYNOPSIS	Default Maximum size of incomming packets. \
			Can be changed during runtime by calling ioctl. \
			Set to a number that is a power of two.
	DEFAULT		1024
	TYPE		uint
}

Parameter GRSPW1_TXBUFS_NR {
	NAME		GRSPW1 TX Descriptor Count
	SYNOPSIS	Number of TX Descriptors in GRSPW driver. \
			Set to a number that is a power of two.
	DEFAULT		64
	TYPE		uint
}

Parameter GRSPW1_RXBUFS_NR {
	NAME		GRSPW1 RX Descriptor Count
	SYNOPSIS	Number of RX Descriptors in GRSPW driver. \
			Set to a number that is a power of two.
	DEFAULT		128
	TYPE		uint
}

Parameter GRSPW1_TXD_SIZE {
	NAME  		GRSPW1 Def Max TX packet size
	SYNOPSIS	Default Maximum allowed size of packets passed to write. \
			Can be changed during runtime by calling ioctl. \
			Set to a number that is a power of two.
	DEFAULT		1024
	TYPE		uint
}

Parameter GRSPW1_TXH_SIZE {
	NAME  		GRSPW1 Def Max TX header size
	SYNOPSIS	Default Maximum allowed size of header passed to write. \
			Can be changed during runtime by calling ioctl. \
			Set to a number that is a power of two.
	DEFAULT		64
	TYPE		uint
}

Parameter GRSPW1_RXPCK_SIZE {
	NAME		GRSPW1 Def Max RX packet size
	SYNOPSIS	Default Maximum size of incomming packets. \
			Can be changed during runtime by calling ioctl. \
			Set to a number that is a power of two.
	DEFAULT		1024
	TYPE		uint
}

Parameter GRSPW2_TXBUFS_NR {
	NAME		GRSPW2 TX Descriptor Count
	SYNOPSIS	Number of TX Descriptors in GRSPW driver. \
			Set to a number that is a power of two.
	DEFAULT		64
	TYPE		uint
}

Parameter GRSPW2_RXBUFS_NR {
	NAME		GRSPW2 RX Descriptor Count
	SYNOPSIS	Number of RX Descriptors in GRSPW driver. \
			Set to a number that is a power of two.
	DEFAULT		128
	TYPE		uint
}

Parameter GRSPW2_TXD_SIZE {
	NAME  		GRSPW2 Def Max TX packet size
	SYNOPSIS	Default Maximum allowed size of packets passed to write. \
			Can be changed during runtime by calling ioctl. \
			Set to a number that is a power of two.
	DEFAULT		1024
	TYPE		uint
}

Parameter GRSPW2_TXH_SIZE {
	NAME  		GRSPW2 Def Max TX header size
	SYNOPSIS	Default Maximum allowed size of header passed to write. \
			Can be changed during runtime by calling ioctl. \
			Set to a number that is a power of two.
	DEFAULT		64
	TYPE		uint
}

Parameter GRSPW2_RXPCK_SIZE {
	NAME		GRSPW2 Def Max RX packet size
	SYNOPSIS	Default Maximum size of incomming packets. \
			Can be changed during runtime by calling ioctl. \
			Set to a number that is a power of two.
	DEFAULT		1024
	TYPE		uint
}

Parameter GRSPW3_TXBUFS_NR {
	NAME		GRSPW3 TX Descriptor Count
	SYNOPSIS	Number of TX Descriptors in GRSPW driver. \
			Set to a number that is a power of two.
	DEFAULT		64
	TYPE		uint
}

Parameter GRSPW3_RXBUFS_NR {
	NAME		GRSPW3 RX Descriptor Count
	SYNOPSIS	Number of RX Descriptors in GRSPW driver. \
			Set to a number that is a power of two.
	DEFAULT		128
	TYPE		uint
}

Parameter GRSPW3_TXD_SIZE {
	NAME  		GRSPW3 Def Max TX packet size
	SYNOPSIS	Default Maximum allowed size of packets passed to write. \
			Can be changed during runtime by calling ioctl. \
			Set to a number that is a power of two.
	DEFAULT		1024
	TYPE		uint
}

Parameter GRSPW3_TXH_SIZE {
	NAME  		GRSPW3 Def Max TX header size
	SYNOPSIS	Default Maximum allowed size of header passed to write. \
			Can be changed during runtime by calling ioctl. \
			Set to a number that is a power of two.
	DEFAULT		64
	TYPE		uint
}

Parameter GRSPW3_RXPCK_SIZE {
	NAME		GRSPW3 Def Max RX packet size
	SYNOPSIS	Default Maximum size of incomming packets. \
			Can be changed during runtime by calling ioctl. \
			Set to a number that is a power of two.
	DEFAULT		1024
	TYPE		uint
}

/********************************************************************************
 * GRLIB GRSPW SpaceWire for vxBus
 *
 */

Component DRV_GRLIB_GRSPWPKT {
	NAME		GRSPW SpaceWire Packet driver
	SYNOPSIS	Enables Gaisler GRSPW SpaceWire Packet driver
	CONFIGLETTES	$(WIND_BASE)/target/src/hwif/io/grlibGrspwPkt.c
	CFG_PARAMS	GRSPWPKT0_NDMA GRSPWPKT0_BD_ADR \
			GRSPWPKT1_NDMA GRSPWPKT1_BD_ADR \
			GRSPWPKT2_NDMA GRSPWPKT2_BD_ADR \
			GRSPWPKT3_NDMA GRSPWPKT3_BD_ADR
	INIT_RTN	grspwPktDrvRegister();
	_INIT_ORDER	hardWareInterFaceBusInit
	EXCLUDES	DRV_GRLIB_GRSPW
}

Parameter GRSPWPKT0_NDMA {
	NAME		GRSPW0 DMA Channel Count
	SYNOPSIS	Number of enabled DMA channels. Use this to limit the \
			The number of DMA channels to save memory. The number \
			of DMA channels is by default autodetected. This must \
			be in the range 1..3 to have an effect.
	DEFAULT		4
	TYPE		uint
}

Parameter GRSPWPKT0_BD_ADR {
	NAME		GRSPW0 Descriptor Table PhyAdr
	SYNOPSIS	Base address of GRSPW descriptor table address. The \
			address is a physical address, if must be aligned to \
			0x400 and hos room for 0x400 * 2 * nDMA.
	DEFAULT		0
	TYPE		uint
}

Parameter GRSPWPKT1_NDMA {
	NAME		GRSPW1 DMA Channel Count
	SYNOPSIS	Number of enabled DMA channels. Use this to limit the \
			The number of DMA channels to save memory. The number \
			of DMA channels is by default autodetected. This must \
			be in the range 1..3 to have an effect.
	DEFAULT		4
	TYPE		uint
}

Parameter GRSPWPKT1_BD_ADR {
	NAME		GRSPW1 Descriptor Table PhyAdr
	SYNOPSIS	Base address of GRSPW descriptor table address. The \
			address is a physical address, if must be aligned to \
			0x400 and hos room for 0x400 * 2 * nDMA.
	DEFAULT		0
	TYPE		uint
}

Parameter GRSPWPKT2_NDMA {
	NAME		GRSPW2 DMA Channel Count
	SYNOPSIS	Number of enabled DMA channels. Use this to limit the \
			The number of DMA channels to save memory. The number \
			of DMA channels is by default autodetected. This must \
			be in the range 1..3 to have an effect.
	DEFAULT		4
	TYPE		uint
}

Parameter GRSPWPKT2_BD_ADR {
	NAME		GRSPW2 Descriptor Table PhyAdr
	SYNOPSIS	Base address of GRSPW descriptor table address. The \
			address is a physical address, if must be aligned to \
			0x400 and hos room for 0x400 * 2 * nDMA.
	DEFAULT		0
	TYPE		uint
}

Parameter GRSPWPKT3_NDMA {
	NAME		GRSPW3 DMA Channel Count
	SYNOPSIS	Number of enabled DMA channels. Use this to limit the \
			The number of DMA channels to save memory. The number \
			of DMA channels is by default autodetected. This must \
			be in the range 1..3 to have an effect.
	DEFAULT		4
	TYPE		uint
}

Parameter GRSPWPKT3_BD_ADR {
	NAME		GRSPW3 Descriptor Table PhyAdr
	SYNOPSIS	Base address of GRSPW descriptor table address. The \
			address is a physical address, if must be aligned to \
			0x400 and hos room for 0x400 * 2 * nDMA.
	DEFAULT		0
	TYPE		uint
}

/********************************************************************************
 * GRLIB OCCAN CAN 2.0 for vxBus
 *
 */

Component DRV_GRLIB_OCCAN {
	NAME		GRLIB OCCAN driver
	SYNOPSIS	Gaisler GRLIB OCCAN CAN 2.0 Driver.
	CONFIGLETTES	$(WIND_BASE)/target/src/hwif/io/grlibOcCan.c
	CFG_PARAMS	OCCAN_TXFIFO_LEN OCCAN_RXFIFO_LEN OCCAN_SHOW_ROUTINES
	INIT_RTN	grlibOcCanDrvRegister();
	_INIT_ORDER	hardWareInterFaceBusInit
	REQUIRES	INCLUDE_VXBUS \
			INCLUDE_PLB_BUS \
			INCLUDE_AMBAPP_BUS
}

Parameter OCCAN_TXFIFO_LEN {
	NAME		OCCAN TX Buffer Size Per Core
	SYNOPSIS	OCCAN TX Buffer Size for one cores. Defaults to 64 messages.
	DEFAULT		64
	TYPE		uint
}

Parameter OCCAN_RXFIFO_LEN {
	NAME		OCCAN RX Buffer Size Per Core
	SYNOPSIS	OCCAN RX Buffer Size for one cores. Defaults to 192 messages.
	DEFAULT		192
	TYPE		uint
}

Parameter OCCAN_SHOW_ROUTINES {
	NAME		OCCAN Show Routines
	SYNOPSIS	Enable to include occanShow* routines.
	DEFAULT		TRUE
	TYPE		bool
}

/********************************************************************************
 * GRLIB GRGPIO GPIO vxBus driver
 *
 */

Component DRV_GRLIB_GRGPIO {
	NAME		GRLIB GPIO driver
	SYNOPSIS	Gaisler GRLIB GRGPIO General Purpose I/O Driver.
	CFG_PARAMS	GRGPIO0_BYPASS GRGPIO0_NUM_PORTS \
			GRGPIO1_BYPASS GRGPIO1_NUM_PORTS
	CONFIGLETTES	$(WIND_BASE)/target/src/hwif/grlib/grlibGrgpio.c
	INIT_RTN	grlibGrGpioDrvRegister();
	_INIT_ORDER	hardWareInterFaceBusInit
	REQUIRES	INCLUDE_VXBUS \
			INCLUDE_PLB_BUS \
			INCLUDE_AMBAPP_BUS \
			DRV_GRLIB_GPIOLIB
}

Parameter GRGPIO0_BYPASS {
	NAME		GRGPIO0 BYPASS
	SYNOPSIS	Configure the BYPASS register of the GRGPIO core. With the \
			BYPASS register a PIN with multiple functions can be set up \
			to use or not to use GPIO functionality. \
			A bit-mask where bitN corresponds to portN. 0=Enable,\
			1=Disable.
	DEFAULT		0
	TYPE		uint
}

Parameter GRGPIO0_NUM_PORTS {
	NAME		GRGPIO0 Number of GPIO Ports
	SYNOPSIS	Hardcode number of GPIO ports, set -1 to autodetect. It \
			might be usefull to hardcode the number of ports to skip \
			autodection because autodetection involves writing to the \
			registers, this can destroy a configuration set up by the \
			boot loader.
	DEFAULT		-1
	TYPE		int
}

Parameter GRGPIO1_BYPASS {
	NAME		GRGPIO1 BYPASS
	SYNOPSIS	Configure the BYPASS register of the GRGPIO core. With the \
			BYPASS register a PIN with multiple functions can be set up \
			to use or not to use GPIO functionality. \
			A bit-mask where bitN corresponds to portN. 0=Enable,\
			1=Disable.
	DEFAULT		0
	TYPE		uint
}

Parameter GRGPIO1_NUM_PORTS {
	NAME		GRGPIO1 Number of GPIO Ports
	SYNOPSIS	Hardcode number of GPIO ports, set -1 to autodetect. It \
			might be usefull to hardcode the number of ports to skip \
			autodection because autodetection involves writing to the \
			registers, this can destroy a configuration set up by the \
			boot loader.
	DEFAULT		-1
	TYPE		int
}

Component DRV_GRLIB_GPIOLIB {
	NAME		GRLIB GPIO Library
	SYNOPSIS	GRLIB General Purpose I/O Driver Library
	CFG_PARAMS	GPIOLIB_SHOW_ROUTINES
	CONFIGLETTES	$(WIND_BASE)/target/src/hwif/grlib/gpiolib.c
	INIT_RTN	gpioLibInitialize();
	_INIT_ORDER	hardWareInterFaceBusInit
}

Parameter GPIOLIB_SHOW_ROUTINES {
	NAME		Enable Show Routines
	SYNOPSIS	Enable GPIO Library Show Routines
	DEFAULT		TRUE
	TYPE		bool
}

/********************************************************************************
 * GRLIB APBUART vxBus driver
 *
 */

Component DRV_GRLIB_APBUART {
	NAME		APBUART driver
	SYNOPSIS	Gaisler GRLIB APBUART Driver.
	CONFIGLETTES	$(WIND_BASE)/target/src/hwif/sio/vxbApbuart.c
	INIT_RTN	apbuartDrvRegister();
	_INIT_ORDER	hardWareInterFaceBusInit
	REQUIRES	INCLUDE_VXBUS \
			INCLUDE_PLB_BUS \
			INCLUDE_AMBAPP_BUS \
			INCLUDE_SIO_UTILS
}


/********************************************************************************
 * GRLIB FTMCTRL FT-Memory controller vxBus driver
 *
 */

Component DRV_GRLIB_FTMCTRL {
	NAME		GRLIB FTMCTRL driver
	SYNOPSIS	GRLIB FTMCTRL Memory Controller Driver
	CONFIGLETTES	$(WIND_BASE)/target/src/hwif/grlib/grlibFtmctrl.c
	INIT_RTN	grlibFtmctrlDrvRegister();
	_INIT_ORDER	hardWareInterFaceBusInit
	REQUIRES	INCLUDE_VXBUS \
			INCLUDE_PLB_BUS \
			INCLUDE_AMBAPP_BUS
}


/********************************************************************************
 * GRLIB AHBSTAT vxBus driver
 *
 */

Component DRV_GRLIB_AHBSTAT {
	NAME		GRLIB AHBSTAT driver
	SYNOPSIS	AHBSTAT bus error monitor driver
	CONFIGLETTES	$(WIND_BASE)/target/src/hwif/grlib/grlibAhbstat.c
	INIT_RTN	grlibAHBStatDrvRegister();
	_INIT_ORDER	hardWareInterFaceBusInit
	REQUIRES	INCLUDE_VXBUS \
			INCLUDE_PLB_BUS \
			INCLUDE_AMBAPP_BUS
}
