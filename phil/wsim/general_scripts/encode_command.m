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

function [ status, byte_array ] = encode_command(command_name, parameter_string)
%ENCODE_COMMAND Summary of this function goes here
%   Detailed explanation goes here

status = 1;

byte_array = zeros(1,260);

fsw_commands = evalin('base', 'fsw_commands');
fsw_parameter_types = evalin('base', 'fsw_parameter_types');
sc_desired_msgids = evalin('base', 'sc_desired_msgids');

if ~isKey(fsw_commands, command_name)
    fprintf(2, ['Command ''' command_name ''' not found in command dictionary.\n']);
    status = -1;
    return;
end

cmd_data = fsw_commands(command_name);

% MsgId and Command ID are easy -- we just parse and store them
% right away.
msgid = uint16(cmd_data.msgid);
if ~ismember(msgid, sc_desired_msgids)
    % This isn't 
    status = 0;
    return;
end

command_id = uint16(cmd_data.command_code);
byte_array(1:2) = typecast(msgid, 'uint8');
byte_array(3:4) = typecast(command_id, 'uint8');

% Break up the line's parameters for processing
line_parameters = regexpi(parameter_string, '(?<name>\w+)=(?<value>[^\s,]+)(\s*,|\s*$)', 'names');

param_keys = {line_parameters.name};

% Check for duplicate keys -- once we build a Map, we won't
% know if there were any
[unique_params, ~, unique_indices] = unique(param_keys);
duplicate_indices = find(histc(unique_indices, 1:length(unique_params)) > 1, 1);
if ~isempty(duplicate_indices)
    fprintf(2, ['Command ''' command_name ''' has duplicate parameter ''' unique_params{duplicate_indices(1)} '''\n']);
    status = 0;
    return;
end

% Build a map out of the line parameters, so we can easily look
% up values for each command parameter
if ~isempty(line_parameters)
    param_map = containers.Map(param_keys, {line_parameters.value});
else
    param_map = containers.Map();
end

% Decode and store parameters. We've already stored 4 bytes
% (msgid and command id), so kick it off at 5
data_pointer = 5;

if strcmp(command_name, 'sc_startrts')
    if ~isKey(param_map, 'rts_id')
        fprintf(2, ['Parameter ''rts_id'' not supplied for command ''' command_name '''\n']);
        status = 0;
        return;
     end
    rts_name = param_map('rts_id');
    rts_num_str = regexpi(rts_name, '^[a-zA-Z_]*(\d+)', 'tokens');
    if isempty(rts_num_str)
        fprintf(2, ['Value supplied for command ''' command_name ''' parameter ''rts_id'' invalid or does not contain number\n']);
        status = -1;
        return;
    end
    rts_num = uint8(str2double(rts_num_str{1}));
    byte_array(data_pointer) = rts_num;
else
    for p=1:length(cmd_data.parameters)
        % Read in the data about the current parameter
        param_data = cmd_data.parameters{p};

        % If the name of the parameter isn't a key in our line
        % parameter map, it wasn't supplied. Error out.
        if ~isKey(param_map, param_data.name)
            fprintf(2, ['Parameter ''' param_data.name ''' not supplied for command ''' command_name '''\n']);
            status = -1;
            return;
        end

        % Get the supplied value for the current parameter.
        specified_value = param_map(param_data.name);

        % Before we decode the parameter, we need to know its
        % domain. Make sure the domain is valid, then get its info.
        if ~isKey(fsw_parameter_types, param_data.type)
            fprintf(2, ['Parameter ''' param_data.name ''' for command ''' command_name ''' has non-existent type ''' param_data.type '''\n']);
            status = -1;
            return;
        end

        param_type = fsw_parameter_types(param_data.type);

        % Finally, actually decode the parameter. During this step
        % we're building up converted_value, which should be the
        % actual expected representation, and the correct length in
        % bytes.
        if isfield(param_type, 'enumeration_list')
            enum_index = find(cellfun(@(c) strcmp(c.label, specified_value), param_type.enumeration_list), 1);
            if isempty(enum_index)
                fprintf(2, ['Invalid value supplied for enumerated parameter ''' param_data.name ''' for command ''' command_name '''\n']);
                status = -1;
                return;
            end
            converted_value = eval([get_matlab_param_type(param_type) '(' num2str(param_type.enumeration_list{enum_index}.value) ')']);
        else
            converted_value = eval([get_matlab_param_type(param_type) '(' specified_value ')']);
        end

        % Cast the decoded value into a uint8 array, pack it into
        % tbl_cmd_data, and increment the data pointer.
        packed_value = typecast(converted_value, 'uint8');
        byte_array(data_pointer:data_pointer+length(packed_value)-1) = packed_value;
        data_pointer = data_pointer + length(packed_value);

        % Remove the parameter from the map -- used for detecting
        % spare parameters at the end
        remove(param_map, param_data.name);

    end

    if ~isempty(param_map)
        fprintf(2, ['Unknown parameter(s) ''' strjoin(param_map.keys, ''', ''') ''' supplied for command ''' command_name '''\n']);
        status = -1;
    end
end

end

