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

% Build the telemetry map.
% tlm_json_data = loadjson('telemetry.json');
% tlm_apids = cellfun(@(msg) {sscanf(msg.apid, '%x')}, tlm_json_data.telemetry);
% tlm_msgs = cellfun(@(msg) rmfield(msg, 'apid'), tlm_json_data.telemetry, 'UniformOutput', false);
% 
% fsw_telemetry = containers.Map(tlm_apids, tlm_msgs);
lc_msgid = fsw_commands('lc_noop').msgid;