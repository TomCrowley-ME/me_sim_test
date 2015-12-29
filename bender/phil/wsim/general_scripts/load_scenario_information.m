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
% load_scenario_information.m                                             %
%                                                                         %
% 07/14/14                                                                %
%-------------------------------------------------------------------------%

function load_scenario_information(scenario)

% assign global variables assumed in the processing
gbl_global_parameters_init;

% ESC: this is kinda hangly
switch scenario
    case {'scenario_1', 'scenario_2', 'scenario_3', 'scenario_4', 'scenario_98','scenario_90'}       
        central_body_name = 'moon';
    case {'scenario_80','scenario_81','scenario_82','scenario_83','scenario_84','scenario_88'}
        central_body_name = 'earth';
    case {'scenario_0'}
        return
    otherwise
        central_body_name = 'moon';
end

set_central_body;


% assign values in base for later use
assignin('base','central_body_name', central_body_name);
assignin('base','central_body_gravity_mu', central_body_gravity_mu);
assignin('base','central_body_radius', central_body_radius);
assignin('base','central_body_rotation_rate', central_body_rotation_rate);
assignin('base','central_body_omega_dot', central_body_omega_dot);
assignin('base','earth_moon_rotation_matrix_select', earth_moon_rotation_matrix_select);

% Build up some directory information
nimbus_root = getenv('NIMBUS_ROOT');
scenarios_root = [nimbus_root '/scenarios'];

if length(strfind(scenario, '_')) > 1
    possible_scenario_names = dir([scenarios_root '/' scenario '*']);
else
    possible_scenario_names = dir([scenarios_root '/' scenario '_*']);
end

if length(possible_scenario_names) > 1
    % Too many matches for scenario name
    error(['Supplied scenario name ''' scenario ''' matches multiple scenarios -- make sure there aren''t any conflicts.']);
elseif length(possible_scenario_names) < 1
    % Requested scenario doesn't exist -- print out known scenarios and exit
    known_scenarios = dir(scenarios_root);
    error_string = ['Scenario ''' scenario ''' not found. Known scenarios are:' char(10)];
    for i=3:length(known_scenarios)
        if known_scenarios(i).isdir
            error_string = [error_string '  ' known_scenarios(i).name char(10)];
        end
    end
    warning(error_string);
    scenario_num = 0;
    scenario_name = 'null';
else
    % Matched a single scenario
    scenario_name = possible_scenario_names(1).name;
    scenario_num_tokens = regexpi(scenario_name, 'scenario_(\d+)_', 'tokens', 'once');
    if isempty(scenario_num_tokens)
        warning(['Scenario ' scenario_name ' doesn''t appear to have an associated number -- assuming 0']);
        scenario_num = 0;
        scenario_name = 'null';
    else
        scenario_num = scenario_num_tokens{1};
    end
end

found_sim_proc = 0;

if scenario_num ~= 0
    % Get a list of files we should process
    scenario_dir = [scenarios_root '/' scenario_name];
    scenario_files = dir(scenario_dir);
    
    for i=3:length(scenario_files)
        [~, file_name, file_extension] = fileparts(scenario_files(i).name);
        if strcmp(file_extension, '.proc')
            if regexp(file_name,'scn\d+_sim')
                found_sim_proc = true;
                fprintf('Loading from %s\n',scenario_files(i).name);
                process_sim_proc(scenario_files(i).name);
            end
        end
    end
end

if ~found_sim_proc
    warning(['Couldn''t find a sim proc for ' scenario_name '! Will try to muddle through...']);
end

