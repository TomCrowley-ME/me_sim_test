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

function [bus_signal_names, signal_map] = create_analog_conversion_maps(signal_name_start)

% TODO: unhardcode this -- use cntutil? also, bus_signal_names is only
% reserved to give order to the map, which is hacky

% load in adio_msg
localBus = evalin('base', 'adio_msg');
n_fields = length(localBus.Elements);    % calc number of fields in the bus object
kk = 1;
for jj = 1 : n_fields
    if regexp(localBus.Elements(jj).Name, ['^' signal_name_start])
        bus_signal_names{kk} = localBus.Elements(jj).Name;
        kk = kk + 1;
    end
end

% load in conversions
json = loadjson('../../clamps/moonex_cnt_dictionary.json');

% find adio conversions in one place only
conversions = json.sub_systems{2}.common_data.conversions;
n_conversion = length(conversions);
conversion_map = containers.Map;
for qq = 1 : n_conversion
    
    element = conversions{ qq };
    
    conversion_map(element.name) = element.conversion_expression;
    
end
    

% find adio_msg elements that reference these conversions
spacecraft_data = json.sub_systems{2}.telemetry_data;
adio_element = spacecraft_data.sequence_containers{11};
if ~strcmp(adio_element.name, 'adio_msg')
    error('Bus order has changed--updated script to indicate actual adio_msg within dictionary')
end

% walk through adio elemnts, create map between element and conversion
signal_map = containers.Map;
for pp = 1 : length(adio_element.parameters)
    
    element = adio_element.parameters{ pp };
    if regexp(element.name, ['^' signal_name_start])
    
        if isfield(element,'conversion')
            signal_map(element.name) = conversion_map(element.conversion);
        else  
            signal_map(element.name) = 'none';
        end
    end
    
end
