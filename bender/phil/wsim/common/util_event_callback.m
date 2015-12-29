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

function util_event_callback(blk, event_message, event_id, event_severity, event_filtered, event_mask, event_use_enums, event_enum_types)

nimbus_root = getenv('NIMBUS_ROOT');
all_enum_files = dir(fullfile(nimbus_root,'fsw','cmp','enums','*.m'));
all_enum_types = strrep({all_enum_files.name},'.m','');

% Start with building the RTW data structure
cfe_severities = {'CFE_EVS_DEBUG', 'CFE_EVS_INFORMATION', 'CFE_EVS_ERROR', 'CFE_EVS_CRITICAL'};
rtw_data.id = num2str(event_id);
rtw_data.message = event_message;
rtw_data.severity = cfe_severities{event_severity};
rtw_data.filtered = num2str(event_filtered);
rtw_data.mask = num2str(event_mask);

% Figure out how many tokens there are in our format string
event_message_stripped = regexprep(event_message, '%%', '');
num_inputs = length(strfind(event_message_stripped,'%'));

% Check to see if we're doing any enumerated inputs
string_outputs = strfind(event_message, '%s');
if ~event_use_enums && ~isempty(string_outputs)
    error('Cannot print formatted strings without enumerated inputs!');
elseif event_use_enums
    if ~iscellstr(event_enum_types)
        error('Enumeration types field must be a cell array of strings');
    end
    if length(event_enum_types) ~= num_inputs
        error('The length of the enumeration types field must be the same as the number of inputs');
    end
    
    format_specifiers = regexp(event_message_stripped, '%[^A-Za-z]*[A-Za-z]', 'match');

    for i=1:length(format_specifiers)
        fs = format_specifiers{i};
        enum_name = event_enum_types{i};
        
        if fs(end) ~= 's' && ~isempty(enum_name)
            error('Non-enumerated inputs must have empty strings in the enumerated types cell array');
        elseif fs(end) == 's'
            if isempty(enum_name)
                error('String format specifiers must be enumerated inputs!');
            end
            
            % Extract the enum names into a cell array
            if ~ismember(all_enum_types, enum_name)
                error(['Invalid enumeration name specified for input ' num2str(i)]);
            end
        end
    end
    
    if all(cellfun('isempty', event_enum_types))
        rtw_data.enum_types = repmat('|',1,num_inputs-1);
    else
        rtw_data.enum_types = strjoin(event_enum_types, '|');
    end
else
    rtw_data.enum_types = repmat('|',1,num_inputs-1);
end

% We're done building the RTW data, so apply it to the block
set_param(blk, 'RTWdata', rtw_data);

% Find all of the current data inputs so we can check to see if we have too
% many or too few
inports = find_system(blk, 'LookUnderMasks', 'on', 'FollowLinks', 'on', ...
    'RegExp', 'on', 'BlockType', 'Inport', 'Name', '^data_');

path_tla_list = regexp(blk, 'cs[cu]_(\w{3})_([\w\d]+)/', 'tokens');
if isempty(path_tla_list)
    parent_tla = 'unk';
    parent_number = '';
else
    parent_tla = path_tla_list{end}{1};
    parent_number = regexp(path_tla_list{end}{2}, '\d+', 'match', 'once');
end

my_name = lower(strrep(get_param(blk, 'Name'), ' ', '_'));

signal_prefix = [parent_tla parent_number '_' my_name '_'];

flag_term_handles = get_param([blk '/flag_terminator'], 'LineHandles');
set(flag_term_handles.Inport, 'DataLoggingName', [signal_prefix 'flag']);

% Update all the existing signal logging names
for i=1:length(inports)
    i_str = num2str(i);
    terminator_ports = get_param([blk '/terminator_' i_str], 'LineHandles');
    set(terminator_ports.Inport, 'DataLoggingName', [signal_prefix 'data_' i_str]);
end

if num_inputs > length(inports)
    % We don't have enough inports, so let's add some more
    for i=length(inports)+1:num_inputs
        i_str = num2str(i);  
        inport_name = ['data_' i_str];
        gain_name = ['gain_' i_str];
        terminator_name = ['terminator_' i_str];
        
        % Add the inport block and its corresponding gain and terminator
        add_block('built-in/Inport', [blk '/' inport_name], 'BackgroundColor', 'green', 'Port', num2str(i+1), 'Position', [20 (30+35*i) 50 (44+35*i)]);
        add_block('built-in/Gain', [blk '/' gain_name], 'ShowName', 'off', 'Gain', '1', 'Position', [70 (20+35*i) 120 (50+35*i)]);
        add_block('built-in/Terminator', [blk '/' terminator_name], 'ShowName', 'off', 'Position', [195 (25+35*i) 215 (45+35*i)]);
        
        % Add lines between them, give the line after the gain a name, and
        % mark it as a test point
        add_line(blk, [inport_name '/1'], [gain_name '/1']);
        data_line = add_line(blk, [gain_name '/1'], [terminator_name '/1']);
        set(data_line, 'Name', ['event_data_' i_str]);
        set(data_line, 'TestPoint', 1);
        set(data_line, 'DataLogging', 1);
        set(data_line, 'DataLoggingNameMode', 'Custom');
        set(data_line, 'DataLoggingName', [signal_prefix 'data_' i_str]);
    end
elseif num_inputs < length(inports)
    % We've got too many inports, we need to delete some things
    for i=num_inputs+1:length(inports)
        i_str = num2str(i);
        inport_name = ['data_' i_str];
        gain_name = ['gain_' i_str];
        terminator_name = ['terminator_' i_str];
        
        delete_line(blk, [inport_name '/1'], [gain_name '/1']);
        delete_line(blk, [gain_name '/1'], [terminator_name '/1']);
        delete_block([blk '/' inport_name]);
        delete_block([blk '/' gain_name]);
        delete_block([blk '/' terminator_name]);
    end
end

end