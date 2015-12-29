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

%% rename_library.m
%
% Renames a library and updates all references to it from models and
% libraries in the given path
%

function rename_library(path, old_lib_name, new_lib_name)

filename = which(old_lib_name);
if isempty(filename)
    fprintf(1, 'That library doesn''t exist. You''re going to mess things up if you try to do that.\n');
end

% Start with updating all the references so they don't totally bork
rename_library_recursor(path, old_lib_name, new_lib_name);

% Now rename the file
fprintf(1, 'Reference update complete. Renaming target library...');

[pathstr, ~, ~] = fileparts(filename);

[status, message] = movefile(filename, fullfile(pathstr, [new_lib_name '.slx']));
if status
    fprintf(1,'Success!\n');
else
    fprintf(1,'Error!\n%s\n(Try renaming the file yourself, we''ve already changed all the references to it)\n', message);
end

end

% Recursively looks for SLX files containing library references
function rename_library_recursor(path, old_lib_name, new_lib_name)

files = dir(path);
for f=3:length(files)
    if files(f).isdir==1
        rename_library_recursor(fullfile(path, files(f).name), old_lib_name, new_lib_name)
    else
        [sys_name, ext] = strtok(files(f).name, '.');
        if strcmp(ext, '.slx')
            slxModel = fullfile(path, [sys_name, ext]);
            load_system(slxModel);
            
            % Look at every single block *in this file* for any that
            % reference our target library
            blocks = find_system(sys_name, 'LookUnderMasks', 'all', 'FollowLinks', 'off', 'RegExp', 'on', 'ReferenceBlock', ['^' old_lib_name '/']);
            
            % Did we find any?
            if ~isempty(blocks)
                set_param(sys_name, 'lock', 'off');
                
                fprintf(1, 'Updating references in %s...\n', slxModel);
                
                % For each block, replace the ReferenceBlock param with the
                % new library name
                for i=1:length(blocks)
                    orig_reference = get_param(blocks{i}, 'ReferenceBlock');
                    new_reference = regexprep(orig_reference, ['^' old_lib_name], new_lib_name);
                    set_param(blocks{i}, 'ReferenceBlock', new_reference);
                end
            
                save_system(sys_name, slxModel);
            end
            
            close_system(sys_name,0);
        end
    end
end

end