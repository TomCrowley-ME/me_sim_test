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
% create_scenario_json_file.m                                             %
%                                                                         %
% 07/14/14                                                                %
%-------------------------------------------------------------------------%

function create_scenario_json_file(scn_number)

% load scenario data
load_scenario_information(['scenario_' num2str(scn_number)])

% pull all ini variables
listing = evalin('base','who(''ini*'')');

% loop through all ini variables and create structure 
%#ok<*SAGROW
% STRUCTURE:
%   name: 'arg_roll_body_pointing_vector'
%   description: 'temp'
%   type: 'double'
%   num_dims: '[ 1 ]'
%   tunable_for: 'GDN'
%   default_value: '[ -0.5 -0.866025 0 ]'
%   owned_by: 'GDN'

index = 1;

for kk = 1 : length(listing)
    
    if strcmp(listing{kk},'ini_epoch_seconds')
        fprintf(1,'Not loading ini_epoch_seconds, as this is already defined from base variables\n')
        continue
    end
    
    % name
    import_json{index}.name = [ 'scn' num2str(scn_number) '.' listing{kk}]; 
    
    % description (use var name as hack)
    import_json{index}.description = listing{kk}(5:end);
    
    % type
    info = evalin('base',['whos(''' listing{kk} ''')']);
    
    import_json{index}.type = info.class;
    
    % determine number of dimensions
    var_size = info.size;
    if all(var_size > 1) && length(var_size) == 2
        import_json{index}.num_dims = '[ 2 ]';
    elseif any(var_size == 1) && length(var_size) == 2
        import_json{index}.num_dims = '[ 1 ]';
    else
        fprintf(2,'size ~= 2 for index %i\n', kk)
        fprintf(1,'size is %s \n', var_size)
    end
    
    % no scenario variables are tunable
    import_json{index}.tunable_for = '';
    
    % get value
    value = evalin('base', listing{kk});
    value_cell = num2cell(value);
    if all( var_size ) > 1
        error('this function is not setup for arrays right now...')
    end
    
    % write out decimals at high precision
    if any( rem( value, floor(value) ) ~= 0 )
        value_string = ['[ ' sprintf('%.12f ', value_cell{:}) ' ]' ];
    else
        value_string = ['[ ' sprintf('%d ', value_cell{:}) ' ]' ];
    end
    
    % add transpose if column vec is needed
    if var_size(1) > 1 && var_size(2) == 1
        value_string = [value_string ''''];
    end
        
   import_json{index}.default_value = value_string;
        

    % all scenario variables owned by SIM
    import_json{index}.owned_by = 'SIM';
    
    % increment index
    index = index + 1;
    
end

% also write out central_body_name:
    % name
    import_json{index}.name = [ 'scn' num2str(scn_number) '.central_body_name']; 
    
    % description 
    import_json{index}.description = 'scenario central body';
    
    % type
    import_json{index}.type = 'string';
    
    % size: empty for string
    import_json{index}.num_dims = '';
    
    % no scenario variables are tunable
    import_json{index}.tunable_for = '';
    
    % value
    import_json{index}.default_value = ['''' evalin('base','central_body_name') ''''];
    
    % all scenario variables owned by SIM
    import_json{index}.owned_by = 'SIM';
    

    
% write out json 
savejson('',import_json,['scn' num2str(scn_number) '_init.json']);
    
    
    

    
    



