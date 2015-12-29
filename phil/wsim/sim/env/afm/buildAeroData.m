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

clear all

%% Define Excel Source file and Matlab Data file
excelFile = 'MTV_AeroData.xlsx';   % Excel file name
Sheet     = 'Data';                % Sheet
matFile   = 'AeroData.mat';        % Mat file name

% Used to convert velocities to Mach number
SoS       = 340.290;               % speed of sound at sea level, m/s

%% Extract reference area, chord and span
[AeroData.area , txt, raw] = xlsread(excelFile, Sheet, 'S3');
[AeroData.span , txt, raw] = xlsread(excelFile, Sheet, 'S4');
[AeroData.chord, txt, raw] = xlsread(excelFile, Sheet, 'S5');

%% Extract Flow Velocities and Calculate Mach Numbers
[data, txt, raw] = xlsread(excelFile, Sheet, 'S55:T55');
AeroData.Static.Mach = [0.0 data/SoS];
m=length(AeroData.Static.Mach);

%% Extract Angles of Attack (deg)
[data, txt, raw] = xlsread(excelFile, Sheet, 'R56:R74');
AeroData.Static.Alpha = data';
n=length(AeroData.Static.Alpha);
z=find(AeroData.Static.Alpha==0.0);

% create angles for -180 to -90 and +90 to +180
AeroData.Static.Alpha=[AeroData.Static.Alpha(1:z-1)-90 AeroData.Static.Alpha AeroData.Static.Alpha(z+1:end)+90];

%% Extract CN, Normal Force coefficients 
[data, txt, raw] = xlsread(excelFile, Sheet, 'S56:T74');
AeroData.Static.CN = zeros(m,n);
AeroData.Static.CN(2:m,1:n) = data';

% create CN coefficients for -180 to -90 and +90 to +180
AeroData.Static.CN=[ AeroData.Static.CN(:,z:-1:2) AeroData.Static.CN  AeroData.Static.CN(:,n-1:-1:z)];

% plot CN coefficients
figure,,set(gcf,'Name','Aerodynamic Coefficients: CN, CA, CM')
subplot(311),plot(AeroData.Static.Alpha,AeroData.Static.CN(2:m,:)),grid,axis([-180 180 -1.3 1.3])
ylabel('CN'),title('Normal Force')

%% Extract CA, Axial Force coefficients
[data, txt, raw] = xlsread(excelFile, Sheet, 'U56:V74');
AeroData.Static.CA = zeros(m,n);
AeroData.Static.CA(2:m,1:n) = data';

% create CA coefficients for -180 to -90 and +90 to +180
AeroData.Static.CA=[-AeroData.Static.CA(:,z:-1:2) AeroData.Static.CA -AeroData.Static.CA(:,n-1:-1:z)];

% plot CA coefficients
subplot(312),plot(AeroData.Static.Alpha,AeroData.Static.CA(2:m,:)),grid,axis([-180 180 -.3 .3])
ylabel('CA'),title('Axial Force')

%% Extract CM, Pitching Moment coefficients
[data, txt, raw] = xlsread(excelFile, Sheet, 'W56:X74');
AeroData.Static.CM = zeros(m,n);
AeroData.Static.CM(2:m,1:n) = data';

% create CM coefficients for -180 to -90 and +90 to +180
AeroData.Static.CM=[ AeroData.Static.CM(:,z:n-1) AeroData.Static.CM  AeroData.Static.CM(:,2:z)];

% plot CM coefficients
subplot(313),plot(AeroData.Static.Alpha,AeroData.Static.CM(2:m,:)),grid,axis([-180 180  -.2 .2])
ylabel('CM'),title('Pitching Moment')
xlabel('Angle of Attack, deg')

%% Extract Moment Reference location
[AeroData.Static.refLocation, txt, raw] = xlsread(excelFile, Sheet, 'S6:U6');

%% Dynamic Aero coefficients
AeroData.Dynamic.Mach  = AeroData.Static.Mach;
AeroData.Dynamic.Alpha = AeroData.Static.Alpha;
AeroData.Dynamic.Beta  = AeroData.Static.Alpha;
AeroData.Dynamic.Clp   = zeros(size(AeroData.Static.Mach));
AeroData.Dynamic.Cmq   = zeros(size(AeroData.Static.CM));
AeroData.Dynamic.Cnr   = zeros(size(AeroData.Static.CM));

%% Create data file
save(matFile,'AeroData');

clear all
