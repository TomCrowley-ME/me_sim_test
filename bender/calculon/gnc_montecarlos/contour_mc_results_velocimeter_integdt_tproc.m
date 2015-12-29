% load MC_WORKSPACE
load lander_sensors_mcall.mat
close all


%-------------------------------------------------------------------------%
%% percentage of failure cases
[ contour_z , n_runs] = create_contour_matrix('fail_strict', '', data_struct_cam_integ_time, data_struct_cam_image_delta_t);
figure; contourf((data_struct_cam_integ_time.bin_centers), (data_struct_cam_image_delta_t.bin_centers), contour_z*100)
xlabel('Camera Integration Time (sec)','fontsize',14)
ylabel('Camera Image Interval Time (sec)','fontsize',14)
title('Percent of Runs which fail (%)','fontsize',14)
colorbar
saveas(gcf,'CamInteg_CamDeltaTContourSuccessFail.png')


%------------------------------------------------------------------------%
%% percentage of cases: failures due to horz velocity
[ contour_z , n_runs] = create_binary_contour_matrix('gnc_vel_err', 'xy', 2, data_struct_cam_integ_time, data_struct_cam_image_delta_t);
figure; contourf((data_struct_cam_integ_time.bin_centers), (data_struct_cam_image_delta_t.bin_centers), contour_z*100)
xlabel('Camera Integration Time (sec)','fontsize',14)
ylabel('Camera Image Interval Time (sec)','fontsize',14)
title('Percent of Runs which fail (%) due to Horizontal Velocity Error','fontsize',14)
colorbar
saveas(gcf,'CamInteg_CamDeltaTContourVelErr.png')

%------------------------------------------------------------------------%
%% percentage of cases: failures due to horz position
[ contour_z , n_runs] = create_binary_contour_matrix('gnc_pos_err', 'xy', 1500, data_struct_cam_integ_time, data_struct_cam_image_delta_t);
figure; contourf((data_struct_cam_integ_time.bin_centers), (data_struct_cam_image_delta_t.bin_centers), contour_z*100)
xlabel('Camera Integration Time (sec)','fontsize',14)
ylabel('Camera Image Interval Time (sec)','fontsize',14)
title('Percent of Runs which fail (%) due to Horizontal Position Error','fontsize',14)
colorbar
saveas(gcf,'CamInteg_CamDeltaTContourPosErr.png')


