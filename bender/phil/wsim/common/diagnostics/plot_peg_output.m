%%
figure,plot(telem.cnt.main_thruster_cmd),grid
cf=gcf;figs=cf.Number;

ylim([-10 110])
xlabel('Time, sec')
fig_text='Main Thruster Fire Command';
title(fig_text),set(gcf,'Name',fig_text)

%%
figure, plot(peg_output.time(1:end),peg_output.signals.values(1:end,1)),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('Angle, deg')
fig_text='Angle Between Z-axis and Velocity Vector';
title(fig_text),set(gcf,'Name',fig_text)

%%
figure, plot(peg_output.time(1:end),peg_output.signals.values(1:end,2)),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('Angle, deg')
fig_text='Angle Between PEG Desired Pointing and Z-axis';
title(fig_text),set(gcf,'Name',fig_text)

%%
figure, plot(peg_output.time(1:end),peg_output.signals.values(1:end,3)),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('Angle, deg')
fig_text='Angle Between PEG Desired Pointing and Velocity Vector';
title(fig_text),set(gcf,'Name',fig_text)

%%
figure, plot(peg_output.time(1:end),peg_output.signals.values(1:end,16)),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('sec')
fig_text='Burn Time to GO';
title(fig_text),set(gcf,'Name',fig_text)

%%
figure, plot(peg_output.time(1:end),normrows(peg_output.signals.values(1:end,17:19))),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('m/sec')
fig_text='Velocity to GO';
title(fig_text),set(gcf,'Name',fig_text)
ylim([0 2e3])

%%
figure, plot(peg_output.time(1:end),normrows(peg_output.signals.values(1:end,20:22))),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('meters')
fig_text='Position to GO';
title(fig_text),set(gcf,'Name',fig_text)
ylim([0 3e5])

%%
figure, plot(peg_output.time(1:end),peg_output.signals.values(1:end,23)),grid
cf=gcf;figs=[figs cf.Number];

ylim([2 9])
xlabel('Time, sec')
fig_text='PEG iterations';
title(fig_text),set(gcf,'Name',fig_text)

%%
if exist('deltaV_peg')
  figure, plot(deltaV_peg.time,deltaV_peg.signals.values),grid
  cf=gcf;figs=[figs cf.Number];

  xlabel('Time, sec'),ylabel('m/sec')
  fig_text='Acceleration Integrated Along Desired Burn Direction';
  title(fig_text),set(gcf,'Name',fig_text)
end

%%
figure, plot(alt_rate_peg.time,alt_rate_peg.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('m/sec')
fig_text='Altitude Rate';
title(fig_text),set(gcf,'Name',fig_text)

ylim([-100 10])

%%
figure, plot(desired_deltaV_peg.time,desired_deltaV_peg.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('m/sec')
fig_text='Acceleration Integrated Along Desired Burn Direction';
title(fig_text),set(gcf,'Name',fig_text)

%%
figure, plot(gravity_turn_deltaV.time,gravity_turn_deltaV.signals.values),grid
cf=gcf;figs=[figs cf.Number];

xlabel('Time, sec'),ylabel('m/sec')
fig_text='Acceleration Integrated Along Velocity Vector';
title(fig_text),set(gcf,'Name',fig_text)

%%
link_fig_axes(figs)
xlim([3750 4100]);


