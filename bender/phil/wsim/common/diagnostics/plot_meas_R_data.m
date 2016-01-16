%%
figure,plot(nadir_dtheta.time,nadir_dtheta.signals.values,'b',...
            nadir_dtheta_filtered.time,nadir_dtheta_filtered.signals.values,'r','Linewidth',2),grid
cf=gcf;if exist('figs'),figs=[figs cf.Number];else figs=cf.Number;end

xlabel('Time, sec')
ylabel('meters/sec')
fig_text='Lidar Boresight Nadir Angular Rate';
title(fig_text),set(gcf,'Name',fig_text)

ylim([-20 20])
legend_cell = {'Original','Filtered'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(meas_R1_alt.time,meas_R1_alt.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec')
fig_text='Measurement noise covariance due to altitude';
title(fig_text),set(gcf,'Name',fig_text)

ylim([-0.1 0.3])

%%
figure,plot(meas_R1_angle.time,meas_R1_angle.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec')
fig_text='Measurement noise covariance due to nadir angle';
title(fig_text),set(gcf,'Name',fig_text)

ylim([-100 1e4])

%%
figure,plot(meas_R1_dtheta.time,meas_R1_dtheta.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec')
fig_text='Measurement noise covariance due to nadir angular rate';
title(fig_text),set(gcf,'Name',fig_text)

ylim([-100 1e4])

%%
figure,plot(meas_R1.time,meas_R1.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec')
fig_text='Total Measurement noise covariance';
title(fig_text),set(gcf,'Name',fig_text)

ylim([-10 1e3])

%%
figure,plot(meas_z_valid.time,meas_z_valid.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec')
fig_text='Slant Range Valid Flag';
title(fig_text),set(gcf,'Name',fig_text)
set(gca,'YTick',0:1,'YTickLabel',{'Invalid','Valid'})

ylim([-0.1 1.1])

%%
link_fig_axes(figs)
xlim([3950 4100]);



