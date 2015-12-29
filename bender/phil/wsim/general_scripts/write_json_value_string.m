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


function value_string = write_json_value_string(var_in)

switch class(var_in)
    
    case char
        value = evalin('base', var_in);
        
    case {'double','single','uint8','uint16','uint32','int8','int16','int32'}
        value = var_in;
    otherwise
        error('Cannot resolve this type using this function')
end

var_size = size(value);
num_rows = var_size(1);

value_cell = num2cell(value);

decimal_flag = any(any( rem( value, floor(value) ) ~= 0 ));
    
value_string = '[ ';

for jj = 1 : num_rows
    
    cell_row = value_cell(jj,:);
    
    % write out decimals at high precision
    if decimal_flag
        value_string = [ value_string sprintf(' %.14f ', cell_row{:}) ];
    else
        value_string = [ value_string sprintf( '%d ', cell_row{:}) ];
    end
    
    if jj < num_rows
        value_string = [ value_string '; '];
    else
        value_string = [ value_string ' ]'];
    end
    
end
    

    
    
    
    
    
    
    
    
