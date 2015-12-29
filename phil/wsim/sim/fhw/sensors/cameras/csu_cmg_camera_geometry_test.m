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
% csu_cmg_camera_geometry_test.m                                          %
%                                                                         %
% unit test                                                               %
% 08/02/12                                                                %
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% init/prep

csc_cam_camera_system_init
csu_fpt_feature_point_init
csu_ini_initial_conditions_init_lander1

csc_cam_camera_system_prep
csu_ini_initial_conditions_prep

%-------------------------------------------------------------------------%
% set spacecraft pose

% topo frame is centered moon center
% eci_q_in =[ 0.4607    0.3976   -0.2807    0.7422] 
% eci_pos_in =  1.0e+06 * [ 0.070902484275196  -0.698405756678877   1.588358634873297];
% 
% topo_pos_in = 1.0e+06 * [ -0.000544760371260   0.000017967046000   1.736571512817274];
% topo_q_in = [0.590448872979131  -0.377645173983178   0.390278138741493   0.597023638883224];

% eci_q_in =[ 0.4607    0.3976   -0.2807    0.7422] 
% eci_pos_in =  1.0e+06 * [ 0.070902484275196  -0.698405756678877   1.588358634873297];

topo_pos_in = [0 0 50+(central_body_radius + ini_alt_wrt_meanrad) ];
topo_q_in = [0 0 sind(5/2) cosd(5/2)];
% topo_q_in = [0 0 0 1];

% lander.T_cam = [0 0 0]';
% lander.RS2C = quat2dcm(angle2quat(0,pi,0,'zyx'));
% 
% pos = [-544.7603712599999   17.9670460000000   71.5128172740806]';
% quat = [0.9962 0.0872 0 0];
% quat4 = [quat(2:4) quat(1)];
% 
% RW2S = quat2dcm( quat );
% 
% T = pos + ( RW2S' * lander.T_cam ) ; % vector to camera, in W
% RW2C = RW2S *  lander.RS2C;
% 
% camera_pose_C = [ RW2C , - RW2C * T ] ;
% camera_pose_P = cam_intrinsic_matrix_c * camera_pose_C;
% 
% 
% for i = 1 : 4
%     u = RW2C' * cam_u_matrix(i,:)';
%     umat(:,i) = u';
%     check_perp = cam_image_plane_norm * u;
%     nT(i) =(-cam_image_plane_norm * T);
%     tU(i) = (cam_image_plane_norm * u);
%     si = (-cam_image_plane_norm * T) / (cam_image_plane_norm * u);
%     siV(i) = si;
%     Pi = T + si * u;
%     corners_in(i,:) = Pi';
%     
% end
% 
% nT
% tU

%-------------------------------------------------------------------------%
% sim

sim('csu_cmg_camera_geometry_hrn')


%-------------------------------------------------------------------------%
% process data

