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
% plot_descent_images.m                                                   %
%                                                                         %
% plot image capture boundaries over course of trajectory                 %
% 01/04/13                                                                %
% eleanorcrane@moonexpress.com                                            %
%-------------------------------------------------------------------------%

% 
map_handle = figure(11); clf;
xmin  = -75; xmax = 30;
ymin = -60; ymax = 10;
patch( [xmin xmax xmax xmin],[ymin ymin ymax ymax],0.5*[1 1 1],'EdgeColor','none')
% -72.4217  123s.2534  -59.6687    8.8175
daspect([1 1 1])
% load VO_descent_map_s0.mat

% plot_map_3D([],map_handle)
% set(gca,'Color',[0.5 0.5 0.5])
load map_traj_view_properties.mat
set(gca,'CameraPosition',view_struct.pos)
set(gca,'CameraTarget',view_struct.target)
set(gca,'CameraViewAngle',view_struct.va)

grid on; hold on;


%%

% if magenta_counter > limit
%     X = [camera_pos(1) ; image_two.corners(1,1); NaN;
%         camera_pos(1) ; image_two.corners(2,1); NaN;
%         camera_pos(1) ; image_two.corners(3,1); NaN;
%         camera_pos(1) ; image_two.corners(4,1); NaN ];
%     
%     Y = [camera_pos(2) ; image_two.corners(1,2); NaN;
%         camera_pos(2) ; image_two.corners(2,2); NaN;
%         camera_pos(2) ; image_two.corners(3,2); NaN;
%         camera_pos(2) ; image_two.corners(4,2); NaN ];
%     
%     Z = [camera_pos(3) ; 0 ; NaN;
%         camera_pos(3) ; 0 ; NaN;
%         camera_pos(3) ; 0 ; NaN;
%         camera_pos(3) ; 0 ; NaN ];
%     
%     
%     plot3(X,Y,Z,'m--')
%     
%     magenta_counter = 0;
% else
%     magenta_counter = magenta_counter + 1;
% end
% quiver3(camera_pos(1),camera_pos(2), camera_pos(3), lander_vel(ii,1), lander_vel(ii,2), lander_vel(ii,3))
% plot3(camera_pos(1),camera_pos(2), camera_pos(3),'ks')


% % axis([-3000        3000      -10000        2000       0        4000])
%%

magenta_counter = 6;
green_counter = 6;
limit = 4;

i_start = 1+cam_take_image_counter;
i_max = length(nadir_cam_2_corners.Time);

camera_pos = [rtk_pos_topo(:,1:2) rtk_pos_topo(:,3)-central_body_radius*1000 - ini_alt_wrt_meanrad];

for jj = i_start : cam_process_pair_counter*3 : i_max

    %-------------------------------------------------------------------------%
    if nadir_cam_2_invalid(jj) == 0 && est_cam_id.Data(jj) == hmg_nadir_cam_id
        % jj is index at second image acquisition
%         grid on; hold on;
%         % image one: image boundaries
%         plot( image_corners_1.signals.values([1 2 3 4 1],1,jj)/1000, image_corners_1.signals.values([1 2 3 4 1],2,jj)/1000,'b' )

        % image two: image boundaries
        plot( nadir_cam_2_corners.Data([1 2 3 4 1],1,jj)/1000, nadir_cam_2_corners.Data([1 2 3 4 1],2,jj)/1000,'r' )


        if magenta_counter > limit
            X = [camera_pos(jj,1) ; nadir_cam_2_corners.Data(1,1,jj); NaN;
                 camera_pos(jj,1) ; nadir_cam_2_corners.Data(2,1,jj); NaN;
                 camera_pos(jj,1) ; nadir_cam_2_corners.Data(3,1,jj); NaN;
                 camera_pos(jj,1) ; nadir_cam_2_corners.Data(4,1,jj); NaN ] /1000;

            Y = [camera_pos(jj,2) ; nadir_cam_2_corners.Data(1,2,jj); NaN;
                 camera_pos(jj,2) ; nadir_cam_2_corners.Data(2,2,jj); NaN;
                 camera_pos(jj,2) ; nadir_cam_2_corners.Data(3,2,jj); NaN;
                 camera_pos(jj,2) ; nadir_cam_2_corners.Data(4,2,jj); NaN ] /1000;

            Z = [camera_pos(jj,3) ; 0 ; NaN;
                 camera_pos(jj,3) ; 0 ; NaN;
                 camera_pos(jj,3) ; 0 ; NaN;
                 camera_pos(jj,3) ; 0 ; NaN ] /1000;


            plot3(X,Y,Z,'m--')

            magenta_counter = 0;
        else
            magenta_counter = magenta_counter + 1;
        end

    end
    
    %-------------------------------------------------------------------------%
    if side_cam_2_invalid(jj) == 0 && est_cam_id.Data(jj) == hmg_side_cam_id
        % jj is index at second image acquisition
%         grid on; hold on;
%         % image one: image boundaries
%         plot( image_corners_1.signals.values([1 2 3 4 1],1,jj)/1000, image_corners_1.signals.values([1 2 3 4 1],2,jj)/1000,'b' )

        % image two: image boundaries
        plot( side_cam_2_corners.Data([1 2 3 4 1],1,jj)/1000, side_cam_2_corners.Data([1 2 3 4 1],2,jj)/1000,'g' )


        if green_counter > limit
            X = [camera_pos(jj,1) ; side_cam_2_corners.Data(1,1,jj); NaN;
                 camera_pos(jj,1) ; side_cam_2_corners.Data(2,1,jj); NaN;
                 camera_pos(jj,1) ; side_cam_2_corners.Data(3,1,jj); NaN;
                 camera_pos(jj,1) ; side_cam_2_corners.Data(4,1,jj); NaN ] /1000;

            Y = [camera_pos(jj,2) ; side_cam_2_corners.Data(1,2,jj); NaN;
                 camera_pos(jj,2) ; side_cam_2_corners.Data(2,2,jj); NaN;
                 camera_pos(jj,2) ; side_cam_2_corners.Data(3,2,jj); NaN;
                 camera_pos(jj,2) ; side_cam_2_corners.Data(4,2,jj); NaN ] /1000;

            Z = [camera_pos(jj,3) ; 0 ; NaN;
                 camera_pos(jj,3) ; 0 ; NaN;
                 camera_pos(jj,3) ; 0 ; NaN;
                 camera_pos(jj,3) ; 0 ; NaN ] /1000;


            plot3(X,Y,Z,'c-')

            green_counter = 0;
        else
            green_counter = magenta_counter + 1;
        end

    end

    plot3(camera_pos(i_start:jj,1)/1000,camera_pos(i_start:jj,2)/1000,camera_pos(i_start:jj,3)/1000,'k--','LineWidth',2)
    
    quiver3(camera_pos(jj,1)/1000,camera_pos(jj,2)/1000,camera_pos(jj,3)/1000, rtk_vel_topo(jj,1)/1000, rtk_vel_topo(jj,2)/1000, rtk_vel_topo(jj,3)/1000)
    plot3(camera_pos(jj,1)/1000,camera_pos(jj,2)/1000,camera_pos(jj,3)/1000,'ks')
%     
%     if jj > 1
%     plot(image_corners([1 2 3 4 1],1,jj-1),image_corners([1 2 3 4 1],2,jj-1),'b--')
%     end
%     plot(image_corners([1 2 3 4 1],1,jj),image_corners([1 2 3 4 1],2,jj))
%     
% 
%     
%     plot3(X,Y,Z,'m:')
%     
%     plot(feature_points_ground(matches(jj,:) > 1,1,jj),feature_points_ground(matches(jj,:) > 1,2,jj),'rs')
%     plot(feature_points_ground(matches(jj,:) > 0,1,jj),feature_points_ground(matches(jj,:) > 0,2,jj),'rx')
%     

    pause(0.2)
    
end
