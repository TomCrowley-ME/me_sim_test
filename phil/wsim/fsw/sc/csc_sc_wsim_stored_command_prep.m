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

sc_msgid = fsw_commands('sc_startrts').msgid;
sc_start_rts_id = fsw_commands('sc_startrts').command_code;

sc_num_rts = length(sc_rts_list);
sc_queue_depth = sc_num_rts + 2;
sc_empty_cmd_queue = zeros(sc_queue_depth, sc_tbl_cmd_size,'uint8');

csc_rtc_rts_collection_generate(sc_rts_list);

%cmd_counter = size(tbl_cmd_data,1) + 1;

% tbl_cmd_time(cmd_counter, 1) = double(4294967295);
% tbl_cmd_data(cmd_counter, 1:2) = typecast(uint16(hex2dec('0')), 'uint8');
% tbl_cmd_data(cmd_counter, 3:4) = typecast(uint16(0), 'uint8');
% tbl_cmd_data(cmd_counter, 5) = uint8(0);
