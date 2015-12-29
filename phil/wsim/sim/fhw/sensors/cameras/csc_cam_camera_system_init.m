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
% csu_cam_camera_system_init.m                                            %
%                                                                         %
% defines camera model, intrinsic parameters, etc                         %
% 07/26/12                                                                %
%-------------------------------------------------------------------------%

cam_attempt_to_use_meme_flag = 0;
meme_ip = '192 168 1 82'; %82 for Eric's machine
meme_port = '5000';


%-------------------------------------------------------------------------%
% create camera model
cam_focal_length_f = 20.3 / 1000  ;       % focal length in meters
cam_pixel_rows = 480 ;  % image size (in pixels)
cam_pixel_cols = 640 ;  % image size (in pixels)
cam_pixel_size = 25e-6; % pixel length, in meters, assuming that pixels are square

cam_image_cx = 320;
cam_image_cy = 240;

%-------------------------------------------------------------------------%
    % % camera 1 : nadir pointing % %
    cam_cam1_pos_in_lander = [0 0 -0.5]'; %meters
    cam_cam1_lander_rotx = 180*pi/180;
    cam_cam1_lander_roty = 0;
    cam_cam1_lander_rotz = -90*pi/180;

%-------------------------------------------------------------------------%


cam_image_plane_norm = [0 0 1];

cam_extrinsic_init = zeros(3,4);

cam_image_delta_t = 0.1; % seconds capture of successive images
cam_process_delta_t = 1; % seconds between processing pairs
cam_integ_time = 0.010;

% time delay between image taken and presentation to the filter (image processing delay)
cam_processing_delay = 0.25; % in seconds

% degrades perfect pixel matches: gaussian RV added to pixel matches (pixels)
cam_pixel_std = 0.001;
cam_pixel_bias = 0;

% degrades estimate of what point in eci (on the surface) a pixel correspnds to (m, eci)
cam_ground_point_std = 0;
cam_ground_point_bias = 0;

