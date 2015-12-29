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

function [time_data, command_data] = process_rts(file_path)

f = fopen(file_path);

time_data = [-1]';
command_data = uint8(zeros(1,260));

cmd_counter = 2;

line = fgetl(f);
line_number = 1;

total_seconds = 0;

while ischar(line)

    if ~isempty(strtrim(line))
        line_components = regexpi(line, '(?<hours>\d{2}):(?<minutes>\d{2}):(?<seconds>\d{2})\s*/(?<cmd>\w+)\s*(?<params>.*)', 'names');

        if isempty(line_components)
            error(['Error parsing line ' num2str(line_number) ' of ' file_path ': ' char(10) ...
                line char(10) ...
                'Expected format is: "HH:MM:SS /command parameter1=0, parameter2=0"']);
        end
        % Translate HH:MM:SS into seconds
        elapsed_seconds = str2double(line_components.hours)*3600 + str2double(line_components.minutes)*60 + str2double(line_components.seconds);
        total_seconds = total_seconds + elapsed_seconds;

        [status, encoded_command] = encode_command(line_components.cmd, lower(line_components.params));

        if status == -1
            error(['Error encoding command on line ' num2str(line_number) ' in ' file_path]);
        elseif status == 1
            % Got a match, fill it in
            time_data(cmd_counter, 1) = total_seconds;
            command_data(cmd_counter, :) = encoded_command;
            cmd_counter = cmd_counter + 1;
        end
    end

    line = fgetl(f);
    line_number = line_number + 1;
end

time_data(cmd_counter, 1) = realmax;
command_data(cmd_counter, 1) = 0;

time_data = adjust_coincident_times(time_data);

fclose(f);

end
