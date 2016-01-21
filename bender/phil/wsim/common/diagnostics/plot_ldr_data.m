%%
figure,co=get(gca,'ColorOrder');
set(gcf,'DefaultAxesColorOrder',co([1 2 3 5 7 6 4],:));
plot(ldr_flat_slant_range.time,ldr_flat_slant_range.signals.values,...
     ldr_ellipsoid_slant_range.time,ldr_ellipsoid_slant_range.signals.values),grid
cf=gcf;figs=cf.Number;

xlabel('Time, sec'),ylabel('meters')
fig_text='Slant Range Outputs From Lidar Model';
title(fig_text,'fontsize',14),set(gcf,'Name',fig_text)

ylim([-100 15100])
legend_cell = {'1\_Flat','2\_Flat','1\_Ellipsoid','2\_Ellipsoid'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(rsp_ldr1_slant_range_100.time,rsp_ldr1_slant_range_100.signals.values,'b',...
            rsp_ldr1_slant_range_15k.time,rsp_ldr1_slant_range_15k.signals.values,'r',...
            rsp_ldr2_slant_range_15k.time,rsp_ldr2_slant_range_15k.signals.values,'g'),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('meters')
fig_text='Slant Range Input to Radar Sensor Processing';
title(fig_text,'fontsize',14),set(gcf,'Name',fig_text)

legend_cell = {'1\_100m','1\_15K','2\_15K'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,co=get(gca,'ColorOrder');
set(gcf,'DefaultAxesColorOrder',co([1 2 5 7 6 4],:));
plot(truth.sim.altitude.Time,truth.sim.altitude.Data,...
     rsp_subsat_alt.time,rsp_subsat_alt.signals.values,...
     rsp_topo_alt.time,rsp_topo_alt.signals.values),grid
hold on,plot(telem.est.Time,telem.est.altitude.Data,'Color',[0.929 0.694 0.125])
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('meters')
fig_text='Altitude';
title(fig_text,'fontsize',14),set(gcf,'Name',fig_text)

ylim([-100 12000])
legend_cell = {'Truth','Subsat1','Subsat2','Topo1','Topo2','Estimate'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,co=get(gca,'ColorOrder');
set(gcf,'DefaultAxesColorOrder',co([1 2 5 7 6 4],:));
plot(rsp_subsat_alt.time,truth.sim.altitude.Data(1:10:end)*[1 1]-rsp_subsat_alt.signals.values,...
     rsp_topo_alt.time,truth.sim.altitude.Data(1:10:end)*[1 1]-rsp_topo_alt.signals.values),grid
hold on,plot(telem.est.time,truth.sim.altitude.Data(1:10:end)-telem.est.altitude.Data,'Color',[0.929 0.694 0.125])
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('meters')
fig_text='Altitude Error';
title(fig_text,'fontsize',14),set(gcf,'Name',fig_text)

ylim([-50 50])
legend_cell = {'Subsat1','Subsat2','Topo1','Topo2','Estimate'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(truth.sim.time,truth.sim.vel_topo.Data(:,3),'b',...
            telem.est.time,telem.est.vel.Data(:,3),'r'),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('meters/sec')
fig_text='Vertical Velocity';
title(fig_text,'fontsize',14),set(gcf,'Name',fig_text)

ylim([-100 10])
legend_cell = {'Truth','Estimate'};
legend(legend_cell,'Location','NorthWest','fontsize',8)

%%
figure,plot(telem.est.time,truth.fsw_rate.total.sim_vel.Data(:,3)-telem.est.vel.Data(:,3),'Color',[0.929 0.694 0.125]),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('meters/sec')
fig_text='Vertical Velocity Error';
title(fig_text,'fontsize',14),set(gcf,'Name',fig_text)

legend_cell = {'Truth-Estimate'};
legend(legend_cell,'Location','NorthWest','fontsize',8)

%%
figure,plot(telem.est.time,truth.fsw_rate.total.sim_pos.Data-telem.est.pos.Data),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('meters')
fig_text='Position Estimation Error';
title(fig_text,'fontsize',14),set(gcf,'Name',fig_text)

legend_cell = {'X','Y','Z'};
legend(legend_cell,'Location','NorthWest','fontsize',8)

%%
figure,plot(telem.est.time,truth.fsw_rate.total.sim_vel.Data-telem.est.vel.Data),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('meters/sec')
fig_text='Velocity Estimation Error';
title(fig_text,'fontsize',14),set(gcf,'Name',fig_text)

legend_cell = {'X','Y','Z'};
legend(legend_cell,'Location','NorthWest','fontsize',8)

%%
figure,plot(truth.sim.vel_topo.Data(:,3),truth.sim.altitude.Data,'b',...
            telem.est.vel.Data(:,3),telem.est.altitude.Data,'r'),grid
% figure,plot(truth.fsw_rate.topo.sim_vel.Data(:,3),truth.fsw_rate.topo.sim_pos.Data(:,3),'b',...
%             telem.est.vel.Data(:,3),telem.est.pos.Data(:,3),'r'),grid

xlabel('Velocity, meters/sec'),ylabel('Altitude, meters')
fig_text='Altitude vs Vertical Velocity';
title(fig_text,'fontsize',14),set(gcf,'Name',fig_text)

xlim([-100 10]),ylim([-100 1000])
legend_cell = {'Truth','Estimate'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(ldr_azimuth.time,ldr_azimuth.signals.values,...
            rsp_boresight_azimuth.time,rsp_boresight_azimuth.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('degrees')
fig_text='Lidar Boresight Azimuth';
title(fig_text,'fontsize',14),set(gcf,'Name',fig_text)

legend_cell = {'LDR1','LDR2','RSP1','RSP2'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(ldr_nadir_angle.time,ldr_nadir_angle.signals.values,...
            rsp_nadir_angle.time,rsp_nadir_angle.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('degrees')
fig_text='Lidar Boresight Nadir Angle';
title(fig_text,'fontsize',14),set(gcf,'Name',fig_text)

legend_cell = {'LDR1','LDR2','RSP1','RSP2'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(ldr_sag.time,ldr_sag.signals.values,...
            rsp_boresight_sag.time,rsp_boresight_sag.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('meters')
fig_text='Slant Range Intercept Below Subsatellite Horizontal Plane';
title(fig_text,'fontsize',14),set(gcf,'Name',fig_text)

legend_cell = {'LDR1','LDR2','RSP1','RSP2'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(rsp_valid.time,rsp_valid.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec')
fig_text='Slant Range Valid Flag';
title(fig_text,'fontsize',14),set(gcf,'Name',fig_text)
set(gca,'YTick',0:1,'YTickLabel',{'Invalid','Valid'})

ylim([-0.1 1.1])
legend_cell = {'1','2'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(rsp_subsat_azimuth.time,rsp_subsat_azimuth.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('degrees')
fig_text='Subsatellite Azimuth From Topocentric';
title(fig_text,'fontsize',14),set(gcf,'Name',fig_text)

legend_cell = {'1','2'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(rsp_subsat_sag.time,rsp_subsat_sag.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('meters')
fig_text='Subsatellite Distance Below Topocentric Horizontal Plane';
title(fig_text,'fontsize',14),set(gcf,'Name',fig_text)

legend_cell = {'1','2'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure,plot(rsp_topo_subsat_distance.time,rsp_topo_subsat_distance.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('meters')
fig_text='Subsatellite Distance on Topocentric Horizontal Plane';
title(fig_text,'fontsize',14),set(gcf,'Name',fig_text)

legend_cell = {'1','2'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
link_fig_axes(figs)
xlim([3890 4100]);
