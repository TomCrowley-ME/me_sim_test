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
% date2seconds.m                                                          %
%                                                                         %
% date vector or structure to julian date                                 %
% 03/21/14                                                                %
%-------------------------------------------------------------------------%
function date = seconds2date(s)

global gbl_param

jd = (s/86400) + gbl_param.epoch_julian_date; 

% source http://quasar.as.utexas.edu/BillInfo/JulianDatesG.html
q = jd+0.5;
z = fix(q);
w = fix((z -1867216.25)/36524.25);
x = fix(w/4);
a = z+1+w-x;
b = a+1524;
c = fix((b-122.1)/365.25);
d = fix(365.25*c);
e = fix((b-d)/30.6001);
f = fix(30.6001*e);

fractional_day = b-d-f+(q-z);

day=fix(fractional_day);
if e > 13
    month = e -13;
else
    month = e - 1;
end

if month == 1 || month == 2
    year = c - 4715;
else
    year = c - 4716;
end

date_part = fractional_day - day;

hours = fix(date_part * 24);
minutes = fix(date_part * 1440) - (hours * 60);
seconds = (date_part * 86400) - (hours * 3600) - (minutes * 60);

date = [year month day hours minutes seconds];

end