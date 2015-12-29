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

function [time_data, command_data] = process_ats(file_path)

f = fopen(file_path);

time_data = [0]';
command_data = uint8(zeros(1,260));

cmd_counter = 1;

line = fgetl(f);
line_number = 1;


while ischar(line)

    if ~isempty(strtrim(line))
        line_components = regexpi(line, '(?<time>[^/]+)\s*/(?<cmd>\w+)\s*(?<params>.*)', 'names');

        % throw out commands preceded by ;
        if strcmp(line_components.time(1), ';')

            % This command's not real, wrap up and go on to the next line
            cmd_counter = cmd_counter + 1;

            line = fgetl(f);
            line_number = line_number + 1;
            continue
        end

        % First decode the time for this command, The expected format is
        % YYYY-DDD HH:MM:SS, where DDD is the day of the year
        cmd_time_seconds = date2seconds( line_components.time );

        % Encode the command
        [status, encoded_command] = encode_command(line_components.cmd, lower(line_components.params));

        if status == -1
            error(['Error encoding command on line ' num2str(line_number) ' in ' file_path]);
        elseif status == 1
            % Got a match, fill it in
            time_data(cmd_counter, 1) = cmd_time_seconds;
            command_data(cmd_counter, :) = encoded_command;
            cmd_counter = cmd_counter + 1;
        end
    end

    line = fgetl(f);
    line_number = line_number + 1;
end

fclose(f);

end
