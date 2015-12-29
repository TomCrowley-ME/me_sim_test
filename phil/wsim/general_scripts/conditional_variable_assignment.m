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
% conditional_variable_assignment.m                                       %
%                                                                         %
% 07/22/14                                                                %
%-------------------------------------------------------------------------%


function conditional_variable_assignment(script_name)


fid = fopen(which(script_name));


while ~feof(fid)

    statement = fgetl(fid);
    
    if isempty(statement) || strcmp(statement(1),'%') || isempty( strfind(statement,'=') )
        
        % line of comments or no information
        continue 
        
    else
        
        % figure out what variable is being defined
        [ token ] = strtok(statement, '=');
        variable_name = strtrim(token);
        
        % test if this variable has already been defined
        test = evalin('base',['exist(''' variable_name ''',''var'')']);
        if test
            error('\n**** Problem : %s\n**** Cannot evaluate variable %s as it already exists in the workspace from the database\n**** This variable must be managed throgh the database.', variable_name, variable_name )
        else
            % go ahead and actually assign it
            evalin('base', statement)
        end

    
    end
    
    
    
    
end
