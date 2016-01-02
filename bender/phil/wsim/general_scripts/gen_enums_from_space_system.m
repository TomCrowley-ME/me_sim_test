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

%% gen_enums_from_space_system.m
% Reads the supplied space system (which is assumed to be the root node of
% the dictionary) and writes class definition files for all enumerations to
% NIMBUS_ROOT/fsw/cmp/enums.

function gen_enums_from_space_system(root_space_system, target_space_systems, generate_parents, enum_root)

fprintf(1, 'Writing %s enumeration definitions to %s...\n', strjoin(target_space_systems), enum_root);

if ~isdir(enum_root)
    % If for some reason the directory isn't there, make it and add it to
    % the path
    mkdir(enum_root);
    addpath(enum_root);
end
delete(fullfile(enum_root, '*.m'));

% Recursively look for enumeration definitions
for i=1:length(target_space_systems)
    process_space_system(root_space_system, target_space_systems{i});
end

    function process_space_system_enums(space_system)
        % Does this space system have associated parameter_types?
        if isfield(space_system, 'common_data') && isfield(space_system.common_data, 'parameter_types')
            for j=1:length(space_system.common_data.parameter_types)
                % Check each parameter type to see if it's an enumeration
                parameter_type = space_system.common_data.parameter_types{j};
                if isfield(parameter_type, 'enumeration_list')
                    if rem(parameter_type.size_in_bits, 8) == 0 && isempty(strfind(parameter_type.name, 'es_'))
                        % We found an enumeration, make a file for it
                        emit_enumeration(parameter_type);
                    end
                end
            end
        end
    end

    function found = process_space_system(space_system, target_name)
        found = 0;
        
        if strcmp(space_system.name, target_name)
            process_space_system_enums(space_system);
            found = 1;
        elseif isfield(space_system, 'sub_systems')
            for j=1:length(space_system.sub_systems)
                if process_space_system(space_system.sub_systems{j}, target_name)
                    if generate_parents
                        process_space_system_enums(space_system);
                    end
                    found = 1;
                    return;
                end
            end
        end
    end

    function emit_enumeration(parameter_type)
        % Prefix the type name with enum_ to get the matlab type
        class_name = ['enum_' parameter_type.name];

        % Create an open this enum's file
        filename = [class_name '.m'];
        fid = fopen([enum_root '/' filename], 'w+');
        
        % Construct the underlying type from the size in bits and
        % signedness
        if parameter_type.signed
            sign_char = '';
        else
            sign_char = 'u';
        end
        parent_type = sprintf('%sint%u', sign_char, parameter_type.size_in_bits);


        % Build up a header for the class file -- we'll be inheriting from
        % domain.type so we can get nice numeric values out
        header = [ ...
            '%%%% ' filename '\n' ...
            '%% AUTOGENERATED -- DO NOT EDIT\n' ...
            '%%\n' ...
            '%% Definition for enumerated type ' class_name '\n' ...
            '%%\n' ...
            '\n' ...
            'classdef ' class_name ' < ' parent_type '\n' ...
            '    enumeration\n' ...
            ];

        fprintf(fid, header);

        % Iterate over the possible enum values
        for j=1:length(parameter_type.enumeration_list)
            enum_value = parameter_type.enumeration_list{j};
            fprintf(fid, '        %-20s (%d)\n', enum_value.label, enum_value.value);
        end

        % Wrap things up
        footer = [ ...
            '    end\n' ...
            'end' ...
            ];

        fprintf(fid, footer);
        fclose(fid);
    end
end