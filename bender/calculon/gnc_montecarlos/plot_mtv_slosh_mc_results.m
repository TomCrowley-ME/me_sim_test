load MC_WORKSPACE
load mtv_slosh_mcall.mat
close all

for kk = 1 : mc_n
    
    %percent_bin = [percent_errors(kk-1) percent_errors(kk)];
    
    indices{kk} = find(mc_all_initial(:,iin.ldr_2k_percent_error) == percent_errors(kk)); % & mc_all_initial(:,iin.ldr_2k_percent_error) < percent_bin(2));
    
    for pp = 1 : mc_n
%         by2index{pp} = find(mc_all_initial(indices{kk},iin.ldr_2k_max_range) == max_ranges(kk)); % & mc_all_initial(:,iin.ldr_2k_percent_error) < percent_bin(2));
        by2index = indices;
        %         inputs(kk,pp) = percent_errors(kk)*100 ; %+ max_ranges(pp);
        %
        for checknan = 1:size(indices{kk},1)
            if isnan(mc_all_final(indices{kk}(checknan),ifi.gnc_pos_err)) == 1
                mc_all_final(indices{kk}(checknan),ifi.gnc_pos_err) = [ 0 0 0];
                mc_all_final(indices{kk}(checknan),ifi.gnc_vel_err) = [ 0 0 0];
                mc_all_final(indices{kk}(checknan),ifi.est_pos_err) = [ 0 0 0];
                mc_all_final(indices{kk}(checknan),ifi.est_vel_err) = [ 0 0 0];
                mc_all_final(indices{kk}(checknan),ifi.mass) = 0;
            end
        end
        total_fuel_used(kk,kk)  = mc_all_initial(kk,iin.mass) - mc_all_final(kk,ifi.mass);
        n_failure(kk,kk)        = mc_all_final(kk,ifi.fail);
        n_failure_strict(kk,kk) = mc_all_final(kk,ifi.fail_strict);
        lateral_pos(kk,kk)      = norm(mc_all_final(kk,ifi.gnc_pos_err(1:2)));
        lateral_vel(kk,kk)      = norm(mc_all_final(kk,ifi.gnc_vel_err(1:2)));
        vertical_pos(kk,kk)     = norm(mc_all_final(kk,ifi.est_pos_err(3)));
        vertical_vel(kk,kk)     = norm(mc_all_final(kk,ifi.gnc_vel_err(3)));

    end
end

nsuccess = 0;
nfail = 0;

for iter=1:size(mc_all_final,1)
   initial_est_pos_err(iter)     = norm(mc_all_initial(iter,2:4));
   initial_est_vel_err(iter)     = norm(mc_all_initial(iter,5:7));
   initial_est_ang_err(iter)     = norm(mc_all_initial(iter,8:10));
   initial_est_rate_err(iter)    = norm(mc_all_initial(iter,11:13));
   lateral_est_vel_scalar(iter)  = norm(mc_all_final(iter,5:6),2);
   vertical_est_vel_scalar(iter) = abs(mc_all_final(iter,7));
   lateral_gnc_pos_scalar(iter)  = norm(mc_all_final(iter,15:16),2);
   lateral_gnc_vel_scalar(iter)  = norm(mc_all_final(iter,18:19),2);
   vertical_gnc_pos_scalar(iter) = mc_all_final(iter,17);
   vertical_gnc_vel_scalar(iter) = abs(mc_all_final(iter,20));
   final_est_vert_pos_err(iter)  = abs(mc_all_final(iter,4));
   final_est_vel_err(iter)       = norm(mc_all_final(iter,5:7));
   final_est_ang_err(iter)       = norm(mc_all_final(iter,8:10));
   final_est_rate_err(iter)      = norm(mc_all_final(iter,11:13));
   final_gnc_vel_err(iter)       = norm(mc_all_final(iter,18:20));
   final_gnc_ang_err(iter)       = norm(mc_all_final(iter,21:22),2);
   final_gnc_rate_err(iter)      = norm(mc_all_final(iter,24:26));
   total_fuel_used_scalar(iter)  = mc_all_initial(iter,14) - mc_all_final(iter,14);
   lateral_cg_dry_offset(iter)   = norm(mc_all_initial(iter,23:24));
   lateral_cg_wet_offset(iter)   = norm(mc_all_initial(iter,40:41));
   cm_x_unit(iter) = mc_all_initial(iter,26)/norm([mc_all_initial(iter,26),mc_all_initial(iter,27)]);
   cm_y_unit(iter) = mc_all_initial(iter,27)/norm([mc_all_initial(iter,26),mc_all_initial(iter,27)]);
   cm_az_deg(iter) = atan2(cm_y_unit(iter),cm_x_unit(iter))*180/pi;

   if mc_all_final(iter,39)==0
       Success(iter) = 1;
       nsuccess = nsuccess + 1;
   else
       Success(iter) = 0;
       nfail = nfail + 1;
   end
end

fprintf(sprintf('Number of Successful Landings: %d\n',nsuccess))
fprintf(sprintf('Number of Failed Landings: %d\n',nfail))

if (nfail>0)
   fprintf('Cases failed due to:\n')
   fprintf('Horizontal position                = %d\n',length(find(lateral_gnc_pos_scalar      > 3.0  )) )
   fprintf('Horizontal velocity                = %d\n',length(find(lateral_gnc_vel_scalar      > 0.75 )) )
   fprintf('Horizontal velocity estimate error = %d\n',length(find(lateral_est_vel_scalar      > 1.0  )) )
   fprintf('Altitude estimate error            = %d\n',length(find(final_est_vert_pos_err      > 0.2  )) )
   fprintf('Vertical velocity                  = %d\n',length(find(vertical_gnc_vel_scalar     > 2.0  )) )
   fprintf('Vertical velocity estimate error   = %d\n',length(find(vertical_est_vel_scalar     > 2.0  )) )
   fprintf('Touchdown angle from vertical      = %d\n',length(find(final_gnc_ang_err           > 25.0 )) )
   fprintf('Touchdown body rates               = %d\n',length(find(final_gnc_rate_err          > 45.0 )) )
   fprintf('HTP depletion                      = %d\n',length(find(mc_all_final(:,43)         >= mc_all_initial(:,86))) )
end

%%
figure;plot(mc_all_final(:,1),Success,'*');grid on
title_string = 'Criteria (horz_\pos > 3) |(horz_vel > 0.75) | (horz\_vel\_est\_err > 1.0) | (alt\_knowledge > 0.2) | (vert\_vel > 2.0) | (vert\_vel\_est\_err > 2.0) | (final\_gnc\_ang\_err > 25) | (body\_rates > 45) | (htp\_mass\_mass >= htp\_mass\_initial)';
title_string = 'Pass / Fail';
title(title_string);
xlabel('Case Number')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(mc_all_final(itest,15),mc_all_final(itest,16),'b*');
 elseif(mc_all_final(itest,39)==1)
     plot(mc_all_final(itest,15),mc_all_final(itest,16),'r*');
 end
rss_landing_err(itest) = norm(mc_all_final(itest,15:16));
end
mean_landing_error = mean(rss_landing_err);
standard_deviation_landing_error = std(rss_landing_err);
title('Touchdown Topocentric Position','fontsize',14)
xlabel('Topocentric X Position (meters)','fontsize',14)
ylabel('Topocentric Y Position (meters)','fontsize',14)
str_text_box = {horzcat('Mean = ',num2str(mean_landing_error),' m'),horzcat('3 Sigma = ',num2str(3*standard_deviation_landing_error),' m')};
annotation('textbox',[.2 .8 .27 .1],'string',str_text_box) 
hold on;
circle_3_sigma_y = 3*standard_deviation_landing_error*sin(2*pi*0.01*[0:100]);
circle_3_sigma_x = 3*standard_deviation_landing_error*cos(2*pi*0.01*[0:100]);
plot(circle_3_sigma_x,circle_3_sigma_y,'r-','linewidth',2);
saveas(gcf,'LateralPosErr.png');saveas(gcf,'LateralPosErr.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
  if(mc_all_final(itest,39)==0)
     plot(mc_all_final(itest,15)-median(mc_all_final(:,15)),mc_all_final(itest,16)-median(mc_all_final(:,16)),'b*');
 elseif(mc_all_final(itest,39)==1)
     plot(mc_all_final(itest,15)-median(mc_all_final(:,15)),mc_all_final(itest,16)-median(mc_all_final(:,16)),'r*');
 end

 rss_landing_err(itest) = norm(mc_all_final(itest,15:16));
end
mean_landing_error = mean(rss_landing_err);
standard_deviation_landing_error = std(rss_landing_err);
title('Touchdown Topocentric Position Relative to Median','fontsize',14)
xlabel('Topocentric X Position (meters)','fontsize',14)
ylabel('Topocentric Y Position (meters)','fontsize',14)
str_text_box = {horzcat('Mean = ',num2str(mean_landing_error),' m'),horzcat('3 Sigma = ',num2str(3*standard_deviation_landing_error),' m')};
annotation('textbox',[.2 .8 .27 .1],'string',str_text_box) 
hold on;
circle_3_sigma_y = 3*standard_deviation_landing_error*sin(2*pi*0.01*[0:100]);
circle_3_sigma_x = 3*standard_deviation_landing_error*cos(2*pi*0.01*[0:100]);
plot(circle_3_sigma_x,circle_3_sigma_y,'r-','linewidth',2);
saveas(gcf,'LateralPosErrMedian.png');saveas(gcf,'LateralPosErrMedian.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(lateral_gnc_vel_scalar(itest),abs(mc_all_final(itest,20)),'b*');
 elseif(mc_all_final(itest,39)==1)
     plot(lateral_gnc_vel_scalar(itest),abs(mc_all_final(itest,20)),'r*');
 end
end
title('Touchdown Lateral Velocity vs Vertical Velocity','fontsize',14)
xlabel('Topocentric Lateral Velocity (m/s)','fontsize',14)
ylabel('Topocentric Vertical Velocity (m/s)','fontsize',14)
saveas(gcf,'LateralVerticalVel.png');saveas(gcf,'LateralVerticalVel.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(norm(mc_all_final(itest,21:22)),norm(mc_all_final(itest,24:25)),'b*');
 elseif(mc_all_final(itest,39)==1)
     plot(norm(mc_all_final(itest,21:22)),norm(mc_all_final(itest,24:25)),'r*');
 end
end
title('Touchdown Angle Versus Body Rate','fontsize',14)
xlabel('Angle From Vertical (deg)','fontsize',14)
ylabel('Body Rate (deg/s)','fontsize',14)
saveas(gcf,'TDAngleVsRate.png');saveas(gcf,'TDAngleVsRate.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(lateral_gnc_vel_scalar(itest),norm(mc_all_final(itest,21:22)),'b*');
 elseif(mc_all_final(itest,39)==1)
     plot(lateral_gnc_vel_scalar(itest),norm(mc_all_final(itest,21:22)),'r*');
 end
end
title('Touchdown Angle vs Lateral Velocity','fontsize',14);
xlabel('Topocentric Lateral Velocity (m/s)','fontsize',14)
ylabel('Angle From Vertical (deg)','fontsize',14)
saveas(gcf,'TDAngleandLateralVel.png');saveas(gcf,'TDAngleandLateralVel.fig')
%%
figure;plot(final_gnc_ang_err,Success,'*');grid on
title('Landing Success Versus Touchdown Off Vertical Angle Error')
xlabel('Touchdown Guidance and Control Off Vertical Angle Error (deg)')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear final_gnc_ang_err_fail final_gnc_ang_err_success
for itest =1:size(final_gnc_ang_err,2)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        final_gnc_ang_err_success(isuccess) = final_gnc_ang_err(itest);
    else
        ifail = ifail + 1;
        final_gnc_ang_err_fail(ifail) = final_gnc_ang_err(itest);
    end
end
if exist('final_gnc_ang_err_success')==1
    figure;hist(final_gnc_ang_err_success,10);grid on
    title('Final GNC Angle Error to Landing Success','fontsize',14)
    xlabel('Final GNC Angle Error (deg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistAngErrSucc.png');saveas(gcf,'HistAngErrSucc.fig')
end
if exist('final_gnc_ang_err_fail')==1
    figure;hist(final_gnc_ang_err_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Final GNC Angle Error to Landing Failure','fontsize',14)
    xlabel('Final GNC Angle Error (deg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
end
%%
figure;plot(final_gnc_rate_err,Success,'*');grid on
title('Landing Success Versus Touchdown Body Rate Error')
xlabel('Touchdown Guidance and Control Body Rate Error (deg/sec)')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear final_gnc_rate_err_fail final_gnc_rate_err_success
for itest =1:size(final_gnc_rate_err,2)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        final_gnc_rate_err_success(isuccess) = final_gnc_rate_err(itest);
    else
        ifail = ifail + 1;
        final_gnc_rate_err_fail(ifail) = final_gnc_rate_err(itest);
    end
end
if exist('final_gnc_rate_err_success')==1
    figure;hist(final_gnc_rate_err_success,10);grid on
    title('Final GNC Rate Error to Landing Success','fontsize',14)
    xlabel('Final GNC Rate Error (deg/sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistRateErrSucc.png');saveas(gcf,'HistRateErrSucc.fig')
end
if exist('final_gnc_rate_err_fail')==1
    figure;hist(final_gnc_rate_err_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Final GNC Rate Error to Landing Failure','fontsize',14)
    xlabel('Final GNC Rate Error (deg/sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
end
%%
figure;plot(final_gnc_vel_err,Success,'*');grid on
title('Landing Success Versus Touchdown Velocity Error')
xlabel('Touchdown Total Velocity Error')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear final_gnc_vel_err_fail final_gnc_vel_err_success
for itest =1:size(final_gnc_vel_err,2)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        final_gnc_vel_err_success(isuccess) = final_gnc_vel_err(itest);
    else
        ifail = ifail + 1;
        final_gnc_vel_err_fail(ifail) = final_gnc_vel_err(itest);
    end
end
if exist('final_gnc_vel_err_success')==1
    figure;hist(final_gnc_vel_err_success,10);grid on
    title('Final GNC Velocity Error to Landing Success','fontsize',14)
    xlabel('Final GNC Velocity Error (m/sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistVelErrSucc.png');saveas(gcf,'HistVelErrSucc.fig')
end
if exist('final_gnc_vel_err_fail')==1
    figure;hist(final_gnc_vel_err_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Final GNC Velocity Error to Landing Failure','fontsize',14)
    xlabel('Final GNC Velocity Error (m/sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistVelErrFail.png')
end
%%
figure;plot(final_est_vert_pos_err,Success,'*');grid on
title('Landing Success Versus Touchdown Estimated Vertical Position Error')
xlabel('Touchdown Estimated Total Vertical Position Error')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear final_est_vert_pos_err_fail final_est_vert_pos_err_success
for itest =1:size(final_est_vert_pos_err,2)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        final_est_vert_pos_err_success(isuccess) = final_est_vert_pos_err(itest);
    else
        ifail = ifail + 1;
        final_est_vert_pos_err_fail(ifail) = final_est_vert_pos_err(itest);
    end
end
if exist('final_est_vert_pos_err_success')==1
    figure;hist(final_est_vert_pos_err_success,10);grid on
    title('Final Estimated Vertical Position Error to Landing Success','fontsize',14)
    xlabel('Final Estimated Vertical Position Error (meters)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistEstVertPosErrSucc.png');saveas(gcf,'HistEstVertPosErrSucc.fig')
end
if exist('final_est_vert_pos_err_fail')==1
    figure;hist(final_est_vert_pos_err_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Final Estimated Vertical Position Error to Landing Failure','fontsize',14)
    xlabel('Final Estimated Vertical Position Error (meters)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
end
%%
figure;plot(final_est_vel_err,Success,'*');grid on
title('Landing Success Versus Touchdown Estimated Velocity Error')
xlabel('Touchdown Estimated Total Velocity Error')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear final_est_vel_err_fail final_est_vel_err_success
for itest =1:size(final_est_vel_err,2)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        final_est_vel_err_success(isuccess) = final_est_vel_err(itest);
    else
        ifail = ifail + 1;
        final_est_vel_err_fail(ifail) = final_est_vel_err(itest);
    end
end
if exist('final_est_vel_err_success')==1
    figure;hist(final_est_vel_err_success,10);grid on
    title('Final Estimated Velocity Error to Landing Success','fontsize',14)
    xlabel('Final Estimated Velocity Error (m/sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistEstVelErrSucc.png');saveas(gcf,'HistEstVelErrSucc.fig')
end
if exist('final_est_vel_err_fail')==1
    figure;hist(final_est_vel_err_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Final Estimated Velocity Error to Landing Failure','fontsize',14)
    xlabel('Final Estimated Velocity Error (m/sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
end
%%
figure;plot(lateral_gnc_vel_scalar,Success,'*');grid on
title('Landing Success Versus Touchdown Guidance and Control Lateral Velocity Error')
xlabel('Touchdown Guidance and Control Lateral Velocity Error')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear lateral_gnc_vel_scalar_fail lateral_gnc_vel_scalar_success
for itest =1:size(lateral_gnc_vel_scalar,2)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        lateral_gnc_vel_scalar_success(isuccess) = lateral_gnc_vel_scalar(itest);
    else
        ifail = ifail + 1;
        lateral_gnc_vel_scalar_fail(ifail) = lateral_gnc_vel_scalar(itest);
    end
end
if exist('lateral_gnc_vel_scalar_success')==1
    figure;hist(lateral_gnc_vel_scalar_success,10);grid on 
    title('Touchdown Guidance and Control Lateral Velocity Error to Landing Success','fontsize',14)
    xlabel('Guidance and Control Lateral Velocity Error (m/s)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistLatVelCtrlErrSucc.png');saveas(gcf,'HistLatVelCtrlErrSucc.fig')
end
if exist('lateral_gnc_vel_scalar_fail')==1
    figure;hist(lateral_gnc_vel_scalar_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Touchdown Guidance and Control Lateral Velocity Error to Landing Failure','fontsize',14)
    xlabel('Guidance and Control Lateral Velocity Error (m/s)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
end
%%
figure;plot(vertical_gnc_vel_scalar,Success,'*');grid on
title('Landing Success Versus Touchdown Guidance and Control Vertical Velocity Accuracy')
xlabel('Touchdown Guidance and Control Vertical Velocity Accuracy')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear vertical_gnc_vel_scalar_fail vertical_gnc_vel_scalar_success
for itest =1:size(vertical_gnc_vel_scalar,2)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        vertical_gnc_vel_scalar_success(isuccess) = vertical_gnc_vel_scalar(itest);
    else
        ifail = ifail + 1;
        vertical_gnc_vel_scalar_fail(ifail) = vertical_gnc_vel_scalar(itest);
    end
end
if exist('vertical_gnc_vel_scalar_success')==1
    figure;hist(vertical_gnc_vel_scalar_success,10);grid on
    title('Touchdown Guidance and Control Vertical Velocity Accuracy to Landing Success','fontsize',14)
    xlabel('Guidance and Control Vertical Velocity Accuracy (1 m/s Target)','fontsize',14)
    ylabel('Number of Cases')
    saveas(gcf,'HistVertVelCtrlErrSucc.png');saveas(gcf,'HistVertVelCtrlErrSucc.fig')
end
if exist('vertical_gnc_vel_scalar_fail')==1
    figure;hist(vertical_gnc_vel_scalar_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Touchdown Guidance and Control Vertical Velocity Error to Landing Failure','fontsize',14)
    xlabel('Guidance and Control Vertical Velocity Accuracy (1 m/s Target)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
end
%%
figure;plot(vertical_gnc_pos_scalar,Success,'*');grid on
title('Landing Success Versus Touchdown Guidance and Control Vertical Position Error')
xlabel('Touchdown Guidance and Control Vertical Position Error')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear vertical_gnc_pos_scalar_fail vertical_gnc_pos_scalar_success
for itest =1:size(vertical_gnc_pos_scalar,2)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        vertical_gnc_pos_scalar_success(isuccess) = vertical_gnc_pos_scalar(itest);
    else
        ifail = ifail + 1;
        vertical_gnc_pos_scalar_fail(ifail) = vertical_gnc_pos_scalar(itest);
    end
end
if exist('vertical_gnc_pos_scalar_success')==1
    figure;hist(vertical_gnc_pos_scalar_success,10);grid on
    title('Touchdown Guidance and Control Vertical Position Error to Landing Success','fontsize',14)
    xlabel('Guidance and Control Vertical Position Error (meters)','fontsize',14)
    ylabel('Number of Cases')
    saveas(gcf,'HistVertPosCtrlErrSucc.png');saveas(gcf,'HistVertPosCtrlErrSucc.fig')
end
if exist('vertical_gnc_pos_scalar_fail')==1
    figure;hist(vertical_gnc_pos_scalar_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Touchdown Guidance and Control Vertical Position Error to Landing Failure','fontsize',14)
    xlabel('Guidance and Control Vertical Position Error (meters)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
end
%%
figure;plot(lateral_gnc_pos_scalar,Success,'*');grid on
title('Landing Success Versus Touchdown Guidance and Control Horizontal Position Error')
xlabel('Touchdown Guidance and Control HOrizontal Position Error')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear lateral_gnc_pos_scalar_fail lateral_gnc_pos_scalar_success
for itest =1:size(lateral_gnc_pos_scalar,2)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        lateral_gnc_pos_scalar_success(isuccess) = lateral_gnc_pos_scalar(itest);
    else
        ifail = ifail + 1;
        lateral_gnc_pos_scalar_fail(ifail) = lateral_gnc_pos_scalar(itest);
    end
end
if exist('lateral_gnc_pos_scalar_success')==1
    figure;hist(lateral_gnc_pos_scalar_success,10);grid on
    title('Touchdown Guidance and Control Horizontal Position Error to Landing Success','fontsize',14)
    xlabel('Guidance and Control Horizontal Position Error (meters)','fontsize',14)
    ylabel('Number of Cases')
    saveas(gcf,'HistHorzPosCtrlErrSucc.png');saveas(gcf,'HistHorzPosCtrlErrSucc.fig')
end
if exist('lateral_gnc_pos_scalar_fail')==1
    figure;hist(lateral_gnc_pos_scalar_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Touchdown Guidance and Control Horizontal Position Error to Landing Failure','fontsize',14)
    xlabel('Guidance and Control Horizontal Position Error (meters)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
end

figure;plot(lateral_est_vel_scalar,Success,'*');grid on
title('Landing Success Versus Touchdown Estimated Lateral Velocity Error')
xlabel('Touchdown Estimated Lateral Velocity Error')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear lateral_est_vel_scalar_fail lateral_est_vel_scalar_success
for itest =1:size(lateral_est_vel_scalar,2)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        lateral_est_vel_scalar_success(isuccess) = lateral_est_vel_scalar(itest);
    else
        ifail = ifail + 1;
        lateral_est_vel_scalar_fail(ifail) = lateral_est_vel_scalar(itest);
    end
end
if exist('lateral_est_vel_scalar_success')==1
    figure;hist(lateral_est_vel_scalar_success,10);grid on 
    title('Touchdown Estimated Lateral Velocity Error to Landing Success','fontsize',14)
    xlabel('Estimated Lateral Velocity Error (m/s)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistLatVelEstErrSucc.png');saveas(gcf,'HistLatVelEstErrSucc.fig')
end
if exist('lateral_est_vel_scalar_fail')==1
    figure;hist(lateral_est_vel_scalar_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Touchdown Estimated Lateral Velocity Error to Landing Failure','fontsize',14)
    xlabel('Estimated Lateral Velocity Error (m/s)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
end
%%
figure;plot(vertical_est_vel_scalar,Success,'*');grid on
title('Landing Success Versus Touchdown Estimated Vertical Velocity Error')
xlabel('Touchdown Estimated Vertical Velocity Error')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear vertical_est_vel_scalar_fail vertical_est_vel_scalar_success
for itest =1:size(vertical_est_vel_scalar,2)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        vertical_est_vel_scalar_success(isuccess) = vertical_est_vel_scalar(itest);
    else
        ifail = ifail + 1;
        vertical_est_vel_scalar_fail(ifail) = vertical_est_vel_scalar(itest);
    end
end
if exist('vertical_est_vel_scalar_success')==1
    figure;hist(vertical_est_vel_scalar_success,10);grid on 
    title('Touchdown Estimated Vertical Velocity Error to Landing Success','fontsize',14)
    xlabel('Estimated Vertical Velocity Error (m/s)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistVertVelEstErrSucc.png');saveas(gcf,'HistVertVelEstErrSucc.fig')
end
if exist('vertical_est_vel_scalar_fail')==1
    figure;hist(vertical_est_vel_scalar_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Touchdown Estimated Vertical Velocity Error to Landing Failure','fontsize',14)
    xlabel('Estimated Vertical Velocity Error (m/s)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
end
%%
figure;plot(total_fuel_used_scalar,Success,'*');grid on
title('Landing Success Versus Fuel Used at Touchdown')
xlabel('Fuel Used at Touchdown (kg)' )
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear total_fuel_used_scalar_fail total_fuel_used_scalar_success
for itest =1:size(total_fuel_used_scalar,2)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        total_fuel_used_scalar_success(isuccess) = total_fuel_used_scalar(itest);
    else
        ifail = ifail + 1;
        total_fuel_used_scalar_fail(ifail) = total_fuel_used_scalar(itest);
    end
end
if exist('total_fuel_used_scalar_success')==1
    figure;hist(total_fuel_used_scalar_success,10);grid on 
    title('Total Fuel Usage to Landing Success','fontsize',14)
    xlabel('Total Fuel Usage (kg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistFuelUsageSucc.png');saveas(gcf,'HistFuelUsageSucc.fig')
end
if exist('total_fuel_used_scalar_fail')==1
    figure;hist(total_fuel_used_scalar_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Total Fuel Usage to Landing Failure','fontsize',14)
    xlabel('Total Fuel Usage (kg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistFuelUsageFail.png')
end
%%
figure;plot(initial_est_pos_err,Success,'*');grid on
title('Landing Success Versus Initial Estimated Position Error')
xlabel('Initial Estimated Total Position Error')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear initial_est_pos_err_fail initial_est_pos_err_success
for itest =1:size(initial_est_pos_err,2)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        initial_est_pos_err_success(isuccess) = initial_est_pos_err(itest);
    else
        ifail = ifail + 1;
        initial_est_pos_err_fail(ifail) = initial_est_pos_err(itest);
    end
end
if exist('initial_est_pos_err_success')==1
    figure;hist(initial_est_pos_err_success,10);grid on
    title('Initial Estimated Position Error to Landing Success','fontsize',14)
    xlabel('Initial Estimated Position Error (meters)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistInitEstPosErrSucc.png');saveas(gcf,'HistInitEstPosErrSucc.fig')
end
if exist('initial_est_pos_err_fail')==1
    figure;hist(initial_est_pos_err_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Initial Estimated Position Error to Landing Failure','fontsize',14)
    xlabel('Initial Estimated Position Error (meters)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistInitEstPosErrFail.png')
end
%%
figure;plot(initial_est_vel_err,Success,'*');grid on
title('Landing Success Versus Initial Estimated Velocity Error')
xlabel('Initial Estimated Total Velocity Error')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear initial_est_vel_err_fail initial_est_vel_err_success
for itest =1:size(initial_est_vel_err,2)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        initial_est_vel_err_success(isuccess) = initial_est_vel_err(itest);
    else
        ifail = ifail + 1;
        initial_est_vel_err_fail(ifail) = initial_est_vel_err(itest);
    end
end
if exist('initial_est_vel_err_success')==1
    figure;hist(initial_est_vel_err_success,10);grid on
    title('Initial Estimated Velocity Error to Landing Success','fontsize',14)
    xlabel('Initial Estimated Velocity Error (m/s)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistInitEstVelErrSucc.png');saveas(gcf,'HistInitEstVelErrSucc.fig')
end
if exist('initial_est_vel_err_fail')==1
    figure;hist(initial_est_vel_err_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Initial Estimated Velocity Error to Landing Failure','fontsize',14)
    xlabel('Initial Estimated Velocity Error (m/s)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistInitEstVelFail.png')
end
%%
figure;plot(initial_est_ang_err,Success,'*');grid on
title('Landing Success Versus Initial Estimated Attitude Error')
xlabel('Initial Estimated Total Attitude Error')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear initial_est_ang_err_fail initial_est_ang_err_success
for itest =1:size(initial_est_ang_err,2)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        initial_est_ang_err_success(isuccess) = initial_est_ang_err(itest);
    else
        ifail = ifail + 1;
        initial_est_ang_err_fail(ifail) = initial_est_ang_err(itest);
    end
end
if exist('initial_est_ang_err_success')==1
    figure;hist(initial_est_ang_err_success,10);grid on 
    title('Initial Estimated Attitude Error to Landing Success','fontsize',14)
    xlabel('Initial Estimated Attitude Error (deg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistInitEstAttErrSucc.png');saveas(gcf,'HistInitEstAttErrSucc.fig')
end
if exist('initial_est_ang_err_fail')==1
    figure;hist(initial_est_ang_err_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Initial Estimated Attitude Error to Landing Failure','fontsize',14)
    xlabel('Initial Estimated Attitude Error (deg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistInitEstAttErrFail.png')
end
%%
figure;plot(mc_all_initial(:,15)*100,Success,'*');grid on
title('Landing Success Versus Altimeter Percent Error')
xlabel('Altimeter Percent Error (%)')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear altimeter_percent_err_fail altimeter_percent_err_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        altimeter_percent_err_success(isuccess) = mc_all_initial(itest,15)*100;
    else
        ifail = ifail + 1;
        altimeter_percent_err_fail(ifail) = mc_all_initial(itest,15)*100;
    end
end
if exist('altimeter_percent_err_success')==1
    figure;hist(altimeter_percent_err_success,10);grid on 
    title('Altimeter Percent Error to Landing Success','fontsize',14)
    xlabel('Altimeter Percent Error (%)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistAltErrorSucc.png')
end
if exist('altimeter_percent_err_fail')==1
    figure;hist(altimeter_percent_err_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Altimeter Percent Error to Landing Failure','fontsize',14)
    xlabel('Altimeter Percent Error (%)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistAltErrorFail.png')
end
%%
figure;plot(mc_all_initial(:,16),Success,'*');grid on
title('Landing Success Versus Altimeter Maximum Range')
xlabel('Altimeter Maximum Range (meters)')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear altimeter_max_range_fail altimeter_max_range_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        altimeter_max_range_success(isuccess) = mc_all_initial(itest,16);
    else
        ifail = ifail + 1;
        altimeter_max_range_fail(ifail) = mc_all_initial(itest,16);
    end
end
if exist('altimeter_max_range_success')==1
    figure;hist(altimeter_max_range_success,10);grid on 
    title('Altimeter Maximum Range to Landing Success','fontsize',14)
    xlabel('Altimeter Maximum Range (meters)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistAltMaxRangeSucc.png')
end
if exist('altimeter_max_range_fail')==1
    figure;hist(altimeter_max_range_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Altimeter Maximum Range to Landing Failure','fontsize',14)
    xlabel('Altimeter Maximum Range (meters)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistAltMaxRangeFail.png')
end
%%
figure;plot(mc_all_initial(:,17)*3600,Success,'*');grid on
title('Landing Success Versus Star Tracker Noise')
xlabel('Star Tracker Noise (arc-sec)')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear star_tracker_noise_fail star_tracker_noise_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        star_tracker_noise_success(isuccess) = mc_all_initial(itest,17)*3600;
    else
        ifail = ifail + 1;
        star_tracker_noise_fail(ifail) = mc_all_initial(itest,17)*3600;
    end
end
if exist('star_tracker_noise_success')==1
    figure;hist(star_tracker_noise_success,20);grid on 
    title('Star Tracker Noise to Landing Success','fontsize',14)
    xlabel('Star Tracker Noise (arc-sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistTrkrNoiseSucc.png')
end
if exist('star_tracker_noise_fail')==1
    figure;hist(star_tracker_noise_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Star Tracker Noise to Landing Failure','fontsize',14)
    xlabel('Star Tracker Noise (arc-sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistTrkrNoiseFail.png')
end
%%
figure;plot(mc_all_initial(:,18),Success,'*');grid on
title('Landing Success Versus Camera Integration Time')
xlabel('Camera Integration Time (sec)')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear camera_integration_time_fail camera_integration_time_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        camera_integration_time_success(isuccess) = mc_all_initial(itest,18);
    else
        ifail = ifail + 1;
        camera_integration_time_fail(ifail) = mc_all_initial(itest,18);
    end
end
if exist('camera_integration_time_success')==1
    figure;hist(camera_integration_time_success,10);grid on 
    title('Camera Integration Time to Landing Success','fontsize',14)
    xlabel('Camera Integration Time (sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistCamDtSucc.png')
end
if exist('camera_integration_time_fail')==1
    figure;hist(camera_integration_time_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Camera Integration Time to Landing Failure','fontsize',14)
    xlabel('Camera Integration Time (sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistCamDtFail.png')
end
%%
figure;plot(mc_all_initial(:,19),Success,'*');grid on
title('Landing Success Versus Camera Focal Length')
xlabel('Camera Focal Length (m)')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear camera_focal_length_fail camera_focal_length_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        camera_focal_length_success(isuccess) = mc_all_initial(itest,19);
    else
        ifail = ifail + 1;
        camera_focal_length_fail(ifail) = mc_all_initial(itest,19);
    end
end
if exist('camera_focal_length_success')==1
    figure;hist(camera_focal_length_success,10);grid on 
    title('Camera Focal Length to Landing Success','fontsize',14)
    xlabel('Camera Focal Length (meters)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistFocalSucc.png')
end
if exist('camera_focal_length_fail')==1
    figure;hist(camera_focal_length_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Camera Focal Length to Landing Failure','fontsize',14)
    xlabel('Camera Focal Length (meters)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistFocalFail.png')
end
%%
figure;plot(mc_all_initial(:,20)*180/pi,Success,'*');grid on
title('Landing Success Versus Camera Angular Field of View')
xlabel('Camera Angular Field of View (deg)')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear camera_aov_fail camera_aov_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        camera_aov_success(isuccess) = mc_all_initial(itest,20)*180/pi;
    else
        ifail = ifail + 1;
        camera_aov_fail(ifail) = mc_all_initial(itest,20)*180/pi;
    end
end
if exist('camera_aov_success')==1
    figure;hist(camera_aov_success,10);grid on 
    title('Camera Angular Field of View to Landing Success','fontsize',14)
    xlabel('Camera Angular Field of View (deg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistCamAOVSucc.png')
end
if exist('camera_aov_fail')==1
    figure;hist(camera_aov_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Camera Angular Field of View to Landing Failure','fontsize',14)
    xlabel('Camera Angular Field of View (deg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistCamAOVFail.png')
end
%%
figure;plot(mc_all_initial(:,21),Success,'*');grid on
title('Landing Success Versus Image Delta-T')
xlabel('Camera Number of Image Delta-T (sec)')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear camera_delta_t_fail camera_delta_t_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        camera_delta_t_success(isuccess) = mc_all_initial(itest,21);
    else
        ifail = ifail + 1;
        camera_delta_t_fail(ifail) = mc_all_initial(itest,21);
    end
end
if exist('camera_delta_t_success')==1
    figure;hist(camera_delta_t_success,10);grid on 
    title('Camera Delta-T to Landing Success','fontsize',14)
    xlabel('Camera Delta-T (sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistProcDtSucc.png')
end
if exist('camera_delta_t_fail')==1
    figure;hist(camera_delta_t_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Camera Delta-T to Landing Failure','fontsize',14)
    xlabel('Camera Delta-T (sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistProcDtFail.png')
end
%%
figure;plot(mc_all_initial(:,22)*1e6,Success,'*');grid on
title('Landing Success Versus Camera Processing Delay')
xlabel('Camera Processing Delay (sec)')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear camera_processing_delay_fail camera_processing_delay_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        camera_processing_delay_success(isuccess) = mc_all_initial(itest,22);
    else
        ifail = ifail + 1;
        camera_processing_delay_fail(ifail) = mc_all_initial(itest,22);
    end
end
if exist('camera_processing_delay_success')==1
    figure;hist(camera_processing_delay_success,10);grid on 
    title('Camera Processing Delay to Landing Success','fontsize',14)
    xlabel('Camera Processing Delay (sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistCamProcDelaySucc.png')
end
if exist('camera_processing_delay_fail')==1
    figure;hist(camera_processing_delay_fail,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Camera Processing Delay to Landing Failure','fontsize',14)
    xlabel('Camera Processing Delay (sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistCamProcDelayFail.png')
end
%%
figure;plot(lateral_cg_dry_offset*1e3,Success,'*');grid on
title('Landing Success Versus Dry Lander CG Offset')
xlabel('Lateral Offset (millimeters)')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear lateral_cg_dry_offset_fail lateral_cg_dry_offset_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        lateral_cg_dry_offset_success(isuccess) = lateral_cg_dry_offset(itest);
    else
        ifail = ifail + 1;
        lateral_cg_dry_offset_fail(ifail) = lateral_cg_dry_offset(itest);
    end
end
if exist('lateral_cg_dry_offset_success')==1
    figure;hist(lateral_cg_dry_offset_success*1e3,10);grid on 
    title('Dry Lander CG Offset to Landing Success','fontsize',14)
    xlabel('Dry Lander CG Offset (mm)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistDryCGOffsetSucc.png');saveas(gcf,'HistDryCGOffsetSucc.fig')
end
if exist('lateral_cg_dry_offset_fail')==1
    figure;hist(lateral_cg_dry_offset_fail*1e3,10);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Dry Lander CG Offset to Landing Failure','fontsize',14)
    xlabel('Dry Lander CG Offset (mm)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistDryCGOffsetFail.png')
end
%%
% figure;plot(lateral_cg_wet_offset*1e3,Success,'*');grid on
% title('Landing Success Versus Wet Lander CG Offset')
% xlabel('Lateral Offset (millimeters)')
% ylabel('Success=1 Fail=0')
% axis([-1 +1 -1 +2]);axis('auto x')
% isuccess = 0;ifail = 0;clear lateral_cg_wet_offset_fail lateral_cg_wet_offset_success
% for itest =1:size(mc_all_initial,1)
%     if Success(itest) == 1
%         isuccess = isuccess + 1;
%         lateral_cg_wet_offset_success(isuccess) = lateral_cg_wet_offset(itest);
%     else
%         ifail = ifail + 1;
%         lateral_cg_wet_offset_fail(ifail) = lateral_cg_wet_offset(itest);
%     end
% end
% if exist('lateral_cg_wet_offset_success')==1
%     figure;hist(lateral_cg_wet_offset_success*1e3,10);grid on 
%     title('Wet Lander CG Offset to Landing Success','fontsize',14)
%     xlabel('Wet Lander CG Offset (mm)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistWetCGOffsetSucc.png');saveas(gcf,'HistWetCGOffsetSucc.fig')
% end
% if exist('lateral_cg_wet_offset_fail')==1
%     figure;hist(lateral_cg_wet_offset_fail*1e3,10);grid on
%     h = findobj(gca,'Type','patch');
%     set(h,'FaceColor','r')
%     title('Wet Lander CG Offset to Landing Failure','fontsize',14)
%     xlabel('Wet Lander CG Offset (mm)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistWetCGOffsetFail.png')
% end
%%
figure;plot(fluid_damping,Success,'*');grid on
title('Landing Success Versus Fluid Damping','fontsize',14)
xlabel('Fluid Damping','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'FluidDampingSuccFail.fig')
isuccess = 0;ifail = 0;clear fluid_damping_fail fluid_damping_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        fluid_damping_success(isuccess) = fluid_damping(itest);
    else
        ifail = ifail + 1;
        fluid_damping_fail(ifail) = fluid_damping(itest);
    end
end
if exist('fluid_damping_success')==1
    figure;hist(fluid_damping_success,20);grid on
    title('Fluid Damping to Landing Success','fontsize',14)
    xlabel('Fluid Damping','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistFluidDampingSucc.png');saveas(gcf,'HistFluidDampingSucc.fig')
end
if exist('fluid_damping_fail')==1
    figure;hist(fluid_damping_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Fluid Damping to Landing Failure','fontsize',14)
    xlabel('Fluid Damping','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistFluidDampingFail.png');saveas(gcf,'HistFluidDampingFail.fig')
end

%%
figure;plot(htp_mass,Success,'*');grid on
title('Landing Success Versus Initial HTP Mass','fontsize',14)
xlabel('Initial HTP Mass','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'HtpMassSuccFail.fig')
isuccess = 0;ifail = 0;clear htp_mass_fail htp_mass_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        htp_mass_success(isuccess) = htp_mass(itest);
    else
        ifail = ifail + 1;
        htp_mass_fail(ifail) = htp_mass(itest);
    end
end
if exist('htp_mass_success')==1
    figure;hist(htp_mass_success,20);grid on
    title('Initial HTP Mass to Landing Success','fontsize',14)
    xlabel('Initial HTP Mass','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistHtpMassSucc.png');saveas(gcf,'HistHtpMassSucc.fig')
end
if exist('htp_mass_fail')==1
    figure;hist(htp_mass_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Initial HTP Mass to Landing Failure','fontsize',14)
    xlabel('Initial HTP Mass','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistHtpMassFail.png');saveas(gcf,'HistHtpMassFail.fig')
end

%%
figure;plot(pendulum_length,Success,'*');grid on
title('Landing Success Versus Pendulum Max Length','fontsize',14)
xlabel('Pendulum Length / Tank Radius','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'PendLenSuccFail.fig')
isuccess = 0;ifail = 0;clear pendulum_length_fail pendulum_length_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        pendulum_length_success(isuccess) = pendulum_length(itest);
    else
        ifail = ifail + 1;
        pendulum_length_fail(ifail) = pendulum_length(itest);
    end
end
if exist('pendulum_length_success')==1
    figure;hist(pendulum_length_success,20);grid on
    title('Pendulum Max Length to Landing Success','fontsize',14)
    xlabel('Pendulum Length / Tank Radius','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistPendLenSucc.png');saveas(gcf,'HistPendLenSucc.fig')
end
if exist('pendulum_length_fail')==1
    figure;hist(pendulum_length_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Pendulum Max Length to Landing Failure','fontsize',14)
    xlabel('Pendulum Length / Tank Radius','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistPendLenFail.png');saveas(gcf,'HistPendLenFail.fig')
end

%%
figure;plot(pendulum_mass*100,Success,'*');grid on
title('Landing Success Versus Pendulum Peak Mass Fraction','fontsize',14)
xlabel('% Mass Fraction','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'PendMassSuccFail.fig')
isuccess = 0;ifail = 0;clear pendulum_mass_fail pendulum_mass_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        pendulum_mass_success(isuccess) = pendulum_mass(itest)*100;
    else
        ifail = ifail + 1;
        pendulum_mass_fail(ifail) = pendulum_mass(itest)*100;
    end
end
if exist('pendulum_mass_success')==1
    figure;hist(pendulum_mass_success,20);grid on
    title('Pendulum Peak Mass Fraction to Landing Success','fontsize',14)
    xlabel('% Mass Fraction','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistPendMassSucc.png');saveas(gcf,'HistPendMassSucc.fig')
end
if exist('pendulum_mass_fail')==1
    figure;hist(pendulum_mass_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Pendulum Peak Mass Fraction to Landing Failure','fontsize',14)
    xlabel('% Mass Fraction','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistPendMassFail.png');saveas(gcf,'HistPendMassFail.fig')
end

%%
figure;plot(hinge_height,Success,'*');grid on
title('Landing Success Versus Pendulum Max Hinge Height','fontsize',14)
xlabel('Hinge Height / Tank Diameter','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'HingeHeightSuccFail.fig')
isuccess = 0;ifail = 0;clear hinge_height_fail hinge_height_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        hinge_height_success(isuccess) = hinge_height(itest);
    else
        ifail = ifail + 1;
        hinge_height_fail(ifail) = hinge_height(itest);
    end
end
if exist('hinge_height_success')==1
    figure;hist(hinge_height_success,20);grid on
    title('Pendulum Max Hinge Height to Landing Success','fontsize',14)
    xlabel('Hinge Height / Tank Diameter','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistHingeHeightSucc.png');saveas(gcf,'HistHingeHeightSucc.fig')
end
if exist('hinge_height_fail')==1
    figure;hist(hinge_height_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title('Pendulum Max Hinge Height to Landing Failure','fontsize',14)
    xlabel('Hinge Height / Tank Diameter','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistHingeHeightFail.png');saveas(gcf,'HistHingeHeightFail.fig')
end

%%
figure;
for itest=1:size(mc_all_final,1) 
    if(mc_all_final(itest,39)==0)
        plot3(mc_all_initial(itest,2),mc_all_initial(itest,3),mc_all_initial(itest,4),'b*');hold on
    elseif(mc_all_final(itest,39)==1)
        plot3(mc_all_initial(itest,2),mc_all_initial(itest,3),mc_all_initial(itest,4),'r*');hold on
    end
end
    
title('Initial Position Estimation Error','fontsize',14)
xlabel('X Position Error (meters)','fontsize',14);
ylabel('Y Position Error (meters)','fontsize',14);
zlabel('Z Position Error (meters)','fontsize',14);
hold on; grid on;
saveas(gcf,'InitialPosEstError.png')
%%
figure;
for itest=1:size(mc_all_final,1)
    if(mc_all_final(itest,39)==0)
        plot3(mc_all_initial(itest,5),mc_all_initial(itest,6),mc_all_initial(itest,7),'b*');hold on 
    elseif(mc_all_final(itest,39)==1)
        plot3(mc_all_initial(itest,5),mc_all_initial(itest,6),mc_all_initial(itest,7),'r*');hold on
    end
end
title('Initial Velocity Estimation Error','fontsize',14)
xlabel('X Velocity Error (m/s)','fontsize',14);
ylabel('Y Velocity Error (m/s)','fontsize',14);
zlabel('Z Velocity Error (m/s)','fontsize',14);
hold on; grid on;
saveas(gcf,'InitialVelEstError.png')
%%
figure;
for ipos = 1:mc_n
    name_mc_pos=[ mc_prefix_s_pos num2str(ipos) ];
    if exist(strcat(name_mc_pos,'.mat'),'file')
        load( name_mc_pos );
    else
        warning(['no data for run' num2str(ipos)])
        continue
    end
    if exist('mc_traj_data','var')
     if(mc_all_final(ipos,39)==0)
            plot(mc_traj_data.sim_pos.Data(:,1),mc_traj_data.sim_pos.Data(:,2),'b-');hold on   
     else
            plot(mc_traj_data.sim_pos.Data(:,1),mc_traj_data.sim_pos.Data(:,2),'r-');hold on 
     end
    end
    hold on; grid on;
end
xlabel('Landing Site Relative Topocentric True X Position (meters)','fontsize',14);
ylabel('Landing Site Relative Topocentric True Y Position (meters)','fontsize',14);
title('Top View - Landing Site Relative Position in Topocentric Frame','fontsize',14);
saveas(gcf,'TruePosLateral.png');saveas(gcf,'TruePosLateral.fig')
%%
figure;
for ipos = 1:mc_n
    name_mc_pos=[ mc_prefix_s_pos num2str(ipos) ];
    if exist(strcat(name_mc_pos,'.mat'),'file')
        load( name_mc_pos );
    else
        warning(['no data for run' num2str(ipos)])
        continue
    end
    if exist('mc_traj_data','var')
       if(mc_all_final(ipos,39)==0)
            plot(mc_traj_data.sim_pos.Time,mc_traj_data.sim_pos.Data(:,1),'b-');hold on
       else
            plot(mc_traj_data.sim_pos.Time,mc_traj_data.sim_pos.Data(:,1),'r-');hold on
       end          
    end
    hold on; grid on;
end
xlabel('Time (sec)','fontsize',14);
ylabel('Landing Site Relative Topocentric True X Position (meters)','fontsize',14);
title('Landing Site Relative X-Position in Topocentric Frame','fontsize',14);
saveas(gcf,'TrueXPos.png');saveas(gcf,'TrueXPos.fig')
%%
figure;
for ipos = 1:mc_n
    name_mc_pos=[ mc_prefix_s_pos num2str(ipos) ];
    if exist(strcat(name_mc_pos,'.mat'),'file')
        load( name_mc_pos );
    else
        warning(['no data for run' num2str(ipos)])
        continue
    end
    if exist('mc_traj_data','var')
       if(mc_all_final(ipos,39)==0)
            plot(mc_traj_data.sim_pos.Time,mc_traj_data.sim_pos.Data(:,2),'b-');hold on
       else
            plot(mc_traj_data.sim_pos.Time,mc_traj_data.sim_pos.Data(:,2),'r-');hold on
       end           
    end
    hold on; grid on;
end
xlabel('Time (sec)','fontsize',14);
ylabel('Landing Site Relative Topocentric True Y Position (meters)','fontsize',14);
title('Landing Site Relative Y-Position in Topocentric Frame','fontsize',14);
saveas(gcf,'TrueYPos.png');saveas(gcf,'TrueYPos.fig')

%%
figure;
for ipos = 1:mc_n
    name_mc_pos=[ mc_prefix_s_pos num2str(ipos) ];
    if exist(strcat(name_mc_pos,'.mat'),'file')
        load( name_mc_pos );
    else
        warning(['no data for run' num2str(ipos)])
        continue
    end
    if exist('mc_traj_data','var')
       if(mc_all_final(ipos,39)==0)
            plot(mc_traj_data.sim_mass,'b-');hold on
       else
            plot(mc_traj_data.sim_mass,'r-');hold on
       end
    end
    hold on; grid on;
end
xlabel('Time (sec)','fontsize',14);
ylabel('Propellant Mass Used (kg)','fontsize',14);
title('Propellant Mass Used','fontsize',14);
saveas(gcf,'PropellantUsed.png');saveas(gcf,'PropellantUsed.fig')
%%
figure;
for ipos = 1:mc_n
    name_mc_pos=[ mc_prefix_s_pos num2str(ipos) ];
    if exist(strcat(name_mc_pos,'.mat'),'file')
        load( name_mc_pos );
    else
        continue
    end
    if exist('mc_traj_data','var')
       if(mc_all_final(ipos,39)==0)
            plot(mc_traj_data.sim_pos.Data(:,3), normrows(mc_traj_data.sim_vel.Data),'b-' );hold on
       else
            plot(mc_traj_data.sim_pos.Data(:,3), normrows(mc_traj_data.sim_vel.Data),'r-' );hold on
       end
    end
    hold on; grid on;
end
xlabel('Altitude (meters)','fontsize',14);
ylabel('Velocity Magnitude (m/s)','fontsize',14);
title('Velocity Magnitude vs. Altitude','fontsize',14);
saveas(gcf,'VelocityvsAltitude.png');saveas(gcf,'VelocityvsAltitude.fig')
%%
figure;
for ipos = 1:mc_n
    name_mc_pos=[ mc_prefix_s_pos num2str(ipos) ];
    if exist(strcat(name_mc_pos,'.mat'),'file')
        load( name_mc_pos );
    else
        continue
    end
    if exist('mc_traj_data','var')
      if(mc_all_final(ipos,39)==0)
            plot(normrows(mc_traj_data.sim_vel),'b-');hold on
      else
            plot(normrows(mc_traj_data.sim_vel),'r-');hold on
      end
    end
    hold on; grid on;
end
xlabel('Time (sec)','fontsize',14);
ylabel('Velocity Magnitude (m/s)','fontsize',14);
title('Velocity Magnitude vs. Time','fontsize',14);
saveas(gcf,'VelocityvsTime.png');saveas(gcf,'VelocityvsTime.fig')
%%
figure;
for ipos = 1:mc_n
    name_mc_pos=[ mc_prefix_s_pos num2str(ipos) ];
    if exist(strcat(name_mc_pos,'.mat'),'file')
        load( name_mc_pos );
    else
        continue
    end
    if exist('mc_traj_data','var')
      if(mc_all_final(ipos,39)==0)
            plot3(mc_traj_data.sim_pos.Data(:,1), mc_traj_data.sim_pos.Data(:,2), mc_traj_data.sim_pos.Data(:,3),'b-' );hold on
      else
            plot3(mc_traj_data.sim_pos.Data(:,1), mc_traj_data.sim_pos.Data(:,2), mc_traj_data.sim_pos.Data(:,3),'r-' );hold on
      end
    end
%    axis([-5000 5000 -5000 5000 0 10000])   
%     axis([-55 -25 -22 -8 0 15])   
    hold on; grid on;
end
xlabel({'Landing Site Relative Topocentric','True X Position (meters)'},'fontsize',14);
ylabel({'Landing Site Relative Topocentric','True Y Position (meters)'},'fontsize',14);
zlabel({'Landing Site Relative Topocentric','True Z Position (meters)'},'fontsize',14);
title('Landing Site Relative Position in Topocentric Frame','fontsize',14);
saveas(gcf,'TruePos3D.png');saveas(gcf,'TruePos3D.fig')
%%
figure;
for ipos = 1:mc_n
    name_mc_pos=[ mc_prefix_s_pos num2str(ipos) ];
    if exist(strcat(name_mc_pos,'.mat'),'file')
        load( name_mc_pos );
    else
        continue
    end
    if exist('mc_traj_data','var')
        iTopo = find( telem.cmp.est_ref_frame.Data == 2);
        est_topo_pos_only = getdatasamples(mc_traj_data.est_pos, iTopo);
        est_topoalt = getdatasamples(mc_traj_data.est_alt, iTopo);
        if(mc_all_final(ipos,39)==0)
            plot3(est_topo_pos_only(:,1), est_topo_pos_only(:,2), est_topoalt,'b-');hold on
        else
            plot3(est_topo_pos_only(:,1), est_topo_pos_only(:,2), est_topoalt,'r-');hold on
        end
        
        clear est_topo_pos_only
    end
    %axis([-30000 1000 -10000 10000 0 10000])   
    hold on; grid on;
end
xlabel({'Landing Site Relative Topocentric','Estimated X Position (meters)'},'fontsize',14);
ylabel({'Landing Site Relative Topocentric','Estimated Y Position (meters)'},'fontsize',14);
zlabel({'Landing Site Relative Topocentric','Estimated Z Position (meters)'},'fontsize',14);
title('Landing Site Relative Estimated Position in Topocentric Frame','fontsize',14);
saveas(gcf,'EstPos3D.png');saveas(gcf,'EstPos3D.fig')
%%



%         median_gnc_pos(kk,pp,:) = median(abs(mc_all_final(indices{kk}(by2index{pp}),ifi.gnc_pos_err)),1);
%         std_gnc_pos(kk,pp,:) = std(mc_all_final(indices{kk}(by2index{pp}),ifi.gnc_pos_err),1);
%         
%         median_gnc_vel(kk,pp,:) = median(abs(mc_all_final(indices{kk}(by2index{pp}),ifi.gnc_vel_err)),1);
%         std_gnc_vel(kk,pp,:) = std(mc_all_final(indices{kk}(by2index{pp}),ifi.gnc_vel_err),1);
%         
%         median_est_pos(kk,pp,:) = median(abs(mc_all_final(indices{kk}(by2index{pp}),ifi.est_pos_err)),1);
%         std_est_pos(kk,pp,:) = std(mc_all_final(indices{kk}(by2index{pp}),ifi.est_pos_err),1);
%         
%         median_est_vel(kk,pp,:) = median(mc_all_final(indices{kk}(by2index{pp}),ifi.est_vel_err),1);
%         std_est_vel(kk,pp,:) = std(mc_all_final(indices{kk}(by2index{pp}),ifi.est_vel_err),1);
%         
%         median_fuel_used(kk,pp,:) = median(mc_all_initial(indices{kk}(by2index{pp}),iin.mass) - mc_all_final(indices{kk}(by2index{pp}),ifi.mass),1);
%         std_fuel_used(kk,pp,:) = std(mc_all_initial(indices{kk}(by2index{pp}),iin.mass) - mc_all_final(indices{kk}(by2index{pp}),ifi.mass),1);
%          
%         n_failure(kk,pp,:) = sum(mc_all_final(indices{kk}(by2index{pp}),ifi.fail),1);
%         n_failure_strict(kk,pp,:) = sum(mc_all_final(indices{kk}(by2index{pp}),ifi.fail_strict),1);
%             
%     median_gnc_pos_all_max(kk,:) = median(abs(mc_all_final(indices{kk},ifi.gnc_pos_err)),1);
%     std_gnc_pos_all_max(kk,:) = std(mc_all_final(indices{kk},ifi.gnc_pos_err),1);
%     
%     median_gnc_vel_all_max(kk,:) = median(mc_all_final(indices{kk},ifi.gnc_vel_err),1);
%     std_gnc_vel_all_max(kk,:) = std(mc_all_final(indices{kk},ifi.gnc_vel_err),1);
%     
%     median_est_pos_all_max(kk,:) = median(mc_all_final(indices{kk},ifi.est_pos_err),1);
%     std_est_pos_all_max(kk,:) = std(mc_all_final(indices{kk},ifi.est_pos_err),1);
%     
%     median_est_vel_all_max(kk,:) = median(mc_all_final(indices{kk},ifi.est_vel_err),1);
%     std_est_vel_all_max(kk,:) = std(mc_all_final(indices{kk},ifi.est_vel_err),1);
%     
%     median_fuel_used_all_max(kk,:) = median(mc_all_initial(indices{kk},iin.mass) - mc_all_final(indices{kk},ifi.mass),1);
%     std_fuel_used_all_max(kk,:) = std(mc_all_initial(indices{kk},iin.mass) - mc_all_final(indices{kk},ifi.mass),1);
   
% figure; plot(percent_errors*100, median_gnc_pos_all_max(1:end,1:2),'o--'); grid on; hold on;
% plot(percent_errors*100, median_est_pos_all_max(1:end,3),'ro--'); grid on; hold on;
% title('Final Position Error: median over 300 cases')
% xlabel('Altimeter Percent of Range Error')
% ylabel('Final Position Error (meters)')
% legend('Crossrange','Downrange','Altitude')
% 
% figure; plot(percent_errors*100, median_gnc_pos_all_max(1:end,1:2),'o--'); grid on; hold on;
% plot(percent_errors*100, median_est_vel_all_max(1:end,3),'ro--'); grid on; hold on;
% title('Final Velocity Error: median over 300 cases')
% xlabel('Altimeter Percent of Range Error')
% ylabel('Final Velocity Error (m/s)')
% legend('Crossrange','Downrange','Vertical')
% 
% figure; plot(percent_errors*100, median_gnc_pos_all_max(1:end,1:2)+3*std_gnc_pos_all_max(1:end,1:2),'o--'); grid on; 
% hold on; plot(percent_errors*100, median_est_pos_all_max(1:end,3)+3*std_est_pos_all_max(1:end,3),'ro--'); grid on; 
% title('Final Position Error: median+3std over 300 cases')
% xlabel('Altimeter Percent of Range Error')
% ylabel('Final Position Error (meters)')
% legend('Crossrange','Downrange','Altitude')
% 
% figure; plot(percent_errors*100, median_gnc_vel_all_max(1:end,1:2)+3*std_gnc_vel_all_max(1:end,1:2),'o--'); grid on; 
% hold on; plot(percent_errors*100, median_est_vel_all_max(1:end,3)+3*std_est_vel_all_max(1:end,3),'ro--'); grid on; 
% title('Final Velocity Error: median+3std over 300 cases')
% xlabel('Altimeter Percent of Range Error')
% ylabel('Final Velocity Error (m/s)')
% legend('Crossrange','Downrange','Vertical')
% 
% median_pos = sqrt(median_gnc_pos(:,:,1).^2 +median_gnc_pos(:,:,2).^2);
% std_pos = sqrt(std_gnc_pos(:,:,1).^2 +std_gnc_pos(:,:,2).^2);

% figure; contourf(max_ranges/1000,percent_errors*100, lateral_pos')
% xlabel('Maximum range return (km)')
% ylabel('Altimeter percent of range error (%)')
% title('GNC lateral landing position error (meters)')
% colorbar
% set(gcf,'Renderer','painters');
% print(gcf,'-depsc','gnc_pos_contour_2');
% 
% % median_vel = sqrt(median_gnc_vel(:,:,1).^2 +median_gnc_vel(:,:,2).^2);
% % std_vel = sqrt(std_gnc_vel(:,:,1).^2 +std_gnc_vel(:,:,2).^2);
% 
% figure; contourf(max_ranges/1000,percent_errors'*100, lateral_vel)
% xlabel('Maximum range return (km)')
% ylabel('Altimeter percent of range error (%)')
% title('GNC lateral landing velocity in m/s')
% colorbar
% set(gcf,'Renderer','painters');
% print(gcf,'-depsc','gnc_vel_contour_2');
% 
% figure; contourf(max_ranges/1000,percent_errors'*100, vertical_pos)
% xlabel('Maximum range return (km)')
% ylabel('Altimeter percent of range error (%)')
% title('Estimated Altitude Error at Landing ')
% colorbar
% set(gcf,'Renderer','painters');
% print(gcf,'-depsc','gnc_alt_contour_2');
% 
% figure; contourf(max_ranges/1000,percent_errors'*100, vertical_vel)
% xlabel('Maximum range return (km)')
% ylabel('Altimeter percent of range error (%)')
% title('Vertical Velocity at 1 m : median')
% colorbar
% set(gcf,'Renderer','painters');
% print(gcf,'-depsc','gnc_vert_vel_contour_2');
% 
% figure; contourf(max_ranges/1000,percent_errors'*100,total_fuel_used)
% xlabel('Maximum range return (km)')
% ylabel('Altimeter percent of range error (%)')
% title('Fuel Consumed at 1 m : median')
% colorbar

% set(gcf,'Renderer','painters');
% print(gcf,'-depsc','gnc_fuel_contour_2');

% figure; contourf(max_ranges/1000,percent_errors'*100, n_failure_strict,10)
% xlabel('Maximum range return (km)')
% ylabel('Altimeter percent of range error (%)')
% title('Number of Failed Runs (10 max)')
% colorbar
% set(gcf,'Renderer','painters');
% print(gcf,'-depsc','gnc_fail_contour_2');
% if (horz_pos > 1500) |(horz_vel > 2) | (horz_vel_est_err > 2) | (alt_knowledge > 8) | (vert_vel > 4) | (vert_vel_est_err > 4) | (final_gnc_ang_err > 15) | (body_rates > 10) | (final_mass < dry_mass)  
%     disp('Degenerative Case.  One or more of the following conditions violated:')
% else
%     disp('All Landing Conditions Within Limits')
% end
% disp('(horz_pos > 1500) |(horz_vel > 2) | (horz_vel_est_err > 2) | (alt_knowledge > 8) | (vert_vel > 4) | (vert_vel_est_err > 4) | (final_gnc_ang_err > 15) | (body_rates > 10) | (final_mass < dry_mass)')
% str = sprintf(['horz_pos = ',num2str(horz_pos)]);disp(str)
% str = sprintf(['horz_vel = ',num2str(horz_vel)]);disp(str)
% str = sprintf(['horz_vel_est_err = ',num2str(horz_vel_est_err)]);disp(str)
% str = sprintf(['alt_knowledge = ',num2str(alt_knowledge)]);disp(str)
% str = sprintf(['vert_vel = ',num2str(vert_vel)]);disp(str)
% str = sprintf(['vert_vel_est_err = ',num2str(vert_vel_est_err)]);disp(str)
% str = sprintf(['final_gnc_ang_err = ',num2str(final_gnc_ang_err)]);disp(str)
% str = sprintf(['body_rates = ',num2str(body_rates)]);disp(str)
% str = sprintf(['final_mass = ',num2str(final_mass)]);disp(str)
% 
% str = sprintf(['Altimeter Noise (percent) = ',num2str(ldr_2k_percent_error*100)]);disp(str)
% str = sprintf(['Altimeter Maximum Range (m) = ',num2str(ldr_2k_range_max)]);disp(str)
% str = sprintf(['Camera Focal Length (m) = ',num2str(cam_focal_length_f)]);disp(str)
% str = sprintf(['Camera Angular Field of View (deg) = ',num2str(cam_aov*180/pi)]);disp(str)
% str = sprintf(['Camera Image Delta-T (sec) = ',num2str(cam_image_delta_t)]);disp(str)
% str = sprintf(['Camera Processing Delay (sec) = ',num2str(cam_processing_delay)]);disp(str)
% str = sprintf(['Camera Integration Time(sec) = ',num2str(cam_integ_time)]);disp(str)
% 
% 
% 
