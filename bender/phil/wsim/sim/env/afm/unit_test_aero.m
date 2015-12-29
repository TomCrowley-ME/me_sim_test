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

disp('Running Aero Model Unit Test...')

global CASE_NUM;

CASE_NUM = 0;
R2D      = 180/pi;

%% Initialize Aero Model
csu_afm_aerodynamics_init;

afm_winds_enable = 0;      % Turn OFF Winds
afm_cg_enable    = 0;      % 0=use CG at origin

%% Load Test Inputs
load('unit_test_inputs.mat')

%% CASE 1: Constant airspeed at zero angle of attack
%          Vehicle heading east, level flight, altitude=10m, forward velocity=5 m/s

% Define Test Conditions:
% P_i = [6378147 0 0]';
% V_i = [0 470.101094254277 0]';
TestInputs.StateBus.Lat     =0;
TestInputs.StateBus.Lon     =0;
TestInputs.StateBus.Alt     =10;
TestInputs.StateBus.AltDot  =0;
TestInputs.StateBus.U       =4.0;
TestInputs.StateBus.V       =0;
TestInputs.StateBus.W       =0;
TestInputs.StateBus.Udot    =0;
TestInputs.StateBus.Vdot    =0;
TestInputs.StateBus.Wdot    =0;
TestInputs.StateBus.phi     =-90;
TestInputs.StateBus.theta   =0;
TestInputs.StateBus.psi     =90;

% Run Model
sim('test_aero')

% Build TestPoints:
  % Forces
  TestPoints.Aero.Case1.Result(1)    = AeroForces.Data(end,1);
  TestPoints.Aero.Case1.Expected(1)  = -FlightPath.Qbar.Data(end)*AeroData.area*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CA',FlightPath.Mach.Data(end),FlightPath.AlphaEff.Data(end)*R2D);
  TestPoints.Aero.Case1.Tolerance(1) = 1e-3;
  TestPoints.Aero.Case1.Type(1)      = cellstr('withinTolerance');
  TestPoints.Aero.Case1.Result(2)    = AeroForces.Data(end,2);
  TestPoints.Aero.Case1.Expected(2)  =  FlightPath.Qbar.Data(end)*AeroData.area*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CN',FlightPath.Mach.Data(end),FlightPath.AlphaEff.Data(end)*R2D)*sin(-FlightPath.MuEff.Data(end));
  TestPoints.Aero.Case1.Tolerance(2) = 1e-3;
  TestPoints.Aero.Case1.Type(2)      = cellstr('withinTolerance');
  TestPoints.Aero.Case1.Result(3)    = AeroForces.Data(end,3);
  TestPoints.Aero.Case1.Expected(3)  = -FlightPath.Qbar.Data(end)*AeroData.area*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CN',FlightPath.Mach.Data(end),FlightPath.AlphaEff.Data(end)*R2D)*cos(-FlightPath.MuEff.Data(end));
  TestPoints.Aero.Case1.Tolerance(3) = 1e-3;
  TestPoints.Aero.Case1.Type(3)      = cellstr('withinTolerance');
%   % Moments
%   TestPoints.Aero.Case1.Result(4)    = AeroMoments.Data(end,1);
%   TestPoints.Aero.Case1.Expected(4)  = 0;
%   TestPoints.Aero.Case1.Tolerance(4) = 1e-3;
%   TestPoints.Aero.Case1.Type(4)      = cellstr('withinTolerance');
%   TestPoints.Aero.Case1.Result(5)    = AeroMoments.Data(end,2);
%   TestPoints.Aero.Case1.Expected(5)  = FlightPath.Qbar.Data(end)*AeroData.area*AeroData.chord*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CM',FlightPath.Mach.Data(end),FlightPath.AlphaEff.Data(end)*R2D)*cos(-FlightPath.MuEff.Data(end));
%   TestPoints.Aero.Case1.Tolerance(5) = 1e-3;
%   TestPoints.Aero.Case1.Type(5)      = cellstr('withinTolerance');
%   TestPoints.Aero.Case1.Result(6)    = AeroMoments.Data(end,3);
%   TestPoints.Aero.Case1.Expected(6)  = FlightPath.Qbar.Data(end)*AeroData.area*AeroData.chord*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CM',FlightPath.Mach.Data(end),FlightPath.AlphaEff.Data(end)*R2D)*sin(-FlightPath.MuEff.Data(end));
%   TestPoints.Aero.Case1.Tolerance(6) = 1e-3;
%   TestPoints.Aero.Case1.Type(6)      = cellstr('withinTolerance');

% Check Results:
check_results(TestPoints.Aero.Case1,'concise');

% Store Results:
% Inputs:
UnitTests.Aero.Case1.Alt = Alt;
UnitTests.Aero.Case1.P_i = P_i;
UnitTests.Aero.Case1.V_i = V_i;
% Outputs:
UnitTests.Aero.Case1.AeroForces  = AeroForces;
UnitTests.Aero.Case1.AeroMoments = AeroMoments;
UnitTests.Aero.Case1.FlightPath  = FlightPath;
UnitTests.Aero.Case1.WindFrame   = WindFrame;

clear Alt P_i V_i AeroForces AeroMoments FlightPath WindFrame

%% CASE 2: Constant airspeed at 90 deg angle of attack
%          Vehicle heading north, level flight, altitude=40m, forward velocity=4 m/s

% Define Test Conditions:
% P_i = [6378147 0 0]';
% V_i = [0 470.101094254277 0]';
TestInputs.StateBus.Lat     =0;
TestInputs.StateBus.Lon     =0;
TestInputs.StateBus.Alt     =40;
TestInputs.StateBus.AltDot  =0;
TestInputs.StateBus.U       =0;
TestInputs.StateBus.V       =0;
TestInputs.StateBus.W       =4.0;
TestInputs.StateBus.Udot    =0;
TestInputs.StateBus.Vdot    =0;
TestInputs.StateBus.Wdot    =0;
TestInputs.StateBus.phi     =0;
TestInputs.StateBus.theta   =-90;
TestInputs.StateBus.psi     =0;

% Run Model
sim('test_aero')

% Build TestPoints:
  % Forces
  TestPoints.Aero.Case2.Result(1)    = AeroForces.Data(end,1);
  TestPoints.Aero.Case2.Expected(1)  = -FlightPath.Qbar.Data(end)*AeroData.area*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CA',FlightPath.Mach.Data(end),FlightPath.AlphaEff.Data(end)*R2D);
  TestPoints.Aero.Case2.Tolerance(1) = 1e-3;
  TestPoints.Aero.Case2.Type(1)      = cellstr('withinTolerance');
  TestPoints.Aero.Case2.Result(2)    = AeroForces.Data(end,2);
  TestPoints.Aero.Case2.Expected(2)  =  FlightPath.Qbar.Data(end)*AeroData.area*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CN',FlightPath.Mach.Data(end),FlightPath.AlphaEff.Data(end)*R2D)*sin(-FlightPath.MuEff.Data(end));
  TestPoints.Aero.Case2.Tolerance(2) = 1e-3;
  TestPoints.Aero.Case2.Type(2)      = cellstr('withinTolerance');
  TestPoints.Aero.Case2.Result(3)    = AeroForces.Data(end,3);
  TestPoints.Aero.Case2.Expected(3)  = -FlightPath.Qbar.Data(end)*AeroData.area*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CN',FlightPath.Mach.Data(end),FlightPath.AlphaEff.Data(end)*R2D)*cos(-FlightPath.MuEff.Data(end));
  TestPoints.Aero.Case2.Tolerance(3) = 1e-3;
  TestPoints.Aero.Case2.Type(3)      = cellstr('withinTolerance');
%   % Moments
%   TestPoints.Aero.Case2.Result(4)    = AeroMoments.Data(end,1);
%   TestPoints.Aero.Case2.Expected(4)  = 0;
%   TestPoints.Aero.Case2.Tolerance(4) = 1e-3;
%   TestPoints.Aero.Case2.Type(4)      = cellstr('withinTolerance');
%   TestPoints.Aero.Case2.Result(5)    = AeroMoments.Data(end,2);
%   TestPoints.Aero.Case2.Expected(5)  = FlightPath.Qbar.Data(end)*AeroData.area*AeroData.chord*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CM',FlightPath.Mach.Data(end),FlightPath.AlphaEff.Data(end)*R2D)*cos(-FlightPath.MuEff.Data(end));
%   TestPoints.Aero.Case2.Tolerance(5) = 1e-3;
%   TestPoints.Aero.Case2.Type(5)      = cellstr('withinTolerance');
%   TestPoints.Aero.Case2.Result(6)    = AeroMoments.Data(end,3);
%   TestPoints.Aero.Case2.Expected(6)  = FlightPath.Qbar.Data(end)*AeroData.area*AeroData.chord*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CM',FlightPath.Mach.Data(end),FlightPath.AlphaEff.Data(end)*R2D)*sin(-FlightPath.MuEff.Data(end));
%   TestPoints.Aero.Case2.Tolerance(6) = 1e-3;
%   TestPoints.Aero.Case2.Type(6)      = cellstr('withinTolerance');

% Check Results:
check_results(TestPoints.Aero.Case2,'concise');

% Store Results:
% Inputs:
UnitTests.Aero.Case2.Alt = Alt;
UnitTests.Aero.Case2.P_i = P_i;
UnitTests.Aero.Case2.V_i = V_i;
% Outputs:
UnitTests.Aero.Case2.AeroForces  = AeroForces;
UnitTests.Aero.Case2.AeroMoments = AeroMoments;
UnitTests.Aero.Case2.FlightPath  = FlightPath;
UnitTests.Aero.Case2.WindFrame   = WindFrame;

clear Alt P_i V_i AeroForces AeroMoments FlightPath WindFrame

%% CASE 3: Varying relative forward velocity at zero angle of attack
%          Vehicle heading west, level flight, altitude=15m
%          initial velocity=0 m/s, increasing at 0.8 m/s^2

% Define Test Conditions:
% P_i = [6378152 0 0]';
% V_i = [0 470.101094254277 0]';  % initial
% V_i = [0 460.101094254277 0]';  % final
TestInputs.StateBus.Lat     =0;
TestInputs.StateBus.Lon     =0;
TestInputs.StateBus.Alt     =15;
TestInputs.StateBus.AltDot  =0;
TestInputs.StateBus.U       =0;
TestInputs.StateBus.V       =0;
TestInputs.StateBus.W       =0;
TestInputs.StateBus.Udot    =0.4999;
TestInputs.StateBus.Vdot    =0;
TestInputs.StateBus.Wdot    =0;
TestInputs.StateBus.phi     =90;
TestInputs.StateBus.theta   =0;
TestInputs.StateBus.psi     =-90;

% Run Model
sim('test_aero')

% Build TestPoints:
for i=1:size(AeroForces.Data,1)
  % Forces
  TestPoints.Aero.Case3.Result(i,1)    = AeroForces.Data(i,1);
  TestPoints.Aero.Case3.Expected(i,1)  = -FlightPath.Qbar.Data(i)*AeroData.area*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CA',FlightPath.Mach.Data(i),FlightPath.AlphaEff.Data(i)*R2D);
  TestPoints.Aero.Case3.Tolerance(i,1) = 1e-3;
  TestPoints.Aero.Case3.Type(i,1)      = cellstr('withinTolerance');
  TestPoints.Aero.Case3.Result(i,2)    = AeroForces.Data(i,2);
  TestPoints.Aero.Case3.Expected(i,2)  =  FlightPath.Qbar.Data(i)*AeroData.area*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CN',FlightPath.Mach.Data(i),FlightPath.AlphaEff.Data(i)*R2D)*sin(-FlightPath.MuEff.Data(i));
  TestPoints.Aero.Case3.Tolerance(i,2) = 1e-3;
  TestPoints.Aero.Case3.Type(i,2)      = cellstr('withinTolerance');
  TestPoints.Aero.Case3.Result(i,3)    = AeroForces.Data(i,3);
  TestPoints.Aero.Case3.Expected(i,3)  = -FlightPath.Qbar.Data(i)*AeroData.area*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CN',FlightPath.Mach.Data(i),FlightPath.AlphaEff.Data(i)*R2D)*cos(-FlightPath.MuEff.Data(i));
  TestPoints.Aero.Case3.Tolerance(i,3) = 1e-3;
  TestPoints.Aero.Case3.Type(i,3)      = cellstr('withinTolerance');
%   % Moments
%   TestPoints.Aero.Case3.Result(i,4)    = AeroMoments.Data(i,1);
%   TestPoints.Aero.Case3.Expected(i,4)  = 0;
%   TestPoints.Aero.Case3.Tolerance(i,4) = 1e-3;
%   TestPoints.Aero.Case3.Type(i,4)      = cellstr('withinTolerance');
%   TestPoints.Aero.Case3.Result(i,5)    = AeroMoments.Data(i,2);
%   TestPoints.Aero.Case3.Expected(i,5)  = FlightPath.Qbar.Data(i)*AeroData.area*AeroData.chord*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CM',FlightPath.Mach.Data(i),FlightPath.AlphaEff.Data(i)*R2D)*cos(-FlightPath.MuEff.Data(i));
%   TestPoints.Aero.Case3.Tolerance(i,5) = 1e-3;
%   TestPoints.Aero.Case3.Type(i,5)      = cellstr('withinTolerance');
%   TestPoints.Aero.Case3.Result(i,6)    = AeroMoments.Data(i,3);
%   TestPoints.Aero.Case3.Expected(i,6)  = FlightPath.Qbar.Data(i)*AeroData.area*AeroData.chord*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CM',FlightPath.Mach.Data(i),FlightPath.AlphaEff.Data(i)*R2D)*sin(-FlightPath.MuEff.Data(i));
%   TestPoints.Aero.Case3.Tolerance(i,6) = 1e-3;
%   TestPoints.Aero.Case3.Type(i,6)      = cellstr('withinTolerance');
end

% Check Results:
check_results(TestPoints.Aero.Case3,'concise');

% Store Results:
% Inputs:
UnitTests.Aero.Case3.Alt = Alt;
UnitTests.Aero.Case3.P_i = P_i;
UnitTests.Aero.Case3.V_i = V_i;
% Outputs:
UnitTests.Aero.Case3.AeroForces  = AeroForces;
UnitTests.Aero.Case3.AeroMoments = AeroMoments;
UnitTests.Aero.Case3.FlightPath  = FlightPath;
UnitTests.Aero.Case3.WindFrame   = WindFrame;

clear Alt P_i V_i AeroForces AeroMoments FlightPath WindFrame

%check if data<eps, set to exactly zero
for i=1:size(UnitTests.Aero.Case3.Alt.Data,2);
    if abs(UnitTests.Aero.Case3.AeroForces.Data(:,1))<1e-6,UnitTests.Aero.Case3.AeroForces.Data(:,1)=0;end
    if abs(UnitTests.Aero.Case3.AeroForces.Data(:,2))<1e-6,UnitTests.Aero.Case3.AeroForces.Data(:,2)=0;end
    if abs(UnitTests.Aero.Case3.AeroForces.Data(:,3))<1e-6,UnitTests.Aero.Case3.AeroForces.Data(:,3)=0;end
    if abs(UnitTests.Aero.Case3.WindFrame.Data(:,1))<1e-6,UnitTests.Aero.Case3.WindFrame.Data(:,1)=0;end
    if abs(UnitTests.Aero.Case3.WindFrame.Data(:,2))<1e-6,UnitTests.Aero.Case3.WindFrame.Data(:,2)=0;end
    if abs(UnitTests.Aero.Case3.WindFrame.Data(:,3))<1e-6,UnitTests.Aero.Case3.WindFrame.Data(:,3)=0;end
end

%% CASE 4: Varying relative vertical velocity (angle of attack)
%          Vehicle heading east, level flight, altitude=25m
%          forward velocity=2 m/s
%          initial alpha=-45 deg, increasing at 9 deg/s to +45 deg

% Define Test Conditions:
% P_i = [6378162 0 0]';
% V_i = [0 465.101094254277 5]';
TestInputs.StateBus.Lat     =0;
TestInputs.StateBus.Lon     =0;
TestInputs.StateBus.Alt     =25;
TestInputs.StateBus.AltDot  =0;
TestInputs.StateBus.U       =2;
TestInputs.StateBus.V       =0;
TestInputs.StateBus.W       =-2;
TestInputs.StateBus.Udot    =0;
TestInputs.StateBus.Vdot    =0;
TestInputs.StateBus.Wdot    =0.4;
TestInputs.StateBus.phi     =-90;
TestInputs.StateBus.theta   = 0;
TestInputs.StateBus.psi     =90;

% Run Model
sim('test_aero')

% Build TestPoints:
for i=1:size(AeroForces.Data,1)
  % Forces
  TestPoints.Aero.Case4.Result(i,1)    = AeroForces.Data(i,1);
  TestPoints.Aero.Case4.Expected(i,1)  = -FlightPath.Qbar.Data(i)*AeroData.area*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CA',FlightPath.Mach.Data(i),FlightPath.AlphaEff.Data(i)*R2D);
  TestPoints.Aero.Case4.Tolerance(i,1) = 1e-3;
  TestPoints.Aero.Case4.Type(i,1)      = cellstr('withinTolerance');
  TestPoints.Aero.Case4.Result(i,2)    = AeroForces.Data(i,2);
  TestPoints.Aero.Case4.Expected(i,2)  =  FlightPath.Qbar.Data(i)*AeroData.area*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CN',FlightPath.Mach.Data(i),FlightPath.AlphaEff.Data(i)*R2D)*sin(-FlightPath.MuEff.Data(i));
  TestPoints.Aero.Case4.Tolerance(i,2) = 1e-3;
  TestPoints.Aero.Case4.Type(i,2)      = cellstr('withinTolerance');
  TestPoints.Aero.Case4.Result(i,3)    = AeroForces.Data(i,3);
  TestPoints.Aero.Case4.Expected(i,3)  = -FlightPath.Qbar.Data(i)*AeroData.area*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CN',FlightPath.Mach.Data(i),FlightPath.AlphaEff.Data(i)*R2D)*cos(-FlightPath.MuEff.Data(i));
  TestPoints.Aero.Case4.Tolerance(i,3) = 1e-3;
  TestPoints.Aero.Case4.Type(i,3)      = cellstr('withinTolerance');
%   % Moments
%   TestPoints.Aero.Case4.Result(i,4)    = AeroMoments.Data(i,1);
%   TestPoints.Aero.Case4.Expected(i,4)  = 0;
%   TestPoints.Aero.Case4.Tolerance(i,4) = 1e-3;
%   TestPoints.Aero.Case4.Type(i,4)      = cellstr('withinTolerance');
%   TestPoints.Aero.Case4.Result(i,5)    = AeroMoments.Data(i,2);
%   TestPoints.Aero.Case4.Expected(i,5)  = FlightPath.Qbar.Data(i)*AeroData.area*AeroData.chord*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CM',FlightPath.Mach.Data(i),FlightPath.AlphaEff.Data(i)*R2D)*cos(-FlightPath.MuEff.Data(i));
%   TestPoints.Aero.Case4.Tolerance(i,5) = 1e-3;
%   TestPoints.Aero.Case4.Type(i,5)      = cellstr('withinTolerance');
%   TestPoints.Aero.Case4.Result(i,6)    = AeroMoments.Data(i,3);
%   TestPoints.Aero.Case4.Expected(i,6)  = FlightPath.Qbar.Data(i)*AeroData.area*AeroData.chord*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CM',FlightPath.Mach.Data(i),FlightPath.AlphaEff.Data(i)*R2D)*sin(-FlightPath.MuEff.Data(i));
%   TestPoints.Aero.Case4.Tolerance(i,6) = 1e-3;
%   TestPoints.Aero.Case4.Type(i,6)      = cellstr('withinTolerance');
end

% Check Results:
check_results(TestPoints.Aero.Case4,'concise');

% Store Results:
% Inputs:
UnitTests.Aero.Case4.Alt = Alt;
UnitTests.Aero.Case4.P_i = P_i;
UnitTests.Aero.Case4.V_i = V_i;
% Outputs:
UnitTests.Aero.Case4.AeroForces  = AeroForces;
UnitTests.Aero.Case4.AeroMoments = AeroMoments;
UnitTests.Aero.Case4.FlightPath  = FlightPath;
UnitTests.Aero.Case4.WindFrame   = WindFrame;

clear Alt P_i V_i AeroForces AeroMoments FlightPath WindFrame

%check if data<eps, set to exactly zero
for i=1:size(UnitTests.Aero.Case4.Alt.Data,2);
    if abs(UnitTests.Aero.Case4.AeroForces.Data(:,1))<1e-6,UnitTests.Aero.Case4.AeroForces.Data(:,1)=0;end
    if abs(UnitTests.Aero.Case4.AeroForces.Data(:,2))<1e-6,UnitTests.Aero.Case4.AeroForces.Data(:,2)=0;end
    if abs(UnitTests.Aero.Case4.AeroForces.Data(:,3))<1e-6,UnitTests.Aero.Case4.AeroForces.Data(:,3)=0;end
    if abs(UnitTests.Aero.Case4.WindFrame.Data(:,1))<1e-6,UnitTests.Aero.Case4.WindFrame.Data(:,1)=0;end
    if abs(UnitTests.Aero.Case4.WindFrame.Data(:,2))<1e-6,UnitTests.Aero.Case4.WindFrame.Data(:,2)=0;end
    if abs(UnitTests.Aero.Case4.WindFrame.Data(:,3))<1e-6,UnitTests.Aero.Case4.WindFrame.Data(:,3)=0;end
end

%% CASE 5: Varying relative lateral velocity (sideslip angle)
%          Vehicle heading east, level flight, altitude=35m,
%          forward velocity=2 m/s, vertical velocity=2 m/s, constant alpha=45 deg
%          initial beta=-41.81 deg, increasing at 8.362 deg/s to +41.81 deg

% Define Test Conditions:
% P_i = [6378162 0 0]';
% V_i = [0 465.101094254277 5]';
TestInputs.StateBus.Lat     =0;
TestInputs.StateBus.Lon     =0;
TestInputs.StateBus.Alt     =35;
TestInputs.StateBus.AltDot  =0;
TestInputs.StateBus.U       =2;
TestInputs.StateBus.V       =-2;
TestInputs.StateBus.W       =2;
TestInputs.StateBus.Udot    =0;
TestInputs.StateBus.Vdot    =0.4;
TestInputs.StateBus.Wdot    =0;
TestInputs.StateBus.phi     =-90;
TestInputs.StateBus.theta   = 0;
TestInputs.StateBus.psi     =90;

% Run Model
sim('test_aero')

% Build TestPoints:
for i=1:size(AeroForces.Data,1)
  % Forces
  TestPoints.Aero.Case5.Result(i,1)    = AeroForces.Data(i,1);
  TestPoints.Aero.Case5.Expected(i,1)  = -FlightPath.Qbar.Data(i)*AeroData.area*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CA',FlightPath.Mach.Data(i),FlightPath.AlphaEff.Data(i)*R2D);
  TestPoints.Aero.Case5.Tolerance(i,1) = 1e-3;
  TestPoints.Aero.Case5.Type(i,1)      = cellstr('withinTolerance');
  TestPoints.Aero.Case5.Result(i,2)    = AeroForces.Data(i,2);
  TestPoints.Aero.Case5.Expected(i,2)  =  FlightPath.Qbar.Data(i)*AeroData.area*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CN',FlightPath.Mach.Data(i),FlightPath.AlphaEff.Data(i)*R2D)*sin(-FlightPath.MuEff.Data(i));
  TestPoints.Aero.Case5.Tolerance(i,2) = 1e-3;
  TestPoints.Aero.Case5.Type(i,2)      = cellstr('withinTolerance');
  TestPoints.Aero.Case5.Result(i,3)    = AeroForces.Data(i,3);
  TestPoints.Aero.Case5.Expected(i,3)  = -FlightPath.Qbar.Data(i)*AeroData.area*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CN',FlightPath.Mach.Data(i),FlightPath.AlphaEff.Data(i)*R2D)*cos(-FlightPath.MuEff.Data(i));
  TestPoints.Aero.Case5.Tolerance(i,3) = 1e-3;
  TestPoints.Aero.Case5.Type(i,3)      = cellstr('withinTolerance');
%   % Moments
%   TestPoints.Aero.Case5.Result(i,4)    = AeroMoments.Data(i,1);
%   TestPoints.Aero.Case5.Expected(i,4)  = 0;
%   TestPoints.Aero.Case5.Tolerance(i,4) = 1e-3;
%   TestPoints.Aero.Case5.Type(i,4)      = cellstr('withinTolerance');
%   TestPoints.Aero.Case5.Result(i,5)    = AeroMoments.Data(i,2);
%   TestPoints.Aero.Case5.Expected(i,5)  = FlightPath.Qbar.Data(i)*AeroData.area*AeroData.chord*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.Cm',FlightPath.Mach.Data(i),FlightPath.AlphaEff.Data(i)*R2D)*cos(-FlightPath.MuEff.Data(i));
%   TestPoints.Aero.Case5.Tolerance(i,5) = 1e-3;
%   TestPoints.Aero.Case5.Type(i,5)      = cellstr('withinTolerance');
%   TestPoints.Aero.Case5.Result(i,6)    = AeroMoments.Data(i,3);
%   TestPoints.Aero.Case5.Expected(i,6)  = FlightPath.Qbar.Data(i)*AeroData.area*AeroData.chord*interp2(AeroData.Static.Mach,AeroData.Static.Alpha,AeroData.Static.CM',FlightPath.Mach.Data(i),FlightPath.AlphaEff.Data(i)*R2D)*sin(-FlightPath.MuEff.Data(i));
%   TestPoints.Aero.Case5.Tolerance(i,6) = 1e-3;
%   TestPoints.Aero.Case5.Type(i,6)      = cellstr('withinTolerance');
end

% Check Results:
check_results(TestPoints.Aero.Case5,'concise');

% Store Results:
% Inputs:
UnitTests.Aero.Case5.Alt = Alt;
UnitTests.Aero.Case5.P_i = P_i;
UnitTests.Aero.Case5.V_i = V_i;
% Outputs:
UnitTests.Aero.Case5.AeroForces  = AeroForces;
UnitTests.Aero.Case5.AeroMoments = AeroMoments;
UnitTests.Aero.Case5.FlightPath  = FlightPath;
UnitTests.Aero.Case5.WindFrame   = WindFrame;

clear Alt P_i V_i AeroForces AeroMoments FlightPath WindFrame

%check if data<eps, set to exactly zero
for i=1:size(UnitTests.Aero.Case5.Alt.Data,2);
    if abs(UnitTests.Aero.Case5.AeroForces.Data(:,1))<1e-6,UnitTests.Aero.Case5.AeroForces.Data(:,1)=0;end
    if abs(UnitTests.Aero.Case5.AeroForces.Data(:,2))<1e-6,UnitTests.Aero.Case5.AeroForces.Data(:,2)=0;end
    if abs(UnitTests.Aero.Case5.AeroForces.Data(:,3))<1e-6,UnitTests.Aero.Case5.AeroForces.Data(:,3)=0;end
    if abs(UnitTests.Aero.Case5.WindFrame.Data(:,1))<1e-6,UnitTests.Aero.Case5.WindFrame.Data(:,1)=0;end
    if abs(UnitTests.Aero.Case5.WindFrame.Data(:,2))<1e-6,UnitTests.Aero.Case5.WindFrame.Data(:,2)=0;end
    if abs(UnitTests.Aero.Case5.WindFrame.Data(:,3))<1e-6,UnitTests.Aero.Case5.WindFrame.Data(:,3)=0;end
end

%% Save Results:
save unit_test_data.mat UnitTests
save testpoints.mat TestPoints

%% clear workspace
clear TestInputs AeroData AeroCoeffs Winds
clear afm_forces_enable afm_moments_enable afm_cg_enable afm_winds_enable
clear R2D CASE_NUM Epoch ans tout i
