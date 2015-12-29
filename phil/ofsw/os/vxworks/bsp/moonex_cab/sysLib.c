/* sysLib.c - MMU LEON/SPARC BSP System-dependent library */

#include "vxWorks.h"
#include "vme.h"
#include "memLib.h"
#include "cacheLib.h"
#include "sysLib.h"
#include "config.h"
#include "string.h"
#include "intLib.h"
#include "logLib.h"
#include "stdio.h"
#include "taskLib.h"
#include "vxLib.h"
#include "tyLib.h"
#include "muxLib.h"
#include "ipProto.h"
#include "private/vmLibP.h"
#include "drv/amba/gaisler/gptimer.h"
#include "arch/sparc/ivSparc.h"
#include "arch/sparc/archSparcDbg.h"
#include "arch/sparc/asmSparc.h"
#include "arch/sparc/leon.h"
#include "arch/sparc/mmuSparcLib.h"
#include "arch/sparc/cache.h"
#if defined (_WRS_CONFIG_SMP)
#include "arch/sparc/smpSparcA.h"
#endif

/* this syscall hack is added so that vxworks-6.0 compiles even
   if INCLUDE_RTP is not defined */
#if  (!defined(__GNUC__)) || !defined(INCLUDE_RTP)
#include "syscallLib.h"
#include "private/syscallLibP.h"
#include "syscallTbl.h"
#endif

/*#define DO_DEBUG*/
#ifdef DO_DEBUG
# define VXSPARCDBG_SYS_PRINTF vxSparc_dbg_printf
#else
# define VXSPARCDBG_SYS_PRINTF
#endif

#ifdef INCLUDE_VXBUS
#    include <../src/hwif/h/vxbus/vxbAccess.h>
#    include "hwif/vxbus/vxBus.h"
#    include "hwconf.c"
#endif /* INCLUDE_VXBUS */

#ifdef INCLUDE_FLASH
#   include "sysFlash.c"
#   include "nvRamToFlash.c"
#else
#   include <mem/nullNvRam.c>
#endif

#define DUMMY_MMU_ENTRY \
    { \
		  (VIRT_ADDR) -1, \
      (PHYS_ADDR) -1, \
      (UINT) -1, \
      (UINT) -1, \
      (UINT) -1 \
    }

/*
 * sysPhysMemDesc[] is used to initialize the Page Table Entry (PTE) array
 * used by the MMU to translate addresses with single page (4k) granularity.
 */
PHYS_MEM_DESC sysPhysMemDesc [] =
{
    /* Address zero, first page normally in ROM, overwritten in case of romResident */
    {
    (VIRT_ADDR) 0,
    (PHYS_ADDR) 0,
    PAGE_SIZE,
    VM_STATE_MASK_VALID | MMU_STATE_MASK_PROTECTION | VM_STATE_MASK_CACHEABLE,
    VM_STATE_VALID  | VM_STATE_WRITABLE_NOT  | VM_STATE_CACHEABLE
    },

    /* Main Memory */
    {
#if !(LOCAL_MEM_LOCAL_ADRS == 0)
    (VIRT_ADDR) LOCAL_MEM_LOCAL_ADRS,
    (PHYS_ADDR) LOCAL_MEM_LOCAL_ADRS,
    (LOCAL_MEM_SIZE)
#else
    (VIRT_ADDR) LOCAL_MEM_LOCAL_ADRS+PAGE_SIZE,
    (PHYS_ADDR) LOCAL_MEM_LOCAL_ADRS+PAGE_SIZE,
    (LOCAL_MEM_SIZE-PAGE_SIZE)
#endif
    /* simple sheme,
     * assume that both cpu use same memory size,
     * map cpu1's memory into cpu0's address space to
     * be able to load image using wrload, for the
     * jump address RAM_HIGH_ADRS has to be configured */
#if defined(_WRS_VX_AMP) && defined(INCLUDE_AMP_CPU_00) && defined(INCLUDE_WRLOAD)
    *2
#endif
    ,
    VM_STATE_MASK_VALID | VM_STATE_MASK_WRITABLE | VM_STATE_MASK_CACHEABLE,
    VM_STATE_VALID  | VM_STATE_WRITABLE  | VM_STATE_CACHEABLE
    },
    /* FPGA I/O -- cacheability currently off */
    {
    (VIRT_ADDR) 0x20000000,
    (PHYS_ADDR) 0x20000000,
    PAGE_SIZE,
    VM_STATE_MASK_VALID | VM_STATE_MASK_WRITABLE,
    VM_STATE_VALID  | VM_STATE_WRITABLE
    },
    /* Dynamic MMU entries needed for devices found during runtime */
#ifdef INCLUDE_PCI /* Include some extra areas for PCI mappings */
    DUMMY_MMU_ENTRY,
    DUMMY_MMU_ENTRY,
    DUMMY_MMU_ENTRY,
    DUMMY_MMU_ENTRY,
#endif
    DUMMY_MMU_ENTRY,
    DUMMY_MMU_ENTRY,
    DUMMY_MMU_ENTRY,
    DUMMY_MMU_ENTRY,
    DUMMY_MMU_ENTRY,
    DUMMY_MMU_ENTRY,
    DUMMY_MMU_ENTRY,
    DUMMY_MMU_ENTRY,
    DUMMY_MMU_ENTRY,
    DUMMY_MMU_ENTRY
};

int sysPhysMemDescNumEntMax = NELEMENTS( sysPhysMemDesc ) ;
int sysPhysMemDescNumEnt = 3;

int   sysBus       = BUS            ; /* system bus type (NONE)            */
int   sysCpu       = CPU            ; /* system CPU type (SPARC/LEON?)     */

extern char _vxSparc_bootline[];
char *sysBootLine  =  /*&_vxSparc_bootline[0]*/  BOOT_LINE_ADRS ; /* address of boot line              */
char *sysExcMsg    = EXC_MSG_ADRS   ; /* catastrophic message area         */

char *_vxworks_default_bootline  = DEFAULT_BOOT_LINE;

/*                                   */
int   sysProcNum   = 0              ; /* processor number of this CPU      */
int   sysFlags                      ; /* boot flags                        */
char  sysBootHost[ BOOT_FIELD_LEN ] ; /* name of host from which we booted */
char  sysBootFile[ BOOT_FIELD_LEN ] ; /* name of file from which we booted */
int   sysMmuOn = TRUE;

void sysPreBoot(unsigned int entry);
STATUS sysAmbaMap(void);

#ifdef DRV_GRLIB_GRETH
/* Number of detected GRETH Ethernet cores */
extern int greth_devs_num;
#endif

#ifdef  INCLUDE_VXBUS
IMPORT  void    hardWareInterFaceInit (void);
#endif

#ifdef INCLUDE_PCI
static BOOL sysPciCapable = FALSE; /* detect core during runtime */

STATUS sysPciSpecialCycle (int busNo, UINT32 message);
STATUS sysPciConfigRead   (int busNo, int deviceNo, int funcNo,
			   int offset, int width, void * pData);
STATUS sysPciConfigWrite  (int busNo, int deviceNo, int funcNo,
			   int offset, int width, ULONG data);
STATUS sysAddMMUMap
    (
    VIRT_ADDR vadr,
    UINT length,
    UINT initialStateMask,
    UINT initialState
    );
BOOL sysCpuHasPci(void);
 #ifndef INCLUDE_VXBUS
  #include "pci/pciIntLib.c"
  #include "pci/pciConfigLib.c"

  #if (defined(INCLUDE_PCI_CFGSHOW) && !defined(PRJ_BUILD))
   #include "pci/pciConfigShow.c"
  #endif
  #include "pci/pciAutoConfigLib.c"
 #endif
#endif

char *sysGetBootLine()
{
    return sysBootLine;
}

/*#include "amba/gaisler/gptimer/gptimer.c"*/

void sysLedInit (void){ CONFIG_VXSPARCDBG_FNCALL; }

UINT8 sysLedSet (UINT8 mask,UINT8 value) { CONFIG_VXSPARCDBG_FNCALL; return 0; }

void sysLedHex ( UINT8	value) { CONFIG_VXSPARCDBG_FNCALL; }


#if defined(INCLUDE_TTY_DEV) || defined(INCLUDE_SIO_POLL)
#include "sysSerial.c"
#endif  /* INCLUDE_TTY_DEV || INCLUDE_SIO_POLL */

#if defined(INCLUDE_VXBUS) && defined(INCLUDE_SIO_UTILS)
IMPORT void sysSerialConnectAll(void);
#endif

#ifdef  INCLUDE_END
#  include "sysNet.h"
#  include "sysNet.c"
#endif /* INCLUDE_END */

#ifdef INCLUDE_I2C
 #include "sysI2C.c"
#endif

#include "sysFpga.c"

/***********************************************************************
*
* sysModel - return the model name of the CPU board
*
* This routine returns the model name of the CPU board.
*
* RETURNS: A pointer to the string.
*
* ERRNO
*/
char sysModelStr[50] = {0};

char * sysModel
    (
    void
    )
    {
      CONFIG_VXSPARCDBG_FNCALL;
      /* Init the String the first time */
      if ( !sysModelStr[0] )
        sprintf(sysModelStr,SYS_MODEL,LEONCOMPAT_VERSION);

      return( &sysModelStr[0] );
    }

/***********************************************************************
*
* sysBspRev - return the BSP version and revision number
*
* This routine returns a pointer to a BSP version and revision number. For
* example, 1.2/0. BSP_REV is concatenated to BSP_VERSION and returned.
*
* RETURNS: A pointer to the BSP version/revision string.
*
* ERRNO
*/

char * sysBspRev
    (
    void
    )
    {
      CONFIG_VXSPARCDBG_FNCALL;
      return( BSP_VERSION BSP_REV );
    }

/***********************************************************************
*
* sysHwInit - initialize the system hardware
*
* This routine initializes various features of the hardware.
* Normally this routine is called from usrInit().
*
* NOTE: This routine should not be called directly by the user.
*
* RETURNS: N/A
*
* ERRNO
*/

extern void _sysInit(void);
void sysHwInit
    (
    void
    )
    {
	/* In case of romResident map rom into vaddr-space */
    int maprom = ((ROM_BASE_ADRS <= (unsigned int)&_sysInit) && (ROM_BASE_ADRS+ROM_SIZE) > (unsigned int)&_sysInit) && (ROM_SIZE>0) ? 1 : 0;

    /* If using TFFS map rom into vaddr-space */
#ifdef INCLUDE_TFFS
    maprom = 1;
#endif

    CONFIG_VXSPARCDBG_FNCALL;

#ifdef LEON2_AMBA_PNP
    leon2_ambapp_avail = 1;

    /* If not defined it will default to LEON2PNP_IO_AREA */
#ifdef LEON2_AMBA_PNP_IOAREA_ADDRESS
    leon2_ambapp_ioarea = LEON2_AMBA_PNP_IOAREA_ADDRESS;
#endif
#endif

    amba_init();        /* call for leon2(do nothing) and leon3 */

    /* Initialize MMU map for all AMBA I/O spaces */
    sysAmbaMap();

    if (maprom) {
        PHYS_MEM_DESC *tab = &sysPhysMemDesc[0];
        if (ROM_BASE_ADRS != tab->virtualAddr) {
            tab = &sysPhysMemDesc[sysPhysMemDescNumEnt];
            sysPhysMemDescNumEnt++;
        }
        tab->virtualAddr = ROM_BASE_ADRS;
        tab->physicalAddr = (PHYS_ADDR)ROM_BASE_ADRS;
        tab->len = ROM_SIZE;
        tab->initialStateMask = VM_STATE_MASK_VALID | VM_STATE_MASK_WRITABLE | VM_STATE_MASK_CACHEABLE;
        tab->initialState = VM_STATE_VALID  | VM_STATE_WRITABLE  | VM_STATE_CACHEABLE;
    }
#ifdef SAVE_NVRAM_REGION
    else
   	{
    	/* Map only NVRAM part of memory into vaddr-space */
    	PHYS_MEM_DESC *tab = &sysPhysMemDesc[sysPhysMemDescNumEnt];
        sysPhysMemDescNumEnt++;
        tab->virtualAddr = NVRAM_START_ADDR;
        tab->physicalAddr = NVRAM_START_ADDR;
        tab->len = NV_RAM_SIZE;
        tab->initialStateMask = VM_STATE_MASK_VALID | VM_STATE_MASK_WRITABLE | VM_STATE_MASK_CACHEABLE;
        tab->initialState = VM_STATE_VALID  | VM_STATE_WRITABLE  | VM_STATE_CACHEABLE;
   	}
#endif

#if defined (_WRS_CONFIG_SMP)
#if GR_MPIRQ_IPI < 14
    do_ipicheck_in_lock = 1;
#endif
    mpirq_ipinr = GR_MPIRQ_IPI;
#endif

#ifdef INCLUDE_VXBUS
    /* Initialize hardware resources */
    sysHwConfInit();

    hardWareInterFaceInit();
#endif /* INCLUDE_VXBUS */

    _func_SysBootParamsGet = (FUNCPTR)sysPreBoot;

    /*
     * Reset serial channels.
     */
#if defined(INCLUDE_TTY_DEV) || defined(INCLUDE_SIO_POLL)
    sysSerialHwInit ();
#endif  /* INCLUDE_TTY_DEV || INCLUDE_SIO_POLL */

#ifdef  FORCE_DEFAULT_BOOT_LINE
    strncpy (sysBootLine,DEFAULT_BOOT_LINE,strlen(DEFAULT_BOOT_LINE)+1);
#endif /* FORCE_DEFAULT_BOOT_LINE */
    }

/***********************************************************************
*
* sysPhysMemTop - get the address of the top of physical memory
*
* This routine returns the address of the first missing byte of memory,
* which indicates the top of memory.
*
* Normally, the user specifies the amount of physical memory with the
* macro LOCAL_MEM_SIZE in config.h.  BSPs that support run-time
* memory sizing do so only if the macro LOCAL_MEM_AUTOSIZE is defined.
* If not defined, then LOCAL_MEM_SIZE is assumed to be, and must be, the
* true size of physical memory.
*
* NOTE: Do no adjust LOCAL_MEM_SIZE to reserve memory for application
* use.  See sysMemTop() for more information on reserving memory.
*
* RETURNS: The address of the top of physical memory.
*
* ERRNO
*
* SEE ALSO: sysMemTop()
*/

char * sysPhysMemTop(void) {
    static int outon = 1;
    char * physTop;

    physTop = (char *)(LOCAL_MEM_LOCAL_ADRS + LOCAL_MEM_SIZE);

    if (outon){
	outon = 0;
	CONFIG_VXSPARCDBG_HEADER_PRINTF_ALWAYS("PhysMemTop: 0x%x\n",physTop);
    }
    return( physTop ) ;
}

/***********************************************************************
*
* sysMemTop - get the address of the top of VxWorks memory
*
* This routine returns a pointer to the first byte of memory not
* controlled or used by VxWorks.
*
* The user can reserve memory space by defining the macro USER_RESERVED_MEM
* in config.h.  This routine returns the address of the reserved memory
* area.  The value of USER_RESERVED_MEM is in bytes.
*
* RETURNS: The address of the top of VxWorks memory.
*
* ERRNO
*/

char *sysMemTop
    (
    void
    )
    {
    static char * memTop = NULL;

    if ( memTop == NULL )
        {
	char *_sysPhysMemTop = sysPhysMemTop ();
        memTop = _sysPhysMemTop - USER_RESERVED_MEM;

#ifdef INCLUDE_EDR_PM
        /* account for ED&R persistent memory */

        memTop = memTop - PM_RESERVED_MEM;
#endif

	CONFIG_VXSPARCDBG_FNCALL;
	CONFIG_VXSPARCDBG_HEADER_PRINTF_ALWAYS("RAM_LOW_ADRS        : 0x%x\n",RAM_LOW_ADRS);
	CONFIG_VXSPARCDBG_HEADER_PRINTF_ALWAYS("LOCAL_MEM_LOCAL_ADRS: 0x%x\n",LOCAL_MEM_LOCAL_ADRS);
	CONFIG_VXSPARCDBG_HEADER_PRINTF_ALWAYS("LOCAL_MEM_SIZE      : 0x%x\n",LOCAL_MEM_SIZE);
	CONFIG_VXSPARCDBG_HEADER_PRINTF_ALWAYS("sysPhysMemTop       : 0x%x\n",_sysPhysMemTop);
	CONFIG_VXSPARCDBG_HEADER_PRINTF_ALWAYS("sysMemTop           : 0x%x\n",memTop);
	/*VXSPARCDBG_HEADER_PRINTF(VXSPARCDBG_ALWAYS_NR,"KERNEL_HEAP_SIZE    : 0x%x\n",KERNEL_HEAP_SIZE);*/

	}

    return memTop;
    }

/***********************************************************************
*
* sysToMonitor - transfer control to the ROM monitor
*
* This routine transfers control to the ROM monitor.  Normally, it is called
* only by reboot()--which services ^X--and by bus errors at interrupt level.
* However, in some circumstances, the user may wish to introduce a
* <startType> to enable special boot ROM facilities.
*
* RETURNS: Does not return.
*
* ERRNO
*/

int  sysToMonitorSmpMaster(int startType) {
#ifdef INCLUDE_LAN91C111_END
    END_OBJ * pEnd;
#endif
    intLock ();

    cacheDisable (INSTRUCTION_CACHE);
    cacheDisable (DATA_CACHE);

#if defined(INCLUDE_AUX_CLK)
    sysAuxClkDisable();
#endif /* INCLUDE_AUX_CLK */

#ifdef INCLUDE_LAN91C111_END
    pEnd = endFindByName ("lnc", 0);
    if ( pEnd )
    	pEnd->pFuncTable->stop(pEnd->devObject.pDevice);
#endif /* INCLUDE_LAN91C111_END */

#if defined(INCLUDE_TTY_DEV) || defined(INCLUDE_SIO_POLL)
    sysSerialReset ();          /* reset the serial device                  */
#endif

    sysClkDisable();

    srmmuDisable ();            /* Disable MMU so we can jump to 0x00000008 */

    (*((FUNCPTR) (ROM_WARM_ADRS))) (startType);        /* warm reboot, jump to bootrom entry point              */

    return( OK );               /* in case we continue from ROM monitor     */
    }

#if defined (_WRS_CONFIG_SMP)

LOCAL int smpsparc_startType = 0;

void  sysToMonitorSmpMasterSlave(int cmd, struct sparc_pt_regs *pt_regs) {

    /* if the reboot() was issued on a slave cpu then
     * the slave-cpu will issue a NMI to cpu0. Continue the
     * master-cpu reset and jumpt to warm-reboot */
    if (_WRS_CPU_INDEX_GET() == 0)
        sysToMonitorSmpMaster(smpsparc_startType);

    /* slave-cpu path */
    intLock ();
    intSmpQuiteIrqNmi(_WRS_CPU_INDEX_GET());
    cacheDisable (INSTRUCTION_CACHE);
    cacheDisable (DATA_CACHE);
    srmmu_set_mmureg(0);
    srmmu_set_context(0);
    (*((FUNCPTR) (ROM_BASE_ADRS+0x1f0))) (0);        /* jump to idle  */
}

#endif

STATUS sysToMonitor
    (
       int startType    /* parameter passed to ROM to tell it how to boot   */
    )
    {

    CONFIG_VXSPARCDBG_FNCALL;
#if defined (_WRS_CONFIG_SMP)
    {
        int j;
        int cpuCnt = intSmpCpuCount();
        smpsparc_startType = startType;

        sparc_mni_ipi_cmd_vec[SPARC_NMI_CMD_REBOOT] = (FUNCPTR) sysToMonitorSmpMasterSlave;
        for (j = 0; j < cpuCnt; j++) {
            if (j != _WRS_CPU_INDEX_GET()) {
                intSmpForceIrqNmi(j, SPARC_NMI_CMD_REBOOT, 0);
            }
        }
    }
    /* if reboot() is issued on a slave-cpu, NMI will force the cpu-0 to
     * reboot, take slave-cpu path */
    if (_WRS_CPU_INDEX_GET() != 0)
        sysToMonitorSmpMasterSlave(SPARC_NMI_CMD_REBOOT, 0); /* will not return */
#endif
    return sysToMonitorSmpMaster(startType); /* in case we continue from ROM monitor     */
    }


/***********************************************************************
*
* sysHwInit2 - initialize additional system hardware
*
* This routine connects system interrupt vectors and configures any
* required features not configured by sysHwInit().
*
* RETURNS: N/A
*
* ERRNO
*/

void sysHwInit2
    (
    void
    )
    {
    static BOOL configured = FALSE ;
    CONFIG_VXSPARCDBG_FNCALL;

    if ( ! configured )
        {
#ifdef  INCLUDE_VXBUS
        vxbDevInit();
#endif /* INCLUDE_VXBUS */

        /*
         * initialize serial interrupts
         */
#if defined(INCLUDE_TTY_DEV) || defined(INCLUDE_SIO_POLL)
        sysSerialHwInit2 ();
#endif

#if defined(INCLUDE_VXBUS) && defined(INCLUDE_SIO_UTILS)
        sysSerialConnectAll();
#endif /* INCLUDE_VXBUS && INCLUDE_SIO_UTILS */

#ifdef INCLUDE_I2C
        /* Initialize i2c support */
        sysI2CInit(NULL);
#endif

#ifdef  INCLUDE_VXBUS
        taskSpawn("tDevConn", 11, 0, 10000,
                  vxbDevConnect, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
#endif /* INCLUDE_VXBUS */

        /* Initialize CAB FPGAs */
        sysFpgaInit();

        /*
         * Indicate we have been through this procedure for reentrancy.
         */
        configured = TRUE;
        }
    }

#if defined(INCLUDE_USER_APPL) && defined(INCLUDE_END)
/******************************************************************************
*
* myAppInit - final system configuration
*
* This routine is invoked after all other system initialization has completed.
* This is an example that configures and enables any Ethernet interfaces other
* than the boot device.
*
* RETURNS: N/A
*
* ERRNO
*/

void myAppInit
    (
    void
    )
    {
      CONFIG_VXSPARCDBG_FNCALL;
    }

#endif  /* INCLUDE_USER_APPL && INCLUDE_END */

/***********************************************************************
*
* sysProcNumGet - get the processor number
*
* This routine returns the processor number for the CPU board, which is
* set with sysProcNumSet().
*
* RETURNS: The processor number for the CPU board.
*
* ERRNO
*
* SEE ALSO: sysProcNumSet()
*/

int sysProcNumGet
    (
    void
    )
    {
    CONFIG_VXSPARCDBG_FNCALL;
    return( sysProcNum );
    }

/***********************************************************************
*
* sysProcNumSet - set the processor number
*
* This routine sets the processor number for the CPU board.  Processor numbers
* should be unique on a single backplane.  It also maps local resources onto
* the VMEbus.
*
* RETURNS: N/A
*
* ERRNO
*
* SEE ALSO: sysProcNumGet()
*
*/

void sysProcNumSet
    (
    int procNum         /* processor number */
    )
    {
    CONFIG_VXSPARCDBG_FNCALL;
    sysProcNum = procNum;
    }


/***********************************************************************
*
* sysCoreFreqGet - determines the Core operating frequency
*
* This routine determines the Core operating frequency
*
*
* RETURNS: Core frequency in HZ
*
* ERRNO
*/

UINT32 sysCoreFreqGet
    (
    void
    )
    {
    return SYS_CLK_FREQ;
    }


/***********************************************************************
*
* sysChipRev - determines revision of Chip installed
*
* This routine determines the revision of Chip installed
*
* RETURNS: Chip revision
*
* ERRNO
*/

UINT32 sysChipRev
    (
    void
    )
{
    if ( LEONCOMPAT_VERSION >= 3 ){
	/* Return GRLIB Build version */
	return sysInWord(0xfffffff2);
    }else{
	return 0;
    }
}

/***********************************************************************
*
* sysCpuHasPci - determines processor PCI capability
*
* This routine returns whether the processor contains a PCI bridge.
* It does not determine if PCI is enabled.
*
* RETURNS: TRUE if processor supports PCI, FALSE otherwise
*
* ERRNO
*/

BOOL sysCpuHasPci
    (
    void
    )
    {
#ifdef INCLUDE_PCI
    /* Look if PCI controller was found */
    return (sysPciCapable);
#else
    return FALSE;
#endif
    }

/***********************************************************************
*
* sysPciEnabled - determines if processor PCI mode is enabled
*
* This routine returns whether the processor has enabled PCI mode.
*
* RETURNS: TRUE if processor PCI mode is enabled, FALSE otherwise
*
* ERRNO
*/

BOOL sysPciEnabled
    (
    void
    )
    {
    BOOL pciEnabled = FALSE;

    if (sysCpuHasPci())
        {
        /* read Status Register */
/*         pciEnabled = ( sysStatusRegGet() & STATUS_PCIMODE_MASK ) ? FALSE : TRUE; */
        }

    return (pciEnabled);
    }

void sysPreBoot(unsigned int entry)
{
	/* Restore AMBA */
	amba_exit();
}

#if !defined(PRJ_BUILD) || !defined(INCLUDE_GNU_INTRINSICS)
/* no gcc intrinsics available, dummy puller */
char **__gcc_intrinsicsInit()
{
    VXSPARC_STOPALL_ONLY;
    return 0;
}
#endif

/* Show a memory map (Physical->Virtual MAP) */
void sysMemDescShow(PHYS_MEM_DESC * pMmu, int index)
{
	if ( !pMmu ) {
		printf("sysPhysMemDesc[%d] = NONE\n", index);
		return;
	}
	printf("sysPhysMemDesc[%d] =\n", index);
	printf("    vAddr @ 0x%08x\n", pMmu->virtualAddr);
	printf("    pAddr @ 0x%08x\n", pMmu->physicalAddr);
	printf("    size  = 0x%08x (%dKB)\n", pMmu->len, pMmu->len/1024);
}

/* Shows the complete current memory map */
void sysMemMapShow (void)
{
	PHYS_MEM_DESC * pMmu = &sysPhysMemDesc[0];
	int i;

	for ( i = 0 ; i < sysPhysMemDescNumEnt ; i++ ) {
		sysMemDescShow(pMmu, i);
		pMmu++;
	}
}

/* Helper function to sysAddMMUMap, finds other memory maps close to
 * vadr..vadr+length.
 * If a region if found on a higher address than, overlapping, or starting at the
 * address as [vadr..vadr+length] end that region is stored into top.
 */
STATUS sysMMuMapfindTopBot(VIRT_ADDR vadr, UINT length, PHYS_MEM_DESC **top, PHYS_MEM_DESC **bottom)
{
	PHYS_MEM_DESC *curr, *high, *low;
	int i;
	VIRT_ADDR end;

	end = (VIRT_ADDR)((UINT)vadr + length);
	high = low = NULL;
	curr = &sysPhysMemDesc[0];
	for(i=0; i<sysPhysMemDescNumEnt; i++) {
		/* Is it closes to bottom? */
		if ( curr->virtualAddr <= vadr ) {
			/* Ok. Map starts lower than what we are suppoesd to map, a candidate */
			if ( !low || (curr->virtualAddr > low->virtualAddr) ) {
				/* Closest to bottom */
				low = curr;
			}
		}

		if ( curr->virtualAddr >= end ) {
			/* Ok. Map starts lower than what we are suppoesd to map, a candidate */
			if ( !high || (curr->virtualAddr < high->virtualAddr) ) {
				/* Closest to bottom */
				high = curr;
			}
		}
		curr++;
	}

	*top = high;
	*bottom = low;

	return OK;
}

/* Helper macros and functions to sysAddMMUMap */
#define START(desc)              ((VIRT_ADDR)((desc)->virtualAddr))
#define END(desc)                ((VIRT_ADDR)((UINT)(desc)->virtualAddr + (desc)->len))
#define OVERLAP_TOP(desc,end)    (end>START(desc))
#define OVERLAP_BOT(desc,start)  (start<END(desc))

void sysAddMMUMapExtend(PHYS_MEM_DESC *bot, VIRT_ADDR vadr, UINT length)
{
	if ( vadr > bot->virtualAddr ) {
		bot->len = bot->len + (((UINT)vadr+length) - ((UINT)bot->virtualAddr+bot->len));
	}
}

void sysAddMMUMapLower(PHYS_MEM_DESC *top, VIRT_ADDR vadr, UINT length)
{
	if ( vadr < top->virtualAddr ) {
		top->virtualAddr = vadr;
		top->len = top->len + ((UINT)top->virtualAddr - (UINT)vadr);
	}
}

/* Do a 1:1 mapping between Virtual and physical space.
 *
 * Note that there are limitations on the input. A region that overlaps a current
 * region on both top and bottom is not supported. This case should not occur normally.
 */
STATUS sysAddMMUMap
    (
    VIRT_ADDR vadr,
    UINT length,
    UINT initialStateMask,
    UINT initialState
    )
{
	PHYS_MEM_DESC *tab;
	PHYS_MEM_DESC *top, *bottom;
	STATUS status;
	VIRT_ADDR end;

	/* Align to page boundary */
	length = (length+(PAGE_SIZE-1)) & ~(PAGE_SIZE-1);
	vadr = ((UINT)vadr) & ~(PAGE_SIZE-1);
	end = (VIRT_ADDR)((UINT)vadr + length);

	/* Find closest two maps (top and bottom) */
	top = bottom = NULL;
	status = sysMMuMapfindTopBot(vadr, length, &top, &bottom);

	if ( bottom ) {
		/* Do we need to extend bottom? */

		/* Is bottom ending where the new map is starting? */
		if ( END(bottom) == vadr ) {
			/* Extend bottom unless top is overlapping */
			if ( top && OVERLAP_TOP(top,end) ) {
				/* top is overlapping, increase size of top
				 * 9.
				 */
				sysAddMMUMapLower(top, vadr, length);
				return OK;
			}
			/* 5,6,7a */
			sysAddMMUMapExtend(bottom, vadr, length);
			return OK;
		}

		/* Is bottom overlapping new map area? */
		if ( OVERLAP_BOT(bottom,vadr) ) {
			/* Yes. */
			if ( top && OVERLAP_TOP(top, end) ) {
				/* Both top and bottom overlap. We solve this by extending
				 * bottom up to top
				 * 10.
				 */
				vadr = END(bottom);
				length = (UINT)START(top) - (UINT)END(bottom);
			}
			/* Bottom is extended
			 * 8a, 8b, 8c
			 */
			sysAddMMUMapExtend(bottom, vadr, length);
			return OK;
		}

		/* Not close to bottom then. We proceed as if we got no bottom as
		 * we're not close to it any way.
		 */
		bottom = NULL;
	}

	/* No bottom interfering */

	if ( top ) {
		/* Is top starting where the new map is ending? */
		if ( START(top) == end ) {
			/* Yes, we increase size of top to include new area
			 * 2.
			 */
			sysAddMMUMapLower(top, vadr, length);
			return OK;
		}
		/* Is top overlapping new map area? */
		if ( OVERLAP_TOP(top, end) ) {
			sysAddMMUMapLower(top, vadr, length);
			return OK;
		}
	}

	/* No matching ==> we need a map of our own */

	if ( sysPhysMemDescNumEnt >= sysPhysMemDescNumEntMax ) {
		/* No more free entries in table */
		return ERROR;
	}

	/* Find next free field */
	tab = &sysPhysMemDesc[sysPhysMemDescNumEnt];

	tab->virtualAddr = vadr;
	tab->physicalAddr = (PHYS_ADDR)vadr; /* Always do 1:1 mapping */
	tab->len = length;
	tab->initialStateMask = initialStateMask;
	tab->initialState = initialState;

	/* Add */
	sysPhysMemDescNumEnt++;

	return OK;
}

/* Calls sysAddMMUMap for each APB Slave region and for each AHB Slave region
 * found. sysAddMMUMap maps it.
 */
STATUS sysAmbaMapDev(int type, void *dev, void *arg)
{
    ambapp_ahb_device *ahb;
    ambapp_apb_device *apb;
    int i;

    if ( type == AMBA_TYPE_AHB_MST )
        return ERROR;

    if ( type == AMBA_TYPE_AHB_SLV ) {
        /* Map only AHB I/O space */
        ahb = (ambapp_ahb_device *)dev;
        for(i=0; i<4; i++) {
            if ( (ahb->type[i] == 3) && (ahb->mask[i] != 0) ) {
                sysAddMMUMap(
                    (VIRT_ADDR)ahb->start[i],
                    ahb->mask[i],
                    (VM_STATE_MASK_VALID | VM_STATE_MASK_WRITABLE | VM_STATE_MASK_CACHEABLE),
                    (VM_STATE_VALID  | VM_STATE_WRITABLE  | VM_STATE_CACHEABLE_NOT)
                    );
            }
        }
    }

    if ( type == AMBA_TYPE_APB_SLV ) {
        apb = (ambapp_apb_device *)dev;
        if ( (apb->mask != 0) ) {
            sysAddMMUMap(
                (VIRT_ADDR)apb->start,
                apb->mask,
                (VM_STATE_MASK_VALID | VM_STATE_MASK_WRITABLE | VM_STATE_MASK_CACHEABLE),
                (VM_STATE_VALID  | VM_STATE_WRITABLE  | VM_STATE_CACHEABLE_NOT)
                );
        }
    }

    return OK;
}

STATUS sysAmbaMap(void)
{
    ambapp_bus *abus = amba_get_bus();

    /* If LEON2 MAP all standard devices on 0x80000000-0x80000200 1:1 */
    if ( LEONCOMPAT_VERSION == 2 ) {
        sysAddMMUMap(
            (VIRT_ADDR)LEON_REG,
            0x200,
            (VM_STATE_MASK_VALID | VM_STATE_MASK_WRITABLE | VM_STATE_MASK_CACHEABLE),
            (VM_STATE_VALID  | VM_STATE_WRITABLE  | VM_STATE_CACHEABLE_NOT)
        );
    }

    /* Iterate through all AMBA AHB Slave devices and call sysAmbaMapDev every time */
    if ( ambapp_for_each_dev(abus, AMBA_TYPE_AHB_SLV, sysAmbaMapDev, NULL) != OK )
    	return ERROR;

    /* Iterate through all AMBA APB Slave devices and call sysAmbaMapDev every time */
    if ( ambapp_for_each_dev(abus, AMBA_TYPE_APB_SLV, sysAmbaMapDev, NULL) != OK )
    	return ERROR;

    return OK;
}

unsigned int sysPipeIntVecGet()
{
    VXSPARC_STOPALL;
    return 0;
}

int sysHasDataSnooping(void)
{
	static int hasSnooping = -1;
	if ( hasSnooping == -1 ) {
		hasSnooping = cacheHasDataSnooping();
	}
	return hasSnooping;
}

int sysDataSnoopingEnabled(void)
{
	return cacheDataSnoopingEnabled();
}

/* Sys out/in Standard vxWorks functions */

UCHAR	sysInByte(ULONG port){
	return LEON23_REG_LOAD8(port);
}

USHORT sysInWord(ULONG port){
	return LEON23_REG_LOAD16(port);
}

ULONG	sysInLong(ULONG port){
	return LEON23_REG_LOAD(port);
}

void	sysOutByte(ULONG port, UCHAR data){
	LEON23_REG_STORE8(port,data);
}

void sysOutWord(ULONG port, UINT16 data){
	LEON23_REG_STORE16(port,data);
}

void sysOutLong(ULONG port, ULONG data){
	LEON23_REG_STORE(port,data);
}

#ifdef INCLUDE_PCI

/* PCI Host Hardware may implement bytetwisting reading/writing from/to
 * PCI address space. When accessing I/O Registers over memory space
 * the register content must be bytetwisted back to non-bytetwisted
 * order.
 *
 * GRPCI is the only GRLIB core that has support for byte-twisting.
 */
#if defined(GRPCI_VXBUS_ENABLE_BYTETWISTING) && \
       (GRPCI_VXBUS_ENABLE_BYTETWISTING == TRUE)
  #define PCI_HW_DO_BYTETWISTING TRUE
#else
  #define PCI_HW_DO_BYTETWISTING FALSE
#endif

UINT8 sysPciInByte(UINT8 *pAddr)
{
  UINT8 ret = *(volatile UINT8 *)pAddr;
  /*VXSPARCDBG_SYS_PRINTF("sysPciInByte: [0x%x] ==> 0x%x\n",pAddr,ret);*/
  return ret;
}

USHORT sysPciInWord(USHORT *pAddr)
{
#if (PCI_HW_DO_BYTETWISTING == TRUE)
  USHORT ret = WORDSWAP(*(volatile USHORT *)pAddr);
#else
  USHORT ret = *(volatile USHORT *)pAddr;
#endif
  /*VXSPARCDBG_SYS_PRINTF("sysPciInWord: [0x%x] ==> 0x%x\n",pAddr,ret);*/
  return ret;
}

UINT32 sysPciInLong(UINT32 *pAddr)
{
#if (PCI_HW_DO_BYTETWISTING == TRUE)
  UINT32 ret = LONGSWAP(*(volatile UINT32 *)pAddr);
#else
  UINT32 ret = *(volatile UINT32 *)pAddr;
#endif
  /*VXSPARCDBG_SYS_PRINTF("sysPciInLong: [0x%x] ==> 0x%x\n",pAddr,ret);*/
  return ret;
}

void sysPciOutByte(UINT8 *pAddr, UINT8 data)
{
  /*VXSPARCDBG_SYS_PRINTF("sysPciOutByte: [0x%x] <== 0x%x\n",pAddr,data);*/
  *(volatile UINT8 *)pAddr = data;
}

void sysPciOutWord(USHORT *pAddr, USHORT data)
{
  /*VXSPARCDBG_SYS_PRINTF("sysPciOutWord: [0x%x] <== 0x%x\n",pAddr,data);*/
#if (PCI_HW_DO_BYTETWISTING == TRUE)
  *(volatile USHORT *)pAddr = WORDSWAP(data);
#else
  *(volatile USHORT *)pAddr = data;
#endif
}

void sysPciOutLong(UINT32 *pAddr, UINT32 data)
{
  /*VXSPARCDBG_SYS_PRINTF("sysPciOutLong: [0x%x] <== 0x%x\n",pAddr,data);*/
#if (PCI_HW_DO_BYTETWISTING == TRUE)
  *(volatile ULONG *)pAddr = LONGSWAP(data);
#else
  *(volatile ULONG *)pAddr = data;
#endif
}

ULONG sysPciRead32(ULONG *pAddr)
{
  /* Byte swap as neccessary */
#if (PCI_HW_DO_BYTETWISTING == TRUE)
  UINT32 ret = LONGSWAP(*(volatile ULONG *)pAddr);
#else
  UINT32 ret = *(volatile ULONG *)pAddr;
#endif
  /*VXSPARCDBG_SYS_PRINTF("sysPciRead32: [0x%x] ==> 0x%x\n",pAddr,ret);*/
  return ret;
}

USHORT sysPciRead16(USHORT *pAddr)
{
#if (PCI_HW_DO_BYTETWISTING == TRUE)
  USHORT ret = WORDSWAP(*(volatile ULONG *)pAddr);
#else
  USHORT ret = *(volatile ULONG *)pAddr;
#endif
  /*VXSPARCDBG_SYS_PRINTF("sysPciRead16: [0x%x] ==> 0x%x\n",pAddr,ret);*/
  return ret;
}

void sysPciWrite16(USHORT *pAddr, USHORT data)
{
  /*VXSPARCDBG_SYS_PRINTF("sysPciWrite16: [0x%x] <== 0x%x\n",pAddr,data);*/
#if (PCI_HW_DO_BYTETWISTING == TRUE)
  *(volatile USHORT *)pAddr = WORDSWAP(data);
#else
  *(volatile USHORT *)pAddr = data;
#endif
}

void sysPciWrite32(ULONG *pAddr, ULONG data)
{
  /*VXSPARCDBG_SYS_PRINTF("sysPciWrite32: [0x%x] <== 0x%x\n",pAddr,data);*/
#if (PCI_HW_DO_BYTETWISTING == TRUE)
  *(volatile ULONG *)pAddr = LONGSWAP(data);
#else
  *(volatile ULONG *)pAddr = data;
#endif
}
#endif

#include <grdrv/register.h>

/* No translation needed on the same bus */
unsigned int system_default_memto(unsigned int address)
{
  return address;
}

/* No translation needed on the same bus */
unsigned int system_default_memfrom(unsigned int address)
{
  return address;
}

STATUS system_intConnect(int irq, void *handler, void *arg)
{
  return intConnect(
            (VOIDFUNCPTR *)INUM_TO_IVEC(irq),
            (VOIDFUNCPTR)handler,
            (int)arg
            );
}

struct grdrv_system system_default =
{
  system_default_memto,
  system_default_memfrom,

  (void (*)(int,void*,void*))system_intConnect,
  NULL,
  (void(*)(int))intDisable,
  (void(*)(int))intEnable,
  NULL,

  amba_get_bus,
  sysCoreFreqGet
};

int vxbTimerLibInit(void) { return OK; }

#ifdef INCLUDE_VXBUS
void optimizeAccessFunction
    (
    UINT32          flags,              /* flags */
    pVXB_ACCESS_LIST pAccess,           /* bus access structure ptr */
    UINT32          operationId         /* operation indicator */
     )
{
}
#endif

#if defined (_WRS_CONFIG_SMP)
#ifdef  INCLUDE_MMU_BASIC
IMPORT void mmuSparcCpuInit (void);
#endif

void _sysCpuInit (void)
{
#ifdef  INCLUDE_MMU_BASIC
	    mmuSparcCpuInit ();
#endif  /* INCLUDE_MMU */
}

#endif

unsigned int sysGet_VEC_BASE_ADRS() { return (int)VEC_BASE_ADRS; }

#ifdef INCLUDE_WRLOAD

/*****************************************************************************
*
* sysAmpCpuEnable - Starts core1 executing code at entryPt
*
* This routine performs the hardware specific code to start the secondary
* core. It does so using two methods - using boot page translation register
* when first called. After this it uses CPU1_INIT_START_ADR to inform the
* second core where to jump to. The second core if reboot will wait until
* CPU1_INIT_START_ADR is set to something other than MP_MAGIC_RBV which is
* what this routines is doing. The success or failure of this routine cannot
* be determined here.
* This function is required for wrload.
*
* RETURNS: NONE
*
*/

void sysAmpCpuEnable(FUNCPTR entryPt,UINT32 cpu)
    {
        unsigned int oldint;
        oldint = intLock();
        VXSPARCDBG_PRINTF("sysAmpCpuEnable(%d)\n", cpu);
        intSmpStartCpu(cpu);
        intUnlock(oldint);
    }

/*****************************************************************************
*
* sysAmpCpuPrep - Prep cpuId for wrload download and start of AMP image
*
* This function is used by wrload to make a core ready for wrload to
* download and/or start a new image.  The state of the target cpu
* after this call is not specified, and is OS/arch/CPU specific.  If
* return is OK, then wrload should expect to succeed; if ERROR, then
* wrload will abort.
*
* arg argument currently unused, expected to provide finer grain control
* in the future.
*
* RETURNS: OK or ERROR
*
* ERRNO: N/A
*/

STATUS sysAmpCpuPrep
    (
    UINT32  cpuId,
    void * arg
    )
    {
    if (cpuId == 1)
	{
            VXSPARCDBG_PRINTF("sysAmpCpuPrep(%d)\n", cpuId);
	return OK;
	}

    /* Cannot prep core 0 or any other core */
    return ERROR;
    }

#endif /* INCLUDE_WRLOAD */

unsigned int sysAmpEn() {
#if defined(_WRS_VX_AMP)
    return 1;
#else
    return 0;
#endif
}

/*
Local Variables:
c-basic-offset:4
indent-tabs-mode:nil
End:
*/

