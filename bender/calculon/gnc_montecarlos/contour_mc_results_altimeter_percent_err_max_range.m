load MC_WORKSPACE
load lander_sensors_mcall.mat
close all


%-------------------------------------------------------------------------%
%% percentage of failure cases
[ contour_z , n_runs] = create_contour_matrix('fail_strict', '', data_struct_rdr_range_max, data_struct_rdr_percent_error);
figure; contourf(round(data_struct_rdr_range_max.bin_centers)/1000, (data_struct_rdr_percent_error.bin_centers)*100, contour_z*100)
xlabel('Maximum range return (km)','fontsize',14)
ylabel('Altimeter percent of range error (%)','fontsize',14)
title('Percent of Runs which fail (%)','fontsize',14)
colorbar
saveas(gcf,'AltContourSuccessFail.png')


%------------------------------------------------------------------------%
%% percentage of cases: failures due to horz velocity
[ contour_z , n_runs] = create_binary_contour_matrix('gnc_vel_err', 'xy', 2, data_struct_rdr_range_max, data_struct_rdr_percent_error);
figure; contourf(round(data_struct_rdr_range_max.bin_centers)/1000, (data_struct_rdr_percent_error.bin_centers)*100, contour_z*100)
xlabel('Maximum range return (km)','fontsize',14)
ylabel('Altimeter percent of range error (%)','fontsize',14)
title('Percent of Runs which fail (%) due to Horizontal Velocity Error','fontsize',14)
colorbar
saveas(gcf,'AltContourVelErr.png')

%------------------------------------------------------------------------%
%% percentage of cases: failures due to horz position
[ contour_z , n_runs] = create_binary_contour_matrix('gnc_pos_err', 'xy', 1500, data_struct_rdr_range_max, data_struct_rdr_percent_error);
figure; contourf(round(data_struct_rdr_range_max.bin_centers)/1000, (data_struct_rdr_percent_error.bin_centers)*100, contour_z*100)
xlabel('Maximum range return (km)','fontsize',14)
ylabel('Altimeter percent of range error (%)','fontsize',14)
title('Percent of Runs which fail (%) due to Horizontal Position Error','fontsize',14)
colorbar
saveas(gcf,'AltContourPosErr.png')




