
# wccLib.tcl - wind "component configuration" management library
#
# Copyright 1998-2007 Wind River Systems, Inc.

# The right to copy, distribute, modify, or otherwise make use
# of this software may be licensed only pursuant to the terms
# of an applicable Wind River license agreement.

#
# modification history
# --------------------
# 02e,14nov08,pee  WIND00143715
# 02d,23oct08,pee  changes to cdf path
# 02d,24oct08,mze  adding check for VSB when adding components
# 02c,10oct08,mze  change to VXBUILD
# 02c,01oct08,pee  WIND00135548
# 02b,01may07,pee  validation problem with Api
# 03a,23apr07,pee  added support for build options
# 02z,02dec06,zhr  Improved component root user cdfinfo and trace path support
# 02y,22nov06,pee  requirement WIND00067800. add version path for windComponents
#     13nov06,pee  requirement WIND00067802. add arch path for windComponents
# 02x,31jul06,zhr  WIND00022923 "component check all" reports wrong errors
# 02w,17apr06,pee  WIND00022804
# 02v,07mar06,zhr  SPR#118621: unresolved component and other CDF issues
# 02u,27feb06,zhr  removed duplicated error report message
# 02t,10feb06,zhr  Added enhanced component check
# 02s,18jan06,pee  improved handling of ARCHIVE
# 02r,02jan06,pee  reverted mod 02p for SPR#114351
# 02q,05dec05,pee  new component handling strategy
# 02p,25oct05,zhr  SPR#114351:  crash by recursively calling wccParamValueEval
# 02o,05apr05,pee  SPR#107367 : parsing of conditional parameters (::)
# 02n,22oct04,fle  SPR#102787 : fixed list of auto removed comps
# 02m,21oct04,fle  SPR#102787 : do a validation when adding components
# 02l,07oct04,fle  Fixed wccBackup
# 02k,13aug04,fle  made mxrDocCreate also look into libraries defined through
#                  ARCHIVE
# 02j,14jul04,fle  Added extended mode to wccDependsGet
# 02i,06may04,fle  Removed all bullet lists refgen markups
# 02h,14apr04,fle  Added wrn/coreip dir to header dirs
# 02g,09apr04,fle  SPR#94279 : Made it possible to use environment variables /
#                  macros to specify path to a configlette
# 02f,30mar04,fle  Fixed doc
# 02e,10mar04,fle  SPR#94125 : default value should be trimmed
# 02d,09mar04,fle  Made wccParamGet check for conditionalised parameter values
# 02c,02mar04,fle  Enhanced a bit doc
# 02b,16feb04,fle  Use package require mechanism to load datadocs libraries
#                  + make it use PrjUtils::relPath rather than prjRelPath
# 02a,01dec03,fle  SPR#91478 : LINK_SYMS names should not be stuck all
#                  together
# 01z,12nov03,fle  Added the possibility to get dependencies for just one
#                  component in wccDependsGet
# 01y,04sep03,fle  enhanced doc
# 01x,19jun03,fle  Updated to new location
# 01w,18jun03,pch  Support CPU_VARIANT conditionals in .cdf files
# 01v,03may02,cjs  fix spr 76601 -- problems w/ using component archive in
#                  bootable project
# 01u,08nov01,j_s  library names passed to mxrLibsContract should be in
#                  relative form
# 01u,06nov01,rbl  allow tool-dependent cdf paths
# 01t,02nov01,j_s  Added mxrLibsSearch to derive libraries from LD_LINK_PATH
#                  and LIBS; adapt mxrDocCreate to use both LIBS and MXR_LIBS
# 01s,03oct01,dat  Adding BSP_STUBS, SPR 69150
# 01r,01apr99,cjs  Comment out prjStatusLog() calls
# 01q,19feb99,ren Added handling of a parameter with no value
# 01p,10nov98,ms  updated for LINK_DATASYMS.
# 01o,26oct98,ms  removed useless wccHelpUrlsGet. Changed puts to prjStatusLog.
# 01n,25sep98,ms  library routines can now be added to a config via wccProc*
# 01m,15sep98,ms  beefed up cxrDocValidate (the .cdf file test routine).
# 01l,09sep98,cjs added wccErrorStatusSet/Get routines
# 01k,26aug98,ms  respect ARCHIVE attribute of components.
#		  updated cxrValidate.
# 01j,18aug98,ms  wccLoad fixes; when initializaing symTbl, use wtxDirectCall
#		  instead of slower wtxFuncCall. Use LD_PARTIAL_FLAGS instead
#	 	  of assuming "-r" (makes SIMSOLARIS work).
# 01j,11aug98,ms  fixed bugs in wccLoad.
# 01i,07aug98,ms  fixed bug in wccParamGet.
# 01h,06aug98,ms  added wccComponentLoad.
# 01h,31jul98,ms  check for components with missing parameters in wccValidate
# 01g,27jul98,ms  added wccMxrLibs[GS]et. [mc]xrDocCreate mods to log
#		  progress, and call [mc]xrDataDocCreate with new args.
#		  removed useless wccComponent*Info routines.
# 01g,14jul98,ms  added type checking in wccParamGet, ran through dos2unix,
#		  [cm]xrDocDelete now callout to dataDocLib procs.
#		  moved cxrConfigAllDiff cmpTestLib.tcl.
# 01f,07jul98,ms  cxrDocDelete and mxrDocDelete check if document exists
# 01e,29jun98,ms  added wccComponentChangeInfo
# 01d,25jun98,ms  fixed mxrDocCreate problem introduced by new build
# 01d,09jun98,ms  implemented the stubed wccParam* functions.
# 01c,24apr98,ms  added a bunch of component checking routines
# 01b,21apr98,ms  added wccCdfPath[Get&Set]
# 01a,19mar98,ms  written.
#
# DESCRIPTION
# This library manages vxWorks compononent configurations within
# a project. Component configrations consist of:
# \is
# \i A reference to a component library
# \i A selection of INCLUDE_* options from that library
# \i A selection of routines within the vxWorks archive that should
#      be included (even if the routine is not part of a component
# \i A set of overrides for some of the component configuration
#      parameters (e.g., NUM_FDS is a parameter for component INCLUDE_IO_SYSTEM)
# \ie
#
# This library supports multiple component configurations within
# a single project. One of which is the default configuration.
#
# Each component configuration has a name (e.g., DEFAULT), and its
# information is stored in the project under tags
#	WCC_<name>_COMPONENTS
#	WCC_<name>_ROUTINES
#	WCC_<name>_PARAMS
# Global information about all wcc's are stored under tags:
#	WCC__LIST
#	WCC__CURRENT
#	WCC__CDF_PATH
#
# PACKAGE REQUIRED:
# \is
# \i DataDocs
# \i PrjUtils
# \i Wind
# \i Wtx (only if 'wccComponentLoad' is used)
# \ie

package require DataDocs
package require PrjUtils
package require Wind

global g_wccParamNoValue
global g_modUsers
set g_wccParamNoValue "<no value>"



################################################################################
#
# wccListGet - get a list of wcc's in the project
#
# SYNOPSIS
# \cs
#   wccListGet <hProj>
# \ce
#
# DESCRIPTION
# Get a list of Wind Components Configurations in the given project
#
# PARAMETERS
#   hProj : handle of the project to get wcc list for
#
# RETURNS: A list of wccs
#

proc wccListGet {hProj} {
    return [prjTagDataGet $hProj WCC__LIST]
}

################################################################################
#
# wccCdfPathSet - set the CDF search path
#
# SYNOPSIS
# \cs
#   wccCdfPathSet <hProj> <cdfPath>
# \ce
#
# DESCRIPTION
# Set the CDF search path
#
# PARAMETERS
#   hProj : project handle
#   cdfPath : cdf path. Use $(TOOL_FAMILY) variable where appropriate
#
# RETURNS: N/A
#
# ERRORS: N/A
#

proc wccCdfPathSet {hProj cdfPath} {
    prjTagDataSet $hProj WCC__CDF_PATH $cdfPath
}

################################################################################
#
# wccCdfPathGet - get the CDF search path
#
# SYNOPSIS
# \cs
#   wccCdfPathGet <hProj>
# \ce
#
# DESCRIPTION
# Get the CDF search path with $(TOOL_FAMILY) variable expanded
#
# PARAMETERS
#   hProj : project handle
#   toolchain : tool chain
#
# RETURNS: cdf path, with $(TOOL_FAMILY) variable expanded
#
# ERRORS: N/A
#

proc wccCdfPathGet {hProj} {

    global env

    set tc [prjBuildTcGet $hProj [prjBuildCurrentGet $hProj]]
    set family [${tc}::family]
    set cpu [${tc}::cpu]
    set archDir [PrjUtils::archDirFind $cpu]
    set version $env(WIND_PLATFORM)

    if {$env(WIND_HOST_TYPE) == "x86-win32"} {
        set separator ";"
    } else {
        set separator ":"
    }

    set cdfPath {}

    set vsbDir [prjTagDataGet $hProj VSB_DIR]
    set bspDir [prjTagDataGet $hProj BSP_DIR]
    set prjDir [file dirname [prjInfoGet $hProj fileName]]
    set wbase $env(WIND_BASE)

    set srcConfig [file join $wbase target config comps vxWorks]
    lappend cdfPath $srcConfig

    lappend cdfPath [file join $wbase target config comps vxWorks arch $archDir]
    lappend cdfPath [file join $wbase target config comps vxWorks tool $family]

    if {[info exists env(WIND_COMPONENTS)] && [info exists env(WIND_COMPONENTS_LIBNAMES)]} {
	set searchPath {}
	set windComponents    $env(WIND_COMPONENTS)
	set compatibleComps $env(WIND_COMPONENTS_LIBNAMES)
        set windCompRoots [split $windComponents $separator]
        set windCompSet [split $compatibleComps $separator]

	set windCompDirs {}
	foreach path $windCompRoots {
	    foreach comp $windCompSet {
	    set dirs [glob -nocomplain [file join $path $comp osconfig]]
	    set windCompDirs [concat $windCompDirs $dirs]
	    }
	}

	set windCompDirs [lsort $windCompDirs]

	foreach path $windCompDirs {
	    set dirs [glob -nocomplain [file join $path vxworks cdf]]
	    set searchPath [concat $searchPath $dirs]
	    if {$archDir != {} } {
		set dirs [glob -nocomplain [file join $path vxworks cdf arch $archDir]]
		set searchPath [concat $searchPath $dirs]
	    }
	    if {$version != {} } {
		set dirs [glob -nocomplain [file join $path $version cdf ]]
		set searchPath [concat $searchPath $dirs]
		if {$archDir != {}} {
		    set dirs [glob -nocomplain [file join $path $version cdf arch $archDir ]]
		    set searchPath [concat $searchPath $dirs]
		}
	    }
	}
	if {[info exists env(COMP_SUBCOMP_LIST)]} {
            set subCompsList $env(COMP_SUBCOMP_LIST)
	    set subCompsList [split $subCompsList $separator]
	    foreach sub $subCompsList {
	        if {[info exists env($sub)]} {
	            set subComps $env($sub)
                    set subComps [split $subComps $separator]
	            foreach path $windCompRoots {
                        foreach sComp  $subComps {
		            set dirs [glob -nocomplain [file join $path $sComp]]
		            set searchPath [concat $searchPath $dirs]
                        }
	            }
	        }
	    }
	}

	set cdfPath [concat $cdfPath $searchPath]
    }


    lappend cdfPath [file normalize $bspDir]

    if {[info exists env(WIND_USER_CDF_PATH)]} {
	set pl [split $env(WIND_USER_CDF_PATH) $separator]
	foreach p $pl {
	    lappend cdfPath $p
	    if {$archDir != {} } {
		lappend cdfPath [file join $p arch $archDir]
	    }
	}
    }

    lappend cdfPath [file normalize $prjDir]

    return $cdfPath

}

################################################################################
#
# wccMxrLibsSet - set the libraries that are used for module xref
#
# SYNOPSIS
# \cs
#   wccMxrLibsSet <hProj> <mxrLibs>
# \ce
#
# DESCRIPTION
# Set the libraries used for modules cross references operations
#
# PARAMETERS:
#   hProj : handle of the project to set Mxr libraries for
#   mxrLibs : libraries to be used for the module cross reference operations
#
# RETURNS: N/A
#
# ERRORS: N/A
#
# SEE ALSO: wccMxrLibsGet
#

proc wccMxrLibsSet {hProj mxrLibs} {
    regsub -all {[\{\}]} $mxrLibs "" mxrLibs
    prjTagDataSet $hProj WCC__MXR_LIBS $mxrLibs
}

################################################################################
#
# wccMxrLibsGet - get the libraries that are used for module xref
#
# SYNOPSIS
# \cs
#   wccMxrLibsGet <hProj>
# \ce
#
# DESCRIPTION
# Get yje libraries used for module cross reference operations
#
# PARAMETERS:
#   hProj : handle of the project to get Mxr libraries for
#
# RETURNS: A list of libraries used for module cross reference operations
#
# ERRORS: N/A
#
# SEE ALSO: wccMxrLibsSet
#

proc wccMxrLibsGet {hProj} {
    set retval [prjTagDataGet $hProj WCC__MXR_LIBS]
    regsub -all {[\{\}]} $retval "" retval
    return $retval
}

################################################################################
#
# wccCurrentGet - get the current build spec
#
# SYNOPSIS
# \cs
#   wccCurrentGet <hProj>
# \ce
#
# DESCRIPTION
# This procedure simply gets the name of the current Wind Component
# Configuration.
#
# PARAMETERS:
#   hProj : handle of the project to get current build spec for
#
# RETURNS: The current build spec for this project
#
# SEE ALSO:
#

proc wccCurrentGet {hProj} {
    return [prjTagDataGet $hProj WCC__CURRENT]
}

################################################################################
#
# wccCurrentSet - set the current build spec
#
# SYNOPSIS
# \cs
# \ce
#
# DESCRIPTION
#
# PARAMETERS:
#
# RETURNS:
#
# ERRORS:
#
# SEE ALSO:
#

proc wccCurrentSet {hProj wcc} {
    if {[lsearch [prjTagDataGet $hProj WCC__LIST] $wcc] == -1} {
        error "component configuration $wcc doesn't exist"
    }

    prjTagDataSet $hProj WCC__CURRENT $wcc
}

################################################################################
#
# wccCreate - create a wcc, optionally copying info from an existing wcc
#
# SYNOPSIS
# \cs
#   wccCreate <hProj> <wcc> [<oldWcc>]
# \ce
#
# DESCRIPTION
# Create a new Wind Component Configuration. The new configuration may be base
# on an existing wcc if <oldWcc> is specified
#
# PARAMETERS:
#   hProj : handle of the project to create new wcc for
#   wcc : name of Wind Component Configuration to create
#   oldWcc : name of an old Wind Component configuration to be used to create
#            new wcc.
#
# RETURNS: N/A
#
# SEE ALSO: wccListGet, wccDelete
#

proc wccCreate {hProj wcc {oldWcc ""}} {

    if {[lsearch [prjTagDataGet $hProj WCC__LIST] $wcc] != -1} {
        error "component configuration $wcc already exist"
    }

    prjTagDataSet $hProj WCC__CURRENT $wcc
    prjTagDataSet $hProj WCC__LIST \
		  [concat [prjTagDataGet $hProj WCC__LIST] $wcc]

    if {$oldWcc == ""} {
	return
    }

    # copy all component data tags from the oldWcc

    foreach oldTag [prjTagListGet $hProj WCC_${oldWcc}_] {
	regsub $oldWcc $oldTag $wcc newTag
	prjTagDataSet $hProj $newTag [prjTagDataGet $hProj $oldTag]
    }
}

################################################################################
#
# wccDelete - delete a wcc
#
# SYNOPSIS
# \cs
#   wccDelete <hProj> <wcc>
# \ce
#
# DESCRIPTION
# Delete a Wind Component Configuration, and all its associated elements from
# project given by <hProj>
#
# PARAMETERS:
#   hProj : handle of the project to delete wcc for
#   wcc : name of the Wind Component Configuration to delete from project
#
# RETURNS: N/A
#
# ERRORS:
# \is
# \i component configuration <wcc> doesn't exist
# \ie
#
# SEE ALSO: wccCreate
#

proc wccDelete {hProj wcc} {
    set wccs [prjTagDataGet $hProj WCC__LIST]
    set ix [lsearch $wccs $wcc]
    if {$ix == -1} {
        error "component configuration $wcc doesn't exist"
    }

    set wccs [lreplace $wccs $ix $ix]
    prjTagDataSet $hProj WCC__LIST $wccs
    prjTagRemove $hProj WCC_${wcc}_COMPONENTS
    prjTagRemove $hProj WCC_${wcc}_ROUTINES
    prjTagRemove $hProj WCC_${wcc}_PARAMS

    set currentSpec [prjTagDataGet $hProj WCC__CURRENT]
    if {"$currentSpec" == $wcc} {
        if {[llength $wccs] == 0} {
            prjTagDataSet $hProj WCC__CURRENT ""
        } else {
            prjTagDataSet $hProj WCC__CURRENT [lindex $wccs 0]
        }
    }
}

################################################################################
#
# wccComponentSet - Set the component lists
#
# SYNOPSIS
# \cs
#   wccComponentSet <explicit> <implicit> <exclude>
# \ce
#
# DESCRIPTION
#       This function sets the component lists for a project
#       if any of the parameter value is set to "same", then the
#       corresponding list is not set.
#
# PARAMETERS:
#       explicitList: the list of explicitly defined components
#       implicitList: the list of implicitly defined components
#       softExcl: the list of components to exclude from soft inclusion
#
# RETURNS: N/A
#
# ERRORS:
# \is
# \i component configuration <wcc> doesn't exist
# \ie
#
# SEE ALSO:
#

proc wccComponentSet {hProj wcc explicitList  {implicitList same} {softExcl same}} {

    if {[lsearch [prjTagDataGet $hProj WCC__LIST] $wcc] == -1} {
        error "component configuration $wcc doesn't exist"
    }

    if {$explicitList != "same"} {
        prjTagDataSet $hProj WCC_${wcc}_COMPONENTS $explicitList
    }

    if {$implicitList != "same"} {
        prjTagDataSet $hProj WCC_${wcc}_IMPLICIT_COMPONENTS $implicitList
    }

    if {$softExcl != "same"} {
        prjTagDataSet $hProj WCC_${wcc}_SOFT_EXCLUDE_COMPONENTS $softExcl
    }
}

################################################################################
#
# wccComponentAdd - add components to a wcc
#
# SYNOPSIS
# \cs
#   wccComponentAdd <hProj> <wcc> <componentList>
# \ce
#
# DESCRIPTION
# Adds a list of component to the given Wind Component Configuration
#
# PARAMETERS:
#   hProj : handle of the project to add Components to wcc
#   wcc : name of the Wind Component Configuration to add components to
#   componentList : list of components to add to the <wcc>
#
# RETURNS: N/A
#
# ERRORS:
# \is
# \i component configuration <wcc> doesn't exist
# \ie
#
# SEE ALSO: wccComponentRemove
#

proc wccComponentAdd {hProj wcc explicitList {implicitList {}}} {

    if {[lsearch [prjTagDataGet $hProj WCC__LIST] $wcc] == -1} {
        error "component configuration $wcc doesn't exist"
    }
    set cxrDoc [cxrDocCreate $hProj]
    set mxrDoc [mxrDocCreate $hProj]
    set cmpSet [$cxrDoc setCreate]

    set cmpUnavailList [cxrUnavailListGet $cxrDoc $mxrDoc]
    set notAdded {}
    set compsToAdd {}
    foreach comp $explicitList {
        if {[lsearch -exact $cmpUnavailList $comp] <0} {
            lappend compsToAdd $comp
        } else {
            lappend notAdded $comp
        }
    }
    set explicitList $compsToAdd

    set compsToAdd {}
    if {$implicitList != {}} {
        foreach comp $implicitList {
           if {[lsearch -exact $cmpUnavailList $comp] <0} {
	       lappend compsToAdd $comp
	   } else {
	       lappend notAdded $comp
	   }
	}
    }
    set implicitList $compsToAdd

    if {$notAdded != {}} {
        puts  "The following components were not added, the VSB does not support them: $notAdded"
    }

    set cxrDoc [cxrDocCreate $hProj]
    set cmpSet [$cxrDoc setCreate]

    set l_ex [prjTagDataGet $hProj WCC_${wcc}_COMPONENTS]
    set l_im [prjTagDataGet $hProj WCC_${wcc}_IMPLICIT_COMPONENTS]

    $cmpSet = "$explicitList $l_ex"
    prjTagDataSet $hProj WCC_${wcc}_COMPONENTS \
		  [format "%s" [$cmpSet instances Component]]

    if {$implicitList != {}} {
	$cmpSet = "$implicitList $l_im"
	prjTagDataSet $hProj WCC_${wcc}_IMPLICIT_COMPONENTS \
		  [format "%s" [$cmpSet instances Component]]
    }


    # add new ARCHIVE's to the mxrDoc as needed

    $cmpSet = "explicitList $implicitList $l_ex $l_im"
    set tc [prjBuildTcGet $hProj [prjBuildCurrentGet $hProj]]
    $cmpSet = [mxrLibsExpand $hProj [$cmpSet get ARCHIVE] $tc]
    set currentLibs [mxrLibsExpand $hProj [wccMxrLibsGet $hProj] $tc]
    set mxrDoc [mxrDocCreate $hProj]

    set extraLibs ""
    foreach lib [$cmpSet - $currentLibs] {
	lappend extraLibs $lib
    }

    set prjDir	[file dirname [prjInfoGet $hProj fileName]]

    if {[llength $extraLibs] != 0} {

	wccMxrLibsSet $hProj [ \
	    mxrLibsContract $hProj [\
		PrjUtils::prjRelPath $hProj [concat $extraLibs $currentLibs] $prjDir \
	    ] $tc \
	]

	mxrDocDelete $hProj
	mxrDocCreate $hProj
    }

    # SPR#102787 : handle cases when a 1-1 Selection has been broken by this
    # component addition

    $cmpSet = [format "%s %s" \
	 [prjTagDataGet $hProj WCC_${wcc}_COMPONENTS] \
	 [prjTagDataGet $hProj WCC_${wcc}_IMPLICIT_COMPONENTS]]
    set cxrSet [$cmpSet setCreate]

    # find all Selections with the wrong # of children

    $cxrSet = [format "%s %s" [$cmpSet get REQUIRES] [$cmpSet get _CHILDREN]]
    $cxrSet = [format "%s" [$cxrSet instances Selection]]

    set componentList [concat $explicitList $implicitList]

    foreach selection [format "%s" [$cxrSet instances Selection]] {

	$cxrSet = $selection
	set min 0
	set max 100000

	if {[scan [format "%s" [$cxrSet get COUNT]] "%d-%d" min max] == 0} {
	    continue
	}

	$cxrSet = [$cmpSet & [format "%s" [$cxrSet get CHILDREN]]]
	set nChildren [$cxrSet size]

	# We only care about 1-1 Selections. Trying to handle the 2-2 would
	# be a real pain. If one component is added, and excludes another one,
	# which of the two components should be removed ? We cannot decide for
	# the user, so we just let it as is, and issue a warning

	if {($max == 1) && ($min == 1) && ($nChildren > 1)} {

	    $cxrSet = [format "%s" [$cxrSet instances Component]]

	    # retrieve the list of components to be removed. The components
	    # to remove are in the cxrSet instances, but not in the
	    # componentList variable

	    set removed	{}
	    set kept	{}

	    foreach comp [format "%s" [$cxrSet instances]] {
		if {[lsearch -exact $componentList $comp] == -1} {
		    lappend removed	$comp
		} else {
		    lappend kept	$comp
		}
	    }

	    puts [prjStdout] "Removing $removed because $kept has been added to\
			      $selection"

	    wccComponentRemove $hProj $wcc $removed
	}
    }

    $cxrSet delete
    $cmpSet delete
}

################################################################################
#
# wccComponentRemove - remove a component from a wcc
#
# SYNOPSIS
# \cs
#   wccComponentRemove <hProj> <wcc> <componentList>
# \ce
#
# DESCRIPTION
# Remove a component from a Wind River Component Configuration
#
# PARAMETERS:
#   hProj : handle of the project to remove WCC component from
#   wcc : Wind River Component Configuration to remove component from
#   componentList : list of components to remove
#
# RETURNS: N/A
#
# ERRORS:
# \is
# \i component configuration <wcc> doesn't exist
# The specified Wind River Component Configuration <wcc> does not belong to
# the project handled by <hProj>
# \ie
#
# SEE ALSO: wccComponentAdd, wccComponentListGet
#

proc wccComponentRemove {hProj wcc l_ex {l_im {}} {l_mv {}}} {

    if {[lsearch [prjTagDataGet $hProj WCC__LIST] $wcc] == -1} {
        error "component configuration $wcc doesn't exist"
    }

    set cxrDoc [cxrDocCreate $hProj]
    set cmpSet [$cxrDoc setCreate]
    set cmpSetOld [$cxrDoc setCreate]
    $cmpSetOld = [wccComponentListGet $hProj $wcc]

    # set explicit list
    $cmpSet = [wccComponentListGet $hProj $wcc explicit]
    $cmpSet = [$cmpSet - $l_ex]
    prjTagDataSet $hProj WCC_${wcc}_COMPONENTS \
		  [format "%s" [$cmpSet instances Component]]

    # set implict list
    $cmpSet = [wccComponentListGet $hProj $wcc implicit]
    $cmpSet = [$cmpSet - $l_im]
    $cmpSet = [$cmpSet + $l_mv]
    prjTagDataSet $hProj WCC_${wcc}_IMPLICIT_COMPONENTS \
		  [format "%s" [$cmpSet instances Component]]

    # remove ARCHIVE's from the mxrDoc as needed

    $cmpSet = [wccComponentListGet $hProj $wcc all]
    set tc [prjBuildTcGet $hProj [prjBuildCurrentGet $hProj]]
    $cmpSetOld = [mxrLibsExpand $hProj [$cmpSetOld get ARCHIVE] $tc]
    $cmpSet = [mxrLibsExpand $hProj [$cmpSet get ARCHIVE] $tc]
    $cmpSet = [$cmpSetOld - [$cmpSet contents]]

    if {[$cmpSet contents] != ""} {

	set prjDir	[file dirname [prjInfoGet $hProj fileName]]
	set currentLibs	[mxrLibsExpand $hProj [wccMxrLibsGet $hProj] $tc]

	foreach lib [$cmpSet contents] {
	    set ix [lsearch $currentLibs $lib]
	    set currentLibs [lreplace $currentLibs $ix $ix]
	}

	wccMxrLibsSet $hProj [ \
	    mxrLibsContract $hProj [PrjUtils::prjRelPath $hProj $currentLibs $prjDir] $tc\
	]

	mxrDocDelete $hProj
	mxrDocCreate $hProj
    }

    $cmpSet delete
    $cmpSetOld delete
}

################################################################################
#
# wccComponentListGet - get a list of components in a wcc
#
# SYNOPSIS
# \cs
#   wccComponentListGet <hProj> <wcc>
# \ce
#
# DESCRIPTION
# Get the list of components for a given component configuration
#
# PARAMETERS:
#   hProj : handle of the project to get components for
#   wcc : component configuration to get components for
#   outputFlag : defines desired output
#	values:
#	explicit : return explicit list
#	implicit : returns implicit list
#	both:    : returns both lists, as a list of list {{explicit} {implicit}}
#	all	 : retruns all components as a single list
#
# RETURNS: a list of components
#
# ERRORS: N/A
#
# SEE ALSO: prjTagDataGet
#

proc wccComponentListGet {hProj wcc {outputFlag all}} {

    set l_ex [lsort [prjTagDataGet $hProj WCC_${wcc}_COMPONENTS]]
    set l_im [lsort [prjTagDataGet $hProj WCC_${wcc}_IMPLICIT_COMPONENTS]]

    switch $outputFlag {
	explicit { set retval $l_ex }
	implicit { set retval $l_im }
	both	{ set retval [list $l_ex $l_im] }
	all	{ set retval [lsort [concat $l_ex $l_im]] }
	softexclude {
	    set retval [prjTagDataGet $hProj WCC_${wcc}_SOFT_EXCLUDE_COMPONENTS]
	}
	default	{
	    error "invalid parameter outputFlag to wccComponentListGet"
	    set retval {}

	}
    }

    return $retval
}

################################################################################
#
# wccProcCompCreate - create a component corresponding to a routine name
#
# SYNOPSIS
# \cs
#   wccProcCompCreate <hProj> <routine>
# \ce
#
# DESCRIPTION
# Create a component corresponding to a routine name
#
# If the INCLUDE_PROC_<routine> component is defined, then this procedure just
# returns.
#
# If not, a 'procs.cdf' file is created in the project directory, and a
# component named INCLUDE_PROC_<routine> is created, which just defines :
# \is
# \i NAME
# The name of the component, set to "<routine> routine"
# \i LINK_SYMS
# The symbol to link with. It is set to <routine>
# \ie
#
# PARAMETERS:
#   hProj : handle of the project to create component for
#   routine : name of the routine to create a component for
#
# RETURNS: N/A
#
# ERRORS: N/A
#

proc wccProcCompCreate {hProj routine} {
    set cxrDoc [cxrDocCreate $hProj]
    set cxrSet [$cxrDoc setCreate]

    $cxrSet = INCLUDE_PROC_$routine
    if {[$cxrSet instances] != ""} {
	$cxrSet delete
	return
    }
    $cxrSet delete

    set prjDir [file dir [prjInfoGet $hProj fileName]]
    set procFile [file join $prjDir procs.cdf]
    set fd [open $procFile "a+"]
    puts $fd "Component INCLUDE_PROC_$routine \{"
    puts $fd "	NAME		$routine routine"
    puts $fd "	LINK_SYMS	$routine"
    puts $fd "\}"
    close $fd

    $cxrDoc import $procFile
}

###############################################################################
#
# wccProcAdd - add a routine to a wcc
#
# SYNOPSIS
# \cs
#   wccProcAdd <hProj> <wcc> <routineList>
# \ce
#
# DESCRIPTION
# Create a component based on each routines of <routineList>, using
# wccProcCompCreate, and then add it to the list of components the given
# <wcc> handles.
#
# PARAMETERS:
#   hProj : handle of the project to create routine based components for
#   wcc : component configuration to create routine based components for
#   routineList : list of routines to create components for
#
# RETURNS: N/A
#
# ERRORS: N/A
#
# SEE ALSO: wccComponentAdd, wccProcCompCreate
#

proc wccProcAdd {hProj wcc routineList} {
    foreach routine $routineList {
	wccProcCompCreate $hProj $routine
	wccComponentAdd $hProj $wcc INCLUDE_PROC_$routine
    }
}

###############################################################################
#
# wccProcDependsGet - get a list of dependencies for a given routine
#
# SYNOPSIS
# \cs
#   wccProcDependsGet <hProj> <wcc> <routineList>
# \ce
#
# DESCRIPTION
# Get the list of components depending on given routines
#
# PARAMETERS:
#   hProj : handle of the project to get depending components for
#   wcc : component configuration to get depending components for
#   routineList : list of routines to get depending components for
#
# RETURNS: a list of components depending on <routineList> routines
#
# ERRORS: N/A
#
# SEE ALSO: wccProcCompCreate
#

proc wccProcDependsGet {hProj wcc routineList} {
    set cxrDoc [cxrDocCreate $hProj]
    set cxrSet [$cxrDoc setCreate]
    set mxrDoc [mxrDocCreate $hProj]
    foreach routine $routineList {
	wccProcCompCreate $hProj $routine
	$cxrSet = [$cxrSet + INCLUDE_PROC_$routine]
    }
    $cxrSet = [cxrSubtree $cxrSet $mxrDoc]
    set depends [$cxrSet - "INCLUDE_PROC_$routine \
	[wccComponentListGet $hProj [wccCurrentGet $hProj]]"]
    $cxrSet delete
    return $depends
}

###############################################################################
#
# wccProcRemove - remove a routine from a wcc
#
# SYNOPSIS
# \cs
#   wccProcRemove <hProj> <wcc> <routineList>
# \ce
#
# DESCRIPTION
# Remove a component based on a routine from component configuration
#
# PARAMETERS:
#   hProj : handle of the project to remove routine-based component for
#   wcc : component configuration to remove routine-based component for
#   routineList : list of routines to remove components for
#
# RETURNS: N/A
#
# ERRORS: N/A
#
# SEE ALSO: wccComponentRemove
#

proc wccProcRemove {hProj wcc routineList} {
    foreach routine $routineList {
	wccComponentRemove $hProj $wcc INCLUDE_PROC_$routine
    }
}

###############################################################################
#
# wccProcListGet - get a list of routines in a wcc
#
# SYNOPSIS
# \cs
#   wccProcListGet <hProj> <wcc>
# \ce
#
# DESCRIPTION
# Get the list of components based on routines
#
# PARAMETERS:
#   hProj : handle of the project to get routine-based component list for
#   wcc : component configuration to get routine-based component list for
#
# RETURNS: a list of routines which components are based on
#
# ERRORS: N/A
#
# SEE ALSO: wccComponentListGet
#

proc wccProcListGet {hProj wcc} {
    set procList ""
    foreach cmp [wccComponentListGet $hProj $wcc] {
	if {[regsub INCLUDE_PROC_ $cmp {} procName] > 0} {
	    lappend procList $procName
	}
    }
    return $procList
}

###############################################################################
#
# wccParamCheck - typecheck a parameter
#
# SYNOPSIS
# \cs
#   wccParamCheck <type> <value>
# \ce
#
# DESCRIPTION
# This routine typechecks a parameter. If the procedure wccParamCheck_<type>
# exists, it is called. Otherwise no type checking is performed.
# New wccParamCheck_<type> procuderes can be added by putting them in
# a .addin.tcl file.
#
# PARAMETER:
#   type : type of the parameter to check
#   value : value to check parameter against
#
# RETURNS: an error string if the parameter is invalid, an empty string if OK
#
# ERRORS: the type checking procedures will throw errors if the parameter value
# is not of the correct type.
#

proc wccParamCheck {type value} {
    global g_wccParamNoValue
    if { $g_wccParamNoValue == [string trim $value] } {
	return ""
    }
    if {"[info procs wccParamCheck_$type]" != "wccParamCheck_$type"} {
	return ""
    }
    return [wccParamCheck_$type $value]
}

################################################################################
#
# wccParamTypeGet - get the type of a parameter
#
# SYNOPSIS
# \cs
#   wccParamTypeGet <hProj> <param>
# \ce
#
# DESCRIPTION
# Get the type of a given parameter
#
# PARAMETERS:
#   hProj : handle of the project to get parameter type for
#   param : parameter to get type for
#
# RETURNS: The type of the given <param> parameter
#
# ERRORS: N/A
#

proc wccParamTypeGet {hProj param} {
    set cxrDoc [cxrDocCreate $hProj]
    set cmpSet [$cxrDoc setCreate]
    $cmpSet = $param
    set type [$cmpSet get TYPE]
    $cmpSet delete
    return $type
}

###############################################################################
#
# wccParamSet - set a parameter in a wcc
#
# SYNOPSIS
# \cs
#   wccParamSet <hProj> <wcc> <param> <value>
# \ce
#
# DESCRIPTION
# Set a parameter value.
#
# PARAMETERS:
#   hProj : handle of the project to set parameter value for
#   wcc : component configuration to set parameter value for
#   param : name of the parameter to set value for
#   value : value to give to <param>
#
# RETURNS: N/A
#
# ERRORS: N/A
#
# SEE ALSO: wccParamCheck, wccParamTypeGet, prjTagDataSet
#

proc wccParamSet {hProj wcc param value} {
    set err [wccParamCheck [wccParamTypeGet $hProj $param] $value]
    if {"$err" != ""} {
	prjWarnLog "Warning setting parameter $param: $err"
    }
    prjTagDataSet $hProj WCC_${wcc}_PARAM_${param} $value
}

###############################################################################
#
# wccParamRemove - remove a parameter setting to a wcc
#
# SYNOPSIS
# \cs
#   wccParamRemove <hProj> <wcc> <param>
# \ce
#
# DESCRIPTION
# This procedure removes a parameter setting to a Component Configuration.
#
# PARAMETERS:
#   hProj : handle of the project to remove a parameter from
#   wcc : component configuration to remove parameter from
#   param : name of the parameter to remove from Component Configuration
#
# RETURNS: N/A
#
# SEE ALSO: wccCurrentGet
#

proc wccParamRemove {hProj wcc param} {
    prjTagRemove $hProj WCC_${wcc}_PARAM_${param}
}

################################################################################
#
# wccParamHasValue - check if a parameter has a value
#
# SYNOPSIS
# \cs
#   wccParamHasValue <hProj> <wcc> <param>
# \ce
#
# DESCRIPTION
# Check if given parameter has an associated value
#
# PARAMETERS:
#   hProj : handle of the project <param> belongs to
#   wcc : component configuration <param> belongs to
#   param : name of the parameter to check value for
#
# RETURNS: '1' if <param> has an associated value, '0' else.
#
# ERRORS: N/A
#
# SEE ALSO: prjTagDataGet
#

proc wccParamHasValue { hProj wcc param } {
    global g_wccParamNoValue
    return [expr { [prjTagDataGet $hProj WCC_${wcc}_PARAM_${param}] \
		   != $g_wccParamNoValue}]
}

proc wccParamClearValue { hProj wcc param } {
    global g_wccParamNoValue
    prjTagDataSet $hProj WCC_${wcc}_PARAM_${param} $g_wccParamNoValue
}

################################################################################
#
# wccParamGet - get a parameter setting from a wcc
#
# SYNOPSIS
# \cs
#   wccParamGet <hProj> <wcc> <param>
# \ce
#
# DESCRIPTION
# Get a parameter value from a wcc.
#
# The value returned takes conditionnalised parameter values into account.
# If the parameter value comes from the CDF files, and states :
#
# \cs
# (cond1)::(val1) (cond2)::(val2) val3
# \ce
#
# The <cond1> and <cond2> statements are evaluated, and the first true returns
# the associated value. If none of them is true, the default value (here <val3>
# is returned.
#
# PARAMETERS:
#   hProj : handle of the project to get value for
#   wcc : Wind Component Configuration to get parameter value for
#   param : name of the parameter to get value for
#
# RETURNS: The value of the given parameter
#
# ERRORS: N/A
#
# SEE ALSO: wccParamSet
#

proc wccParamGet {hProj wcc param} {

    if {[prjTagDataGet $hProj WCC_${wcc}_PARAM_${param}] != ""} {
	set val [prjTagDataGet $hProj WCC_${wcc}_PARAM_${param}]
    } else {

	set cxrDoc [cxrDocCreate $hProj]
	set cxrSet [$cxrDoc setCreate]
	$cxrSet = $param
	set val [$cxrSet get DEFAULT]
	$cxrSet delete
    }

    # check for the "::" pattern which would indicate the it is a
    # conditionnalised parameter value, and the value must be evaluated first

    if {[set index [string first ")::(" $val]] != -1} {

	# first, gather all the included components, and all the exists and
	# bool parameters

	set cxrDoc	[cxrDocCreate $hProj]
	set includes	[wccComponentListGet $hProj $wcc]

	# look for the parameters of type exists or bool which are set to
	# true

	set bools	{}

	foreach parameter [wccParamListGet $hProj $wcc] {
	    set paramType	[wccParamTypeGet $hProj $parameter]
	    if {($paramType == "exists") || ($paramType == "bool")} {
		set paramValue	[wccParamGet $hProj $wcc $parameter]
		set paramValue	[wccParamValueEval $includes $paramValue]
		if {$paramValue == "TRUE"} {
		    lappend bools $parameter
		}
	    }
	}

	set includes	[concat $includes $bools]

	# we now have the list of includes and bools, we may try to evaluate
	# the conditionnal expression

	set realVal	[wccParamValueEval $includes $val]

    } else {
	set realVal	$val
    }

    return $realVal
}

################################################################################
#
# wccParamValueEval - evaluate a contitionnalised parameter value
#
# SYNOPSIS
# \cs
#   wccParamValueEval <includes> <condition>
# \ce
#
# DESCRIPTION
# This procedure evaluates the <condition> value against the <includes>
# components/defines. The <condition> should be of the form :
#
# \cs
# (cond1)::(val1) (cond2)::(val2) ... valx
# \ce
#
# Where cond<n> is an inclusion component condition to evaluate (like
# (INCLUDE_MY_COMPONENT)), and val<n> the value to return if the condition is
# true
#
# The last value is the default value to give to the parameter whenever none of
# the conditionals is true
#
# On the first true conditionnal, the associated value is returned.
#
# PARAMETERS:
#   includes : list of included components and boolean parameters
#   condition : condition to evaluate
#
# RETURNS: The value associated to the first true condition of <conditions>, or
# the default value of <conditions>
#
# ERRORS: N/A
#
# SEE ALSO: wccParamGet
#

proc wccParamValueEval {includes condition} {

    # if there is not delimiter, there is no condition to process.

    if {[set index [string first ")::(" $condition]] == -1} {
	return $condition
    }

    incr index

    # process and evaluate one condition a time, return the value
    # once a condition is satisfied

    set cond [string range $condition 0 [expr {$index} -1]]

    # workStr is now (expr1) ....

    set workStr [string range $condition [expr {$index} +2] end]

    while {[string length $workStr] != 0} {

	set parenIndex [string first "(" $workStr]
	set parenCount 1

	# extract expression

	set count $parenIndex
	while {$count < [string length $workStr] && $parenCount != 0} {
	    incr count
	    if {[string index $workStr $count] == "("} {
		incr parenCount
	    } elseif {[string index $workStr $count] == ")"} {
		set parenCount [expr {$parenCount} - 1]
	    }
	}

	set exp [string range $workStr [expr {$parenIndex} + 1] \
			      [expr {$count} - 1]]

	# evaluate the condition

	regsub -all -nocase {[a-z0-9_]+} [string trim $cond] \
	       {([lsearch $includes &] != -1)} cond

	set cmd "if {$cond} {return \$exp}"

	eval $cmd

	# the condition doesn't hold, continue

	set workStr [string range $workStr [expr {$count} + 1] end]
	set index [string first ")::(" $workStr]
	if {$index == -1} {
	    return [string trim $workStr]
	} else {
	    incr index
	    set cond [string range $workStr 0 [expr {$index} -1]]
	    set workStr [string range $workStr [expr {$index} +1] end]
	}
    }

    return ""
}

################################################################################
#
# wccParamListGet - get a list of parameter macros
#
# SYNOPSIS
# \cs
#   wccParamListGet <hProj> <wcc>
# \ce
#
# DESCRIPTION
# This procedure gets the list of components defined for the given <hProj>
# project.
#
# PARAMETERS:
#   hProj : handle of the project to get list of parameters for
#   wcc : components specification to get list of components for
#
# RETURNS: The list of components for the <hProj> project with Build Spec <wcc>.
#
# SEE ALSO: wccCurrentGet
#

proc wccParamListGet {hProj wcc} {
    set cxrDoc [cxrDocCreate $hProj]
    set cxrSet [$cxrDoc setCreate]
    $cxrSet = [wccComponentListGet $hProj $wcc]
    $cxrSet = [$cxrSet get CFG_PARAMS]
    set params [$cxrSet instances Parameter]
    $cxrSet delete
    return $params
}

################################################################################
#
# cxrDocCreate - create a Cxr document for a project
#
# SYNOPSIS
# \cs
#   cxrDocCreate <hProj>
# \ce
#
# DESCRIPTION
# Create a Component Cross Reference document for a given project.
#
# DELAY: This routine can take a couple of seconds while importing the '.cdf'
# files.
#
# PARAMETERS:
#   hProj : handle of the kernel configuration project to create Cxr Doc for
#
# RETURNS: Cxr Doc handle
#
# ERRORS: N/A
#
# SEE ALSO: dataDocLib, cxrDocDelete
#

proc cxrDocCreate {hProj} {

    global cxrDocs

    if {[info exists cxrDocs($hProj)]} {
	return $cxrDocs($hProj)
    }
    set buildSpec [prjBuildCurrentGet $hProj]
    set toolchain [prjBuildTcGet $hProj $buildSpec]
    set variant [prjTagDataGet $hProj BUILD_${buildSpec}_MACRO_CPU_VARIANT]
    set vsbDir [prjTagDataGet $hProj VSB_DIR]
    set cdfPath   [wccCdfPathGet $hProj]
    set vxbuild [prjTagDataGet $hProj VXBUILD]
    set cxrDocs($hProj) [cxrDataDocCreate $cdfPath $toolchain $variant $vsbDir $vxbuild]
    return $cxrDocs($hProj)
}

################################################################################
#
# cxrDocDelete - delete a Cxr document for a project
#
# SYNOPSIS
# \cs
#   cxrDocDelete <hProj>
# \ce
#
# DESCRIPTION
# Delete a Components Cross Reference document for a given kernel configuration.
#
# PARAMETERS:
#   hProj : handle of the kernel configuration project to delete Cxr Doc for
#
# RETURNS: N/A
#
# ERRORS: N/A
#
# SEE ALSO: dataDocLib, cxrDocCreate
#

proc cxrDocDelete {hProj} {
    global cxrDocs

    if {![info exists cxrDocs($hProj)]} {
	return
    }
    $cxrDocs($hProj) delete
    unset cxrDocs($hProj)
}

###############################################################################
#
# mxrLibsSearch - search for module libraries
#
# SYNOPSIS
# \cs
#   mxrLibsSearch <linkPath> <libs>
# \ce
#
# DESCRIPTION
# Derive the list of libraries for creation of mxrDoc from linkPath and libs
#
# PARAMETERS:
#  linkPath : link path
#  libs : libraries
#
# RETURNS: a list of libraries
#
# ERRORS: N/A
#

proc mxrLibsSearch {linkPath libs} {
    set pathList {}
    foreach path $linkPath {
        regsub -- {-L} $path "" path
	lappend pathList $path
    }
    set libList {}
    foreach lib $libs {
	if {[regexp -- {-l} $lib]} {
	    regsub -- {-l} $lib "" lib
	    set lib lib${lib}.a
	}
	foreach path $pathList {
	    if {[file exist [file join $path $lib]]} {
		set lib [file join $path $lib]
		break
	    }
	}
	lappend libList $lib
    }
    return $libList
}

###############################################################################
#
# mxrDocCreate - create an Mxr document for a project
#
# SYNOPSIS
# \cs
#   mxrDocCreate <hProj>
# \ce
#
# DESCRIPTION
#
# DELAY:
# This routine may take 10 seconds or more the read in the module and symbol
# info from the project archives.
#
# PARAMETERS:
#   hProj : handle of the project to create Mxr document for
#
# RETURNS: The Module Cross refernce class id
#
# ERRORS: N/A
#
# SEE ALSO: mxrDocDelete, cxrDocCreate, cxrDocDelete
#

proc mxrDocCreate {hProj} {

    global mxrDocs
    global cxrDocs

    if {[info exists mxrDocs($hProj)]} {
	return $mxrDocs($hProj)
    }

    # get a Cxr in order to gater the ARCHIVEs directives

    if {[info exists cxrDocs($hProj)]} {

	# get archives from there

	set cxrDoc	$cxrDocs($hProj)

    } else {

	set cxrDoc	[cxrDocCreate $hProj]
    }

    set cmpSet		[$cxrDoc setCreate]
    $cmpSet =		[$cxrDoc instances Component]
    set archives	[format "%s" [$cmpSet get ARCHIVE]]

    set build		[prjBuildCurrentGet $hProj]
    set libs		[prjBuildMacroGet $hProj $build LIBS]
    set tc		[prjBuildTcGet $hProj $build]
    set libs		[concat [wccMxrLibsGet $hProj] $libs]
    set libs		[mxrLibsExpand $hProj $libs $tc]
    set libs		[concat $libs [mxrLibsExpand $hProj $archives $tc]]
    set mxrDocs($hProj)	[mxrDataDocCreate $tc $libs]
# prototype code for next release
# set buf {}
# set mxrDoc $mxrDocs($hProj)
# set containerSet [$cxrDoc setCreate]
# set moduleSet [$mxrDoc setCreate]
# set symbolSet [$mxrDoc setCreate]


# set containers [$cxrDoc instances Api]
# foreach container $containers {
#	$cmpSet = $container
#	set children [$cmpSet get CHILDREN]
#	if {[llength $children] == 0} { continue }
#	set first [lindex $children 0]
#	$cmpSet = $first
#	$moduleSet = [$cmpSet get MODULES]
#	$symbolSet = [$moduleSet get exports]
#	foreach child [lrange $children 1 end] {
#		$cmpSet = $child
#		$moduleSet = [$cmpSet get MODULES]
#		$symbolSet = [$symbolSet & [$moduleSet get exports]]
#	}
#	$cmpSet = [$symbolSet get importedBy]
#	$cmpSet = [$cmpSet get _MODULES]
#	lappend buf "\nApi $container \{\n_LIB_REQUIRES [$cmpSet instances]\n\}\n"
# }
# $containerSet = $containers
# $cmpSet = [$cxrDoc instances Component]
# set components [$cmpSet - [$containerSet get CHILDREN]]
# foreach component $components {
#	$cmpSet = $component
#	$moduleSet = [$cmpSet get MODULES]
#	$symbolSet = [$moduleSet get exports]
#	$cmpSet = [$symbolSet get importedBy]
#	$cmpSet = [$cmpSet get _MODULES]
#	lappend buf "\nComponent $component \{\n_LIB_REQUIRES [$cmpSet instances]\n\}\n"
# }

# puts "buf: [join $buf]"

    $cmpSet delete
# $containerSet delete
# $moduleSet delete
# $symbolSet delete

    return $mxrDocs($hProj)
}

################################################################################
#
# mxrDocDelete - delete an Mxr document for a project
#
# SYNOPSIS
# \cs
#   mxrDocDelete <hProj>
# \ce
#
# DESCRIPTION
# Delete an Mxr document for a given project
#
# PARAMETERS:
#   hProj : handle of the project to delete Mxr document for
#
# RETURNS: N/A
#
# ERRORS: N/A
#
# SEE ALSO: mxrDocCreate
#

proc mxrDocDelete {hProj} {
    global mxrDocs

    if {![info exists mxrDocs($hProj)]} {
	return
    }
    $mxrDocs($hProj) delete
    unset mxrDocs($hProj)
}

#################################################################################
#
# cxrDupRecRm - remove duplicate message
#
# RETURN List: <object message>
#

proc cxrDupRecRm { msg } {
    set printed {}
    set n 0
    foreach s $msg {
        if { [lsearch $printed $s ] ==-1 } {
            lappend printed $s
        } else {
           incr n
        }
    }
    return $printed
}

#################################################################################
#
# mxrSymsValidate - Verify if the symbols belong to the set of objects (exported)
#
# RETURN List: <object symbols>
#

proc mxrSymsValidate { hProj cmpSet cmpUser syms } {

    set mxrDoc [mxrDocCreate $hProj]
    set modSet [$mxrDoc setCreate]
    set exSyms [$mxrDoc setCreate]
    set imSyms [$mxrDoc setCreate]
    set linkSyms [$mxrDoc setCreate]
    set realSymList {}
    $modSet = [$cmpSet get MODULES]
    set symList [format "%s%s" [$modSet get exports] [$modSet get declares]]

    $exSyms = [$modSet get exports]
    $exSyms =  [$exSyms + [$modSet get declares]]

    $cmpSet = $cmpUser
    $modSet = [$cmpSet get MODULES]
    $imSyms = [$modSet get imports ]
    $linkSyms = [$imSyms & [$exSyms instances]]

    $modSet delete
    $exSyms delete
    $imSyms delete
    set result [format "%s" [$linkSyms instances]]

    $linkSyms delete
    return $result

}

#############################################################################
#
# cxrSymsAdd - add the symbols to the components which import the symbols
#
# Add symbols to the components to represent the relationship anmong the
# components. Duplicated symboles are handled by removal.
#

proc cxrSymsAdd {hProj cmpSet component msg cmpUserSymlist} {

    set cxrDoc [cxrDocCreate $hProj]
    set printed {}
    upvar 1 $cmpUserSymlist cmpUserSyms
    set output ""
    array set  cmpSym {}
    set symList {}
    foreach ln $msg {
        if {[lsearch $printed $ln] ==-1} {
            set cmp [lindex $ln 0]
            $cmpSet = $cmp
            set cmpUser [lindex $ln 1]
            set realSyms [mxrSymsValidate $hProj $cmpSet $cmpUser $symList]
            set output "$cmp is required by $cmpUser \($realSyms\)"
            if { ($cmpUser != "") && ($realSyms != "") } {
                    puts  $output
                    lappend printed $output
            }
       }
   }
}



proc cxrCleanReqList {comprequiedBy} {

    upvar 1 $comprequiedBy compRequiedBy
    array set compRequiedBy1 {}
    foreach n [array names compRequiedBy] {
         set  compRequiedBy($n) [lsort -unique $compRequiedBy($n)]
         set next ""
         foreach cmp $compRequiedBy($n) {
             if {$next == $cmp} {
                 continue
             }
             if { $cmp != $n } {
                 lappend compRequiedBy1($n) $cmp
             }
                 set next $cmp
         }
     }
     array unset compRequiedBy
     array set compRequiedBy [array get compRequiedBy1]
}

############################################################################
#
# cmpIncluedUserGet  - get components which only included in the project
# RETURNS list: <components>
#

proc  cmpIncluedUserGet {cmpSet cmpSet1  included cmp {opt ""} } {

    upvar 1 cdfPrinted  cdfPrinted
    $cmpSet = $cmp
    set cmpSet2 [$cmpSet setCreate]
    set usr [$cmpSet get _REQUIRES]
    $cmpSet = [$cmpSet get MACRO_NEST]
    $cmpSet = [$cmpSet + $usr]
    if {$opt == ""} {
        extractCMs  $cmpSet $cmpSet2 $included "Component"
     }
    set usr [format %s [$cmpSet contents]]
    if { $usr == "" } {
        return
    }
    set outp [format "%s" "$cmp is required by $usr"]
    if { [lsearch $cdfPrinted $outp] == -1 } {
        puts $outp
        lappend cdfPrinted $outp
    }
    return  $usr
}

############################################################################
#
# cxDepFstTraceCdf - Component relationship searching in cdfs
#
# Searching the component relationship with the depth given by cxrSupertree.
# The depth also determines how many code can be generated for looping.
#

proc cxDepFstTraceCdf { cmpSet cmpSet2 cmp included cunt {opt ""}} {

    set cmd ""
    set cdfPrinted {}
    set s1 cmpSet
    set s2 cmpSet2
    set s3 cmp
    set s4 included
    set s5 usr
    set s6 u
    set func "cmpIncluedUserGet  $$s1 $$s2  $$s4"
    set func2 "cmpIncluedUserGet  $$s1 $$s2 $$s3 $$s4"
    set usr0 [cmpIncluedUserGet $cmpSet $cmpSet2  $included $cmp]

    for { set i 0 } {$i < $cunt} { incr i} {
        append cmd [format \t%s "foreach u$i $$s5$i \{ set $s5[expr $i + 1] \[ $func $$s6$i \] \n"]
    }

    for { set i 0 } {$i < $cunt} { incr i} {
        append cmd [format  %s "\t\}\n"]
    }
    return [eval $cmd]
}

#############################################################################
#
# cxrOneToOneTrace -  Trace path searching
#
# Searching the component relationship with the "dept" given by cxrSupertree.
# The depth also determines how many code can be generated for looping.
#

proc cxrOneToOneTrace {compRequires component1 component2 dept} {

    upvar 1  $compRequires compReqs
    set s1 sublist
    set s2 compReqs
    set s3 component2
    set s4 dept
    set cmd2 ""
    set s0 $component1
    set clist ""

    for { set i 0 } {$i < $dept } { incr i} {
        append cmd [format \t%s "\n\tforeach s[expr $i + 1] $$s2\(\$s$i\) \{
          set sublist[expr $i + 1] \$s[expr $i + 1]
          if \{ \$s[expr $i + 1] == \$$s3 \} \{ \n"]

        for { set j 0 } {$j < [expr $i + 1]} { incr j} {
          append cmd2 [format "\t  %s" "  lappend clist $$s1[expr $j + 1]\n"]
        }
        append cmd2 "\t   # puts \"clist == \$clist \" \n\t    return \$clist\t\n\t  \}
          if \{ \[array names $s2 \$s[expr $i + 1] \] == \"\" \} \{
                 continue
          \} "
        append  cmd $cmd2
        set cmd2 ""
    }
    for { set i 0 } {$i < $dept} { incr i} {
       append cmd3 [format  %s "\n\t\}"]
     }
    append cmd $cmd3
    eval $cmd
    return -1

}

#############################################################################
#
# cxrDepFstTraceCos - Component relationship searching
#
# Searching the component relationship with the depth given by cxrSupertree.
# The depth also determines how many code can be generated for looping.
#


proc cxrDepFstTraceCos {compReqs component depth} {

    upvar 1 $compReqs  compRequires
    set cmd ""
    set s1 compRequires
    set s2 component
    set s3 dep
    #set s4 processedList
    set dep0 $component
    set result {}
    set processedList {}
    lappend processedList $component
    for { set i 0 } {$i < $depth} { incr i} {

        append cmd [format \t%s "
                       foreach dep[expr $i +1] $$s1\($$s3$i\) \{
                           if \{ \[lsearch -exact \$processedList $$s3[expr $i +1]\] == -1 \}  \{
                               lappend result \"$$s3$i  $$s3[expr $i +1]\"
                               lappend processedList  $$s3[expr $i +1]

                           \} else \{
                                continue
                           \}
                           if \{ \[array names compRequires $$s3[expr $i +1]\] == \"\" \} \{
                                     continue
                          \} else  \{
                                    lappend processedList  $$s3[expr $i +1]
                          \} "]

    }

    for { set i 0 } {$i < $depth} { incr i} {
       append cmd [format  %s "\n\t\}"]
    }
    eval $cmd
    return $result
}

################################################################################
#
# wccCmpRootUserCxrGet - find root users for the given component in a project
#                         from CxrDoc (CDF difinations)
#
# SYNOPSIS
# \cs
#   wccCmpRootUserCxrGet <hProj> <component> <included> <opt>
# \ce
#
# DESCRIPTION
# Check a compoent to find who is root user and drag it into the project
# from CDF definations (CxrDoc)
#
# PARAMETERS:
#   hProj :     handle of the project
#   component : component to be checked
#   included  : components included in a project
#   opt:        options
#
# RETURNS: N/A
#
# ERRORS: N/A
#
# SEE ALSO: wccCmpRootUserGet
#
#
proc wccCmpRootUserCxrGet  { hProj component included {opt ""} } {

    set cxrDoc [cxrDocCreate $hProj]
    set cmpSet [$cxrDoc setCreate]
    set cmpSet2 [$cxrDoc setCreate]
    set DEF_DEPTH 5
    $cmpSet = $component
    cxDepFstTraceCdf $cmpSet $cmpSet2 $component $included $DEF_DEPTH $opt

}

############################################################################
#
# explicityCmpsDisplay - display direct relationship amongs components
#

proc explicityCmpsDisplay { hProj comprequiedBy cxrDoc component included cmpUsers } {

    upvar  $comprequiedBy  compRequiedBy
    set impList {}
    set cmpSet [$cxrDoc setCreate]
    puts  "Users for $component:"
    puts  [lsort -unique $cmpUsers]
    puts  "\n$component is directly dragged in by the following ..."

    foreach cmpu $compRequiedBy($component) {
        $cmpSet = $component
        set syms [mxrSymsValidate  $hProj $cmpSet $cmpu ""]
        if {([lsearch $included $cmpu] != -1) && ($syms != "")} {
             puts "$component is required by $cmpu \($syms\)"
             lappend impList $cmpu
        }
    }
    return $impList
}

##########################################################################################
#
# tracPathCmpsDisplay - display trace path between two selected components
#

proc tracPathCmpsDisplay { hProj cmpSet cmpObjSymlist result depth component component2} {
     upvar 1 $cmpObjSymlist cmpObjSymList

     foreach s $result {
        set name [lindex $s 0]
        set elem [lindex $s 1]
        lappend compReqReal($name) $elem
     }
     set tracePath [cxrOneToOneTrace compReqReal  $component $component2 $depth]
     if {$tracePath == -1 } {
         puts  "WARNING: Trace to outside of the project"
         return
     } else {
         set tracePath [concat $component $tracePath]
     }
     foreach l $tracePath {
         if { $l == [lindex $tracePath end]} {
             puts "$l"
         } else {
             puts -nonewline "$l <-- "
         }
      }
     set traceSyms {}
     for {set i 0} { $i < [llength $tracePath]} { incr i} {
         lappend traceSyms [list [lindex $tracePath $i] \
                  [lindex $tracePath [expr $i + 1]]]
     }
     puts  "\nSymbols called by each component:"
     cxrSymsAdd $hProj $cmpSet $component $traceSyms  cmpObjSymList
     return $tracePath
}


######################################################################################
#
# modUsersParse - parse and get useful information from the message
# It results in two type of data: compRequiedBy and cmpObjSymList
#

proc modUsersParse { cxrDoc comprequiedBy  cmpobjSymList } {

    global  g_modUsers
    upvar  $cmpobjSymList  cmpObjSymList
    upvar  $comprequiedBy compRequiedBy
    array set objSym {}
    array set cmpSym {}
    set expCmp ""

            foreach mod [array names g_modUsers] {
                if { [cxrCmpGetByMod $cxrDoc $mod] != "" } {
                    # the format of message is:  modex, obj1 sym1 sym2,
                    # obj2 sym1 sym2, ....objn sym1 sym2
                    foreach osPair $g_modUsers($mod) {
                        set obj [lindex $osPair 0]
                        lappend objSym($obj) [lindex  $osPair 1]
                        set cmp [cxrCmpGetByMod $cxrDoc $obj]
                        if { $cmp != "" } {
                            lappend cmpSym($cmp) [lindex $osPair 1]
                        } else {
                            continue
                        }
                        set  objSym($obj) [lsort -unique $objSym($obj)]
                        set  cmpSym($cmp) [lsort -unique $cmpSym($cmp)]
                        set cmpUser [cxrCmpGetByMod $cxrDoc $obj]
                        if { $cmpUser != "" } {
                            set expCmp [cxrCmpGetByMod $cxrDoc $mod]

                            # handle a object with multiple component
                            # for both cmp and cmp users

                            foreach c  $expCmp {
                                foreach cu $cmpUser {
                                    lappend  compRequiedBy($c) $cu
                                    set  compRequiedBy($c) [lsort -unique $compRequiedBy($c)]
                                }
                            }
                       } else {
                           continue
                       }
                   }
                   if { $expCmp != "" } {
                       set  cmpObjSymList($expCmp) [array get cmpSym]
                   }
                   array unset objSym
                   array unset cmpSym

               } else {
                    continue
               }
         }

}

################################################################################
#
# wccCmpRootUserGet - find root users and path for components in a project
#
# SYNOPSIS
# \cs
#   wccCmpRootUserGet <hProj> <components> <included> <opt>
# \ce
#
# DESCRIPTION
# Check a compoent to find who is a root user and drag it into the project.
# And find a relationships (trace path) between two componets.
#
# PARAMETERS:
#   hProj :     handle of the project
#   components : components to be checked
#   included  : components included in a project
#   opt:        options
#
# RETURNS: N/A
#
# ERRORS: N/A
#
# SEE ALSO: cxrDocValidate1 wccCmpRootUserCxrGet
#
#
proc wccCmpRootUserGet  { hProj components included {opt ""} } {

    global cxrUnavailInfo
    global g_modUsers
    array set  compRequiedBy {}
    array set misComps {}
    set cxrDoc [cxrDocCreate $hProj]
    set mxrDoc [mxrDocCreate $hProj]
    set cmpSet [$cxrDoc setCreate]
    set cmpSet2 [$cxrDoc setCreate]
    set result {}
    set rcDep 0
    set DEP_POS  5
    array set cmpObjSymList {}
    set ERR_1 "No root user for the component"
    set expList {}

    set component [lindex $components 0]
    if { $opt == "tracepath"} {
        set component2 [lindex $components 1]
        puts  "Searching the trace path..."
    } else {
        set component2 ""
    }
    $cmpSet = $component
    # Deal with root user and path trace
    # get all componets and symbols which use the given component
    # search the relationship among components

    if { ($opt == "rootuser") || ($opt == "tracepath") } {
         set res [cxrSupertree $cmpSet $mxrDoc $included "extended"]
         if { ([info exists cxrUnavailInfo]) && ([llength $cxrUnavailInfo] != 0) } {
               set rcDep  [lindex $cxrUnavailInfo $DEP_POS]
         } else {
              puts $ERR_1
              return
         }
         modUsersParse  $cxrDoc compRequiedBy  cmpObjSymList
         cxrCleanReqList compRequiedBy

         if { [array names compRequiedBy $component] == ""} {
             puts $ERR_1
             return
         }

         if { $opt == "rootuser" } {
            $cmpSet = [cxrSupertree $cmpSet $mxrDoc $included ]
            extractCMs  $cmpSet $cmpSet2 $included "Component"
            set compUsers [$cmpSet instances Component]
            set ix [lsearch -exact $compUsers $component]
            set compUsers [lreplace $compUsers $ix $ix]
            foreach cmp [array names compRequiedBy] {
                    lappend cmpFromSTList $cmp
            }
            set cmpFromSTList [lsort -unique $cmpFromSTList]
            $cmpSet = $cmpFromSTList
            $cmpSet = [$cmpSet & $compUsers]
            set  compUsers [$cmpSet instances Component]
            set  expList [explicityCmpsDisplay $hProj compRequiedBy $cxrDoc $component $included $compUsers]
            $cmpSet = $compUsers
            $cmpSet = [$cmpSet - $expList]
            set impList [$cmpSet instances Component]
         }
         if { [array names compRequiedBy $component] != "" } {
              set result [cxrDepFstTraceCos compRequiedBy $component  $rcDep]
         } else {
             puts "WARNING: $ERR_1"
         }

         # In case the result is available
         # print out root user and trace path message
         if { [array names compRequiedBy $component] != ""} {
             set result [cxrDupRecRm $result]
             if {  $opt == "tracepath" } {
                  return [tracPathCmpsDisplay $hProj $cmpSet cmpObjSymList $result \
                                                      $rcDep $component $component2]
             } elseif { $opt == "rootuser" } {
                 puts  "\n$component is indirectly dragged in  by the following..."
                 puts  $impList
                 # ZZZ: if need detail information for the whole tree uncomment the following
                 #cxrSymsAdd $hProj  $cmpSet $component $result  cmpObjSymList
            }
         }
         puts  "Done"

    } else {
         puts "WARNING: Wrong option $opt"
         return
    }
    $cmpSet delete
    $cmpSet2 delete
    return $result
}



################################################################################
#
#  cxrDocValidate1 -  single component check
#
# SYNOPSIS
# \cs
#   cxrDocValidate1 <hProj> <component> <opt>
# \ce
#
# DESCRIPTION
# Check a single compoent to find the unavailabe reason
#
# PARAMETERS:
#   hProj :     handle of the project to delete Mxr document for
#   component : component to be checked
#   opt:        options
#
# RETURNS: N/A
#
# ERRORS: N/A
#
# SEE ALSO: cxrDocValidate
#
proc cxrDocValidate1 {hProj component {opt ""}} {

    global cxrUnavailInfo
    array set compRequires {}
    array set misCompsObj {}
    set unavailCompList {}
    set installedComps {}
    set cxrDoc [cxrDocCreate $hProj]
    set mxrDoc [mxrDocCreate $hProj]
    set wcc [wccCurrentGet $hProj]
    set cmpSet [$cxrDoc setCreate]

    if {  $opt == "unavailDetail" } {
        puts "Retrieving detail information about unavailable components..."
    } else {
       puts "\nChecking Component $component..."
       set compList [wccComponentListGet $hProj $wcc]
       if {[ lsearch -exact $compList $component] != -1} {
          puts "$component is included"
       } else {
          puts "$component is not included"
       }
    }

    set unavailCompList [cxrUnavailListGet $cxrDoc $mxrDoc]
    if { [lsearch $unavailCompList $component] !=-1} {
        puts "Component $component is unavailable because:"
    }

    set deps [cxrUnavailListGet $cxrDoc $mxrDoc "extended"]

    if {[info exists cxrUnavailInfo]} {
	if {("$cxrDoc" == [lindex $cxrUnavailInfo 0]) && \
		("$mxrDoc" == [lindex $cxrUnavailInfo 1])} {
           array set misCompsObj [lindex $cxrUnavailInfo 3]
           set installedComps [lindex $cxrUnavailInfo 4]
	}
    }

    if { ([lsearch $installedComps $component] != -1) && ( [lsearch $unavailCompList $component] ==-1) } {
          puts stdout "$component is installed and available\n"
          return
    }

   # get dependences/requires trace information

    cxrInfoParse $deps compRequires $opt

    if { $opt == "unavailDetail" } {
        return $unavailCompList
    }

    if { [lsearch [array names misCompsObj] $component] != -1} {
         if { $misCompsObj($component) == "REQUIRE_ALL_RESOLVED" } {
             $cmpSet = $component
             foreach c [cxrRequires $hProj $cmpSet 0 ] {
                 if { ([lsearch [array names misCompsObj] $c ] != -1) && ($c != $component)} {
                     puts stdout "**** Component $c is not $misCompsObj($c)"
                 }
             }
         } else {
             if { $misCompsObj($component) == "defined" } {
                puts stdout "**** Component $component is not $misCompsObj($component)"
             }  else {
                 puts stdout "**** Component $component is missing $misCompsObj($component)"
             }
         }
         puts ""
    } else {
           set count 0
           puts stdout " "
           cxrTrace $component $hProj misCompsObj compRequires
    }
}

proc cxrInfoParse2  { deps compReq titles ix included unavailCmpList {opt ""}} {

   upvar 1 $compReq  compRequires

	foreach depType $deps {
            array set compRequires {}
	    set printed	{}
	    puts stdout [lindex $titles $ix]
	    incr ix

	    foreach comp [lsort -index 0 -dictionary $depType] {
		set compName		[lindex $comp 0]
		set reasons		[lindex $comp 1]
                 if { [lsearch -exact $included $compName] !=-1 } {
	  	     puts  -nonewline "$compName \(included\)"
                } else {
                     puts  -nonewline "$compName \(excluded\)"
                }

                if { [lsearch -exact $unavailCmpList $compName] !=-1 } {
	     	     puts -nonewline "\(unavailable\)\n"
                } else {
                     puts ""
                }

                set reason [lsort  -unique  -dictionary $reasons]

		# some dependencies are listed twice, just try to
		# ouput them once

		foreach reason $reasons {

                  foreach s $reason {
		    if {[llength $s] != 0} {

			if {[lsearch  $printed  $s ]==-1} {

			    puts stdout "    -  $s "
                            regexp {([^\ ]+) requires ([^>]+)} $s match n1 r2
                            set iy [lsearch -exact -regexp $r2 "component|module"]
                            if { $iy != -1 } {
                                 set r2 [lreplace $r2 $iy $iy]
                            }
                            lappend compRequires($compName) $r2
			}
			lappend printed  $s
		    }
                 }
	       }
	    }
	}
      return [array get compRequires]

}

proc cxrInfoParse  { deps compReq {opt ""}} {
   upvar 1 $compReq  compRequires

   foreach depType $deps {
        set printed {}
        set compName            [lindex $depType 0]
        set reasons             [lindex $depType 1]
        if { $opt == "unavailDetail" } {
            puts stdout "$compName"
        }
        set compRequires($compName) {}

        foreach comp $reasons {
                set r2 {}
                foreach s $comp {

                    if {[llength $s] != 0} {

                        if {[lsearch  $printed  $s ]==-1} {
                            if { $opt == "unavailDetail" } {
                                puts stdout "    -  $s "
                            }
                            regexp {([^\ ]+) requires ([^>]+)} $s match n1 r2
                            set ix [lsearch -exact -regexp $r2 "component|module"]
                            if { $ix != -1 } {
                                 set r2 [lreplace $r2 $ix $ix]
                            }

                            if { ( [lsearch $compRequires($compName) $r2 ] == -1) && ($r2 != $compName) && ([string first "symbol" $r2 ] ==-1) } {
                                lappend compRequires($compName) $r2
                            }
                        }
                        lappend printed  $s
                    }
                }
         }
     }
     return [array get compRequires]
}


# pravite procedures

proc cxrCmpGetBySym { cxrDoc sym } {

  set cmpSet	[$cxrDoc setCreate]
  $cmpSet = $sym
  set component [format %s [$cmpSet get  _LINK_SYMS ]]
  $cmpSet delete
  return $component
}


proc cxrCmpGetByMod { cxrDoc mod } {

  set cmpSet	[$cxrDoc setCreate]
  $cmpSet = $mod
  set component [format %s [$cmpSet get _MODULES]]
  $cmpSet delete
  return $component
}

################################################################################
#
# cxrTrace -  trace inforamtion retrieved from cxrDoc and mxrDoc
#
# SYNOPSIS
# \cs
#   cxrTrace <component>  <hProj> <mCObj> <cRqs> } {
# \ce
#
# DESCRIPTION
# Check a single compoent to find the unavailabe reason
#
# PARAMETERS:
#   component : component to be checked
#   mCObjt:     missed object list
#   cRqs:       required component information in cxrDoc and mxrDoc
#
# RETURNS: N/A
#
# ERRORS: N/A
#
# SEE ALSO: cxrSubtree cxrSuptree
#

proc cxrTrace { component hProj mCObj cRqs {opt ""} } {
    upvar 1 $mCObj misCompsObj
    upvar 1 $cRqs  compRequires

  # recursively retrieve trace information
  proc cxrEach { c  cRqs prevComp postList misCps dup opt { ptd ""} } {

      upvar 1 $cRqs  compRequires1
      upvar 1 $misCps  misCompsObj
      upvar 1 $ptd  printed
      set k 0
      if { ($prevComp != $c) && ([format "%s" $c] != "{}") } {
          # YYY zhr - For simplifying the output remove the tracing information
          # for component check. It could be restored if it is required
          if { $opt == "dep" } {
               puts "$prevComp requires $c"
          }
      }
      if { [lsearch [array names misCompsObj] $c] != -1} {
          if { [lsearch $printed $c ]==-1 } {
               puts stdout "**** Component $c is missing $misCompsObj($c)\n"
               lappend printed $c
          }
      }
      if { [lsearch $postList $prevComp] ==-1 } {
          lappend postList $c
      } else {
         incr dup
         if { $dup > 2 } {
             return
         }
      }

      foreach  cmpName [array names compRequires1] {

          if { $c == $cmpName } {
              set k 0
              set reqList  $compRequires1($cmpName)
              while { [lindex $reqList $k] != ""} {
                     incr k
                     set prevComp $c
                     cxrEach [lindex $reqList [expr $k -1]] compRequires1 $prevComp $postList misCompsObj $dup $opt printed
              }
          }
      }
   }
    set i 0
    array set compRequires1 {}

    # Remove duplicated components again to avoid undefinate loop

    foreach cn [array names compRequires] {
        foreach cmp $compRequires($cn) {
            if { $cmp != $cn } {
               lappend compRequires1($cn) $cmp
            }
        }
    }

    set prevComp $component
    set postList {}
    set dup  0
    set printed {}
    cxrEach $component compRequires1 $prevComp $postList misCompsObj $dup $opt printed

}

proc extractCMs { allSet exSet included docType} {

      $exSet = [$allSet - $included]
      $allSet = [$allSet - [$exSet instances $docType]]
}


###############################################################################
#
# cxrDocValidate - validate a cxr document
#
# SYNOPSIS
# \cs
#   cxrDocValidate <hProj> [<components> [<buildTest>]]
# \ce
#
# DESCRIPTION
# This routine can be used by component authors to validate .cdf files:
# * every Component, Selection, and Folder is the child of
#   exactly one other (except for FOLDER_ROOT and FOLDER_HIDDEN).
# * every InitGroup and component with an INIT_ROUTINE is in exactly one
#   InitGroup (except for usrRoot and usrInit), and
#   every item in an InitGroup has an InitRtn
# * all configlettes, modules, header files, and linkSyms exist
# * every component with an initRtn or configlette can build
#
# PARAMETERS:
#   hProj : handle of the project to check component configuration for
#   components : list of components to test
#   buildTest : tell if build tests should also be performed
#
# RETURNS: N/A
#
# ERRORS: N/A
#

proc cxrDocValidate {hProj {components ""} {buildTest ""}} {

    set cxrDoc [cxrDocCreate $hProj]
    set mxrDoc [mxrDocCreate $hProj]
    set prjDir [file dirname [prjInfoGet $hProj fileName]]
    set bspDir [prjTagDataGet $hProj BSP_DIR]

    if {$components == ""} {
	set components [format "%s" [$cxrDoc instances Component]]
    }

    set objSet		[$cxrDoc setCreate]
    set moduleSet	[$mxrDoc setCreate]
    set srcDir		[file join [Wind::tgtDir] config comps src]
    set hDir		[file join [Wind::tgtDir] h]
    set netDir		[file join $hDir wrn coreip]

    puts "checking for unresolved object references..."

    $objSet = [$cxrDoc instances Component]
    $objSet = [$objSet get CFG_PARAMS]

    set unresolved		[$cxrDoc instances Unresolved]
    set unresolvedParams	[$objSet & $unresolved]

    $objSet = $unresolved

    set unresolved [lrange [lsort [$objSet - $unresolvedParams]] 1 end]

    if {$unresolved != ""} {
	puts "ERROR: unresolved objects :"
	foreach elt $unresolved {
	    puts [format "    %s" $elt]
	}
    }

    if {$unresolvedParams != ""} {
	puts "ERROR: unresolved Parameters :"

	foreach elt [lsort $unresolvedParams] {
	    puts [format "    %s" $elt]
	}
    }
    puts "done\n"

    puts "checking that all objects are contained in exactly one folder..."

    $objSet = $components
    $objSet = [format "%s" [$objSet + [format "%s" [$cxrDoc instances Folder]]]]
    $objSet = [format "%s" [$objSet + [format "%s" [$cxrDoc instances \
							    Selection]]]]

    foreach object [$objSet instances] {

	$objSet = $object

	set containers [$objSet get _CHILDREN]

	if {[llength $containers] == 0} {
	    if {"$object" == "FOLDER_ROOT"} {
	        continue
	    }
	    puts "ERROR: $object belongs to no containers"
	}

	if {[llength $containers] > 1} {
	    puts "ERROR: $object belongs to $containers"
	}
    }

    puts "done\n"

    puts "checking that all objects belong to exactly one InitGroup..."

    $objSet = $components

    set objects [$objSet + [$cxrDoc instances InitGroup]]

    foreach object $objects {

	if {($object == "usrInit") || ($object == "usrRoot")} {
	    continue
	}

	$objSet = $object

	set initRtn [format "%s" [$objSet get INIT_RTN]]

	if {$initRtn == ""} {
	    if {([format "%s" [$objSet types]] == "InitGroup")} {
		puts "ERROR: InitGroup $object has no INIT_RTN"
	    }
	    continue
	}

       # WIND00022923 fixed wrong error message

        set containers [format "%s" [$objSet get _INIT_ORDER]]
        if {[llength $containers] == 0} {
            # check if the component with the same inital routine
            # belongs to one of InitGroup  with _INIT_ORDER
            if { [format "%s" [$objSet types]] == "InitGroup"} {
                set found 0
                foreach cmp $components {
                    $objSet =  $cmp
                    if { [string first $object [format "%s" [$objSet get INIT_RTN]]] != -1} {
                        set isInGrp [format "%s" [$objSet get _INIT_ORDER]]
                        if { [llength $isInGrp] != 0 } {
                            set found 1
                            break
                        }
                    }
                }
                if { !$found } {
                    puts "ERROR: $object belongs to no InitGroup"
                }
            } else {
                puts "ERROR: $object belongs to no InitGroup"

            }
        } elseif {[llength $containers] > 1} {
	        puts "ERROR: $object belongs to $containers"
        }
    }
    puts "done\n"

    puts "checking that all components have a NAME..."

    foreach component [concat $components \
			      [format "%s" [$cxrDoc instances Folder]] \
			      [format "%s" [$cxrDoc instances Selection]]] {

	$objSet = $component

	if {[format "%s" [$objSet get NAME]] == $component} {
	    puts "ERROR: $component has no NAME"
	}
    }
    puts "done\n"

    puts "checking that all component software exists..."
    $objSet = $components

    set bspStubs	[format "%s" [$objSet get BSP_STUBS]]
    set configlettes	[join [format "%s" [$objSet get CONFIGLETTES]]]
    set headers		[join [format "%s" [$objSet get HDR_FILES]]]
    set linkSyms	[format "%s" [$objSet get LINK_SYMS] \
				     [$objSet get  LINK_DATASYMS]]
    set modules		[format "%s" [$objSet get MODULES]]

    # SPR#94279 : make it possible to use macros/environment variables in
    # configlettes declarations

    set configlettes	[prjConfigletteExpand $hProj $configlettes]

    # check the BSP stubs

    set bad ""

    foreach stub $bspStubs {
	if { ![file exists [file join $srcDir $stub]]} {
	    lappend bad $stub
	}
    }

    if {$bad != ""} {

	puts "ERROR: missing BSP_STUB's :"

	foreach elt $bad {
	    puts [format "    %s" $elt]
	}

	set bad ""
    }

    # check the configlettes

    foreach configlette $configlettes {

	if {(![file exists [file join $srcDir $configlette]]) && \
	    (![file exists $configlette])} {

	    lappend bad $configlette
	}
    }

    if {$bad != ""} {
	puts "ERROR: missing CONFIGLETTE's :"
	foreach elt $bad {
	    puts [format "    %s" $elt]
	}
	set bad ""
    }

    # check the header files

    foreach header $headers {
	if {(![file exists [file join $hDir $header]]) &&
	    (![file exists [file join $bspDir $header]]) && \
	    (![file exists [file join $netDir $header]]) && \
	    (![file exists $header])} {

	    lappend bad $header
	}
    }

    if {$bad != ""} {
	puts "ERROR: missing HDR_FILE's :"
	foreach elt $bad {
	    puts [format "    %s" $elt]
	}
	set bad ""
    }

    # check the modules

    foreach module $modules {
	$moduleSet = $module
	if {[format "%s" [$moduleSet instances Module]] != $module} {
	    lappend bad $module
	}
    }

    if {$bad != ""} {
	$objSet = $bad
	$objSet = [$objSet get _MODULES]
	puts "WARNING: components not installed:"
	foreach elt [lsort [format %s [$objSet contents]]] {
	    puts [format "    %s" $elt]
	}
	puts "WARNING: missing MODULE's :"
	foreach elt [lsort $bad] {
	    puts [format "    %s" $elt]
	}
	set bad ""
    }

    # check for the link symbols

    foreach linkSym [cSymsMangle $linkSyms [mxrTcGet $mxrDoc]] {
	$moduleSet = $linkSym
	if {[format "%s" [$moduleSet instances Symbol]] != $linkSym} {
	    lappend bad $linkSym
	}
    }

    if {$bad != ""} {
	puts "ERROR: missing LINK_SYMS's :"
	foreach elt [lsort $bad] {
	    puts [format "    %s" $elt]
	}
    }
    puts "done\n"

    # shall we try to build the components too ?

    if {$buildTest == ""} {
	$objSet delete
	return
    }

    puts "checking that all components can build..."

    set prjDir [file dirname [prjInfoGet $hProj fileName]]
    set badList ""
    set wcc [wccCurrentGet $hProj]
    foreach component $components {
	$objSet = $component
	set missingParams ""
	foreach param [$objSet get CFG_PARAMS] {
	    if {[wccParamGet $hProj $wcc $param] == ""} {
		lappend missingParams $param
	    }
	}
	if {[llength $missingParams] > 0} {
	    puts "WARNING: skipping $component because it needs the following"
	    puts "parameters, but they have no default values: $missingParams\n"
	    continue
	}
	::prj_vxWorks_hidden::configGen $hProj $component
	set prjType [prjTypeGet $hProj]
	set info [::${prjType}::buildCmdGet $hProj prjConfig.o]
	set cmd [lindex $info 0]
	set buildDir [lindex $info 1]

	set dir [pwd]
	cd $buildDir
	if {[catch "eval exec $cmd" errMsg]} {
	    puts $errMsg
	    file delete [file join $prjDir $component.c]
	    file rename [file join $prjDir prjConfig.c] \
			[file join $prjDir $component.c]
	    lappend badList $component
	}

        cd $dir
	continue
    }

    if {[llength $badList] > 0} {
	puts "Summary of failures: $badList"
    }

    puts "done\n"

    $objSet delete
}

###############################################################################
#
# wccDependsGet - compute the dependancies of a component configuration
#
# SYNOPSIS
# \cs
#   wccDependsGet <hProj> <wcc> [<component>] [<option>]
# \ce
#
# DESCRIPTION
# This procedure computes the dependencies of a component configuration.
#
# PARAMETERS:
#   hProj : handle of the project to get dependancies for
#   wcc : component configuration to get dependancies for
#   component : component to get dependencies for
#   option : if set to 'extended', not only the components depending on
#            <component> are returned, but also the more info on dependencies,
#            and the components depending on <component>
#
# RETURNS: The list of dependancies for this configuration
#
# SEE ALSO: cxrDocCreate, mxrDocCreate, wccComponentListGet
#

proc wccDependsGet {hProj wcc {component ""} {option ""}} {

    set cxrDoc [cxrDocCreate $hProj]
    set mxrDoc [mxrDocCreate $hProj]
    set cmpSet [$cxrDoc setCreate]
    set cmpSubtree [$cxrDoc setCreate]

    if {$component != ""} {
	$cmpSet = $component
    } else {
	$cmpSet = [wccComponentListGet $hProj $wcc]
    }

    if {$option == "extended"} {
	set subTree [cxrSubtree $cmpSet $mxrDoc "" $option]
	set cmpSupertree [format "%s" [cxrSupertree $cmpSet $mxrDoc "" $option]]
    } else {
	$cmpSubtree = [format "%s" [cxrSubtree $cmpSet $mxrDoc]]
    }

    # XXX : fle : since we switched to Tcl 8.4, it seems like the DataDocs
    # manipulations may do things wrong. The DataDocs internal representations
    # mey be wrong. To be sure to get a valid result, we have to give it the
    # string type. This can be achieved by a call to format ...

    if {$option == "extended"} {

	# as cmpSupertree and cmpSubtree do not return only component lists
	# when using the extended mode, we have to extract the lists from the
	# cmpSet

	set subDeps	{}
	set superDeps	{}
	set comps	[format "%s" [$cmpSet instances]]

	# get sub dependencies

	foreach subDep $subTree {
	    if {[lsearch -exact $comps [lindex $subDep 0]] == -1} {
		lappend subDeps $subDep
	    }
	}

	# get super dependencies

	foreach superDep $cmpSupertree {
	    if {[lsearch -exact $comps [lindex $superDep 0]] == -1} {
		lappend superDeps $superDep
	    }
	}

	set dependancies [list $subDeps $superDeps]

    } else {
	set dependancies [format "%s" [$cmpSubtree - [$cmpSet instances]]]
    }

    $cmpSet delete
    $cmpSubtree delete

    return $dependancies
}

################################################################################
#
# wccValidate - validate a component configuration
#
# SYNOPSIS
# \cs
#   wccValidate <hProj> <wcc>
# \ce
#
# DESCRIPTION
# Validate a component configuration
#
# PARAMETERS:
#   hProj : handle of the project to check component configuration for
#   wcc : component configuration to test
#
# RETURNS: Validation information
#
# ERRORS: N/A
#

proc wccValidate {hProj wcc} {
    set d [cxrDocCreate $hProj]
    set s [$d setCreate]
    set wcc [wccCurrentGet $hProj]
    $s = [wccComponentListGet $hProj $wcc]

    # find components that are misconfigured

    set info [cxrSetValidate $s]

    # find all Components that have undefined Parameters

    foreach component [wccComponentListGet $hProj $wcc] {
	set params ""
	$s = $component
	$s = [$s get CFG_PARAMS]
	foreach param [$s instances Parameter] {
	    if {[wccParamGet $hProj $wcc $param] == ""} {
		lappend params $param
	    }
	}
	if {$params != ""} {
	    lappend info "$component {undefined parameters $params}"
	}
    }

    # find all missing dependencies

    $s = [wccComponentListGet $hProj $wcc]
    $s = [cxrSubtree $s [mxrDocCreate $hProj] minimal]
    $s = [$s - [wccComponentListGet $hProj $wcc]]
#    foreach cmp [$s instances Component] {
#        lappend info "$cmp {needs to be included}"
#    }

    # Cache the error status for anyone interested
    if {$info == ""} {
	set status 0
    } else {
	set status 1
    }
    wccErrorStatusSet $hProj $status

    $s delete
    return $info
}

################################################################################
#
# wccErrorStatusSet - cache whether or not this project has configuration errors
#
# SYNOPSIS
# \cs
#   wccErrorStatusSet <hProj> <status>
# \ce
#
# DESCRIPTION
# Cache whether or not this project has configuration errors
#
# PARAMETERS:
#   hProj : handle of the project to set wcc error status for
#   status : component configuration status to set to
#
# RETURNS: N/A
#
# ERRORS: N/A
#
# SEE ALSO: prjTagDataSet, prjTagDataGet
#

proc wccErrorStatusSet {hProj status} {
    set oldStatus [::prjTagDataGet $hProj COMPONENT_ERROR_STATUS]
    if {$oldStatus != $status} {
	::prjTagDataSet $hProj COMPONENT_ERROR_STATUS $status
    }
}

###############################################################################
#
# wccErrorStatusGet - Get the Component Configuration error status
#
# SYNOPSIS
# \cs
#   wccErrorStatusGet <hProj>
# \ce
#
# DESCRIPTION
# Get the component configuration erros status
#
# PARAMETERS:
#   hProj : handle of the kernel configuration project to get error status for
#
# RETURNS: '0' if there is no component configuration error, '-1' else.
#
# ERRORS: N/A
#
# SEE ALSO: prjTagDataGet
#

proc wccErrorStatusGet {hProj} {
    set status [::prjTagDataGet $hProj COMPONENT_ERROR_STATUS]
    if {$status == ""} {
	set status -1
    }
    return $status
}

###############################################################################
#
# wccParamCheck_uint - typecheck a uint parameter
#
# SYNOPSIS
# \cs
#   wccParamCheck_uint <param>
# \ce
#
# DESCRIPTION
# Check if type of <param> is <uint>
#
# PARAMETERS:
#   param : parameter to check <uint> type for
#
# RETURNS: Nothing, or "bad value <param> - must be a non-negative integer" if
# the parameter was found to be negative
#
# ERRORS: N/A
#
# SEE ALSO: wccParamCheck_exists, wccParamCheck_bool
#

proc wccParamCheck_uint param {
    if {[catch "expr $param >= 0" val]} {
	# A hack: if we get a string value like (A + B),
	# expr doesn't handle it, so we look for the error string
	# from the catch statement instead
	if {![regexp {^syntax error.*} $val dummy]} {
	    set val "bad value $param - must be a non-negative integer"
	} else {
	    set val ""
	}
    } elseif {$val == 0} {
	return "bad value $param - must be a non-negative integer"
    } else {
	set val ""
    }
}

###############################################################################
#
# wccParamCheck_exists - typecheck an "exists" type parameter
#
# SYNOPSIS
# \cs
#   wccParamCheck_exists <param>
# \ce
#
# DESCRIPTION
# Check if type of <param> is of type <exists>
#
# PARAMETERS:
#   param : parameter to check <exists> type for
#
# RETURNS: Nothing, or "bad value <param> - must be a non-negative integer" if
# the parameter value was found to be different from 'TRUE' or 'FALSE'
#
# ERRORS: N/A
#
# SEE ALSO: wccParamCheck_bool, wccParamCheck_uint
#

proc wccParamCheck_exists param {
    if {("$param" != "TRUE") && ("$param" != "FALSE")} {
	return "bad value $param - must be either TRUE or FALSE"
    }
}

###############################################################################
#
# wccParamCheck_bool - typecheck a "bool" type parameter
#
# SYNOPSIS
# \cs
#   wccParamCheck_bool <param>
# \ce
#
# DESCRIPTION
# Check if type of <param> is <bool>
#
# PARAMETERS:
#   param : parameter to check <bool> type for
#
# RETURNS: Nothing, or "bad value <param> - must be a non-negative integer" if
# the parameter value was found to be different from 'TRUE', '1', 'FALSE' or '0'
#
# ERRORS: N/A
#
# SEE ALSO: wccParamCheck_uint, wccParamCheck_exists
#

proc wccParamCheck_bool param {
    if {("$param" != "TRUE") && ("$param" != "FALSE") && \
        ("$param" != "1") && ("$param" != "0")} {
	return "bad value $param - must be either TRUE or FALSE"
    }
}

###############################################################################
#
# wccComponentLoad - dynamically load components
#
# SYNOPSIS
# \cs
#   wccComponentLoad <hProj> <compList> [<appModules>]
# \ce
#
# DESCRIPTION
# Dynamically loads components. This requires the Wtx facilities.
#
# PARAMETERS:
#   hProj : handle of the project to load components for
#   compList : list of components to load modules to target
#   appModules : list of application modules to load to the target
#
# RETURNS: N/A
#
# ERRORS: N/A
#
# PACKAGES:
# \is
# \i Wtx
# The Wind River transmistion package. This allows to connect to the target
# sever and load the modules and applications to the target
# \ie
#
# SEE ALSO: wtxMemRead, wtxSymFind, wtxObjModuleList, wtxSymListGet,
# wtxMemAlloc, wtxMemSet, wtxSymAdd, wtxFuncCall, wtxObjModuleLoad,
# wtxDirectCall, wtxMemWrite
#

proc wccComponentLoad {hProj compList {appModules ""}} {

    # here we need the wtxtcl library. If it is not already loaded, load it.

    package require Wtx

    wtxMemRead [lindex [wtxSymFind -name vxTicks] 1] 4

    set dynLoadIx [llength [wtxObjModuleList]]
    set dynLoadFile dynLoad${dynLoadIx}
    set libs ""
    foreach lib [wccMxrLibsGet $hProj] {
	lappend libs [file join [Wind::tgtDir] lib $lib]
    }
    set wcc [wccCurrentGet $hProj]
    set build [prjBuildCurrentGet $hProj]
    set tc [prjBuildTcGet $hProj $build]
    set ar [prjBuildMacroGet $hProj $build AR]
    set tool_cc [${tc}::toolFindByFile foo.c]
    set tool_ld [${tc}::toolFindByType linker]
    set cflags [prjBuildFlagsGet $hProj $build ${tool_cc}]

    set cc [set ${tool_cc}::tool]
    set ld [set ${tool_ld}::tool]

    # compute the loaded modules

    prjStatusLog "computing already loaded modules..."
    set symList ""
    foreach symInfo [wtxSymListGet -name .*] {
	lappend symList [lindex $symInfo 0]
    }
    set mxrDoc [mxrDocCreate $hProj]
    set mxrSet [$mxrDoc setCreate]
    $mxrSet = $symList
    set loadedModules [$mxrSet get exportedBy]

    # compute the loaded components

    prjStatusLog "computing already loaded components..."
    set cxrDoc [cxrDocCreate $hProj]
    set cxrSet [$cxrDoc setCreate]
    $cxrSet = $loadedModules
    $cxrSet = "[wccComponentListGet $hProj $wcc] [$cxrSet get _MODULES]"
    set loadedComponents [cxrSubtree $cxrSet $mxrDoc]

    # compute required components for compList

    prjStatusLog "computing components needed..."
    $cxrSet = $compList
    $cxrSet = [cxrSubtree $cxrSet $mxrDoc]
    $cxrSet = [$cxrSet - $loadedComponents]

    set symTblInit [expr {[lsearch [$cxrSet get REQUIRES] SELECT_SYMTBL_INIT]} \
			 >= 0]

    set requiredComponents [$cxrSet instances]
    prjStatusLog "requiredComponents = [lsort $requiredComponents]"

    # compute required modules for compList

    prjStatusLog "computing modules needed..."
    $mxrSet = "[$cxrSet get LINK_SYMS] [$cxrSet get LINK_DATASYMS]"
    $mxrSet = "[$mxrSet get defines] [$cxrSet get MODULES]"
    $mxrSet = [mxrSubtree $mxrSet]
    set requiredModules [$mxrSet - $loadedModules]
    prjStatusLog "requiredModules = [lsort $requiredModules]"

    # generate the configuration code needed for the components

    if {"$requiredComponents" == ""} {
	set requiredComponents BOGUS_COMPONENT
    }
    ::prj_vxWorks_hidden::configGen $hProj $requiredComponents

    # extract required modules from the archive and link them together

    prjStatusLog "creating $dynLoadFile..."
    set prjDir [file dirname [prjInfoGet $hProj fileName]]
    set origDir [pwd]
    cd $prjDir
    if {"$requiredModules" != ""} {
	eval exec $ar -x $libs $requiredModules
    }

    set ldPartialFlags [prjBuildMacroGet $hProj $build LD_PARTIAL_FLAGS]
    if {"$ldPartialFlags" == ""} {
	set ldPartialFlags "-r"
    }
    eval exec $cc $cflags -c prjConfig.c
    eval exec $ld $ldPartialFlags prjConfig.o $requiredModules \
		$appModules -o $dynLoadFile
    cd $origDir

    # add missing common block symbols as needed

    if {"[${tc}::::commSymLink]" == "symbol"} {
	prjStatusLog "adding missing common block symbols..."

	$mxrSet = [$mxrDoc instances Module]
	set commSyms [$mxrSet get declares]

	set d [mxrDataDocCreate $tc $prjDir/$dynLoadFile]
	set s [$d setCreate]
	$s = [$d instances Module]
	$mxrSet = [$s get imports]
	$s delete
	$d delete

	$mxrSet = [$mxrSet contents]		;# undefed syms in dynLoadFile
	$mxrSet = [$mxrSet - $symList]		;# remove already loaded syms
	$mxrSet = [$mxrSet & $commSyms]		;# only add common block syms

	foreach sym [$mxrSet instances] {
	    puts -nonewline "$sym "
	    $mxrSet = $sym
	    set size [$mxrSet get size]
	    set addr [wtxMemAlloc $size]
	    wtxMemSet $addr $size 0
	    wtxSymAdd $sym $addr 0x11
	}
	puts ""
    }

    prjStatusLog "loading $dynLoadFile..."
    set usrRootAddr [lindex [wtxSymFind -name usrRoot] 1]
    set ldFlags "LOAD_COMMON_MATCH_ALL|LOAD_GLOBAL_SYMBOLS"
    set badSyms [lrange [wtxObjModuleLoad $ldFlags $prjDir/$dynLoadFile] 4 end]
    if {[llength $badSyms] > 0} {
        puts "warning: module contains undefined symbols:"
        puts $badSyms
    } else {
	set newUsrRootAddr [lindex [wtxSymFind -name usrRoot] 1]
	if {"$newUsrRootAddr" != "$usrRootAddr"} {
	    if {[llength $badSyms] > 0} {
		puts "skipping initialization call to usrRoot"
	    } else {
		prjStatusLog "calling usrRoot..."
		wtxFuncCall $newUsrRootAddr
		prjStatusLog "done"
	    }
	}
    }

    # initialize the target symbol table as needed

    set sysSymTblAddr [lindex [wtxSymFind -name sysSymTbl] 1]
    set memBlk [wtxMemRead $sysSymTblAddr 4]
    set sysSymTbl [memBlockGet -l $memBlk]
    memBlockDelete $memBlk
    if {($symTblInit) && ($sysSymTbl == 0)} {
	prjStatusLog "initializing the target symbol table..."
	set symTblCreateRtn [lindex [wtxSymFind -name symTblCreate] 1]
	set memSysPartIdAddr [lindex [wtxSymFind -name memSysPartId] 1]
	set memBlk [wtxMemRead $memSysPartIdAddr 4]
	set memSysPartId [memBlockGet -l $memBlk]
	memBlockDelete $memBlk
	set hashSizeLog2 8
	set sysSymTbl [wtxDirectCall $symTblCreateRtn $hashSizeLog2 \
		1 $memSysPartId]

	set memBlk [memBlockCreate]
	memBlockSet -l $memBlk 0 $sysSymTbl
	wtxMemWrite $memBlk $sysSymTblAddr
	memBlockDelete $memBlk

	set symAddRtn [lindex [wtxSymFind -name symAdd] 1]
	set symNameAddr [wtxMemAlloc 100]

	set symInfoList [wtxSymListGet -name .*]
	prjStatusLog "adding [llength $symInfoList] symbols..."
	set ix 0
	foreach symInfo $symInfoList {
	    incr ix
	    if {($ix % 100) == 0} {
		prjStatusLog " $ix"
	    }
	    set symNameMemBlock [memBlockCreate -string [lindex $symInfo 0]]
	    wtxMemWrite $symNameMemBlock $symNameAddr
	    memBlockDelete $symNameMemBlock
	    set symVal  [lindex $symInfo 1]
	    set symType [lindex $symInfo 2]
	    set symGrp  [lindex $symInfo 3]
	    wtxDirectCall $symAddRtn $sysSymTbl $symNameAddr $symVal \
		$symType $symGrp
	}
    }

    # done

    prjStatusLog "done"
    foreach file [glob -nocomplain $prjDir/*.o $prjDir/prj*.*] {
	file delete -force $file
    }
    $mxrSet delete
    $cxrSet delete
}


