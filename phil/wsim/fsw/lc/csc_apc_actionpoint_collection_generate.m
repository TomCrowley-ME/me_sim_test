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
% csc_apc_actionpoint_collection_generate.m                               %
%                                                                         %
% Generator for csc_apc_actionpoint_collection_lib. Creates an actionpoint%
% collection subsystem by reading lc_def_adt.c                            %
%                                                                         %
% 08/23/13                                                                %
% mikestewart@moonexpress.com                                             %
%-------------------------------------------------------------------------%
function csc_apc_actionpoint_collection_generate(adt_filename)

nimbus_root = getenv('NIMBUS_ROOT');
if isempty(nimbus_root)
    error('NIMBUS_ROOT is not set -- first run nimbus_set_path');
end

sys = 'csc_apc_actionpoint_collection_lib';
subsys = [sys '/csc_apc_actionpoint_collection'];

% Get info about the ADT file. We need to check if it's been modified
% since we last regenerated
adt_fileinfo = dir(adt_filename);

try
    % Try loading the system first. If this fails, we'll just create a new
    % one
    load_system(sys);

    % Grab the last modified date from the existing block
    apc_last_modified = get_param(subsys, 'UserData');

    % Check is commented out for now to always force update
    %if isempty(apc_last_modified)
        % No date info stored -- an error happened somewhere. Force update.
        apc_last_modified = 0;
    %end

    if adt_fileinfo.datenum == apc_last_modified
        % The dates modified match, so we don't have any work to do
        close_system(sys);
        return;
    else
        % The ADT file has been updated since we last generated. Unlock the
        % system for editing, and kill our old subsystem block
        set_param(sys, 'Lock', 'off');
        delete_block(subsys);
    end
catch
    % System doesn't exist, make a new one
    new_system(sys, 'Library');
    load_system(sys);
end

%fprintf(1, 'Detected new LC Actionpoint Definition Table, regenerating csc_apc_actionpoint_collection...\n');
fprintf(1, 'Updating LC actionpoints...\n');

% Read in the ADT source file for processing
adt_source = fileread(adt_filename);

% Strip out the comments -- since they can appear anywhere, they can cause
% some serious problems
adt_source = regexprep(adt_source, '/\*.*?\*/','');

% Extract out only rows of the table so we don't get confused by anything
% else
adt_source = regexp(adt_source, 'LC_ActionpointDefinitionTable_t\s*\w+\s*=\s*\{\s*\{(.*?)\}\s*\}\s*;', 'tokens', 'once');
if isempty(adt_source)
    error('csc_apc_actionpoint_collection_generate: couldn''t extract actionpoint definition table from source file!');
end
adt_source = adt_source{1};

% Splitting up this table into individual actionpoints is more tricky than
% the watchpoint table, since it (a) contains nested braces, and (b) has
% strings that need to retain their whitespace (so we can't just nuke it
% all in one go). Both problems are beyond the scope of regular
% expressions, so we have to do this bit of preprocessing manually. This
% pass over the data both bins the actionpoints, and drops all whitespace
% not contained inside strings
actionpoint_list = {};
inside_string = false;
brace_depth = 0;
actionpoint_index = 0;

for i=1:length(adt_source)
    % We're defining actionpoint boundaries as top-level braces here, so
    % we need to first check if we're opening a brace block
    if adt_source(i) == '{'
        brace_depth = brace_depth + 1;
        if brace_depth == 1
            % When the brace depth becomes one, we've just started an
            % actionpoint. Increment the index and prepare the new
            % actionpoint bin for receiving its substring
            actionpoint_index = actionpoint_index + 1;
            actionpoint_list{actionpoint_index} = '';

            % We don't need this brace in the bin, so move on
            continue;
        end
    elseif adt_source(i) == '}'
        % Check to see if we're closing out a brace-enclosed block. If this
        % is the end of an actionpoint, we won't make it into the following
        % if block, so this brace won't be echoed.
        brace_depth = brace_depth - 1;
    end

    if brace_depth > 0
        % If (and only if) we're inside an actionpoint definition, we need
        % to copy across the current character, if it's relevant (ie, any
        % non-whitespace character, and any whitespace inside a string).
        % Before we can determine relevance, we first need to check up on
        % our current string state
        if adt_source(i) == '"' && adt_source(i-1) ~= '\'
            % We've found a non-escaped quote, so invert the current
            % string state.
            inside_string = ~inside_string;
        end

        if ~isstrprop(adt_source(i), 'wspace') || inside_string
            % We've found a relevant character, as defined above. Copy it
            % into the current actionpoint's bin
           actionpoint_list{actionpoint_index} =  [actionpoint_list{actionpoint_index} adt_source(i)];
        end
    end


end

num_actionpoints = length(actionpoint_list);
ap_default_state_vector = zeros(1, num_actionpoints);

% Define the regex that will pull out most of the information -- the result
% will be an array of structures containing information about the current
% actionpoint
ap_regex =  ...
[ ...
    '\.default_state=(?<default_state>\w+),' ...
    '\.rts_id=(?<rts_id>\d+),' ...
    '\.max_fail_before_rts=(?<max_fail_before_rts>\d+),' ...
    '\.rpn_equation=\{(?<rpn_equation>((\d+|AND|OR|NOT),?)+)\},' ...
    '\.event_type=(?<event_type>\w+),' ...
    '\.event_id=(?<event_id>[\w\d]+),' ...
    '\.event_text="(?<event_text>.*?)",?' ...
];

apc_mask_display = ...
[ ...
    'color(''blue'');' ...
    'text(0.05, 0.02, ''MoonEx'', ''HorizontalAlignment'', ''Left'', ''VerticalAlignment'', ''Bottom'');' ...
    'color(''red'');' ...
    'text(0.95, 0.02, ''Autogenerated'', ''HorizontalAlignment'', ''Right'', ''VerticalAlignment'', ''Bottom'');' ...
];

% Add in the subsystem itself and its input ports
add_block('built-in/Subsystem', subsys, 'BackgroundColor', 'yellow', 'UserData', adt_fileinfo.datenum, 'UserDataPersistent', 'on', 'MaskDisplay', apc_mask_display, 'MaskIconOpaque', 'off', 'Position', [200 200 450 300]);
add_block('built-in/Note', [subsys '/AUTOGENERATED BY ' mfilename ' FROM' char(10) strrep(adt_filename,'/','//') char(10) 'DO NOT EDIT'], 'FontWeight', 'bold', 'FontSize', '14', 'Position', [400 0 1200 60]);

add_block('built-in/Inport', [subsys '/watchpoint_bus'], 'BackgroundColor', 'green', 'Port', '1', 'Position', [(60+65) 72 (60+95) 89]);
add_block('built-in/Inport', [subsys '/ap_state_vector_in'], 'BackgroundColor', 'green', 'Port', '2', 'Position', [(30+65) 105 (30+95) 122]);
add_block('built-in/Inport', [subsys '/ap_result_vector_in'], 'BackgroundColor', 'green', 'Port', '3', 'Position', [(65) 139 (95) 156]);

% Add the information block to the subsystem
add_block('util_info_lib/Library Information', [subsys '/Library Information'], 'MaskValues', {'''escrane'''}, 'Position', [0 -300 430 -100]);


% Add in the vector concats and the output ports
concat_h = 20*num_actionpoints;
concat_pos = 40;

add_block('built-in/Concatenate', [subsys '/rts_vector_concatenate'], 'ShowName', 'off', 'NumInputs', int2str(num_actionpoints), 'Position', [800 concat_pos 805 (concat_pos + concat_h)]);
add_block('built-in/Outport', [subsys '/ap_rts_vector'], 'BackgroundColor', 'red', 'Port', '1', 'Position', [850 (concat_pos+concat_h/2-8) 885 (concat_pos+concat_h/2+8)]);
add_line(subsys, 'rts_vector_concatenate/1', 'ap_rts_vector/1');
concat_pos = concat_pos + concat_h + 20;
add_block('built-in/Concatenate', [subsys '/state_vector_concatenate'], 'ShowName', 'off', 'NumInputs', int2str(num_actionpoints), 'Position', [800 concat_pos 805 (concat_pos + concat_h)]);
add_block('built-in/Outport', [subsys '/ap_state_vector'], 'BackgroundColor', 'red', 'Port', '2', 'Position', [850 (concat_pos+concat_h/2-8) 885 (concat_pos+concat_h/2+8)]);
add_line(subsys, 'state_vector_concatenate/1', 'ap_state_vector/1');
concat_pos = concat_pos + concat_h + 20;
add_block('built-in/Concatenate', [subsys '/result_vector_concatenate'], 'ShowName', 'off', 'NumInputs', int2str(num_actionpoints), 'Position', [800 concat_pos 805 (concat_pos + concat_h)]);
add_block('built-in/Outport', [subsys '/ap_result_vector'], 'BackgroundColor', 'red', 'Port', '3', 'Position', [850 (concat_pos+concat_h/2-8) 885 (concat_pos+concat_h/2+8)]);
add_line(subsys, 'result_vector_concatenate/1', 'ap_result_vector/1');

for ap_num=1:num_actionpoints
    ap_num_str = int2str(ap_num);

    % Start by building up some helpful info
    ap_block_name = ['csc_eap_evaluate_ap' ap_num_str];

    csc_eap_pos = [230 (95-85+85*ap_num) 570 (95-20+85*ap_num)];

    % We'll need these gotos whether or not the actionpoint really exists.
    add_block('built-in/Goto', [subsys '/ap' ap_num_str '_state_goto'], 'GotoTag', ['ap' ap_num_str '_state'], 'ShowName', 'off', 'BackgroundColor', 'cyan', 'Position', [590 (csc_eap_pos(2)+5) 670 (csc_eap_pos(2)+20)]);
    add_block('built-in/Goto', [subsys '/ap' ap_num_str '_result_goto'], 'GotoTag', ['ap' ap_num_str '_result'], 'ShowName', 'off', 'BackgroundColor', 'orange', 'Position', [590 (csc_eap_pos(2)+25) 670 (csc_eap_pos(2)+40)]);
    add_block('built-in/Goto', [subsys '/ap' ap_num_str '_rts_goto'], 'GotoTag', ['ap' ap_num_str '_rts'], 'ShowName', 'off', 'BackgroundColor', 'magenta', 'Position', [590 (csc_eap_pos(2)+45) 670 (csc_eap_pos(2)+60)]);

    % Similarly, we'll always need the corresponding from blocks
    concat_pos = 40;
    add_block('built-in/From', [subsys '/ap' ap_num_str '_rts_from'], 'GotoTag', ['ap' ap_num_str '_rts'], 'ShowName', 'off', 'BackgroundColor', 'magenta', 'Position', [700 (concat_pos-20+ap_num*20) 780 (concat_pos-5+ap_num*20)]);
    add_line(subsys, ['ap' ap_num_str '_rts_from/1'], ['rts_vector_concatenate/' ap_num_str]);
    concat_pos = concat_pos + concat_h + 20;
    add_block('built-in/From', [subsys '/ap' ap_num_str '_state_from'], 'GotoTag', ['ap' ap_num_str '_state'], 'ShowName', 'off', 'BackgroundColor', 'cyan', 'Position', [700 (concat_pos-20+ap_num*20) 780 (concat_pos-5+ap_num*20)]);
    add_line(subsys, ['ap' ap_num_str '_state_from/1'], ['state_vector_concatenate/' ap_num_str]);
    concat_pos = concat_pos + concat_h + 20;
    add_block('built-in/From', [subsys '/ap' ap_num_str '_result_from'], 'GotoTag', ['ap' ap_num_str '_result'], 'ShowName', 'off', 'BackgroundColor', 'orange', 'Position', [700 (concat_pos-20+ap_num*20) 780 (concat_pos-5+ap_num*20)]);
    add_line(subsys, ['ap' ap_num_str '_result_from/1'], ['result_vector_concatenate/' ap_num_str]);

    % With all that set up, it's time to actually parse our actionpoint
    % First check to see if this is unused
    empty_actionpoint = isempty(actionpoint_list{ap_num});

    if ~empty_actionpoint
        % Not unused, so try to parse it as an actionpoint
        actionpoint_data = regexp(actionpoint_list{ap_num}, ap_regex, 'names', 'once');

        if isempty(actionpoint_data)
            % TODO: Check for explicitly defined empty actionpoints
            warning('Failed to match AP #%s defined as: \n%s', ap_num_str, actionpoint_list{ap_num});
            empty_actionpoint = true;
        end
    end

    if empty_actionpoint
        % Wire up zeros to everything for this actionpoint
        add_block('built-in/Constant', [subsys '/empty_ap' ap_num_str '_state'], 'Value', '0', 'OutDataTypeStr', 'uint8', 'ShowName', 'off', 'Position', [385 (csc_eap_pos(2)+5) 410 (csc_eap_pos(2)+20)]);
        add_line(subsys, ['empty_ap' ap_num_str '_state/1'], ['ap' ap_num_str '_state_goto/1']);
        add_block('built-in/Constant', [subsys '/empty_ap' ap_num_str '_result'], 'Value', '0', 'OutDataTypeStr', 'boolean', 'ShowName', 'off', 'Position', [385 (csc_eap_pos(2)+25) 410 (csc_eap_pos(2)+40)]);
        add_line(subsys, ['empty_ap' ap_num_str '_result/1'], ['ap' ap_num_str '_result_goto/1']);
        add_block('built-in/Constant', [subsys '/empty_ap' ap_num_str '_rts'], 'Value', '0', 'OutDataTypeStr', 'uint16', 'ShowName', 'off', 'Position', [385 (csc_eap_pos(2)+45) 410 (csc_eap_pos(2)+60)]);
        add_line(subsys, ['empty_ap' ap_num_str '_rts/1'], ['ap' ap_num_str '_rts_goto/1']);

        continue;
    end

    % Build up the MaskValues structure for the block
    ap_mask_values = { ...
        ap_num_str ... % number of the actionpoint
        actionpoint_data.rts_id ... % the number of the RTS to start on fail
        actionpoint_data.max_fail_before_rts ... % Number of consecutive failures before RTS start
        strrep(actionpoint_data.rpn_equation, ',', ' ') ... % RPN equation (space-delimited)
        actionpoint_data.default_state ... % Default state of the AP
        strrep(actionpoint_data.event_type, 'CFE_EVS_', '') ... % Event type (minus the CFE_EVS_ prefix)
        actionpoint_data.event_id ... % Event ID
        actionpoint_data.event_text ... % Event String
        };

    % Figure out the numeric equivalent of the default state and put it in
    % the default state vector
    % TODO: Make this an enumeration evaluation
    switch actionpoint_data.default_state
        case 'DISABLED'
            ap_default_state_vector(ap_num) = 0;
        case 'PASSIVE'
            ap_default_state_vector(ap_num) = 1;
        case 'ACTIVE'
            ap_default_state_vector(ap_num) = 2;
        otherwise
            error([mfilename ': successfully matched AP#' ap_num_str ' but got invalid default state ''' actionpoint_data.default_state '''.']);
    end

    % Add and wire in the new actionpoint block
    add_block('csc_eap_evaluate_ap_lib/csc_eap_evaluate_ap', [subsys '/' ap_block_name], 'MaskValues', ap_mask_values, 'Position', csc_eap_pos);
    add_line(subsys, 'ap_result_vector_in/1', [ap_block_name '/3'], 'autorouting', 'on');
    add_line(subsys, 'ap_state_vector_in/1', [ap_block_name '/2'], 'autorouting', 'on');
    add_line(subsys, 'watchpoint_bus/1', [ap_block_name '/1'], 'autorouting', 'on');

    add_line(subsys, [ap_block_name '/1'], ['ap' ap_num_str '_state_goto/1']);
    add_line(subsys, [ap_block_name '/2'], ['ap' ap_num_str '_result_goto/1']);
    add_line(subsys, [ap_block_name '/3'], ['ap' ap_num_str '_rts_goto/1']);
end

% Assign the default state vector in the base workspace. Note that due to
% this line, the system must be regenerated every run, so the modified
% check is commented out
assignin('base', 'lc_ap_default_states', ap_default_state_vector);

% Our work is done, so let's save and get out of here
save_system(sys, fullfile(nimbus_root, 'fsw', 'lc', 'csc_apc_actionpoint_collection_lib.slx'));
close_system(sys);

end
