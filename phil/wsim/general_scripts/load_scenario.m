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

function load_scenario(varargin)

scenario = varargin{1};
vehicle = varargin{2};


if nargin > 2
    usr_data_dir_name = varargin{3};
end

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
    error(error_string);
else
    % Matched a single scenario
    scenario_name = possible_scenario_names(1).name;
    scenario_num_tokens = regexpi(scenario_name, 'scenario_(\d+)_', 'tokens', 'once');
    if isempty(scenario_num_tokens)
        warning(['Scenario ' scenario_name ' doesn''t appear to have an associated number -- assuming 0']);
        scenario_num = 0;
    else
        scenario_num = scenario_num_tokens{1};
    end
end

% Always define fresh command tables
sc_tbl_cmd_time = double([-1])';
sc_tbl_cmd_data = uint8([zeros(1,evalin('base','sc_tbl_cmd_size'))]);

% load in all RTS files in the rts directory
sc_rts_list = [];

rts_dir = [scenarios_root '/rts'];
rts_files = dir(rts_dir);
for i = 4:length(rts_files)
    [~, ~, file_extension] = fileparts(rts_files(i).name);
    if strcmp(file_extension,'.rtf')
        rts_num = sscanf(rts_files(i).name, 'rts_%u');
        if isempty(rts_num) || rts_num > 255
            error(['Invalid RTS file name ' rts_files(i).name ' -- must be of form rts_N_*.rtf, where 0<=N<=255']);
        end
        [rts_times, rts_data] = process_rts([rts_dir '/' rts_files(i).name]);
        rts_num_str = sprintf('%03u', rts_num);
        sc_rts_list = [sc_rts_list rts_num];
        assignin('base', ['sc_rts' rts_num_str '_cmd_time'], rts_times);
        assignin('base', ['sc_rts' rts_num_str '_cmd_data'], rts_data);
    end
end

% if using an mtv vehicle, also load the RTSs for earth-based test
if strcmp(vehicle, 'schooner') || ~isempty( strfind(vehicle, 'mtv') )
    
    rts_dir = [scenarios_root '/rts/mtv'];
    rts_files = dir(rts_dir);
    for i = 3:length(rts_files)
        [~, ~, file_extension] = fileparts(rts_files(i).name);
        if strcmp(file_extension,'.rtf')
            rts_num = sscanf(rts_files(i).name, 'rts_%u');
            if isempty(rts_num) || rts_num > 255
                error(['Invalid RTS file name ' rts_files(i).name ' -- must be of form rts_N_*.rtf, where 0<=N<=255']);
            end
            [rts_times, rts_data] = process_rts([rts_dir '/' rts_files(i).name]);
            rts_num_str = sprintf('%03u', rts_num);
            sc_rts_list = [sc_rts_list rts_num];
            assignin('base', ['sc_rts' rts_num_str '_cmd_time'], rts_times);
            assignin('base', ['sc_rts' rts_num_str '_cmd_data'], rts_data);
        end
        
    end
end

% count up total number of RTS
[rts_num_counts, rts_bins] = histc(sc_rts_list, unique(sc_rts_list));
duplicate_rts_list = find(rts_num_counts > 1);

if ~isempty(duplicate_rts_list)
    duplicated_rts_numbers = unique(sc_rts_list(find(ismember(rts_bins, duplicate_rts_list))));
    error(['Found duplicate RTS number(s): '  num2str(duplicated_rts_numbers)]);
end

assignin('base', 'sc_rts_list', sc_rts_list);

found_sim_proc = false;

% Get a list of files we should process
scenario_dir = [scenarios_root '/' scenario_name];
scenario_files = dir(scenario_dir);

for i=3:length(scenario_files)
    [~, file_name, file_extension] = fileparts(scenario_files(i).name);
    if strcmp(file_extension, '.proc')
        if regexp(file_name,'scn\d+_sim')
            found_sim_proc = true;
            process_sim_proc(scenario_files(i).name);
        end
    end
end

if ~found_sim_proc
    warning(['Couldn''t find a sim proc for ' scenario_name '!']);
end

found_mos_proc = false;

for i=3:length(scenario_files)
    [~, file_name, file_extension] = fileparts(scenario_files(i).name);
    if strcmp(file_extension, '.proc')
        if regexp(file_name,'scn\d+_mos')
            found_mos_proc = true;
            process_sim_proc(scenario_files(i).name);
        end
    end
end

if ~found_mos_proc
    warning(['Couldn''t find a mos proc for ' scenario_name '!']);
end

atf_name = ['ats_scn' scenario_num '.atf'];

if any(strcmp({scenario_files.name}, atf_name))
    [ats_times, ats_data] = process_ats([scenario_dir '/' atf_name]);
    sc_tbl_cmd_time = [sc_tbl_cmd_time; ats_times];
    sc_tbl_cmd_data = [sc_tbl_cmd_data; ats_data];
else
    error(['Unable to find ATS ' atf_name ' in ' scenario_dir '!']);
end

[ats_sorted_times, sorted_indices] = sortrows(sc_tbl_cmd_time);
ats_sorted_data = sc_tbl_cmd_data(sorted_indices,:);

ats_sorted_times = adjust_coincident_times(ats_sorted_times);
ats_total_length = length(ats_sorted_times);
ats_sorted_times(ats_total_length+1,1) = realmax;
ats_sorted_data(ats_total_length+1,1) = 0;

assignin('base', 'scenario_dir', scenario_dir);
assignin('base', 'scenario_num', str2double(scenario_num));
if exist('usr_data_dir_name','var')
    assignin('base', 'scenario_data_dir', [scenario_dir filesep 'scn' scenario_num '_' usr_data_dir_name]);
else
    assignin('base', 'scenario_data_dir', [scenario_dir filesep 'scn' scenario_num '_wsim_data']);
end
evalin('base','delete([scenario_data_dir filesep ''*.mat''])')
assignin('base', 'sc_tbl_cmd_time', ats_sorted_times);
assignin('base', 'sc_tbl_cmd_data', ats_sorted_data);

end
