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

function process_sim_proc(file_path)

f = fopen(file_path);

line_number = 1;
line = fgetl(f);
while ischar(line)
    % Extract the variable name in the Parameters_* table, optionally an
    % index to go along with it, and whatever comes after that
    line_components = regexp(line, '^\s*Parameters_\w+\.(\w+)(\[\d+(,\d+)*\])?([^;]*);?','tokens');
    if ~isempty(line_components)
        line_components = line_components{1}; % Get rid of the outer cell

        % Our line components are now variable, index (if exists),
        % everything following
        if ~isempty(line_components{2})
            % If we got an index, we need to add one to each number
            % and change the indexing characters
            indices = strsplit(line_components{2}(2:end-1), ',');

            if isempty(indices)
                % User must have supplied a string or something, error
                fclose(f);
                error(['Invalid index ''' line_components{2} ''' supplied on line ''' num2str(line_number) ''' of ' file_path]);
            end

            indices = cellfun(@(index) {num2str(str2double(index)+1)}, indices);
            index_string = ['(' strjoin(indices, ',') ')'];
        else
            index_string = '';
        end

        matlab_cmd = [line_components{1} index_string line_components{3} ';'];
        % Stupidly convert STOL strings to MATLAB strings -- not allowing double quotes at the moment
        matlab_cmd = strrep(matlab_cmd, '"', '''');

        % There's still stuff that can be wrong with our string at this
        % point, but matlab will error if it's wrong, so let's try
        try
            %fprintf(1,[matlab_cmd '\n']);
            evalin('base', matlab_cmd);
        catch me
            fprintf(2, ['%s\n'...
                        'process_sim_proc.m translated line %u of %s from:\n' ...
                        '   %s\n' ...
                        'into the MATLAB command:\n' ...
                        '   %s\n' ...
                        'If this looks wrong, check the proc syntax.\n' ...
                        ], me.message, line_number, file_path, line, matlab_cmd);
        end
    end
    line = fgetl(f);
    line_number = line_number+1;
end

fclose(f);

% generate the epoch seconds time from the scenario values
evalin('base','ini_epoch_seconds = date2seconds([ini_year, ini_doy, ini_hour, ini_minute, ini_seconds]);');
evalin('base','cfe_initial_utc_time = date2seconds([ini_year, ini_doy, ini_hour, ini_minute, ini_seconds]);');

end
