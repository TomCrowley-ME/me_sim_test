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

% % load scenario will set this value to be same as scenario start for wsim
cfe_initial_utc_time = gbl_param.epoch_seconds;

%  define cfe_time_msg for WSIM/CSL, not in clamps since not really C or T
cellInfo = { ...
            { ...
                'cfe_time_msg', ...
                '', ...
                'Current cFE time -- when autocoded, provided by the SIL.', ...
                'Auto', ...
                '-1', ...
                { ...
                    {'utc_seconds', 1, 'uint32', -1, 'real', 'Sample'}; ... % Current UTC seconds
                    {'utc_mseconds', 1, 'uint16', -1, 'real', 'Sample'}; ... % Current UTC milliseconds
                } ...
            } ...
           };

Simulink.Bus.cellToObject(cellInfo)

clear cellInfo
