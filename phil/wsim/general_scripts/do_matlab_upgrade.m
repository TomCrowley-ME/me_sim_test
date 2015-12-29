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

function do_matlab_upgrade(path)

files = dir(path);
for f=3:length(files)
    if files(f).isdir==1
        do_matlab_upgrade(fullfile(path, files(f).name))
    else
        [name, ext] = strtok(files(f).name, '.');
        if strcmp(ext, '.slx')
            disp(name)
            slxModel = fullfile(path, [name, ext]);
            load_system(slxModel);
            save_system(name, slxModel);
            close_system(name,0);
        end
    end
end

end
