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

%% gen_products_from_clamps.m
% Loads the JSON-formatted C&T dictionary and uses it to write out all
% three clamps-based products: bus definitions, command & type maps, and
% enumeration definitions.

function gen_products_from_clamps()

nimbus_root = getenv('NIMBUS_ROOT');
if isempty(nimbus_root)
    warning('NIMBUS_ROOT not set and no filename specified, output will be in current directory');
end

mtv_root = getenv('MTV_ROOT');
if isempty(mtv_root)
    mtv_root = fullfile(nimbus_root, 'mtv');
end

cnt_json = loadjson('moonex_cnt_dictionary.json');

% Generate bus, command, and enum files for MX-1
gen_bus_from_space_system(cnt_json, {'MX1', 'MX1-SIM'}, fullfile(nimbus_root, 'nimbus_bus_all.m'));
gen_commands_from_space_system(cnt_json, {'MX1'}, fullfile(nimbus_root, 'nimbus_commands_all.m'));
gen_enums_from_space_system(cnt_json, {'MX1'}, true, fullfile(nimbus_root, 'fsw', 'cmp', 'enums'));

% Generate bus, command, and enum files for MTV-1
gen_bus_from_space_system(cnt_json, {'MTV1x', 'MTV1x-SIM'}, fullfile(mtv_root, 'mtv_bus_all.m'));
gen_commands_from_space_system(cnt_json, {'MTV1x'}, fullfile(mtv_root, 'mtv_commands_all.m'));
gen_enums_from_space_system(cnt_json, {'MTV1x'}, false, fullfile(mtv_root, 'fsw', 'enums'));

% Regenerate analog conversion blocks (figure out how to keep different
% nimbus vs mtv versions going)
mtv_bus_all;
csu_cmv_convert_measured_voltages_collection_generate;
csu_cmc_convert_measured_currents_collection_generate;
csu_cmx_convert_measured_pressure_xducer_collection_generate;
% not autogenerating temps for MTV1x at present, using manual conversion
%csu_cmt_convert_measured_temps_collection_generate;

end