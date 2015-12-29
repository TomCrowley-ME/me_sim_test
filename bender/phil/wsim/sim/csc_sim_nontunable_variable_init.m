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
% csc_sim_nontunable_variable_init.m                                      %
%                                                                         %
% 07/24/14                                                                %
%-------------------------------------------------------------------------%


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% EPH :  these params are not suited for tuning at this time

    NIMBUS_ROOT = getenv('NIMBUS_ROOT');
    eph_kernel_dir = fullfile(NIMBUS_ROOT, 'externals', 'mice', 'kernels');

    % Load Sun/Earth/Moon ephemeris data (applicable from 1950 to 2050)
    cspice_furnsh([eph_kernel_dir filesep 'de421.bsp']);     %ephemeris data
    cspice_furnsh([eph_kernel_dir filesep 'pck00010.tpc']);  %planetary constants kernel
    cspice_furnsh([eph_kernel_dir filesep 'naif0010.tls']);  %leapseconds kernel
    cspice_furnsh([eph_kernel_dir filesep 'moon_pa_de421_1900-2050.bpc']); 
    cspice_furnsh([eph_kernel_dir filesep 'moon_assoc_pa.tf']);
    cspice_furnsh([eph_kernel_dir filesep 'moon_080317.tf']);


    % Sample rate of ephemeris data. Should be <= than the guidance update rate
    eph_time_step_size = 1; % (seconds)


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% INI

    ini_landed_flag = boolean(0);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% FRAME

    % MOON IAU J2000 Pole Orientation
    e1coeff =  fliplr([125.045 -0.0529921]) ; 
    e2coeff =  fliplr([250.089 -0.1059842]) ; 
    e3coeff =  fliplr([260.008 +13.0120009]) ; 
    e4coeff =  fliplr([176.625 +13.3407154]) ; 
    e5coeff =  fliplr([357.529 +0.9856003]) ; 
    e6coeff =  fliplr([311.589 +26.4057084]) ; 
    e7coeff =  fliplr([134.963 +13.0649930]) ; 
    e8coeff =  fliplr([276.617 +0.3287146]) ; 
    e9coeff =  fliplr([ 34.226 +1.7484877]) ;
    e10coeff = fliplr([ 15.134 -0.1589763]) ;
    e11coeff = fliplr([119.743 +0.0036096]) ;
    e12coeff = fliplr([239.961 +0.1643573]) ;
    e13coeff = fliplr([ 25.053 +12.9590088]) ; 

    % for multiplying [e1 e2 e3 e4 e6 e10 e13]
    ra_sin_coeff = [ -3.8787 ; -0.1204 ;  +0.0700 ; -0.0172 ; +0.0072 ; -0.0052 ; +0.0043 ];
    ra_t_poly = fliplr( [269.9949 +0.0031] );

    % for multiplying [e1 e2 e3 e4 e6 e7 e10 e13]
    de_cos_coeff = [ 1.5419 ;  +0.0239;  -0.0278;  +0.0068; -0.0029; +0.0009; +0.0008; -0.0009 ]; 
    de_t_poly = fliplr( [66.5392 +0.0130] );

    omega_moon_iau_coeff = [  3.5610 ; +0.1208 ; -0.0642 ; +0.0158 ; +0.0252 ; -0.0066 ; -0.0047 ; -0.0046 ;  +0.0028 ; +0.0052 ; +0.0040 ; +0.0019 ; -0.0044  ];

    omega_pa_mat_init = [0 0 0; 0 0 0; 0 0 1];
