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

%% Begin SPICE kernel init file 
% Dependencies: 
% 
% Source: http://naif.jpl.nasa.gov/naif/data_generic.html
%
%%

NIMBUS_ROOT = getenv('NIMBUS_ROOT');

eph_kernel_dir = fullfile(NIMBUS_ROOT, 'externals', 'mice', 'kernels');

% Load Sun/Earth/Moon ephemeris data (applicable from 1950 to 2050)
cspice_furnsh([eph_kernel_dir filesep 'de421.bsp']);     %ephemeris data
cspice_furnsh([eph_kernel_dir filesep 'pck00010.tpc']);  %planetary constants kernel
cspice_furnsh([eph_kernel_dir filesep 'naif0010.tls']);  %leapseconds kernel
cspice_furnsh([eph_kernel_dir filesep 'moon_pa_de421_1900-2050.bpc']); 
cspice_furnsh([eph_kernel_dir filesep 'moon_assoc_pa.tf']);
cspice_furnsh([eph_kernel_dir filesep 'moon_080317.tf']);


% Sample rate of ephemeris data. Should be equal or less than the guidance
% update rate.
eph_time_step_size = 1; % (seconds)
%%%%%%%%%%%%%%% END SCRIPT %%%%%%%%%%%%%%%