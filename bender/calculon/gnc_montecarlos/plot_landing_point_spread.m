
% run script for the 2D landing point spread

save_flag  = 1;
[ data_pdf, best_model ] = plot_mc_distribution(rss_landing_err, 'Radial Position Drift at Touchdown', 'm', save_flag);

radius_3sig_prob = icdf(best_model, 0.997);
radius_99_prob = icdf(best_model, 0.99);

figure(10);
grid on; hold on;
set(gcf,'Position',[680   351   774   627])

plot(mc_all_final(mc_all_final(:,39)==0,15),mc_all_final(mc_all_final(:,39)==0,16),'b*');
plot(mc_all_final(mc_all_final(:,39)==1,15),mc_all_final(mc_all_final(:,39)==1,16),'r*');

mean_landing_error = mean(rss_landing_err);
standard_deviation_landing_error = std(rss_landing_err);

% gaussian fit
circle_stat = 3*standard_deviation_landing_error*sin(2*pi*0.01*[0:100]);
circle_3_sigma_x = 3*standard_deviation_landing_error*cos(2*pi*0.01*[0:100]);
plot(circle_3_sigma_x,circle_stat,'c:','linewidth',2);

% best fit 99.7%
circle_stat = radius_3sig_prob*sin(2*pi*0.01*[0:100]);
circle_3_sigma_x = radius_3sig_prob*cos(2*pi*0.01*[0:100]);
plot(circle_3_sigma_x,circle_stat,'m-','linewidth',2);

% best fit 99.0%
circle_stat = radius_99_prob*sin(2*pi*0.01*[0:100]);
circle_3_sigma_x = radius_99_prob*cos(2*pi*0.01*[0:100]);
plot(circle_3_sigma_x,circle_stat,'r-','linewidth',2);

str_text_box = { horzcat('Empirical Mean = ',sprintf('%.2f',mean_landing_error),' m'), ...
                 horzcat('Emperical Standard Deviation = ', sprintf('%.2f',standard_deviation_landing_error),' m'), ...
                 sprintf('\nGaussian Fit 99.7%% Dispersion Radius = %.2f m',3*standard_deviation_landing_error ), ...
                 sprintf('%s Fit 99.7%% Dispersion Radius = %.2f m', best_model.DistributionName, radius_3sig_prob ), ...
                 sprintf('%s Fit 99.0%% Dispersion Radius = %.2f m', best_model.DistributionName, radius_99_prob )
                };
annotation('textbox',[.15 .22 .27 .06],'string', str_text_box,'BackgroundColor','w', 'FitBoxToText','On') 

axis equal

%,'Failed landing positions' (none plotted)
legend('Successful landing position','Gassian Fit 3-\sigma',[best_model.DistributionName ' Fit 99.7%'],[best_model.DistributionName ' Fit 99.0%'])


title('Touchdown Lateral Guidance and Control Topocentric Position','fontsize',14)
xlabel('Topocentric X Position (meters)','fontsize',14)
ylabel('Topocentric Y Position (meters)','fontsize',14)


