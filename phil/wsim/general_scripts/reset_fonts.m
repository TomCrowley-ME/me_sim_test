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

function reset_fonts(path, fontname, fontsize)
% This script walks the directory tree you point it at and sets the model
% and library fonts to the specified font/size, and resets each block to 
% inherit its font/size. Only models that actually get changed are saved.
% The default for R2013a appears to be 10pt Helvetica.

files = dir(path);
for f=3:length(files) % skip over . and ..
    if files(f).isdir==1
        reset_fonts(fullfile(path, files(f).name), fontname, fontsize)
    else
        [name, ext] = strtok(files(f).name, '.');
        if strcmp(ext, '.slx') % Only look at simulink models/libraries
            modified = false;
            
            model = fullfile(path, [name ext]);
            load_system(model);
            set_param(name, 'Lock', 'off'); %We'll be changing locked libraries, so unlock them
            
            model_font_name = get_param(name, 'DefaultBlockFontName');
            model_font_size = get_param(name, 'DefaultBlockFontSize');
            if model_font_size ~= fontsize || ~strcmp(model_font_name, fontname)
                fprintf('Setting default font in %s...\n', name);
                set_param(name, 'DefaultBlockFontName', fontname);
                set_param(name, 'DefaultBlockFontSize', fontsize);
                modified = true;
            end
            
            blks = find_system(name,'FollowLinks','off');
            for i=1:length(blks)
                try
                    block_font_name = get_param(blks{i},'FontName');
                    block_font_size = get_param(blks{i},'FontSize');
                    block_font_weight = get_param(blks{i},'FontWeight');
                    if block_font_size ~= -1 || ~strcmp(block_font_name, 'auto') || ~strcmp(block_font_weight,'auto')
                        fprintf('Resetting block %s in %s to inherit its font...\n', get_param(blks{i}, 'Name'), name);
                        set_param(blks{i},'FontName', 'auto');
                        set_param(blks{i},'FontSize', -1);
                        set_param(blks{i},'FontWeight', 'auto');
                        modified = true;
                    end
                catch % Block didn't have font params -- no big deal, just keep going
                end
            end
            
            if modified
                save_system(name, model); % Only save if modified
            end
            close_system(name,0);
        end
    end
end

end