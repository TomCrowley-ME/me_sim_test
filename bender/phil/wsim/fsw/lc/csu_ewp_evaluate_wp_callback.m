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
% csu_ewp_evaluate_wp_callback.m                                          %
%                                                                         %
% Initialization callback for csu_ewp_evaluate_wp mask initialization     %
%                                                                         %
% Inputs:    1. Path for block to update (gcb from the mask)              %
%            2. The total signal name (bus.signal) to be checked          %
%            3. The index into that signal as a vector (1 for             %
%               single-element signals)                                   %
%            4. The comparison operator to use                            %
%            5. The bitmask value to use (0 removes the bitmask)          %
%                                                                         %
% 08/19/13                                                                %
% mikestewart@moonexpress.com                                             %
%-------------------------------------------------------------------------%

function csu_ewp_evaluate_wp_callback(blk, signal_name, signal_index, comparison_type, bitmask_value)

% Split up the telemetry point name into its bus name and signal name, and
% update the appropriate bus selectors
name_components = regexpi(signal_name,'\.','split','once');
set_param([blk '/tlm_bus_select'], 'OutputSignals', name_components{1});
set_param([blk '/tlm_signal_select'], 'OutputSignals', name_components{2});

% Set up the selector block to get the correct index into the signal. These
% changes all have to be made simultaneously
num_dimensions = length(signal_index);
set_param([blk '/tlm_index_select'], 'NumberOfDimensions', int2str(num_dimensions), ...
                                     'IndexOptionArray', repmat({'Index vector (dialog)'}, 1, num_dimensions), ...
                                     'IndexParamArray', strsplit(int2str(signal_index)));

% Check to see if we need to add or remove the bitmask
if bitmask_value == 0
    try
        % Delete the lines currently attached to the bitmask block
        port_handles = get_param([blk '/bitmask'], 'LineHandles');
        delete_line(port_handles.Inport);
        delete_line(port_handles.Outport);
        
        % Delete the bitmask block itself
        delete_block([blk '/bitmask']);
        
        % Connect the selector directly to the comparator
        add_line(blk, 'tlm_index_select/1', 'comparison_operator/1');
    catch
        % Block doesn't exist, which was our goal anyways
    end
else
    try
        % Add a bitmask block to the system
        add_block('simulink/Logic and Bit Operations/Bitwise Operator', [blk '/bitmask'], ...
                  'Position', [535 165 585 215], 'BitMask', 'bitmask_value', 'logicop', 'AND', ...
                  'UseBitMask', 'on', 'ShowName', 'off');
              
        % Delete the line directly connecting the index selector and the 
        % comparator
        delete_line(blk, 'tlm_index_select/1', 'comparison_operator/1');
        
        % Add lines between them and the bitmask
        add_line(blk, 'tlm_index_select/1', 'bitmask/1');
        add_line(blk, 'bitmask/1', 'comparison_operator/1');
    catch
        % Block already exists, which was our goal anyways
    end
end

% Set the proper relational operator on the comparator
set_param([blk '/comparison_operator'], 'Operator', comparison_type);


end