%%
figure,plot(ldr_flat_slant_range.time,ldr_flat_slant_range.signals.values,'b',...
            ldr_ellipsoid_slant_range.time,reshape(ldr_ellipsoid_slant_range.signals.values,1,450001),'r'),grid
cf=gcf;figs=cf.Number;

xlabel('Time, sec'),ylabel('meters')
fig_text='Slant Range Outputs From Lidar Model';
title(fig_text),set(gcf,'Name',fig_text)

ylim([-100 15000])
legend_cell = {'Flat','Ellipsoid'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(rsp_slant_range_100.time,rsp_slant_range_100.signals.values,'b',...
            rsp_slant_range_2k.time,rsp_slant_range_2k.signals.values,'r'),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('meters')
fig_text='Slant Range Input to Radar Sensor Processing';
title(fig_text),set(gcf,'Name',fig_text)

legend_cell = {'100m','15K'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(ldr_alt.time,ldr_alt.signals.values,'b',...
            rsp_alt.time,reshape(rsp_alt.signals.values,45001,1),'r',...
            rsp_topo_alt.time,reshape(rsp_topo_alt.signals.values,1,45001),'g'),grid
hold on,plot(telem.est.Time,telem.est.altitude.Data,'Color',[0.929 0.694 0.125])
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('meters')
fig_text='Altitude';
title(fig_text),set(gcf,'Name',fig_text)

ylim([-100 7000])
legend_cell = {'LDR','Subsat','Topo','Estimate'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(rsp_alt.time,ldr_alt.signals.values(1:10:end)-reshape(rsp_alt.signals.values,45001,1),'b',...
            rsp_alt.time,ldr_alt.signals.values(1:10:end)-reshape(rsp_topo_alt.signals.values,45001,1),'r'),grid
hold on,plot(telem.est.time,truth.sim.altitude.Data(1:10:end)-telem.est.altitude.Data,'Color',[0.929 0.694 0.125])
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('meters')
fig_text='Altitude Error';
title(fig_text),set(gcf,'Name',fig_text)

ylim([-200 200])
legend_cell = {'LDR-Subsat','LDR-Topo','Truth-Estimate'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(truth.sim.time,truth.sim.vel_topo.Data(:,3),'b',...
            telem.est.time,telem.est.vel.Data(:,3),'r'),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('meters/sec')
fig_text='Vertical Velocity';
title(fig_text),set(gcf,'Name',fig_text)

ylim([-140 200])
legend_cell = {'Truth','Estimate'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(truth.sim.vel_topo.Data(:,3),truth.sim.altitude.Data,'b',...
            telem.est.vel.Data(:,3),telem.est.altitude.Data,'r'),grid
% figure,plot(truth.fsw_rate.topo.sim_vel.Data(:,3),truth.fsw_rate.topo.sim_pos.Data(:,3),'b',...
%             telem.est.vel.Data(:,3),telem.est.pos.Data(:,3),'r'),grid

xlabel('Velocity, meters/sec'),ylabel('Altitude, meters')
fig_text='Altitude vs Vertical Velocity';
title(fig_text),set(gcf,'Name',fig_text)

xlim([-150 10]),ylim([-100 1000])
legend_cell = {'Truth','Estimate'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(ldr_azimuth.time,reshape(ldr_azimuth.signals.values,1,450001),'b',...
            rsp_azimuth.time,reshape(rsp_azimuth.signals.values,1,45001),'r'),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('degrees')
fig_text='Lidar Boresight Azimuth';
title(fig_text),set(gcf,'Name',fig_text)

legend_cell = {'LDR','RSP'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(ldr_nadir_angle.time,ldr_nadir_angle.signals.values,'b',...
            rsp_nadir_angle.time,rsp_nadir_angle.signals.values,'r'),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('degrees')
fig_text='Lidar Boresight Nadir Angle';
title(fig_text),set(gcf,'Name',fig_text)

legend_cell = {'LDR','RSP'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(ldr_sag.time,reshape(ldr_sag.signals.values,1,450001),'b',...
            rsp_sag.time,reshape(rsp_sag.signals.values,1,45001),'r'),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('meters')
fig_text='Slant Range Intercept Below Subsatellite Horizontal Plane';
title(fig_text),set(gcf,'Name',fig_text)

legend_cell = {'LDR','RSP'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(rsp_valid.time,reshape(rsp_valid.signals.values,1,45001)),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec')
fig_text='Slant Range Valid Flag';
title(fig_text),set(gcf,'Name',fig_text)
set(gca,'YTick',0:1,'YTickLabel',{'Invalid','Valid'})

ylim([-0.1 1.1])

%%
link_fig_axes(figs)
xlim([3950 4100]);