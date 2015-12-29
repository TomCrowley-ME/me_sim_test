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
% doy2date.m                                                              %
%                                                                         %
% year/month/day to day of year (1-366) conversion                        %
% 11/26/13                                                                %
%-------------------------------------------------------------------------%

function [year month day] = doy2date(year, doy)

if doy < 1 || doy > 366
    error('Invalid doy: must be [1 366]')
end


if isleapyear( year )
    mvec = ( [31 29 31 30 31 30 31 31 30 31 30 31] );
else
    mvec = ( [31 28 31 30 31 30 31 31 30 31 30 31] );
end

doycount = 0;
for i = 1 : 12
    if doycount + mvec(i) >= doy
        break
    else
        doycount = doycount + mvec(i);
    end
    
end

month = i;
day = doy - doycount;

if day > 31
    warning('Strange date calculated from doy')
end

function leap = isleapyear( year )

if (mod(year,4) == 0 && mod(year,100) ~= 0 ) || mod(year,400) == 0
    leap = 1;
else
    leap = 0;
end