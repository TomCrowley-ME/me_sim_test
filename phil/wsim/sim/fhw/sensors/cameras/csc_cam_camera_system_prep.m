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


cam_use_meme_flag = csc_cam_establish_meme_contact(cam_attempt_to_use_meme_flag, meme_ip, meme_port);

clear cam_u_matrix

cam_take_image_counter = round(cam_image_delta_t/sim_time_step_size);
cam_process_pair_counter = round(cam_process_delta_t/sim_time_step_size);

% angular field of view
cam_i  = sqrt( (cam_pixel_size*cam_pixel_cols)^2 + (cam_pixel_size*cam_pixel_rows)^2 );
cam_ihalf  = sqrt( (cam_pixel_size*cam_pixel_cols/2)^2 + (cam_pixel_size*cam_pixel_rows/2)^2 );

if exist('cam_aov','var')
    % set focal length based on desired angular FOV and given chip size
    cam_focal_length_f = cam_i / ( 2*tan(cam_aov) );
else
    cam_aov = atan( cam_i/(2*cam_focal_length_f) );
end

cam_kir_image_size = [cam_pixel_cols cam_pixel_rows];
cam_kir_intrinsics = [cam_focal_length_f cam_pixel_size];

if exist('cam_processing_delay','var')
    cam_processing_delay_cycles = round(cam_processing_delay / sim_time_step_size);
end

cam_intrinsic_matrix_c = [ cam_focal_length_f/cam_pixel_size  0                                  cam_image_cx ;
                           0                                  cam_focal_length_f/cam_pixel_size  cam_image_cy ;
                           0                                  0                                  1            ];

cam_intrinsic_matrix_c_inv = inv(cam_intrinsic_matrix_c);


cam_u1 = [  cam_pixel_size*cam_pixel_cols/2  cam_pixel_size*cam_pixel_rows/2 cam_ihalf*tan(pi/2 - cam_aov) ];
cam_u2 = [ -cam_pixel_size*cam_pixel_cols/2  cam_pixel_size*cam_pixel_rows/2 cam_ihalf*tan(pi/2 - cam_aov) ];
cam_u3 = [ -cam_pixel_size*cam_pixel_cols/2 -cam_pixel_size*cam_pixel_rows/2 cam_ihalf*tan(pi/2 - cam_aov) ];
cam_u4 = [  cam_pixel_size*cam_pixel_cols/2 -cam_pixel_size*cam_pixel_rows/2 cam_ihalf*tan(pi/2 - cam_aov) ];

cam_u_matrix = [cam_u1'/norm(cam_u1) cam_u2'/norm(cam_u2) cam_u3'/norm(cam_u3) cam_u4'/norm(cam_u4)]';
cam_u_matrix_4x3 = cam_u_matrix';

% spacecraft angular rate norm (in rad/sec) limit at which pixel noise (cam_pixel_std) is increased by max factor (3 max, 1 min)
cam_max_rate = cam_aov / (cam_integ_time *max(cam_pixel_rows,cam_pixel_cols));

%cam_camva = atand((cam_pixel_size*cam_pixel_rows/2)/cam_focal_length_f)*2;

cam_plane_dot_u = cam_u_matrix * cam_image_plane_norm';

clear u1 u2 u3 u4

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - %
% %                   CAMERA 1 : NADIR POINTING                           %

cam_cam1_lander_dcm  = rot_angles_to_dcm( [cam_cam1_lander_rotz cam_cam1_lander_roty cam_cam1_lander_rotx] );

cam_cam1_lander_quat = rot_angles_to_quat( [cam_cam1_lander_rotz cam_cam1_lander_roty cam_cam1_lander_rotx] );

