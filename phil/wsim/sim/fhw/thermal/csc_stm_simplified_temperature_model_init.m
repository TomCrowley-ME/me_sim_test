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
% csc_ltm_linear_temperature_model_init.m                                 %
%                                                                         %
% 07/10/14                                                                %
%-------------------------------------------------------------------------%


% load in CSV file from Gayle
filename = 'MTV1X_test_temperature_model_data.csv';
export_thermal_data_to_json(filename, 'matlab')

% jake is taking care of this in the sim-side microcontroller
stm_celcius_to_bits_slope = 10.24;
stm_celcius_to_bits_offset = 273.15;