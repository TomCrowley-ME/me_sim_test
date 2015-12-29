/* dosFsLib.c - MS-DOS media-compatible file system library */

/*
 * Copyright (c) 1998-2011, 2012-2014 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify or otherwise make use
 * of this software may be licensed only pursuant to the terms
 * of an applicable Wind River license agreement.
 */

/*
modification history
--------------------
07t,04dec14,zly  reworks 07s for support 3rd format tool.
07s,25nov14,zly  Fix VXW6-83819, dosFsDiskProbe fails when testing a HRFS volume
07r,11nov14,m_y  add FIOFSTATFSGET64 command control (VXW6-83627)
07q,10nov14,zly  Fix VXW6-83271, fsync() confict with flush background task
07p,07nov14,yjl  Fix VXW6-82987, Setting file attributes requires a different
                 API using NFS
07o,18aug14,yjl  Fix VXW6-83274, Missing DosFs warning about spliting the
                 write buffer
07n,25feb14,xwu  fix VXW6-15687 DosFs documentation is missing the description
                 of the DOSFS_COMPAT_NT flag
07m,20nov13,ghs  Merge continuous trim block (WIND00439644)
07l,29oct13,xwu  cleanup of coverity issue remains
07k,14sep12,yjl  Fix WIND00376255, dosFs to be compatible with Windows FAT32
                 naming rules for file/directory name length
07j,25sep13,xwu  WIND00436386 medium impact coverity issue of FS
07i,13aug13,xwu  fix WIND00425358 iter26 fs branch issue: Incorrect dosfs mount
                 log was shown
07h,24may13,xwu  Remove xbdIoctl call in dosFsFileRW (WIND00337587)
07g,23may13,xwu  Fix WIND00416379 DosFs mount failure for some custom devices
07f,31jan13,xwu  Fix WIND00399792 dosFs flushTask does not write whole Cache to media
07e,24dec12,ghs  Fix WIND00391664, release semaphore before return
07d,07nov12,zly  Fix defect WIND00377570, dosFsClose miss return value with
                 cache enable
07c,10oct12,txu  fix WIND00348713: using cat command  on linux client with
                 vxworks server found error
07b,10aug12,yjl  Fix defect WIND00364508, To get correct block size from disk
                 and not always uses 512
07a,15dec11,txu  fix WIND00317695: copy many small files from nfs server will fail
06z,28sep11,ghs  fix compatibility issue for validate partition (WIND00288397)
06y,24jun11,y_t  req WIND00236547: improve nfs ls performance.
06x,13may11,yjl  Fix defect WIND00259953, dosFs: moving directory creates
                 bogus directory entries
06w,21dec10,yjl  fix defect WIND00173330, update doc for max path name, max file name.
06v,27jul10,sjz  fix defect WIND00224526, upgrade tiny cache for high performance
06u,06jul10,jxu  Restrict the 32-bit FIO commands to handle 32-bit values only,
                 and updated the comments. Changed the type of dosFsIoctl's
                 third argument from _Vx_usr_arg_t to _Vx_ioctl_arg_t.
06t,09jun10,j_l  Fix dosFsVolBufCreate() for LP64.
06s,24may10,yjl  Fix defect WIND00211042
06r,21apr10,yjl  fix defect WIND00208806
06q,30mar10,yjl  modify the prototype of dosFsRead() and dosFsWrite()
06p,18mar10,yjl  fix defect WIND00190080, modify dosFsTrunc
06o,05feb10,yjl  adaptation for 64bit merge
06n,15dec09,cww  Added include ffsLib.h
06m,04dec09,cww  Removed extern ffsMsb declaration
06u,05nov09,yjl  update iosDrvInstall() parameter type
06t,26oct09,yjl  remove ppc32 gnu warning in dosFsFillGap().
06s,13oct09,h_k  changed the arg type for dosFsIoctl.
06r,07oct09,h_k  fixed a wrong pointer casting to arg.
06q,30sep09,lyc  Fix WIND182473: Truncting file to 0 failed to
                 release start cluster
06p,27sep09,yjl  fix WIND00183327, wrong name length check in dosFsOpen()
06o,03sep09,hui  Fix WIND179839: The collection for FS and IO bug reported coverity
06n,17aug09,zly  Update document for dosSetVolCaseSens(WIND176312)
06m,31jul09,yjl  fix for WIND00173330 according to WINDOWS XP, in root
                 directory  the max length of file is 255, the max length of
                 directory is 244
06h,03sep09,yjl  fix ppc32 diab line6528 error,add (unsinged *) type cast
06g,29jul09,yjl  dosFs 64-bit
06l,22jul09,yjl  requirement WIND00142043, changes about dosfs cache
06k,13jul09,zly  replace DOS_VOLUME_BIO_BUFFER_SIZE
                 with dosFsVolumeBioBufferSize (WIND00161794)
06j,09jul09,yjl  remove warning
06i,18jun09,zly  printf()/logMsg() replace with PRINT_MSG()
06h,29apr09,hps  WIND00164451: miss one semGive volMemSemId
                 in dosFsXbdBytesRW()
06g,08dec08,yjl  WIND00145865 cp()/xcopy() does not work correctly when size
                 of source file is zero byte.
06f,16oct08,zly  Fixed SPR#112538, added a judgement for nBusyFd in
                 dosFsClose().

06e,12oct07,dcc  WIND00096046 fix.
06d,10oct07,act  fix WIND00099841: dosFsSeek optimization is too greedy
06c,11sep07,dcc  fix for WIND00086211
06b,09jul07,act  WIND00091022: rewrite dosFsFillGap
06a,29jun07,act  WIND00096598: rename can detach directories
05z,02may07,jon  SMP - widened the lock aound iosDevReplace
05x,03may07,pcm  fixed defect WIND00091025
05w,18apr07,jlk  Fixed defect WIND00090934. rename not working correctly.
05v,24apr07,pcm  applied corrections as per code review
05u,22jan07,jlk  Fix WIND00086422 - FIORMDIR
05t,17jan07,act  replace CBIO_DELETE with new FIODISCARD
05s,03nov06,pcm  modified Cache interfaces; added option to disable
                 secondary FAT's; replaced DISK to HOST macros with functions
05r,30aug06,pcm  tweaked some 64-bit comparisons
05q,30aug06,act  fix WIND00045106 (gcc warnings)
05p,21aug06,pcm  moved dosFsShow() to dosFsShow.c
05o,17aug06,kuo  added FIOUPDATE ioctl command and updated write-through and
                 auto-chkdisk mask constants to macros
05n,25jul06,kuo  split dosFsVolMount into two parts
05m,10may06,pcm  undid st_ino changes from version 05l and 05k
05l,09may06,pcm  changed method to set st_ino stat field
05k,26apr06,pcm  st_ino stat field set to  starting cluster in dosFsStatGet()
05j,10apr06,pcm  made dosFsDevCreate() NOMANUAL and changed parameter type
05i,03mar06,dcc  fixed SPR 117527
05h,15feb06,jlk  adjusted for 64 bit st_size in struct stat.
05g,23feb06,pcm  added FIOGETFL ioctl command (SPR 117517)
05f,13feb06,pcm  fixed GNU compiler warnings
05e,01feb06,dcc  fixed case where seeks fail because pFd->curSec is invalid.
05d,23jan06,dcc  optimized backwards seeks.
05c,16jan06,pcm  removed superfluous loads of tiny cache
05b,19oct05,dcc  updated documentation.
05a,03oct05,dcc  fixed memory leak when ejecting a volume with cache support.
04z,28sep05,dcc  added data cache support.
04y,20sep05,pcm  changed alignment checks to use DOS_VOLUME_DESC_ID type
04x,02sep05,jlk  fixed order of sub-component instantiation
04w,25aug05,pcm  added support for xbd stack completion
04v,12aug05,dcc  added testing for the existence of underlying xbd. Added
                 xbdEventMediaChanged event registration.
04u,11aug05,pcm  moved dosFsFmtRtn to funcBind.c
04t,05aug05,dcc  added cache creation to dosFsMonitorDevCreate(). updated
                 to call iosDevReplace() at volume creation time.
04s,04aug05,jlk  fixed bug in dosFsIsDirEmpty()
04r,03aug05,pcm  changed parameters to dosFsLibInit()
04p,02aug05,dcc  updated to use iosDevDelEnable() for delayed deletion.
04o,27jul05,jlk  Updated for ERF changes
04n,20jul05,dcc  miscellaneous cleanup: probe function to be reentrant,
                 instantiator to open and close before returning, etc.
04m,22jul05,jlk  added formatter function pointer, dosFsFmtRtn
04l,04jul05,dcc  incremented bio data buffer to hold 32 blocks.
04k,04jul05,dcc  apigen errors cleanup.
04j,04jul05,jlk  added event raising when path added to core I/O
04i,04jul05,jlk  changed default instantiation options to not check disk
04h,28jun05,dcc  updated xxxIoctl() routines to not assume anything when
                 command is for the underlying XBD. Added coherency between
                 block write/read and tiny cache.
04g,20jun05,dcc  fixed memory leak when a dosFs volume is deleted.
04f,24may05,dcc  added cache support.
04e,27may05,jlk  added support for unlink.
04d,19may05,dcc  added removability support.
04c,18apr05,dcc  updated dosFs formatter to work over rawFs.
04b,29apr05,pcm  FIORMDIR ioctl to only work on directories (SPR 70673)
04a,23mar05,dcc  fix for SPR# 92242: deadlock in dosFs.
03z,30mar05,dcc  updated to use several bios per volume.
03y,31jan05,dcc  modified to use XBD interface.
03x,22mar05,act  SPR#95005: reversed arguments to KHEAP_ALIGNED_ALLOC
03w,22mar05,dcc  fix SPR 92108: mutexes are not priority inversion safe.
03v,14feb05,rfr  Fixed failure condition in dosFsDevCreate()
03u,02feb05,dcc  fix SPR 91384: dosFsVolDescGet() cause "Page Fault" exception.
03t,04jan05,hya  removed ioFullFileNameGet in dosFsRename.
03s,07dec04,act  SPR #93888: mkdir of existing dir name should fail but does
                 not
03r,22nov04,rfr  Fixed cbio wrapper assignment in dosFsDevCreate()
03q,16nov04,jlk  SPR 93785, dosFsClose() no longer attempts to truncate a
                 file that has not been written to.
03p,15nov04,rfr  SPR 94067 & 94074, Fixed memory leaks in dosFsDevCreate
03o,09nov04,rfr  Added handling for FIOCOMMITFS, SPR
03n,07oct04,act  handle _FAPPEND; don't mash flags and mode together in lkup()
03m,04oct04,act  make dosFsSeek fix up curSec, and do seek before file-size
                 update in dosFsTrunc
03l,24sep04,act  back out changes for SPR#90008
03k,23sep04,feg  Extending ftruncate function.
03j,31aug04,feg  Coverity code coverage bugs #612, #635 and #458 of 2004-06-22
03i,11jun04,jyo  Fixing some doc errors.
03h,07may04,rfr  Fixed create with O_SYNC
03g,03may04,jkf  SPR#90008, adding device deletion routine
03f,02may04,jkf  fixed SPR#87245
03e,01may04,jkf  fixed SPR#89242, dosFsSeek() truncates 64 bit
03d,27apr04,jyo  Fixing SPR 96796: dosFsWrite is returning STATUS instead of
                 bytes.
03c,18apr04,act  fix documentation and add Unicode flag
03b,21mar04,act  changes to support clean bit
03a,19mar04,jyo  Fixing documentation data.
02z,09mar04,jkf  fixing doc errors
02y,25feb04,rfr  Added support for O_SYNC
02x,21dec03,jkf  warning cleanup
02w,23sep03,jkf  correcting doc build error
02v,02sep03,jkf  rename autoChkLevel to dosDevCreateOptions (write through)
02u,31jan03,jkf  SPR#85305, flush cache after chkdsk repair,
                 SPR#28428/82911 sync fats before vol unmount.
                 SPR#82414, FIOTIMESET doc markup error
                 SPR#76352, sync fat copy on dir create in dosFsCloseon
                 dir create in dosFsClose
02t,10jan03,jkf  Adding fsize_t cast to SPR#81268 fix per SPR#79703
                 upped copyright to 2003.
02s,14oct02,jkf  SPR#79703, seek over 4GB failed.
02r,06sep02,jkf  Fixed SPR#81268, introduced in 30540 fix.
                 Also fixes corruption when seek of sector size multiple
                 when positioned upon the end of a sector.
02q,02may02,jkf  Corrects SPR#76501, 72603. Avoids 65085 and 33221.
                 and a performance improvement for FIOSYNC.
02p,30apr02,jkf  SPR#62786, rename should preserve time and date fields
02o,30apr02,jkf  SPR#76510, dosFsVolDescGet() should return NULL instead of
                 the default device when the underlying iosDevFind() does.
02n,15Jan02,chn  SPR#29751, removed path case sensitivity during creat phase
                 of rename. Possible NFS interaction, see comments at change.
02m,18dec01,chn  SPR#71105, correct file size in dosFsContigAlloc & comment
02l,12dec01,jkf  SPR#72133, add FIOMOVE and fixing diab build warnings.
02k,10dec01,jkf  SPR#24332, dont delete existing files or dirs in dosFsRename
02j,10dec01,jkf  SPR#72039, various fixes from Mr. T. Johnson.
02i,09dec01,jkf  SPR#71637, fix for SPR#68387 caused ready changed bugs.
02h,30nov01,jkf  SPR#68203, updating last access date on open-read-close
                 operation causes unwanted writes, increasing flash wear.
02g,30nov01,jkf  SPR#33343, media unformatted or missing err better reported.
                 SPR#69074, statfs to invalid media caused continuous errors.
02f,15nov01,jkf  SPR#71720, avoid unaligned pointer access.
                 clean up multiple errno's when mounting unformatted volume.
02e,13nov01,jkf  correct typo in checkin comment.
02d,13nov01,jkf  improve dosFsBootSecGet() error message, add a comment about
                 nBlocks reporting total blocks, not last addressable block.
02c,10nov01,jkf  SPR#67890, chkdsk writes to RDONLY device
02b,09nov01,jkf  SPR#71633, dont set errno when DevCreate is called w/BLK_DEV
                 SPR#32178, made dosFsVolDescGet public, cleaned up man page.
                 SPR#33684, dosFsShow reporting incorrect verbosity setting.
02a,23oct01,rip  SPR#65085: tasks in FIOSYNC interlocking (dup of #33221 cf 01v)
                 SPR#30464: FIONCONTIG64 not shifting using 64bit math
                 SPR#30540: FillGap assumes step over sector on FIOSEEK > EOF
01z,21aug01,jkf  SPR#69031, common code for both AE & 5.x.
01y,26jul01,jkf  T2 SPR#65009, T3 SPR#65271.  dosFsLibInit returns OK or ERROR.
01x,14mar01,jkf  SPR#34704,FAT12/FAT16 determination, SPR#62415 sig location.
01w,19sep00,csh  Manual Merge From Alameda Branch To Sunnyvale Branch
01v,08sep00,nrj  fixed SPR#33221, to avoid dead-lock because of multiple tasks
                 doing FIOSYNC on opened files
                 fixed SPR#33702, 33684, The autocheck verbosity is now
                 initialized properly in volume descriptor.
01u,29feb00,jkf  cleaning warning.

01t,29feb00,jkf  T3 changes.
01s,28sep99,jkf  fixed SPR#28554, now return error on write to full disk.
01r,31aug99,jkf  changes for new CBIO API.  Changed FIOTIMESET to allow
                 utime to follow Solaris 2.6 behavior.  If arg is NULL,
                 the current time is used, added docs. SPR#28924
01q,06aug99,jkf  delete existing file when dosFsOpen uses O_CREAT/O_TRUNC
                 do not overflow read buffer on truncated files, SPR#28309
01p,31jul99,jkf  Dont allow larger than 4GB file on anything but
                 VXLONGNAMES directory entry files. SPR#27532.
01o,31jul99,jkf  Added support for FSTYPE (0x36) in bootsec, SPR#28273
01n,31jul99,jkf  T2 merge, tidiness & spelling.
01m,03dec98,vld  fixed SPR #23692: added FIOTRUNC64 ioctl code;
                 rd/wr time measurement excluded
01l,22nov98,vld  included  features required by NFS protocol:
                  - added support for FIOFSTATFSGET ioctl code;
                  - added support for creating files "with holes";
                  - added dosFsSeekDir() routine and controlling
                    of dd_cookie field within FIOREADDIR
01k,28sep98,vld  gnu extensions dropped from DBG_MSG/ERR_MSG macros
01j,24sep98,vld  added support for FIOTIMESET ioctl code
01i,16sep98,vld  created separate routine dosFsChkDsk() to solve
hen-and-egg problem during volume mounting and
                 external call for disk check operation.
01h,16sep98,vld  added support for read only devices
01j,11sep98,vld  added support for non CBIO ptr argument in dosFsDevCreate().
01i,26aug98,vld  ignore mode = S_IFDIR except with O_CREAT (SPR#22227)
01h,30jul98,wlf  partial doc cleanup
01g,27jul98,vld  fixed FIOWHERE64  return
01f,08jul98,vld  print64Lib.h moved to h/private directory.
01e,08jul98,vld  dosFsContigAlloc() (FIOCONTIG effected) changed
                 not to zero allocated data and leave file size as 0
01d,08jul98,vld  fixed bug in dosFsContigAlloc()
                 added counting sectors per file count for CONTIG_MAX case.
01c,30jun98,lrn  renamed dosFsInit to dosFsLibInit
01b,28jun98,vld  tested, checked in, ready for EAR
01a,18jan98,vld  written, preliminary
*/

/*
INTERNAL: MS-DOS is a registered trademark of Microsoft Corporation.

DESCRIPTION
This library implements the MS-DOS compatible file system.
This is a multi-module library, which depends on sub-modules to
perform certain parts of the file system functionality.
A number of different file system format variations are supported.

USING THIS LIBRARY
The various routines provided by the VxWorks DOS file system (dosFs) may be
separated into three broad groups: general initialization, device
initialization, and file system operation.

The dosFsLibInit() routine is the principal initialization function; it should
be called once during system initialization, regardless of how many dosFs
devices are to be used.

Another dosFs routine is used for device initialization.
For each dosFs device, dosFsDevCreate() must be called to install the
device in VxWorks device list.
In the case where partitioned disks are used, dosFsDevCreate() must be
called for each partition that is anticipated, thereby it is associated
with a logical device name, so it can be later accessed via the I/O
system. Note that starting from VxWorks 6.2, the job of instantiating file
systems is done automatically by the File System Monitor module, either at
boot time or whenever removable media is inseted in the system (such as
a floppy disk or a USB device). Please refer to the File System Monitor
documentation for further details.

In case of a removable media, device access and file system instantiation
will be done only when the logical device is first accessed by the application.

More detailed information on all of these routines is provided below.

INITIALIZING DOSFSLIB
To enable this file system in a particular VxWorks configuration,
a library initialization routine must be called for each sub-module of
the file system, as well as for the underlying disk cache, partition
manager and drivers.
This is usually done at system initialization time, within the
.I usrRoot
task context.

Following is the list of initialization routines that need to be
called:
.IP dosFsLibInit
(mandatory) initialize the principle dosFs module. Must be called first.
.IP dosFsFatInit
(mandatory) initialize the File Allocation Table handler, which supports
12-bit, 16-bit and 32-bit FATs.
.IP dosVDirLibInit
(choice) install the variable size directory handler
supporting Windows-compatible Long File Names (VFAT) Directory
Handler.
.IP dosDirOldLibInit
(choice) install the fixed size  directory handler
which supports read-only access to old-fashioned 8.3
MS-DOS file names, and Wind River Systems proprietary long file names
(VXLONG).
.IP dosFsFmtLibInit
(optional) install the volume formatting module.
.IP dosChkLibInit
(optional) install the file system consistency checking module.
.IP dosFsCacheLibInit
(optional) install the file system cacheing module.
.LP
The two Directory handlers which are marked
.I choice
are installed in accordance with the system requirements, either one
of these modules could be installed or both, in which case the VFAT will
take precedence for MS-DOS compatible volumes.


DEFINING A DOSFS DEVICE
The dosFsDevCreate() routine associates a device with the dosFsLib
functions.  It expects four parameters:
.IP "(1)" 4
A pointer to a name string, to be used to identify the device - logical
device name.
This will be part of the pathname for I/O operations which operate on the
device.  This name will appear in the I/O system device table, which may be
displayed using the iosDevShow() routine.
.IP "(2)"
device_t - a XBD for the device on which to create the file system. It could
be a partition XBD, an XBD block wrapper, or an ATA device XBD for example.
.IP "(3)"
A maximum number of files can be simultaneously opened on a particular device.
.IP "(4)"
Flags for volume checking, metadata integrity, and file name interpretation.
Because volume integrity check utility can be automatically
invoked every time a device is mounted,
this parameter indicates whether the consistency check needs to be
performed automatically on a given device, and on what level of
verbosity is required.
In any event, the consistency check may be invoked at a later time
e.g. by calling chkdsk().
See description for FIOCHKDSK ioctl command for more information.
.LP
For example:
.CS
    dosFsDevCreate
    (
    "/sd0",     /@ name to be used for volume   @/
    device,      /@ underlying XBD device @/
    10,     /@ max no. of simultaneously open files @/
    DOS_CHK_REPAIR | DOS_CHK_VERB_1
            /@ check volume during mounting and repair @/
            /@ errors, and display volume statistics @/
    )
.CE

Once dosFsDevCreate() has been called, the device can be accessed
using
.I ioLib
generic I/O routines: open(), read(), write(), close(),
ioctl(), remove(). Also, the user-level utility functions may be used to
access the device at a higher level (See usrFsLib reference page for
more details).

DEVICE AND PATH NAMES
On true MS-DOS machines, disk device names are typically of the form "A:",
that is, a single letter designator followed by a colon.  Such names may be
used with the VxWorks dosFs file system.  However, it is possible (and
desirable) to use longer, more mnemonic device names, such as "DOS1:",
or "/floppy0".
The name is specified during the dosFsDevCreate() call. Since most of the time
the call to this routine is done automatically by the File System Monitor
module, fsmNameInstall() can be called prviously to specify the desired
name for the device. Please refer to the fsMonitor documentation for
further details.

The pathnames used to specify dosFs files and directories may use either
forward slashes ("/") or backslashes ("\e") as separators.  These may be
freely mixed.  The choice of forward slashes or backslashes has absolutely
no effect on the directory data written to the disk.  (Note, however, that
forward slashes are not allowed within VxWorks dosFs filenames, although
they are normally legal for pure MS-DOS implementations.)

Use of forward slashes ("/") is recommended at all times.

The leading slash of a dosFs pathname following the device name is
optional.  For example, both "DOS1:newfile.new" and "DOS1:/newfile.new"
refer to the same file.

USING EXTENDED DIRECTORY STRUCTURE
This library supports DOS4.0 standard file names which fit the restrictions
of eight upper-case characters optionally followed by a three-character
extension,
as well as Windows style VFAT standard long file names
that are stored mixed cased on disk, but are case insensitive when
searched and matched (e.g. during open() call).
The VFAT long file name is stored in a variable number of consecutive
directory entries.
Both standards restrict file size to 4 GB (32 bit value).

To provide additional flexibility, this implementation of the
DOS file system provides proprietary long file name format (VXLONGNAMES),
which uses a simpler directory structure: the directory entry is
of fixed size.  When this option is
used, file names may consist of any sequence of up to 40 ASCII
characters.  No case conversion is performed,
and file name match is case-sensitive.
With this directory format the
file maximum size is expanded to 1 Terabyte (40 bit value). This option
only supports read-only access to files in the VxWorks 6.2 version though.

.RS 4 4
NOTE:  Because special directory entries are used on the disk, disks
which use the extended names are
.I not
compatible with other implementation of the
MS-DOS systems, and cannot be read on MS-DOS or Windows machines.
.RE

To enable the extended file names, set the DOS_OPT_VXLONGNAMES flag
when calling dosFsVolFormat().

USING UNICODE CHARACTERS
When Unicode characters are in use, they are encoded in UTF-8 through
the the open() and readdir() interface, and in Windows-compatible
UTF-16 format on-disk.  The translation between external (UTF-8)
and internal (UTF-16) encodings is automatic, avoiding all the
byte-order problems associated with UTF-16 encodings.

Existing VxWorks file systems that use "high bit" characters (such
as ISO Latin 1 character sets) are not compatible with Unicode
encodings.  For this reason, Unicode file names must currently
be enabled explicitly using the DOS_FILENAMES_UNICODE flag.

Unicode is only supported on VFAT (variable-length file name) volumes.

READING DIRECTORY ENTRIES
Directories on VxWorks dosFs volumes may be searched using the opendir(),
readdir(), rewinddir(), and closedir() routines.  These calls allow the
names of files and subdirectories to be determined.

To obtain more detailed information about a specific file, use the fstat()
or stat() routine.  Along with standard file information, the structure
used by these routines also returns the file attribute byte from a dosFs
directory entry.

For more information, see the manual entry for dirLib.

SYNCHRONOUS FILES
Files can be opened with the O_SYNC flag, indicating that each write
should be immediately written to the backing media. This includes
synchronizing the FAT and the directory entries.

FILE DATE AND TIME
Directory entries on dosFs volumes contain creation, last modification
time and date, and the last access date for each file or subdirectory.
Directory last modification time and date fields are set only when
a new entry is created, but not when any directory entries are deleted.
The last access date field indicates the date of the last read or write.
The last access date field is an optional field, per Microsoft.  By
default, file open-read-close operations do not update the last access
date field.  This default avoids media writes (writing out the date field)
during read only operations.   In order to enable the updating of the
optional last access date field for open-read-close operations, you must
call dosFsLastAccessDateEnable(), passing it the volumes DOS_VOLUME_DESC_ID
and TRUE.

The dosFs file system uses the ANSI time() function, that returns
system clock value to obtain date and time.  It is recommended that the
target system should set the system time during system initialization
time from a network server or from an embedded Calendar / Clock
hardware component, so that all files on the file system would be
associated with a correct date and time.

The file system consistency checker (see below) sets system clock to
value following the latest date-time field stored on the disk, if it
discovers, that function time() returns a date earlier then Jan 1,
1998, meaning that the target system does not have a source of valid
date and time to synchronize with.

See also the reference manual entry for ansiTime.

FILE ATTRIBUTES
Directory entries on dosFs volumes contain an attribute byte consisting
of bit-flags which specify various characteristics of the entry.  The
attributes which are identified are:  read-only file, hidden file,
system file, volume label, directory, and archive.  The VxWorks symbols
for these attribute bit-flags are:

.IP DOS_ATTR_RDONLY
File is write-protected, can not be modified or deleted.
.IP DOS_ATTR_HIDDEN
this attribute is not used by VxWorks.
.IP DOS_ATTR_SYSTEM
this attribute is not used by VxWorks.
.IP DOS_ATTR_VOL_LABEL
directory entry describes a volume label,
this attribute can not be set or used directly, see ioctl() command
FIOLABELGET and FIOLABELSET below for volume label manipulation.
.IP DOS_ATTR_DIRECTORY
directory entry is a subdirectory,
this attribute can not be set directly.
.IP DOS_ATTR_ARCHIVE
this attribute is not used by VxWorks.

.LP
All the flags in the attribute byte, except the directory and volume label
flags, may be set or cleared using the ioctl() FIOATTRIBSET function.  This
function is called after opening the specific file whose attributes are to
be changed.  The attribute byte value specified in the FIOATTRIBSET call is
copied directly.  To preserve existing flag settings, the current attributes
should first be determined via fstat(), and the appropriate
flag(s) changed using bitwise AND or OR operations.  For example, to make
a file read-only, while leaving other attributes intact:

.CS
    struct stat fileStat;

    fd = open ("file", O_RDONLY, 0);     /@ open file          @/
    fstat (fd, &fileStat);               /@ get file status    @/

    ioctl (fd, FIOATTRIBSET, (fileStat.st_attrib | DOS_ATTR_RDONLY));
                                         /@ set read-only flag @/
    close (fd);                          /@ close file         @/
.CE
.LP
See also the reference manual entry for attrib() and xattrib() for
user-level utility routines which control the attributes of files or
file hierarchy.

CONTIGOUS FILE SUPPORT
The VxWorks dosFs file system provides efficient files storage:
space will be allocated in groups of clusters (also termed
.I extents
) so that a file will be composed of relatively large contiguous units.
This  nearly contiguous allocation technique is designed to
effectively eliminate the effects of disk space fragmentation,
keeping throughput very close to the maximum of which the hardware is
capable.

However dosFs provides mechanism to allocate truly contiguous files,
meaning files which are made up of a consecutive series of disk sectors.
This support includes both the ability to allocate contiguous space to a file
and optimized access to such a file when it is used.
Usually this will somewhat improve performance when compared to
Nearly Contiguous allocation, at the price of disk space fragmentation.

To allocate a contiguous area to a file, the file is first created in the
normal fashion, using open() or creat().  The file descriptor returned
during the creation of the file is then used to make an ioctl() call,
specifying the FIOCONTIG or FIOCONTIG64 function.
The last parameter to the FIOCONTIG function is the size of the requested
contiguous area in bytes, If the FIOCONTIG64 is used, the last parameter
is pointer to 64-bit integer variable, which contains the required file size.
It is also possible to request that the largest contiguous free area on
the disk be obtained.  In this case, the size value CONTIG_MAX (-1)
is used instead of an actual size.  These ioctl() codes
are not supported for directories.
The volume is searched for a contiguous area of free space, which
is assigned to the file. If a segment of contiguous free space
large enough for the request was not found,
ERROR is returned, with <errno> set to  S_dosFsLib_NO_CONTIG_SPACE.

When contiguous space is allocated to a file, the file remains empty,
while the newly allocated space has not been initialized.
The data should be then written to the file, and eventually, when
all data has been written, the file is closed.
When file is closed, its space is truncated to reflect the amount
of data actually written to the file.
This file may then be again opened and used for further
I/O operations read() or write(),
but it can not be guaranteed that appended data will be contiguous
to the initially written data segment.

For example, the following will create a file and allocate 85 Mbytes of
contiguous space:
.CS
    fd = creat ("file", O_RDWR, 0);             /@ open file             @/
    status = ioctl (fd, FIOCONTIG, 85*0x100000);/@ get contiguous area   @/
    if (status != OK)
       ...                                      /@ do error handling     @/
    close (fd);                                 /@ close file            @/
.CE

In contrast, the following example will create a file and allocate the
largest contiguous area on the disk to it:

.CS
    fd = creat ("file", O_RDWR, 0);             /@ open file             @/
    status = ioctl (fd, FIOCONTIG, CONTIG_MAX); /@ get contiguous area   @/
    if (status != OK)
       ...                                      /@ do error handling     @/
    close (fd);                                 /@ close file            @/
.CE

.IP NOTE
the FIOCONTIG operation should take place right after the file has been
created, before any data is written to the file.
Directories may not be allocated a contiguous disk area.
.LP
To determine the actual amount of contiguous space obtained when CONTIG_MAX
is specified as the size, use fstat() to examine the number of blocks
and block size for the file.

When any file is opened, it may be checked for contiguity.
Use the extended flag DOS_O_CONTIG_CHK when calling open() to access an
existing file which may have been allocated contiguous space.
If a file is detected as contiguous, all subsequent operations on the
file will not require access to the File Allocation Table, thus
eliminating any disk Seek operations.
The down side however is that if this option is used, open() will take
an amount of time which is linearly proportional of the file size.

CHANGING, UNMOUNTING, AND SYNCHRONIZING DISKS
Buffering of disk data in RAM, and synchronization of these
buffers with the disk are handled by the disk cache. See reference manual on
dosFsCacheLib for more details. Detection of removable disk replacement
is done by the File System Monitor subsystem.

If a disk is physically removed, the File System Monitor subsystem will
delete the filesystem entry from coreIO and free all its allocated resources,
including disk cache buffers.

If a new DOS FS formatted disk is inserted, it will be detected by the File
System Monitor subsystem and a DOS FS filesystem will be automatically created
with the name previously registered through  a call to fsmNameInstall() (or
a default name will be assigned), and with the global parameters
DOSFS_DEFAULT_MAX_FILES, DOSFS_DEFAULT_CREATE_OPTIONS, and if disk cache is
supported (see dosFsCacheLib for details), with a DOSFS_DEFAULT_CACHE_SIZE
cache.

IOCTL FUNCTIONS
The dosFs file system supports the following ioctl() functions.  The
functions listed are defined in the header ioLib.h.  Unless stated
otherwise, the file descriptor used for these functions may be any file
descriptor which is opened to a file or directory on the volume or to
the volume itself.
There are some ioctl() commands, that expect a 32-bit integer result
(FIONFREE, FIOWHERE, etc.).
However, disks and files which are greater than 4GB are supported.
In order to solve this problem, new ioctl() functions have been added
to support 64-bit integer results.
They have the same name as basic functions, but with suffix
.I 64,
namely: FIONFREE64, FIOWHERE64 and so on. These commands
expect a pointer to a 64-bit integer, i.e.:
.CS
long long *arg ;
.CE
as the 3rd argument to the ioctl() function.
If a value which is requested with a 32-bit ioctl() command is
too large to be represented in the 32-bit variable, ioctl() will return
ERROR, and <errno> will be set to S_dosFsLib_32BIT_OVERFLOW.

.iP "FIOUNMOUNT"
Unmounts a disk volume.  It performs the same function as dosFsVolUnmount().
This function must not be called from interrupt level:
.CS
    status = ioctl (fd, FIOUNMOUNT, 0);
.CE

.iP "FIOGETNAME"
Gets the file name of the file descriptor and copies it to the buffer <nameBuf>.
Note that <nameBuf> must be large enough to contain the largest possible
path name.
.CS
    status = ioctl (fd, FIOGETNAME, &nameBuf);
.CE

.iP "FIORENAME"
Renames the file or directory to the string <newname>:
.CS
    fd = open("oldname", O_RDONLY, 0);
    status = ioctl (fd, FIORENAME, "newname");
.CE

.iP "FIOUPDATE"
Updates the dosFs create options to the new value <newoptions>
.CS
    int newOptions;
    status = ioctl (fd, FIOUPDATE, newOptions);
.CE

.iP "FIOMOVE"
Moves the file or directory to the string <newname>:
.CS
    fd = open("oldname", O_RDONLY, 0);
    status = ioctl (fd, FIOMOVE, "newname");
.CE

.iP "FIOSEEK"
Sets the current byte offset in the file to the position specified by
<newOffset>. This function supports offsets range from 0 to UINT_MAX.
Use FIOSEEK64 for larger offset:
.CS
    status = ioctl (fd, FIOSEEK, newOffset);
.CE

.iP "FIOSEEK64"
Sets the current byte offset in the file to the position specified by
<newOffset>. This function supports offsets in 64-bit value range:
.CS
    long long   newOffset = ...;
    status = ioctl (fd, FIOSEEK64, (_Vx_ioctl_arg_t) & newOffset);
.CE

.iP "FIOWHERE"
Returns the current byte position in the file. This is the
byte offset of the next byte to be read or written.
This function returns a 32-bit value range from 0 to UINT_MAX - 1,
and returns ERROR(-1) on failure.
It takes no additional argument:
.CS
    position = ioctl (fd, FIOWHERE, 0);
.CE

.iP "FIOWHERE64"
Returns the current byte position in the file. This is the
byte offset of the next byte to be read or written.
This function returns a 64-bit value in <position>:
.CS
    long long position = 0;
    status = ioctl (fd, FIOWHERE64, (_Vx_ioctl_arg_t) & position);
.CE

.iP "FIOFLUSH"
Flushes disk cache buffers.  It guarantees that any output that has
been requested is actually written to the device:
.CS
    status = ioctl (fd, FIOFLUSH, 0);
.CE

.iP "FIOSYNC"
Updates the FAT copy for the passed file descriptor, then
flushes and invalidates the dosFs cache buffers for the file
descriptor's volume.  FIOSYNC ensures that any outstanding
output requests for the passed file descriptor are written
to the device and a subsequent I/O operation will fetch data
directly from the physical medium.  To safely sync a volume
for shutdown, all open file descriptor's should at the least
be FIOSYNC'd by the application.  Better, all open FD's should
be closed by the application and the volume should be unmounted
via FIOUNMOUNT.
.CS
    status = ioctl (fd, FIOSYNC, 0);
.CE

.iP "FIOTRUNC"
Sets the specified file's length to <newLength> bytes, supports 32-bit length
range from 0 to UINT_MAX.
Any disk clusters which had been allocated to the file but are now unused are
deallocated while additional clusters are zeroed, and the directory entry for
the file is updated to reflect the new length.  Only regular files may
be truncated; attempts to use FIOTRUNC on directories will return an error.
.CS
    status = ioctl (fd, FIOTRUNC, newLength);
.CE

.iP "FIOTRUNC64"
Similar to FIOTRUNC, but can be used for files larger, than 4GB.
.CS
    long long newLength = .....;
    status = ioctl (fd, FIOTRUNC, (_Vx_ioctl_arg_t) & newLength);
.CE

.iP "FIONREAD"
Copies to <unreadCount> the number of unread bytes in the file,
if the number of unread bytes may exceed UINT_MAX, use FIONREAD64 instead:
.CS
    unsigned int unreadCount = 0;
    status = ioctl (fd, FIONREAD, (_Vx_ioctl_arg_t)&unreadCount);
.CE
.iP "FIONREAD64"
Copies to <unreadCount> the number of unread bytes in the file.
This function returns a 64-bit integer value:
.CS
    long long unreadCount = 0;
    status = ioctl (fd, FIONREAD64, (_Vx_ioctl_arg_t)&unreadCount);
.CE
.iP "FIONFREE"
Copies to <freeCount> the amount of free space, in bytes, on the volume:
.CS
   unsigned int freeCount = 0;
   status = ioctl (fd, FIONFREE, (_Vx_ioctl_arg_t)&freeCount);
.CE
.iP "FIONFREE64"
Copies to <freeCount> the amount of free space, in bytes, on the volume.
This function can return value in 64-bit range:
.CS
   long long freeCount = 0;
   status = ioctl (fd, FIONFREE64, &freeCount);
.CE
.iP "FIOMKDIR"
Creates a new directory with the name specified as <dirName>:
.CS
    status = ioctl (fd, FIOMKDIR, "dirName");
.CE
.iP "FIORMDIR"
Removes the directory whose name is specified as <dirName>:
.CS
    status = ioctl (fd, FIORMDIR, "dirName");
.CE
.iP "FIOLABELGET"
Gets the volume label (located in root directory) and copies the string to
<labelBuffer>. If the label contains DOS_VOL_LABEL_LEN significant
characters, resulting string  is not NULL terminated:
.CS
    char    labelBuffer [DOS_VOL_LABEL_LEN];
    status = ioctl (fd, FIOLABELGET, (_Vx_ioctl_arg_t)labelBuffer);
.CE
.iP "FIOLABELSET"
Sets the volume label to the string specified as <newLabel>.  The string may
consist of up to eleven ASCII characters:
.CS
    status = ioctl (fd, FIOLABELSET, (_Vx_ioctl_arg_t)"newLabel");
.CE
.iP "FIOATTRIBSET"
Sets the file attribute byte in the DOS directory entry to the new value
<newAttrib>.  The file descriptor refers to the file whose entry is to be
modified:
.CS
    status = ioctl (fd, FIOATTRIBSET, newAttrib);
.CE
.iP "FIOCONTIG"
Allocates contiguous disk space for a file or directory.  The number of
bytes of requested space is specified in <bytesRequested>, it should be
neither larger than UINT_MAX, nor negative values.  In general,
contiguous space should be allocated immediately after the file is
created:
.CS
    status = ioctl (fd, FIOCONTIG, bytesRequested);
.CE
.iP "FIOCONTIG64"
Allocates contiguous disk space for a file or directory.  The number of
bytes of requested space is specified in <bytesRequested>.  In general,
contiguous space should be allocated immediately after the file is
created. This function accepts a 64-bit value:
.CS
    long long bytesRequested = 0;
    status = ioctl (fd, FIOCONTIG64, &bytesRequested);
.CE
.iP "FIONCONTIG"
Copies to <maxContigBytes> the size of the largest contiguous free space,
in bytes, on the volume:
.CS
    unsigned int maxContigBytes = 0;
    status = ioctl (fd, FIONCONTIG, &maxContigBytes);
.CE
.iP "FIONCONTIG64"
Copies to <maxContigBytes> the size of the largest contiguous free space,
in bytes, on the volume. This function returns a 64-bit value:
.CS
    long long maxContigBytes = 0;
    status = ioctl (fd, FIONCONTIG64, &maxContigBytes);
.CE
.iP "FIOREADDIR"
Reads the next directory entry.  The argument <dirStruct> is a DIR
directory descriptor.  Normally, the readdir() routine is used to read a
directory, rather than using the FIOREADDIR function directly.  See dirLib.
.CS
    DIR dirStruct;
    fd = open ("directory", O_RDONLY);
    status = ioctl (fd, FIOREADDIR, &dirStruct);
.CE
.iP "FIOFSTATGET"
Gets file status information (directory entry data).  The argument
<statStruct> is a pointer to a stat structure that is filled with data
describing the specified file.  Normally, the stat() or fstat() routine is
used to obtain file information, rather than using the FIOFSTATGET
function directly.  See dirLib.
.CS
    struct stat statStruct;
    fd = open ("file", O_RDONLY);
    status = ioctl (fd, FIOFSTATGET, (int)&statStruct);
.CE
.iP "FIOTIMESET"
Update time on a file.   <arg> shall be a pointer to a utimbuf structure,
see utime.h.  If <arg> is value NULL, the current system time is used for
both actime and modtime members.  If <arg> is not NULL then the utimbuf
structure members actime and modtime are used as passed.  If actime is
zero value, the file access time is not updated (the operation is ignored).
If modtime is zero, the file modification time is not updated (the operation
is ignored).
See also utime()
.CS
    struct utimbuf newTimeBuf;;
    newTimeBuf.modtime = newTimeBuf.actime = fileNewTime;
    fd = open ("file", O_RDONLY);
    status = ioctl (fd, FIOTIMESET, (_Vx_ioctl_arg_t)&newTimeBuf);
.CE
.iP "FIOCHKDSK"
This function invokes the integral consistency checking.
During the test, the file system will be blocked from application code
access, and will emit messages describing any inconsistencies found on
the disk, as well as some statistics, depending on the verbosity
level in the <flags> argument.
Depending on the repair permission value in <flags> argument,
the inconsistencies will be repaired, and changes written to disk
or only reported.
Argument <flags> should be composed of bitwise or-ed
verbosity level value and repair permission value.
Possible repair levels are:
.RS
.iP "DOS_CHK_ONLY (1)"
Only report errors, do not modify disk.
.iP "DOS_CHK_REPAIR (2)"
Repair any errors found.
.LP
Possible verbosity levels are:
.iP "DOS_CHK_VERB_SILENT (0xff00)"
Do not emit any messages, except errors encountered.
.iP "DOS_CHK_VERB_1 (0x0100)"
Display some volume statistics when done testing, as well
.iP "DOS_CHK_VERB_2 (0x0200)"
In addition to the above option, display path of every file, while it
is being checked. This option may significantly slow down the test
process.
.IP "NOTE"
In environments with reduced RAM size check disk uses reserved
FAT copy as temporary buffer, it can cause respectively long
time of execution on a slow CPU architectures..
.LP
.RE
See also the reference manual usrFsLib for the chkdsk() user level
utility which may be used to invoke the FIOCHKDSK ioctl().
The volume root directory should be opened, and the resulting file
descriptor should be used:
.CS
    int fd = open (device_name, O_RDONLY, 0);
    status = ioctl (fd, FIOCHKDSK, DOS_CHK_REPAIR | DOS_CHK_VERB_1);
    close (fd);
.CE
.LP
Any other ioctl() function codes are passed to the underlying
.I XBD
modules for handling.

INCLUDE FILES: dosFsLib.h

SEE ALSO:
ioLib, iosLib, dirLib, usrFsLib, dosFsCacheLib, dosFsFmtLib,
dosChkLib
.I "Microsoft MS-DOS Programmer's Reference"
(Microsoft Press),
.I "Advanced MS-DOS Programming"
(Ray Duncan, Microsoft Press),
.I "VxWorks Programmer's Guide: I/O System, Local File Systems"

CAUTION: dosFs file names are limited to 255 characters, not including
the trailing NUL. The total path length cannot exceed 1024 characters,
including the trailing NUL. While dosFs supports path names of 1024 characters,
using a path name of more than 259 characters makes it incompatible with Windows
(that is, the file cannot be used on a Windows host).

If DOSFS_COMPAT_NT(directory entry NT flag compatibility with Windows, only used
for FAT32) is set TRUE, then VxWorks will has same explanation about the field
(offset 0x0c of directory entry) with Windows NT. Otherwise, VxWorks keep the same
explanation with legacy version.
Below is detail info for this.
The field which is offset 0x0c of directory entry offset. It is always 0x00 for VFAT LFN,
other values reserved for future use; for special usage of bits 4 and 3 in SFNs. Windows
NT and later versions uses bits 3 and 4 to encode case information.
If a filename contains only lowercase letters, or is a combination of a lowercase basename
with an uppercase extension, or vice-versa; and has no special characters, and fits within
the 8.3 limits, a VFAT entry is not created on Windows NT and later versions of Windows such
as XP. Instead, two bits in byte 0x0C of the directory entry are used to indicate that the
filename should be considered as entirely or partially lowercase. Specifically, bit 4 means
lowercase extension and bit 3 lowercase basename, which allows for combinations such as
"example.TXT" or "HELLO.txt" but not "Mixed.txt". Few other operating systems support it.
This creates a backwards-compatibility problem with older Windows versions
(Windows 95 / 98 / 98 SE / ME) that see all-uppercase filenames if this extension has been
used, and therefore can change the name of a file when it is transported between operating
systems, such as on a USB flash drive.

If DosFs cache component can not be included due to some project/hardware
requirements, to increase DOSFS_DEFAULT_VOL_BIO_BUFFER_SIZE can gain performance.
Meanwhile another parameter(number of sectors per cluster) is needed to be changed.
If this parameter is left to default, then the write buffer will be split into
smaller ones in some situation. To call dosFsVolFormat() with _func_FormatPrompt
and a bigger secPerClust can change it.

INTERNAL:
Note:  To represent a backslash in documentation use "\e", not "\\".
The double backslash sometimes works, but results may be unpredictable.
*/

/* includes */

#include <vxWorks.h>
#include <private/dosFsVerP.h>
#include <stat.h>
#include <time.h>
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <taskLib.h>
#include <tickLib.h>
#include <semLib.h>
#include <logLib.h>
#include <errnoLib.h>
#include <memLib.h>
#include <utime.h>
#include <blkIo.h>
#include <intLib.h>
#include <ffsLib.h>
#include <fsEventUtilLib.h>

#include <private/dosFsLibP.h>
#include <private/dosDirLibP.h>
#include <drv/xbd/bio.h>
#include <drv/xbd/xbd.h>
#include <drv/erf/erfLib.h>
#include <private/dosFsFatP.h>
#include <private/dosDirLibP.h>

#include <ctype.h>
#include <pathLib.h>

#ifdef _WRS_CONFIG_DOSFS_NAME_LENGTH_COMPAT
#include <private/utfLibP.h>
#endif

/* defines */

#if FALSE
#   undef FAT_ALLOC_ONE
#   define FAT_ALLOC_ONE        (FAT_ALLOC | 8)
#endif /* FALSE */

#define DOSFS_MERGE_DISCARD

/* macros */

#undef DBG_MSG
#undef ERR_MSG
#undef NDEBUG

#ifdef DEBUG
#   undef LOCAL
#   define LOCAL
#   undef ERR_SET_SELF
#   define ERR_SET_SELF
#   define DBG_MSG(lvl, fmt, arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8) \
    { if ((lvl) <= dosFsDebug)                 \
        printErr("%s : %d : " fmt,             \
                   __FILE__, __LINE__, arg1,arg2,   \
               arg3,arg4,arg5,arg6,arg7,arg8); }

#   define ERR_MSG(lvl, fmt, a1,a2,a3,a4,a5,a6)       \
        { logMsg(__FILE__ " : " fmt, (_Vx_usr_arg_t)(a1), \
          (_Vx_usr_arg_t)(a2),(_Vx_usr_arg_t)(a3), (_Vx_usr_arg_t)(a4), \
          (_Vx_usr_arg_t)(a5), (_Vx_usr_arg_t)(a6)); }
#else   /* NO DEBUG */

#   define NDEBUG
#   define DBG_MSG(lvl,fmt,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8)     {}

#   define ERR_MSG(lvl, fmt, a1,a2,a3,a4,a5,a6)       \
    { if ((lvl) <= dosFsDebug)                 \
            logMsg(__FILE__ " : " fmt, (_Vx_usr_arg_t)(a1), \
            (_Vx_usr_arg_t)(a2),(_Vx_usr_arg_t)(a3), (_Vx_usr_arg_t)(a4), \
            (_Vx_usr_arg_t)(a5), (_Vx_usr_arg_t)(a6)); }

#endif /* DEBUG */

#include "assert.h"

#ifdef ERR_SET_SELF
#   define errnoSet(err) errnoSetOut(__FILE__, __LINE__, #err, (err))
#endif /* ERR_SET_SELF */

#define DOSFS_MIN_BOOT_BLK_SIZE 512

/* typedefs */

/* globals */

int dosFsDrvNum = ERROR; /* dosFs number in vxWorks driver table */
u_int   dosFsDebug = 1;

int dosFsMutexOptions = (SEM_Q_PRIORITY | SEM_DELETE_SAFE | SEM_INVERSION_SAFE);

void (*_func_dosDirOldShow) (DOS_VOLUME_DESC_ID    pVolDesc) = NULL;
void (*_func_dosVDirShow) (DOS_VOLUME_DESC_ID    pVolDesc) = NULL;
void (*_func_dosFsFatShow) (DOS_VOLUME_DESC_ID    pVolDesc) = NULL;
void (*_func_dosChkStatPrint) (DOS_FILE_DESC_ID    pFd) = NULL;

/* handlers lists */

DOS_HDLR_DESC    dosFatHdlrsList[ DOS_MAX_HDLRS ] = {{0}};
DOS_HDLR_DESC    dosDirHdlrsList[ DOS_MAX_HDLRS ] = {{0}};

STATUS (*dosFsChkRtn)(DOS_FILE_DESC_ID pFd) = NULL;
                    /* check disk routine */

/* disk cache mount, unmount and create func pointers */

void (*dosFsCacheMountRtn) (DOS_VOLUME_DESC * pVolDesc) = NULL;
void (*dosFsCacheUnmountRtn) (DOS_VOLUME_DESC * pVolDesc) = NULL;
STATUS (*dosFsCacheCreateRtn) (
                              char *    volName,
                              char *    dataDirCacheAddr,
                              u_int     dataDirCacheSize,
                              char *    fatCacheAddr,
                              u_int     fatCacheSize
                              ) = NULL;
STATUS (*dosFsCacheDeleteRtn) (DOS_VOLUME_DESC * pVolDesc) = NULL;
UINT dosFsCacheDataDirDefaultSize = 0;
UINT dosFsCacheFatDefaultSize = 0;

IMPORT UINT dosFsVolumeBioBufferSize;

extern STATUS dosVDirReaddirPlus (
                DOS_FILE_DESC_ID        pFd,   /* descriptor of the directory being read */
                DIRPLUS *               pDir,  /* destination for directory name */
                CHK_DSK_READDIR_EXTRA * pExtra /* extra chkdsk data, or NULL */
                );

/* locals */

LOCAL ssize_t dosFsRead(FAST DOS_FILE_DESC_ID pFd, char * pBuf,
                        size_t maxBytes);

STATUS dosFsIoctl (FAST DOS_FILE_DESC_ID pFd, int function,
                   _Vx_ioctl_arg_t arg);

DOS_FILE_DESC_ID dosFsOpen (FAST DOS_VOLUME_DESC * pVolDesc,
                            char * pPath, int flags, int mode);

LOCAL STATUS dosFsDelete (DOS_VOLUME_DESC_ID pVolDesc, char * pPath);

STATUS dosFsClose  (DOS_FILE_DESC_ID pFd);

LOCAL STATUS dosFsCheckDirRename (DOS_VOLUME_DESC *pVolDesc,
                  char *pOldName, char *pNewName);

LOCAL STATUS dosFsRename (DOS_FILE_DESC_ID    pFdOld, char *pOldName,
              char * pNewName, BOOL allowOverwrite);

LOCAL STATUS dosFsOptUpdate
            (
            DOS_VOLUME_DESC_ID  pVolDesc,
            int usrDefinedOptions
            );

LOCAL STATUS dosFsFillGap (FAST DOS_FILE_DESC_ID      pFd,
                           u_int        fatFlags);

LOCAL STATUS dosFsVolBufCreate (DOS_VOLUME_DESC * pVolDesc);

LOCAL STATUS dosFsVolMount (DOS_VOLUME_DESC_ID  pVolDesc);

LOCAL STATUS dosFsVolMountPart1 (DOS_VOLUME_DESC_ID  pVolDesc);

LOCAL STATUS dosFsVolMountPart2 (DOS_VOLUME_DESC_ID  pVolDesc);

LOCAL void dosFsXbdDone (struct bio * pBio);

LOCAL STATUS dosFsSingleBlkXfer (DOS_VOLUME_DESC * pVolDesc, sector_t block,
                                 addr_t buffer, DOS_RW operation);

LOCAL void dosFsFinishDevDelete (DOS_VOLUME_DESC * pVolDesc);

LOCAL struct bio *dosFsBioGet (DOS_VOLUME_DESC *);
LOCAL STATUS dosFsBioRelease (DOS_VOLUME_DESC *, struct bio *);
STATUS dosFsChkDsk (FAST DOS_FILE_DESC_ID   pFd,
                    u_int   params);
void dosFsFdFree (DOS_FILE_DESC_ID    pFd);
DOS_FILE_DESC_ID dosFsFdGet (DOS_VOLUME_DESC_ID  pVolDesc);

LOCAL int dosFsMaxFiles;
LOCAL int dosFsCreateOptions;

#ifdef ERR_SET_SELF
/*******************************************************************************
* errnoSetOut - put error message
*
* This routine is called instead of errnoSet during debugging.
*/
static VOID errnoSetOut
    (
    char * pFile,
    int line,
    const char * pStr,
    int errCode
    )
    {
    if (errCode != OK && strcmp(pStr, "errnoBuf") != 0)
        PRINT_MSG (CLSMSG_NORMAL, " %s : line %d : %s = %p, task %p\n",
                pFile, line, pStr, (void *)errCode,
                (void *)taskIdSelf());
    errno = errCode;
    }
#endif  /* ERR_SET_SELF */

/***************************************************************************
*
* dosfsHostToDisk32 - convert uint32_t from host to on-disk format
*
* This routine converts a uint32_t from host's memory to on-disk format.
*
* RETURNS: N/A
*
* /NOMANUAL
*/

void dosfsHostToDisk32
    (
    uint32_t   src,
    uint8_t *  pDest
    )
    {
    pDest[0] = (uint8_t)(src & 0xff);
    pDest[1] = (uint8_t)((src >> 8) & 0xff);
    pDest[2] = (uint8_t)((src >> 16) & 0xff);
    pDest[3] = (uint8_t)((src >> 24) & 0xff);
    }

/***************************************************************************
*
* dosfsHostToDisk16 - convert uint16_t from host to on-disk format
*
* This routine converts a uint16_t from host's memory to on-disk format.
*
* RETURNS: N/A
*
* /NOMANUAL
*/

void  dosfsHostToDisk16
    (
    uint16_t   src,
    uint8_t *  pDest
    )
    {
    pDest[0] = (uint8_t)(src & 0xff);
    pDest[1] = (uint8_t)((src >> 8) & 0xff);
    }

/***************************************************************************
*
* dosfsDiskToHost32 - convert uint32_t from on-disk to host format
*
* This routine converts a uint32_t from on-disk format to host's endian-ness.
*
* RETURNS: uint32_t in host's endian-ness
*
* /NOMANUAL
*/

uint32_t  dosfsDiskToHost32
    (
    uint8_t *  pSrc
    )
    {
    return ((uint32_t) (((uint32_t) pSrc[3] << 24) +
                        ((uint32_t) pSrc[2] << 16) +
                        ((uint32_t) pSrc[1] << 8) +
                        (uint32_t) pSrc[0]));
    }

/***************************************************************************
*
* dosfsDiskToHost16 - convert uint16_t from on-disk to host format
*
* This routine converts a uint16_t from on-disk format to host's endian-ness.
*
* RETURNS: uint16_t in hosts's endian-ness
*
* /NOMANUAL
*/

uint16_t  dosfsDiskToHost16
    (
    uint8_t *  pSrc
    )
    {
    return ((uint16_t) (((uint32_t) pSrc[1] << 8) + (uint32_t) pSrc[0]));
    }

/*******************************************************************************
*
* dosFsVolumeOptionsSet - set this volume's disk options
*
* This routine sets the volume options for the dosFs volume <volName>.
* Currently the only option available is DOS_VOLUME_VOL_NO_DMA, which means
* that DosFS does not need to use DMA-safe buffers on <volName> when large
* transfers to and from the media are requested. This option may gain
* performance on large transfers, and is recommended for USB devices.
* It replaces the routine dosFsCacheOptionsSet().
*
* <volName> is a NULL terminated character string that corresponds to the
* name of the desired DosFS volume.
* Valid settings for <options> are currently DOS_VOLUME_VOL_NO_DMA or 0.
*
* RETURNS: new value of the volume's options, or ERROR on failure.
*/

UINT dosFsVolumeOptionsSet
    (
    char *      volName,         /* dosFs volume name */
    UINT        options          /* new options */
    )
    {
    DOS_VOLUME_DESC *  pVolDesc;

    pVolDesc = dosFsVolDescGet (volName, NULL);

    if (pVolDesc == NULL)
        {
        PRINT_MSG (CLSMSG_NORMAL,"%s Not a DOSFS Device\n", volName);
        return ((UINT)ERROR);
        }

    if ((options & (~DOS_VOLUME_VOL_NO_DMA)) != 0)
        {
        errnoSet (EINVAL);
        return ((UINT)ERROR);
        }

    if (semTake (pVolDesc->devSem, WAIT_FOREVER) != OK)
        return ((UINT)ERROR);

    pVolDesc->volOptions = options;

    semGive (pVolDesc->devSem);
    return (options);
    }

/*******************************************************************************
*
* dosFsVolumeOptionsGet - get this volume's disk options
*
* This routine gets the volume options for the dosFs volume <volName>.  It
* replaces the routine dosFsCacheOptionsGet().
*
* <volName> is a NULL terminated character string identifying the DosFS volume.
*
* RETURNS: DOS_VOLUME_VOL_NO_DMA if that option is enabled;
*          0 if no options are enabled; ERROR on failure
*/

UINT dosFsVolumeOptionsGet
    (
    char *      volName         /* dosFs volume name */
    )
    {
    DOS_VOLUME_DESC *  pVolDesc;

    pVolDesc = dosFsVolDescGet (volName, NULL);

    if (pVolDesc == NULL)
        {
        PRINT_MSG (CLSMSG_NORMAL,"%s Not a DOSFS Device\n", volName);
        return (UINT)(ERROR);
        }

    return (pVolDesc->volOptions);
    }

/*******************************************************************************
*
* dosSetVolCaseSens - set case sensitivity of volume
*
* Pass TRUE to setup a case sensitive volume.
* Pass FALSE to setup a case insensitive volume.
* Note this affects rename lookups only. It is invalidation
* for short name that conform to 8.3 format.
*
* RETURNS: TRUE if pVolDesc pointed to a DOS volume.
*/

STATUS dosSetVolCaseSens
    (
    DOS_VOLUME_DESC_ID pVolDesc,
    BOOL sensitivity
    )
    {
    if (_WRS_ALIGN_CHECK ((long)pVolDesc, DOS_VOLUME_DESC_ID) &&
        (pVolDesc->magic == DOS_FS_MAGIC))
        {
        /* <pVolDesc> is aligned OK, and it points to a DOS volume */
        pVolDesc->volIsCaseSens = sensitivity;
        return (TRUE);
        }

    /* Not a DOS volume or not aligned so that's an invalid parameter */
    errnoSet(S_dosFsLib_INVALID_PARAMETER);
    return (FALSE);
    }


/*******************************************************************************
*
* dosFsIsValHuge - check if value is grater, than 4GB (max 32 bit).
*
* RETURNS: TRUE if is grater, else return FALSE.
*/
LOCAL BOOL dosFsIsValHuge
    (
    fsize_t val
    )
    {
    return (DOS_IS_VAL_HUGE (val));
    } /* dosFsIsValHuge() */

/*******************************************************************************
*
* dosFsVolDescGet - convert a device name into a DOS volume descriptor pointer.
*
* This routine validates <pDevNameOrPVolDesc> to be a DOS volume
* descriptor pointer else a path to a DOS device. This routine
* uses the standard iosLib function iosDevFind() to obtain a pointer
* to the device descriptor. If device is eligible, <ppTail> is
* filled with the pointer to the first character following
* the device name.  Note that ppTail is passed to iosDevFind().
* <ppTail> may be passed as NULL, in which case it is ignored.
*
* RETURNS: A DOS_VOLUME_DESC_ID or NULL if not a DOSFS device.
*
* ERRNO:
* S_dosFsLib_INVALID_PARAMETER
*/

DOS_VOLUME_DESC_ID dosFsVolDescGet
    (
    void *      pDevNameOrPVolDesc, /* device name or pointer to dos vol desc */
    u_char **   ppTail              /* return ptr for name, used in iosDevFind */
    )
    {
    DOS_VOLUME_DESC_ID  pVolDesc;   /* pointer to volume descriptor */
    char *      pDevName = pDevNameOrPVolDesc;
    u_char *    pNameTail;

    if (ppTail == NULL)
        ppTail = &pNameTail;

    *ppTail = NULL;

    /* SPR#71720 NULL is presumed to be an invalid value */

    if (NULL == pDevNameOrPVolDesc)
        {
        errnoSet(S_dosFsLib_INVALID_PARAMETER);
        return (NULL);
        }

    /*
     * SPR# 91384: first, assume pDevNameOrPVolDesc points to a device name. If
     * unsuccessful then try to dereference.
     */

#ifdef _WRS_DOSFS2_VXWORKS_AE
    pVolDesc = (DOS_VOLUME_DESC_ID) iosDevFind (pDevName,
                                                (const char **) ppTail);
#else
    pVolDesc = (DOS_VOLUME_DESC_ID) iosDevFind (pDevName, (char **) ppTail);
#endif /* _WRS_DOSFS2_VXWORKS_AE */

    /*
     * SPR#76510, if iosDevFind() returned default device,
     * then the tail (ppTail) will point to the front of
     * the passed name and that is considered a lookup failure.
     */

    if ((pVolDesc != NULL) && ((char *) *ppTail != pDevName))
        {
        /* ensure returned pVolDesc is valid */

        if ((_WRS_ALIGN_CHECK ((long)pVolDesc, DOS_VOLUME_DESC_ID)) &&
                (pVolDesc->magic == DOS_FS_MAGIC))
            {
            return (pVolDesc);
            }
        }

    /* pDevNameOrPVolDes is not a device name. It may be a vol. descriptor */

    pVolDesc = (DOS_VOLUME_DESC_ID) pDevNameOrPVolDesc;

    /* SPR#71720 ensure alignment and then check the magic cookie */

    if ((_WRS_ALIGN_CHECK ((long)pVolDesc, DOS_VOLUME_DESC_ID)) &&
        (pVolDesc->magic == DOS_FS_MAGIC))
        {
        return (pVolDesc);
        }

    /* not a valid device name, nor a volume descriptor */

    errnoSet (S_dosFsLib_INVALID_PARAMETER);

    return (NULL);
    } /* dosFsVolDescGet() */

/*******************************************************************************
*
* dosFsFSemTake - take file semaphore.
*
* RETURNS: STATUS as result of semTake.
*/
LOCAL STATUS dosFsFSemTake
    (
    DOS_FILE_DESC_ID    pFd,
    int         timeout
    )
    {
    STATUS retStat;

    assert(pFd - pFd->pVolDesc->pFdList < pFd->pVolDesc->maxFiles);
    assert(pFd->pFileHdl - pFd->pVolDesc->pFhdlList < pFd->pVolDesc->maxFiles);

    retStat = semTake(*(pFd->pVolDesc->pFsemList +
                        (pFd->pFileHdl - pFd->pVolDesc->pFhdlList)),
                        timeout);
    assert(retStat == OK);
    return retStat;
    } /* dosFsFSemTake() */

/*******************************************************************************
*
* dosFsFSemGive - release file semaphore.
*
* RETURNS: STATUS as result of semGive.
*/
LOCAL STATUS dosFsFSemGive
    (
    DOS_FILE_DESC_ID    pFd
    )
    {
    STATUS retStat;

    assert(pFd - pFd->pVolDesc->pFdList < pFd->pVolDesc->maxFiles);
    assert(pFd->pFileHdl - pFd->pVolDesc->pFhdlList < pFd->pVolDesc->maxFiles);

    retStat = semGive(*(pFd->pVolDesc->pFsemList +
                       (pFd->pFileHdl - pFd->pVolDesc->pFhdlList)));
    assert(retStat == OK);
    return retStat;
    } /* dosFsFSemGive() */

/*******************************************************************************
*
* dosFsVolUnmount - unmount a dosFs volume
*
* This routine is called when I/O operations on a volume are to be
* discontinued.  This is the preferred action prior to changing a
* removable disk.
*
* All buffered data for the volume is written to the device
* (if possible, with no error returned if data cannot be written),
* any open file descriptors are marked as obsolete,
* and the volume is marked as not currently mounted.
*
* When a subsequent open() operation is initiated on the device,
* new volume will be mounted automatically.
*
* Once file descriptors have been marked as obsolete, any attempt to
* use them for file operations will return an error.  (An obsolete file
* descriptor may be freed by using close().  The call to close() will
* return an error, but the descriptor will in fact be freed).
*
* This routine may also be invoked by calling ioctl() with the
* FIOUNMOUNT function code.
*
* This routine must not be called from interrupt level.
*
* RETURNS: OK, or ERROR if the volume was not mounted.
*
* /NOMANUAL
*/

STATUS dosFsVolUnmount
    (
    void *  pDevNameOrPVolDesc  /* device name or ptr to */
                                /* volume descriptor */
    )
    {
    DOS_VOLUME_DESC_ID  pVolDesc;   /* pointer to volume descriptor */
    int i;

    /* get volume descriptor */

    pVolDesc = dosFsVolDescGet (pDevNameOrPVolDesc, NULL);

    if (pVolDesc == NULL)
        return (ERROR);

    if (!pVolDesc->mounted)
        return (ERROR);

    /* acquire semaphore */

    if (semTake (pVolDesc->devSem, WAIT_FOREVER) == ERROR)
        return (ERROR);

    /* mark all opened file descriptors as obsolete */
    /* also synchronize the FAT and do not hold the */
    /* file semaphore, in certain operations like   */
    /* rename-file the file semaphore is locked     */
    /* before devSem. Trying to hold file semaphore */
    /* , after holding devSem, will cause dead-lock */
    /* XXX if this is true, what is the protection expected to be provided by
     * the file semaphore?. Isn't this case a violation of the exclusive
     * access to the file handler intended by this mutex? */

    for (i = 0; i < pVolDesc->maxFiles; i ++)
        {
        if (pVolDesc->pFdList[i].busy)
            {
            /* Synchronize the FAT */
            pVolDesc->pFatDesc->flush (&pVolDesc->pFdList[i]);
            pVolDesc->pFdList[i].pFileHdl->obsolet = 1;
            }
        }

    pVolDesc->nBusyFd = 0;

    /* give the FAT code a chance to release resources and clean up */
    pVolDesc->pFatDesc->volUnmount (pVolDesc);

    /* flush buffers */

    pVolDesc->dataIoctl (pVolDesc, CBIO_CACHE_FLUSH, (void*)(-1));

    pVolDesc->dataIoctl (pVolDesc, CBIO_CACHE_INVAL, 0);

    /* invalidate disk cache, if any */

    if (dosFsCacheUnmountRtn != NULL)
        dosFsCacheUnmountRtn (pVolDesc);

    pVolDesc->mounted = FALSE;  /* volume unmounted */

    semGive (pVolDesc->devSem);
    return (OK);
    } /* dosFsVolUnmount() */

/*******************************************************************************
*
* dosFsChkDsk - make volume integrity checking.
*
* This library does not make integrity check process itself, but
* instead uses routine provided by dosChkLib.
* This routine prepares parameters and invokes checking routine
* via preinitialized function pointer. If dosChkLib is not configured
* into vxWorks, this routine returns ERROR.
*
* Ownership on device should be taken by an upper level routine.
*
* RETURNS: STATUS as returned by volume checking routine or
*  ERROR, if such routine is not installed.
*
* ERRNO:
* S_dosFsLib_UNSUPPORTED.
*/
STATUS dosFsChkDsk
    (
    FAST DOS_FILE_DESC_ID   pFd,    /* file descriptor of root dir */
    u_int   params                  /* check level and verbosity */
    )
    {
    DOS_VOLUME_DESC_ID  pVolDesc = pFd->pVolDesc;
    STATUS  retVal = ERROR;
    int     verb;

    if (dosFsChkRtn == NULL)
        {
        errnoSet (S_dosFsLib_UNSUPPORTED);
        ERR_MSG (1,"Check disk utility not installed\n", 0,0,0,0,0,0);
        return (ERROR);
        }

    /* prepare check disk parameters */

    verb = (params >> 8) & 0xff;    /* XXX "knows" encoding */
    params &= DOS_CHK_FLAGS_MASK;

    /* exactly one of DOS_CHK_{ONLY,REPAIR} should be set */

    if ((params & DOS_CHK_REPAIR) == 0)
        {
        params |= DOS_CHK_ONLY;
        }
    else
        {
        params &= ~DOS_CHK_ONLY;
        }

    pVolDesc->chkFlags = (u_char)params;

    pVolDesc->chkVerbLevel = (u_char)((verb == (DOS_CHK_VERB_0 >> 8)) ? 0 : verb);

    /* run disk check */

    retVal = dosFsChkRtn (pFd);

    /* flush and invalidate DOS tiny caches */

    pVolDesc->dataIoctl (pVolDesc, CBIO_CACHE_FLUSH, (void *)(-1));
    pVolDesc->dataIoctl (pVolDesc, CBIO_CACHE_INVAL, 0);

    pVolDesc->chkFlags = 0;
    pVolDesc->chkVerbLevel = 0;

    return (retVal);
    } /* dosFsChkDsk() */

/*******************************************************************************
*
* dosFsBadBootMsg - print error message while boot sector parsing.
*
* RETURNS: N/A.
*/
LOCAL void dosFsBadBootMsg
    (
    u_int   dbgLevel,   /* message level */
    u_int   offset,     /* offset of invalid field */
    u_int   val,        /* invalid value */
    char *  pExtraMsg,  /* extra message */
    u_int   line        /* line number of error detecting code */
    )
    {
#ifdef DEBUG
    printErr ("%s : %u. Malformed boot sector. Offset %u, value %u. %s\n",
              __FILE__, __LINE__, offset, val,
              ((pExtraMsg == NULL)? " " : pExtraMsg));
#else /* not DEBUG */
    DBG_MSG (dbgLevel, "Malformed boot sector. Offset %u, value %u. %s\n",
             offset, val, ((pExtraMsg == NULL)? " " : pExtraMsg), 0,0,0,0,0);
#endif /* DEBUG */
    }

/*******************************************************************************
*
* dosFsBootSecGet - extract boot sector parameters.
*
* This routine reads boot sector from the disk and extracts
* current volume parameters from of it.
*
* This routine also performs sanity check of those volume parameters,
* that are mutually dependent or alternative.
*
* This routine also determines the FAT type: FAT32, FAT12, or FAT16.
*
* If read or damaged boot sector is encountered, this routine
* searches for backup copy of boot sector and accepts volume
* volume configuration from this copy.,
*
* RETURNS: OK or ERROR if disk read error or inconsistent
* boot sector data or failure to obtain xbd parameters.
*
* ERRNO:
* S_dosFsLib_UNKNOWN_VOLUME_FORMAT
*/

LOCAL STATUS dosFsBootSecGet
    (
    DOS_VOLUME_DESC_ID  pVolDesc    /* pointer to volume descriptor */
    )
    {
    u_int       work;
    u_char      bootSec [DOS_FAT_DEFAULT_SECTOR_SIZE] = {0}; /* buffer for boot sector data */
    u_char      tmpType [DOS_BOOT_FSTYPE_LEN + 1] = {0};
    sector_t    nBlocks;
    unsigned    blockSize;

    pVolDesc->bootSecNum = DOS_BOOT_SEC_NUM;  /* zero, per FAT standard */

    /* request the underlying XBD device parameters */

    if (xbdNBlocks (pVolDesc->device, &nBlocks) != OK)
        return (ERROR);

    if (xbdBlockSize (pVolDesc->device, &blockSize) != OK)
        return (ERROR);

    /*
     * For DosFS, <blockSize> must be both at least 32 bytes and
     * a power of two.
     */

    if ((blockSize < 32) || ((blockSize & (blockSize - 1)) != 0))
        {
        ERR_MSG (1, "blockSize (%d) must be a power of two and "
                    "greater than zero.\n", 0, 0, 0, 0, 0, 0);
        goto error;
        }

    /* read relevant boot sector data into bootSec[] */

    work = min (blockSize, (int) sizeof (bootSec));

    if (dosFsXbdBytesRW (pVolDesc, pVolDesc->bootSecNum, 0 /* offset */,
                         (addr_t) bootSec, work, DOS_READ) == ERROR)
        {
        ERR_MSG(1, "ERROR reading the device boot sector\n", 0,0,0,0,0,0);
        ERR_MSG(1, "media not formatted or not present\n", 0,0,0,0,0,0);
        goto error;
        }

    /* check for both acceptable Intel 80x86 `jmp' opcodes */

    if (bootSec [DOS_BOOT_JMP] != 0xe9 && bootSec [DOS_BOOT_JMP] != 0xeb)
        {
        dosFsBadBootMsg (1, DOS_BOOT_JMP, (u_int) bootSec [DOS_BOOT_JMP],
                         NULL , __LINE__);
        goto error;
        }

    /*
     * Start filling out and verifying the volume descriptor fields
     * using the data from the boot parameter block.  Evaluate the validity
     * of the data, so that dosFsVolIsFat12() may be safely called.
     */

    /* evaluate bytes per sector */

    work = dosfsDiskToHost16 (bootSec + DOS_BOOT_BYTES_PER_SEC);

    pVolDesc->bytesPerSec = (UINT16)work;

    if (work != blockSize)
        {
        dosFsBadBootMsg (1, DOS_BOOT_BYTES_PER_SEC, work, NULL, __LINE__);
        ERR_MSG (2, "blockSize %u != bytes-per-sec %u\n", blockSize, work,
                 0,0,0,0);
        goto error;
        }

    /*
     * The block size has already been confirmed to be both a power of two and
     * at least 32 bytes.  Use ffsMsb() to determine pVolDesc->secSizeShift.
     */

    pVolDesc->secSizeShift = (u_char)(ffsMsb (blockSize) - 1);

    /* evaluate the total number of sectors on this volume */

    work = dosfsDiskToHost16 (bootSec + DOS_BOOT_NSECTORS);

    /*
     * When the volume has at least 0x10000 sectors, the 16 bit field
     * DOS_BOOT_NSECTORS is zero, and the alternate 32bit field
     * DOS_BOOT_LONG_NSECTORS is used to determine the number of
     * sectors on the volume.
     */

    if (work == 0) /* it is a large disk */
        {
        work = dosfsDiskToHost32 (bootSec + DOS_BOOT_LONG_NSECTORS);
        if (work == 0)
            {
            dosFsBadBootMsg (1, DOS_BOOT_LONG_NSECTORS, work, NULL, __LINE__);
            goto error;
            }
        }

    pVolDesc->totalSec = work;

     /* number of sectors can be greater than nBlocks */

    if (work != nBlocks)
        {
        /*
         * An error here may indicate a problem with representing
         * a partition size correctly in the underlying XBD layer.
         *
         * Also, an off by one error may mean a driver bug.
         * nBlocks is the number of blocks on the
         * XBD device. Using the "last addressable LBA value"
         * in nBlocks can produce an off by one error, this is
         * considered a driver problem.  xbd_nblocks shall be the
         * number of blocks (1-xxx) not the last addressable block.
         * Rather the driver should set nBlocks to the
         * (last addressable block + 1).  DOSFS1 did not make this
         * check.  DOSFS2 does make this check to avoid overrun.
         */

        if (work > nBlocks)
            pVolDesc->totalSec = (UINT32)nBlocks;

        ERR_MSG (10, "WARNING: num-sectors %u != nBlocks %u\n",
                 work, nBlocks, 0,0,0,0);
        }

    /* evaluate the number of sectors per cluster */

    pVolDesc->secPerClust = bootSec [DOS_BOOT_SEC_PER_CLUST];

    if (pVolDesc->secPerClust == 0)
        {
        dosFsBadBootMsg (1, DOS_BOOT_SEC_PER_CLUST, 0, NULL, __LINE__);
        goto error;
        }

    /* evaluate the number of FAT copies */

    pVolDesc->nFats = bootSec [DOS_BOOT_NFATS];

    if (pVolDesc->nFats == 0)
        {
        dosFsBadBootMsg (1, DOS_BOOT_NFATS, 0, NULL, __LINE__);
        goto error;
        }

    /* get the number of hidden sectors */

    pVolDesc->nHiddenSecs = dosfsDiskToHost16 (bootSec +
                                               DOS_BOOT_NHIDDEN_SECS);

    /* evaluate the number of reserved sectors */

    pVolDesc->nReservedSecs = dosfsDiskToHost16 (bootSec +
                                                 DOS_BOOT_NRESRVD_SECS);

    if (pVolDesc->nReservedSecs == 0)
        {
        dosFsBadBootMsg (1, DOS_BOOT_NRESRVD_SECS, 0, NULL, __LINE__);
        goto error;
        }

    /* evaluate the number of sectors alloted to FAT table */

    pVolDesc->secPerFat = dosfsDiskToHost16 (bootSec + DOS_BOOT_SEC_PER_FAT);

    /*
     * Now determine the volumes FAT type.  FAT12, FAT16, and FAT32.
     * NOTE: The secPerFat field is zero on FAT32 DOSFS volumes.
     * This is how we determine if FAT32 will be used when mounting
     * this volume.  If secPerFat is zero, it must be FAT32.
     * Else, we need to pick between FAT12 and FAT16.
     */

    if (pVolDesc->secPerFat != 0) /* then using either FAT12 or FAT16 */
        {
        /*
         * The maximum number of 16 bit FAT entries is 65536.
         * Anything greater is invalid.  Check here.
         */

        if (pVolDesc->secPerFat >  (ULONG)0x10000*2 / pVolDesc->bytesPerSec)
            {
            dosFsBadBootMsg (1, DOS_BOOT_SEC_PER_FAT, pVolDesc->secPerFat,
                             NULL, __LINE__);
            ERR_MSG (2, "secPerFat 12/16 = %u, while BPS = %u\n",
                     pVolDesc->secPerFat, pVolDesc->bytesPerSec,0,0,0,0);
            goto error;
            }

        /*
         * Now we must decide if our volume is using FAT12 or FAT16.
         * If we choose the wrong FAT type, volume mounting will fail,
         * and/or data corruption on the volume will occur when its exercised.
         * See also: SPR#34704.
         * We will also check the MS FSTYPE field (offset 0x36 in the
         * boot sector) when determining the FAT type.  If either of the
         * Microsoft defined strings exist, then we honor the boot sectors
         * wisdom.  This presumes that the formatter of the volume knew what
         * they were doing when writing out these strings.  This may not
         * be the case, but its seems the most compatible approach.
         * The FSTYPE string field is also intentionaly being honored, so
         * that either FAT type can be forced in the field.  In the event
         * of a bad mount occuring in the field, a hack of writing the correct
         * string to the BPB FSTYPE field would force the mount to the desired
         * type.  Many DOS implementations do not set these strings and that
         * is just fine.  Copy FSTYPE string to tmpType.
         */

        bcopy ((char *) bootSec + DOS_BOOT_FSTYPE_ID, (char *) tmpType,
               DOS_BOOT_FSTYPE_LEN);

        /*
         * Now calculate the FAT type (FAT12 vs. FAT16) per a formula
         * We warn the user when the FSTYPE string (if present) doesn't match
         * the calculation.
         */

        work = dosFsVolIsFat12 (bootSec);

        if ((UINT)ERROR == work)
            {
            ERR_MSG (1, "dosFsVolIsFat12 returned ERROR\n", 0,0,0,0,0,0);
            goto error;
            }

        if (TRUE == work) /* then calculated FAT12 */
            {
            /*
             * Check the FSTYPE field in the BPB to ensure the string
             * value matches our calculation.  If not, the we assume
             * the formatter knew what they wanted, and we honor
             * the string value. We look for "FAT12   " or "FAT16   ".
             */

            if ((strcmp ((char *)tmpType, DOS_BOOT_FSTYPE_FAT16)) == 0)
                {
                pVolDesc->fatType = FAT16;
                PRINT_MSG (CLSMSG_NORMAL,"WARNING: FAT16 indicated by BPB FSTYPE string, "
                        "cluster calculation was FAT12. Honoring string.\n");
                }
            else
                {
                pVolDesc->fatType = FAT12;
                }
            }
        else /* we calculated FAT 16 */
            {
            /*
             * Check the FSTYPE field in the BPB to ensure the string
             * value matches our calculation.  If not, the we assume
             * the formatter knew what they wanted, and we honor
             * the string value. We look for "FAT12   " or "FAT16   ".
             */

            if ((strcmp ((char *)tmpType, DOS_BOOT_FSTYPE_FAT12)) == 0)
                {
                pVolDesc->fatType = FAT12;
                PRINT_MSG (CLSMSG_NORMAL,"WARNING: FAT12 indicated by BPB FSTYPE string, "
                       "cluster calculation was FAT16. Honoring string.\n");
                }
            else
                {
                pVolDesc->fatType = FAT16;
                }
            }

        /* volume Id and label */

        pVolDesc->volIdOff = DOS_BOOT_VOL_ID;
        pVolDesc->volLabOff = DOS_BOOT_VOL_LABEL;
        }
    else    /* Use FAT32 because (pVolDesc->secPerFat == 0) */
        {
        pVolDesc->fatType = FAT32;

        /* sectors per fat copy */

        pVolDesc->secPerFat = dosfsDiskToHost32 (bootSec +
                                                 DOS32_BOOT_SEC_PER_FAT);

        if (pVolDesc->secPerFat == 0)
            {
            dosFsBadBootMsg(1, DOS32_BOOT_SEC_PER_FAT, 0, "(FAT32)", __LINE__);
            goto error;
            }

        /* volume Id and label */

        pVolDesc->volIdOff = DOS32_BOOT_VOL_ID;
        pVolDesc->volLabOff = DOS32_BOOT_VOL_LABEL;
        }

    /*
     * count sector number of data area start cluster.
     * This value can be corrected later by directory handler, if
     * root directory is not stored as regular directory
     * in clusters (FAT32), but instead resides contiguously
     * ahead first data cluster (FAT12/FAT16)
     */

    pVolDesc->dataStartSec = pVolDesc->nReservedSecs +
                             (pVolDesc->secPerFat * pVolDesc->nFats);

    /* volume Id and label */

    pVolDesc->volId = dosfsDiskToHost32 (bootSec + pVolDesc->volIdOff);

    bcopy ((char *)bootSec + pVolDesc->volLabOff,
           (char *)pVolDesc->bootVolLab, DOS_VOL_LABEL_LEN);

    *(pVolDesc->bootVolLab + DOS_VOL_LABEL_LEN) = EOS;

    /* currently it is enough for starting */

    return (OK);

error:
    /*
     * some data is inconsistent. We are no longer trying to find other
     * boot block copy on next sector
     */

    if (errnoGet() == OK)
        errnoSet (S_dosFsLib_UNKNOWN_VOLUME_FORMAT);
    return (ERROR);
    } /* dosFsBootSecGet() */

/*******************************************************************************
*
* dosFsVolIsFat12 - determine if a MSDOS volume is FAT12 or FAT16
*
* This routine is the container for the logic which determines if a
* dosFs volume is using FAT12 or FAT16.  Two methods are implemented.
* Both methods use information from the volumes boot parameter block
* fields found in the boot sector.
*
* The first FAT determination method follows the recommendations outlined
* in the Microsoft document:
*
* "Hardware White Paper
*  Designing Hardware for Microsoft Operating Systems
*  FAT: General Overview of On-Disk Format
*  Version 1.02, May 5, 1999
*  Microsoft Corporation"
*
* This method is used in the hopes that greater compatability with
* MSDOS formatted media will be achieved.  The Microsoft recommended
* method for FAT type determination between FAT12 and FAT16 is done
* via the count of clusters on the volume.
*
* The Microsoft recommended approach is as follows:
*
* 1.) Determine the count of sectors occupied by the root directory
*     entries for this volume, rounding up:
*
* rootDirSecs = ((rootEntCount * dirEntSz) + (bytesPerSec-1)) / bytesPerSec;
*
* Where dirEntSz is 32 for MSDOS 8.3, and 64 for VXLONGNAMES.
*
*
* 2.) Determine the count of sectors occupied by the volumes data region:
*
* dataRgnSecs = totalSecs - (reservedSecs + (nFats * fatSecs) + rootDirSecs);
*
*
* 3.) determine the count of clusters, rounding down:
*
* countOfClusts = dataSecs / secsPerClust; /@ Note: this rounds down. @/
*
* Note: countOfClusts represents the count of data clusters, starting at two.
*
* 4.) determine the FAT types based on the count of clusters on the volume,
*
*     if (countOfClusts < 4085) /@ Microsoft recommends using "less than" @/
*         {
*         /@ Volume is FAT12 @/
*         }
*     else
*         {
*         /@ Volume is FAT16 @/
*         }
*
*
* An alternate method is used when mounting a known VxWorks DOSFS-1.0 volume.
* This method is used for greater backward compatability with VxWorks
* DOSFS-1.0 volumes.  See also: SPR#34704.  The VxWorks dosFs1 method
* deviates from the Microsoft currently recommened method.
*
* This is the VxWorks DOSFS1 method per dosFsVolDescFill(), dosFsLib.c,
* dosFs 1.0, revision history: "03l,16mar99,dgp".  Using the identical
* method  here will help ensure backward compatablitity when mounting
* volumes formatted by the VxWorks dosFs1.0 code.
*
* The VxWorks DOSFS 1.0 approach is as follows:
*
* 1.) Get starting sector of the root directory:
*
* rootSec = reservedSecs + (nFats * secsPerFat);
*
*
* 2.) Get the size of the root dir in bytes:
*
* rootBytes = (nRootEnts * dirEntSz):
*
* Where dirEntSz is 32 for MSDOS 8.3, and 64 for VXLONGNAMES.
*
*
* 3.) Get the starting sector of the data area:
*
* dataSec = rootSec + ((rootBytes + bytesPerSec-1) / bytesPerSec);
*
*
* 4.) Get the number of "FAT entries":
*
* countOfClusts =
*        (((totalSecs - dataSecs) / secsPerClust) + DOS_MIN_CLUST);
*
*
* 5.) Choose the FAT type based on the count of clusters, note DOSFS1
* uses less than or equal here.
*
* if (countOfClusts <= 4085) /@ VxDosFs1 uses less than or equal to. @/
*     {
*     /@ use FAT12 @/
*     }
* else
*     {
*     /@ use FAT16 @/
*     }
*
* By mimicking the dosFs 1.0 approach, we should be able to mount
* all dosFs 1.0 volumes correctly.  By using the microsoft recommened
* approach in all other cases, we should be as compatable as possible
* with Microsoft OS's.
*
* The volumes Boot Parameter Block fields MUST be validated for sanity
* before this routine is called.
*
* pBootBuf is not verified, DO NOT pass this routine a NULL pointer.
* This routine is also used by dosFsFmtLib.c
*
* RETURNS: TRUE if the FAT type is FAT12, FALSE if the FAT type is FAT16,
* or ERROR if the data is invalid.
*
* /NOMANUAL
*/

int dosFsVolIsFat12
    (
    u_char * pBootBuf       /* boot parameter block buffer */
    )
    {
    u_int  dirEntSz;        /* directory entry size in bytes */
    u_int  nRootEnts;       /* number of root directory entries */
    u_int  bytesPerSec;     /* number of bytes per sector */
    u_int  rootDirSecs;     /* count of sectors used for root directory */
    u_int  reservedSecs;    /* count of reserved sectors */
    u_int  totalSecs;       /* count of total sectors on volume */
    u_int  dataRgnSecs;     /* count of data region sectors */
    u_int  secsPerClust;    /* count of sectors per cluster */
    u_int  nFats;           /* number of FAT tables */
    u_int  secsPerFat;      /* number of sectors used for a FAT table */
    u_int  countOfClusts;   /* count of clusters on this volume */
    u_int  work;            /* work int */
    BOOL   vxDOSFS1Vol;         /* tracks when using VxWorks dosFs 1.0 */
    const char * dosFs1SysId = "VXDOS4.0";    /* VxDOSFS 1.0 using 8.3 */
    const char * dosFs1ExtSysId = "VXEXT1.0"; /* VxDOSFS 1.0 VxLongnames */

    /* NULL is presumed to be an invalid value */

    if (NULL == pBootBuf)
        {
        return (ERROR);
        }

    /* initialize all variables used to determine FAT type */

    /* determine the total number of sectors on this volume */

    work = dosfsDiskToHost16 (pBootBuf + DOS_BOOT_NSECTORS);

    /*
     * When the volume has at least 0x10000 sectors, the 16 bit field
     * DOS_BOOT_NSECTORS is zero, and the alternate 32bit field
     * DOS_BOOT_LONG_NSECTORS is used to determine the number of
     * sectors on the volume.
     */

    if (0 == work)  /* disk has 0x10000 or more sectors */
        {
        work = dosfsDiskToHost32 (pBootBuf + DOS_BOOT_LONG_NSECTORS);
        }

    totalSecs = work; /* total sectors on volume */

    /* cannot have a device with zero sectors */

    if (0 == totalSecs)
        {
        return (ERROR);
        }

    /*
     * Determine if we are mounting a VxWorks DOSFS 1.0 file system.
     * This is done because VxWorks DOSFS 1.0 uses a different
     * FAT mounting formula than is recommended by Microsoft today.
     * We must account for this, or errors will occur in the FAT type
     * calculation, causing us to fail to correctly mount VxWorks DOSFS 1.0
     * volumes on some 12/16 boundary cases.
     * We check for one of two possible VxWorks DOSFS 1.0 signature strings.
     * VxWorks DOSFS 1.0 will have "VXDOS1.0" for 8.3 filenames.
     * VxWorks DOSFS 1.0 will have "VXEXT1.0" for VxLongnames.
     */

    if ((bcmp((char *) pBootBuf + DOS_BOOT_SYS_ID, (char *) dosFs1SysId,
              (int) (strlen(dosFs1SysId))) == 0)     ||
        (bcmp((char *) pBootBuf + DOS_BOOT_SYS_ID, (char *) dosFs1ExtSysId,
              (int) (strlen(dosFs1ExtSysId))) == 0))
        {
        vxDOSFS1Vol = TRUE;  /* using Kents VxLongs */
        }
    else /* presume not VxLongnames */
        {
        vxDOSFS1Vol = FALSE; /* standard 8.3 */
        }

    /*
     * Determine the directory entry size to use.  Check for the "VXEXT"
     * string, if present then use longnames dirent size, else use
     * the standard 8.3 dirent size.  We only check the first 5 chars
     * so we cant get both versions, "VXEXT1.0" and "VXEXT1.1".
     * Yes, the FAT type mounting differs if using 1.1, this is intentional.
     */

    if (bcmp((char *) pBootBuf + DOS_BOOT_SYS_ID,
              (char *) DOS_VX_LONG_NAMES_SYS_ID,
              (int) strlen(DOS_VX_LONG_NAMES_SYS_ID)) == 0)
        {
        dirEntSz = DOS_VX_DIRENT_LEN;   /* 64 bytes using Kents VxLongs */
        }
    else
        {
        dirEntSz = DOS_DIRENT_STD_LEN; /* 32 bytes using standard 8.3 */
        }

    /* Determine the number of bytes per sector on this volume */

    bytesPerSec = dosfsDiskToHost16 (pBootBuf + DOS_BOOT_BYTES_PER_SEC);

    /* cannot have zero bytes per sector */

    if (0 == bytesPerSec)
        return (ERROR);

    /* Determine the number of root directory entries on this volume */

    nRootEnts = dosfsDiskToHost16 (pBootBuf + DOS_BOOT_MAX_ROOT_ENTS);

    /* cannot have zero root directory entries */

    if (0 == nRootEnts)
        return (ERROR);

    /* Determine the number of sectors per cluster */

    secsPerClust = pBootBuf [DOS_BOOT_SEC_PER_CLUST];

    /* cannot have zero sectors per cluster */

    if (0 == secsPerClust)
        return (ERROR);

    /* determine the number of FAT copies */

    nFats = pBootBuf [DOS_BOOT_NFATS];

    /* cannot have zero number of FAT copies */

    if (0 == nFats)
        return (ERROR);

    /* determine the number of reserved sectors */

    reservedSecs = dosfsDiskToHost16 (pBootBuf + DOS_BOOT_NRESRVD_SECS);

    /* determine the number of sectors alloted to FAT table */

    secsPerFat = dosfsDiskToHost16 (pBootBuf + DOS_BOOT_SEC_PER_FAT);

    /* cannot have zero sectors per FAT */

    if (0 == secsPerFat)
        return (ERROR);

    /* All needed fields have been stored, now determine the FAT type */

    if (FALSE == vxDOSFS1Vol)
        {
        /*
         * Were not mounting a VxWorks DOSFS 1.0 volume.
         * We will use the formula recommended by Microsoft.
         */

        /* Determine the sectors used by root directory, this rounds up */

        rootDirSecs = ((nRootEnts * dirEntSz)+(bytesPerSec-1)) / bytesPerSec;

        /* determine the total count of sectors in volumes data region */

        dataRgnSecs =
        totalSecs - (reservedSecs + (nFats * secsPerFat) + rootDirSecs);

        /* determine the count of clusters, this rounds down. */

        countOfClusts = dataRgnSecs / secsPerClust;

        /*
         * Determine FAT type based on the count of clusters.
         * Return TRUE for FAT12, FALSE for FAT16.
         */

        return (countOfClusts < (u_int) DOS_FAT_12BIT_MAX);
        }

    /*
     * (TRUE == vxDOSFS1Vol)
     *
     * Mounting VxWorks DOSFS 1.0 volume, use VxDOSFS 1.0 method.
     * This VxWorks DOSFS1 method is per dosFsVolDescFill(), dosFsLib.c
     * dosFs 1.0 version "03l,16mar99,dgp".
     *
     * Note that some variables below are used a bit differently than
     * in the Microsoft method above.
     */

    /* Determine the starting sector of the root dir  */

    rootDirSecs = reservedSecs + (nFats * secsPerFat);

    /* Determine the size of the root dir in bytes */

    work = (nRootEnts * dirEntSz);

    /* Determine the starting sector of the data area */

    dataRgnSecs = rootDirSecs + ((work + bytesPerSec-1) / bytesPerSec);

    /* Determine the number of FAT entries */

    countOfClusts = (((totalSecs - dataRgnSecs)/ secsPerClust)+DOS_MIN_CLUST);

    /*
     * Choose the FAT type based on countOfClusts, note VxDOSFS1
     * uses less than or equal here.
     */

    return (countOfClusts <= (u_int) DOS_FAT_12BIT_MAX);
    } /* dosFsVolIsFat12 */

/*******************************************************************************
*
* dosFsVolMount - prepare to use dosFs volume
*
* This routine prepares the library to use the dosFs volume on the
* device specified.  The first sector, known as the boot sector,
* is read from the disk.  The required information in the boot sector
* is copied to the volume descriptor for this device.
* Some other fields in the volume descriptor
* are set using values calculated from the boot sector information.
*
* The appropriate File Allocation Table (FAT) handler and directory
* handler  are chosen from handlers list in accordance with
* particular volume format version and user's preferences.
*
* This routine is automatically called via first open() if device not
* mounted and every time after a disk is changed.
*
* This routine is split into 2 parts: dosFsVolMountPart1 and
* dosFsVolMountPart2. Part1 does most of the mounting work, while part2
* takes charge of disk checking.
*
* RETURNS: OK or ERROR.
*
* ERRNO:
* S_dosFsLib_INVALID_PARAMETER
*
*/

LOCAL STATUS dosFsVolMount
    (
    DOS_VOLUME_DESC_ID  pVolDesc    /* pointer to volume descriptor */
    )
    {
    if (dosFsVolMountPart1 (pVolDesc) == OK)
        return (dosFsVolMountPart2 (pVolDesc));

    return (ERROR);
    } /* dosFsVolMount() */

/*******************************************************************************
*
* dosFsVolMountPart1 - prepare to use dosFs volume--stage1
*
* This routine prepares the library to use the dosFs volume on the
* device specified.  The first sector, known as the boot sector,
* is read from the disk.  The required information in the boot sector
* is copied to the volume descriptor for this device.
* Some other fields in the volume descriptor are set using values
* calculated from the boot sector information.
*
* The appropriate File Allocation Table (FAT) handler and directory
* handler  are chosen from handlers list in accordance with
* particular volume format version and user's preferences.
*
* RETURNS: OK or ERROR.
*
* ERRNO:
* S_dosFsLib_INVALID_PARAMETER
*
*/

LOCAL STATUS dosFsVolMountPart1
    (
    DOS_VOLUME_DESC_ID  pVolDesc    /* pointer to volume descriptor */
    )
    {
    u_int   errnoBuf = errnoGet();
    int i;

    /* check volume descriptor */

    if ((pVolDesc == NULL) || (pVolDesc->magic != DOS_FS_MAGIC))
        {
        errnoSet(S_dosFsLib_INVALID_PARAMETER);
        return (ERROR);
        }

    /* prevent mount process from reentrant call */

    if (semTake (pVolDesc->devSem, WAIT_FOREVER) == ERROR)
        return (ERROR);

    /*
     * before we can mount new volume
     * we have to unmount previous one
     */

    if (pVolDesc->mounted)
        dosFsVolUnmount (pVolDesc);

    pVolDesc->mounted = FALSE;

    /* update and check base volume information from boot sector */
    errnoSet (OK);

    if (dosFsBootSecGet (pVolDesc) == ERROR)
        {
        if (errnoGet () == OK)
            errnoSet (S_dosFsLib_UNKNOWN_VOLUME_FORMAT);
        semGive (pVolDesc->devSem);
        return (ERROR);
        }
    /*
     * init DIRECTORY handler ahead FAT, because
     * directory handler finally sets "data start sector" field,
     * that depends for FAT12/FAT16 root directory size in sectors
     */

    /* dir handler mount */

    for (i = 0; i < (int) NELEMENTS (dosDirHdlrsList); i ++)
        {
        if ((dosDirHdlrsList[i].mountRtn != NULL) &&
            (dosDirHdlrsList[i].mountRtn (pVolDesc,
                                            dosDirHdlrsList[i].arg) == OK))
            {
            break;
            }
        }

    if (i == NELEMENTS (dosDirHdlrsList))
        {
        semGive (pVolDesc->devSem);
        return (ERROR);
        }
    /* FAT handler mount */

    for (i = 0; i < (int) NELEMENTS (dosFatHdlrsList); i++)
        {
        if ((dosFatHdlrsList[i].mountRtn != NULL) &&
            (dosFatHdlrsList[i].mountRtn(pVolDesc,
                                           dosFatHdlrsList[i].arg) == OK))
            {
            errnoSet (errnoBuf);
            pVolDesc->mounted = TRUE;
            return (OK);
            }
        }

    semGive (pVolDesc->devSem);
    return (ERROR);
    } /* dosFsVolMountPart1() */

/*******************************************************************************
*
* dosFsVolMountPart2  - prepare to use dosFs volume--stage 2
*
* This routine is called after dosFsVolMountPart1(), it does the check-disk
* if supported and the rest of the mounting.
*
* RETURNS: OK or ERROR.
*
* /NOMANUAL
*/

LOCAL STATUS dosFsVolMountPart2
    (
    DOS_VOLUME_DESC_ID  pVolDesc    /* pointer to volume descriptor */
    )
    {
    DOS_FILE_DESC_ID    pFd = (void *)ERROR;


    /* execute device integrity check (if not started yet) */

    /*
     * It may seem, that following call to open() while device
     * semaphore is taken can cause deadlock because during
     * open() a file handle semaphore possibly is taken.
     * But don't worry. First, file semaphore is taken only
     * when open() has been called with O_TRUNC or DOS_O_CONTIG_CHK
     * flags, second, all opened file handles have been
     * marked obsolete already and so no one of them will be
     * actually shared.
     */

    if ((dosFsChkRtn != NULL) && (pVolDesc->autoChk != 0) &&
        (pVolDesc->chkFlags == 0))
        {
        pFd = dosFsOpen (pVolDesc, "", 0, 0);
        if (pFd != (void *) ERROR)
            {
            if ((dosFsChkDsk (pFd, pVolDesc->autoChk |
                                  (pVolDesc->autoChkVerb << 8)) != OK) &&
                ((pVolDesc->autoChk & DOS_CHK_REPAIR) != 0))
                {
                pVolDesc->mounted = FALSE;
                goto ret;
                }
            }
        }
    /* re-mount disk cache routines if already supported by this volume*/

    if (dosFsCacheMountRtn != NULL)
        dosFsCacheMountRtn (pVolDesc);

ret:
    if (pFd != (void *) ERROR)
        {
        pFd->pFileHdl->obsolet = 0; /* avoid errno set */
        dosFsClose (pFd);
        }

    /*
     * Before releasing the device semaphore, tell the file system
     * that it is "in use for real", if it is (i.e., if it is now
     * mounted).  This gives it a chance to mark the file system as
     * "no longer clean", for instance.  (We really should do this
     * based on the number of valid-for-write file handles, perhaps.)
     */

    if (pVolDesc->mounted && pVolDesc->mountActivate != NULL)
        (*pVolDesc->mountActivate) (pVolDesc);

    semGive (pVolDesc->devSem);

    if (pVolDesc->mounted)
        return (OK);
    return (ERROR);
    } /* dosFsVolMountPart2() */

/***************************************************************************
*
* dosFsFdFree - free a file descriptor
*
* This routine marks a file descriptor as free and decreases
* reference count of a referenced file handle.
*
* RETURNS: N/A.
*
* /NOMANUAL
*/

void dosFsFdFree
    (
    DOS_FILE_DESC_ID    pFd
    )
    {
    DOS_VOLUME_DESC_ID  pVolDesc;

    assert (pFd != NULL);
    pVolDesc = pFd->pVolDesc;

    DBG_MSG (600, "pFd = %p\n", pFd, 0, 0, 0, 0, 0, 0, 0);

    if (semTake (pFd->pVolDesc->devSem, WAIT_FOREVER) != OK)
        {
        ERR_MSG(1, "\a dosFsFdFree() can not take the semphore \a\n", 0,0,0,0,0,0);
        return;
        }

    assert (pFd->pFileHdl->nRef != 0);
    pFd->pFileHdl->nRef --;

    pFd->busy = 0;
    semGive (pVolDesc->devSem);
    } /* dosFsFdFree() */

/***************************************************************************
*
* dosFsFdGet - get an available file descriptor
*
* This routine obtains a free dosFs file descriptor.
*
* RETURNS: Pointer to file descriptor, or NULL, if none available.
*
* ERRNO:
* S_dosFsLib_NO_FREE_FILE_DESCRIPTORS
*
* /NOMANUAL
*/

DOS_FILE_DESC_ID dosFsFdGet
    (
    DOS_VOLUME_DESC_ID      pVolDesc
    )
    {
    FAST DOS_FILE_DESC_ID   pFd = pVolDesc->pFdList;
    FAST DOS_FILE_DESC_ID   pFdFree = NULL;
    FAST DOS_FILE_HDL_ID    pFileHdl = pVolDesc->pFhdlList;
    FAST DOS_FILE_HDL_ID    pFileHdlFree = NULL;

    if (semTake (pVolDesc->devSem, WAIT_FOREVER) == ERROR)
        return (NULL);

    /* allocate file descriptor */

    for (pFd = pVolDesc->pFdList;
         pFd < pVolDesc->pFdList + pVolDesc->maxFiles; pFd++)
        {
        if (!pFd->busy)
            {
            pFdFree = pFd;
            break;
            }
        }

    if (pFdFree == NULL)
        {
        errnoSet (S_dosFsLib_NO_FREE_FILE_DESCRIPTORS);
        pFd = NULL;
        goto ret;
        }

    DBG_MSG (600, "pFdFree = %p\n", pFdFree, 0, 0, 0, 0, 0, 0, 0);

    bzero ((char *) pFdFree, sizeof (*pFdFree));
    pFdFree->pVolDesc = pVolDesc;
    pFdFree->busy = TRUE;
    pFdFree->pVolDesc->nBusyFd ++;

    /* allocate file handle */

    for (pFileHdl = pVolDesc->pFhdlList;
         pFileHdl < pVolDesc->pFhdlList + pVolDesc->maxFiles;
         pFileHdl++)
        {
        if (pFileHdl->nRef == 0)
            {
            pFileHdlFree = pFileHdl;
            break;
            }
        }

    assert (pFileHdlFree != NULL);

    bzero ((char *) pFileHdlFree, sizeof (*pFileHdlFree));

    pFileHdlFree->nRef = 1;
    pFdFree->pFileHdl = pFileHdlFree;

    DBG_MSG (600, "pFileHdlFree = %p\n", pFileHdlFree, 0, 0, 0, 0, 0, 0, 0);

ret:
    semGive (pVolDesc->devSem);
    return (pFdFree);
    } /* dosFsFdGet() */

/***************************************************************************
*
* dosFsHdlDeref - unify file descriptors of the same file.
*
* All file descriptors, that are opened for one file
* have to share the same file handle in order to
* prevent confusion when file is changed and accessed through
* several file descriptors simultaneously.
*
* This routine lookups throw list of file handles and
* references <pFd> to the file handle, that already describes the
* same file, if such exists. File handle, that has been used
* by <pFd> is freed.
*
* RETURNS: N/A.
*
* /NOMANUAL
*/

LOCAL void dosFsHdlDeref
    (
    DOS_FILE_DESC_ID    pFd
    )
    {
    FAST DOS_VOLUME_DESC_ID pVolDesc = pFd->pVolDesc;
    FAST DOS_DIR_HDL_ID     pDirHdlFd = & pFd->pFileHdl->dirHdl;
                            /* dir handle ptr */
    FAST DOS_FILE_HDL_ID    pFhdlLCur = pVolDesc->pFhdlList;
                            /* loop file handle */
    FAST DOS_DIR_HDL_ID     pDirHdlCur = NULL;
                            /* dir handle of the */
                            /* loop file handle */
    FAST int    i;          /* loop counter */

    if (semTake(pVolDesc->devSem, WAIT_FOREVER) != OK)
        {
        ERR_MSG(1, "\a dosFsHdlReref() can not take the semphore \a\n", 0,0,0,0,0,0);
        return;
        }

    /* loop by file handles list */

    for (i = 0; i < pVolDesc->maxFiles; i++, pFhdlLCur++)
        {
        if ((pFhdlLCur->nRef == 0) || (pFhdlLCur == pFd->pFileHdl) ||
            (pFhdlLCur->deleted) || (pFhdlLCur->obsolet))
            {
            continue;
            }

        /* compare directory handles */

        pDirHdlCur = & pFhdlLCur->dirHdl;

        if ((pDirHdlCur->sector == pDirHdlFd->sector) &&
            (pDirHdlCur->offset == pDirHdlFd->offset))
            {
            /* the same directory entry */

            assert (pDirHdlCur->parDirStartCluster ==
                    pDirHdlFd->parDirStartCluster);
            DBG_MSG (600, " use %p instead of %p\n",
                     pFhdlLCur, pFd->pFileHdl, 0, 0, 0, 0, 0, 0);

            /* free file handle in <pFd> */

            assert (pFd->pFileHdl->nRef == 1);
            bzero ((char *) pFd->pFileHdl, sizeof (*pFd->pFileHdl));

            /* deference <pFd> */

            pFd->pFileHdl = pFhdlLCur;
            pFhdlLCur->nRef ++;
            break;
            }
        }
    semGive (pVolDesc->devSem);
    } /* dosFsHdlDeref() */

/***************************************************************************
*
* dosFsSeek - change file's current character position
*
* This routine sets the specified file's current character position to
* the specified position.  This only changes the pointer, doesn't affect
* the hardware at all.
*
* If the new offset pasts the end-of-file (EOF), attempts to read data
* at this location will fail (return 0 bytes).
*
* For a write if the seek is done past EOF, then use dosFsFillGap
* to fill the remaining space in the file.
*
* RETURNS: OK, or ERROR if invalid file position.
*
* ERRNO:
* S_dosFsLib_NOT_FILE
*
* /NOMANUAL
*/

LOCAL STATUS dosFsSeek
    (
    DOS_FILE_DESC_ID    pFd,    /* file descriptor pointer */
    fsize_t             newPos  /* ptr to desired character */
                                /* position in file */
    )
    {
    fsize_t     sizeBuf = (fsize_t) pFd->pFileHdl->size;
                                /* backup directory size */
    sector_t    nSec;           /* sector offset of new position */
                                /* from seek start sector */
    sector_t    startSec;       /* cluster number to count clusters from */
    fsize_t     pos2;           /* position for underlying fat-seek */
    STATUS      retStat = ERROR;

    DBG_MSG (500, "pFd = %p: newPos = %lu, "
             "current pos = %lu, size = %lu\n",
             pFd, newPos, pFd->pos, pFd->pFileHdl->size, 0, 0, 0, 0);

    pFd->seekOutPos = 0;

    /*
     * If we are not changing positions and the current sector is known,
     * there is no work to do.
     */

    if ((newPos == pFd->pos) && (pFd->curSec > 0))
        return (OK);

    /*  there is no field storing actual directory length */

    if (pFd->pFileHdl->attrib & DOS_ATTR_DIRECTORY)
        {
        pFd->pFileHdl->size = (fsize_t) DOS_MAX_FSIZE;
        }

    /*
     * If attempting to seek past EOF, only store the new position.  In
     * an exception that perhaps never occurs, if the current position
     * is unknown (curSec <= 0), we subsequently seek here to pFd->pos,
     * so that the current position (pFd->curSec) becomes known.
     */

    if (newPos > pFd->pFileHdl->size)
        {
        pFd->seekOutPos = newPos;
        if (pFd->curSec > 0)
            return OK;
        newPos = pFd->pos;
        }

    /*
     * pFd->curSec is invalid if pFd->nSec == 0. This is because in
     * dosFsFileRW() a look into the cluster chain is avoided when a R/W
     * finished on a cluster boundary.
     */

    if ((pFd->curSec > 0) && (pFd->pos != 0) && (pFd->nSec == 0))
        {
        /* contiguous block exhausted */

        pFd->nSec    = 1;
        pFd->curSec -= 1;
        pFd->pos    -= (fsize_t)(pFd->nSec << pFd->pVolDesc->secSizeShift);
        }

    /*
     * Compute target for fatSeek function: new position, or last
     * byte of file, whichever comes first.  If the last byte of the
     * file is nonexistent (i.e., the file is empty), just seek to 0.
     * By seeking to the last byte of the file, we make sure we know
     * which is the final cluster (so that it can be marked "EOF").
     *
     * Note that pos2 != newPos (i.e., pos2 > newPos) if and only
     * if newPos == pFd->pFileHdl->size && pFd->pFileHdl->size > 0.
     */

    if ((pos2 = pFd->pFileHdl->size) != 0)
        pos2--;
    if (newPos < pos2)
        pos2 = newPos;

    /*
     * Count number of sectors to move and check for seek within
     * current contiguous block.  Current position unknown, and some backwards
     * seeks, require starting from the beginning of the file,
     * otherwise seek forward from where we are now.
     */

    if (pFd->curSec == 0) /* current position unknown */
        {
        /* number of sector from file start to move to */

        nSec = NSECTORS (pFd->pVolDesc, pos2);

        /* begin seeking from file start */

        startSec = FH_FILE_START;
        DBG_MSG (550, "SEEK_SET : startClust = %lu\n",
                 pFd->pFileHdl->startClust, 0, 0, 0, 0, 0, 0, 0);
        }
    else if (pos2 < pFd->pos) /* backwards seek */
        {
        /*
         * A new variable is not really needed here, but it makes
         * the code easier to understand, which BTW, is desperately needed
         * in this library.
         */

        fsize_t   nSecNewPos;

        nSecNewPos = NSECTORS (pFd->pVolDesc, pos2);
        nSec = NSECTORS (pFd->pVolDesc, pFd->pos);

        nSec = nSec - nSecNewPos;

        /*
         * If we are backing up within a contiguous set of sectors, simply
         * get to the proper sector and we're done.  For this to be the
         * case we have to know where we are (pFd->curSec != 0) and where
         * the contiguous range starts (pFd->startContigSec != 0), of
         * course.  We already checked pFd->curSec != 0 above.  We must
         * make sure that pFd->curSec exceeds nSec, though, lest the
         * subtraction result in a negative number, which due to unsigned
         * arithmetic becomes a huge positive number.
         */

        if (pFd->startContigSec != 0 &&
            pFd->curSec > nSec &&
            (pFd->curSec - nSec) >=  pFd->startContigSec)
            {
            pFd->nSec   += (u_int)nSec;
                pFd->curSec -= nSec;
            goto retOK;
            }
        /* not within contiguous set of sectors */
        nSec = NSECTORS(pFd->pVolDesc, pos2);

        /* begin seeking from file start */

        pFd->contigEndPlus1 = 0;
        startSec = FH_FILE_START;
        }

    else    /* forward */
        {
        fsize_t   nSecCurPos;

        /* number of sectors from current position. */

        nSecCurPos = NSECTORS (pFd->pVolDesc, pFd->pos);
        nSec = NSECTORS (pFd->pVolDesc, pos2);

        nSec = nSec - nSecCurPos;

        if (nSec < pFd->nSec)  /* within current block ? */
            {
            pFd->nSec   -= (u_int)nSec;
            pFd->curSec += nSec;
            DBG_MSG (500, "within current cluster group\n",
                     0, 0, 0, 0, 0, 0, 0, 0);
            goto retOK;
            }

        /* begin seeking from current sector */

        startSec = pFd->curSec;
        DBG_MSG (550, "SEEK_CUR : startSec = %lu\n",
                 startSec, 0, 0, 0, 0, 0, 0, 0);
        }

    /* go !*/

    if (pFd->pVolDesc->pFatDesc->seek (pFd, startSec, nSec) == ERROR)
        {
        goto ret;
        }

retOK:
    pFd->pos = newPos;
    retStat = OK;

    /*
     * If pos2 != newPos, we were asked to seek to the last byte of the
     * file but instead did a seek to last-byte-minus-1.  In this case,
     * step forward.  Stepping forward is a no-op (because we already
     * set pFd->pos to newPos, not pos2) unless the new offset is an
     * even multiple of a sector: in this last case we have to step
     * one sector too.
     */

    if (pos2 != newPos && OFFSET_IN_SEC(pFd->pVolDesc, newPos) == 0)
        {
        pFd->nSec --;
        pFd->curSec ++;
        }

ret:
    pFd->pFileHdl->size = (fsize_t) sizeBuf;
    return retStat;
    } /* dosFsSeek() */

/***************************************************************************
*
* dosFsSeekDir - set current offset in directory.
*
* This routine sets current offset in directory.  It takes special
* care of contiguous root.
*
* File semaphore should be taken prior calling this routine.
*
* RETURNS: OK or ERROR, if seek is out of directory chain.
*
* /NOMANUAL
*/

LOCAL STATUS dosFsSeekDir
    (
    DOS_FILE_DESC_ID    pFd,    /* pointer to file descriptor */
    DIR *   pDir                /* seek for dd_cookie position */
    )
    {
    fsize_t newOffset = (fsize_t)(DD_COOKIE_TO_POS(pDir));

    if (pFd->pos == newOffset) /* at the place */
        return (OK);

    /* special process for contiguous root */

    if (IS_ROOT (pFd) && (pFd->pVolDesc->pDirDesc->rootNSec > 0))
        {
        /* check for seek out of root */

        if (newOffset >= (pFd->pVolDesc->pDirDesc->rootNSec <<
                          pFd->pVolDesc->secSizeShift))
            {
            errnoSet (S_dosFsLib_INVALID_PARAMETER);
            return (ERROR);
            }

        pFd->pos = newOffset;
        newOffset = NSECTORS (pFd->pVolDesc, newOffset);
        pFd->curSec = pFd->pVolDesc->pDirDesc->rootStartSec + newOffset;
        pFd->nSec = (u_int)(pFd->pVolDesc->pDirDesc->rootNSec - newOffset);

        return (OK);
        }

    /* regular directory */

    return dosFsSeek (pFd, (fsize_t) newOffset);
    } /* dosFsSeekDir() */

/***************************************************************************
*
* dosFsIsDirEmpty - check if directory is empty.
*
* This routine checks if directory is not a root directory and
* whether it contains entries unless "." and "..".
*
* RETURNS: OK if directory is empty and not root, else ERROR.
*
* ERRNO:
* S_dosFsLib_DIR_NOT_EMPTY
*
* /NOMANUAL
*/

LOCAL STATUS dosFsIsDirEmpty
    (
    DOS_FILE_DESC_ID    pFd        /* pointer to file descriptor */
    )
    {
    DOS_DIR_DESC_ID pDirDesc = pFd->pVolDesc->pDirDesc;
    DIR     dir;                    /* use readDir calls */
    DOS_FILE_DESC   workFd = * pFd; /* working file descriptor */

    assert (pFd->pFileHdl->attrib & DOS_ATTR_DIRECTORY);

    if (IS_ROOT (pFd))
        goto ret;   /* root directory */

    dir.dd_cookie = 0;  /* rewind dir */
    dir.dd_eof = FALSE;

    /* pass "." and ".." */

    if ((pDirDesc->readDir (&workFd, &dir, NULL) == ERROR) ||
        (pDirDesc->readDir (&workFd, &dir, NULL) == ERROR))
        return (ERROR);   /* illegal directory */

    /* try to get one more entry */

    if (pDirDesc->readDir (&workFd, &dir, NULL) == ERROR)
        return (OK);  /* no more entries */

    /* Check to see if end of directory reached */
    if (dir.dd_eof)
        return (OK);  /* no more entries */

    DBG_MSG (500, "name = %s\n", dir.dd_dirent.d_name,0, 0, 0, 0, 0, 0, 0);

ret:
    errnoSet (S_dosFsLib_DIR_NOT_EMPTY);
    return (ERROR);
    } /* dosFsIsDirEmpty() */

/***************************************************************************
*
* dosPathParse - parse a full pathname into an array of names.
*
* This routine is similar to pathParse(), but on the contrary it does not
* allocate additional buffers nor changes the path string.
*
* Parses a path in directory tree which has directory names
* separated by '/' or '\'s.  It fills the supplied array of
* structures with pointers to directory and file names and
* correspondence name length.
* All occurrences of '//', '.' and '..'
* are right removed from path. All tail dots and spaces are broken from
* each name, that is name like "abc. . ." is treated as just "abc".
*
* For instance, "/usr/vw/data/../dir/file" gets parsed into
*
* .CS
*                          namePtrArray
*                         |---------|
*   ---------------------------o    |
*   |                     |    3    |
*   |                     |---------|
*   |   -----------------------o    |
*   |   |                 |    2    |
*   |   |                 |---------|
*   |   |          ------------o    |
*   |   |          |      |    3    |
*   |   |          |      |---------|
*   |   |          |   --------o    |
*   |   |          |   |  |    4    |
*   |   |          |   |  |---------|
*   v   v          v   v  |   NULL  |
*   |   |          |   |  |    0    |
*   |   |          |   |  |---------|
*   v   v          v   v
*  |------------------------|
*  |usr/vw/data/../dir/file |
*  |-------\-----/----------|
*          ignored
* .CE
*
* Note that UTF-8 bytes that are not representing ASCII characters '.',
* '/', etc., never compare equal to '.', '/', etc., so that no special
* work is required here for Unicode.
*
* In the future, the "../" erasure trick is likely to vanish.  Do not
* rely on the fact that you can currently access "nosuchdir/../file.txt"
* when "nosuchdir" does not exist.
*
* RETURNS: number of levels in path.
*
* ERRNO:
* S_dosFsLib_ILLEGAL_PATH
* S_dosFsLib_ILLEGAL_NAME
*/

int dosPathParse
    (
    u_char *     path,
    PATH_ARRAY * pnamePtrArray,
    size_t       sizeArray
    )
    {
    u_int      numPathLevels;
    u_char *   pName;
    u_char *   pRegChar; /* last not DOT and not SPACE char */

    /* sizeArray must be at least 1. */

    pnamePtrArray[0].pName = NULL;

    /* go through path string from left to right */

    pName = path;
    numPathLevels = 0;
    while (*pName != EOS)  /* there is 'break' in loop also */
        {
        /* pass slashes */

        if ((*pName == SLASH) || (*pName == BACK_SLASH))
            {
            pName++;
            continue;
            }

        /* process special names ("." "..") */

        if (*pName == DOT)
            {
            /* "/./" - ignore "current directory" */
            if ((*(pName + 1) == EOS) || (*(pName + 1) == SLASH) ||
                (*(pName + 1) == BACK_SLASH))
                {
                pName ++;
                continue;
                }

            /* "/../" - goto one level back */

            if ((*(pName + 1) == DOT) &&
                ((*(pName + 2) == EOS) || (*(pName + 2) == SLASH) ||
                (*(pName + 2) == BACK_SLASH)))
                {
                if (numPathLevels > 0)
                    numPathLevels --;
                pName += 2;
                continue;
                }
            } /* if (*pName == DOT) */

        /* regular name: insert it into array */

        if (numPathLevels + 1 >= sizeArray)
            break;  /* max level overloaded */

        pnamePtrArray[numPathLevels].pName = pName;
        pnamePtrArray[numPathLevels + 1].pName = NULL;
        pRegChar = NULL;
        while ((*pName != SLASH) && (*pName != BACK_SLASH) &&
               (*pName != EOS))
            {
            if ((*pName != DOT) && (*pName != SPACE))
                pRegChar = pName;
            pName++;
            }

        /* name can not contain only dots */

        if (pRegChar == NULL)
            {
            errnoSet (S_dosFsLib_ILLEGAL_NAME);
            return (ERROR);
            }

        pnamePtrArray[numPathLevels].nameLen =
            (u_short)(pRegChar + 1 - pnamePtrArray[numPathLevels].pName);

        numPathLevels++;
        } /* while(*pName != EOS) */

    /* check result */

    if (*pName != EOS)  /* path termination has not been reached */
        {
        errnoSet (S_dosFsLib_ILLEGAL_PATH);
        return (ERROR);
        }

#ifdef DEBUG
    if (dosFsDebug >= 600)
        {
        int     i;
        u_char *str;
        u_char *strEnd;
        u_char  ch;

        DBG_MSG (600, "path: %s, result: \n", path, 0, 0, 0, 0, 0, 0, 0);
        for (i = 0; i < numPathLevels; i++)
            {
            str = pnamePtrArray[i].pName;
            strEnd = &str[pnamePtrArray[i].nameLen];
            ch = *strEnd;
            *strEnd = EOS;
            printErr ("%d : %s : ", i + 1, str);
            }
        printErr ("\b\b \n");
        }
#endif /* DEBUG */

    return (numPathLevels);
    } /* dosPathParse() */


/***************************************************************************
*
* dosFsTrunc - truncate a file.
*
* This routine is called via an ioctl(), using the FIOTRUNC
* function and from dosFsOpen(), when called with O_TRUNC flag.
* It causes the file specified by the file descriptor to be changed
* to the specified <newLength>.  The directory entry for the file is
* updated to reflect the new length.
*
* RETURNS: OK or ERROR, if pFd is opened for directory, or new size
* greater than the current size, or a disk access error occurs.
*
* ERRNO:
* S_dosFsLib_NOT_FILE
* S_dosFsLib_INVALID_NUMBER_OF_BYTES
* S_dosFsLib_READ_ONLY
*
*/

LOCAL STATUS dosFsTrunc
    (
    DOS_FILE_DESC_ID    pFd,        /* pointer to file descriptor */
    fsize_t             newLength   /* requested new file length */
    )
    {
    DOS_VOLUME_DESC_ID  pVolDesc = pFd->pVolDesc;
    DOS_FILE_HDL_ID     pFileHdl = pFd->pFileHdl;
    fsize_t             saved_pos;
    fsize_t             saved_seekOut;
    STATUS              status = OK;
    fsize_t             work;

    assert(pVolDesc->magic == DOS_FS_MAGIC);
    assert(pFd - pFd->pVolDesc->pFdList < pFd->pVolDesc->maxFiles);
    assert(pFd->pFileHdl - pFd->pVolDesc->pFhdlList <
           pFd->pVolDesc->maxFiles);

    /* check for directory truncation */

    if (pFileHdl->attrib & DOS_ATTR_DIRECTORY)
        {
        errnoSet(S_dosFsLib_NOT_FILE);
        return ERROR;
        }

    if (pFileHdl->size == newLength)   /* nothing to do */
        return OK;

    /* Check that file is not read only */

    if ((pFd->openMode & _FWRITE) == 0)
        {
        errnoSet (S_dosFsLib_READ_ONLY);
        return ERROR;
        }

    DBG_MSG(500, "pFd:pFileHdl = %p:%p, newLength = %lu, size = %lu\n",
            pFd, pFileHdl, newLength, pFileHdl->size,0,0,0,0);

    /* Need the semaphore */

    if (dosFsFSemTake(pFd, WAIT_FOREVER) == ERROR)
        return ERROR;

    /* Save the current offset - will reset to this afterwards */

    saved_pos = pFd->pos;

    if (newLength < pFileHdl->size)  /* We are shrinking */
        {
        /*
         * If saved seek pointer is in area to be freed, set to what
         * will become the final byte.
         */
        if (saved_pos > newLength)
            saved_pos = newLength;

        if (newLength == 0)
            {
            /* First seek to the 0 position */
            status = dosFsSeek(pFd, 0);
            if (status != OK)
                goto error_cleanup;

            if (pFileHdl->startClust != 0)
                {
                status = pVolDesc->pFatDesc->truncate(pFd, FH_FILE_START, FH_INCLUDE);
                if (status != OK)
                    {
                    DBG_MSG(0, "Error truncating directory entry, pFileHdl = %p\n",
                        pFileHdl,0,0,0,0,0,0,0);
                    goto error_cleanup;
                    }
                }
            pFileHdl->size = (fsize_t) newLength;
            pFileHdl->startClust = 0;
            if (pVolDesc->pDirDesc->updateEntry(pFd, DH_TIME_MODIFY |
                                     DH_TIME_ACCESS, 0) != OK)
                {
                DBG_MSG(0, "Error updating directory entry, pFileHdl = %p\n",
                    pFileHdl,0,0,0,0,0,0,0);
                goto error_cleanup;
                }
            }
        else
            {
            /* Seek into the last desired position */

            work = (fsize_t) (newLength - 1);
            status = dosFsSeek(pFd, work);
            if (status != OK)
                goto error_cleanup;

            /* For checkdisk, we update directory entry before shrinking */

            pFileHdl->size = (fsize_t) newLength;

            if (pVolDesc->pDirDesc->updateEntry(pFd, DH_TIME_MODIFY |
                                         DH_TIME_ACCESS, 0) != OK)
                {
                DBG_MSG(0, "Error updating directory entry, pFileHdl = %p\n",
                    pFileHdl,0,0,0,0,0,0,0);
                goto error_cleanup;
                }

            /* Force the sector to a file start if it is a 0-lenght file */
            /* Return clusters after seek pointer */

            status = pVolDesc->pFatDesc->truncate(pFd, pFd->curSec, FH_EXCLUDE);
            if (status != OK)
                goto error_cleanup;
            }

        /* Reset seekOutPos to zero */

        pFd->seekOutPos = 0;
        }
    else                              /* We are expanding */
        {
        /* For checkdisk, we expand before updating directory entry */

        /* Set ->seekOutPos to desired final location */

        saved_seekOut = pFd->seekOutPos;  /* For error handling */
        pFd->seekOutPos = newLength;

        /*
         * dosFsFillGap() will set seek position to end of file first and
         * then fill until pFd->seekOutPos.
         */

        status = dosFsFillGap(pFd, (UINT)FAT_ALLOC);
        if (status != OK)
            {
            pFd->seekOutPos = saved_seekOut;
            goto error_cleanup;
            }

        pFileHdl->size = (fsize_t) newLength;

        if (OK != pVolDesc->pDirDesc->updateEntry(pFd,
                DH_TIME_MODIFY |
                DH_TIME_ACCESS,
                0))
            {
            DBG_MSG(0, "Error updating directory entry, pFileHdl = %p\n",
                pFileHdl,0,0,0,0,0,0,0);
            goto error_cleanup;
            }
        }

    /* Restore saved seek pointer */

    status = dosFsSeek(pFd, saved_pos);
    if (status == ERROR)
        goto error_cleanup;

    pFd->changed = 1;
    dosFsFSemGive(pFd);
    return OK;

error_cleanup:
    /* Try to reset the saved seek position */

    (void) dosFsSeek(pFd, saved_pos);

    dosFsFSemGive(pFd);
    return status;
    } /* dosFsTrunc() */
/***************************************************************************
*
* dosFsOpen - open a file on a dosFs volume
*
* This routine opens the file <name> with the specified mode
* (O_RDONLY/O_WRONLY/O_RDWR/CREATE/TRUNC).  The directory structure is
* searched, and if the file is found a dosFs file descriptor
* is initialized for it.
* Extended flags are provided by DOS FS for more efficiency:
* .IP
* DOS_O_CONTIG_CHK - to check file for contiguity.
* .IP
* DOS_O_CASENS - force the file name lookup in case insensitive manner,
* (if directory format provides such opportunity)
* .LP
*
* If this is the very first open for the volume,
* configuration data will be read from the disk automatically
* (via dosFsVolMount()).
*
* RETURNS: A pointer to a dosFs file descriptor, or ERROR
* if the volume is not available,
* or there are no available dosFs file descriptors,
* or there is no such file and O_CREAT was not specified,
* or file can not be opened with such permissions.
*
* ERRNO:
* S_dosFsLib_INVALID_PARAMETER
* S_dosFsLib_READ_ONLY
* S_dosFsLib_FILE_NOT_FOUND
* S_dosFsLib_FILE_EXISTS
*
* /NOMANUAL
*/

DOS_FILE_DESC_ID dosFsOpen
    (
    DOS_VOLUME_DESC_ID  pVolDesc,   /* pointer to volume descriptor */
    char *              pPath,      /* dosFs full path/filename */
    int                 flags,      /* file open flags */
    int                 mode        /* file open permissions (mode) */
    )
    {
    DOS_FILE_DESC_ID    pFd = NULL;
    u_int               errnoBuf;
    BOOL                devSemOwned = FALSE;    /* device semaphore privated */
    BOOL                fileSemOwned = FALSE;   /* file semaphore privated */
    BOOL                error = TRUE;           /* result condition */
    int                 adjflags;               /* "converted" flags */
    int                 ret;

#ifdef _WRS_CONFIG_DOSFS_NAME_LENGTH_COMPAT
    unsigned short *    utf16;
    int                 u16, vollen;
#endif

    /*
     * Note that O_ACCMODE (0x03) happens to be an illegal value in
     * the O_ACCMODE flags.  We can then add 1 to the flags parameter
     * and the result will be a flags bitmap, with _FREAD set for
     * a read-mode file, _FWRITE set for a write-mode file.  This
     * simplifies the rest of the logic.
     */
    if ((pVolDesc == NULL) || pVolDesc->magic != DOS_FS_MAGIC ||
        (flags & O_ACCMODE) == O_ACCMODE)
        {
        errnoSet(S_dosFsLib_INVALID_PARAMETER);
        return (void *)ERROR;
        }
    adjflags = flags + 1;   /* convert from O_* to _F* */

    if (pPath == NULL || strlen(pPath) > PATH_MAX)
        {
        errnoSet(S_dosFsLib_ILLEGAL_PATH);
        return (void *)ERROR;
        }
 #ifdef _WRS_CONFIG_DOSFS_NAME_LENGTH_COMPAT
    /* check full path name length except [.]/[..] */
    vollen = strlen(pVolDesc->devHdr.name);
    u16 = strlen(pPath);
    if (((pPath [u16 - 2] == '\\') || (pPath [u16 - 2] == '/')) &&
        (pPath [u16 - 1] == '.'))
        {
        ;   /* [.] */
        }
    else if (((pPath [u16 - 3] == '\\') || (pPath [u16 - 3] == '/')) &&
             (pPath [u16 - 2] == '.') && (pPath [u16 - 1] == '.'))
        {
        ;   /* [..] */
        }
    else
        {
        if (_func_utf8ToUtf16String != NULL)
            {
            utf16 = (unsigned short *)malloc (PATH_MAX + (5 * 4) + 4);
            if (utf16 == NULL)
                {
                return (void *)ERROR;
                }
            u16 = _func_utf8ToUtf16String (pPath, utf16, (PATH_MAX + (5 * 4)) / 4,
                     (_BYTE_ORDER == _LITTLE_ENDIAN) ? TRUE : FALSE);
            free (utf16);
            if ((u16 <= 0) || ((PATH_MAX / 4) < (vollen + u16 - 1)))
                {
                errnoSet(S_dosFsLib_ILLEGAL_PATH);
                return (void *)ERROR;
                }
            }
        }
#endif

    /* prevent device from removing directory during a path search */

    if (semTake(pVolDesc->devSem, WAIT_FOREVER) == ERROR)
        goto ret;

    ret = xbdIoctl (pVolDesc->device, XBD_TEST, 0);
    if (ret != OK && ret != ENOTSUP)
        {
        errnoSet (ret);
        semGive (pVolDesc->devSem);
        return (void *)ERROR;
        }

    devSemOwned = TRUE;

    /* Call driver check-status routine, if any and mount the volume */

    if (FALSE == pVolDesc->mounted)
        {
        if (dosFsVolMount(pVolDesc) == ERROR)
            goto ret;
        }

    /*
     * If the volume is mounted as read-only,
     * do not allow a file to be opened for writing.
     */

    if (pVolDesc->readOnly)
        {
        if ((flags & (O_ACCMODE | O_CREAT | O_APPEND | O_TRUNC)) != O_RDONLY)
            {
            semGive (pVolDesc->devSem);
            errnoSet (EROFS);
            return ((void *) ERROR);
            }
        }

    /*
     * Only regular file and directory creation are supported.
     *
     * The assignment below loses the original rwxrwxrwx style
     * permissions, but we never use them (even though, for new file
     * creation, it would make sense to set the read-only bit in the
     * DOS attributes if none of the "writeable" bits are on).  It
     * would probably be better to use:
     *     mode = (mode & ~S_IFMT) | S_IFREG;
     * but that requires more machine code, and the DOS_ATTR_RDONLY
     * test below happens after creating a new file, so we would have
     * to move that test into the path-lookup routines too.
     */
    if (!S_ISDIR(mode))
        mode = S_IFREG;     /* for now */

    DBG_MSG(500, "path = %s, flags = %s%s%s%s mode = %d\n",
            pPath,
            (((flags&O_ACCMODE) == 0)? "O_RDONLY" : (
               ((flags&O_ACCMODE) == 1)? "O_WRONLY" : (
                ((flags&O_ACCMODE) == 2)? "O_RDWR" : "UNKN ?"))),
            ((flags&O_CREAT)? " | O_CREAT" : " "),
            ((flags&O_TRUNC)? " | O_TRUNC" : " "),
            ((flags&DOS_O_CONTIG_CHK)? " | DOS_O_CONTIG_CHK":" "),
            mode,0,0);

    /* adjust flags even more to avoid special cases for directories */

    if (S_ISDIR(mode))
        {
        adjflags &= ~O_TRUNC;   /* never truncate directories */
        if (adjflags & O_CREAT) /* i.e., mkdir(path) */
            adjflags |= O_EXCL; /* mkdir is always exclusive */
        }

    /* allocate file descriptor and file handle */

    pFd = dosFsFdGet(pVolDesc);

    if (pFd == NULL)
        goto ret;

     /* search for the file */

    errnoBuf = errnoGet();
    errnoSet(OK);
    if (pVolDesc->pDirDesc->pathLkup(pFd, pPath, adjflags, mode) == ERROR)
        {
        if (errnoGet() == OK)
            errnoSet(S_dosFsLib_FILE_NOT_FOUND);

        goto ret;
        }

    errnoSet(errnoBuf);

    /* share file handles in case of simultaneous file opening */

    dosFsHdlDeref(pFd);

    /* check open attributes */

    if ((pFd->pFileHdl->attrib & DOS_ATTR_RDONLY) && (adjflags & _FWRITE))
        {
        errnoSet(S_dosFsLib_READ_ONLY);
        goto ret;
        }

    /* set open mode */

    pFd->openMode = adjflags;

    /*
     * release device semaphore, because
     * file semaphores have to be taken ahead others.
     */
    semGive(pVolDesc->devSem);
    devSemOwned = FALSE;

    /*
     * If you asked to create a file (without O_EXCL -- note that
     * directories use O_EXCL), and we opened a directory, it must
     * have already been there and we should return a "file exists"
     * error.  If you set O_EXCL, and either a dir or a file with
     * that name already existed, the lookup code should have handled
     * the error already (which subsumes the old fix for SPR#22227).
     */
    if ((adjflags & _FCREAT) && !S_ISDIR(mode) &&
        (pFd->pFileHdl->attrib & DOS_ATTR_DIRECTORY))
        {
        errnoSet(S_dosFsLib_FILE_EXISTS);
        goto ret;
        }

    /* service additional requests */

    if (adjflags & (_FTRUNC | DOS_O_CONTIG_CHK))
        {
        /* take control on file */

        if (dosFsFSemTake(pFd, WAIT_FOREVER) == ERROR)
            goto ret;

        fileSemOwned = TRUE;

        if (!pFd->busy)
            {
            assert(pFd->busy);
            errnoSet (S_dosFsLib_INVALID_PARAMETER);
            goto ret;
            }

        if (pFd->pFileHdl->deleted || pFd->pFileHdl->obsolet)
            {
            errnoSet(S_dosFsLib_FILE_NOT_FOUND);
            goto ret;
            }

        if (adjflags & _FTRUNC)
            {
            u_int   openMode = pFd->openMode;
            STATUS  stat;

            /*
             * when file is newly created flag O_RDONLY may be supplied.
             * Because "file create" is implemented
             * via open(... | O_TRUNC ...), it can fail in
             * operation below in dosFsTrunc(). TO prevent the error
             * open flag is temporarily set to O_RDWR mode.
             */
            pFd->openMode = _FREAD | _FWRITE; /* prevent error on rdonly open */
            stat = dosFsTrunc(pFd, 0);
            pFd->openMode = openMode;

            if (stat == ERROR)
                goto ret;
            } /* TRUNC */

        /* check for contiguity */

        if (adjflags & DOS_O_CONTIG_CHK)
            pVolDesc->pFatDesc->contigChk(pFd);

        }

    error = FALSE;  /* file opened */
#ifdef _WRS_CONFIG_DOSFS_NAME_LENGTH_COMPAT
    /*
     * save open full-path length for readdir
     */
    pFd->pathLength = vollen + u16 - 1;
#endif /* USE_FILE_PATHLENGTH */

ret:
    /* release the file and device */

    if (devSemOwned)
        semGive(pVolDesc->devSem);
    if (fileSemOwned)
        dosFsFSemGive(pFd);

    /* check state */

    if (error) /* error opening file */
        {
        if (pFd != NULL)
            dosFsFdFree(pFd);  /* free file descriptor */
        return (void *)ERROR;
        }

    /* if O_SYNC is set, then sync the underlying caches. */
    if (adjflags & O_SYNC)
        dosFsIoctl(pFd, FIOSYNC, -1);

    /* when create file,set pFd->changed to sync cache when close
       Mainly fix for cp 0 size file and create file then reboot.
    */
    if ((flags & O_CREAT) == O_CREAT)
        pFd->changed = 1;

    return pFd;
    } /* dosFsOpen() */


/*******************************************************************************
*
* dosFsCreate - create a dosFs file
*
* This routine creates a file with the specified name and opens it
* with specified flags.
* If the file already exists, it is truncated to zero length, but not
* actually created.
* A dosFs file descriptor is initialized for the file.
*
* RETURNS: Pointer to dosFs file descriptor,
*  or ERROR if error in create.
*
*/
LOCAL DOS_FILE_DESC_ID  dosFsCreate
    (
    DOS_VOLUME_DESC_ID  pVolDesc,   /* pointer to volume descriptor */
    char *              pName,      /* dosFs path/filename string */
    int                 flags       /* flags (O_RDONLY/O_WRONLY/O_RDWR) */
    )
    {
    DOS_FILE_DESC_ID    pFd;

    /*
     * create file via dosFsOpen().
     *
     * Do not make additional tests on device state, as it
     * is done in dosFsOpen()
     */

    pFd = dosFsOpen(pVolDesc, pName, flags | O_CREAT | O_TRUNC, S_IFREG);

    if (pFd == (void *)ERROR)
        return pFd; /* error creat file */

    /* set new create date */

    if (dosFsFSemTake(pFd, WAIT_FOREVER) == ERROR)
        {
        dosFsClose(pFd);
        pFd = (void *)ERROR;
        return pFd;
        }

    if (!pFd->busy || pFd->pFileHdl->deleted ||
        pFd->pFileHdl->obsolet)
        {
        assert(FALSE);
        errnoSet(S_dosFsLib_FILE_NOT_FOUND);
        pFd = (void *)ERROR;
        goto ret;
        }

    pVolDesc->pDirDesc->updateEntry(pFd, (DH_TIME_CREAT  |
                                          DH_TIME_ACCESS |
                                          DH_TIME_MODIFY),
                                    time(NULL));

ret:

    dosFsFSemGive(pFd);

    return pFd;
    } /* dosFsCreate() */

/*******************************************************************************
*
* dosFsClose - close a dosFs file
*
* This routine closes the specified dosFs file. If file contains
* excess clusters beyond EOF they are freed, when last
* file descriptor is being closed for that file.
*
* RETURNS: OK, or ERROR if directory couldn't be flushed
* or entry couldn't be found.
*
* ERRNO:
* S_dosFsLib_INVALID_PARAMETER
* S_dosFsLib_DELETED
* S_dosFsLib_FD_OBSOLETE
*
* /NOMANUAL
*/

STATUS dosFsClose
    (
    DOS_FILE_DESC_ID    pFd /* file descriptor pointer */
    )
    {
    DOS_VOLUME_DESC_ID  pVolDesc;
    DOS_FILE_HDL_ID     pFileHdl;
    STATUS              retStat = ERROR;
    BOOL                flushCache = FALSE; /* blk I/O cache flushed */
    fsize_t             work = (fsize_t) (0);

    if ((pFd == NULL || pFd == (void *)ERROR  || !pFd->busy) ||
        pFd->pVolDesc->magic != DOS_FS_MAGIC)
        {
        assert(FALSE);
        errnoSet(S_dosFsLib_INVALID_PARAMETER);
        return ERROR;
        }

    assert(pFd - pFd->pVolDesc->pFdList < pFd->pVolDesc->maxFiles);
    assert(pFd->pFileHdl - pFd->pVolDesc->pFhdlList <
           pFd->pVolDesc->maxFiles);

    pVolDesc = pFd->pVolDesc;
    pFileHdl = pFd->pFileHdl;

    /* Take control of file descriptor */

    if (dosFsFSemTake(pFd, WAIT_FOREVER) == ERROR)
        return ERROR;

    /*
     * If file was deleted or obsolete, free descriptor
     * but return error
     */
    if (pFileHdl->obsolet)
        {
        errnoSet(S_dosFsLib_FD_OBSOLETE);
        retStat = ERROR;
        goto ret;
        }

    if (pVolDesc->nBusyFd != 0)
        {
        pVolDesc->nBusyFd--;    /* close normal file descriptor */
        }

    if (pFileHdl->deleted)
        {
        /*
         * I directly assign <errno>, instead of using errnoSet,
         * because together with ERR_SET_SELF debug flag it
         * becomes too much verbose
         */
        errno = S_dosFsLib_DELETED;
        flushCache = TRUE;
        goto ret;
        }

    /* nothing to do for directory except sync FAT tables */

    if (pFileHdl->attrib & DOS_ATTR_DIRECTORY)
        {
        flushCache = TRUE;
        retStat = OK;
        goto ret;
        }

    /*
     * SPR#68203, avoid writing last access date field
     * on open-read-close.
     */

    if (FALSE == pVolDesc->updateLastAccessDate)
        {
        pFd->accessed = 0;
        }

    /* update file's directory entry */

    if (pFd->accessed || pFd->changed)
        {
        u_int   timeFlag;

        timeFlag = (pFd->accessed) ? DH_TIME_ACCESS :
                                     (DH_TIME_ACCESS | DH_TIME_MODIFY);

        if (pVolDesc->pDirDesc->updateEntry (pFd, timeFlag, time (NULL))
            != ERROR)
            {
            pFd->accessed = 0;
            }
        else
            {
            goto ret;
            }
        }

    /*
     * flush buffers and deallocate unused clusters beyond EOF,
     * if last file descriptor is being closed for the file
     */

    if (pFd->changed || (pFileHdl->changed && pFileHdl->nRef == 1))
        {
        if (pFileHdl->nRef == 1)   /* last fd for the file */
            {

            /* deallocate unused clusters */

            /* 1) seek into the last position */
            work = (pFileHdl->size == 0) ? (fsize_t) 0 :
                                           pFileHdl->size - (fsize_t) 1;

            if (ERROR == dosFsSeek(pFd, work))
                {
                goto ret;
                }

            /* 2) return clusters to free state */
            if (pFd->curSec)
                {
                pVolDesc->pFatDesc->truncate(pFd, pFd->curSec, FH_EXCLUDE);

                pFileHdl->changed = 0;
                }
            }

        flushCache = TRUE;
        pFd->changed = 0;
        }

    retStat = OK;

ret:
    /* synchronize FAT */

    if (TRUE == flushCache)
        pVolDesc->pFatDesc->flush(pFd);

    /* release file handle */

    dosFsFSemGive(pFd);

    /* free file descriptor */

    dosFsFdFree(pFd);

    /* force flush cache, when last opened file was closed */

    if (pVolDesc->nBusyFd == 0 || flushCache)
        {
        retStat = pVolDesc->dataIoctl (pVolDesc, CBIO_CACHE_FLUSH, 0);
        pVolDesc->pFatDesc->rawIoctl (pVolDesc, CBIO_CACHE_FLUSH, 0);
        flushCache = FALSE;
        }

    return (retStat);
    } /* dosFsClose() */

/*******************************************************************************
*
* dosFsDeleteByFd - delete a file, described by file descriptor.
*
* This routine deletes the file the <pFd> was opened for it.
*
* RETURNS: OK, or ERROR if the file not found, is read only,
* or is not empty directory, if
* the volume is not available, or there are problems writing out.
*
* ERRNO:
* S_dosFsLib_DIR_NOT_EMPTY
* S_dosFsLib_FD_OBSOLETE
*/
LOCAL STATUS dosFsDeleteByFd
    (
    DOS_FILE_DESC_ID    pFd
    )
    {
    DOS_VOLUME_DESC_ID  pVolDesc = pFd->pVolDesc;
    STATUS              retStat = ERROR;
    BOOL                devSemOwned = FALSE;    /* device semaphore privated */
    BOOL                fileSemOwned = FALSE;   /* file semaphore privated */

    /* take control on the file */

    if (dosFsFSemTake(pFd, WAIT_FOREVER) == ERROR)
        return ERROR;
    fileSemOwned = TRUE;

    /* check the file state */

    if (!pFd->busy)
        {
        assert(pFd->busy);
        errnoSet (S_dosFsLib_INVALID_PARAMETER);
        goto ret;
        }
    if (pFd->pFileHdl->obsolet)
        {
        errnoSet (S_dosFsLib_FD_OBSOLETE);
        goto ret;
        }
    if (pFd->pFileHdl->deleted)
        {
        retStat = OK;
        goto ret;
        }

    /* take control on the volume */

    if (semTake(pVolDesc->devSem, WAIT_FOREVER) == ERROR)
        goto ret;

    devSemOwned = TRUE;

    /* check for directory */

    if (pFd->pFileHdl->attrib & DOS_ATTR_DIRECTORY)
        {
        /* only empty directory can be deleted */

        if (dosFsIsDirEmpty(pFd) == ERROR)
            {
            goto ret;
            }
        }

    /* mark entry as removed */

    if (pVolDesc->pDirDesc->updateEntry(pFd, DH_DELETE, 0) == ERROR)
        goto ret;

    /* invalidate file handle */

    pFd->pFileHdl->deleted = 1;

    /* remove FAT chain */

    if (pFd->pFileHdl->startClust != 0)
        {
        if (pVolDesc->pFatDesc->truncate(
                    pFd, FH_FILE_START, FH_INCLUDE) == ERROR)
            goto ret;
        }

    retStat = OK;

ret:
    if (devSemOwned)
        semGive(pVolDesc->devSem);
    if (fileSemOwned)
        dosFsFSemGive(pFd);

    return retStat;
    } /* dosFsDeleteByFd() */

/*******************************************************************************
*
* dosFsDelete - delete a dosFs file/directory
*
* This routine deletes the file <path> from the specified dosFs volume.
*
* RETURNS: OK, or ERROR if the file not found, is read only,
* or is not empty directory, if
* the volume is not available, or there are problems writing out.
*
* ERRNO:
*/

LOCAL STATUS dosFsDelete
    (
    DOS_VOLUME_DESC_ID  pVolDesc,   /* ptr to volume descriptor */
    char *              pPath       /* dosFs path/filename */
    )
    {
    DOS_FILE_DESC_ID    pFd;
    u_int               errnoBuf;   /* errno backup */
    STATUS              retStat = ERROR;

    /* open the file */

    pFd = dosFsOpen(pVolDesc, pPath, O_WRONLY, 0);
    if (pFd == (void *)ERROR)
        return ERROR;

    retStat = dosFsDeleteByFd(pFd);   /* actually delete */
    /*
     * because 'deleted' flag is set in file handle
     * dosFsClose() will set errno to S_dosFsLib_DELETED,
     * that is not right.
     */
    errnoBuf = errnoGet();
    dosFsClose(pFd);
    errnoSet(errnoBuf);

    return retStat;
    } /* dosFsDelete() */

/*******************************************************************************
*
* dosFsFillGap -  fill gap from current EOF to current position.
*
* After lseek(), a write() start with the current position beyond EOF.
* Or, using ftruncate(), a file can have its size increased.  In either
* case there is a "gap" between the current end-of-file and the current
* position.  This routine fills the gap with zero bytes.
*
* File current position is set to point immediately after the gap.  Note
* that file size (in file handle) is NOT updated; caller must do this.
*
* RETURNS: OK or ERROR if write or cluster alloc failed.
*/
LOCAL STATUS dosFsFillGap
    (
    FAST DOS_FILE_DESC_ID   pFd,        /* file descriptor ptr */
    u_int                   fatFlags    /* clusters allocation policy */
    )
    {
    DOS_VOLUME_DESC_ID  pVolDesc = pFd->pVolDesc; /* volume descriptor ptr */
    DOS_FILE_HDL_ID     pFileHdl = pFd->pFileHdl; /* file handle */
    fsize_t             seekOutPos = (fsize_t)pFd->seekOutPos; /* seek past EOF */
    fsize_t             i;
    fsize_t             bytesToZero;
    fsize_t             secOff;
    STATUS              status;

    assert(seekOutPos != 0);

    /* First call dosFsSeek() and ensure that pFd->pos is at current EOF */

    if (ERROR == dosFsSeek(pFd, pFileHdl->size))
        {
        return (ERROR);
        }

    /*
     * The "gap" we need to fill in has length (seekOutPos - size).
     * If the current size ends in the middle of a sector, we have
     * to zero out the partial sector up to the next sector boundary.
     * (In this case, we are guaranteed that pFd->nSec > 0.)
     *
     * This code is much like that for dosFsFileRW() below.  We use
     * one bio to hold the zero data.  It would be nicer if we could
     * just bzero the cache data directly but the cache interface is not
     * set up that way.
     */
    bytesToZero = seekOutPos - pFd->pos;
    secOff = OFFSET_IN_SEC(pVolDesc, pFd->pos);
    if (secOff != 0)
        {
        char   *pBuf;
        DOS_RW  op;
        int     rest;   /* number of bytes in the rest of the sector */
        struct bio *pBio;

        pBio = dosFsBioGet(pVolDesc);
        if (pBio == NULL)
            return (ERROR);
        pBuf = pBio->bio_data;
        rest = (int)(pVolDesc->bytesPerSec - secOff);
        i = rest;
        if (i > bytesToZero)
            i = bytesToZero;
        bzero(pBuf, (size_t)i);

        if ((0 != (pVolDesc->volWriteOpt & DOS_WRITE_THROUGH_ALL)) ||
            (0 != (pVolDesc->volWriteOpt & DOS_WRITE_THROUGH_USR)))
            {
            op = DOS_WRITE_THROUGH;
            }
        else
            {
            op = DOS_WRITE;
            }

        pVolDesc->dataBytesRW(pVolDesc, pFd->curSec, (off_t)secOff, pBuf, (size_t)i, op);

        /* if we finished off the sector, account for it */

        if (i == rest)
            {
            pFd->curSec++;
            pFd->nSec--;
            }

        bytesToZero -= i;
        pFd->pos += i;

        dosFsBioRelease(pVolDesc, pBio);
        }

    /*
     * For any additional bytes to zero, we can quickly zero out
     * an entire sector using the CBIO_CACHE_NEWBLK ioctl, which
     * directs the cache code to allocate a one-sector-size block
     * and fill it with zero bytes (without reading from the
     * underlying disk).
     *
     * Note that it is safe (and cheaper) to zero out an entire sector,
     * even if we only have to zero out a few bytes, since "zero out
     * only one byte" requires reading the sector off the media first,
     * and by definition, we are filling a post-end-of-file gap so there
     * are no valid bytes to preserve.  (It is, however, *not* safe
     * to zero out an initial partial sector, since the pre-EOF data
     * must be preserved, hence the code above.)  For example:
     *
     *  -----sector----->|-----sector----->|-----sector----->|
     *  ---data--->......::::::::::::::::::////???????????????
     *             ^                           ^
     *             |                           |
     *       current EOF here            desired new EOF here
     *
     * In this situation, the ".", ":", and "/" portions must all be
     * zeroed out.  The ":" section is a whole sector so obviously it
     * is safe to NEWBLK that.  The "." section has data that must be
     * saved.  The "/" section is a partial sector, but the data beyond
     * the "/" section -- the "?" part -- need not be preserved, so we
     * can treat it like the whole sector in the middle.
     *
     * (It might be nice if we could assume that "."-type data had
     * always been "pre-zeroed", but this need not be the case in existing
     * file systems "in the field", so we cannot assume it, even if we
     * arrange for our code to enforce it.  In other words, zeroing out
     * the "?" data now, and "pre-zeroing" newly allocated sectors elsewhere
     * in this code, cannot guarantee "pre-zeroed" "." data on existing
     * disk drives.)
     */
    while (bytesToZero != 0)
        {
        if (pFd->nSec == 0)
            {
            /* we are out of sectors, so get more */

            if (pVolDesc->pFatDesc->getNext(pFd, fatFlags) == ERROR)
                return (ERROR);
            }

        /* we now have at least one sector, so zero it */

        status = pVolDesc->dataIoctl(pVolDesc, CBIO_CACHE_NEWBLK,
                         (addr_t)((long)pFd->curSec));
        if (status == ERROR)
            return (ERROR);

        /*
         * If we zeroed a full sector, account for that.  Otherwise,
         * we zeroed the "?" section too, but pretend we wrote just
         * the partial sector.
         */
        i = pVolDesc->bytesPerSec;
        if (bytesToZero >= i)
            {
            pFd->curSec++;
            pFd->nSec--;
            }
        else
            i = bytesToZero;

        bytesToZero -= i;
        pFd->pos += i;
        }

    return (OK);

    } /* dosFsFillGap() */

/*******************************************************************************
*
* dosFsFileRW - read/write a file.
*
* This function is called from both dosFsRead() and dosFsWrite().
*
* This routine reads/writes the requested number of bytes
* from/to a file.
*
* RETURNS: number of bytes successfully processed, 0 on EOF,
* or ERROR if file can not be accessed by required way.
*
* ERRNO:
* S_dosFsLib_INVALID_PARAMETER
* S_dosFsLib_VOLUME_NOT_AVAILABLE
* S_dosFsLib_NOT_FILE
* S_dosFsLib_FD_OBSOLETE
* S_dosFsLib_DELETED
* S_dosFsLib_DISK_FULL
* S_dosFsLib_WRITE_ONLY
* S_dosFsLib_READ_ONLY
* S_dosFsLib_ACCESS_BEYOND_EOF
*
*/

LOCAL ssize_t dosFsFileRW
    (
    FAST DOS_FILE_DESC_ID   pFd,        /* file descriptor ptr */
    char *                  pBuf,       /* addr of destination/source buffer */
    size_t                  maxBytes,   /* maximum bytes to read/write buffer */
    u_int                   operation   /* _FREAD/FWRITE */
    )
    {
    DOS_VOLUME_DESC_ID      pVolDesc;
                            /* volume descriptor ptr */
    DOS_DIR_PDESCR_ID       pDirDesc;
    DOS_FILE_HDL_ID         pFileHdl;   /* file handle */
    FAST device_t           device;
                            /* cached I/O descriptor ptr */
    FAST size_t             remainBytes = maxBytes; /* work counter */
    FAST size_t             numRW = 0;  /* number of bytes/sectors to accept */
    FAST off_t              work;       /* short work buffer */
    u_int                   fatFlags = 0;   /* flags to fat getNext call */
    BOOL                    error = TRUE;   /* result flag */
    int                     ret;

    if ((pFd == NULL || pFd == (void *)ERROR) ||
        pFd->pVolDesc->magic != DOS_FS_MAGIC)
        {
        errnoSet (S_dosFsLib_INVALID_PARAMETER);
        return (ERROR);
        }

    assert (pFd - pFd->pVolDesc->pFdList < pFd->pVolDesc->maxFiles);
    assert (pFd->pFileHdl - pFd->pVolDesc->pFhdlList < pFd->pVolDesc->maxFiles);

    pVolDesc = pFd->pVolDesc;
    pFileHdl = pFd->pFileHdl;
    device = pFd->pVolDesc->device;

    /* check volume state */

    if (FALSE == pFd->pVolDesc->mounted)
        {
        errnoSet (S_dosFsLib_FD_OBSOLETE);
        return (ERROR);
        }

    assert (operation == _FREAD || operation == _FWRITE);

    /* private control on file */

    if (dosFsFSemTake (pFd, WAIT_FOREVER) == ERROR)
        return (ERROR);

    /* DOS does not access directories as a regular data files */

    if (pFileHdl->attrib & DOS_ATTR_DIRECTORY)
        {
        dosFsFSemGive (pFd);
        errnoSet (S_dosFsLib_NOT_FILE);
        return (ERROR);
        }

    if (maxBytes == 0) /* nothing to be done */
        {
        dosFsFSemGive (pFd);
        return (0);
        }

    /* check file state */

    if (!pFd->busy)
        {
        assert (pFd->busy);
        errnoSet (S_dosFsLib_INVALID_PARAMETER);
        goto ret;
        }

    if (pFileHdl->obsolet)
        {
        errnoSet (S_dosFsLib_FD_OBSOLETE);
        goto ret;
        }

    if (pFileHdl->deleted)
        {
        errnoSet (S_dosFsLib_DELETED);
        goto ret;
        }

    /* we support seek for position passed EOF */

    if (pFd->seekOutPos != 0 && pFd->seekOutPos <= pFileHdl->size)
        {
        if (dosFsSeek (pFd, pFd->seekOutPos) == ERROR)
            goto ret;
        }

    /* init parameters */

    if (operation == _FREAD)   /* read data */
        {
        if ((pFd->openMode & _FREAD) == 0)  /* i.e., write only */
            {
            errnoSet (S_dosFsLib_WRITE_ONLY);
            goto ret;
            }

        /* seek passed current EOF not allowed on READ */

        if ((pFd->seekOutPos != 0) || (pFd->pos > pFileHdl->size))
            {
            errnoSet (S_dosFsLib_ACCESS_BEYOND_EOF);
            error = FALSE;  /* return 0, not ERROR */
            goto ret;
            }

        if (pFd->pos == pFileHdl->size) /* EOF already reached */
            {
            DBG_MSG(100, "EOF on read: Pos = %lu, size = %lu\n",
                    pFd->pos, pFileHdl->size,0,0,0,0,0,0);
            error = FALSE;
            goto ret;
            }

        operation = DOS_READ;
        fatFlags = FAT_NOT_ALLOC;
        pFd->accessed = 1;

        /* read data up to file size */

        maxBytes = (int)min (maxBytes, pFileHdl->size - pFd->pos);
        }
    else    /* _FWRITE - write data */
        {
        if ((pFd->openMode & _FWRITE) == 0) /* read only */
            {
            errnoSet (S_dosFsLib_READ_ONLY);
            goto ret;
            }

        /*
         * Dont allow larger than 4GB file on anything but
         * VXLONGNAMES directory entry files. SPR#27532.
         */

        pDirDesc = (void *) pVolDesc->pDirDesc;

        if (pDirDesc->nameStyle != VXLONG) /* >4GB ok on VxLong */
            {
#ifdef SIZE64
            /*
             * Using DOS_IS_VAL_HUGE is faster but works only when SIZE64
             * is defined in dosFsLibP.h
             */
            if ((DOS_IS_VAL_HUGE (pFd->pos + maxBytes)) == TRUE)
#else
            if ((0xffffffff - pFd->pos) < maxBytes)
#endif
                {
                DBG_MSG(1,"Cannot write more than 4GB without VXLONGNAMES.\n",
                        0,0,0,0,0,0,0,0);

                /* attempt write if big enough, else return 0. */
                maxBytes = (int)min (maxBytes,
                               ((fsize_t)(0xffffffff) - (fsize_t)(pFd->pos)));

                if (maxBytes < 0x2)
                    {
                    errnoSet (S_dosFsLib_ACCESS_BEYOND_EOF);
                    error = FALSE;  /* return 0, not ERROR */
                    goto ret;
                    }
                }
            } /* pDirDesc->nameStyle != VXLONG */

        /* choose allocation policy: is maxBytes less than bytes per cluster? */

        if (maxBytes <= (unsigned int)(pVolDesc->secPerClust << pVolDesc->secSizeShift))
            {
            fatFlags = FAT_ALLOC_ONE;   /* one-cluster allocation */
            }
        else
            {
            fatFlags = (UINT)FAT_ALLOC;   /* group allocation */
            }
        DBG_MSG(400, "Allocate policy = %p\n", (void *)fatFlags,
                0,0,0,0,0,0,0);

        /*
         * _FAPPEND mode means seek to current EOF on each write, so
         * seek to the current size.  Note, this may reset seekOutPos.
         */

        if (pFd->openMode & _FAPPEND)
            {
            if (dosFsSeek (pFd, pFileHdl->size) == ERROR)
            goto ret;
            }

        /*
         * seek operation can set current position beyond EOF.
         * Fill the lacked gap.
         */

        if (pFd->seekOutPos  != 0)
            {
            if (dosFsFillGap (pFd, fatFlags) == ERROR)
                goto ret;
            }

        /* user data may be write through */

        if ((0 != (pVolDesc->volWriteOpt & DOS_WRITE_THROUGH_ALL)) ||
            (0 != (pVolDesc->volWriteOpt & DOS_WRITE_THROUGH_USR)))
            {
            operation = DOS_WRITE_THROUGH;
            }
        else
            {
            operation = DOS_WRITE;
            }

        pFileHdl->changed = 1;
        pFd->changed = 1;
        pFd->accessed = 0;  /* base upon pFd->changed */

        error = FALSE;  /* return value other, than maxBytes, */
                        /* indicates an error itself */
        }

    /* get next contiguous block, if current already finished */

    work = pFileHdl->startClust;    /* backup for future */

    if (pFileHdl->startClust == 0)
        {
        pFd->nSec = 0;
        pFd->fatHdl.nextClust  = 0;
        pFd->fatHdl.lastClust  = 0;
        pFd->fatHdl.cbioCookie = 0;
        }

    if (pFd->nSec == 0)
        {
        if (pVolDesc->pFatDesc->getNext (pFd, fatFlags) == ERROR)
            {
            /*
             * Return ERROR on condition of full disk per POSIX
             * make sure we actually fill the disk though.
             */

            if (errnoGet() == S_dosFsLib_DISK_FULL)
                {
                error = TRUE;
                }
            goto ret;
            }
        }

    assert (pFd->nSec != 0);

    /*
     * it may be first data in the file.
     * In this case file start cluster have been just allocated and
     * "start cluster" field in file's directory entry is 0 yet
     */

    if (work == 0)
        {
        DBG_MSG (400, "pFileHdl = %p : first cluster in chain = %u\n",
                 pFileHdl, pFileHdl->startClust,0,0,0,0,0,0);

        if (pVolDesc->pDirDesc->updateEntry (pFd, 0, 0) == ERROR)
            {
            pFileHdl->obsolet = 1;
            pFd->pVolDesc->nBusyFd--;
            goto ret;
            }
        }
    assert (pFileHdl->startClust != 0);

    /* init bytes down-counter */

    remainBytes = maxBytes;

    /* for the beginning, process remain part of current sector */

    work = (off_t)OFFSET_IN_SEC (pVolDesc, pFd->pos); /* offset in sector */

    if (work != 0)
        {
        numRW = min (remainBytes, (size_t)pVolDesc->bytesPerSec - work);

        DBG_MSG (600, "rest bytes in sec; op=%s off=%u numRW=%u\n",
                 ((operation==DOS_READ)? "_FREAD":"_FWRITE"),
                 work, numRW,0,0,0,0,0);

        if (pVolDesc->dataBytesRW (pVolDesc, pFd->curSec, work, pBuf, numRW,
                                   operation) == ERROR)
            {
            goto ret;
            }

        remainBytes -= numRW;
        pBuf        += numRW;
        pFd->pos    += (fsize_t) numRW;

        /* it may be current sector exhausted */

        if (OFFSET_IN_SEC (pVolDesc, pFd->pos) == 0)
            {
            pFd->curSec ++;
            pFd->nSec --;
            }
        } /* if (offset != 0) */

    /* main loop: read entire sectors */

    while (remainBytes >= pVolDesc->bytesPerSec)
        {
        /* get next contiguous block, if current already finished */

        if (pFd->nSec == 0)
            {
            if (pVolDesc->pFatDesc->getNext (pFd, fatFlags) == ERROR)
                goto ret;
            }

        /* number of sectors to R/W */

        numRW = min (NSECTORS (pVolDesc, remainBytes), pFd->nSec);
        assert (numRW > 0);

        /* R/W data */

        DBG_MSG (600, "entire sectors; op=%s numRW=%u\n",
                 ((operation==DOS_READ)? "_FREAD":"_FWRITE"), numRW,
                 0,0,0,0,0,0);

    if (operation == DOS_READ)
        {
        if (pVolDesc->dataBlkRead (pVolDesc, pFd->curSec, numRW, pBuf)
                == ERROR)
            {
            goto ret;
            }
        }
    else
        {
        if (pVolDesc->dataBlkWrite (pVolDesc, pFd->curSec, numRW, pBuf,
                                    operation) == ERROR)
            {
            goto ret;
            }
        }

        /* correct position */

        work = numRW << pVolDesc->secSizeShift;

        remainBytes -= work;
        pBuf        += work;
        pFd->pos    += (fsize_t)work;
        pFd->curSec += numRW;
        pFd->nSec   -= (u_int)numRW;
        } /* while ... */

    /* now process remain part of data, that is shorter, than sector */

    assert (remainBytes < pVolDesc->bytesPerSec);

    numRW = remainBytes;

    if (numRW > 0)
        {
        DBG_MSG (600, "part of sec; op=%s numRW=%u\n",
                 ((operation==DOS_READ)? "_FREAD":"_FWRITE"), numRW,
                 0,0,0,0,0,0);

        /* get next contiguous block, if current already finished */

        if (pFd->nSec == 0)
            {
            if (pVolDesc->pFatDesc->getNext (pFd, fatFlags) == ERROR)
                goto ret;
            }

        /* read/write data */

        /*
         * prevent dosFs from reading a very new sector into
         * cache, because it does not contain yet any data
         */

        if (pFd->pos >= pFileHdl->size)    /* append file */
            {
            assert (operation == DOS_WRITE || operation == DOS_WRITE_THROUGH);

            if (pVolDesc->dataIoctl (pVolDesc, CBIO_CACHE_NEWBLK,
                                     (addr_t)((long)pFd->curSec)) == ERROR)
                {
                goto ret;
                }
            }

        if (pVolDesc->dataBytesRW (pVolDesc, pFd->curSec, 0, pBuf, numRW,
                                   operation) == ERROR)

            {
            goto ret;
            }

        remainBytes -= numRW;
        pBuf        += numRW;
        pFd->pos    += (fsize_t)numRW;
        }

    error = FALSE;  /* all right */

ret:

    /* update file descriptor */

    if (((operation == DOS_WRITE) || (operation == DOS_WRITE_THROUGH)) &&
        ((size_t)remainBytes < (size_t)maxBytes))
        {
        if (pFd->pos > pFileHdl->size)
            pFileHdl->size = pFd->pos;

        pVolDesc->pDirDesc->updateEntry (pFd, DH_TIME_ACCESS | DH_TIME_MODIFY,
                                         0);
        pFd->changed = 0;
        }

    dosFsFSemGive (pFd);

    if (error)
        return (ERROR);

    DBG_MSG(600, "Result = %u\n", maxBytes - remainBytes,0,0,0,0,0,0,0);

    return ((int)(maxBytes - remainBytes));
    } /* dosFsFileRW() */

/*******************************************************************************
*
* dosFsRead - read a file.
*
* This routine reads the requested number of bytes from a file.
*
* RETURNS: number of bytes successfully read, or 0 if EOF,
* or ERROR if file is unreadable.
*
*/

LOCAL ssize_t dosFsRead
    (
    FAST DOS_FILE_DESC_ID   pFd,    /* file descriptor pointer */
    char *  pBuf,       /* addr of destination buffer */
    size_t     maxBytes    /* maximum bytes to read into buffer */
    )
    {
    return dosFsFileRW(pFd, pBuf, maxBytes, _FREAD);
    } /* dosFsRead() */

/*******************************************************************************
*
* dosFsWrite - read a file.
*
* This routine writes the requested number of bytes to a file.
*
* RETURNS: number of bytes successfully written,
* or ERROR if file is unwritable.
*
*/

LOCAL ssize_t dosFsWrite
    (
    FAST DOS_FILE_DESC_ID   pFd,    /* file descriptor pointer */
    char *  pBuf,       /* addr of src buffer */
    size_t     maxBytes    /* maximum bytes to read into buffer */
    )
    {
    ssize_t rc;

    if (pFd->pVolDesc->readOnly)
        {
        errnoSet (EROFS);
        return (ERROR);
        }

    rc = dosFsFileRW(pFd, pBuf, maxBytes, _FWRITE);

    if ((rc != ERROR) && (pFd->openMode & _FSYNC))
        {
        dosFsIoctl(pFd, FIOSYNC, -1);
        }

    return (rc);
    } /* dosFsWrite() */

/*******************************************************************************
*
* dosFsStatGet - get file status (directory entry data)
*
* This routine is called via an ioctl() call, using the FIOFSTATGET
* function code.  The passed stat structure is filled, using data
* obtained from the directory entry which describes the file.
*
* RETURNS: OK or ERROR if disk access error.
*
*/

LOCAL STATUS dosFsStatGet
    (
    DOS_FILE_DESC  *pFd,    /* pointer to file descriptor */
    struct stat    *pStat   /* structure to fill with data */
    )
    {
    DOS_FILE_HDL_ID pFileHdl = pFd->pFileHdl;
    DOS_VOLUME_DESC_ID  pVolDesc = pFd->pVolDesc;

    bzero ((char *) pStat, sizeof (struct stat));

    /* Fill stat structure */

    /*
     * Not supported fields:
     * pStat->st_ino
     * pStat->st_uid
     * pStat->st_gid
     * pStat->st_rdev
     */

    pStat->st_dev     = (u_long) pVolDesc; /* device ID = DEV_HDR addr */

    pStat->st_nlink   = 1;                  /* always only one link */

    pStat->st_size    = pFileHdl->size;     /* file size, in bytes */

    /* block size = cluster size shifted */
    pStat->st_blksize = (unsigned int)pVolDesc->secPerClust << pVolDesc->secSizeShift;

    if (0 == pStat->st_blksize)
        {
        /* avoid dividing by zero */
        return (ERROR);
        }

    pStat->st_blocks  = (blkcnt_t)(pStat->st_size + (pStat->st_blksize-1)) /
                pStat->st_blksize;  /* no. of blocks */

    pStat->st_attrib  = pFileHdl->attrib;   /* file attribute byte */

    /* Set file type in mode field */

    pStat->st_mode = S_IRWXU | S_IRWXG | S_IRWXO;

    if ((pFileHdl->attrib & DOS_ATTR_RDONLY) != 0)
        pStat->st_mode &= ~(S_IWUSR | S_IWGRP | S_IWOTH);

    if (pFileHdl->attrib & DOS_ATTR_DIRECTORY)
        {
        pStat->st_mode |= S_IFDIR;  /* set bits in mode field */

        pStat->st_size = pStat->st_blksize; /* make it look like dir */
                            /* uses one block */
        }
    else  /* if not a volume label */
        {
        assert(!(pFileHdl->attrib & DOS_ATTR_VOL_LABEL));

        pStat->st_mode |= S_IFREG;  /*  it is a regular file */
        }

    /* Fill in modified date and time */

    if (pVolDesc->pDirDesc->dateGet(pFd, pStat) == ERROR)
        return ERROR;

    return (OK);
    } /* dosFsStatGet() */

/******************************************************************************
*
* dosFsFSStatGet - get statistics about entire file system
*
* Used by fstatfs() and statfs() to get information about a file
* system.  Called through dosFsIoctl() with FIOFSTATFSGET code.
*
* RETURNS:  OK, or ERROR if fail
*/

LOCAL STATUS dosFsFSStatGet
    (
    DOS_FILE_DESC_ID    pFd,        /* pointer to file descriptor */
    struct statfs *     pStat       /* structure to fill with data */
    )
    {
    fsize_t  uVal;
    if (pStat == NULL)
        return ERROR;

    pStat->f_type   = 0;

    pStat->f_bsize  = (long)pFd->pVolDesc->secPerClust <<
                      pFd->pVolDesc->secSizeShift;

#ifdef _WRS_CONFIG_LP64
    if (dosFsIsValHuge(pFd->pVolDesc->nFatEnts))
        {
        errnoSet(S_dosFsLib_32BIT_OVERFLOW);
        return ERROR;
        }
#endif
    pStat->f_blocks = pFd->pVolDesc->nFatEnts;

    if (0 != pFd->pVolDesc->secPerClust)
        {
        uVal = (pFd->pVolDesc->pFatDesc->nFree(pFd) >>
                            pFd->pVolDesc->secSizeShift) /
                            pFd->pVolDesc->secPerClust;

#ifdef _WRS_CONFIG_LP64
        if (dosFsIsValHuge(uVal))
           {
           errnoSet(S_dosFsLib_32BIT_OVERFLOW);
           return ERROR;
           }
#endif
        pStat->f_bfree = (long)uVal;
        }

    pStat->f_bavail = pStat->f_bfree;

    pStat->f_files  = -1;

    pStat->f_ffree  = -1;

    pStat->f_fsid.val[0] = (long) pFd->pVolDesc->volId;

    pStat->f_fsid.val[1] = 0;

    return (OK);
    }

/*******************************************************************************
 *
 * dosfsFsStatGet64 - get statistics about entire file system in 64bit mode
 *
 * This routine gets the statistics about entire file system in 64bit mode.
 *
 * RETURNS: OK, or ERROR if fail
 *
 * ERRNO: N/A
 *
 * \NOMANUAL
 */

LOCAL STATUS dosfsFsStatGet64
    (
    DOS_FILE_DESC_ID    pFd,        /* pointer to file descriptor */
    struct statfs64 *   pStat64     /* structure to fill with data */
    )
    {
    if (pStat64 == NULL)
        return ERROR;

    pStat64->f_type   = 0;
    pStat64->f_bsize  = (long)pFd->pVolDesc->secPerClust <<
                        pFd->pVolDesc->secSizeShift;
    pStat64->f_blocks = pFd->pVolDesc->nFatEnts;

    if (0 != pFd->pVolDesc->secPerClust)
        {
        pStat64->f_bfree  = (pFd->pVolDesc->pFatDesc->nFree(pFd) >>
                            pFd->pVolDesc->secSizeShift) /
                            pFd->pVolDesc->secPerClust;
        }

    pStat64->f_bavail = pStat64->f_bfree;
    pStat64->f_files  = -1;
    pStat64->f_ffree  = -1;
    pStat64->f_fsid.val[0] = (long) pFd->pVolDesc->volId;
    pStat64->f_fsid.val[1] = 0;
    return (OK);
    }

/*******************************************************************************
*
* dosFsCheckDirRename - verify that a directory rename keeps tree structure.
*
* The new name must not be a subdirectory of the old name, e.g.,
* rename "/fs/dir", "/fs/dir/sub" is invalid.  We have to make
* sure we catch cases like "dir" -> "dir/sub/sub2" (which is not too
* hard) but also "irrelevant/../dir" -> "dir/sub".  If this is not
* stopped early, the directory that is moved to a subdirectory of
* itself becomes detached from the tree (chkdsk will report it, and
* everything inside it, as "lost", and remove it and its contents).
*
* Note: when we return OK, this does not mean the rename itself is
* going to succeed, only that it does not break the tree structure.
*
* RETURNS: OK, or ERROR if pNewName is invalid with respect to pOldName.
*
* ERRNO:
* S_dosFsLib_ILLEGAL_NAME
* S_dosFsLib_ILLEGAL_PATH
* S_dosFsLib_INVALID_PARAMETER
*
* /NOMANUAL
*/

LOCAL STATUS dosFsCheckDirRename
    (
    DOS_VOLUME_DESC * pVolDesc,
    char *            pOldName,
    char *            pNewName
    )
    {
    int        oldNumLevels;
    int        newNumLevels;
    int        i;
    PATH_ARRAY oldArray[DOS_MAX_DIR_LEVELS + 1];
    PATH_ARRAY newArray[DOS_MAX_DIR_LEVELS + 1];

    /*
     * dosPathParse() removes "." and ".." components for us.  It is
     * a bit over-aggressive (see comments in dosPathParse()), but
     * the directory routines all use it, so this over-aggressiveness
     * does not hurt our tree-checking in any way.
     */
    oldNumLevels = dosPathParse ((u_char *) pOldName, oldArray,
                     DOS_MAX_DIR_LEVELS + 1);
    if (oldNumLevels == ERROR)
        return (ERROR);
    newNumLevels = dosPathParse ((u_char *) pNewName, newArray,
                     DOS_MAX_DIR_LEVELS + 1);
    if (newNumLevels == ERROR)
        return (ERROR);

    DBG_MSG (100, "dosFsCheckDirRename: pOldName = %s, oldNumLevels = %d\n",
             pOldName, oldNumLevels, 0, 0, 0, 0, 0, 0);
    DBG_MSG (100, "dosFsCheckDirRename: pNewName = %s, newNumLevels = %d\n",
             pNewName, newNumLevels, 0, 0, 0, 0, 0, 0);

    /*
     * If oldNumLevels exceeds newNumLevels, the directory is being
     * moved up (e.g., "sub1/sub2/sub3" -> "sub1/new").  This is OK.
     * If oldNumLevels equals newNumLevels and the names are all the
     * same, our caller will see this and set S_dosFsLib_FILE_EXISTS,
     * so we should not do anything.  We must only check for tree
     * detachment if oldNumLevels is strictly less than newNumLevels.
     */
    if (oldNumLevels < newNumLevels)
        {
        /*
         * If any of the initial path components differ, the rename can
         * proceed, e.g., "sub1/sub2/sub3" -> "sub1/new/sub3/sub4".  If
         * all initial path components are the same, we must reject the
         * attempt.  So we find the first place they are different.
         */
        for (i = 0; i < oldNumLevels; i++)
            {
            size_t len = oldArray[i].nameLen;
            char  *o;
            char  *n;
            int    retVal;

            if (len != newArray[i].nameLen)
                break;
            o = (char *) oldArray[i].pName;
            n = (char *) newArray[i].pName;
            if (pVolDesc->volIsCaseSens)
                retVal = memcmp (o, n, len);
            else
                retVal = strncasecmp (o, n, len);
            if (retVal != 0)
                break;
            }

        DBG_MSG (100, "dosFsCheckDirRename: %sdifferent at %d\n",
            i == oldNumLevels ? "not " : "", i + 1, 0, 0, 0, 0, 0, 0);

        if (i == oldNumLevels)
            {
            errnoSet (S_dosFsLib_INVALID_PARAMETER);
            return (ERROR);
            }
        }

    return (OK);
    }

/*******************************************************************************
*
* dosFsRename - change name of dosFs file
*
* This routine changes the name of the specified file to the specified
* new name.
*
* RETURNS: OK, or ERROR if pNewName already in use,
* or unable to write out new directory info.
*
* ERRNO:
* S_ioLib_NO_FILENAME
* S_dosFsLib_NOT_SAME_VOLUME
* S_ioLib_WRITE_PROTECTED
* S_dosFsLib_VOLUME_NOT_AVAILABLE
* S_dosFsLib_NOT_FILE
* S_dosFsLib_ILLEGAL_NAME
* S_dosFsLib_ILLEGAL_PATH
* S_dosFsLib_INVALID_PARAMETER
* S_dosFsLib_FILE_EXISTS
*/

LOCAL STATUS dosFsRename
    (
    DOS_FILE_DESC_ID    pFdOld,         /* pointer to file descriptor   */
    char *              pOldName,       /* old name of file to change */
    char *              pNewName,       /* change name of file to this  */
    BOOL                allowOverwrite  /* allow dest. file to be overwritten */
    )
    {
    DOS_VOLUME_DESC_ID  pVolDesc;
                        /* ptr to volume descriptor */
    DOS_FILE_HDL_ID     pFileHdlOld = pFdOld->pFileHdl;
                        /* old file's file handle ptr */
    DOS_FILE_DESC_ID    pFdNew = NULL;
                        /* new file descriptor */
    DOS_FILE_HDL_ID     pFileHdlNew = NULL;
                        /* new file's file handle ptr */
    u_int               errnoBuf;       /* errno backup */
    struct stat         fStat;          /* structure to fill with data */
    DOS_DIR_HDL         oldDirHdl;      /* backup of directory handle */
    STATUS              retStat = ERROR;/* function return status */

    /* Get volume descriptor and real pathname */

    if ((pNewName == NULL) || (pNewName[0] == EOS))
        {
        errnoSet (S_ioLib_NO_FILENAME);
        return (ERROR);
        }

    pVolDesc = pFdOld->pVolDesc;

    /*
     * check to see if the new file path to rename towards already
     * exists. We never rename a file to an existing filename.
     * however in FIOMOVE case if allowOverwrite is TRUE it is ok.
     */

    if (FALSE == allowOverwrite)
        {
        pFdNew = dosFsOpen(pVolDesc,
                            (char *) pNewName,
                            (O_RDONLY |
                             (pVolDesc->volIsCaseSens ? DOS_O_CASENS : 0)),
                            0);

        if (ERROR != (long) pFdNew)
            {
            dosFsClose(pFdNew);
            errnoSet(S_dosFsLib_FILE_EXISTS);
            return (ERROR);
            }
        else
            {
            errnoSet(OK);
            }
        }

    /* get creation time etc. of file being renamed */

    if (pVolDesc->pDirDesc->dateGet(pFdOld, &fStat) == ERROR)
        {
        return ERROR;
        }

    /*
     * Make sure the path is valid if renaming a directory.
     */
    if (pFdOld->pFileHdl->attrib & DOS_ATTR_DIRECTORY)
        {
        if (dosFsCheckDirRename (pVolDesc, pOldName, pNewName) == ERROR)
            return (ERROR);
        }


    /*
     * create the file to rename to, but
     * prevent from file self-name renaming.
     */

    FOREVER
        {

        /*
         * SPR 29751 - Made the case sensitivity depend upon a switch in
         * the volume descriptor. Initially set to FALSE but can be set
         * with an ioctl
         */

        /* Create the new name entry */
        pFdNew = dosFsOpen(pVolDesc,
                            (char *)pNewName,
                            (O_CREAT | O_WRONLY |
                             (pVolDesc->volIsCaseSens ? DOS_O_CASENS : 0)),
                            0);

        if (pFdNew == (void *)ERROR)
            {
            return (ERROR);
            }

        /* get ownership of new file */

        if (dosFsFSemTake(pFdNew, WAIT_FOREVER) == ERROR)
            {
            dosFsClose (pFdNew);
            return (ERROR);
            }

        /* get ownership of volume */

        if (semTake(pVolDesc->devSem, WAIT_FOREVER) != OK)
            {
            dosFsFSemGive (pFdNew);
            dosFsClose(pFdNew);
            return (ERROR);
            }

        /* do not allow a rename to original name */

        if (pFdNew->pFileHdl == pFileHdlOld)
            {
            semGive (pVolDesc->devSem);
            dosFsFSemGive (pFdNew);
            dosFsClose(pFdNew);
            errnoSet(S_dosFsLib_INVALID_PARAMETER);
            return (ERROR);
            }

        pFileHdlNew = pFdNew->pFileHdl;

        /* check again new file state (after semTake()) */

        if (!pVolDesc->mounted || pFileHdlNew->obsolet)
            {
            /* volume have been unmounted */

            errnoSet(S_dosFsLib_VOLUME_NOT_AVAILABLE);

            goto ret;
            }

        if (!pFileHdlNew->deleted)
            break;

        /* somebody had time to delete the file. Create again */

        semGive(pVolDesc->devSem);

        dosFsFSemGive(pFdNew);
        } /* FOREVER */

    /* protect an existing directory from being a destination */

    if (pFileHdlNew->attrib & DOS_ATTR_DIRECTORY)
        {
        errnoSet(S_dosFsLib_NOT_FILE);
        goto ret;
        }

    /* prevent access to the new file via its share file handle */

    pFileHdlNew->deleted = 1;

    /* repoint new directory chain onto the renamed file chain */

    oldDirHdl = pFileHdlOld->dirHdl; /* backup dir handle */

    pFileHdlOld->dirHdl = pFileHdlNew->dirHdl;


    /* restore original dirent times */

    if (pVolDesc->pDirDesc->updateEntry(pFdOld, DH_TIME_CREAT,
                             fStat.st_ctime) == ERROR)
        {
        pFileHdlOld->dirHdl = oldDirHdl;
        goto ret;
        }

    if (pVolDesc->pDirDesc->updateEntry(pFdOld, DH_TIME_MODIFY,
                             fStat.st_mtime) == ERROR)
        {
        pFileHdlOld->dirHdl = oldDirHdl;
        goto ret;
        }

    if (pVolDesc->pDirDesc->updateEntry(pFdOld, DH_TIME_ACCESS,
                             fStat.st_atime) == ERROR)
        {
        pFileHdlOld->dirHdl = oldDirHdl;
        goto ret;
        }

    /* mark old directory entry as removed */

    pFileHdlOld->dirHdl = oldDirHdl;
    if (pFileHdlOld->attrib & DOS_ATTR_DIRECTORY)
        {
        dosVDirLibUptDotDot(pFdOld, pFdNew);
        }

    pVolDesc->pDirDesc->updateEntry(pFdOld, DH_DELETE, 0);

    pFileHdlOld->dirHdl = pFileHdlNew->dirHdl;

    /* remove destination fat chain, if it was not a new file */

    if (pFileHdlNew->startClust != 0)
        {
        pVolDesc->pFatDesc->truncate(pFdNew, FH_FILE_START,
                          FH_INCLUDE);
        }

    retStat = OK;

ret:

    /* release device and file semaphores */

    semGive(pVolDesc->devSem);

    dosFsFSemGive(pFdNew);

    /*
     * because 'deleted' flag in file handle of the new file
     * descriptor is set, dosFsClose() will set appropriate
     * errno, we ignore the error.
     */
    errnoBuf = errnoGet();

    dosFsClose(pFdNew);

    errnoSet(errnoBuf);

    /*
     * force flush cache in order to store deleted entry descriptor
     * before rename finishes (this is important for the check disk)
     */

    if (retStat == OK)
        dosFsIoctl(pFdOld, FIOFLUSH, (-1));

    return (retStat);
    } /* dosFsRename() */

/*******************************************************************************
*
* dosFsOptUpdate - update dosFs default create options
*
* This routine updates the dosFs default create options on a valid dosFs volume
* such as check disk option, write option and file name format option.
*
* RETURNS : STATUS
*
* /NOMANUAL
*/
LOCAL STATUS dosFsOptUpdate
    (
    DOS_VOLUME_DESC_ID  pVolDesc,
    int                 usrDefinedOptions
    )
    {
    STATUS              retVal = OK;

    /* get ownership of volume */

    if (semTake(pVolDesc->devSem, WAIT_FOREVER) != OK)
        return ERROR;

    if (usrDefinedOptions == (u_int) NONE)
        {

        /* set every related member to 0 */

        pVolDesc->autoChk = 0;
        pVolDesc->autoChkVerb = 0;
        pVolDesc->volWriteOpt = 0;
        pVolDesc->volUnicode = 0;
        }
    else
        {

        /*check disk autocall level*/

        if ((usrDefinedOptions & DOS_CHK_FLAGS_MASK) == (u_int) DOS_CHK_NONE)
            {
            pVolDesc->autoChk = 0;
            }
        else
            {
            pVolDesc->autoChk=
                (u_char)(((usrDefinedOptions & DOS_CHK_FLAGS_MASK) == DOS_CHK_REPAIR) ?
                    DOS_CHK_REPAIR : DOS_CHK_ONLY);
            pVolDesc->autoChk = (u_char)(pVolDesc->autoChk | (usrDefinedOptions & DOS_CHK_FORCE));

            /* extract the auto chk verbosity, verify and assign */

            switch (usrDefinedOptions & DOS_CHK_VERB_MASK)
                {
                case DOS_CHK_VERB_0:
                case DOS_CHK_VERB_1:
                case DOS_CHK_VERB_2:
                    pVolDesc->autoChkVerb =
                             (u_char)((usrDefinedOptions & DOS_CHK_VERB_MASK) >> 8);
                    break;
                default:
                    /* Force out of range verbosity to maximum level */
                    pVolDesc->autoChkVerb = DOS_CHK_VERB_2 >> 8;
                    break;
                } /* switch */
            }

        /* write option is changed */

        if ((usrDefinedOptions & DOS_WRITE_THROUGH_MASK) != pVolDesc->volWriteOpt)
            {

            /* changed from write-back to write-through and if this volume
             * actually support the disk cache
             */

            if ((pVolDesc->volWriteOpt == 0) &&
                  (((pVolDesc->cache[DOS_DATA_DIR_CACHE].base != NULL) &&
                    (pVolDesc->cache[DOS_DATA_DIR_CACHE].size != 0)) ||
                   ((pVolDesc->cache[DOS_FAT_CACHE].base != NULL) &&
                    (pVolDesc->cache[DOS_FAT_CACHE].size != 0))))
                {
                /* flush the cache*/
                retVal = pVolDesc->dataIoctl (pVolDesc, CBIO_CACHE_FLUSH, 0);
                }

            pVolDesc->volWriteOpt = (usrDefinedOptions & DOS_WRITE_THROUGH_MASK);
            }

        /*
         * Unicode -- note that "old style" and VxWorks-long-name dir handlers
         * can ignore this, or set it to FALSE, since Unicode file names currently
         * only work with variable-length directory entries.
         */

        pVolDesc->volUnicode =
                   (usrDefinedOptions & DOS_FILENAMES_UNICODE) != 0;


        }

    /* release device semaphores */

    semGive(pVolDesc->devSem);
    return retVal;
    } /* dosFsOptUpdate() */

/*******************************************************************************
*
* dosFsContigAlloc - allocate contiguous space for file
*
* This routine attempts to allocate a contiguous area on the disk for
* a file.  The
* available area which is large enough is allocated.
*
* RETURNS: OK, or ERROR if no contiguous area large enough.
*
* ERRNO:
* S_dosFsLib_INVALID_PARAMETER
* S_dosFsLib_INVALID_NUMBER_OF_BYTES
*/
LOCAL STATUS dosFsContigAlloc
    (
    DOS_FILE_DESC_ID    pFd,    /* pointer to file descriptor */
    fsize_t *           pNBytes /* requested size of contiguous area */
    )
    {
    DOS_VOLUME_DESC_ID  pVolDesc = pFd->pVolDesc;
    DOS_FILE_DESC_ID    pLoopFd = pFd->pVolDesc->pFdList;
    UINT32              startClust = pFd->pFileHdl->startClust;
                                /* backup current start cluster */
    UINT32              startClustNew;  /* backup file new start cluster */
    u_int               nSec;           /* clusters to alloc */
    int                 i;

    /* Check for zero bytes requested */
    if (pNBytes == NULL)
        {
        errnoSet (S_dosFsLib_INVALID_PARAMETER);
        return ERROR;
        }

    if (*pNBytes == 0)
        {
        errnoSet (S_dosFsLib_INVALID_NUMBER_OF_BYTES);
        return ERROR;
        }

    /* only regular file can be contiguous preallocated */

    if (pFd->pFileHdl->attrib & DOS_ATTR_DIRECTORY)
        {
        errnoSet(S_dosFsLib_NOT_FILE);
        return ERROR;
        }

    /* file must be writable */
    if ((pFd->openMode & _FWRITE) == 0)
        {
        errnoSet (S_dosFsLib_READ_ONLY);
        return ERROR;
        }


    /*
     * Find a suitable area on the disk
     */

    /* First evaluate space in sectors */
    if (*pNBytes == (fsize_t)CONTIG_MAX) /* if max contig area req'd */
        {
        nSec = (UINT)CONTIG_MAX;
        }
    else
        {
        nSec = (u_int)((*pNBytes + pVolDesc->bytesPerSec - 1) >>
                        pVolDesc->secSizeShift);
        }

    /* Try to allocate the required sectors */
    if (pVolDesc->pFatDesc->contigAlloc(pFd, nSec) == ERROR)
        {
        return ERROR;
        }

    /* SPR#71105: Got enough sectors so adjust the file size to new value */

    /*
     * So now we have allocated enough sectors for the
     * requested size, but was it a specific size or CONTIG_MAX?
     * If the latter then we have to work out how much space
     * we actually allocated!
     */
    if (*pNBytes == (fsize_t)CONTIG_MAX) /* if max contig area req'd */
        {
        /* We got CONTIG_MAX, how much was that?? */

        /* How many clusters? */
        int clusters = pFd->contigEndPlus1
                           - pFd->pFileHdl->startClust;
        /* size = (clusters*sectors/cluster)*sector_size */
        pFd->pFileHdl->size = (fsize_t) ((clusters  * pVolDesc->secPerClust)
                                         << (pVolDesc->secSizeShift));
        }
    else
        {
        /* OK, we got what we asked for so use that as the size */
        pFd->pFileHdl->size = *pNBytes;
        }


    /* Update the endtry to reflect the changes */
    if (pVolDesc->pDirDesc->updateEntry(pFd, 0, 0) == ERROR)
        {
        return ERROR;
        }

    /*
     * when the file is recreated, the old file chain
     * is preserved until last file descriptor is
     * closed for the file.
     * In this case all file descriptors must be synchronized
     * and old chain be deallocated.
     */

    if (startClust != 0)
        {
        startClustNew = pFd->pFileHdl->startClust;

        /* deallocate old chain */

        pFd->pFileHdl->startClust = startClust;

        pVolDesc->pFatDesc->truncate(pFd, FH_FILE_START, FH_INCLUDE);

        pFd->pFileHdl->startClust = startClustNew;

        /*
         *  synchronize file descriptors: cause next access to
         * begin with absolute seek
         */
        for (pLoopFd = pFd->pVolDesc->pFdList, i = 1;
             i < pFd->pFileHdl->nRef; pLoopFd ++)
            {
            assert(pLoopFd - pFd->pVolDesc->pFdList <
                    pVolDesc->maxFiles);

            if (pLoopFd->busy && pLoopFd != pFd &&
                pLoopFd->pFileHdl == pFd->pFileHdl)
                {
                i ++;
                pLoopFd->seekOutPos = pLoopFd->pos;
                pLoopFd->pos = 0;
                pLoopFd->nSec = 0;
                pLoopFd->curSec = 0;
                }
            }
        }

    /* seek to file start */
    if (pVolDesc->pFatDesc->seek(pFd, FH_FILE_START, 0) == ERROR)
        {
        return ERROR;
        }

    return OK;
    } /* dosFsContigAlloc() */

/*******************************************************************************
*
* dosFsMakeDir - create a directory.
*
* This routine creates directory.
*
* RETURNS: OK or ERROR if such directory can not be created.
*/
LOCAL STATUS dosFsMakeDir
    (
    DOS_VOLUME_DESC_ID  pVolDesc,   /* pointer to volume descriptor */
    u_char *            name        /* directory name */
    )
    {
    DOS_FILE_DESC_ID    pFd;
    DEV_HDR            *pDev;
    u_char              path [PATH_MAX + 1];

    /* get full path to the new file */

    if (ioFullFileNameGet ((const char *) name, &pDev, (char *) path) != OK)
        return (ERROR);

    /* Old and new devices must be the same */

    if (pDev != &pVolDesc->devHdr)
        {
        errnoSet(S_dosFsLib_NOT_SAME_VOLUME);
        return (ERROR);
        }

    /* create directory */

    pFd = dosFsOpen(pVolDesc, (char *)path, O_CREAT | O_EXCL, S_IFDIR);

    if (pFd != (void *) ERROR)
        {
        dosFsClose(pFd);
        return OK;
        }

    return ERROR;
    } /* dosFsMakeDir() */

/*******************************************************************************
*
* dosFsIoctl - do device specific control function
*
* This routine performs the following ioctl functions.
*
* Any ioctl function codes, that are not supported by this routine
* are passed to the underlying XBD module for handling.
*
* There are some ioctl() functions, that suppose to receive as
* result a 32-bit numeric value (FIONFREE, FIOWHERE and so on),
* however disks and files with size grater, than 4GB are supported.
* In order to solve this contradiction new ioctl() functions are
* provided. They have the same name as basic functions, but with
* suffix '64': FIONFREE64, FIOWHERE64 and so on. These functions
* gets pointer to 'long long' as an argument. Also FIOWHERE64
* returns value via argument, but not as ioctl()returned value.
* If an ioctl fails, the task's status (see errnoGet()) indicates
* the nature of the error.
*
* RETURNS: OK or current position in file for FIOWHERE,
* or ERROR if function failed or driver returned error, or if
* function supposes 32 bit result value, but
* actual result overloads this restriction.
*
* ERRNO:
* S_dosFsLib_INVALID_PARAMETER
* S_dosFsLib_VOLUME_NOT_AVAILABLE
* S_dosFsLib_FD_OBSOLETE
* S_dosFsLib_DELETED
* S_dosFsLib_32BIT_OVERFLOW
*
* /NOMANUAL
*/

STATUS dosFsIoctl
    (
    FAST DOS_FILE_DESC_ID   pFd,            /* fd of file to control */
    int                     function,       /* function code */
    _Vx_ioctl_arg_t         arg             /* some argument */
    )
    {
    DOS_VOLUME_DESC_ID      pVolDesc;
    void *                  pBuf;           /* work ptr */
    fsize_t                 buf64 = 0;      /* 64-bit work buffer */
    BOOL                    devSemOwned = FALSE;
    STATUS                  retVal = ERROR;
    int                     ret;
    dsize_t                 diskSize64 = 0;

    if ((pFd == NULL || pFd == (void *)ERROR) ||
        pFd->pVolDesc->magic != DOS_FS_MAGIC)
        {
        errnoSet(S_dosFsLib_INVALID_PARAMETER);
        return ERROR;
        }

    assert (pFd - pFd->pVolDesc->pFdList < pFd->pVolDesc->maxFiles);
    assert (pFd->pFileHdl - pFd->pVolDesc->pFhdlList <
            pFd->pVolDesc->maxFiles);

    pVolDesc = pFd->pVolDesc;

    ret = xbdIoctl (pVolDesc->device, XBD_TEST, 0);
    if (ret != OK && ret != ENOTSUP)
        {
        errnoSet (ret);
        return (ERROR);
        }

    if (pVolDesc->readOnly)
        {
        if ((function == FIOTIMESET) || (function == FIOSQUEEZE) ||
            (function == FIOTRUNC) || (function == FIOTRUNC64) ||
            (function == FIOCONTIG) || (function == FIOUNLINK) ||
            (function == FIOCONTIG64) || (function == FIOATTRIBSET) ||
            (function == FIOLABELSET) || (function == FIORMDIR) ||
            (function == FIOMKDIR) || (function == FIORENAME) ||
            (function == FIOMOVE) || (function == FIOCHMOD))
            {
            errnoSet (EROFS);
            return (ERROR);
            }
        }

    /* take control on file */

    if (dosFsFSemTake(pFd, WAIT_FOREVER) == ERROR)
        return ERROR;

    /* check file status */

    if (!pFd->busy)
        {
        assert(pFd->busy);

        errnoSet (S_dosFsLib_INVALID_PARAMETER);
        goto ioctlRet;
        }

    if (FALSE == pVolDesc->mounted)
        {
        errnoSet(S_dosFsLib_FD_OBSOLETE);
        goto ioctlRet;
        }

    if (pFd->pFileHdl->obsolet)
        {
        errnoSet (S_dosFsLib_FD_OBSOLETE);
        goto ioctlRet;
        }

    if (pFd->pFileHdl->deleted)
        {
        errnoSet (S_dosFsLib_DELETED);
        goto ioctlRet;
        }

    /* Perform requested function */

    DBG_MSG(600, "Function %u\n", function,0,0,0,0,0,0,0);
    switch (function)
        {
        case FIOUPDATE:
            {
            retVal = dosFsOptUpdate(pVolDesc, (int)arg);
            goto ioctlRet;
            } /* FIOUPDATE */

        case FIORENAME:
            {
            retVal = dosFsRename(pFd, ((RENAME_STRUCT *)arg)->oldname,
                                 ((RENAME_STRUCT *)arg)->newname, FALSE);
            goto ioctlRet;
            } /* FIORENAME */

        case FIOMOVE:
            {
            retVal = dosFsRename(pFd, ((RENAME_STRUCT *)arg)->oldname,
                                 ((RENAME_STRUCT *)arg)->newname, TRUE);
            goto ioctlRet;
            } /* FIORENAME */

        case FIOSEEK:
            {
            retVal = ERROR;

            if (pFd->pFileHdl->attrib & DOS_ATTR_DIRECTORY)
                { /* seek for directories is not supported */
                errnoSet(S_dosFsLib_NOT_FILE);
                }
#ifdef _WRS_CONFIG_LP64
            else if (dosFsIsValHuge(arg))
                { /* restrict to seek 32-bit value ranges from 0 to UINT_MAX */
                errnoSet(S_dosFsLib_32BIT_OVERFLOW);
                }
#endif
            else
                {
                retVal = dosFsSeek (pFd, (u_int)arg);
                }
            goto ioctlRet;
            } /* FIOSEEK */

        case FIOSEEK64: /* seek within 64-bit position */
            {
            retVal = ERROR;

            if (pFd->pFileHdl->attrib & DOS_ATTR_DIRECTORY)
                { /* seek for directories is not supported */
                errnoSet(S_dosFsLib_NOT_FILE);
                }
            else if (arg == (_Vx_ioctl_arg_t) NULL)
                {
                errnoSet(S_dosFsLib_INVALID_PARAMETER);
                }
            else
                {
                retVal = dosFsSeek (pFd, *(fsize_t *)arg);
                }

            goto ioctlRet;
            } /* FIOSEEK64 */

        case FIOWHERE:  /* position within 32 bit boundary */
            {
            buf64 = (pFd->seekOutPos != 0)? pFd->seekOutPos :
                          pFd->pos;
            if (dosFsIsValHuge(buf64))
                {
                errnoSet(S_dosFsLib_32BIT_OVERFLOW);
                retVal = ERROR;
                }
            else
                retVal = (STATUS)buf64;

            goto ioctlRet;
            } /* FIOWHERE */

        case FIOWHERE64:    /* position within 64 bit boundary */
            {
            retVal = ERROR;
            if ((void *)arg == NULL)
                {
                errnoSet(S_dosFsLib_INVALID_PARAMETER);
                }
            else
                {
                *(fsize_t *)arg = (pFd->seekOutPos != 0)?
                    pFd->seekOutPos : pFd->pos;
                retVal = OK;
                }
            goto ioctlRet;
            } /* FIOWHERE64 */

        case FIOSYNC:
            {
            int saverr;

            /*
             * synchronize FAT copies which only happens if FAT
             * syncing is enabled in the fat handler.
             */

            retVal = pVolDesc->pFatDesc->flush(pFd);
            if (retVal != OK)
                goto ioctlRet;

            /* flush and invalidate I/O cache.  */

            retVal = pVolDesc->dataIoctl (pVolDesc, CBIO_CACHE_FLUSH, 0);
            if (retVal != OK)
                goto ioctlRet;


            /*
             * CBIO_CACH_INVAL is no necessary which probably introduce data
             * missing risk under multi-task when background flush task is enable
             */

            /*
            retVal = pVolDesc->dataIoctl (pVolDesc, CBIO_CACHE_INVAL, 0);
            if (retVal != OK)
                goto ioctlRet;
            */

            /*
             * issue the FIOSYNC call to the underlying XBD (XBD_SYNC).
             * Some XBDs may return ERROR if they cannot
             * handle the FIOSYNC ioctl.
             */

            saverr = errno;
            retVal = xbdIoctl (pVolDesc->device, XBD_SYNC, (void *) arg);
            errno = saverr;

            goto ioctlRet;
            } /* FIOSYNC */

        case FIOFLUSH:
            {
            retVal = OK;

            /* store directory entry */

            if (pFd->accessed || pFd->changed)
                {
                pBuf = (void *)(long)((pFd->accessed) ? DH_TIME_ACCESS :
                                (DH_TIME_ACCESS | DH_TIME_MODIFY)) ;

                retVal = pVolDesc->pDirDesc->updateEntry(
                                        pFd, (u_int)((long)pBuf), 0);
                }

            if (retVal == OK)
                {
                retVal = pVolDesc->dataIoctl (pVolDesc, CBIO_CACHE_FLUSH, 0);
                }

            goto ioctlRet;
            } /* FIOFLUSH */

        case FIONREAD:
            {
            buf64 = (pFd->seekOutPos != 0) ? pFd->seekOutPos : pFd->pos;

            buf64 = (buf64 < pFd->pFileHdl->size) ?
                        pFd->pFileHdl->size - buf64 : (fsize_t) 0;

            retVal = ERROR;

            if ((void *)arg == NULL)
                {
                errnoSet(S_dosFsLib_INVALID_PARAMETER);
                }
            else if (dosFsIsValHuge(buf64))
                {
                errnoSet(S_dosFsLib_32BIT_OVERFLOW);
                *(u_int *)arg = (UINT)(-1);
                }
            else
                {
                *(u_int *)arg = (u_int)buf64;
                retVal = OK;
                }

            goto ioctlRet;
            } /* FIONREAD */

        case FIONREAD64:
            {
            retVal = ERROR;

            if ((void *)arg == NULL)
                {
                errnoSet(S_dosFsLib_INVALID_PARAMETER);
                }
            else
                {
                buf64 = (pFd->seekOutPos != 0)? pFd->seekOutPos :
                                                  pFd->pos;
                *(fsize_t *)arg = (buf64 < pFd->pFileHdl->size)?
                                    pFd->pFileHdl->size - buf64 : (fsize_t) 0;
                retVal = OK;
                }

            goto ioctlRet;
            } /* FIONREAD64 */

        case FIOUNMOUNT:    /* unmount the volume */
            {
            retVal = dosFsVolUnmount(pVolDesc);
            goto ioctlRet;
            } /* FIOUNMOUNT */

        case FIONFREE:
            {
            diskSize64 = pVolDesc->pFatDesc->nFree(pFd);

            retVal = ERROR;

            if ((void *)arg == NULL)
                {
                errnoSet(S_dosFsLib_INVALID_PARAMETER);
                }
            else if (dosFsIsValHuge(diskSize64))
                {
                *(u_int *)arg = (UINT)(-1);
                errnoSet(S_dosFsLib_32BIT_OVERFLOW);
                }
            else
                {
                *(u_int *)arg = (u_int)diskSize64;
                retVal = OK;
                }
            goto ioctlRet;
            } /* FIONFREE */

        case FIONFREE64:
            {
            if ((void *)arg == NULL)
                {
                errnoSet(S_dosFsLib_INVALID_PARAMETER);
                retVal = ERROR;
                goto ioctlRet;
                }

            *(dsize_t *)arg = pVolDesc->pFatDesc->nFree(pFd);

            retVal = OK;

            goto ioctlRet;
            } /* FIONFREE64 */

        case FIOMKDIR:  /* creat new directory */
            {
            retVal = dosFsMakeDir (pFd->pVolDesc, (u_char *)arg);
            goto ioctlRet;
            } /* FIOMKDIR */

        case FIORMDIR:  /* remove directory */
            {
            if ((pFd->pFileHdl->attrib & DOS_ATTR_DIRECTORY) !=
                DOS_ATTR_DIRECTORY)
                {
                errnoSet (ENOTDIR);
                retVal = ERROR;
                }
            else
                retVal = dosFsDelete (pVolDesc, (char *)arg);
            goto ioctlRet;
            } /* FIORMDIR */

        case FIOLABELGET:
            {
            retVal = pVolDesc->pDirDesc->volLabel(
                    pVolDesc, (u_char *)arg, FIOLABELGET);
            goto ioctlRet;
            } /* FIOLABELGET */

        case FIOLABELSET:
            {
            retVal = ERROR;
            if (dosFsFSemTake(pFd, WAIT_FOREVER) == ERROR)
                goto ioctlRet;
            retVal = pVolDesc->pDirDesc->volLabel(
                    pVolDesc, (u_char *)arg, FIOLABELSET);
            dosFsFSemGive(pFd);
            goto ioctlRet;
            } /* FIOLABELSET */

        case FIOATTRIBSET:
            {
            /*
             * ensure sane values before we shove it into the directory
             * We never modify 'entry type' bits (directory or label) so
             * DOS_ATTR_DIRECTORY and DOS_ATTR_VOL_LABEL are masked.
             */

            arg &= (DOS_ATTR_RDONLY | DOS_ATTR_HIDDEN |
                    DOS_ATTR_SYSTEM | DOS_ATTR_ARCHIVE);

            /* preserve entry type bits if they existed already */

            arg |= ((pFd->pFileHdl->attrib) &
                    (DOS_ATTR_DIRECTORY | DOS_ATTR_VOL_LABEL));

            /* ready to set the new attribute */

            pFd->pFileHdl->attrib = (u_char)arg;

            pVolDesc->pDirDesc->updateEntry(pFd,
                                DH_TIME_ACCESS | DH_TIME_MODIFY,
                        0);
            retVal = OK;

            goto ioctlRet;
            } /* FIOATTRIBSET */

        case FIOCONTIG:
            {
#ifdef _WRS_CONFIG_LP64
            if (dosFsIsValHuge(arg))
                {
                errnoSet(S_dosFsLib_32BIT_OVERFLOW);
                retVal = ERROR;
                goto ioctlRet;
                }
#endif
            buf64 = (u_int)arg;
            retVal = dosFsContigAlloc(pFd, &buf64);
            goto ioctlRet;
            } /* FIOCONTIG */

        case FIOUNLINK:
            {
            if (pFd->pFileHdl->attrib & DOS_ATTR_RDONLY)
                {
                errnoSet(S_dosFsLib_READ_ONLY);
                retVal = ERROR;
                }
            else
                retVal = dosFsDeleteByFd(pFd);
            goto ioctlRet;
            } /* FIOUNLINK */

        case FIOCONTIG64:
            {
            retVal = dosFsContigAlloc(pFd, (fsize_t *)arg);
            goto ioctlRet;
            } /* FIOCONTIG64 */

        case FIONCONTIG:
            {
            buf64 = pVolDesc->pFatDesc->maxContig(pFd) <<
                                pVolDesc->secSizeShift;

            retVal = ERROR;

            if (dosFsIsValHuge(buf64))
                {
                errnoSet(S_dosFsLib_32BIT_OVERFLOW);
                }
            else if ((void *)arg == NULL)
                {
                errnoSet(S_dosFsLib_INVALID_PARAMETER);
                }
            else
                {
                *(u_int *)arg = (u_int)buf64;
                retVal = OK;
                }
            goto ioctlRet;
            } /* FIONCONTIG */

        case FIONCONTIG64:
            {
            if ((void *)arg == NULL)
                {
                errnoSet(S_dosFsLib_INVALID_PARAMETER);
                retVal = ERROR;
                goto ioctlRet;
                }
            /*
             * SPR#30464 added (fsize_t) cast to pVolDesc->...  to ensure
             * use of 64bit math.
             * precedence is the (pFd) followed by the -> followed by the
             * cast followed by the shift
             */

            *(fsize_t *)arg = (fsize_t) pVolDesc->pFatDesc->maxContig(pFd) <<
                  pVolDesc->secSizeShift;

            retVal = OK;
            goto ioctlRet;
            } /* FIONCONTIG64 */

        case FIOREADDIR:
            {
            retVal = ERROR;
            if ((void *)arg == NULL)
                {
                errnoSet(S_dosFsLib_INVALID_PARAMETER);
                }
            else if ((pFd->pFileHdl->attrib & DOS_ATTR_DIRECTORY) == 0)
                {
                errnoSet(S_dosFsLib_NOT_DIRECTORY);
                }
            else if (((DIR *) arg)->dd_cookie == ERROR)
                {
                /* any error already occurred while recent readdir */
                }
            /*
             * may be application did seek by
             * direct setting dd_cookie field
             */
            else if ((pFd->pos == DD_COOKIE_TO_POS((DIR *) arg)) ||
                     dosFsSeekDir(pFd, (DIR *) arg) == OK)
                {
                retVal = pVolDesc->pDirDesc->readDir(
                            pFd, (DIR *) arg, NULL);
                }
            goto ioctlRet;
            } /* FIOREADDIR */

            /*
             * this entry combined readdir and stat in one IOCTL
             * and it also return information about directory entry
             * in directory.
             * This IOCTL will use DIRPLUS dirPlusStruct  this will be
             * similiar to DIR with additional field for stat struct and
             * extra field for optional rawEntry data.
             * the stat.st_ino wich is not used dosFs will be used as directory
             * entry cookie.
             */

        case FIOREADDIRPLUS:
            {
            retVal = ERROR;
            if ((void *)arg == NULL)
                {
                errnoSet(S_dosFsLib_INVALID_PARAMETER);
                }
            else if ((pFd->pFileHdl->attrib & DOS_ATTR_DIRECTORY) == 0)
                {
                errnoSet(S_dosFsLib_NOT_DIRECTORY);
                }
            else if (((DIR *) arg)->dd_cookie == ERROR)
                {
                /* any error already occurred while recent readdir */
                }
            /*
             * may be application did seek by
             * direct setting dd_cookie field
             */
            else if ((pFd->pos  == DD_COOKIE_TO_POS((DIR *) arg)) ||
                     dosFsSeekDir(pFd, (DIR *) arg) == OK)
                {
                retVal = dosVDirReaddirPlus(pFd, (DIRPLUS *) arg,NULL);
                }
            goto ioctlRet;
            } /* FIOREADDIR */



        case FIOFSTATGET:
            {
            retVal = dosFsStatGet (pFd, (struct stat *) arg);
            goto ioctlRet;
            } /* FIOFSTATGET */

        case FIOFSTATFSGET:
            {
            retVal = dosFsFSStatGet (pFd, (struct statfs *) arg);
            goto ioctlRet;
            } /* FIOFSTATFSGET */

        case FIOFSTATFSGET64:
            {
            retVal = dosfsFsStatGet64(pFd, (struct statfs64 *)arg);
            goto ioctlRet;
            } /* FIOFSTATFSGET64 */

        case FIOTRUNC:
            {
#ifdef _WRS_CONFIG_LP64
            if (dosFsIsValHuge(arg))
                {
                errnoSet(S_dosFsLib_32BIT_OVERFLOW);
                retVal = ERROR;
                }
            else
#endif
                retVal = dosFsTrunc (pFd, (u_int)arg);
            goto ioctlRet;
            } /* FIOTRUNC */

        case FIOTRUNC64:
            {
            retVal = ERROR;
            if ((void *)arg == NULL)
                {
                errnoSet(S_dosFsLib_INVALID_PARAMETER);
                }
            else
                {
                retVal = dosFsTrunc (pFd, *((fsize_t *)arg));
                }
            goto ioctlRet;
            } /* FIOTRUNC64 */
        case FIOSQUEEZE:
            {   /* TBD: we can think about directory squeezing */
            retVal = OK;
            goto ioctlRet;
            } /* FIOSQUEEZE */

        case FIOCHKDSK:
            {
            retVal = ERROR;
            if (dosFsChkRtn == NULL)
                {
                errnoSet(S_dosFsLib_UNSUPPORTED);
                ERR_MSG(1,"Check disk utility not installed\n", 0,0,0,0,0,0);
                goto ioctlRet;
                }

            if (!IS_ROOT(pFd))
                {
                errnoSet(S_dosFsLib_INVALID_PARAMETER);
                goto ioctlRet;
                }

            /* take ownership on device */

            if (dosFsFSemTake(pFd, WAIT_FOREVER) == ERROR)
                goto ioctlRet;

            if (semTake (pVolDesc->devSem, WAIT_FOREVER) == ERROR)
                goto FIOCHKDSK_ret;

            devSemOwned = TRUE;

            /*
             * it may be device had been unmounted before
             * devSem was taken
             */
            if (pFd->pFileHdl->obsolet)
                {
                errnoSet(S_dosFsLib_FD_OBSOLETE);
                goto FIOCHKDSK_ret;
                }

            /*
             * now force device remounting, but prevent
             * recursive check disk call
             */

            pVolDesc->chkFlags = DOS_CHK_ONLY;

            dosFsVolUnmount(pVolDesc);

            retVal = dosFsVolMount(pVolDesc);

            pVolDesc->chkFlags = 0;

            if (retVal == ERROR)
                goto FIOCHKDSK_ret;

            pFd->pFileHdl->obsolet = 0;

            /* run disk check */

            retVal = dosFsChkDsk(pFd, (u_int)arg);

FIOCHKDSK_ret:

            if (devSemOwned)
                semGive (pVolDesc->devSem);

            dosFsFSemGive (pFd);

            goto ioctlRet;
            } /* FIOCHKDSK */

        case FIOTIMESET:        /* later, surely */
            {
            retVal = ERROR;

            if ((void *)arg == NULL)
                {
                /*
                 * This will update file to current date
                 * and time in either dosDirOldLib.c or
                 * dosVDirLib.c if the FIOTIMESET argument is NULL.
                 * This make utime() behave as it does on Solaris 2.6
                 * SPR#28924.
                 */
                retVal = pVolDesc->pDirDesc->updateEntry(pFd, DH_TIME_MODIFY |
                                                         DH_TIME_ACCESS, 0);
                goto ioctlRet;
                }

            /* avoid setting any time on zero value */

            if (0 != ((struct utimbuf *) arg)->modtime)
                {
                retVal = pVolDesc->pDirDesc->updateEntry(pFd, DH_TIME_MODIFY,
                                            ((struct utimbuf *) arg)->modtime);
                }

            /* avoid setting any time on zero value */

            if (0 != ((struct utimbuf *) arg)->actime)
                {
                retVal = pVolDesc->pDirDesc->updateEntry(pFd, DH_TIME_ACCESS,
                                             ((struct utimbuf *) arg)->actime);
                }
            goto ioctlRet;
            }

        /*
         * Compat: turn old CBIO_TRANS_COMMIT into new FIOCOMMITFS ioctl.
         */
        case CBIO_TRANS_COMMIT:
            function = FIOCOMMITFS;
            /* FALLTHROUGH */

        case FIOCOMMITFS:
            retVal = pVolDesc->dataIoctl (pVolDesc, function, (void *) arg);
            goto ioctlRet;

        /*
         * These should not be issued by user code, so reject them.
         */
        case CBIO_CACHE_FLUSH:
        case CBIO_CACHE_INVAL:
        case CBIO_CACHE_NEWBLK:
        case FIODISCARD:
            retVal = ERROR;
            errnoSet(S_dosFsLib_INVALID_PARAMETER);
            goto ioctlRet;

        case FIOGETFL:
            /* Convert from _F* to O_* */
            *((int *) arg) = (int) (pFd->openMode - 1);
            retVal = OK;
            goto ioctlRet;

        case FIOCHMOD:
            {
            if ((arg == (S_IRUSR | S_IXUSR | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH ))
                || (arg == (S_IRWXU | S_IRWXG | S_IRWXO )))
                {
                /* set RWXRWXRWX or R-XR-XR-X */
                if (arg & S_IWUSR)
                    {
                    /* set RWXRWXRWX */
                    pFd->pFileHdl->attrib &= (~DOS_ATTR_RDONLY) ;
                    }
                else
                    {
                    /* set R-XR-XR-X */
                    pFd->pFileHdl->attrib |= (DOS_ATTR_RDONLY) ;
                    }

                retVal = pVolDesc->pDirDesc->updateEntry(pFd,
                                 DH_TIME_ACCESS | DH_TIME_MODIFY, 0);
                }
            else
                {
                /* not support */
                errnoSet (ENOTSUP);
                retVal = ERROR;
                }
            goto ioctlRet;
            } /* FIOCHMOD */

        case FIOINODETONAME:    /* probably never again */
        /* not supported */
        default:
            {
            int error;

            /*
             * Call device driver function. Since the command can be an
             * ejection one (XBD_HARD_EJECT for example), we can not rely
             * on the volume to be still valid when we come back. Therefore
             * we release the file semaphore here.
             * Note that dosFs policy regarding locks, is to allways take the
             * file semaphore first and then the device or mem semaphores.
             * However, in an eject scenario we first need to take the device
             * semaphore for mutual exclusion and then to clean the rest, It
                 * is for this reason that we cannot rely on the ejection to pend
             * on the file semaphore before deleting it. It could lead to a
             * deadlock.
             */
            dosFsFSemGive (pFd);

            error = xbdIoctl (pVolDesc->device, function, (void *) arg);
            if (error)
                {
                errnoSet (error);
                retVal = ERROR;
                }
            else
                retVal = OK;

            return (retVal);
            }
        } /* switch */

ioctlRet:
    dosFsFSemGive(pFd);
    return (retVal);
    } /* dosFsIoctl() */

/*******************************************************************************
*
* dosFsLastAccessDateEnable - enable last access date updating for this volume
*
* This function enables or disables updating of the last access date directory
* entry field on open-read-close operations for the given dosFs volume.  The
* last access date file indicates the last date that a file has been read or
* written.  When the optional last access date field update is enabled, read
* operations on a file will cause a write to the media.
*
* RETURNS: OK or ERROR if the volume is invalid or enable is not TRUE or FALSE.
*
*/
STATUS dosFsLastAccessDateEnable
    (
    DOS_VOLUME_DESC_ID dosVolDescId, /* dosfs volume ID to alter */
    BOOL enable      /* TRUE = enable update, FALSE = disable update */
    )
    {
    /* ensure this is a valid DOS_VOLUME_DESC_ID */

    if (!_WRS_ALIGN_CHECK ((long)dosVolDescId, DOS_VOLUME_DESC_ID))
        return (ERROR);           /* alignment failed */

    if ((DOS_FS_MAGIC != dosVolDescId->magic)  ||
        ((TRUE != enable) && (FALSE != enable)))
        {
        return (ERROR);
        }

    /* set the last access field update boolean */

    dosVolDescId->updateLastAccessDate = enable;

    return (OK);
    } /* dosFsEnableLastAccessDate */

/*******************************************************************************
*
* dosFsLibInit - prepare to use the dosFs library
*
* This routine initializes the dosFs library.
* This initialization is enabled when the configuration macro INCLUDE_DOSFS
* is defined.
* This routine installs dosFsLib as a
* driver in the I/O system driver table, and allocates and sets up
* the necessary structures.
* The driver number assigned to dosFsLib is placed
* in the global variable <dosFsDrvNum>.
*
* RETURNS: OK or ERROR, if driver can not be installed.
*
*/
STATUS dosFsLibInit
    (
    int  maxFiles,
    int  options
    )
    {
    if (dosFsDrvNum != ERROR)
        return (OK);

    dosFsDrvNum = iosDrvInstall (
                      (DRV_CREATE_PTR) dosFsCreate,
                      (DRV_REMOVE_PTR) dosFsDelete,
                      (DRV_OPEN_PTR) dosFsOpen,
                      (DRV_CLOSE_PTR) dosFsClose,
                      (DRV_READ_PTR) dosFsRead,
                      (DRV_WRITE_PTR) dosFsWrite,
                      (DRV_IOCTL_PTR) dosFsIoctl
                     );

    dosFsMaxFiles      = maxFiles;
    dosFsCreateOptions = options;

    return (dosFsDrvNum == ERROR ? ERROR : OK); /* SPR#65271,65009 */
    } /* dosFsLibInit() */

/*******************************************************************************
*
* dosFsDevCreate - create file system device.
*
* This routine associates an XBD device with a logical I/O device name
* and prepare it to perform file system functions.
* It takes an XBD device handle, typically created by xbdBlkDevCreate() or
* xbdPartitionDevCreate(), and defines it as a dosFs volume.  As a result, when
* high-level I/O operations (e.g., open(), write()) are performed on
* the device, the calls will be routed through dosFsLib.  The <device>
* parameter is the handle of the underlying partition or block
* device XBD.
*
* The argument <maxFiles> specifies the number of files
* that can be opened at once on the device.
*
* The volume structure integrity can be automatically checked
* during volume mounting. Parameter <dosDevCreateOptions>
* defines checking level (DOS_CHK_ONLY or DOS_CHK_REPAIR),
* that can be bitwise or-ed with check verbosity level value
* (DOS_CHK_VERB_SILENT, DOS_CHK_VERB_1 or DOS_CHK_VERB_2).
*
* If the value of <dosDevCreateOptions> is 0, the default checking
* level is used. The default level is (DOS_CHK_ONLY | DOS_CHK_VERB_2).
*
* To suppress the automatic check disk, bitwise or (DOS_CHK_NONE)
* or set <dosDevCreateOptions> to NONE.
*
* Disk checking is normally suppressed on volumes marked clean.  To
* force a disk-check, bitwise or (DOS_CHK_FORCE).
*
* The volume may be configured to request DOS_WRITE_THROUGH writes
* for some or all of the disk operations. Additional bits of parameter
* <dosDevCreateOptions> define the volume's write-through setting.
* The default (zero) is to use copyback writes (DOS_WRITE) for all
* write operations. The default is the fastest configuration.
*
* To writethrough all FAT table write operations,
* or in DOS_WRITE_THROUGH_FAT
* To writethrough all directory entry write operations,
* or in DOS_WRITE_THROUGH_DIR
* To writethrough all user data buffers,
* or in DOS_WRITE_THROUGH_USR
* To writethrough both FAT and DIRENT operations, or them together.
* (DOS_WRITE_THROUGH_DIR | DOS_WRITE_THROUGH_FAT | DOS_CHK_NONE)
*
* User data writes will still use copyback DOS_WRITE operations when
* using (DOS_WRITE_THROUGH_DIR | DOS_WRITE_THROUGH_FAT)
*
* To write-through all write operations, including all user data,
* or in DOS_WRITE_THROUGH_ALL.  This is the slowest operation and
* all write operation made by the file system will be DOS_WRITE_THROUGH.
*
* To enable Unicode filenames, or in DOS_FILENAMES_UNICODE.  Case
* insensitivity (if enabled) currently applies only to ASCII values even
* when Unicode is turned on.  For instance, a German eszet is never
* considered the same as two uppercase S characters, but two uppercase
* S characters can match two lowercase S characters because these are
* both in the first 128 character codes.
*
* NOTE: Setting parameter <dosDevCreateOptions> to NONE (-1) will both
* disable the automated chkdsk and force copyback (DOS_WRITE) operation.
* Unicode filenames will not be enabled.
*
* Note that during a call to dosFsDevCreate() actual disk accesses
* are deferred to the time when open() or creat() are first called.
* That is also when the automatic disk checking will take place.
* Therefore this function will succeed in cases where a removable
* disk is not present in the drive.
*
* RETURNS: OK, or ERROR if the device name is already in use or
* insufficient memory.
*
* /NOMANUAL
*/

STATUS dosFsDevCreate
    (
    char *    pDevName,            /* device name */
    device_t  device,              /* underlying XBD block device */
    u_int     maxFiles,            /* max no. of simultaneously open files */
    int       dosDevCreateOptions  /* write option & volume integrity */
    )
    {
    DOS_VOLUME_DESC_ID  pVolDesc = NULL; /* volume descriptor ptr */
    SEM_ID              tmpSem = NULL;
    int                 error;
    int                 index;
    STATUS              stat;
    int                 wantDiscard;
    XBD_INFO            xbdInfo;

    /* install dos file system as a driver */

    if (dosFsDrvNum == ERROR)
        goto error_drv;

    /* validate underlying device */

    if (device == (device_t)((long) NULL))
        {
        ERR_MSG(1, "NULL device_t\n", 0,0,0,0,0,0);
        goto error_drv;
        }

    /* allocate volume descriptor */

    pVolDesc = (DOS_VOLUME_DESC_ID) KHEAP_ALLOC (sizeof (*pVolDesc));

    if (pVolDesc == NULL)
        goto error_volalloc;

    bzero ((char *) pVolDesc, sizeof(*pVolDesc));

    pVolDesc->device = device;

    /* initialize XBD data */

    error = xbdBlockSize (pVolDesc->device, (unsigned *)&pVolDesc->blockSize);
    if (error)
        {
        errnoSet (error);
        goto error_semcreate1;
        }

    error = xbdNBlocks (pVolDesc->device, &pVolDesc->nBlocks);
    if (error)
        {
        errnoSet (error);
        goto error_semcreate1;
        }

    /*
     * Retrieve properties from underlying XBD.
     * If XBD_GETINFO is not supported, the device is assumed to have
     * both read and write capabilities; it is also assumed not to
     * support the discard interface.  In such an event, it will query the
     * device to see if it does support the discard interface.  This is
     * because not all XBD drivers support the XBD_GETINFO command.
     */

    bzero ((char *) &xbdInfo, sizeof (xbdInfo));
    error = xbdIoctl (pVolDesc->device, XBD_GETINFO, &xbdInfo);

    pVolDesc->readOnly = ((xbdInfo.properties & XBD_INFO_READONLY) != 0);
    wantDiscard = ((xbdInfo.properties & XBD_INFO_DISCARD) != 0);

    if (error != OK)
        {
        (void) xbdIoctl (pVolDesc->device, FIODISCARDGET, &wantDiscard);
        }

    pVolDesc->doSecDiscard = (wantDiscard == 1);

    /* create bio management resources */

    pVolDesc->volBioLock = semMCreate (dosFsMutexOptions);

    if (pVolDesc->volBioLock == NULL)
        {
        goto error_semcreate1;
        }

    pVolDesc->volBioCount = semCCreate (SEM_Q_PRIORITY, DOS_VOLUME_BIO_SIZE);
    if (pVolDesc->volBioCount == NULL)
        {
        goto error_semcreate2;
        }

    for (index = 0; index < DOS_VOLUME_BIO_SIZE; index++)
        {
        pVolDesc->dosBioArray[index].bioIndex = (UINT16) index;

        /* initialize free bio list. 0xffff means no more free bios */

        if ((index + 1) == DOS_VOLUME_BIO_SIZE)
            pVolDesc->dosBioArray[index].nextFreeBioIndex = 0xffff;
        else
            pVolDesc->dosBioArray[index].nextFreeBioIndex = (UINT16)(index + 1);

        pVolDesc->dosBioArray[index].syncSemId = semBCreate (SEM_Q_PRIORITY,
                                                             SEM_EMPTY);
        if (pVolDesc->dosBioArray[index].syncSemId == NULL)
            goto error_semcreate3;
        }

    for (index = 0; index < DOS_VOLUME_BIO_SIZE; index++)
        {
        pVolDesc->dosBioArray[index].bio.bio_data = bio_alloc (device,
                                                        dosFsVolumeBioBufferSize);
        if (pVolDesc->dosBioArray[index].bio.bio_data == NULL)
            goto error_semcreate4;
        }

    /* dosBioArray[0] is the first free bio to use */

    pVolDesc->nextFreeBio = 0;

    /* create tiny cache */

    if (dosFsVolBufCreate (pVolDesc) == ERROR)
        {
        goto error_bioAlloc;
        }

    /* initialize tiny cache management members in volume descriptor */

    pVolDesc->volMemAccess = 0;
    pVolDesc->volMemHits = 0;
    pVolDesc->volMemLastHit = -1;
    pVolDesc->volMemSemId = semMCreate (SEM_Q_PRIORITY | SEM_DELETE_SAFE |
                                        SEM_INVERSION_SAFE);
    if (pVolDesc->volMemSemId == NULL)
        goto error_membuf;

    /* init semaphores */

    pVolDesc->devSem = semMCreate (dosFsMutexOptions);

    if (NULL == pVolDesc->devSem)
        {
        goto error_semmemcreate;
        }

    pVolDesc->shortSem = semMCreate (dosFsMutexOptions);

    if (NULL == pVolDesc->shortSem)
        {
        goto error_semcreate5;
        }

    /* init file descriptors and handles list */

    maxFiles = (maxFiles == 0) ? DOS_NFILES_DEFAULT : maxFiles;
    maxFiles += 6;

    pVolDesc->pFdList =
        KHEAP_ALLOC((maxFiles * (sizeof(*pVolDesc->pFdList))));

    if (pVolDesc->pFdList == NULL)
        goto error_fdalloc;
    bzero ((char *)pVolDesc->pFdList,
            (maxFiles * (sizeof(*pVolDesc->pFdList))));

    pVolDesc->pFhdlList =
        KHEAP_ALLOC((maxFiles * (sizeof(*pVolDesc->pFhdlList))));

    if (pVolDesc->pFhdlList == NULL)
        goto error_fhdlalloc;

    bzero ((char *)pVolDesc->pFhdlList,
       (maxFiles * (sizeof(*pVolDesc->pFhdlList))));

    pVolDesc->pFsemList =
        KHEAP_ALLOC((maxFiles * (sizeof(SEM_ID))));

    if (pVolDesc->pFsemList == NULL)
        goto error_fsemalloc;
    bzero ((char *)pVolDesc->pFsemList, (maxFiles * (sizeof(SEM_ID))));

    pVolDesc->maxFiles = (u_short)maxFiles;

    /* init file semaphores */

    for (maxFiles = 0; maxFiles < pVolDesc->maxFiles; maxFiles++)
        {
        tmpSem = semMCreate (dosFsMutexOptions);

        if (NULL == tmpSem)
            {
            goto error_fsemcreate;
            }

        pVolDesc->pFsemList[maxFiles] = tmpSem;

        tmpSem = NULL;
        }

    /* device descriptor have been initiated. Install the device */

    pVolDesc->magic = DOS_FS_MAGIC;

    pVolDesc->mounted = FALSE;

    pVolDesc->updateLastAccessDate = FALSE; /* SPR#68203 */

    /* Initially directory paths are not case sensitive */
    pVolDesc->volIsCaseSens = FALSE;

    /* check disk autocall level */

    if ((dosDevCreateOptions != (u_int) NONE) &&
       ((dosDevCreateOptions & DOS_CHK_FLAGS_MASK) != (u_int) DOS_CHK_NONE))
        {
        pVolDesc->autoChk =(u_char)(
                (dosDevCreateOptions & DOS_CHK_REPAIR) ?
                    DOS_CHK_REPAIR : DOS_CHK_ONLY);
        pVolDesc->autoChk = (u_char)(pVolDesc->autoChk | (dosDevCreateOptions & DOS_CHK_FORCE));

        /* extract the auto chk verbosity, verify and assign */

        switch (dosDevCreateOptions & DOS_CHK_VERB_MASK)
            {
            case DOS_CHK_VERB_0:
            case DOS_CHK_VERB_1:
            case DOS_CHK_VERB_2:
                pVolDesc->autoChkVerb =
                               (u_char)((dosDevCreateOptions & DOS_CHK_VERB_MASK) >> 8);
                break;
            default:
                /* Force out of range verbosity to maximum level */

                pVolDesc->autoChkVerb = DOS_CHK_VERB_2 >> 8;
                break;
            } /* switch */
        }

    /* write through options */

    if ((dosDevCreateOptions != (u_int) NONE))
        {
        pVolDesc->volWriteOpt = (dosDevCreateOptions & DOS_WRITE_THROUGH_MASK);
        }

    /*
     * Unicode -- note that "old style" and VxWorks-long-name dir handlers
     * can ignore this, or set it to FALSE, since Unicode file names currently
     * only work with variable-length directory entries.
     */

    if ((dosDevCreateOptions != (u_int) NONE))
        {
        pVolDesc->volUnicode =
                (dosDevCreateOptions & DOS_FILENAMES_UNICODE) != 0;

        pVolDesc->volNoDuplicateFat =
                (dosDevCreateOptions & DOS_DUPLICATE_FAT_DISABLE) != 0;
        }

    /* initialization for data transfers */

    pVolDesc->dataBlkWrite = dosFsXbdBlkWrite;
    pVolDesc->dataBlkRead = dosFsXbdBlkRead;
    pVolDesc->dataBytesRW = dosFsXbdBytesRW;
    pVolDesc->dataIoctl = dosFsXbdIoctl;

    stat = dosFsVolMountPart1 (pVolDesc);
    if (stat == ERROR)
        {
        ERR_MSG (2, "error when mounting volume 0x%x\n", (_Vx_usr_arg_t) pVolDesc,
                 0,0,0,0,0);
        goto error_mount;
        }

    iosLock();
    if (iosDevReplaceExt((void *)pVolDesc, pDevName, dosFsDrvNum) == ERROR)
        {
        pVolDesc->magic = (UINT)NONE;
        iosUnlock();
        goto error_mount;
        }

    /* delayed deletion registration */
    iosDevDelCallback((DEV_HDR *) pVolDesc, (FUNCPTR) dosFsFinishDevDelete);
    iosUnlock();

    if (dosFsVolMountPart2 (pVolDesc) == ERROR)
        {
        ERR_MSG (1, "error when mounting volume 0x%x\n", (_Vx_usr_arg_t) pVolDesc,
             0,0,0,0,0);
        goto error_mount;
        }

    xbdIoctl (device, XBD_STACK_COMPLETE, NULL);
    /* Raise an event to let others know the path is hooked up */
    fsPathAddedEventRaise (pDevName);

    return (OK);

/* Error Handling */
error_mount:
    maxFiles = pVolDesc->maxFiles;
error_fsemcreate:
    /*
    * If we get here, we must undo the file semaphore create. maxFiles is the
    * index of the semaphore we failed on, or of the number of files. Thus we
    * don't free the semaphore at maxFiles.
    */
    if (maxFiles)
        {
        maxFiles--;
        do
            {
            semDelete(pVolDesc->pFsemList[maxFiles]);
            } while (maxFiles--);
        }

    KHEAP_FREE(pVolDesc->pFsemList);
error_fsemalloc:
    KHEAP_FREE(pVolDesc->pFhdlList);
error_fhdlalloc:
    KHEAP_FREE(pVolDesc->pFdList);
error_fdalloc:
    semDelete (pVolDesc->shortSem);
error_semcreate5:
    semDelete (pVolDesc->devSem);
error_semmemcreate:
    semDelete (pVolDesc->volMemSemId);
error_membuf:
    for (index = 0; index < VOL_MEM_NUM; index++)
        {
        if (pVolDesc->volMem[index].volMemBase != NULL)
            KHEAP_FREE (pVolDesc->volMem[index].volMemBase);
        }
error_bioAlloc:
    for (index = 0; index < DOS_VOLUME_BIO_SIZE; index++)
        {
        bio_free (pVolDesc->dosBioArray[index].bio.bio_data);
        }
error_semcreate4:
    for (index = 0; index < DOS_VOLUME_BIO_SIZE; index++)
        {
        semDelete (pVolDesc->dosBioArray[index].syncSemId);
        }
error_semcreate3:
    semDelete (pVolDesc->volBioCount);
error_semcreate2:
    semDelete (pVolDesc->volBioLock);
error_semcreate1:
    KHEAP_FREE ((char *)pVolDesc);
error_volalloc:
error_drv:
    ERR_MSG(2, "Failed to create a dosFs volume\n", 0,0,0,0,0,0);

    return (ERROR);
    } /* dosFsDevCreate() */

/***************************************************************************
*
* dosFsDevDelete - delete a dosFs volume
*
* This routine deletes a dosFs volume.
*
* RETURNS: OK on success, ERROR otherwise
*/

STATUS dosFsDevDelete
    (
    DOS_VOLUME_DESC_ID  pVolDesc    /* pointer to volume descriptor */
    )
    {

    if (INT_RESTRICT () != OK)
        return (ERROR);

    /* check volume descriptor */

    if ((pVolDesc == NULL) || pVolDesc->magic != DOS_FS_MAGIC)
        {
        errnoSet(S_dosFsLib_INVALID_PARAMETER);
        return (ERROR);
        }

    /* remove from coreIO. iosDevDelete() will call dosFsFinishDevDelete() */

    iosDevDelete ((DEV_HDR *) pVolDesc);

    return (OK);
    }

/***************************************************************************
*
* dosFsFinishDevDelete - finish deletion of a dosFs device
*
* This routine deletes a dosFs device.
*
* RETURNS: OK on success, ERROR otherwise
*/

LOCAL void dosFsFinishDevDelete
    (
    DOS_VOLUME_DESC * pVolDesc
    )
    {
    u_int maxFiles;
    int ix;

    /* prevent deletion process from reentrant call */

    if (semTake(pVolDesc->devSem, WAIT_FOREVER) != OK)
        {
        ERR_MSG(1, "\a dosFsFinishDevDelete() can not take the semphore \a\n", 0,0,0,0,0,0);
        return;
        }

    /* delete disk cache if supported on this volume */

    if ((dosFsCacheDeleteRtn != NULL) &&
        ((pVolDesc->cache[DOS_DATA_DIR_CACHE].size != 0) ||
          (pVolDesc->cache[DOS_FAT_CACHE].size != 0)))
        {
        dosFsCacheDeleteRtn (pVolDesc);
        }

    semDelete (pVolDesc->volMemSemId);
    for (ix = 0; ix < VOL_MEM_NUM; ix++)
        {
        if (pVolDesc->volMem[ix].volMemBase != NULL)
            KHEAP_FREE (pVolDesc->volMem[ix].volMemBase);
        }

    maxFiles = 0;

    while (maxFiles < pVolDesc->maxFiles)
        {
        semDelete (pVolDesc->pFsemList [maxFiles]);
        maxFiles++;
        }

    KHEAP_FREE (pVolDesc->pFsemList);
    KHEAP_FREE (pVolDesc->pFhdlList);
    KHEAP_FREE (pVolDesc->pFdList);
    semDelete (pVolDesc->shortSem);

    for (ix = 0; ix < DOS_VOLUME_BIO_SIZE; ix++)
        {
        bio_free (pVolDesc->dosBioArray[ix].bio.bio_data);
        }

    for (ix = 0; ix < DOS_VOLUME_BIO_SIZE; ix++)
        {
        semDelete (pVolDesc->dosBioArray[ix].syncSemId);
        }

    semDelete (pVolDesc->volBioCount);
    semDelete (pVolDesc->volBioLock);


    /* pVolDesc->pDirDesc and pVolDesc->pFatDesc need to be cleaned */

    if (pVolDesc->pFatDesc != NULL)
        {
        MS_FAT_DESC * pFatDesc = (MS_FAT_DESC *) pVolDesc->pFatDesc;

        semDelete (pFatDesc->allocSem);
        KHEAP_FREE ((char *) pVolDesc->pFatDesc);
        }

    if (pVolDesc->pDirDesc != NULL)
        {
        DOS_DIR_PDESCR * pDirDesc = (DOS_DIR_PDESCR *) pVolDesc->pDirDesc;

        if (pDirDesc->vfatSpace != NULL)
            {
            KHEAP_FREE ((char *) pDirDesc->vfatSpace);

            if (pDirDesc->vfatSem != NULL)
                semDelete (pDirDesc->vfatSem);
            }
        KHEAP_FREE ((char *) pVolDesc->pDirDesc);
        }

    semDelete (pVolDesc->devSem);
    KHEAP_FREE ((char *)pVolDesc);
    }

/*******************************************************************************
*
* dosFsEject - handler to be called by the Event Reporting Framework.
*
* This is the routine that is called by the Event Reporting Framework when
* an ejection event on the device is issued.
*
* RETURNS: N/A.
*
*/

LOCAL void dosFsEject
    (
    UINT16 Category,
    UINT16 Type,
    void * eventData,
    void * userData
    )
    {
    device_t        dev;
    DOS_VOLUME_DESC_ID  id;

    if ((Category == xbdEventCategory) &&
        (Type == xbdEventRemove || Type == xbdEventMediaChanged))
        {
        dev = (device_t) (long)eventData;
        id  = (DOS_VOLUME_DESC_ID) userData;

        /* Check to see if this event is for us */
        if (id->device != dev)
            return;

        /* This event is for us - unregister from both registered events */

        erfHandlerUnregister (xbdEventCategory, xbdEventRemove, dosFsEject,
                              id);

    erfHandlerUnregister (xbdEventCategory, xbdEventMediaChanged,
                              dosFsEject, id);

    if (Type == xbdEventRemove)
            iosDevDelete ((DEV_HDR *) id);

    else /* xbdEventMediaChanged */
        iosDevSuspend ((DEV_HDR *) id);
        }
    }

/***************************************************************************
*
* dosFsMonitorDevCreate - create a dosFs volume through the fs monitor
*
* This routine creates an DOS FS device.
*
* RETURNS: OK if successful. ERROR otherwise.
*
* /NOMANUAL
*/

STATUS dosFsMonitorDevCreate
    (
    device_t  xbdId,           /* XBD for the device on which to mount. */
    char *    pDevName         /* Name of the DOS FS device (mount point). */
    )
    {
    DOS_VOLUME_DESC_ID id;
    int fd;

    if (dosFsDevCreate (pDevName, xbdId, dosFsMaxFiles,
                        dosFsCreateOptions) != OK)
        {
        return (ERROR);
        }

    /* create disk cache for this volume, if supported */

    if ((dosFsCacheCreateRtn != NULL) &&
        ((dosFsCacheDataDirDefaultSize != 0) ||
         (dosFsCacheFatDefaultSize != 0)))
        {
        dosFsCacheCreateRtn (pDevName, 0, dosFsCacheDataDirDefaultSize,
                             0, dosFsCacheFatDefaultSize);
        }

    id = dosFsVolDescGet (pDevName, NULL);

    if (id == NULL)
        {
        /* what should we do if dosFsVolDescGet() fails ? */
        return (ERROR);
        }

    /* Make sure the root dir can be opened */
    fd = open (pDevName, O_RDONLY, 0777);
    if (fd < 0)
        {
        /*
         * Can't even open ourselves. This is probably due to a corrupt or
         * badly formatted disk.
         */

        dosFsDevDelete (id);
        return (ERROR);
        }

    close (fd);

    erfHandlerRegister(xbdEventCategory, xbdEventRemove, dosFsEject, id, 0);

    erfHandlerRegister(xbdEventCategory, xbdEventMediaChanged, dosFsEject,
                       id, 0);

    return (OK);
    }

/***************************************************************************
*
* dosFsDiskProbe - probe if a device contains a valid dosFs
*
* This routine probes if a device (or a partition) contains a valid DOS FS.
*
* RETURNS: OK if successful. ERROR otherwise.
*
* /NOMANUAL
*/

STATUS dosFsDiskProbe
    (
    device_t            xbdDevice    /* XBD device to probe */
    )
    {
    unsigned            blkSize;
    int                 error;
    u_char *            bootSec;
    struct bio          bio;
    char                sysId[DOS_SYS_ID_LEN + 1]={0};

    error = xbdBlockSize (xbdDevice, &blkSize);
    if (error != OK)
        return (error);

    bzero ((char *) &bio, sizeof (struct bio));

    bio.bio_data = bio_alloc (xbdDevice, 1);
    if (bio.bio_data == NULL)
        return (ERROR);

    bio.bio_caller1 = (void *) semBCreate (SEM_Q_PRIORITY, SEM_EMPTY);
    if (bio.bio_caller1 == NULL)
        {
        bio_free (bio.bio_data);
        return (ERROR);
        }

    bio.bio_dev    = xbdDevice;
    bio.bio_blkno  = DOS_BOOT_SEC_NUM;
    bio.bio_bcount = blkSize;
    bio.bio_error  = OK;
    bio.bio_flags  = BIO_READ;
    bio.bio_done   = (void *) dosFsXbdDone;

    xbdStrategy (xbdDevice, &bio);

    if (semTake ((SEM_ID) bio.bio_caller1, WAIT_FOREVER) != OK)
        {
        bio_free (bio.bio_data);
        return (ERROR);
        }

    if (bio.bio_resid != 0 || bio.bio_error != OK)
        {
        error = ERROR;
        goto probe_return;
        }

    bootSec = (u_char *) bio.bio_data;

    /* check for both acceptable Intel 80x86 `jmp' opcodes */

    if (bootSec [DOS_BOOT_JMP] != 0xe9 && bootSec [DOS_BOOT_JMP] != 0xeb)
        {
        error = ERROR;
        goto probe_return;
        }

    /*
     * Check the sysid (offset 0x03) in BPB to identify FAT system.
     * The method of sysid checking is simple and effective, but not
     * perfect since the content of sysid can be changed to anything.
     * But for compatible almost all driver set it to "MSWIN4.1".
     */
    bcopy((char *)bootSec+DOS_BOOT_SYS_ID, sysId,  DOS_SYS_ID_LEN);
    if(strstr(sysId, "DOS") == NULL
        && strstr(sysId, "FAT") == NULL
        && strstr(sysId, "VXEXT") == NULL
        && strstr(sysId, "MSWIN") == NULL
        && strstr(sysId, "dos") == NULL
        )
        {
        error = ERROR;
        goto probe_return;
        }

    error = OK;

probe_return:
    bio_free (bio.bio_data);
    semDelete ((SEM_ID) bio.bio_caller1);

    return (error);
    }

/*******************************************************************************
*
* dosFsHdlrInstall - install handler.
*
* This library does not directly access directory structure,
* nor FAT, rather it uses particular handlers to serve such accesses.
* This function is intended for use by the dosFsLib sub-modules only.
*
* This routine installs a handler into DOS FS handlers list.
* There are two such lists: FAT Handlers List (<dosFatHdlrsList>)
* and Directory Handlers List (<dosDirHdlrsList>).
* Each handler must provide its unique Id (see dosFsLibP.h) and
* pointer to appropriate list to install it to. All lists
* are sorted by Id-s in ascending order. Every handler is tried
* to be mounted on each new volume in accordance to their order
* in list, until succeeded. So preferable handlers, that supports
* the same type of volumes must have less Id values.
*
* RETURNS: STATUS.
*
* /NOMANUAL
*/

STATUS dosFsHdlrInstall
    (
    DOS_HDLR_DESC_ID    hdlrsList,  /* appropriate list */
    DOS_HDLR_DESC_ID    hdlr        /* ptr on handler descriptor */
    )
    {
    int                 i;
    STATUS              retStat = ERROR;
    DOS_HDLR_DESC       hdlrBuf1, hdlrBuf2;

    if (hdlr == NULL)
        {
        ERR_MSG(1, "\a NULL handler descriptor ptr \a\n", 0,0,0,0,0,0);
        return ERROR;
        }
    if (hdlrsList != dosFatHdlrsList && hdlrsList != dosDirHdlrsList)
        {
        ERR_MSG(1, "\a Unknown handler list \a\n", 0,0,0,0,0,0);
        return ERROR;
        }

    hdlrBuf1 = *hdlr;

    for (i = 0; i < DOS_MAX_HDLRS; i++)
        {
        if ((hdlrsList[ i ] .id == 0) ||
           (hdlrsList[ i ] .id > hdlrBuf1.id))
            {
            retStat = OK;
            hdlrBuf2 = hdlrsList[ i ];
            hdlrsList[ i ] = hdlrBuf1;
            hdlrBuf1 = hdlrBuf2;
            }
        }

    if (retStat == ERROR)
        {
        ERR_MSG(1, "\a Handler not installed \a\n", 0,0,0,0,0,0);
        }
    return retStat;
    } /* dosFsHdlrInstall() */

/*******************************************************************************
*
* dosFsBioGet - get a preallocated bio struct and buffer from this volume.
*
*
* RETURNS: STATUS.
*
* /NOMANUAL
*/

LOCAL struct bio * dosFsBioGet
    (
    DOS_VOLUME_DESC_ID  pVolDesc    /* pointer to volume descriptor */
    )
    {
    struct bio * pBio;
    int bioIndex;

    /* fist take the counting semaphore to grant a free bio */

    if (semTake (pVolDesc->volBioCount, WAIT_FOREVER) == ERROR)
        {
        return (NULL);
        }

    /*
     * If we are here, that means that we have been granted a free bio.
     * Still, to figure out which one are we getting, mutual exclusion
     * to access the volume bio array is needed. A task releasing a bio
     * will take this same semaphore.
     */

    if (semTake (pVolDesc->volBioLock, WAIT_FOREVER) == ERROR)
        {
        /* restore count of free bios */

        semGive (pVolDesc->volBioCount);
        return (NULL);
        }

    if (pVolDesc->nextFreeBio == 0xffff)
        {
        /* we shouldn't get here */

        semGive (pVolDesc->volBioCount);
        semGive (pVolDesc->volBioLock);

        ERR_MSG (1,"volume free bio list is corrupted\n", 0,0,0,0,0,0);
        return (NULL);
        }

    bioIndex = pVolDesc->nextFreeBio;
    pBio = &(pVolDesc->dosBioArray[bioIndex].bio);
    pVolDesc->nextFreeBio = pVolDesc->dosBioArray[bioIndex].nextFreeBioIndex;

    semGive (pVolDesc->volBioLock);
    return (pBio);
    }

/*******************************************************************************
*
* dosFsBioRelease - release a preallocated bio from this volume.
*
*
* RETURNS: STATUS.
*
* /NOMANUAL
*/

LOCAL STATUS dosFsBioRelease
    (
    DOS_VOLUME_DESC_ID  pVolDesc,    /* pointer to volume descriptor */
    struct bio * pBio
    )
    {
    DOS_BIO * pDosBio = (DOS_BIO *) pBio;

    /* mutual exclusion */

    if (semTake (pVolDesc->volBioLock, WAIT_FOREVER) == ERROR)
        {
        return (ERROR);
        }

    pDosBio->nextFreeBioIndex = pVolDesc->nextFreeBio;
    pVolDesc->nextFreeBio = pDosBio->bioIndex;

    /* increment count of free bios */

    semGive (pVolDesc->volBioCount);

    /* release lock */

    semGive (pVolDesc->volBioLock);

    return (OK);
    }

/*******************************************************************************
*
* dosFsXbdDone - callback when an XBD transaction is complete.
*
*
* RETURNS: STATUS.
*
* /NOMANUAL
*/

LOCAL void dosFsXbdDone
    (
    struct bio * pBio
    )
    {
    semGive ((SEM_ID) pBio->bio_caller1);
    }

/*******************************************************************************
*
* dosFsBlkXfer - read/write a block from/to the underlying device.
*
*
* RETURNS: STATUS.
*
* /NOMANUAL
*/

LOCAL int dosFsBlkXfer
    (
    DOS_VOLUME_DESC *   pVolDesc,
    struct bio *        pBio,
    sector_t            blockNum,
    unsigned            byteCount,
    unsigned            flags
    )
    {
    /* fill out the bio structure */

    pBio->bio_blkno = blockNum;
    pBio->bio_bcount = byteCount;
    pBio->bio_flags = flags;
    pBio->bio_done = dosFsXbdDone;
    pBio->bio_caller1 = (void *) (((DOS_BIO *)pBio)->syncSemId);
    pBio->bio_chain = NULL;
    pBio->bio_error = OK;
    pBio->bio_resid = 0;

    /* Make the actual transaction */

    xbdStrategy (pVolDesc->device, pBio);

    /* Wait for RW transaction to complete */

    if (semTake ((SEM_ID) pBio->bio_caller1, WAIT_FOREVER) != OK)
        {
        return (ERROR);
        }

    if (pBio->bio_resid != 0)
        return (ERROR);
    else
        return (pBio->bio_error);
    }


/*******************************************************************************
*
* dosFsXbdBlkRead - read blocks from the underlying XBD block device.
*
*
* RETURNS: STATUS.
*
* /NOMANUAL
*/

STATUS dosFsXbdBlkRead
    (
    DOS_VOLUME_DESC *   pVolDesc,   /* volume descriptor */
    sector_t            startBlock, /* starting block of transfer */
    sector_t            numBlocks,  /* number of blocks to transfer */
    addr_t              buffer      /* address of the memory buffer */
    )
    {
    struct bio *        pBio;
    unsigned            blocksRead;
    char *              pDest;
    int                 error;
    UINT                blocksToRead;
    UINT                bytesToRead;
    int                 retVal = 0;
    sector_t            tmp;
    void *              tempHolder;
    int                 id;

    if (pVolDesc == NULL)
        {
        errno = S_dosFsLib_INVALID_PARAMETER;
        return (ERROR);
        }

    if (numBlocks < 1)
        /* nothing to do */
        return (OK);

    /*
     * This next test ensures that all the blocks to be read are within the
     * volume's range.  The prvious code was ...
     *
     * if ((pVolDesc->nBlocks < startBlock) ||
     *     (pVolDesc->nBlocks < numBlocks + startBlock))
     *
     * That is, it is of the form 'if ((N < S) || (N < (X + S)))'.  That means
     * we can rewrite the statements as ...
     *          ((N - S) < 0)  || ((N - S) < X)
     *
     * Substituting T for (N - S) yeilds ...
     *          (T < 0) || (T < X)
     *
     * We know from the code above that 'X' or rather <numBlocks> is > 0.
     * Therefore the code above can be simplified to (T < X).
     */

    tmp = pVolDesc->nBlocks - startBlock;
    if (tmp < numBlocks)
        {
        errno = EINVAL;
        return (ERROR);
        }

    /*
     * Is one of the blocks to read already present in the tiny cache?
     * If so:
     * If we are reading only one block, then we read it from there.
     * else if reading several blocks and the tiny cache is dirty, then we
     * flush it, and then we read the whole thing.
     */

    if (semTake (pVolDesc->volMemSemId, WAIT_FOREVER) != OK)
        return (ERROR);

    pVolDesc->volMemAccess++ ;
    for (id = 0; id < VOL_MEM_NUM; id++)
        {
        tmp = pVolDesc->volMem[id].volMemBlkNo - startBlock;
        if ((unsigned long long)tmp < (unsigned long long) numBlocks)
            {
            if (numBlocks == 1)
                {
                /* copy into user buffer */

                bcopy (pVolDesc->volMem[id].volMemBase, buffer, pVolDesc->blockSize);
                pVolDesc->volMemHits++ ;

                /* we're done */

                semGive (pVolDesc->volMemSemId);
                return (OK);
                }
            else if (pVolDesc->volMem[id].volMemDirty != 0)
                {
                retVal = dosFsSingleBlkXfer (pVolDesc, pVolDesc->volMem[id].volMemBlkNo,
                                             pVolDesc->volMem[id].volMemBase, DOS_WRITE);
                if (retVal != OK)
                    {
                    semGive (pVolDesc->volMemSemId);
                    return (ERROR);
                    }
                pVolDesc->volMem[id].volMemDirty = 0;
                }
            }
        }

    /*
     * We can release the tiny cache lock here because we can
     * assume that the following blocks to read, belong to the
     * same file, and mutual exclusion to the file is achieved
     * by holding the file mutex.
     */

    semGive (pVolDesc->volMemSemId);

    /* get a bio */

    if ((pBio = dosFsBioGet (pVolDesc)) == NULL)
        {
        return (ERROR);
        }

    if (DOS_VOL_IS_NO_DMA (pVolDesc))
        {
        tempHolder = pBio->bio_data;
        pBio->bio_data = buffer;

        error = dosFsBlkXfer (pVolDesc, pBio, startBlock,
                                  (unsigned)(pVolDesc->blockSize * numBlocks), BIO_READ);
        if (error)
            {
            if (error != ERROR)
                errnoSet (error);
            retVal = ERROR;
            }

            pBio->bio_data = tempHolder;
        }
    else
        {
        for (blocksRead = 0, pDest = buffer; numBlocks > 0;
             numBlocks -= blocksToRead)
            {
            blocksToRead = (UINT)min (dosFsVolumeBioBufferSize, numBlocks);
            bytesToRead = pVolDesc->blockSize * blocksToRead;

            /* read the block */

            error = dosFsBlkXfer (pVolDesc, pBio, startBlock + blocksRead,
                                  bytesToRead, BIO_READ);
            if (error)
                {
                if (error != ERROR)
                    errnoSet (error);
                retVal = ERROR;
                break;
                }

                /* copy into user buffer */
            bcopy (pBio->bio_data, pDest, bytesToRead);
            pDest = pDest + bytesToRead;

            blocksRead += blocksToRead;
            }
        }

    /* release bio */

    dosFsBioRelease (pVolDesc, pBio);

    return (retVal);
    }


/*******************************************************************************
*
* dosFsXbdBlkWrite - write blocks to the underlying XBD block device.
*
*
* RETURNS: STATUS.
*
* /NOMANUAL
*/

STATUS dosFsXbdBlkWrite
    (
    DOS_VOLUME_DESC *   pVolDesc,   /* volume descriptor */
    sector_t            startBlock, /* starting block of write */
    sector_t            numBlocks,  /* number of blocks to write */
    addr_t              buffer,     /* address of the memory buffer */
    DOS_RW              operation   /* DOS_WRITE/DOS_WRITE_THROUGH */
    )
    {
    struct bio *        pBio;
    unsigned            blocksWritten;
    char *              pDest;
    UINT                blocksToWrite;
    UINT                bytesToWrite;
    int                 error;
    int                 retVal = OK;
    sector_t            tmp;
    void *              tempHolder;
    int                 id;

    if (pVolDesc == NULL)
        {
        errno = S_dosFsLib_INVALID_PARAMETER;
        return (ERROR);
        }

    if (numBlocks < 1)
        /* nothing to do */
        return (OK);

    /*
     * This next test ensures that all the blocks to be read are within the
     * volume's range.
     */

    tmp = (pVolDesc->nBlocks - startBlock);
    if (tmp < numBlocks)
        {
        errno = EINVAL;
        return (ERROR);
        }

    /*
     * The following code checks for one of the blocks to be written to be
     * already cached in the tiny cache. This can happen if a write at the
     * byte level has been done, but has not been commited to disk yet.
     */

    /* mutual exclusion to access the local block buffer */

    if (semTake (pVolDesc->volMemSemId, WAIT_FOREVER) != OK)
        return (ERROR);

    pVolDesc->volMemAccess++;
    for (id = 0; id < VOL_MEM_NUM; id++)
        {

        /* see if Tiny Cache contains a valid block */

        if ((pVolDesc->volMem[id].volMemBase != NULL) &&
            (pVolDesc->volMem[id].volMemBlkNo != (sector_t) NONE))
            {

            /* see if the range touches the cached block. If so, invalidate it. */

            tmp = pVolDesc->volMem[id].volMemBlkNo - startBlock;
            if ((unsigned long long) tmp < (unsigned long long) numBlocks)
                {
                pVolDesc->volMem[id].volMemBlkNo = (sector_t) NONE;
                pVolDesc->volMem[id].volMemDirty = 0;
                }
            }
        }

    /*
     * We can release the tiny cache lock here because exclusive access
     * to the file is granted trough the file lock (dosFsFSemTake).
     * We are not accessing the FAT or a directory entry. Those accesses are
     * done trough the tiny cache or the disk cache.
     */

    semGive (pVolDesc->volMemSemId);

    /* get a bio */

    if ((pBio = dosFsBioGet (pVolDesc)) == NULL)
        {
        return (ERROR);
        }

    if (DOS_VOL_IS_NO_DMA (pVolDesc))
        {
        tempHolder = pBio->bio_data;
        pBio->bio_data = buffer;
        error = dosFsBlkXfer (pVolDesc, pBio, startBlock,
                              (unsigned)(pVolDesc->blockSize * numBlocks), BIO_WRITE);

        pBio->bio_data = tempHolder;

        if (error)
            {
            if (error != ERROR)
                errnoSet (error);
            retVal = ERROR;
            }
        }
    else
        {
        for (blocksWritten = 0, pDest = buffer; numBlocks > 0;
             numBlocks -= blocksToWrite)
            {
            blocksToWrite = (UINT)min (dosFsVolumeBioBufferSize, numBlocks);
            bytesToWrite = pVolDesc->blockSize * blocksToWrite;

            /* copy data to be written */

            bcopy (pDest, pBio->bio_data, bytesToWrite);

            /* write the block */

            error = dosFsBlkXfer (pVolDesc, pBio, startBlock + blocksWritten,
                                      bytesToWrite, BIO_WRITE);
            if (error)
                {
                if (error != ERROR)
                    errnoSet (error);
                retVal = ERROR;
                break;
                }

            blocksWritten += blocksToWrite;
            pDest = pDest + bytesToWrite;
            }
        }

    /* release bio */

    dosFsBioRelease (pVolDesc, pBio);

    if (retVal == OK)
        {
        if (operation == DOS_WRITE_THROUGH)
            {
            /* - completely ignore any failure during the FIOSYNC
             * (SPR 13774) */
            int saverr = errno;
            error = xbdIoctl (pVolDesc->device, XBD_SYNC, 0);
            if ((error != ENOTSUP) && (error != OK))
                {
                errnoSet(error);
                return(ERROR);
                }
            errno = saverr;
            }
        }

    return (retVal);
    }

/*******************************************************************************
*
* dosFsSingleBlkXfer - transfer a single block to/from underlying XBD device.
*
* This routine reads or writes a single block from the underlying XBD block
* device. This routine is intended to be used by dosFsXbdBytesRW(), in the
* sense that it is optimized for single block transfers and to assume no need
* to examine the tiny cache for a block match.
*
* RETURNS: STATUS.
*
* /NOMANUAL
*/

LOCAL STATUS dosFsSingleBlkXfer
    (
    DOS_VOLUME_DESC *   pVolDesc,   /* volume descriptor */
    sector_t            block,      /* starting block of write */
    addr_t              buffer,     /* address of the memory buffer */
    DOS_RW              operation   /* DOS_WRITE/DOS_WRITE_THROUGH/DOS_READ */
    )
    {
    struct bio *        pBio;
    int                 error;
    int                 retVal = OK;
    void *              tempHolder;


    /* get a bio */

    if ((pBio = dosFsBioGet (pVolDesc)) == NULL)
        {
        return (ERROR);
        }

    tempHolder = pBio->bio_data;

    if (operation == DOS_WRITE || operation == DOS_WRITE_THROUGH)
        {
        /* copy data to be written */

            if (DOS_VOL_IS_NO_DMA (pVolDesc))
                pBio->bio_data = buffer;
            else
                bcopy (buffer, pBio->bio_data, pVolDesc->blockSize);

        /* write the block */

        error = dosFsBlkXfer (pVolDesc, pBio, block, pVolDesc->blockSize,
                              BIO_WRITE);

        if (error)
            {
            if (error != ERROR)
                errnoSet (error);
            retVal = ERROR;
            }
        }

    else /* DOS_READ */
        {
        /* read the block */

        if (DOS_VOL_IS_NO_DMA (pVolDesc))
            pBio->bio_data = buffer;

        error = dosFsBlkXfer (pVolDesc, pBio, block, pVolDesc->blockSize,
                              BIO_READ);

        if (error)
            {
            if (error != ERROR)
                errnoSet (error);
            retVal = ERROR;
            }

        /* copy into user buffer */

        if (!DOS_VOL_IS_NO_DMA (pVolDesc))
            bcopy (pBio->bio_data, buffer, pVolDesc->blockSize);
        }

    /* release bio */

    pBio->bio_data = tempHolder;

    dosFsBioRelease (pVolDesc, pBio);

    if (retVal == OK)
        {
        if (operation == DOS_WRITE_THROUGH)
            {
            /* - completely ignore any failure during the FIOSYNC
                 * (SPR 13774) */
            int saverr = errno;
            (void)xbdIoctl (pVolDesc->device, XBD_SYNC, 0);
            errno = saverr;
            }
        }

    return (retVal);
    }


/*******************************************************************************
*
* dosFsXbdBytesRW - read/write bytes to/from the underlying XBD block device.
*
*
* RETURNS: STATUS.
*
* /NOMANUAL
*/

STATUS dosFsXbdBytesRW
    (
    DOS_VOLUME_DESC *   pVolDesc,   /* volume descriptor */
    sector_t            startBlock, /* starting block of the transfer */
    off_t               offset,     /* offset into block in bytes */
    addr_t              buffer,     /* address of data buffer */
    size_t              nBytes,     /* number of bytes to transfer */
    u_int               operation   /* DOS_READ/DOS_WRITE/WRITE_THROUGH */
    )
    {
    STATUS              stat = ERROR;
    caddr_t             pStart;
    int                 id;
    int                 cHit = 0;
    int                 s_Id = -1; /* cache id which blocks hits in or to fill in*/


    if ((operation != DOS_READ) && (operation != DOS_WRITE) &&
        (operation != DOS_WRITE_THROUGH))
        /* bail out */
        return (ERROR);

    if (pVolDesc == NULL)
        {
        errno = S_dosFsLib_INVALID_PARAMETER;
        return (ERROR);
        }

    if (startBlock >= pVolDesc->nBlocks)
        {
        errno = EINVAL;
        return (ERROR);
        }
    /* verify that all bytes are within one block range */

    if (((offset + nBytes) >  pVolDesc->blockSize) || (offset < 0) ||
        (nBytes <= 0))
        {
        errno = EINVAL;
        return (ERROR);
        }
    /* mutual exclusion to access the local block buffer */

    if (semTake (pVolDesc->volMemSemId, WAIT_FOREVER) != OK)
        return (ERROR);

    for (id = 0; id < VOL_MEM_NUM; id++)
        {

        /* verify that there is a block buffer */

        if (pVolDesc->volMem[id].volMemBase == NULL)
            {
            semGive (pVolDesc->volMemSemId);
            return (ERROR);
            }
        }

    if ((pVolDesc->volMemLastHit != -1) &&
        (pVolDesc->volMem[pVolDesc->volMemLastHit].volMemBlkNo == startBlock))
        {
        cHit = 1;
        s_Id = pVolDesc->volMemLastHit;
        }
    else
        {

        /*block hits in the tiny cache?*/

        for (id = 0; id < VOL_MEM_NUM; id ++)
            if (pVolDesc->volMem[id].volMemBlkNo == startBlock)
                {
                cHit = 1;
                s_Id = id;
                break;
                }
        }

    /*if not hit, select an empty or cold cacheline to replace*/

    if (cHit == 0)
        {
        for (id = 0; id < VOL_MEM_NUM; id++)
            {
            if (pVolDesc->volMem[id].volMemBlkNo == (sector_t) NONE)
                {
                s_Id = id;
                break;
                }
            }

        if (s_Id == -1)
            s_Id = (pVolDesc->volMemLastHit + 1) % VOL_MEM_NUM;

        /* flush the current contents of the block buffer if needed */

        if ((pVolDesc->volMem[s_Id].volMemBlkNo != (sector_t) NONE) &&
            (pVolDesc->volMem[s_Id].volMemDirty != 0))
            {
            sector_t cachedBlock = pVolDesc->volMem[s_Id].volMemBlkNo;

            pVolDesc->volMem[s_Id].volMemBlkNo = (sector_t) NONE;
            pVolDesc->volMem[s_Id].volMemDirty = 0;
            stat = dosFsSingleBlkXfer (pVolDesc, cachedBlock, pVolDesc->volMem[s_Id].volMemBase,
                                       DOS_WRITE);

            if (stat == ERROR)
                {
                semGive (pVolDesc->volMemSemId);
                return (ERROR);
                }
            }

        /* read the requested block into the tiny cache if appropriate */

        if (pVolDesc->volMem[s_Id].volMemDirty == 0)
            {
            if ((operation == DOS_READ) || (nBytes != pVolDesc->blockSize))
                {
                stat = dosFsSingleBlkXfer (pVolDesc, startBlock,
                                           pVolDesc->volMem[s_Id].volMemBase, DOS_READ);
                if (stat == ERROR)
                    {
                    semGive (pVolDesc->volMemSemId);
                    return (ERROR);
                    }
                }

            pVolDesc->volMem[s_Id].volMemBlkNo = startBlock ;
            pVolDesc->volMem[s_Id].volMemDirty = 0;
            }
        }
    else
        pVolDesc->volMemHits ++ ;

    pVolDesc->volMemAccess ++;

    assert (startBlock == pVolDesc->volMem[s_Id].volMemBlkNo);

    /* calculate actual memory address of data */

    pStart = pVolDesc->volMem[s_Id].volMemBase + offset;

    switch (operation)
        {
        case DOS_READ:
            bcopy (pStart, buffer, nBytes);
            break;

        case DOS_WRITE:
            bcopy (buffer, pStart, nBytes);
            pVolDesc->volMem[s_Id].volMemDirty = 1;
            break;

        case DOS_WRITE_THROUGH:
            bcopy (buffer, pStart, nBytes);
            stat = dosFsSingleBlkXfer (pVolDesc, startBlock,
                               pVolDesc->volMem[s_Id].volMemBase, DOS_WRITE_THROUGH);

            if (stat == ERROR)
                {
                semGive(pVolDesc->volMemSemId);
                return ERROR;
                }
            else
                {
                pVolDesc->volMem[s_Id].volMemBlkNo = startBlock;
                pVolDesc->volMem[s_Id].volMemDirty = 0;
                }
            break;

        }

    pVolDesc->volMemLastHit = s_Id;

    semGive(pVolDesc->volMemSemId);
    return (OK);
    }


/*******************************************************************************
*
* dosFsVolBufCreate - create the local block buffer
*
* /NOMANUAL
*/

LOCAL STATUS dosFsVolBufCreate
    (
    DOS_VOLUME_DESC *   pVolDesc
    )
    {
    unsigned            blockSize;
    int                 i;

    /* get block size */

    if (xbdBlockSize (pVolDesc->device, &blockSize) != OK)
        /* bail out */
        return (ERROR);

    for (i = 0; i < VOL_MEM_NUM; i++)
        {

        /* it has already been checked that volMemBase is NULL */

        pVolDesc->volMem[i].volMemBase = KHEAP_ALLOC (blockSize);

        if (pVolDesc->volMem[i].volMemBase == NULL)
            {
            goto alloc_err;
            }

        /* empty block */

        pVolDesc->volMem[i].volMemBlkNo = (sector_t) NONE;
        pVolDesc->volMem[i].volMemSize = (size_t) blockSize;
        pVolDesc->volMem[i].volMemDirty = 0;
        }
    return (OK);
alloc_err:
    for (i = 0; i < VOL_MEM_NUM; i++)
        {
        if (pVolDesc->volMem[i].volMemBase != NULL)
            KHEAP_FREE (pVolDesc->volMem[i].volMemBase);
        }
    return (ERROR);
    }

/*******************************************************************************
*
* dosFsXbdBlkCopy - copy blocks on the underlying XBD block device.
*
*
* RETURNS: STATUS.
*
* /NOMANUAL
*/

STATUS dosFsXbdBlkCopy
    (
    DOS_VOLUME_DESC *   pVolDesc,   /* volume descriptor */
    sector_t            srcBlock,
    sector_t            dstBlock,
    sector_t            numBlocks
    )
    {
    struct bio *        pBio;
    unsigned            blocksCopied;
    UINT                blocksToCopy;
    UINT                bytesToCopy;
    int                 error;
    STATUS              retVal = OK;
    sector_t            tmp;
    int                 id;

    if (numBlocks < 1)
        /* nothing to do */
        return (OK);

    tmp = pVolDesc->nBlocks - numBlocks;
    if ((tmp < 0) || (srcBlock > tmp) || (dstBlock > tmp))
        {
        errno = EINVAL;
        return ERROR;
        }

    /* mutual exclusion to access tiny cache */

    if (semTake (pVolDesc->volMemSemId, WAIT_FOREVER) != OK)
        return (ERROR);

    /* see if Tiny Cache contains a block within range */

    for (id = 0; id < VOL_MEM_NUM; id++)
        {
        if ((pVolDesc->volMem[id].volMemBase != NULL) &&
            (pVolDesc->volMem[id].volMemBlkNo != (sector_t) NONE))
            {

            /* see if source range touches the cached block */

            if (((unsigned long long) (pVolDesc->volMem[id].volMemBlkNo - srcBlock) <
                (unsigned long long) numBlocks) &&
                (pVolDesc->volMem[id].volMemDirty != 0))
                {

                /* need to flush the tiny cache prior to the copy operation */

                retVal = dosFsSingleBlkXfer (pVolDesc, pVolDesc->volMem[id].volMemBlkNo,
                                pVolDesc->volMem[id].volMemBase, DOS_WRITE);
                if (retVal == ERROR)
                    {
                    semGive (pVolDesc->volMemSemId);
                    return (ERROR);
                    }

                pVolDesc->volMem[id].volMemDirty = 0;
                }

                /* else, tiny cache may be within the destination range */

            else if ((unsigned long long) (pVolDesc->volMem[id].volMemBlkNo - dstBlock) <
                    (unsigned long long) numBlocks)
                {

                /* In this case, we simply invalidate the tiny cache */

                pVolDesc->volMem[id].volMemBlkNo = (sector_t) NONE;
                pVolDesc->volMem[id].volMemDirty = 0;
                }
            }
        }

    /* get a bio */

    if ((pBio = dosFsBioGet (pVolDesc)) == NULL)
        {
        semGive (pVolDesc->volMemSemId);
        return (ERROR);
        }

    for (blocksCopied = 0; numBlocks > 0; numBlocks -= blocksToCopy)
        {
        blocksToCopy = (UINT)min (dosFsVolumeBioBufferSize, numBlocks);
        bytesToCopy = pVolDesc->blockSize * blocksToCopy;

        /* read the block(s) */

        error = dosFsBlkXfer (pVolDesc, pBio, srcBlock + blocksCopied,
                              bytesToCopy, BIO_READ);
        if (error)
            {
            if (error != ERROR)
                errnoSet (error);
            retVal = ERROR;
            break;
            }

        /* Write the block(s) */

        error = dosFsBlkXfer (pVolDesc, pBio, dstBlock + blocksCopied,
                              bytesToCopy, BIO_WRITE);
        if (error)
            {
            if (error != ERROR)
                errnoSet (error);
            retVal = ERROR;
            break;
            }

        blocksCopied += blocksToCopy;
        }

    semGive (pVolDesc->volMemSemId);

    /* release bio */

    dosFsBioRelease (pVolDesc, pBio);

    return (retVal);
    }

/*******************************************************************************
*
* dosFsXbdDiscard - mark sectors as discarded (helper for dosFsXbdIoctl)
*
* RETURNS: OK or errno.
*
* NOMANUAL
*/
LOCAL int dosFsXbdDiscard
    (
    DOS_VOLUME_DESC *   pVolDesc,
    SECTOR_RANGE *      range
    )
    {
    sector_t            blockNum;
    int                 retVal;
    int                 id;

    blockNum = range->startSector;
    /*
     * Invalidate this block in tiny cache in case
     * it happens to be there (don't care whether it
     * is dirty or not).
     */
    for (id = 0; id < VOL_MEM_NUM; id++)
        if ((pVolDesc->volMem[id].volMemBase != NULL) &&
            (pVolDesc->volMem[id].volMemBlkNo >= blockNum) &&
            (pVolDesc->volMem[id].volMemBlkNo < blockNum + range->nSectors))
        {
        pVolDesc->volMem[id].volMemBlkNo = (sector_t) NONE;
        pVolDesc->volMem[id].volMemDirty = 0;
        }

    retVal = dosFsDicard(pVolDesc, range, FALSE);

    return (retVal);
    }

/*******************************************************************************
*
* dosFsXbdIoctl - Misc control operations
*
* This performs the requested old CBIO ioctl() operations.
*
* RETURNS OK or ERROR and may otherwise set errno.
*
* /NOMANUAL
*/

STATUS dosFsXbdIoctl
    (
    DOS_VOLUME_DESC *   pVolDesc,
    UINT32              command,
    addr_t              arg
    )
    {
    STATUS              retVal = OK;
    int                 id;

    switch (command)
        {
        case FIODISCARD:
        case FIOCOMMITFS:
        case CBIO_CACHE_FLUSH:
        case CBIO_CACHE_INVAL:
        case CBIO_CACHE_NEWBLK:

            if (semTake (pVolDesc->volMemSemId, WAIT_FOREVER) == ERROR)
                return (ERROR);
        }

    switch (command)
        {
        case FIODISCARD:
            retVal = dosFsXbdDiscard (pVolDesc, (SECTOR_RANGE *) arg);
            if (retVal != OK && retVal != ENOTSUP)
                {
                errnoSet (retVal);
                retVal = ERROR;
                }
            else
                {
                retVal = OK;
                }
            break;

        case FIOCOMMITFS:
        case CBIO_CACHE_FLUSH:
            {
                /*
                 * Flush out tiny cache, if necessary.
                 * For dosFsSingleBlkXfer(), DOS_WRITE means write into media, but
                 * do not issue an xbdIoctl(..., FIOSYNC).
                 */

            for (id = 0; id < VOL_MEM_NUM; id ++)
                if ((pVolDesc->volMem[id].volMemBase != NULL) &&
                    (pVolDesc->volMem[id].volMemBlkNo != (sector_t) NONE) &&
                    (pVolDesc->volMem[id].volMemDirty != (sector_t) 0))
                    {
                    retVal = dosFsSingleBlkXfer (pVolDesc, pVolDesc->volMem[id].volMemBlkNo,
                                                 pVolDesc->volMem[id].volMemBase, DOS_WRITE);
                    if (retVal == OK)
                        {
                        pVolDesc->volMem[id].volMemDirty = 0;
                        }
                    }

            /* funnel the call if FIOCOMMITFS */

            if (command == FIOCOMMITFS)
                {
                retVal = xbdIoctl (pVolDesc->device, command, arg);
                if (retVal != OK && retVal != ENOTSUP)
                    {
                    errnoSet (retVal);
                    retVal = ERROR;
                    }
                else
                    {
                    retVal = OK;
                    }
                }
            }
            break;

        case CBIO_CACHE_INVAL:
            for (id = 0 ; id < VOL_MEM_NUM; id++)
                {
                /* flush out tiny cache, if necessary */

                if ((pVolDesc->volMem[id].volMemBase != NULL) &&
                    (pVolDesc->volMem[id].volMemBlkNo != (sector_t) NONE) &&
                    (pVolDesc->volMem[id].volMemDirty != (sector_t) 0))
                    {
                    sector_t cachedBlock = pVolDesc->volMem[id].volMemBlkNo;

                    retVal = dosFsSingleBlkXfer (pVolDesc, cachedBlock,
                                                 pVolDesc->volMem[id].volMemBase,
                                                 DOS_WRITE);
                    if (retVal == ERROR)
                        break;
                    } /* what if volMemBase is NULL ?*/

                pVolDesc->volMem[id].volMemBlkNo = (sector_t) NONE;
                pVolDesc->volMem[id].volMemDirty = 0;
                }
            break;

        case CBIO_CACHE_NEWBLK:
            {
            int s_Id;

            s_Id = (pVolDesc->volMemLastHit + 1) % VOL_MEM_NUM;

            /* flush out tiny cache, if necessary */

            if ((pVolDesc->volMem[s_Id].volMemBase != NULL) &&
                (pVolDesc->volMem[s_Id].volMemBlkNo != (sector_t) NONE) &&
                (pVolDesc->volMem[s_Id].volMemDirty != (sector_t) 0))
                {
                sector_t cachedBlock = pVolDesc->volMem[s_Id].volMemBlkNo;

                retVal = dosFsSingleBlkXfer (pVolDesc, cachedBlock,
                                             pVolDesc->volMem[s_Id].volMemBase,
                                             DOS_WRITE);
                if (retVal == ERROR)
                    break;
                } /* what if volMemBase is NULL ?*/

            if (pVolDesc->volMem[s_Id].volMemBase != NULL)
                {
                bzero (pVolDesc->volMem[s_Id].volMemBase, pVolDesc->volMem[s_Id].volMemSize);
                pVolDesc->volMem[s_Id].volMemBlkNo = (sector_t) ((long) arg);
                pVolDesc->volMem[s_Id].volMemDirty = 1;
                }

            break;
            }

        default:
            {
            int error;

            /* Call device driver function */

            error = xbdIoctl (pVolDesc->device, command, (void *) arg);
            if (error)
                {
                errnoSet (error);
                retVal = ERROR;
                }
            return (retVal);
            }
        }

    semGive (pVolDesc->volMemSemId);
    return retVal;
    }

int dosFsDicard
    (
    DOS_VOLUME_DESC *   pVolDesc,
    SECTOR_RANGE *      range,
    BOOL                flush
    )
    {
    int retVal = OK;
#ifdef DOSFS_MERGE_DISCARD
    int retTemp;

    if (pVolDesc == NULL || pVolDesc->doSecDiscard == FALSE)
        return OK;

    if (range != NULL)
        {
        if (pVolDesc->rangeDiscard.nSectors == 0)
            {
            if (range->nSectors > 0)
                {
                pVolDesc->rangeDiscard.nSectors = range->nSectors;
                pVolDesc->rangeDiscard.startSector = range->startSector;
                }
            }
        else
            {
            if (range->nSectors > 0)
                {
                if (pVolDesc->rangeDiscard.startSector + pVolDesc->rangeDiscard.nSectors
                    == range->startSector)
                    {
                    pVolDesc->rangeDiscard.nSectors += range->nSectors;
                    }
                else
                    {
                    retVal = xbdIoctl (pVolDesc->device, FIODISCARD, &pVolDesc->rangeDiscard);
                    if (retVal == ENOTSUP)
                        retVal = OK;

                    pVolDesc->rangeDiscard.nSectors = range->nSectors;
                    pVolDesc->rangeDiscard.startSector = range->startSector;
                    }
                }
            }
        }
    if (pVolDesc->rangeDiscard.nSectors > 0 && flush == TRUE)
        {
        retTemp = xbdIoctl (pVolDesc->device, FIODISCARD, &pVolDesc->rangeDiscard);
        if (retTemp == ENOTSUP)
            retTemp = OK;

        if (retVal == OK && retTemp != OK)
            retVal = retTemp;

        pVolDesc->rangeDiscard.nSectors = 0;
        }
#else
    if (range == NULL)
        return OK;

    if (pVolDesc->doSecDiscard)
        {
        retVal = xbdIoctl (pVolDesc->device, FIODISCARD, range);
        if (retVal == ENOTSUP)
            retVal = OK;
        }
    else
        retVal = OK;
#endif
    return retVal;
    }

/* following code until End Of File is unused except for unitesting */
#ifdef  __unitest__

#include <private/print64Lib.h>

#ifdef DEBUG

STATUS dosSecPut
    (
    void * pDev,
    u_int sec,
    u_int off,
    u_int nBytes,
    char * buf
    )
    {
    DOS_VOLUME_DESC_ID  pVolDesc = dosFsVolDescGet (pDev, NULL);

    if (pVolDesc == NULL)
        {
        PRINT_MSG (CLSMSG_NORMAL,"pDev Not device \n");
        return ERROR;
        }

    if (buf == NULL)
        {
        PRINT_MSG (CLSMSG_NORMAL,"NULL buffer\n");
        return ERROR;
        }

    if (sec >= pVolDesc->nBlocks)
        {
        PRINT_MSG (CLSMSG_NORMAL,"sec = %u >= nBlocks = %u\n",
            sec, (u_int)pVolDesc->nBlocks);
        return ERROR;
        }

    if (off + nBytes > pVolDesc->blockSize)
        {
        PRINT_MSG (CLSMSG_NORMAL,"off + nBytes = %u > bytesPerBlk = %u\n",
            off + nBytes, pVolDesc->blockSize);
        return ERROR;
        }

    if (dosFsXbdBytesRW (pVolDesc, sec, off, buf, nBytes, DOS_WRITE) == ERROR)
        {
        PRINT_MSG (CLSMSG_NORMAL,"Error write sector, errno = %p\n", (void *)errno);
        return ERROR;
        }

    return OK;
    } /* dosSecPut() */

STATUS dosSecGet
    (
    void * pDev,
    u_int sec,
    u_int off,
    u_int nBytes,
    char * buf
    )
    {
    IMPORT d();
    DOS_VOLUME_DESC_ID  pVolDesc = dosFsVolDescGet(pDev, NULL);
    static void * pBuf = NULL;

    if (pVolDesc == NULL)
        {
        PRINT_MSG (CLSMSG_NORMAL,"pDev Not a device \n");
        return ERROR;
        }

    if (buf == NULL)
        {
        if (pBuf == NULL)
            {
            pBuf = KHEAP_ALIGNED_ALLOC (pVolDesc->blockSize, 16);
            if (pBuf == NULL)
                return ERROR;
            }
        buf = pBuf;
        }

    if (sec >= pVolDesc->nBlocks)
        {
        PRINT_MSG (CLSMSG_NORMAL,"sec = %u >= nBlocks = %u\n", sec, (u_int)pVolDesc->nBlocks);
        return ERROR;
        }

    if (off + nBytes > pVolDesc->blockSize)
        {
        PRINT_MSG (CLSMSG_NORMAL,"off + nBytes = %u > bytesPerBlk = %u\n",
               off + nBytes, pVolDesc->blockSize);
        return ERROR;
        }

    if (dosFsXbdBytesRW (pVolDesc, sec, off, buf, nBytes, DOS_READ) == ERROR)
        {
        PRINT_MSG (CLSMSG_NORMAL,"Error read sector, errno = %p\n", (void *)errno);
        return ERROR;
        }

    if (buf == pBuf)
        d (buf, nBytes, 1);

    return OK;
    } /* dosSecGet() */

#ifdef SIZE64
int test64(int val)
    {
    fsize_t     val64 = val;

    print64Fine("val = ", val64, "\n", 16);
    val64 = (val64 << 32) | val;
    print64Fine("val<<32 | val = ", val64, "\n", 16);
    val64 >>= 32;
    print64Fine("val >> 32= ", val64, "\n", 16);
    return val;
    }
#endif /* SIZE64 */

#endif /* DEBUG */
#endif  /*__unitest__*/

/* End of File */

