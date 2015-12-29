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

disp('Running Atmosphere Model Unit Test...')

global CASE_NUM;

CASE_NUM = 0;

%% Load Atmosphere Data
load('COESA_1976.mat')

%% Load Test Inputs
load('unit_test_inputs.mat')
TestInputs.StateBus.AltDot=10;
TestInputs.StateBus.Alt   =0;

%% Run Model
sim('test_atmosphere')

%% Build TestPoints:
n=size(Atmosphere.GeometricAlt.Data,1);

% density
for i=1:n
  TestPoints.Atmosphere.Density.Result(i)   = Atmosphere.Density.Data(i);
  TestPoints.Atmosphere.Density.Expected(i) = interp1(COESA_1976.arrZ,COESA_1976.arrDensity,Atmosphere.GeometricAlt.Data(i));
  TestPoints.Atmosphere.Density.Tolerance(i)= 1e-3;
  TestPoints.Atmosphere.Density.Type(i)     = cellstr('withinTolerance');
end

% pressure
for i=1:n
  TestPoints.Atmosphere.Pressure.Result(i)   = Atmosphere.Pressure.Data(i);
  TestPoints.Atmosphere.Pressure.Expected(i) = interp1(COESA_1976.arrZ,COESA_1976.arrPress,Atmosphere.GeometricAlt.Data(i));
  TestPoints.Atmosphere.Pressure.Tolerance(i)= 1e-3;
  TestPoints.Atmosphere.Pressure.Type(i)     = cellstr('withinTolerance');
end

% speed of sound
for i=1:n
  TestPoints.Atmosphere.Sound.Result(i)   = Atmosphere.Sound.Data(i);
  TestPoints.Atmosphere.Sound.Expected(i) = interp1(COESA_1976.arrZ,COESA_1976.arrSound,Atmosphere.GeometricAlt.Data(i));
  TestPoints.Atmosphere.Sound.Tolerance(i)= 1e-3;
  TestPoints.Atmosphere.Sound.Type(i)     = cellstr('withinTolerance');
end

%% Check Results:
check_results(TestPoints.Atmosphere.Density,'concise');
check_results(TestPoints.Atmosphere.Pressure,'concise');
check_results(TestPoints.Atmosphere.Sound,'concise');

%% Store Results:
% Inputs:
UnitTests.Atmosphere.Alt      = Alt;
% Outputs:
UnitTests.Atmosphere.Density  = Atmosphere.Density;
UnitTests.Atmosphere.Pressure = Atmosphere.Pressure;
UnitTests.Atmosphere.Sound    = Atmosphere.Sound;

clear Alt Atmosphere

%% Save Results:
save unit_test_data.mat UnitTests
save testpoints.mat TestPoints

%% clear workspace
clear TestInputs COESA_1976 
clear CASE_NUM ans tout i n
