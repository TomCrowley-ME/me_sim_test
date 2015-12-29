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
% date2jd.m                                                               %
%                                                                         %
% date vector or structure to julian date                                 %
% 11/26/13                                                                %
%-------------------------------------------------------------------------%

function jd = date2jd( date )

if ischar(date)
    % pull out date components from string: assume format is 'YYYY-DOY HH:MM:SS'
    date_components = strsplit(date, '-');
    year = str2double(date_components{1});
    
    doy = str2double(date_components{2});
    
    time_components = strsplit(date_components{3}, ':');
    hour=  str2double(time_components{1});
    minute=  str2double(time_components{2});
    second=  str2double(time_components{3});
    
else
    if length(date) == 5
        %fprintf(1,'Assuming year-dayofyear hour:minute:second format for input date\n')
        year = date(1);
        doy = date(2);
        hour = date(3);
        minute = date(4);
        second = date(5);
        
    elseif length(date) == 6
        %fprintf(1,'Assuming year-day-month hour:minute:second format for input date\n')
        year = date(1);
        month = date(2);
        day = date(3);
        hour = date(4);
        minute = date(5);
        second = date(6);
    end
end


%-------------------------------------------------------------------------%
% create julian date  

if exist('doy','var')
    [year month day] = doy2date(year, doy);
end

% source http://aa.usno.navy.mil/faq/docs/JD_Formula.php    
jd =	367*year - fix( (7*(year+fix( (month+9)/12 ) ))/4 ) + fix( (275*month)/9 ) + day + 1721013.5 + ( hour + (minute/60) + (second/3600) )/24 ;



    
    
    