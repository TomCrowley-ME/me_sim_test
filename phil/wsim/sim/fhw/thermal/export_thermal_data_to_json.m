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
% export_thermal_data_to_json.m                                           %
%                                                                         %
% 07/18/14                                                                %
%-------------------------------------------------------------------------%

function export_thermal_data_to_json(filename, output_type)

thermal = importdata(filename);

% assume only one row of header material
% [ 'TC description'  'TC #'   'Ti (ÁC)'  'C1'   'C2'   'C3'  'C4'  'C5' ]

tc_description = thermal.textdata(:,1);

tc_id = thermal.data(:,1);
heater_id = thermal.data(:,2);

tc_temp_init = thermal.data(:,3);

tc_coefficient_1 = thermal.data(:,4);
tc_coefficient_2 = thermal.data(:,6);
tc_coefficient_3 = thermal.data(:,6);
tc_coefficient_4 = thermal.data(:,7);
tc_coefficient_5 = thermal.data(:,8);

n = length(tc_id);

% % ESC HACK
% n = 5;

% for scenario initialization
%prefix = [ 'scn' num2str(scn_number) '.'];

prefix = [ '' ];

index = 1;
clear import_json

for kk = 1 : n
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
    % RELEVANT HEATER ID
        % name
        import_json{index}.name = [ prefix 'stm_tc' num2str(tc_id(kk)) '_heater_id' ]; 

        % description 
        import_json{index}.description = ['heater which drive' tc_description{kk+1} ];

        % type
        import_json{index}.type = 'double';

        % one dimension 
        import_json{index}.num_dims = '[ 1 ]';

        % TC variables are tunable
        import_json{index}.tunable_for = 'SIM';

        % get value
        import_json{index}.default_value = write_json_value_string(heater_id(kk));

        % all scenario variables owned by SIM
        import_json{index}.owned_by = 'SIM';
        
        index = index + 1;
        
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
    % INITIAL TEMPERATURE
        % name
        import_json{index}.name = [ prefix 'stm_tc' num2str(tc_id(kk)) '_initial_temperature' ]; 

        % description 
        import_json{index}.description = [tc_description{kk+1} ' initial temperature'];

        % type
        import_json{index}.type = 'double';

        % one dimension 
        import_json{index}.num_dims = '[ 1 ]';

        % TC variables are tunable
        import_json{index}.tunable_for = 'SIM';

        % get value
        import_json{index}.default_value = write_json_value_string(tc_temp_init(kk));

        % all scenario variables owned by SIM
        import_json{index}.owned_by = 'SIM';
        
        index = index + 1;
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
    % TEMPERATURE COEFFICIENTS
        % name
        import_json{index}.name = [ prefix 'stm_tc' num2str(tc_id(kk)) '_eqn_coefficients' ]; 

        % description 
        import_json{index}.description = [tc_description{kk+1} ' temperature equation coefficients'];

        % type
        import_json{index}.type = 'double';

        % one dimension 
        import_json{index}.num_dims = '[ 1 ]';

        % TC variables are tunable
        import_json{index}.tunable_for = 'SIM';

        % get value
        import_json{index}.default_value = write_json_value_string( [tc_coefficient_1(kk) tc_coefficient_2(kk) tc_coefficient_3(kk) tc_coefficient_4(kk) tc_coefficient_5(kk)] );

        % all scenario variables owned by SIM
        import_json{index}.owned_by = 'SIM';
        
        index = index + 1;
    
end

switch output_type
    case 'json'
        % write out json
        savejson('',import_json,['stm_thermal_model_init.json']);
        
    case 'matlab'
        
        % evaluate all parameters in the workspace
        for ii = 1 : length(import_json)
            
            evalin('base', [ import_json{ii}.name ' = ' import_json{ii}.default_value ';' ]);
        end
      
        evalin('base', ['stm_n_temp_sensors = ' num2str(n) ';']);
        evalin('base', ['stm_n_heaters = ' num2str(n) ';']);
            
    otherwise
        error('Current supported outputs are ''json'' and ''matlab''. Try again. ')
        
end
            
            
        
