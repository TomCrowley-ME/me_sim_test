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

clear all,close all

% Define Excel Source file and Matlab Data file
excelFile = '9_Inch_Spherical_Tank_Slosh_Parameters.xlsx'; % Excel file name
Sheet     = 'Metric';                                      % Sheet name
matFile   = 'SloshData.nasa.mat';                          % Mat file name

% conversions
lb2g = 453.592;
in2cm  = 2.54;

% 4.5" tank parameters
density1 = 1.4024;                         % g/cm3
radius1  = 4.5;                            % in
volume1  = 4/3*pi*radius1^3;               % in^3
mass1    = density1/lb2g*volume1*in2cm^3;  % lbm

% 4.834" tank parameters
density2 = 1.40;                           % g/cm3
radius2  = 4.834;                          % in
volume2  = 4/3*pi*radius2^3;               % in^3
mass2    = density2/lb2g*volume2*in2cm^3;  % lbm

% Scale Factors for 4.5" to 4.834" tank
mass_scale   = mass2/mass1;
length_scale = radius2/radius1;

% Extract Fill Fraction
[data, txt, raw] = xlsread(excelFile, Sheet, 'B2:B16');
SloshData.fill_fraction = data'/100;

% Extract Total Mass (kg)
[data1, txt, raw] = xlsread(excelFile, Sheet, 'C2:C16');

% Extract Static Mass (kg)
[data2, txt, raw] = xlsread(excelFile, Sheet, 'D2:D16');

% Extract Pendulum Length (m)
[data3, txt, raw] = xlsread(excelFile, Sheet, 'F2:F16');

% Extract Hinge Height (m)
[data4, txt, raw] = xlsread(excelFile, Sheet, 'G2:G16');

% Extract Fluid Damping
[data, txt, raw] = xlsread(excelFile, Sheet, 'H2:H16');
SloshData.fluid_damping = data';

% Scale parameters
SloshData.pendulum_mass   =(data1'-data2')*mass_scale;
SloshData.pendulum_length = data3'*length_scale;
SloshData.hinge_height    = data4'*length_scale;

figure,plot(SloshData.fill_fraction,SloshData.pendulum_mass),grid,title('Pendulum Mass')
figure,plot(SloshData.fill_fraction,SloshData.pendulum_length),grid,title('Pendulum Length')
figure,plot(SloshData.fill_fraction,SloshData.hinge_height),grid,title('Hinge Height')
figure,plot(SloshData.fill_fraction,SloshData.fluid_damping),grid,title('Fluid Damping')

save(matFile,'SloshData');

clear all
