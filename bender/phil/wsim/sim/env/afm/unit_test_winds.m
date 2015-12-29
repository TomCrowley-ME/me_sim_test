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

disp('Running Wind Model Unit Test...')

global CASE_NUM;

CASE_NUM = 0;
D2R      = pi/180;

%% Load Winds Data
load('Winds.mat')

afm_winds_enable = 1;      % Turn ON Winds

% scale down altitude
scale=1000;
Winds.Altitude=Winds.Altitude/scale;

%% Load Test Data Inputs
load('unit_test_inputs.mat')

%% CASE 1: Vehicle heading east, level flight, initial altitude=10m, forward velocity=10 m/s

% Define Test Conditions:
TestInputs.StateBus.V_i   =[0 475.101094254277 0]';
TestInputs.StateBus.Lat   =0;
TestInputs.StateBus.Lon   =0;
TestInputs.StateBus.AltDot=0;
TestInputs.StateBus.Alt   =10;
TestInputs.StateBus.phi   =-90;
TestInputs.StateBus.theta =0;
TestInputs.StateBus.psi   =90;

% Run Model
sim('test_winds');

% Build TestPoints:
n=find(Winds.Altitude==Alt.Data(end));
% test #1
TestPoints.Winds.Case1.Result(1)   = Wind_i.Data(end,2);
TestPoints.Winds.Case1.Expected(1) = Winds.Speed(n)*sin(Winds.Azimuth(n)*D2R);
TestPoints.Winds.Case1.Tolerance(1)= 1e-3;
TestPoints.Winds.Case1.Type(1)     = cellstr('withinTolerance');
% test #2
TestPoints.Winds.Case1.Result(2)   = Wind_i.Data(end,3);
TestPoints.Winds.Case1.Expected(2) = Winds.Speed(n)*cos(Winds.Azimuth(n)*D2R);
TestPoints.Winds.Case1.Tolerance(2)= 1e-3;
TestPoints.Winds.Case1.Type(2)     = cellstr('withinTolerance');
% test #3
TestPoints.Winds.Case1.Result(3)   = Vrel_i.Data(end,1);
TestPoints.Winds.Case1.Expected(3) = TestInputs.StateBus.V_i(1)-Wind_i.Data(end,1)-Vomega_i.Data(end,1);
TestPoints.Winds.Case1.Tolerance(3)= 1e-3;
TestPoints.Winds.Case1.Type(3)     = cellstr('withinTolerance');
% test #4
TestPoints.Winds.Case1.Result(4)   = Vrel_i.Data(end,2);
TestPoints.Winds.Case1.Expected(4) = TestInputs.StateBus.V_i(2)-Wind_i.Data(end,2)-Vomega_i.Data(end,2);
TestPoints.Winds.Case1.Tolerance(4)= 1e-3;
TestPoints.Winds.Case1.Type(4)     = cellstr('withinTolerance');
% test #5
TestPoints.Winds.Case1.Result(5)   = Vrel_i.Data(end,3);
TestPoints.Winds.Case1.Expected(5) = TestInputs.StateBus.V_i(3)-Wind_i.Data(end,3)-Vomega_i.Data(end,3);
TestPoints.Winds.Case1.Tolerance(5)= 1e-3;
TestPoints.Winds.Case1.Type(5)     = cellstr('withinTolerance');

% Check Results:
check_results(TestPoints.Winds.Case1,'concise');

% Store Results:
% Inputs:
UnitTests.Winds.Case1.Inputs = TestInputs.StateBus;
UnitTests.Winds.Case1.Alt    = Alt;
% Outputs:
UnitTests.Winds.Case1.Wind_i   = Wind_i;
UnitTests.Winds.Case1.Wind_b   = Wind_b;
UnitTests.Winds.Case1.Vomega_i = Vomega_i;
UnitTests.Winds.Case1.Vrel_i   = Vrel_i;
UnitTests.Winds.Case1.Vrel_b   = Vrel_b;

clear Alt Wind_i Wind_b Vomega_i Vrel_i Vrel_b V_i Pdot_i

%% CASE 2: Vehicle heading north, level flight, initial altitude=20m, forward velocity=10 m/s

% Define Test Conditions:
TestInputs.StateBus.P_i   =[6378137 0 0]';
TestInputs.StateBus.V_i   =[0 465.101094254277 10]';
TestInputs.StateBus.Lat   =0;
TestInputs.StateBus.Lon   =0;
TestInputs.StateBus.AltDot=0;
TestInputs.StateBus.Alt   =20;
TestInputs.StateBus.phi   =0;
TestInputs.StateBus.theta =-90;
TestInputs.StateBus.psi   =0;

% Run Model
sim('test_winds');

% Build TestPoints:
n=find(Winds.Altitude==Alt.Data(end));
% test #1
TestPoints.Winds.Case2.Result(1)   = Wind_i.Data(end,2);
TestPoints.Winds.Case2.Expected(1) = Winds.Speed(n)*sin(Winds.Azimuth(n)*D2R);
TestPoints.Winds.Case2.Tolerance(1)= 1e-3;
TestPoints.Winds.Case2.Type(1)     = cellstr('withinTolerance');
% test #2
TestPoints.Winds.Case2.Result(2)   = Wind_i.Data(end,3);
TestPoints.Winds.Case2.Expected(2) = Winds.Speed(n)*cos(Winds.Azimuth(n)*D2R);
TestPoints.Winds.Case2.Tolerance(2)= 1e-3;
TestPoints.Winds.Case2.Type(2)     = cellstr('withinTolerance');
% test #3
TestPoints.Winds.Case2.Result(3)   = Vrel_i.Data(end,1);
TestPoints.Winds.Case2.Expected(3) = TestInputs.StateBus.V_i(1)-Wind_i.Data(end,1)-Vomega_i.Data(end,1);
TestPoints.Winds.Case2.Tolerance(3)= 1e-3;
TestPoints.Winds.Case2.Type(3)     = cellstr('withinTolerance');
% test #4
TestPoints.Winds.Case2.Result(4)   = Vrel_i.Data(end,2);
TestPoints.Winds.Case2.Expected(4) = TestInputs.StateBus.V_i(2)-Wind_i.Data(end,2)-Vomega_i.Data(end,2);
TestPoints.Winds.Case2.Tolerance(4)= 1e-3;
TestPoints.Winds.Case2.Type(4)     = cellstr('withinTolerance');
% test #5
TestPoints.Winds.Case2.Result(5)   = Vrel_i.Data(end,3);
TestPoints.Winds.Case2.Expected(5) = TestInputs.StateBus.V_i(3)-Wind_i.Data(end,3)-Vomega_i.Data(end,3);
TestPoints.Winds.Case2.Tolerance(5)= 1e-3;
TestPoints.Winds.Case2.Type(5)     = cellstr('withinTolerance');

% Check Results:
check_results(TestPoints.Winds.Case2,'concise');

% Store Results:
% Inputs:
UnitTests.Winds.Case2.Inputs = TestInputs.StateBus;
UnitTests.Winds.Case2.Alt    = Alt;
% Outputs:
UnitTests.Winds.Case2.Wind_i   = Wind_i;
UnitTests.Winds.Case2.Wind_b   = Wind_b;
UnitTests.Winds.Case2.Vomega_i = Vomega_i;
UnitTests.Winds.Case2.Vrel_i   = Vrel_i;
UnitTests.Winds.Case2.Vrel_b   = Vrel_b;

clear Alt Wind_i Wind_b Vomega_i Vrel_i Vrel_b V_i Pdot_i

%% CASE 3: Vehicle heading vertical, initial altitude=10m, forward velocity=10 m/s

% Define Test Conditions:
TestInputs.StateBus.P_i   =[6378137 0 0]';
TestInputs.StateBus.V_i   =[10 465.101094254277 0]';
TestInputs.StateBus.Lat   =0;
TestInputs.StateBus.Lon   =0;
TestInputs.StateBus.AltDot=1;
TestInputs.StateBus.Alt   =10;
TestInputs.StateBus.phi   =0;
TestInputs.StateBus.theta =0;
TestInputs.StateBus.psi   =0;

% Run Model
sim('test_winds');

% Build TestPoints:
n=find(Winds.Altitude==Alt.Data(end));
% test #1
TestPoints.Winds.Case3.Result(1)   = Wind_i.Data(end,2);
TestPoints.Winds.Case3.Expected(1) = Winds.Speed(n)*sin(Winds.Azimuth(n)*D2R);
TestPoints.Winds.Case3.Tolerance(1)= 1e-3;
TestPoints.Winds.Case3.Type(1)     = cellstr('withinTolerance');
% test #2
TestPoints.Winds.Case3.Result(2)   = Wind_i.Data(end,3);
TestPoints.Winds.Case3.Expected(2) = Winds.Speed(n)*cos(Winds.Azimuth(n)*D2R);
TestPoints.Winds.Case3.Tolerance(2)= 1e-3;
TestPoints.Winds.Case3.Type(2)     = cellstr('withinTolerance');
% test #3
TestPoints.Winds.Case3.Result(3)   = Vrel_i.Data(end,1);
TestPoints.Winds.Case3.Expected(3) = TestInputs.StateBus.V_i(1)-Wind_i.Data(end,1)-Vomega_i.Data(end,1);
TestPoints.Winds.Case3.Tolerance(3)= 1e-3;
TestPoints.Winds.Case3.Type(3)     = cellstr('withinTolerance');
% test #4
TestPoints.Winds.Case3.Result(4)   = Vrel_i.Data(end,2);
TestPoints.Winds.Case3.Expected(4) = TestInputs.StateBus.V_i(2)-Wind_i.Data(end,2)-Vomega_i.Data(end,2);
TestPoints.Winds.Case3.Tolerance(4)= 1e-3;
TestPoints.Winds.Case3.Type(4)     = cellstr('withinTolerance');
% test #5
TestPoints.Winds.Case3.Result(5)   = Vrel_i.Data(end,3);
TestPoints.Winds.Case3.Expected(5) = TestInputs.StateBus.V_i(3)-Wind_i.Data(end,3)-Vomega_i.Data(end,3);
TestPoints.Winds.Case3.Tolerance(5)= 1e-3;
TestPoints.Winds.Case3.Type(5)     = cellstr('withinTolerance');

% Check Results:
check_results(TestPoints.Winds.Case3,'concise');

% Store Results:
% Inputs:
UnitTests.Winds.Case3.Inputs = TestInputs.StateBus;
UnitTests.Winds.Case3.Alt    = Alt;
% Outputs:
UnitTests.Winds.Case3.Wind_i   = Wind_i;
UnitTests.Winds.Case3.Wind_b   = Wind_b;
UnitTests.Winds.Case3.Vomega_i = Vomega_i;
UnitTests.Winds.Case3.Vrel_i   = Vrel_i;
UnitTests.Winds.Case3.Vrel_b   = Vrel_b;

clear Alt Wind_i Wind_b Vomega_i Vrel_i Vrel_b V_i Pdot_i

%% CASE 4: Vehicle heading west, descending at 1 m/s, initial altitude=15m, forward velocity=10 m/s

% Define Test Conditions:
TestInputs.StateBus.P_i   =[6378137 0 0]';
TestInputs.StateBus.V_i   =[0 455.101094254277 0]';
TestInputs.StateBus.Lat   =0;
TestInputs.StateBus.Lon   =0;
TestInputs.StateBus.AltDot=-1;
TestInputs.StateBus.Alt   =15;
TestInputs.StateBus.phi   =90;
TestInputs.StateBus.theta =0;
TestInputs.StateBus.psi   =-90;

% Run Model
sim('test_winds');

% Build TestPoints:
n=size(Alt.Data,1);
for i=1:n
  TestPoints.Winds.Case4.Result(i,1)   = Wind_i.Data(i,2);
  TestPoints.Winds.Case4.Expected(i,1) = interp1(Winds.Altitude,Winds.Speed,Alt.Data(i))*sin(interp1(Winds.Altitude,Winds.Azimuth,Alt.Data(i))*D2R);
  TestPoints.Winds.Case4.Tolerance(i,1)= 1e-3;
  TestPoints.Winds.Case4.Type(i,1)     = cellstr('withinTolerance');
end
for i=1:n
  TestPoints.Winds.Case4.Result(i,2)   = Wind_i.Data(i,3);
  TestPoints.Winds.Case4.Expected(i,2) = interp1(Winds.Altitude,Winds.Speed,Alt.Data(i))*cos(interp1(Winds.Altitude,Winds.Azimuth,Alt.Data(i))*D2R);
  TestPoints.Winds.Case4.Tolerance(i,2)= 1e-3;
  TestPoints.Winds.Case4.Type(i,2)     = cellstr('withinTolerance');
end

% Check Results:
check_results(TestPoints.Winds.Case4,'concise');

% Store Results:
% Inputs:
UnitTests.Winds.Case4.Inputs = TestInputs.StateBus;
UnitTests.Winds.Case4.Alt    = Alt;
% Outputs:
UnitTests.Winds.Case4.Wind_i   = Wind_i;
UnitTests.Winds.Case4.Wind_b   = Wind_b;
UnitTests.Winds.Case4.Vomega_i = Vomega_i;
UnitTests.Winds.Case4.Vrel_i   = Vrel_i;
UnitTests.Winds.Case4.Vrel_b   = Vrel_b;

clear Alt Wind_i Wind_b Vomega_i Vrel_i Vrel_b V_i Pdot_i

%% Save Results:
save unit_test_data.mat UnitTests
save testpoints.mat TestPoints

%% clear workspace
clear TestInputs
clear afm_winds_enable
clear D2R CASE_NUM Epoch n scale ans tout i

