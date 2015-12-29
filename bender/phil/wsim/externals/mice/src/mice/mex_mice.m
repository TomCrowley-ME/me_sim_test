%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2010 - 2015 Moon Express, Inc.
% All Rights Reserved.
%
% PROPRIETARY DATA NOTICE:
% The data herein include Proprietary Data and are restricted under the
% Data Rights provisions of Lunar CATALYST Space Act Agreement
% No. SAAM ID# 18251 and Reimbursable Space Act Agreement No.SAA2-402930.
% All information contained herein is and remains proprietary to and the
% property of Moon Express, Inc. Dissemination of this information or
% reproduction of this material is strictly forbidden unless prior
% written permission is obtained from Moon Express, Inc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mex_mice(varargin)

rebuild = false;

% Check for force flag
if nargin > 0
    if ischar(varargin{1}) && strcmp(varargin{1}, '-f')
        rebuild = true;
    end
end

% Switch to mice directory for building
currentpwd = pwd;
pathstr = fullfile(getenv('NIMBUS_ROOT'),'externals','mice','src','mice');
cd(pathstr);

% Determine OS information to make F2C happy
switch mexext
    case 'mexa64'
        platform_def = '-DCSPICE_PC_LINUX_64BIT_GCC';
    case 'mexmaci64'
        platform_def = '-DCSPICE_MAC_OSX_INTEL_64BIT_GCC';
    case 'mexw64'
        platform_def = '-DCSPICE_PC_64BIT_MS';
    case 'mexw32'
        platform_def = '-DCSPICE_PC_MS';
    otherwise
        error('CSPICE building not yet supported on your platform! (Go yell at Mike)');
end

% Set up platform-specific defines and linker opts
if ispc
    os_defs = '-D__STDC__ -D_COMPLEX_DEFINED -DMSDOS -DOMIT_BLANK_CC -DNON_ANSI_STDIO';
    link_opts = 'LINKFLAGS="$LINKFLAGS /NODEFAULTLIB:libcmt.lib"';
else
    os_defs = '-DNON_UNIX_STDIO -Dunix';
    link_opts = '';
end

% Get information about the CSPICE sources
cspice_headers = dir('../../include/*.h');
cspice_sources = dir('../cspice/*.c');
cspice_header_paths = fullfile('..', '..', 'include', {cspice_headers.name});
cspice_source_paths = fullfile('..', 'cspice', {cspice_sources.name});

% Build up overall mex sources info and generate a mex dependency list
mex_headers = ['cspice_params.h' 'mice.h' 'npf_cspice.h' 'zzmice.h' cspice_header_paths];
mex_sources = ['mice.c' 'zzmice.c' 'zzmice_CreateIntScalar.c' cspice_source_paths];
mex_deps = [mex_headers mex_sources];

% Get modified date for our mex file
mex_info = dir(which('mice'));

if ~isempty(mex_info)
    % Check to see if any dependency file has a newer modified date than
    % the mex file
    for i=1:length(mex_deps)
        file_info =  dir(mex_deps{i});
        if file_info.datenum > mex_info.datenum
            rebuild = true;
            break;
        end
    end
else
    % mex file doesn't exist in the first place, so we need to build it
    rebuild = true;
end

if rebuild
    % Go!
    fprintf(1,'### Compiling mice...\n');
    evalin('base',['mex -outdir ../../lib -I../../include ' link_opts ' ' os_defs ' ' platform_def ' ' strjoin(mex_sources)]);
end

% Change back to where we started from
cd(currentpwd);

end
