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

% Treat the egc_reset_ctrs command as a source of constant truth
egc_msgid = fsw_commands('egc_reset_ctrs').msgid;

% define the bus for the command to be non-virtual
cellInfo = { ...
    { ...
        'ecl_bus_msg', ...
        '', ...
        'EGC command latch message', ...
        'Auto', ...
        '-1', ...
        { ...
            {'cfe_tlm_header_align', 4, 'uint8', -1, 'real', 'Sample'}; ... % i really hate sparc
            {'process_cmds_counter', 1, 'uint16', -1, 'real', 'Sample'}; ... % Number of EGC commands processed
            {'process_cmds_errors', 1, 'uint16', -1, 'real', 'Sample'}; ... % Number of errors encountered processing EGC commands
            {'egc_enable', 1, 'uint8', -1, 'real', 'Sample'}; ... % EGC enable setting
        } ...
    } ...
};
Simulink.Bus.cellToObject(cellInfo)

clear cellInfo