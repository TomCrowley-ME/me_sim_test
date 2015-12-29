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


csc_sc_dt = fsw_dt;

sc_params_size = 256;
sc_tbl_cmd_size = sc_params_size + 4;

sc_tbl_cmd_time = double([-1])';
sc_tbl_cmd_data = uint8([zeros(1,sc_tbl_cmd_size)]);


sc_ids_index = [1 2 3 4];
sc_params_index = [5 : sc_tbl_cmd_size];

%sc_queue_depth = 4;

%sc_empty_cmd_queue = zeros(sc_queue_depth, sc_tbl_cmd_size,'uint8');

sc_empty_cmd_row = zeros(1, sc_tbl_cmd_size,'uint8');

%  define ci_cmd_msg for WSIM/CSL, not in clamps since not really C or T
cellInfo = { ...
            { ...
                'ci_cmd_msg', ...
                '', ...
                'CI/SC command bus used for command inputs into FSW apps.', ...
                'Auto', ...
                '-1', ...
                { ...
                    {'apid', 1, 'uint16', -1, 'real', 'Sample'}; ... % Application ID of the current message.
                    {'command_id', 1, 'uint16', -1, 'real', 'Sample'}; ... % Command code of the current message.
                    {'sequence', 1, 'uint16', -1, 'real', 'Sample'}; ... % Sequence number of the current message.
                    {'params', 256, 'uint8', -1, 'real', 'Sample'}; ... % All parameters of the current message
                } ...
            } ...
           };

Simulink.Bus.cellToObject(cellInfo)

clear cellInfo
