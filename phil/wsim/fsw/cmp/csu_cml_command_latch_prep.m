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

% Treat the cmp_reset command as a source of constant truth
cmp_msgid = fsw_commands('cmp_reset').msgid;

cml_cmd_indices = struct();

fsw_command_keys = fsw_commands.keys;

for i=1:length(fsw_command_keys)
    if cmp_msgid == fsw_commands(fsw_command_keys{i}).msgid
        cml_cmd_indices.(fsw_command_keys{i}) = uint8(fsw_commands(fsw_command_keys{i}).command_code);
    end
end

clear fsw_command_keys
