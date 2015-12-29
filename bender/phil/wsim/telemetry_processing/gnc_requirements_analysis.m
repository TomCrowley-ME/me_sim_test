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
% gnc_requirements_analysis.m                                             %
%                                                                         %
% starter function for gnc pointing/knowledge analysis                    %
% 04/14/14                                                                %
%-------------------------------------------------------------------------%

function [ analysis ] = gnc_requirements_analysis(telem, truth, error)

analysis = struct;

% walk through and pull out mode/submode combintations

[~, mode_name] = enumeration('enum_mode');
[~, submode_name] = enumeration('enum_submode');

n_modes = length(mode_name);
n_submodes = length(submode_name);

try
    valid_modes = evalin('base','cml_valid_modes');
catch
    csu_cml_command_latch_init;
    valid_modes = cml_valid_modes;
end

% walk through every mode
for row = 1 : n_modes
    
    % walk through every submode
    for col = 1 : n_submodes
        
        % figure out if this is a valid pair
        if valid_modes(row, col)        
            
            % mode/submode value corresponds to the row/col id
            current_mode    = row;
            current_submode = col;
            
            % pull out indices of any data associated with this pair in the current scenario and assign to structure
             analysis.(mode_name{row}).(submode_name{col}).all_indices = find( telem.cmp.mode.Data == current_mode & telem.cmp.submode.Data == current_submode & telem.cmp.cnt_active_controller_disable.Data == 0);
            
            % add flag to indicate whether this pair is exhibited in the current scenario
            analysis.(mode_name{row}).(submode_name{col}).exhibited = ~isempty( analysis.(mode_name{row}).(submode_name{col}).all_indices );
            
        else
            % not a valid mode/submode pair, no work to be done
            continue
        end
        
    end %submodes
    
end %modes
     
    
% ESC: want to add function call that can exclude T seconds after some event--systematic latency/settling time inclusion


% now that analysis structure is created, walk this structure and assign test results to it

mode_structs = fieldnames(analysis);
n_modes = length(mode_structs);

for jj = 1 : n_modes
    
    % look for submode structures within this mode
    submode_structs = fieldnames( analysis.(mode_structs{jj}) );
    n_submodes = length(submode_structs);

    for kk = 1 : n_submodes
        
        if analysis.(mode_structs{jj}).(submode_structs{kk}).exhibited == 1
        
            % pull out relevant quantities for each mode/submode
            % assume for now that these are pretty simple, and that a whole stream exists
            
            % create pointing substruct
            analysis.(mode_structs{jj}).(submode_structs{kk}).pointing.total_error_deg = getsamples( telem.cnt.error_eul_xyz, analysis.(mode_structs{jj}).(submode_structs{kk}).all_indices );
            analysis.(mode_structs{jj}).(submode_structs{kk}).pointing.total_angle_deg = getsamples( error.pointing.total.angle, analysis.(mode_structs{jj}).(submode_structs{kk}).all_indices );

            
            % create knowledge substruct
            analysis.(mode_structs{jj}).(submode_structs{kk}).knowledge.euler_deg = getsamples( error.knowledge.total.euler , analysis.(mode_structs{jj}).(submode_structs{kk}).all_indices );
            analysis.(mode_structs{jj}).(submode_structs{kk}).knowledge.rate_degsec = getsamples( error.knowledge.total.rate, analysis.(mode_structs{jj}).(submode_structs{kk}).all_indices );

            analysis.(mode_structs{jj}).(submode_structs{kk}).knowledge.total_angle_deg = getsamples( error.knowledge.total.angle, analysis.(mode_structs{jj}).(submode_structs{kk}).all_indices );
            
        end
        
    end
    
end

