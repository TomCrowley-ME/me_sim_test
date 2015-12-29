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

function result = yn_prompt(str, default, color)

% Assume stdout unless the prompter really wants red
if strcmpi(color, 'red')
    outstream = 2;
else
    outstream = 1;
end

% Adjust the prompt string based on the default action
if strcmpi(default, 'y')
    promptstring = [str ' [Yn] '];
else
    promptstring = [str ' [yN] '];
    default = 'n';
end

% Keep asking until we get either y or n
c = '';
while ~strcmpi(c, 'y') && ~strcmpi(c, 'n')
    fprintf(outstream, promptstring);
    c = input('', 's');
    if isempty(c)
        % No characters entered, so take default action
        c = default;
    end
end

% Return a boolean result to make it easier on the user
result = strcmpi(c, 'y');

end