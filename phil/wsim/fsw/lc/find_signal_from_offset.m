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

function [bus_name, signal_name, signal_index] = find_signal_from_offset(msgid, byte_offset)

tlm_header_size = 12;
fsw_telemetry = evalin('base', 'fsw_telemetry');

cur_offset = tlm_header_size;

bus_name = '';
signal_name = '';
signal_index = 0;

if fsw_telemetry.isKey(msgid)
    parameters = fsw_telemetry(msgid).parameters;

    for i=1:length(parameters)
        param_dimensions = eval(parameters{i}.dimensions);
        param_type_size = sizeof(parameters{i}.type);
        
        param_size = prod(param_dimensions)*param_type_size;
        
        if byte_offset < (cur_offset + param_size)
            % We have found the correct parameter -- now to find the index
            param_offset = byte_offset - cur_offset;
            
            if mod(param_offset, param_type_size) ~= 0
                warning(['find_signal_name: requested invalid offset']);
                return;
            end
            
            element_offset = param_offset/param_type_size;
            
            signal_index = zeros(size(param_dimensions));

            cum_dimensions = [1 cumprod(param_dimensions(1:end-1))];
            remaining_offset = element_offset;

            for j=length(cum_dimensions):-1:1
                signal_index(j) = floor(remaining_offset / cum_dimensions(j));
                remaining_offset = mod(remaining_offset, cum_dimensions(j));
            end

            signal_index = signal_index + 1;
            
            bus_name = fsw_telemetry(msgid).name;
            signal_name = parameters{i}.name;
            
            break;
        end
        
        cur_offset = cur_offset + param_size;
    end

else
    warning(['find_signal_name: unable to find msg with apid 0x' dec2hex(msgid)]);
end