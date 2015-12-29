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

function mex_tcp(varargin)

rebuild = false;

% Check for force flag
if nargin > 0
    if ischar(varargin{1}) && strcmp(varargin{1}, '-f')
        rebuild = true;
    end
end

%-----------------------------------------------------------
%       Save original directory to return to later
%-----------------------------------------------------------
currentpwd = pwd;
[pathstr, name, ext] = fileparts(which('mex_tcp.m'));
cd(pathstr);

%-----------------------------------------------------------
%       Set up platform-specific defines and linker opts
%-----------------------------------------------------------
if ispc
    link_opts = 'LINKFLAGS="$LINKFLAGS /GS-"';
else
    link_opts = '-g';
end

%-------------------------------------------------------------------------------------------
%      Build up overall mex sources info and generate a mex dependency list
%-------------------------------------------------------------------------------------------
mex_headers = {'tcp_obj.h' 'sfun_tcp_wrapper.h' 'ServerUtils.h'};
mex_sources = {'sfun_tcp.cpp' 'sfun_tcp_wrapper.cpp' 'tcp_obj.cpp'};
mex_deps = [mex_headers mex_sources];

%-------------------------------------------------------------------------------------------
%      Get mex modified date and determine if rebuild is necessary
%-------------------------------------------------------------------------------------------
mex_info = dir(which('sfun_tcp'));

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

%-----------------------------------------------------------
%       Save original for whatever
%-----------------------------------------------------------
if rebuild
    fprintf(1,'### Compiling sfun_tcp...\n');
    evalin('base',['mex ' link_opts ' ' strjoin(mex_sources)]); 
end

%-------------------------------------------------------------------------------------------
%      Return to previous location
%-------------------------------------------------------------------------------------------
cd(currentpwd);

end
