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

function mex_hmg(varargin)

rebuild = false;

% Check for force flag
if nargin > 0
    if ischar(varargin{1}) && strcmp(varargin{1}, '-f')
        rebuild = true;
    end
end

%-------------------------------------------------------------------------------------------
%      Store location to allow calling from anywhere
%-------------------------------------------------------------------------------------------
currentpwd = pwd;
[pathstr, ~, ~] = fileparts(which('mex_hmg.m'));
cd(pathstr);

%-------------------------------------------------------------------------------------------
%      Get information about the OpenCV sources
%-------------------------------------------------------------------------------------------
opencv_dir= fullfile(getenv('NIMBUS_ROOT'),'externals','minopencv');
opencv_headers = dir(fullfile(opencv_dir, 'include', 'opencv2', '*.h*'));
opencv_sources = dir(fullfile(opencv_dir, '*.cpp'));
opencv_header_paths = fullfile(opencv_dir, 'include', 'opencv2', {opencv_headers.name});
opencv_source_paths = fullfile(opencv_dir, {opencv_sources.name});

%-------------------------------------------------------------------------------------------
%      Build up overall mex sources info and generate a mex dependency list
%-------------------------------------------------------------------------------------------
mex_headers = ['hmg_obj.h' 'sfun_hmg_wrapper.h' opencv_header_paths];
mex_sources = ['sfun_hmg.cpp' 'sfun_hmg_wrapper.cpp' 'hmg_obj.cpp' opencv_source_paths];
mex_deps = [mex_headers mex_sources];

%-------------------------------------------------------------------------------------------
%      Get mex modified date and determine if rebuild is necessary
%-------------------------------------------------------------------------------------------
mex_info = dir(which('sfun_hmg'));

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

%-------------------------------------------------------------------------------------------
%      Compile S-Function
%-------------------------------------------------------------------------------------------
if rebuild
    % Link with librt if available
    if isunix
        fclose(fopen('temp.c', 'w'));
        try
            mex -lrt temp.c
            link_opts = '-lrt';
        catch
            link_opts = '';
        end
        delete('temp.c');
    else
        link_opts = '';
    end
    
    fprintf('### Compiling sfun_hmg....\n');
    evalin('base',['mex -I"' opencv_dir filesep 'include" -I"' opencv_dir filesep 'include' filesep 'minopencv2" ' link_opts ' "' strjoin(mex_sources, '" "') '"']);
end

%-------------------------------------------------------------------------------------------
%      Return to previous location
%-------------------------------------------------------------------------------------------
cd(currentpwd);

end