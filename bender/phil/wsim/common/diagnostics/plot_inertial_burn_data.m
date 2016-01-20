%%
figure,plot(telem.cnt.main_thruster_cmd),grid
cf=gcf;figs=cf.Number;

ylim([-10 110])
xlabel('Time, sec'),ylabel('On-time, msec')
fig_text='Main Thruster Fire Command';
title(fig_text),set(gcf,'Name',fig_text)

%%
figure, plot(dtheta_zhat_vhat.time,dtheta_zhat_vhat.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('Angle, deg')
fig_text='Angle Between Z-axis and Velocity Vector';
title(fig_text),set(gcf,'Name',fig_text)

%%
figure, plot(dtheta_zhat_phat.time,dtheta_zhat_phat.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('Angle, deg')
fig_text='Angle Between Desired Pointing and Z-axis';
title(fig_text),set(gcf,'Name',fig_text)

%%
figure, plot(dtheta_vhat_phat.time,dtheta_vhat_phat.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('Angle, deg')
fig_text='Angle Between Desired Pointing and Velocity Vector';
title(fig_text),set(gcf,'Name',fig_text)

%%
if isfield(truth.fsw_rate.total,'sim_altitude')
  figure,plot(truth.fsw_rate.total.sim_altitude.Time,truth.fsw_rate.total.sim_altitude.Data,'b',...
              telem.est.time,telem.est.altitude.Data,'r'),grid
else
  figure,plot(truth.sim.altitude.time,truth.sim.altitude.Data,'b',...
              telem.est.time,telem.est.altitude.Data,'r'),grid
end
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('meters')
fig_text='Altitude';
title(fig_text),set(gcf,'Name',fig_text)

legend_cell = {'Truth','Estimate'};
legend(legend_cell,'Location','NorthEast','fontsize',8)

%%
figure, plot(alt_rate_gib.time,alt_rate_gib.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('m/sec')
fig_text='Altitude Rate';
title(fig_text),set(gcf,'Name',fig_text)

ylim([-100 10])

%%
figure, plot(desired_deltaV_gib.time,desired_deltaV_gib.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('m/sec')
fig_text='Acceleration Integrated Along Desired Burn Direction';
title(fig_text),set(gcf,'Name',fig_text)

%%
link_fig_axes(figs)
xlim([3750 4100]);