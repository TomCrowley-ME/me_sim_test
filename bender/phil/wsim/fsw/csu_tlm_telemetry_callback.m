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

%-------------------------------------------------------------------------%
% csc_tlm_telemetry_callback.m                                            %
%                                                                         %
% Initialization callback for csc_gnd_sta mask initialization             %
%                                                                         %
% Inputs:    1. Path for block to update (gcb from the mask)              %
%            2. Output bus name                                           %
%                                                                         %
% 06/04/13                                                                %
% mikestewart@moonexpress.com                                             %
%-------------------------------------------------------------------------%

function csu_tlm_telemetry_callback(blk, num_inputs, output_bus_name)

% Check the validity of our inputs before we do any processing with them
if ~isnumeric(num_inputs) || length(num_inputs) ~= 1
    error('Inalid number of inputs');
end

if ~isvarname(output_bus_name)
    error('Invalid output bus name');
end

num_inputs = floor(num_inputs);

% Build up information about the current instatiation of the mask
bus_creator_name = [blk '/tlm_bus_creator'];

inport_list = find_system(blk, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'SearchDepth', '1', 'BlockType', 'Inport');
cur_num_inputs = length(inport_list);

outport_name = find_system(blk, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'SearchDepth', '1', 'BlockType', 'Outport');
outport_name = outport_name{1};

if num_inputs ~= cur_num_inputs
    % Set the new number of inputs on the bus creator and adjust its size
    bus_creator_height = 50 + (num_inputs-1)*45;
    set_param(bus_creator_name, 'Inputs', num2str(num_inputs));
    set_param(bus_creator_name, 'Position', [505 215 515 (215 + bus_creator_height)]);

    % Move the outport block to be halfway down the bus creator
    set_param(outport_name, 'Position', [585 (210 + bus_creator_height/2) 615 (224 + bus_creator_height/2)]);

    if cur_num_inputs > num_inputs
        % We need to delete some blocks, but we're not sure of which inport
        % name corresponds to which inport number, so loop through all of
        % them and ask each which number it is. We're also going to build
        % up a list of port names that we keep
        kept_port_list = cell(num_inputs);
        kept_port_count = 0;

        for i = 1 : cur_num_inputs
            inport_name = inport_list{i};
            port_num = str2double(get_param(inport_name, 'Port'));
            if port_num > num_inputs
                % This port's number is too high, so get rid of the line
                % attached to it and the port itself
                line_handles = get_param(inport_name, 'LineHandles');
                delete_line(line_handles.Outport);
                delete_block(inport_name);
            else
                % This port can stay -- add it to the list
                kept_port_count = kept_port_count + 1;
                kept_port_list{kept_port_count} = inport_name;
            end
        end
        % Overwrite the current input list with those that remain
        inport_list = kept_port_list;
    elseif num_inputs > cur_num_inputs
        % We need some more inport ports. We're also going to add to our
        % inport list so we don't have to do find_system again when this is
        % all over
        inport_list{num_inputs} = [];
        for i = cur_num_inputs+1 : num_inputs
            % Build up some info about the new block
            i_str = num2str(i);
            inport_name = ['signal_' i_str];
            inport_path = [blk '/' inport_name];
            inport_top = 188 + 45*i;

            % Add the block, attach it, and add it to the inport list
            add_block('built-in/Inport', inport_path, 'BackgroundColor', 'green', 'Port', i_str, 'Position', [410 inport_top 440 (inport_top+14)]);
            add_line(blk, [inport_name '/1'], ['tlm_bus_creator/' i_str]);
            inport_list{i} = inport_path;
        end
    end
end

% Set the new name of the outport block (We do it now because after we set
% its name, it enters some sort of quantum state and can't be accessed with
% either the old or the new name)
set_param(outport_name, 'Name', output_bus_name);

% Grab the input signal names from the subsystem -- we'll adjust the names
% displayed on the ports of the block to reflect these, for convenience
input_signal_names = get_param(blk, 'InputSignalNames');

for i = 1 : num_inputs
    % Since our input port list is not guaranteed to be sorted, we need to
    % do this in the order of the list instead of in port order
    inport_name = inport_list{i};
    port_num = str2double(get_param(inport_name, 'Port'));

    if isempty(input_signal_names{port_num})
        % If the signal doesn't have a name, make one up
        input_signal_names{port_num} = ['signal_' num2str(i)];
    end
    % Set the name!
    set_param(inport_name, 'Name', input_signal_names{port_num});
end

end
