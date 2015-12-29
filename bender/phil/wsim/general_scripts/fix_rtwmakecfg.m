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

%-------------------------------------------------------------------------%
% fix_rtwmakecfg.m                                                        %
%                                                                         %
% Allows for evaluation of MATLAB expressions for paths in rtwmakecfg.m   %
% files, rather than requiring hardcoded absolute paths.                  %
%                                                                         %
% Inputs:                                                                 %
%      filename -- the path of the rtwmakecfg.m file to fix               %
%                                                                         %
% To use:                                                                 %
%   When setting IncPaths and SrcPaths in a call to legacy_code() (or any %
%   other way of generating an rtwmakecfg.m file), supply a string that   %
%   begins and ends with #. The contained string will be turned into a    %
%   MATLAB expression that will be evaluated when the rtwmakecfg file     %
%   is called.                                                            %
%                                                                         %
% Example:                                                                %
% specs.SrcPaths = {'#fullfile(getenv(''NIMBUS_ROOT''), ...               %
%                   ''externals'', ''minopencv'')#'};                     %
%                                                                         %
% 10/31/13                                                                %
% mikestewart@moonexpress.com                                             %
%-------------------------------------------------------------------------%

function fix_rtwmakecfg(filename)

source_filename = [filename '~'];

copyfile(filename, source_filename);

% Open up the source file
sfd = fopen(source_filename, 'r+');
if sfd == -1
    error(['Couldn''t open ' source_filename '!']);
end

% Open up the destination file
dfd = fopen(filename, 'w+');
if dfd == -1
    fclose(sfd);
    error(['Couldn''t open ' filename '!']);
end

source_line = fgetl(sfd);
while ischar(source_line)
    
    % Look for a line that might have 
    if ~isempty(regexp(source_line, '^info\(\d+\).(Src|Inc)', 'once'))
        % This looks kind of scary but it's pretty straightforward -- we're
        % matching everything in #-contained blocks and stripping both the
        % #s and the associate outer quotes
        source_line = regexprep(source_line, '''#([^#]*)#''','$1');
    end
    
    % Be sure to add back the newline that fgetl stripped
    fwrite(dfd, [source_line 10]);
    
    source_line = fgetl(sfd);
end

fclose(sfd);
fclose(dfd);

end