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
% move_folder_to_bulid.m                                                  %
%                                                                         %
% 06/24/2014                                                              %
%-------------------------------------------------------------------------%

function move_folder_to_build(directory)

listing = dir(directory);

for jj = 3 : length(listing)

    if exist(listing(jj).name,'file')
        info = which(listing(jj).name);
        [pathstr,~,~] = fileparts(info) ;
    else
        continue
    end
    
    fprintf('Copying %s to %s\n', listing(jj).name, [pathstr filesep])
    copyfile([directory filesep listing(jj).name], [pathstr filesep])
    
end