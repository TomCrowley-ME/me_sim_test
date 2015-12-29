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

function str = date2datestr(date)

if length(date) == 5
    year = date(1);
    doy = date(2);
    hour = date(3);
    minute = date(4);
    second = date(5);

elseif length(date) == 6
    year = date(1);
    month = date(2);
    day = date(3);
    hour = date(4);
    minute = date(5);
    second = date(6);
end


%-------------------------------------------------------------------------%
% create julian date  

if ~exist('doy','var')
    doy = date2doy(year, month, day);
end

str = sprintf('%04u-%03u-%02u:%02u:%06.3f', year, doy, hour, minute, second);

end