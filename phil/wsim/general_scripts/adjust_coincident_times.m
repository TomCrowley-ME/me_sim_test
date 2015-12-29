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

function new_times = adjust_coincident_times(times)
% Add fsw_dt in steps to adjacent equivalent array elements. Assumes input
% is sorted.

fsw_dt = evalin('base', 'fsw_dt');

current_second = -1;
time_offset = fsw_dt;

for i=2:length(times)
    if times(i,1) == current_second
        times(i,1) = current_second + time_offset;
        time_offset = time_offset + fsw_dt;
    else
        current_second = times(i, 1);
        time_offset = fsw_dt;
    end
end

new_times = times;

end