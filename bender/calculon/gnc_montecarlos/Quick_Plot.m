
if ~exist('t','var')
    t = lns_accel.time;
    lns_accel  = lns_accel.signals.values;
end

plot_est = 1;

error.pos = rtk_pos_topo - est_pos_topo;
error.pos_int = rtk_pos_topo - est_int_pos_topo;
error.vel = rtk_vel_topo - est_vel_topo;
error.accel = rtd_acc_body_in_eci - est_accel;
error.rate = rrk_rate_body_eci_body - est_rate;
error.angle = rrk_eulers_zyx_rot_deg_topo - est_eulers_zyx_rot_deg_topo;
    
% arrange figs
maxpos  = get (0,'screensize'); % determine terminal size in pixels
maxrow = maxpos(4) - 500;
maxcol = maxpos(3) + 100;
mincol = 75;
hands   = get (0,'Children');   % locate fall open figure handles
hands   = sort(hands);          % sort figure handles
numfigs = size(hands,1);        % number of open figures

defSize = get(0,'DefaultFigurePosition');
height = defSize(4);
width = defSize(3);
border = 2;

%-------------------------------------------------------------------------%
%-----                          POS                                  -----%
fnum = 1;
RowNum = 1;
ColNum = 1;
row = maxrow - (RowNum-1)*(height+4*border) ;
col = (ColNum-1)*(width+border) + mincol;
%-------------------------------------------------------------------------%

figure(fnum); clf; set(fnum,'Position',[col row-50 width height])
plot(t(41:end), [rtk_pos_topo(41:end,1:2) rtk_pos_topo(41:end,3)-1738*1000 - ini_alt_wrt_1738rad],'LineWidth',2); grid on; hold on; 
M = {'X-Topocentric','Y-Topocentric','Altitude'};
if plot_est 
    plot(t(49:end), [est_pos_topo(49:end,1:2) est_pos_topo(49:end,3)-1738*1000 - ini_alt_wrt_1738rad]); title('position')
    M = {'X-Topocentric','Y-Topocentric','Altitude','Estimated X-Topocentric','Estimated Y-Topocentric','Estimated Altitude'};
end
legend(M,'Location','SouthEast','fontsize',14)
title('position: topocentric','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('meters','fontsize',14)
saveas(gcf,'Position.png');saveas(gcf,'Position.fig')

%-------------------------------------------------------------------------%
%-----                          VEL                                  -----%
fnum = 2;
RowNum = 1;
ColNum = 2;
row = maxrow - (RowNum-1)*(height+4*border) ;
col = (ColNum-1)*(width+border) + mincol;
%-------------------------------------------------------------------------%

figure(fnum); clf; set(fnum,'Position',[col row-50 width height])
plot(t(41:end), rtk_vel_topo(41:end,:),'LineWidth',2); grid on; hold on;
if plot_est
    plot(t(49:end), est_vel_topo(49:end,:));
end
title('velocity: topocentric','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('meters/sec','fontsize',14)
saveas(gcf,'Velocity.png');saveas(gcf,'Velocity.fig')

%-------------------------------------------------------------------------%
%-----                          ACC                                  -----%
fnum = 3;
RowNum = 1;
ColNum = 3;
row = maxrow - (RowNum-1)*(height+4*border) ;
col = (ColNum-1)*(width+border) + mincol;
%-------------------------------------------------------------------------%

figure(fnum); clf; set(fnum,'Position',[col row-50 width height])
plot(t, rtd_acc_body_in_eci,'LineWidth',2); grid on; hold on; 
if plot_est 
    plot(t, est_accel);
end
title('acceleration in inertial frame','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('m/s^2','fontsize',14)
saveas(gcf,'Acceleration.png');saveas(gcf,'Acceleration.fig')

%-------------------------------------------------------------------------%
%-----                          RATE                                 -----%
fnum = 4;
RowNum = 2;
ColNum = 1;
row = maxrow - (RowNum-1)*(height+4*border) ;
col = (ColNum-1)*(width+border) + mincol;
%-------------------------------------------------------------------------%

figure(fnum); clf; set(fnum,'Position',[col row-50 width height])
plot(t, rrk_rate_body_eci_body*180/pi,'LineWidth',2); grid on; hold on;
Mrate = {'Body X','Body Y','Body Z'};
if plot_est
    plot(t, est_rate*180/pi); 
    Mrate = {'Body X','Body Y','Body Z','Estimated Body X','Estimated Body Y','Estimated Body Z'};
end
legend(Mrate,'Location','SouthEast','fontsize',14)
title('Body Rates','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('degrees/sec','fontsize',14)
saveas(gcf,'BodyRate.png');saveas(gcf,'BodyRate.fig')

%-------------------------------------------------------------------------%
%-----                          EUL                                 -----%
fnum = 5;
RowNum = 2;
ColNum = 2;
row = maxrow - (RowNum-1)*(height+4*border) ;
col = (ColNum-1)*(width+border) + mincol;
%-------------------------------------------------------------------------%

figure(fnum); clf; set(fnum,'Position',[col row-50 width height])
plot(t, rrk_eulers_zyx_rot_deg_topo ,'LineWidth',2); grid on; hold on; 
Mrate = {'Body X','Body Y','Body Z'};
if plot_est
    plot(t, est_eulers_zyx_rot_deg_topo);
    Mrate = {'Body X','Body Y','Body Z','Estimated Body X','Estimated Body Y','Estimated Body Z'};
end
title('euler 321: topocentric','fontsize',14)
legend(Mrate,'Location','SouthEast','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('degrees','fontsize',14)
saveas(gcf,'EulerAngles.png');saveas(gcf,'EulerAngles.fig')

%-------------------------------------------------------------------------%
%-----                          Pos and Vel Err                                 -----%
fnum = 6;
RowNum = 2;
ColNum = 3;
row = maxrow - (RowNum-1)*(height+4*border) ;
col = (ColNum-1)*(width+border) + mincol;
%-------------------------------------------------------------------------%
figure(fnum); clf; set(fnum,'Position',[col row-150 width 2*height])
subplot(3,1,1)
plot(t, error.pos); grid on;
ylabel('External Position Estimator Error (m)','fontsize',14)
title('Topocentric: External Position Estimator Error (m)','fontsize',14)
M = {'X-Topocentric','Y-Topocentric','Altitude',};
legend(M,'fontsize',14)
subplot(3,1,2)
plot(t, error.pos_int); grid on;
ylabel('Internal Position Estimator Error (m)','fontsize',14)
title('Topocentric: Internal Position Estimator Error (m)','fontsize',14)
subplot(3,1,3)
plot(t, error.vel); grid on;
ylabel('External Velocity Estimator Error (m/s)','fontsize',14)
xlabel('Time (sec)','fontsize',14)
title('Topocentric: External Velocity Estimator Error (m/s)','fontsize',14)
saveas(gcf,'EstimationErrors.png');saveas(gcf,'EstimationErrors.fig')

%-------------------------------------------------------------------------%
%-----                          EUL ERR                              -----%
fnum = 7;
RowNum = 2;
ColNum = 4;
row = maxrow - (RowNum-1)*(height+4*border) ;
col = (ColNum-1)*(width+border) + mincol;
%-------------------------------------------------------------------------%

figure(fnum); clf; set(fnum,'Position',[col row-50 width height])
plot(t, error_eul_xyz*180/pi ,'LineWidth',2); grid on; hold on; 
Mrate = {'Body X','Body Y','Body Z'};
title('Euler 123 Attitude Error Relative to Topocentric Frame','fontsize',14)
legend(Mrate,'Location','SouthEast','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('degrees','fontsize',14)
saveas(gcf,'EulerErrors.png');saveas(gcf,'EulerErrors.fig')

fnum = 8;
RowNum = 2;
ColNum = 5;
row = maxrow - (RowNum-1)*(height+4*border) ;
col = (ColNum-1)*(width+border) + mincol;
figure(fnum);clf;set(fnum,'Position',[col row-50 width height]);
plot(t, error.vel); grid on;
ylabel('External Velocity Estimator Error (m/s)','fontsize',14)
xlabel('Time (sec)','fontsize',14)
title('Topocentric: External Velocity Estimator Error (m/s)','fontsize',14)
saveas(gcf,'VelEstErr.png');saveas(gcf,'VelEstErr.fig')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

horz_pos = norm(rtk_pos_topo(end,1:2),2);
horz_vel = norm(rtk_vel_topo(end,1:2));
horz_vel_est_err = norm(rtk_vel_topo(end,1:2) - est_vel_topo(end,1:2),2);
alt_knowledge =  norm(rtk_pos_topo(end,3) - est_pos_topo(end,3));
vert_vel =  norm(rtk_vel_topo(end,3));
vert_vel_est_err = abs(rtk_vel_topo(end,3) - est_vel_topo(end,3));
final_gnc_ang_err = norm(rrk_eulers_zyx_rot_deg_topo(end,1:2));
body_rates = norm(rrk_rate_body_eci_body(end,:))*180/pi;
dry_mass = evalin('base','mpl_mass_dry');final_mass = mas_mass(end);

if (horz_pos > 5000) |(horz_vel > 2) | (horz_vel_est_err > 2) | (alt_knowledge > 8) | (vert_vel > 4) | (vert_vel_est_err > 4) | (final_gnc_ang_err > 15) | (body_rates > 10) | (final_mass < dry_mass)  
    disp('Degenerative Case.  One or more of the following conditions violated:')
else
    disp('All Landing Conditions Within Limits')
end
disp('(horz_pos > 5000) |(horz_vel > 2) | (horz_vel_est_err > 2) | (alt_knowledge > 8) | (vert_vel > 4) | (vert_vel_est_err > 4) | (final_gnc_ang_err > 15) | (body_rates > 10) | (final_mass < dry_mass)')
str = sprintf(['horz_pos = ',num2str(horz_pos)]);disp(str)
str = sprintf(['horz_vel = ',num2str(horz_vel)]);disp(str)
str = sprintf(['horz_vel_est_err = ',num2str(horz_vel_est_err)]);disp(str)
str = sprintf(['alt_knowledge = ',num2str(alt_knowledge)]);disp(str)
str = sprintf(['vert_vel = ',num2str(vert_vel)]);disp(str)
str = sprintf(['vert_vel_est_err = ',num2str(vert_vel_est_err)]);disp(str)
str = sprintf(['final_gnc_ang_err = ',num2str(final_gnc_ang_err)]);disp(str)
str = sprintf(['body_rates = ',num2str(body_rates)]);disp(str)
str = sprintf(['final_mass = ',num2str(final_mass)]);disp(str)

str = sprintf(['Altimeter Noise (percent) = ',num2str(rdr_percent_error*100)]);disp(str)
str = sprintf(['Altimeter Maximum Range (m) = ',num2str(rdr_range_max)]);disp(str)
str = sprintf(['Camera Focal Length (m) = ',num2str(cam_focal_length_f)]);disp(str)
str = sprintf(['Camera Angular Field of View (deg) = ',num2str(cam_aov*180/pi)]);disp(str)
str = sprintf(['Camera Image Delta-T (sec) = ',num2str(cam_image_delta_t)]);disp(str)
str = sprintf(['Camera Processing Delay (sec) = ',num2str(cam_processing_delay)]);disp(str)
str = sprintf(['Camera Integration Time(sec) = ',num2str(cam_integ_time)]);disp(str)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% 
% %%
% 
% 
% figure(10); clf; hold on; grid on;
% axis([-3000        3000      -10000        2000       0        4000])
% for jj = 1 : length(image_corners)
%     
%     clf; hold on; grid on;
%         axis([-3000        3000      -10000        2000       0        4000])
%     
%     X = [camera_pos(jj,1) ; image_corners(1,1,jj); NaN;
%         camera_pos(jj,1) ; image_corners(2,1,jj); NaN;
%         camera_pos(jj,1) ; image_corners(3,1,jj); NaN;
%         camera_pos(jj,1) ; image_corners(4,1,jj); NaN ];
%     
%     Y = [camera_pos(jj,2) ; image_corners(1,2,jj); NaN;
%         camera_pos(jj,2) ; image_corners(2,2,jj); NaN;
%         camera_pos(jj,2) ; image_corners(3,2,jj); NaN;
%         camera_pos(jj,2) ; image_corners(4,2,jj); NaN ];
%     
%     Z = [camera_pos(jj,3) ; image_corners(1,3,jj); NaN;
%         camera_pos(jj,3) ; image_corners(2,3,jj); NaN;
%         camera_pos(jj,3) ; image_corners(3,3,jj); NaN;
%         camera_pos(jj,3) ; image_corners(4,3,jj); NaN ];
%     
% %     x_limit = [min( min(X), camera_pos(jj,1)) max( max(X), camera_pos(jj,1)) ];
% %     y_limit = [min( min(Y), camera_pos(jj,2)) max( max(Y), camera_pos(jj,2)) ];
% %     z_limit = [min( min(Z), camera_pos(jj,3)) max( max(Z), camera_pos(jj,3)) ];
% %     
% %     axis([ sort(mean(x_limit)+x_limit*2) , sort(mean(y_limit)+y_limit*2) , 0 z_limit(2)+50 ])
% %     round([ sort(mean(x_limit)+x_limit*2) , sort(mean(y_limit)+y_limit*2) , 0 z_limit(2)+50 ])
% 
%     plot3(camera_pos(1:jj,1),camera_pos(1:jj,2),camera_pos(1:jj,3),'k--','LineWidth',2)
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
%     view(3)
%     pause(0.25)
%     
% end
