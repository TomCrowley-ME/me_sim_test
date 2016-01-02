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

%% gen_bus_from_space_system.m
% Reads in the supplied space system (which is assumed to be the root node 
% of the dictionary) and writes out a bus definition script.

function gen_bus_from_space_system(root_space_system, target_space_systems, filename)

fprintf(1,'Writing %s bus definitions to %s...\n', strjoin(target_space_systems, ' & '), filename);
% Determine function name and open file
[~, functionname] = fileparts(filename);
fid = fopen(filename, 'w+');

% Write out the header for the script, as well as initial non-variable
% setup code

header = [ ...
    '%%%% ' functionname '.m\n' ...
    '%% AUTOGENERATED -- DO NOT EDIT\n' ...
    '%% Creates all the required nonvirtual bus objects for the WSIM.\n' ...
	'%% Returns a cell array of these objects\n' ...
    '%%\n' ...
	'%% Optional input: ''false'' suppresses creation of workspace objects\n' ...
    '%%\n' ...
	'%% The order of bus definitions is as follows:\n' ...
	'%%     BusName, HeaderFile, Description, DataScope, Alignment, Elements\n' ...
	'%% The order of bus element attributes is as follows:\n' ...
	'%%     ElementName, Dimensions, DataType, SampleTime, Complexity, SamplingMode\n' ...
    '%%\n' ...
    '\n' ...
	'function cellInfo = ' functionname '(varargin)\n\n' ...
	'suppressObjects = false;\n' ...
	'if nargin == 1 && islogical(varargin{1}) && varargin{1} == false\n' ...
	'    suppressObjects = true;\n' ...
    'elseif nargin > 1\n' ...
    '    error(''Invalid input argument(s) supplied\\n'');\n' ...
    'end\n' ...
    '\n' ...
    'cellInfo = { ...\n'
    ];

fprintf(fid, header);

abstract_structures_map = containers.Map;
simulink_buses_map = containers.Map;
parameter_types_map = containers.Map;
required_structures = {};

for i=1:length(target_space_systems)
    result = load_space_system(root_space_system, target_space_systems{i});
    if ~result
        warning(['Target space system ' target_space_systems{i} ' not found!']);
    end
end

% Emit all of the found simulink buses
bus_names = simulink_buses_map.keys;
for i=1:length(bus_names)
    emit_bus_definition(bus_names{i}, simulink_buses_map(bus_names{i}), true);
end

% Emit all required abstract structures
% This cell array can grow as we iterate through it, so use a while loop
i = 1;
while i <= length(required_structures)
    emit_bus_definition(required_structures{i}, abstract_structures_map(required_structures{i}), false);
    i = i+1;
end

% Write out the wrap-up code
footer = [ ...
    '};\n' ...
    '\n' ...
    'if ~suppressObjects\n' ...
    '    %% Create bus objects in the MATLAB base workspace\n' ...
    '    Simulink.Bus.cellToObject(cellInfo);\n' ...
    'end\n' ...
    '\n' ...
    'end\n' ...
    ];

fprintf(fid, footer);

fclose(fid);


    function emit_bus_definition(name, sequence_container, add_tlm_hdr_align)
        bus_entry = [ ...
            '    { ...\n' ...
            '        ''' name ''', ...\n' ...
            '        '''', ...\n' ...
            '        ''' sequence_container.description ''', ...\n' ...
            '        ''Auto'', ...\n' ...
            '        ''-1'', ...\n' ...
            '        { ...\n' ...
            ];

        if add_tlm_hdr_align % Put out alignment bytes for top level buses
            bus_entry = [ bus_entry '            {''cfe_tlm_header_align'', 4, ''uint8'', -1, ''real'', ''Sample''}; ... %% i really hate sparc\n' ];
        end

        for j=1:length(sequence_container.parameters)
            bus_param = sequence_container.parameters{j};

            % If this parameter has a "dimensions" field, we need to
            % iterate through it and build up a MATLAB array of them
            if isfield(bus_param, 'dimensions') && ~isempty(bus_param.dimensions)
                if length(bus_param.dimensions) > 1
                    % Multidimensional parameter, build up a formatted
                    % array
                    bus_dimensions = sprintf('[%d', bus_param.dimensions{1}.len);
                    for k=2:length(bus_param.dimensions)
                        bus_dimensions = sprintf('%s,%d', bus_dimensions, bus_param.dimensions{k}.len);
                    end
                    bus_dimensions = [bus_dimensions ']'];
                else
                    % One-dimensional, so just use the length
                    bus_dimensions = num2str(bus_param.dimensions{1}.len);
                end
            else
                % Assume scalar
                bus_dimensions = '1';
            end

            % If this is a nested bus, add it to the list of structures to
            % generate nonvirtual buses for
            if parameter_types_map.isKey(bus_param.type)
                bus_type = get_matlab_param_type(parameter_types_map(bus_param.type));
            else
                bus_type = bus_param.type;
                
                if isempty(find(strcmp(required_structures, bus_param.type), 1))
                    required_structures = [required_structures bus_param.type];
                end
            end

            %Construct the parameter entry
            bus_entry = [ bus_entry ...
                '            {''' bus_param.name ''', ' bus_dimensions ', ''' bus_type ''', -1, ''real'', ''Sample''}; ... %% ' bus_param.description '\n' ...
                ];
        end
        % Close out the parameters and bus, and write it out
        bus_entry = [ bus_entry ...
            '        } ...\n' ...
            '    } ...\n' ...
            ];
        fprintf(fid, bus_entry);
    end

    % Adds all supplied sequence containers to the parameter type map
    function load_sequence_containers(sequence_containers)
        if ~isempty(sequence_containers)
            container_map = named_cell_to_map(sequence_containers);
            names = container_map.keys;
            for j=1:length(names)
                container = container_map(names{j});
                if container.abstract && ~abstract_structures_map.isKey(names{j})
                    abstract_structures_map(names{j}) = container;
                elseif isfield(container, 'bus_type') && strcmp(container.bus_type, 'simulink_bus') && ~simulink_buses_map.isKey(names{j})
                    simulink_buses_map(names{j}) = container_map(names{j});
                end
            end
        end
    end

    % Adds all supplied parameter types to the parameter type map
    function load_parameter_types(parameter_types)
        type_map = named_cell_to_map(parameter_types);
        names = type_map.keys;
        for j=1:length(names)
            param_type = type_map(names{j});
            if ~parameter_types_map.isKey(names{j})
                parameter_types_map(names{j}) = param_type;
            end
        end
    end

    % Given a space system, locate and load all relevant information
    function process_space_system_data(space_system)
        if isfield(space_system, 'common_data')
            if isfield(space_system.common_data, 'sequence_containers')
                load_sequence_containers(space_system.common_data.sequence_containers);
            end
            if isfield(space_system.common_data, 'parameter_types')
                load_parameter_types(space_system.common_data.parameter_types);
            end
        end
        if isfield(space_system, 'telemetry_data')
            load_sequence_containers(space_system.telemetry_data.sequence_containers);
        end
    end

    % Loads bus and type definitions from only the requested named
    % subsystem and its parents
    function found=load_space_system(space_system, target_name)
        found = 0;
        
        if strcmp(space_system.name, target_name)
            process_space_system_data(space_system);
            found = 1;
        elseif isfield(space_system, 'sub_systems')
            for j=1:length(space_system.sub_systems)
                if load_space_system(space_system.sub_systems{j}, target_name)
                    process_space_system_data(space_system);
                    found = 1;
                    return;
                end
            end
        end
    end
end