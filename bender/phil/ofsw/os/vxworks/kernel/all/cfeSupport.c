/*
** cFE Support routines
**
** This module is a collection of support routines needed to run the cFE on vxWorks.
**
*/

#include <stdio.h>
#include <string.h>
#include "vxWorks.h"
#include "taskLib.h"
#include "sysLib.h"
#include "symLib.h"
#include "loadLib.h"
#include "ioLib.h"
#include "dosFsLib.h"
#include "xbdBlkDev.h"
#include "errnoLib.h"
#include "usrLib.h"
#include "cacheLib.h"

/*
** External reference to wrs_kernel_text_start and wrs_kernel_text_end
** The cFE core needs these symbols, but when the cfe-core.o is loaded as a
** dynamic module, these symbols are not in the symbol table.
*/

extern unsigned int wrs_kernel_text_start;
extern unsigned int wrs_kernel_text_end;

/*
** External reference to the vxWorks symbol table
*/
extern SYMTAB_ID sysSymTbl;

/*
** Function: GetWrsKernelTextStart
** Purpose:  This function returns the start address of the kernel code.
**
*/
unsigned int GetWrsKernelTextStart (void)
{
    return (unsigned int) &wrs_kernel_text_start;
}

/*
** Function: GetWrsKernelTextEnd
** Purpose:  This function returns the end address of the kernel code.
**
*/
unsigned int GetWrsKernelTextEnd (void)
{
    return (unsigned int) &wrs_kernel_text_end;
}


/*
** Function: loadCfeCore
** Purpose:  This function unzips ( if needed ) , loads, and starts the cFE core.
**
*/
int startCfeCore (char *cfepath, int ModeId, char *StartupFilePath )
{
    int         fd;
    int         status;
    MODULE_ID   moduleID;
#if _WRS_VXWORKS_MAJOR==6 && _WRS_VXWORKS_MINOR==9
    SYMBOL_DESC symDesc;
#else
    SYM_TYPE   symType;
    char       *symValue;
#endif
    
    void        (*cFEFuncPtr)(int ModeId, char *StartupFilePath);

    if ( cfepath == NULL )
    {
       printf("Error: No cFE volume or path/filename given.\n");
       return(-1);
    }

    /*
    ** Open the cFE core module
    */
    fd = open( cfepath, O_RDONLY, 0);
    if ( fd < 0 )
    {
       printf("Error: Cannot open cFE core file: %s!\n", cfepath);
       return(-1);
    }
    else
    {
       printf("Opened %s.\n", cfepath);
    }

    /*
    ** Load the cFE core
    */
    moduleID = loadModule ( fd, LOAD_ALL_SYMBOLS );
    if ( moduleID == NULL )
    {
       printf("Error: Cannot load cFE core module.\n");
       close(fd);
       return(-1);
    }
    else
    {
       printf("Loaded %s module OK.\n",cfepath);
    }

    /*
    ** Close the file
    */
    close(fd);

    /*
    ** Lookup the cFE core entry point
    */
#if _WRS_VXWORKS_MAJOR==6 && _WRS_VXWORKS_MINOR==9
    memset(&symDesc,0,sizeof(SYMBOL_DESC));
    symDesc.mask = SYM_FIND_BY_NAME;
    symDesc.name = "CFE_PSP_Main";

    status = symFind(sysSymTbl, &symDesc);
    cFEFuncPtr = (void *)symDesc.value;
#else
    status = symFindByName(sysSymTbl, "CFE_PSP_Main", &symValue, &symType);
    cFEFuncPtr = (void *)symValue;
#endif
    
    if ( status == ERROR )
    {
        printf("Error: Cannot locate CFE_PSP_Main symbol.\n");
        return(-1);
    }

    /*
    ** Call the cFE startup routine
    */
     (*cFEFuncPtr)(ModeId, StartupFilePath);

    /*
    ** Return to the vxWorks shell
    */
    return(0);

}
