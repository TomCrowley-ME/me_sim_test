%%
figure,plot(nadir_dtheta.time,nadir_dtheta.signals.values(:,1),'b',...
            nadir_dtheta_filtered.time,nadir_dtheta_filtered.signals.values(:,1),'r','Linewidth',2),grid
cf=gcf;if exist('figs'),figs=[figs cf.Number];else figs=cf.Number;end

xlabel('Time, sec')
ylabel('meters/sec')
fig_text='Lidar 1 Boresight Nadir Angular Rate';
title(fig_text),set(gcf,'Name',fig_text)

ylim([-20 20])
legend_cell = {'1\_Original','1\_Filtered'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(nadir_dtheta.time,nadir_dtheta.signals.values(:,2),'b',...
            nadir_dtheta_filtered.time,nadir_dtheta_filtered.signals.values(:,2),'r','Linewidth',2),grid
cf=gcf;if exist('figs'),figs=[figs cf.Number];else figs=cf.Number;end

xlabel('Time, sec')
ylabel('meters/sec')
fig_text='Lidar 2 Boresight Nadir Angular Rate';
title(fig_text),set(gcf,'Name',fig_text)

ylim([-20 20])
legend_cell = {'2\_Original','2\_Filtered'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(meas_R_alt.time,meas_R_alt.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec')
fig_text='Measurement noise covariance due to altitude';
title(fig_text),set(gcf,'Name',fig_text)

ylim([-0.1 0.3])
legend_cell = {'1','2'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(meas_R_angle.time,meas_R_angle.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec')
fig_text='Measurement noise covariance due to nadir angle';
title(fig_text),set(gcf,'Name',fig_text)

ylim([-100 1e4])
legend_cell = {'1','2'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(meas_R_dtheta.time,meas_R_dtheta.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec')
fig_text='Measurement noise covariance due to nadir angular rate';
title(fig_text),set(gcf,'Name',fig_text)

ylim([-100 1e4])
legend_cell = {'1','2'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(meas_R.time,meas_R.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec')
fig_text='Total Measurement noise covariance';
title(fig_text),set(gcf,'Name',fig_text)

ylim([-10 1e3])
legend_cell = {'1','2'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
link_fig_axes(figs)
xlim([3890 4100]);



