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
% csu_srp_solar_radiation_model_init.m                                    %
%                                                                         %
% 08/14/13                                                                %
%-------------------------------------------------------------------------%

srp_model_on = 0;
srp_time_step_size = 1;

srp_kv = 1;             %fraction of solar disk visible at s/c location
srp_cr = 1.5;           %coefficient of solar radiation (aluminum: 1.95)
srp_ar = 0.5;           %cross-sectional area presented to Sun (m^2)
srp_ls = 3.839e26;      %Sun luminosity (W)
srp_c = 2.99792458E8;   %speed of light (m/s)

% Multiply srp_K by 1/(m*r^2) to get acceleration due to SRP.
% SRP Calculation found here:
% https://www.agi.com/resources/help/online/stk/index.html?
% page=source%2Fhpop%2Fhpop-05.htm
srp_K = srp_kv * srp_cr * srp_ar * srp_ls * 1/(4 * pi * srp_c);



