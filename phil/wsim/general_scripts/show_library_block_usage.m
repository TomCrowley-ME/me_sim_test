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

function show_library_block_usage(library_name, path)
w = warning('off', 'all');

show_library_block_usage_recursor(library_name, path);

warning(w);
end


function show_library_block_usage_recursor(library_name, path)

files = dir(path);
for f=3:length(files)
    if files(f).isdir==1
        show_library_block_usage_recursor(library_name, fullfile(path, files(f).name))
    else
        [sys_name, ext] = strtok(files(f).name, '.');
        if strcmp(ext, '.slx')
            slxModel = fullfile(path, [sys_name, ext]);
            load_system(slxModel);
            
            % Look at every single block *in this file* for any that
            % reference our target library
            blocks = find_system(sys_name, 'LookUnderMasks', 'all', 'FollowLinks', 'off', 'RegExp', 'on', 'ReferenceBlock', ['^' library_name '/']);
            
            % Did we find any?
            if ~isempty(blocks)
                fprintf(1, '%s contains:\n', slxModel);
                m = containers.Map();
                
                for i=1:length(blocks)
                    reference_block = get_param(blocks{i}, 'ReferenceBlock');
                    if m.isKey(reference_block)
                        m(reference_block) = m(reference_block) + 1;
                    else
                        m(reference_block) = 1;
                    end
                end
                
                m_keys = m.keys;
                for i=1:length(m.keys)
                    fprintf('    %u reference(s) to %s\n', m(m_keys{i}), m_keys{i});
                end
                
                fprintf(1,'\n');
            end
            
            close_system(sys_name,0);
        end
    end
end

end