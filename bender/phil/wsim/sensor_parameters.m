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
% sensor_parameters.m                                                     %
%                                                                         %
% attempting to compile a comprehensive list of sensor params             %
% 09/06/12                                                                %
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
%                       ALTIMETER PARAMS                                  %
%-------------------------------------------------------------------------%

    % error as a percentage of true range (given as a fractional value)
    ldr_2k_percent_error = 1.0 / 100;

    % range resolution (implemented as uniform RV beetween [-res/2 : +res/2])
    ldr_2k_bin_minimum = -0.5;
    ldr_2k_bin_maximum = 0.5;

    % range return rate (in seconds)
    ldr_2k_update_time = 0.1; %10hz update rate

    % minimum/maximum slant-range reutrn (in meters)
    ldr_2k_range_min = 1;
    ldr_2k_range_max = 5000.0;
    
%-------------------------------------------------------------------------%
%                 COMPUTER VISION PARAMS                                  %
%-------------------------------------------------------------------------%

    % degrades perfect pixel matches: gaussian RV added to pixel matches (pixels)
    cam_pixel_std = 0.1;
    cam_pixel_bias = 0;

    % degrades estimate of what point in eci (on the surface) a pixel correspnds to (m, eci)
    cam_ground_point_std = 0;
    cam_ground_point_bias = 0;

    % camera system timing
%     cam_image_delta_t = 0.1; %seconds between images

    % time delay between image taken and presentation to the filter (image processing delay)
    cam_processing_delay = 0.25; % in seconds
    
    % spacecraft angular rate norm (in rad/sec) limit at which pixel noise (cam_pixel_std) is increased by max factor (3 max, 1 min)
    cam_max_rate = (pi/180) * 50;

%-------------------------------------------------------------------------%
%                 CAMERA PHYSICAL PARAMS                                  %
%-------------------------------------------------------------------------%

    % camera focal length (in meters)
    cam_focal_length_f = (20.3 / 1000)  ;       % focal length in meters
    cam_pixel_rows = 480 ;
    cam_pixel_cols = 640 ;
    cam_pixel_size = 25e-6;      % 25 micrometer pixels    % image center in pixels (should be half of rows/cols)
    cam_image_cx = 320;
    cam_image_cy = 240;
