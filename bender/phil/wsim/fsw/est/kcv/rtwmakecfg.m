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

function makeInfo = rtwmakecfg()
%RTWMAKECFG adds include and source directories to the make files.
%   makeInfo=RTWMAKECFG returns a structured array containing build info.
%   Please refer to the rtwmakecfg API section in the Simulink Coder
%   documentation for details on the format of this structure.
%
%   Simulink version    : 8.2 (R2013b) 08-Aug-2013
%   MATLAB file generated on : 11-Nov-2013 16:50:42

% Verify the Simulink version
verify_simulink_version();

% Get the current directory
currDir = pwd;

% Get the MATLAB search paths and remove the toolbox sub-directories except simfeatures
pSep = pathsep;
matlabPaths = regexp([matlabpath pSep], ['.[^' pSep ']*' pSep], 'match');
if ~isempty(matlabPaths)
    filteredPathIndices = strncmp(fullfile(matlabroot,'toolbox'), matlabPaths, numel(fullfile(matlabroot,'toolbox')));
    lctPath = fileparts(which('sldemo_lct_builddemos'));
    if ~isempty(lctPath)
        filteredPathIndices(strncmp([lctPath pSep], matlabPaths, numel([lctPath pSep]))) = 0;
    end
    lctPath = fileparts(which('rtwdemo_lct_builddemos'));
    if ~isempty(lctPath)
        filteredPathIndices(strncmp([lctPath pSep], matlabPaths, numel([lctPath pSep]))) = 0;
    end
    matlabPaths(filteredPathIndices) = [];
    matlabPaths = strrep(matlabPaths, pSep, '');
end

% Declare cell arrays for storing the paths found
allIncPaths = {};
allSrcPaths = {};


% Get the serialized paths information
info = get_serialized_info();

% Get all S-Function's name in the current model
sfunNames = {};
if ~isempty(bdroot)
    sfunBlks = find_system(bdroot,...
        'LookUnderMasks', 'all',...
        'FollowLinks', 'on',...
        'BlockType', 'S-Function'...
    );
    sfunNames = get_param(sfunBlks, 'FunctionName');
end

for ii = 1:length(info)
    % If the S-Function isn't part of the current build then skip its path info
    if isempty(strmatch(info(ii).SFunctionName, sfunNames, 'exact'))
        continue
    end

    % Path to the S-function source file
    if strcmp(info(ii).Language, 'C')
        fext = '.c';
    else
        fext = '.cpp';
    end
    pathToSFun = fileparts(which([info(ii).SFunctionName,fext]));
    if isempty(pathToSFun)
        pathToSFun = currDir;
    end

    % Default search paths for this S-function
    defaultPaths = [{pathToSFun} {currDir}];
    allPaths = [defaultPaths matlabPaths];

    % Verify if IncPaths are absolute or relative and then complete
    % relative paths with the full S-function dir or current dir or MATLAB path
    incPaths = info(ii).IncPaths;
    for jj = 1:length(incPaths)
        [fullPath, isFound] = resolve_path_info(correct_path_sep(incPaths{jj}), allPaths);
        if (isFound==0)
            DAStudio.error('Simulink:tools:LCTErrorCannotFindIncludePath',...
                incPaths{jj});
        else
            incPaths{jj} = fullPath;
        end
    end
    incPaths = [incPaths defaultPaths];

    % Verify if SrcPaths are Absolute or Relative and then complete
    % relative paths with the full S-function dir or current dir or MATLAB path
    srcPaths = info(ii).SrcPaths;
    for jj = 1:length(srcPaths)
        [fullPath, isFound] = resolve_path_info(correct_path_sep(srcPaths{jj}), allPaths);
        if (isFound==0)
            DAStudio.error('Simulink:tools:LCTErrorCannotFindSourcePath',...
                srcPaths{jj});
        else
            srcPaths{jj} = fullPath;
        end
    end
    srcPaths = [srcPaths defaultPaths];

    % Common search paths for Source files specified with path
    srcSearchPaths = [srcPaths matlabPaths];

    % Add path to source files if not specified and complete relative
    % paths with the full S-function dir or current dir or search
    % paths and then extract only the path part to add it to the srcPaths
    sourceFiles = info(ii).SourceFiles;
    pathFromSourceFiles = cell(1, length(sourceFiles));
    for jj = 1:length(sourceFiles)
        [fullName, isFound] = resolve_file_info(correct_path_sep(sourceFiles{jj}), srcSearchPaths);
        if isFound==0
            DAStudio.error('Simulink:tools:LCTErrorCannotFindSourceFile',...
                sourceFiles{jj});
        else
            % Extract the path part only
            [fpath, fname, fext] = fileparts(fullName);
            pathFromSourceFiles{jj} = fpath;
        end
    end
    srcPaths = [srcPaths pathFromSourceFiles];

    % Concatenate known include and source directories
    allIncPaths = RTW.uniquePath([allIncPaths incPaths]);
    allSrcPaths = RTW.uniquePath([allSrcPaths srcPaths]);

end

% Additional include directories
makeInfo.includePath = correct_path_name(allIncPaths);

% Additional source directories
makeInfo.sourcePath = correct_path_name(allSrcPaths);

%--------------------------------------------------------------------------
function verify_simulink_version()

% Retrieve Simulink version
slVer = ver('simulink');
factor = 1.0;
thisVer = 0.0;
for ii = 1:length(slVer.Version)
    if slVer.Version(ii)=='.'
        factor = factor/10.0;
    else
        thisVer = thisVer + sscanf(slVer.Version(ii), '%d')*factor;
    end
end

% Verify that the actual plateform supports the function used
if thisVer < 6.4
    DAStudio.error('Simulink:tools:LCTErrorBadSimulinkVersion', sprintf('%g',thisVer))
end


%--------------------------------------------------------------------------
function [fullPath, isFound] = resolve_path_info(fullPath, searchPaths)

% Initialize output value
isFound = 0;

if is_absolute_path(fullPath)==1
    % Verify that the dir exists
    if exist(fullPath, 'dir')
        isFound = 1;
    end
else
    % Walk through the search path
    for ii = 1:length(searchPaths)
        thisFullPath = fullfile(searchPaths{ii}, fullPath);
        % If this candidate path exists then exit
        if exist(thisFullPath, 'dir')
            isFound = 1;
            fullPath = thisFullPath;
            break
        end
    end
end


%--------------------------------------------------------------------------
function [fullName, isFound] = resolve_file_info(fullName, searchPaths)

% Initialize output value
isFound = 0;

% Extract file parts
[fPath, fName, fExt] = fileparts(fullName);

if is_absolute_path(fPath)==1
    % If the file has no extension then try to add it
    if isempty(fExt)
        fExt = find_file_extension(fullfile(fPath, fName));
        fullName = fullfile(fPath, [fullName,fExt]);
    end
    % Verify that the file exists
    if exist(fullName, 'file')
        isFound = 1;
    end
else
    % Walk through the search path
    for ii = 1:length(searchPaths)
        thisFullName = fullfile(searchPaths{ii}, fullName);
        % If the file has no extension then try to add it
        if isempty(fExt)
            fExt = find_file_extension(thisFullName);
            thisFullName = [thisFullName,fExt];
        end
        % If this candidate path exists then exit
        if exist(thisFullName, 'file')
            fullName = thisFullName;
            isFound = 1;
            break
        end
    end
end


%--------------------------------------------------------------------------
function fext = find_file_extension(fullName)

% Initialize output value
fext = [];

% Use 'dir' because this command has the same behavior both
% on PC and Unix
theDir = dir([fullName,'.*']);
if ~isempty(theDir)
    for ii = 1:length(theDir)
        if theDir(ii).isdir
            continue
        end
        [fpath, fname, fext] = fileparts(theDir(ii).name);
        if ~isempty(fext)
            break % stop on first occurrence
        end
    end
end


%--------------------------------------------------------------------------
function bool = is_absolute_path(thisPath)

if isempty(thisPath)
    bool = 0;
    return
end

if(thisPath(1)=='.')
    % Relative path
    bool = 0;
else
    if(ispc && length(thisPath)>=2)
        % Absolute path on PC start with drive letter or \(for UNC paths)
        bool = (thisPath(2)==':') | (thisPath(1)=='\');
    else
        % Absolute paths on unix start with '/'
        bool = thisPath(1)=='/';
    end
end


%--------------------------------------------------------------------------
function thePath = correct_path_sep(thePath)

if isunix
    wrongFilesepChar = '\';
    filesepChar = '/';
else
    wrongFilesepChar = '/';
    filesepChar = '\';
end

seps = find(thePath==wrongFilesepChar);
if(~isempty(seps))
    thePath(seps) = filesepChar;
end


%--------------------------------------------------------------------------
function thePaths = correct_path_name(thePaths)

for ii = 1:length(thePaths)
    thePaths{ii} = rtw_alt_pathname(thePaths{ii});
end
thePaths = RTW.uniquePath(thePaths);


%--------------------------------------------------------------------------
function info = get_serialized_info()

% Allocate the output structure array
info(1:1) = struct(...
    'SFunctionName', '',...
    'IncPaths', {{}},...
    'SrcPaths', {{}},...
    'LibPaths', {{}},...
    'SourceFiles', {{}},...
    'HostLibFiles', {{}},...
    'TargetLibFiles', {{}},...
    'Language', ''...
    );

% Dependency info for S-function 'sfun_hmg'
info(1).SFunctionName = 'sfun_hmg';
info(1).IncPaths = {fullfile(getenv('NIMBUS_ROOT'), 'externals', 'minopencv'), fullfile(getenv('NIMBUS_ROOT'), 'externals', 'minopencv', 'include'), fullfile(getenv('NIMBUS_ROOT'), 'externals', 'minopencv', 'include', 'opencv2')};
info(1).SrcPaths = {fullfile(getenv('NIMBUS_ROOT'), 'externals', 'minopencv')};
info(1).SourceFiles = {'hmg_obj.cpp', 'sfun_hmg_wrapper.cpp', 'algorithm.cpp', 'alloc.cpp', 'arithm.cpp', 'array.cpp', 'calibration.cpp', 'color.cpp', 'convert.cpp', 'copy.cpp', 'datastructs.cpp', 'descriptors.cpp', 'detectors.cpp', 'drawing.cpp', 'fast.cpp', 'fast_score.cpp', 'filter.cpp', 'fundam.cpp', 'histogram.cpp', 'imgwarp.cpp', 'keypoint.cpp', 'lapack.cpp', 'matchers.cpp', 'mathfuncs.cpp', 'matmul.cpp', 'matop.cpp', 'matrix.cpp', 'modelest.cpp', 'orb.cpp', 'parallel.cpp', 'pyramids.cpp', 'smooth.cpp', 'stat.cpp', 'system.cpp', 'thresh.cpp', 'undistort.cpp', 'utils.cpp'};
info(1).Language = 'C';

