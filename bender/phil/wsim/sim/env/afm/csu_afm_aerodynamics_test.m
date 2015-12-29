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

%% UNIT_TEST Executive

% This script will run all UNIT TESTS by simply calling the run_*** files
% and then the corresponding plot_*** files:

clear all,close all,clc

% Delete Exisiting Data Files:
if exist('unit_tests.mat'),delete unit_tests.mat;end
if exist('testpoints.mat'),delete testpoints.mat;end

% Run:
unit_test_aero;
unit_test_winds
unit_test_atmosphere;

% Plot:
plot_aero;
plot_winds;
plot_atmosphere;
