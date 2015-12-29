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
% csc_gnd_sta_callback.m                                                  %
%                                                                         %
% Initialization callback for csc_gnd_sta mask initialization             %
%                                                                         %
% Inputs:    1. Path for block to update (gcb from the mask)              %
%            2. Output directory name                                     %
%                                                                         %
% 05/31/13                                                                %
% mikestewart@moonexpress.com                                             %
%-------------------------------------------------------------------------%

function csc_gnd_sta_callback(blk, dir_name)

% Grab the current input and output signals for the two bus selectors.
% We're going to temporarily disable the Bus Selector Unconnected warning
% here for now, as a temporary workaround to not being able to determine
% the difference between being compiled and being drawn for the first time
warning_state = warning('query','Simulink:blocks:BusSelectorUnconnected');
warning('off','Simulink:blocks:BusSelectorUnconnected');
fsw_input_signals = get_param([blk '/fsw_tlm_bus_select'], 'InputSignals');
sim_input_signals = get_param([blk '/sim_tlm_bus_select'], 'InputSignals');
warning(warning_state);

current_fsw_outputs = get_param([blk '/fsw_tlm_bus_select'], 'OutputSignals');
current_sim_outputs = get_param([blk '/sim_tlm_bus_select'], 'OutputSignals');

if isempty(fsw_input_signals) || isempty(sim_input_signals)
    % No inputs detected -- something's not right, and somebody else will
    % probably get an error before us, so bail out without nuking anything
    return;
end

% With that sanity check out of the way, we need to make sure our output
% directory actually exists
if ~isempty(dir_name)
    if ~exist(dir_name, 'dir')
        mkdir(dir_name);
    end
    dir_name = [dir_name filesep];
end

% Construct strings out of the input signal structures that is formatted in
% the same way that the output signal strings are
fsw_input_names = cellfun(@csc_gnd_extract_signal, fsw_input_signals)';
sim_input_names = cellfun(@csc_gnd_extract_signal, sim_input_signals)';

fsw_input_string = strjoin(fsw_input_names, ',');
sim_input_string = strjoin(sim_input_names, ',');

if strcmp(fsw_input_string, current_fsw_outputs) && strcmp(sim_input_string, current_sim_outputs)
    % The bus selectors are properly passing through all of the signals
    % available to them, so let's just walk through the To File blocks and
    % make sure that their destination directories are up to date

    for i=1:length(fsw_input_names)
        filename = [dir_name fsw_input_names{i} '.mat'];
        set_param([gcb '/fsw_tofile_' num2str(i)], 'Filename', filename);
    end

    for i=1:length(sim_input_names)
        filename = [dir_name sim_input_names{i} '.mat'];
        set_param([gcb '/sim_tofile_' num2str(i)], 'Filename', filename);
    end

    return;
end

% Get a quick count of the current number of outputs for each bus selector,
% since we're about to overwrite them, and we want to know how many To File
% blocks currently exist
prev_num_fsw_outputs = length(strfind(current_fsw_outputs, ',')) + 1;
prev_num_sim_outputs = length(strfind(current_sim_outputs, ',')) + 1;

% Select all of our new signals!
set_param([blk '/fsw_tlm_bus_select'], 'OutputSignals', fsw_input_string);
set_param([blk '/sim_tlm_bus_select'], 'OutputSignals', sim_input_string);

% We'll need to know how many outputs we have now to properly position and
% size things
num_fsw_signals = length(fsw_input_names);
num_sim_signals = length(sim_input_names);

% Set size and location of the inport blocks and their corresponding bus
% selectors
fsw_bus_select_top = 30;
fsw_bus_select_height = num_fsw_signals*40;
fsw_bus_select_bottom = 25+fsw_bus_select_height;

set_param([blk '/ofsw_telemetry_bus_msg'], 'Position', [50 (25+fsw_bus_select_height/2) 80 (39+fsw_bus_select_height/2)]);
set_param([blk '/fsw_tlm_bus_select'], 'Position', [145 fsw_bus_select_top 150 fsw_bus_select_bottom]);

sim_bus_select_top = fsw_bus_select_bottom + 20;
sim_bus_select_height = num_sim_signals*40;

set_param([blk '/sim_telemetry_bus_msg'], 'Position', [50 (sim_bus_select_top+sim_bus_select_height/2-5) 80 (sim_bus_select_top+sim_bus_select_height/2+9)]);
set_param([blk '/sim_tlm_bus_select'], 'Position', [145 sim_bus_select_top 150 (sim_bus_select_top+sim_bus_select_height)]);

% And finally, update the to file blocks
update_tofile_blocks('fsw', prev_num_fsw_outputs, num_fsw_signals, fsw_input_names, fsw_bus_select_top);
update_tofile_blocks('sim', prev_num_sim_outputs, num_sim_signals, sim_input_names, sim_bus_select_top);

function update_tofile_blocks(group, prev_num_outputs, num_signals, input_names, bus_select_top)
if prev_num_outputs > num_signals
    % Last time we did this, there were more inputs, so we'll need to
    % delete some To File blocks and the lines attached to them
    for j=num_signals+1 : prev_num_outputs
        tofile_name = [blk '/' group '_tofile_' num2str(j)];
        try
            line_handles = get_param(tofile_name, 'LineHandles');
            delete_line(line_handles.Inport(1));
            delete_block(tofile_name);
        catch
            error(['can''t delete ' tofile_name]);
        end
    end
elseif prev_num_outputs < num_signals
    % We've got some additional signals, so we need to add some more To
    % File blocks
    for j=prev_num_outputs+1 : num_signals
        i_str = num2str(j);
        tofile_name = [group '_tofile_' i_str];
        add_block('built-in/ToFile', [blk '/' tofile_name], 'MatrixName', 'data', 'SaveFormat', 'Timeseries', 'ShowName', 'off');
        add_line(blk, [group '_tlm_bus_select/' i_str], [tofile_name '/1']);
    end
end

% The number of To File blocks for this group is now correct, so we just
% need to relocate them and set some parameters
for j=1:num_signals
    i_str = num2str(j);
    tofile_name = [blk '/' group '_tofile_' i_str];

    tofile_block_top = bus_select_top + 5 + 40*(j-1);
    set_param(tofile_name, 'Filename', [dir_name input_names{j} '.mat']);
    set_param(tofile_name, 'Position', [300 (tofile_block_top) 500 (tofile_block_top+25)]);
end
end

function name = csc_gnd_extract_signal(input)
    if iscell(input)
        name = {input{1}};
    else
        name = {input};
    end
end

end
