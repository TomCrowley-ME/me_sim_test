load MC_WORKSPACE
load mtv_acceptance_mcall.mat
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
   total_fuel_used_scalar(iter)  = mc_all_initial(iter,14) - mc_all_final(iter,14);
end
mean_fuel_used = mean(total_fuel_used_scalar);
half_sigma_fuel_dispersion = 0.5*std(total_fuel_used_scalar);
if half_sigma_fuel_dispersion < 5 
    half_sigma_fuel_dispersion = 5;
end

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
   final_est_pos_err(iter)       = norm(mc_all_final(iter,2:3));
   final_est_vel_err(iter)       = norm(mc_all_final(iter,5:7));
   final_est_ang_err(iter)       = norm(mc_all_final(iter,8:10));
   final_est_rate_err(iter)      = norm(mc_all_final(iter,11:13));
   final_gnc_vel_err(iter)       = norm(mc_all_final(iter,18:20));
   final_gnc_ang_err(iter)       = norm(mc_all_final(iter,21:22),2);
   final_gnc_rate_err(iter)      = norm(mc_all_final(iter,24:26));
   lateral_cg_dry_offset(iter)   = norm(mc_all_initial(iter,23:24));
   lateral_cg_wet_offset(iter)   = norm(mc_all_final(iter,40:41));
   cm_x_unit(iter) = mc_all_initial(iter,26)/norm([mc_all_initial(iter,26),mc_all_initial(iter,27)]);
   cm_y_unit(iter) = mc_all_initial(iter,27)/norm([mc_all_initial(iter,26),mc_all_initial(iter,27)]);
   cm_az_deg(iter) = atan2(cm_y_unit(iter),cm_x_unit(iter))*180/pi;
  
   if mc_all_final(iter,39)==0 %&& total_fuel_used_scalar(iter) > mean_fuel_used - half_sigma_fuel_dispersion
       Success(iter) = 1;
       nsuccess = nsuccess + 1;
   else
       Success(iter) = 0;
       nfail = nfail + 1;
       mc_all_final(iter,39) = 1;
   end
end

fprintf(sprintf('Number of Successful Landings: %d\n',nsuccess))
fprintf(sprintf('Number of Failed Landings: %d\n',nfail))

lateral_gnc_pos_scalar_limit  = 3.0;
lateral_gnc_vel_scalar_limit  = 0.75;
lateral_est_vel_scalar_limit  = 1.0;
final_est_vert_pos_err_limit  = 0.2;
final_gnc_vert_vel_err_limit  = 2.0;
vertical_est_vel_scalar_limit = 2.0;
final_gnc_ang_err_limit       = 25.0;
final_gnc_rate_err_limit      = 45.0;

lateral_gnc_pos_scalar_limit_cases  = int2str( find(lateral_gnc_pos_scalar   > lateral_gnc_pos_scalar_limit  ));
lateral_gnc_vel_scalar_limit_cases  = int2str( find(lateral_gnc_vel_scalar   > lateral_gnc_vel_scalar_limit  ));
lateral_est_vel_scalar_limit_cases  = int2str( find(lateral_est_vel_scalar   > lateral_est_vel_scalar_limit  ));
final_est_vert_pos_err_limit_cases  = int2str( find(final_est_vert_pos_err   > final_est_vert_pos_err_limit  ));
final_gnc_vert_vel_err_limit_cases  = int2str( find(vertical_gnc_vel_scalar  > final_gnc_vert_vel_err_limit  ));
vertical_est_vel_scalar_limit_cases = int2str( find(vertical_est_vel_scalar  > vertical_est_vel_scalar_limit ));
final_gnc_ang_err_limit_cases       = int2str( find(final_gnc_ang_err        > final_gnc_ang_err_limit       ));
final_gnc_rate_err_limit_cases      = int2str( find(final_gnc_rate_err       > final_gnc_rate_err_limit      ));
htp_depletion_cases                 = int2str( find(mc_all_final(:,43)'     >= mc_all_initial(:,86)'         ));

if (nfail>0)
   fprintf('Cases failed due to:\n')
   fprintf('Horizontal position                 = %3d   ',length(find(lateral_gnc_pos_scalar      >  lateral_gnc_pos_scalar_limit  )) )
   if size(lateral_gnc_pos_scalar_limit_cases,2)>0,fprintf('case numbers = %s\n',lateral_gnc_pos_scalar_limit_cases(:))  ,else fprintf('\n'),end
   fprintf('Horizontal velocity                 = %3d   ',length(find(lateral_gnc_vel_scalar      > lateral_gnc_vel_scalar_limit  )) )
   if size(lateral_gnc_vel_scalar_limit_cases,2)>0,fprintf('case numbers = %s\n',lateral_gnc_vel_scalar_limit_cases)     ,else fprintf('\n'),end
   fprintf('Horizontal velocity estimate error  = %3d   ',length(find(lateral_est_vel_scalar      > lateral_est_vel_scalar_limit  )) )
   if size(lateral_est_vel_scalar_limit_cases,2)>0,fprintf('case numbers = %s\n',lateral_est_vel_scalar_limit_cases(:))  ,else fprintf('\n'),end
   fprintf('Altitude estimate error             = %3d   ',length(find(final_est_vert_pos_err      > final_est_vert_pos_err_limit  )) )
   if size(final_est_vert_pos_err_limit_cases,2)>0,fprintf('case numbers = %s\n',final_est_vert_pos_err_limit_cases(:))  ,else fprintf('\n'),end
   fprintf('Vertical velocity                   = %3d   ',length(find(vertical_gnc_vel_scalar     > final_gnc_vert_vel_err_limit  )) )
   if size(final_gnc_vert_vel_err_limit_cases,2)>0,fprintf('case numbers = %s\n',final_gnc_vert_vel_err_limit_cases(:))  ,else fprintf('\n'),end
   fprintf('Vertical velocity estimate error    = %3d   ',length(find(vertical_est_vel_scalar     > vertical_est_vel_scalar_limit  )) )
   if size(vertical_est_vel_scalar_limit_cases,2)>0,fprintf('case numbers = %s\n',vertical_est_vel_scalar_limit_cases(:)),else fprintf('\n'),end
   fprintf('Touchdown angle from vertical       = %3d   ',length(find(final_gnc_ang_err           > final_gnc_ang_err_limit )) )
   if size(final_gnc_ang_err_limit_cases,2)>0      ,fprintf('case numbers = %s\n',final_gnc_ang_err_limit_cases(:))      ,else fprintf('\n'),end
   fprintf('Touchdown body rates                = %3d   ',length(find(final_gnc_rate_err          > final_gnc_rate_err_limit )) )
   if size(final_gnc_rate_err_limit_cases,2)>0     ,fprintf('case numbers = %s\n',final_gnc_rate_err_limit_cases(:))     ,else fprintf('\n'),end
   fprintf('HTP depletion                       = %3d   ',length(find(mc_all_final(:,43)         >= mc_all_initial(:,86))) )
   if size(htp_depletion_cases,2)>0                ,fprintf('case numbers = %s\n',htp_depletion_cases(:))                ,else fprintf('\n'),end
end


%%
figure;plot(mc_all_final(:,1),Success,'*');grid on
title_string = 'Criteria (horz_\pos > 3) |(horz_vel > 0.75) | (horz\_vel\_est\_err > 1.0) | (alt\_knowledge > 0.2) | (vert\_vel > 2.0) | (vert\_vel\_est\_err > 2.0) | (final\_gnc\_ang\_err > 25) | (body\_rates > 45) | (htp\_mass\_mass >= htp\_mass\_initial)';
title_string = 'Pass / Fail';
title(title_string);set(gcf,'Name',title_string)
xlabel('Case Number')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
%%
figure;plot(final_gnc_ang_err,Success,'*');grid on
title_string = 'Landing Success vs Touchdown Off Vertical Angle Error';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(final_gnc_ang_err_success,20);grid on
    title_string = 'Final GNC Angle Error to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Final GNC Angle Error (deg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistAngErrSucc.png');%saveas(gcf,'HistAngErrSucc.fig')
end
if exist('final_gnc_ang_err_fail')==1
    figure;hist(final_gnc_ang_err_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Final GNC Angle Error to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Final GNC Angle Error (deg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistAngErrFail.png');%saveas(gcf,'HistAngErrFail.fig')
end
%%
figure;plot(final_gnc_rate_err,Success,'*');grid on
title_string = 'Landing Success vs Touchdown Body Rate Error';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(final_gnc_rate_err_success,20);grid on
    title_string = 'Final GNC Rate Error to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Final GNC Rate Error (deg/sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistRateErrSucc.png');%saveas(gcf,'HistRateErrSucc.fig')
end
if exist('final_gnc_rate_err_fail')==1
    figure;hist(final_gnc_rate_err_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Final GNC Rate Error to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Final GNC Rate Error (deg/sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistRateErrFail.png');%saveas(gcf,'HistRateErrFail.fig')
end
%%
figure;plot(final_gnc_vel_err,Success,'*');grid on
title_string = 'Landing Success vs Touchdown Velocity Error';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(final_gnc_vel_err_success,20);grid on
    title_string = 'Final GNC Velocity Error to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Final GNC Velocity Error (m/sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistVelErrSucc.png');%saveas(gcf,'HistVelErrSucc.fig')
end
if exist('final_gnc_vel_err_fail')==1
    figure;hist(final_gnc_vel_err_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Final GNC Velocity Error to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Final GNC Velocity Error (m/sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistVelErrFail.png');%saveas(gcf,'HistVelErrFail.fig')
end
%%
figure;plot(final_est_vert_pos_err,Success,'*');grid on
title_string = 'Landing Success vs Touchdown Estimated Vertical Position Error';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(final_est_vert_pos_err_success,20);grid on
    title_string = 'Final Estimated Vertical Position Error to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Final Estimated Vertical Position Error (meters)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistEstVertPosErrSucc.png');%saveas(gcf,'HistEstVertPosErrSucc.fig')
end
if exist('final_est_vert_pos_err_fail')==1
    figure;hist(final_est_vert_pos_err_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Final Estimated Vertical Position Error to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Final Estimated Vertical Position Error (meters)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistEstVertPosErrFail.png');%saveas(gcf,'HistEstVertPosErrFail.fig')
end
%%
figure;plot(final_est_vel_err,Success,'*');grid on
title_string = 'Landing Success vs Touchdown Estimated Velocity Error';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(final_est_vel_err_success,20);grid on
    title_string = 'Final Estimated Velocity Error to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Final Estimated Velocity Error (m/sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistEstVelErrSucc.png');%saveas(gcf,'HistEstVelErrSucc.fig')
end
if exist('final_est_vel_err_fail')==1
    figure;hist(final_est_vel_err_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Final Estimated Velocity Error to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Final Estimated Velocity Error (m/sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistEstVelErrFail.png');%saveas(gcf,'HistEstVelErrFail.fig')
end
%%
figure;plot(lateral_gnc_vel_scalar,Success,'*');grid on
title_string = 'Landing Success vs Touchdown Guidance and Control Lateral Velocity Error';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(lateral_gnc_vel_scalar_success,20);grid on 
    title_string = 'Touchdown Guidance and Control Lateral Velocity Error to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Guidance and Control Lateral Velocity Error (m/s)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistLatVelCtrlErrSucc.png');%saveas(gcf,'HistLatVelCtrlErrSucc.fig')
end
if exist('lateral_gnc_vel_scalar_fail')==1
    figure;hist(lateral_gnc_vel_scalar_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Touchdown Guidance and Control Lateral Velocity Error to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Guidance and Control Lateral Velocity Error (m/s)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistLatVelCtrlErrFail.png');%saveas(gcf,'HistLatVelCtrlErrFail.fig')
end
%%
figure;plot(vertical_gnc_vel_scalar,Success,'*');grid on
title_string = 'Landing Success vs Touchdown Guidance and Control Vertical Velocity Accuracy';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(vertical_gnc_vel_scalar_success,20);grid on
    title_string = 'Touchdown Guidance and Control Vertical Velocity Accuracy to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Guidance and Control Vertical Velocity Accuracy (1 m/s Target)','fontsize',14)
    ylabel('Number of Cases')
    saveas(gcf,'HistVertVelCtrlErrSucc.png');%saveas(gcf,'HistVertVelCtrlErrSucc.fig')
end
if exist('vertical_gnc_vel_scalar_fail')==1
    figure;hist(vertical_gnc_vel_scalar_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Touchdown Guidance and Control Vertical Velocity Error to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Guidance and Control Vertical Velocity Accuracy (1 m/s Target)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistVertVelCtrlErrFail.png');%saveas(gcf,'HistVertVelCtrlErrFail.fig')
end
%%
figure;plot(vertical_gnc_pos_scalar,Success,'*');grid on
title_string = 'Landing Success vs Touchdown Guidance and Control Vertical Position Error';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(vertical_gnc_pos_scalar_success,20);grid on
    title_string = 'Touchdown Guidance and Control Vertical Position Error to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Guidance and Control Vertical Position Error (meters)','fontsize',14)
    ylabel('Number of Cases')
    saveas(gcf,'HistVertPosCtrlErrSucc.png');%saveas(gcf,'HistVertPosCtrlErrSucc.fig')
end
if exist('vertical_gnc_pos_scalar_fail')==1
    figure;hist(vertical_gnc_pos_scalar_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Touchdown Guidance and Control Vertical Position Error to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Guidance and Control Vertical Position Error (meters)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistVertPosCtrlErrFail.png');%saveas(gcf,'HistVertPosCtrlErrFail.fig')
end
%%
figure;plot(lateral_gnc_pos_scalar,Success,'*');grid on
title_string = 'Landing Success vs Touchdown Guidance and Control Horizontal Position Error';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(lateral_gnc_pos_scalar_success,20);grid on
    title_string = 'Touchdown Guidance and Control Horizontal Position Error to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Guidance and Control Horizontal Position Error (meters)','fontsize',14)
    ylabel('Number of Cases')
    saveas(gcf,'HistHorzPosCtrlErrSucc.png');%saveas(gcf,'HistHorzPosCtrlErrSucc.fig')
end
if exist('lateral_gnc_pos_scalar_fail')==1
    figure;hist(lateral_gnc_pos_scalar_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Touchdown Guidance and Control Horizontal Position Error to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Guidance and Control Horizontal Position Error (meters)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistHorzPosCtrlErrFail.png');%saveas(gcf,'HistHorzPosCtrlErrFail.fig')
end
%%
figure;plot(lateral_est_vel_scalar,Success,'*');grid on
title_string = 'Landing Success vs Touchdown Estimated Lateral Velocity Error';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(lateral_est_vel_scalar_success,20);grid on 
    title_string = 'Touchdown Estimated Lateral Velocity Error to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Estimated Lateral Velocity Error (m/s)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistLatVelEstErrSucc.png');%saveas(gcf,'HistLatVelEstErrSucc.fig')
end
if exist('lateral_est_vel_scalar_fail')==1
    figure;hist(lateral_est_vel_scalar_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Touchdown Estimated Lateral Velocity Error to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Estimated Lateral Velocity Error (m/s)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistLatVelEstErrFail.png');%saveas(gcf,'HistLatVelEstErrFail.fig')
end
%%
figure;plot(vertical_est_vel_scalar,Success,'*');grid on
title_string = 'Landing Success vs Touchdown Estimated Vertical Velocity Error';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(vertical_est_vel_scalar_success,20);grid on 
    title_string = 'Touchdown Estimated Vertical Velocity Error to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Estimated Vertical Velocity Error (m/s)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistVertVelEstErrSucc.png');%saveas(gcf,'HistVertVelEstErrSucc.fig')
end
if exist('vertical_est_vel_scalar_fail')==1
    figure;hist(vertical_est_vel_scalar_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Touchdown Estimated Vertical Velocity Error to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Estimated Vertical Velocity Error (m/s)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistVertVelEstErrFail.png');%saveas(gcf,'HistVertVelEstErrFail.fig')
end
%%
figure;plot(total_fuel_used_scalar,Success,'*');grid on
title_string = 'Landing Success vs Fuel Used at Touchdown';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(total_fuel_used_scalar_success,20);grid on 
    title_string = 'Total Fuel Usage to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Total Fuel Usage (kg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistFuelUsageSucc.png');%saveas(gcf,'HistFuelUsageSucc.fig')
end
if exist('total_fuel_used_scalar_fail')==1
    figure;hist(total_fuel_used_scalar_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Total Fuel Usage to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Total Fuel Usage (kg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistFuelUsageFail.png');%saveas(gcf,'HistFuelUsageFail.fig')
end
%%
% figure;plot(initial_est_pos_err,Success,'*');grid on
% title_string = 'Landing Success vs Initial Estimated Position Error';
% title(title_string);set(gcf,'Name',title_string)
% xlabel('Initial Estimated Total Position Error')
% ylabel('Success=1 Fail=0')
% axis([-1 +1 -1 +2]);axis('auto x')
% isuccess = 0;ifail = 0;clear initial_est_pos_err_fail initial_est_pos_err_success
% for itest =1:size(initial_est_pos_err,2)
%     if Success(itest) == 1
%         isuccess = isuccess + 1;
%         initial_est_pos_err_success(isuccess) = initial_est_pos_err(itest);
%     else
%         ifail = ifail + 1;
%         initial_est_pos_err_fail(ifail) = initial_est_pos_err(itest);
%     end
% end
% if exist('initial_est_pos_err_success')==1
%     figure;hist(initial_est_pos_err_success,20);grid on
%     title_string = 'Initial Estimated Position Error to Landing Success';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Initial Estimated Position Error (meters)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistInitEstPosErrSucc.png');%saveas(gcf,'HistInitEstPosErrSucc.fig')
% end
% if exist('initial_est_pos_err_fail')==1
%     figure;hist(initial_est_pos_err_fail,20);grid on
%     h = findobj(gca,'Type','patch');
%     set(h,'FaceColor','r')
%     title_string = 'Initial Estimated Position Error to Landing Failure';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Initial Estimated Position Error (meters)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistInitEstPosErrFail.png');%saveas(gcf,'HistInitEstPosErrFail.fig')
% end
%%
% figure;plot(initial_est_vel_err,Success,'*');grid on
% title_string = 'Landing Success vs Initial Estimated Velocity Error';
% title(title_string);set(gcf,'Name',title_string)
% xlabel('Initial Estimated Total Velocity Error')
% ylabel('Success=1 Fail=0')
% axis([-1 +1 -1 +2]);axis('auto x')
% isuccess = 0;ifail = 0;clear initial_est_vel_err_fail initial_est_vel_err_success
% for itest =1:size(initial_est_vel_err,2)
%     if Success(itest) == 1
%         isuccess = isuccess + 1;
%         initial_est_vel_err_success(isuccess) = initial_est_vel_err(itest);
%     else
%         ifail = ifail + 1;
%         initial_est_vel_err_fail(ifail) = initial_est_vel_err(itest);
%     end
% end
% if exist('initial_est_vel_err_success')==1
%     figure;hist(initial_est_vel_err_success,20);grid on
%     title_string = 'Initial Estimated Velocity Error to Landing Success';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Initial Estimated Velocity Error (m/s)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistInitEstVelErrSucc.png');%saveas(gcf,'HistInitEstVelErrSucc.fig')
% end
% if exist('initial_est_vel_err_fail')==1
%     figure;hist(initial_est_vel_err_fail,20);grid on
%     h = findobj(gca,'Type','patch');
%     set(h,'FaceColor','r')
%     title_string = 'Initial Estimated Velocity Error to Landing Failure';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Initial Estimated Velocity Error (m/s)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistInitEstVelFail.png');%saveas(gcf,'HistInitEstVelFail.fig')
% end
%%
figure;plot(initial_est_ang_err,Success,'*');grid on
title_string = 'Landing Success vs Initial Estimated Attitude Error';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(initial_est_ang_err_success,20);grid on 
    title_string = 'Initial Estimated Attitude Error to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Initial Estimated Attitude Error (deg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistInitEstAttErrSucc.png');%saveas(gcf,'HistInitEstAttErrSucc.fig')
end
if exist('initial_est_ang_err_fail')==1
    figure;hist(initial_est_ang_err_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Initial Estimated Attitude Error to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Initial Estimated Attitude Error (deg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistInitEstAttErrFail.png');%saveas(gcf,'HistInitEstAttErrFail.fig')
end
%%
% figure;plot(mc_all_initial(:,15)*100,Success,'*');grid on
% title_string = 'Landing Success vs Altimeter Percent Error';
% title(title_string);set(gcf,'Name',title_string)
% xlabel('Altimeter Percent Error (%)')
% ylabel('Success=1 Fail=0')
% axis([-1 +1 -1 +2]);axis('auto x')
% isuccess = 0;ifail = 0;clear altimeter_percent_err_fail altimeter_percent_err_success
% for itest =1:size(mc_all_initial,1)
%     if Success(itest) == 1
%         isuccess = isuccess + 1;
%         altimeter_percent_err_success(isuccess) = mc_all_initial(itest,15)*100;
%     else
%         ifail = ifail + 1;
%         altimeter_percent_err_fail(ifail) = mc_all_initial(itest,15)*100;
%     end
% end
% if exist('altimeter_percent_err_success')==1
%     figure;hist(altimeter_percent_err_success,20);grid on 
%     title_string = 'Altimeter Percent Error to Landing Success';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Altimeter Percent Error (%)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistAltErrorSucc.png');%saveas(gcf,'HistAltErrorSucc.fig');
% end
% if exist('altimeter_percent_err_fail')==1
%     figure;hist(altimeter_percent_err_fail,20);grid on
%     h = findobj(gca,'Type','patch');
%     set(h,'FaceColor','r')
%     title_string = 'Altimeter Percent Error to Landing Failure';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Altimeter Percent Error (%)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistAltErrorFail.png');%saveas(gcf,'HistAltErrorFail.fig')
% end
%%
% figure;plot(mc_all_initial(:,16),Success,'*');grid on
% title_string = 'Landing Success vs Altimeter Maximum Range';
% title(title_string);set(gcf,'Name',title_string)
% xlabel('Altimeter Maximum Range (meters)')
% ylabel('Success=1 Fail=0')
% axis([-1 +1 -1 +2]);axis('auto x')
% isuccess = 0;ifail = 0;clear altimeter_max_range_fail altimeter_max_range_success
% for itest =1:size(mc_all_initial,1)
%     if Success(itest) == 1
%         isuccess = isuccess + 1;
%         altimeter_max_range_success(isuccess) = mc_all_initial(itest,16);
%     else
%         ifail = ifail + 1;
%         altimeter_max_range_fail(ifail) = mc_all_initial(itest,16);
%     end
% end
% if exist('altimeter_max_range_success')==1
%     figure;hist(altimeter_max_range_success,20);grid on 
%     title_string = 'Altimeter Maximum Range to Landing Success';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Altimeter Maximum Range (meters)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistAltMaxRangeSucc.png');%saveas(gcf,'HistAltMaxRangeSucc.fig')
% end
% if exist('altimeter_max_range_fail')==1
%     figure;hist(altimeter_max_range_fail,20);grid on
%     h = findobj(gca,'Type','patch');
%     set(h,'FaceColor','r')
%     title_string = 'Altimeter Maximum Range to Landing Failure';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Altimeter Maximum Range (meters)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistAltMaxRangeFail.png');%saveas(gcf,'HistAltMaxRangeFail.fig')
% end
%%
% figure;plot(mc_all_initial(:,17)*3600,Success,'*');grid on
% title_string = 'Landing Success vs Star Tracker Noise';
% title(title_string);set(gcf,'Name',title_string)
% xlabel('Star Tracker Noise (arc-sec)')
% ylabel('Success=1 Fail=0') 
% axis([-1 +1 -1 +2]); axis('auto x') 
% isuccess = 0;ifail = 0; clear star_tracker_noise_fail star_tracker_noise_success 
% for itest =1:size(mc_all_initial,1)
%     if Success(itest) == 1
%         isuccess = isuccess + 1;
%         star_tracker_noise_success(isuccess) = mc_all_initial(itest,17)*3600;
%     else
%         ifail = ifail + 1;
%         star_tracker_noise_fail(ifail) = mc_all_initial(itest,17)*3600;
%     end
% end
% if exist('star_tracker_noise_success')==1
%     figure;hist(star_tracker_noise_success,20);grid on 
%     title_string = 'Star Tracker Noise to Landing Success';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Star Tracker Noise (arc-sec)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistTrkrNoiseSucc.png');%saveas(gcf,'HistTrkrNoiseSucc.fig')
% end
% if exist('star_tracker_noise_fail')==1
%     figure;hist(star_tracker_noise_fail,20);grid on
%     h = findobj(gca,'Type','patch');
%     set(h,'FaceColor','r')
%     title_string = 'Star Tracker Noise to Landing Failure';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Star Tracker Noise (arc-sec)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistTrkrNoiseFail.png');%saveas(gcf,'HistTrkrNoiseFail.fig')
% end
%%
% figure;plot(mc_all_initial(:,18),Success,'*');grid on
% title_string = 'Landing Success vs Camera Integration Time';
% title(title_string);set(gcf,'Name',title_string)
% xlabel('Camera Integration Time (sec)')
% ylabel('Success=1 Fail=0')
% axis([-1 +1 -1 +2]);axis('auto x')
% isuccess = 0;ifail = 0;clear camera_integration_time_fail camera_integration_time_success
% for itest =1:size(mc_all_initial,1)
%     if Success(itest) == 1
%         isuccess = isuccess + 1;
%         camera_integration_time_success(isuccess) = mc_all_initial(itest,18);
%     else
%         ifail = ifail + 1;
%         camera_integration_time_fail(ifail) = mc_all_initial(itest,18);
%     end
% end
% if exist('camera_integration_time_success')==1
%     figure;hist(camera_integration_time_success,20);grid on 
%     title_string = 'Camera Integration Time to Landing Success';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Camera Integration Time (sec)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistCamDtSucc.png');%saveas(gcf,'HistCamDtSucc.fig')
% end
% if exist('camera_integration_time_fail')==1
%     figure;hist(camera_integration_time_fail,20);grid on
%     h = findobj(gca,'Type','patch');
%     set(h,'FaceColor','r')
%     title_string = 'Camera Integration Time to Landing Failure';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Camera Integration Time (sec)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistCamDtFail.png');%saveas(gcf,'HistCamDtFail.fig')
% end
%%
% figure;plot(mc_all_initial(:,19),Success,'*');grid on
% title_string = 'Landing Success vs Camera Focal Length';
% title(title_string);set(gcf,'Name',title_string)
% xlabel('Camera Focal Length (m)')
% ylabel('Success=1 Fail=0')
% axis([-1 +1 -1 +2]);axis('auto x')
% isuccess = 0;ifail = 0;clear camera_focal_length_fail camera_focal_length_success
% for itest =1:size(mc_all_initial,1)
%     if Success(itest) == 1
%         isuccess = isuccess + 1;
%         camera_focal_length_success(isuccess) = mc_all_initial(itest,19);
%     else
%         ifail = ifail + 1;
%         camera_focal_length_fail(ifail) = mc_all_initial(itest,19);
%     end
% end
% if exist('camera_focal_length_success')==1
%     figure;hist(camera_focal_length_success,20);grid on 
%     title_string = 'Camera Focal Length to Landing Success';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Camera Focal Length (meters)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistFocalSucc.png');%saveas(gcf,'HistFocalSucc.fig')
% end
% if exist('camera_focal_length_fail')==1
%     figure;hist(camera_focal_length_fail,20);grid on
%     h = findobj(gca,'Type','patch');
%     set(h,'FaceColor','r')
%     title_string = 'Camera Focal Length to Landing Failure';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Camera Focal Length (meters)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistFocalFail.png');%saveas(gcf,'HistFocalFail.fig')
% end
%%
% figure;plot(mc_all_initial(:,20)*180/pi,Success,'*');grid on
% title_string = 'Landing Success vs Camera Angular Field of View';
% title(title_string);set(gcf,'Name',title_string)
% xlabel('Camera Angular Field of View (deg)')
% ylabel('Success=1 Fail=0')
% axis([-1 +1 -1 +2]);axis('auto x')
% isuccess = 0;ifail = 0;clear camera_aov_fail camera_aov_success
% for itest =1:size(mc_all_initial,1)
%     if Success(itest) == 1
%         isuccess = isuccess + 1;
%         camera_aov_success(isuccess) = mc_all_initial(itest,20)*180/pi;
%     else
%         ifail = ifail + 1;
%         camera_aov_fail(ifail) = mc_all_initial(itest,20)*180/pi;
%     end
% end
% if exist('camera_aov_success')==1
%     figure;hist(camera_aov_success,20);grid on 
%     title_string = 'Camera Angular Field of View to Landing Success';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Camera Angular Field of View (deg)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistCamAOVSucc.png');%saveas(gcf,'HistCamAOVSucc.fig')
% end
% if exist('camera_aov_fail')==1
%     figure;hist(camera_aov_fail,20);grid on
%     h = findobj(gca,'Type','patch');
%     set(h,'FaceColor','r')
%     title_string = 'Camera Angular Field of View to Landing Failure';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Camera Angular Field of View (deg)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistCamAOVFail.png');%saveas(gcf,'HistCamAOVFail.fig')
% end
%%
% figure;plot(mc_all_initial(:,21),Success,'*');grid on
% title_string = 'Landing Success vs Image Delta-T';
% title(title_string);set(gcf,'Name',title_string)
% xlabel('Camera Number of Image Delta-T (sec)')
% ylabel('Success=1 Fail=0')
% axis([-1 +1 -1 +2]);axis('auto x')
% isuccess = 0;ifail = 0;clear camera_delta_t_fail camera_delta_t_success
% for itest =1:size(mc_all_initial,1)
%     if Success(itest) == 1
%         isuccess = isuccess + 1;
%         camera_delta_t_success(isuccess) = mc_all_initial(itest,21);
%     else
%         ifail = ifail + 1;
%         camera_delta_t_fail(ifail) = mc_all_initial(itest,21);
%     end
% end
% if exist('camera_delta_t_success')==1
%     figure;hist(camera_delta_t_success,20);grid on 
%     title_string = 'Camera Delta-T to Landing Success';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Camera Delta-T (sec)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistProcDtSucc.png');%saveas(gcf,'HistProcDtSucc.fig')
% end
% if exist('camera_delta_t_fail')==1
%     figure;hist(camera_delta_t_fail,20);grid on
%     h = findobj(gca,'Type','patch');
%     set(h,'FaceColor','r')
%     title_string = 'Camera Delta-T to Landing Failure';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Camera Delta-T (sec)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistProcDtFail.png');%saveas(gcf,'HistProcDtFail.fig')
% end
%%
% figure;plot(mc_all_initial(:,22)*1e6,Success,'*');grid on
% title_string = 'Landing Success vs Camera Processing Delay';
% title(title_string);set(gcf,'Name',title_string)
% xlabel('Camera Processing Delay (sec)')
% ylabel('Success=1 Fail=0')
% axis([-1 +1 -1 +2]);axis('auto x')
% isuccess = 0;ifail = 0;clear camera_processing_delay_fail camera_processing_delay_success
% for itest =1:size(mc_all_initial,1)
%     if Success(itest) == 1
%         isuccess = isuccess + 1;
%         camera_processing_delay_success(isuccess) = mc_all_initial(itest,22);
%     else
%         ifail = ifail + 1;
%         camera_processing_delay_fail(ifail) = mc_all_initial(itest,22);
%     end
% end
% if exist('camera_processing_delay_success')==1
%     figure;hist(camera_processing_delay_success,20);grid on 
%     title_string = 'Camera Processing Delay to Landing Success';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Camera Processing Delay (sec)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistCamProcDelaySucc.png');%saveas(gcf,'HistCamProcDelaySucc.fig')
% end
% if exist('camera_processing_delay_fail')==1
%     figure;hist(camera_processing_delay_fail,20);grid on
%     h = findobj(gca,'Type','patch');
%     set(h,'FaceColor','r')
%     title_string = 'Camera Processing Delay to Landing Failure';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Camera Processing Delay (sec)','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     saveas(gcf,'HistCamProcDelayFail.png');%saveas(gcf,'HistCamProcDelayFail.fig')
% end

%%
figure;plot(wind_speed,Success,'*');grid on
title_string = 'Landing Success vs Wind Speed';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Wind Speed (m/s)','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
set(gcf,'Name','Landing Success vs Wind Speed')
saveas(gcf,'WindSpeedSuccFail.png');%saveas(gcf,'WindSpeedSuccFail.fig')
isuccess = 0;ifail = 0;clear wind_speed_fail wind_speed_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        wind_speed_success(isuccess) = wind_speed(itest);
    else
        ifail = ifail + 1;
        wind_speed_fail(ifail) = wind_speed(itest);
    end
end
if exist('wind_speed_success')==1
    figure;hist(wind_speed_success,20);grid on
    title_string = 'Wind Speed to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Wind Speed (m/s)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistWindSpeedSucc.png');%saveas(gcf,'HistWindSpeedSucc.fig')
end
if exist('wind_speed_fail')==1
    figure;hist(wind_speed_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Wind Speed to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Wind Speed (m/s)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistWindSpeedFail.png');%saveas(gcf,'HistWindSpeedFail.fig')
end

%%
figure;plot(wind_azimuth,Success,'*');grid on
title_string = 'Landing Success vs Wind Azimuth';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Wind Azimuth (deg)','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
set(gcf,'Name','Landing Success vs Wind Azimuth')
saveas(gcf,'WindAzSuccFail.png');%saveas(gcf,'WindAzSuccFail.fig')
isuccess = 0;ifail = 0;clear wind_azimuth_fail wind_azimuth_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        wind_azimuth_success(isuccess) = wind_azimuth(itest);
    else
        ifail = ifail + 1;
        wind_azimuth_fail(ifail) = wind_azimuth(itest);
    end
end
if exist('wind_azimuth_success')==1
    figure;hist(wind_azimuth_success,20);grid on
    title_string = 'Wind Azimuth to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Wind Azimuth (deg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistWindAzSucc.png');%saveas(gcf,'HistWindAzSucc.fig')
end
if exist('wind_azimuth_fail')==1
    figure;hist(wind_azimuth_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Wind Azimuth to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Wind Azimuth (deg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistWindAzFail.png');%saveas(gcf,'HistWindAzFail.fig')
end

%%
figure;plot(gust_magnitude,Success,'*');grid on
title_string = 'Landing Success vs Gust Magnitude';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Gust Magnitude (m/s)','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
set(gcf,'Name','Landing Success vs Gust Magnitude')
saveas(gcf,'GustMagnitudeSuccFail.png');%saveas(gcf,'GustMagnitudeSuccFail.fig')
isuccess = 0;ifail = 0;clear gust_magnitude_fail gust_magnitude_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        gust_magnitude_success(isuccess) = gust_magnitude(itest);
    else
        ifail = ifail + 1;
        gust_magnitude_fail(ifail) = gust_magnitude(itest);
    end
end
if exist('gust_magnitude_success')==1
    figure;hist(gust_magnitude_success,20);grid on
    title_string = 'Gust Magnitude to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Gust Magnitude (m/s)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistGustMagnitudeSucc.png');%saveas(gcf,'HistGustMagnitudeSucc.fig')
end
if exist('gust_magnitude_fail')==1
    figure;hist(gust_magnitude_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Gust Magnitude to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Gust Magnitude (m/s)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistGustMagnitudeFail.png');%saveas(gcf,'HistGustMagnitudeFail.fig')
end

%%
figure;plot(gust_start-35,Success,'*');grid on
title_string = 'Landing Success vs Gust Start Relative to Takeoff';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Gust Start (sec)','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
set(gcf,'Name','Landing Success vs Gust Start')
saveas(gcf,'GustStartSuccFail.png');%saveas(gcf,'GustStartSuccFail.fig')
isuccess = 0;ifail = 0;clear gust_start_fail gust_start_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        gust_start_success(isuccess) = gust_start(itest);
    else
        ifail = ifail + 1;
        gust_start_fail(ifail) = gust_start(itest);
    end
end
if exist('gust_start_success')==1
    figure;hist(gust_start_success-35,20);grid on
    title_string = 'Gust Start to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Gust Start (sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistGustStartSucc.png');%saveas(gcf,'HistGustStartSucc.fig')
end
if exist('gust_start_fail')==1
    figure;hist(gust_start_fail-35,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Gust Start to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Gust Start (sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistGustStartFail.png');%saveas(gcf,'HistGustStartFail.fig')
end

%%
figure;plot(gust_length,Success,'*');grid on
title_string = 'Landing Success vs Gust Length';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Gust Length (sec)','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
set(gcf,'Name','Landing Success vs Gust Length')
saveas(gcf,'GustLengthSuccFail.png');%saveas(gcf,'GustLengthSuccFail.fig')
isuccess = 0;ifail = 0;clear gust_length_fail gust_length_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        gust_length_success(isuccess) = gust_length(itest);
    else
        ifail = ifail + 1;
        gust_length_fail(ifail) = gust_length(itest);
    end
end
if exist('gust_length_success')==1
    figure;hist(gust_length_success,20);grid on
    title_string = 'Gust Length to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Gust Length (sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistGustLengthSucc.png');%saveas(gcf,'HistGustLengthSucc.fig')
end
if exist('gust_length_fail')==1
    figure;hist(gust_length_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Gust Length to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Gust Length (sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    set(gcf,'Name','Histogram: Gust Length to Landing Failure')
    saveas(gcf,'HistGustLengthFail.png');%saveas(gcf,'HistGustLengthFail.fig')
end

%%
figure;plot(gust_direction,Success,'*');grid on
title_string = 'Landing Success vs Gust Relative Direction';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Gust Relative Direction (deg)','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
set(gcf,'Name','Landing Success vs Gust Relative Direction')
saveas(gcf,'GustDirectionSuccFail.png');%saveas(gcf,'GustDirectionSuccFail.fig')
isuccess = 0;ifail = 0;clear gust_direction_fail gust_direction_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        gust_direction_success(isuccess) = gust_direction(itest);
    else
        ifail = ifail + 1;
        gust_direction_fail(ifail) = gust_direction(itest);
    end
end
if exist('gust_direction_success')==1
    figure;hist(gust_direction_success,20);grid on
    title_string = 'Gust Relative Direction to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Gust Relative Direction (deg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistGustDirectionSucc.png');%saveas(gcf,'HistGustDirectionSucc.fig')
end
if exist('gust_direction_fail')==1
    figure;hist(gust_direction_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Gust Relative Direction to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Gust Relative Direction (deg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistGustDirectionFail.png');%saveas(gcf,'HistGustDirectionFail.fig')
end

%%
figure;plot(fluid_damping,Success,'*');grid on
title_string = 'Landing Success vs Fluid Damping';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Fluid Damping','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'FluidDampingSuccFail.png');%saveas(gcf,'FluidDampingSuccFail.fig')
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
    title_string = 'Fluid Damping to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Fluid Damping','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistFluidDampingSucc.png');%saveas(gcf,'HistFluidDampingSucc.fig')
end
if exist('fluid_damping_fail')==1
    figure;hist(fluid_damping_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Fluid Damping to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Fluid Damping','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistFluidDampingFail.png');%saveas(gcf,'HistFluidDampingFail.fig')
end

%%
figure;plot(htp_mass,Success,'*');grid on
title_string = 'Landing Success vs Initial HTP Mass';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Initial HTP Mass','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'HtpMassSuccFail.png');%saveas(gcf,'HtpMassSuccFail.fig')
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
    title_string = 'Initial HTP Mass to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Initial HTP Mass','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistHtpMassSucc.png');%saveas(gcf,'HistHtpMassSucc.fig')
end
if exist('htp_mass_fail')==1
    figure;hist(htp_mass_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Initial HTP Mass to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Initial HTP Mass','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistHtpMassFail.png');%saveas(gcf,'HistHtpMassFail.fig')
end

%%
figure;plot(pendulum_length,Success,'*');grid on
title_string = 'Landing Success vs Pendulum Max Length';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Pendulum Length / Tank Radius','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'PendLenSuccFail.png');%saveas(gcf,'PendLenSuccFail.fig')
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
    title_string = 'Pendulum Max Length to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Pendulum Length / Tank Radius','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistPendLenSucc.png');%saveas(gcf,'HistPendLenSucc.fig')
end
if exist('pendulum_length_fail')==1
    figure;hist(pendulum_length_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Pendulum Max Length to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Pendulum Length / Tank Radius','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistPendLenFail.png');%saveas(gcf,'HistPendLenFail.fig')
end

%%
figure;plot(pendulum_mass*100,Success,'*');grid on
title_string = 'Landing Success vs Peak Pendulum Mass';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('% Peak Mass','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'PendMassSuccFail.png');%saveas(gcf,'PendMassSuccFail.fig')
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
    title_string = 'Pendulum Mass to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('% Peak Mass','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistPendMassSucc.png');%saveas(gcf,'HistPendMassSucc.fig')
end
if exist('pendulum_mass_fail')==1
    figure;hist(pendulum_mass_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Pendulum Mass to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('% Peak Mass','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistPendMassFail.png');%saveas(gcf,'HistPendMassFail.fig')
end

%%
figure;plot(hinge_height,Success,'*');grid on
title_string = 'Landing Success vs Pendulum Max Hinge Height';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Hinge Height / Tank Diameter','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'HingeHeightSuccFail.png');%saveas(gcf,'HingeHeightSuccFail.fig')
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
    title_string = 'Pendulum Max Hinge Height to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Hinge Height / Tank Diameter','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistHingeHeightSucc.png');%saveas(gcf,'HistHingeHeightSucc.fig')
end
if exist('hinge_height_fail')==1
    figure;hist(hinge_height_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Pendulum Max Hinge Height to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Hinge Height / Tank Diameter','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistHingeHeightFail.png');%saveas(gcf,'HistHingeHeightFail.fig')
end

%%
figure;plot(drain_efficiency(:,1),Success,'*');grid on
title_string = 'Landing Success vs Tank 1 Drain Efficiency';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Drain Efficiency','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'DrainEffTank1SuccFail.png');%saveas(gcf,'DrainEffTank1SuccFail.fig')
isuccess = 0;ifail = 0;clear drain_efficiency_fail drain_efficiency_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        drain_efficiency_success(isuccess) = drain_efficiency(itest,1);
    else
        ifail = ifail + 1;
        drain_efficiency_fail(ifail) = drain_efficiency(itest,1);
    end
end
if exist('drain_efficiency_success')==1
    figure;hist(drain_efficiency_success,20);grid on
    title_string = 'Tank 1 Drain Efficiency to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Drain Efficiency','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistDrainEffTank1Succ.png');%saveas(gcf,'HistDrainEffTank1Succ.fig')
end
if exist('drain_efficiency_fail')==1
    figure;hist(drain_efficiency_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Tank 1 Drain Efficiency to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Drain Efficiency','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistDrainEffTank1Fail.png');%saveas(gcf,'HistDrainEffTank1Fail.fig')
end

%%
figure;plot(drain_efficiency(:,2),Success,'*');grid on
title_string = 'Landing Success vs Tank 2 Drain Efficiency';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Drain Efficiency','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'DrainEffTank2SuccFail.png');%saveas(gcf,'DrainEffTank2SuccFail.fig')
isuccess = 0;ifail = 0;clear drain_efficiency_fail drain_efficiency_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        drain_efficiency_success(isuccess) = drain_efficiency(itest,2);
    else
        ifail = ifail + 1;
        drain_efficiency_fail(ifail) = drain_efficiency(itest,2);
    end
end
if exist('drain_efficiency_success')==1
    figure;hist(drain_efficiency_success,20);grid on
    title_string = 'Tank 2 Drain Efficiency to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Drain Efficiency','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistDrainEffTank2Succ.png');%saveas(gcf,'HistDrainEffTank2Succ.fig')
end
if exist('drain_efficiency_fail')==1
    figure;hist(drain_efficiency_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Tank 2 Drain Efficiency to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Drain Efficiency','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistDrainEffTank2Fail.png');%saveas(gcf,'HistDrainEffTank2Fail.fig')
end

%%
figure;plot(lateral_cg_dry_offset*1e3,Success,'*');grid on
title_string = 'Landing Success vs Dry Lander CG Offset';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Lateral Offset (millimeters)','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'DryCGOffsetSuccFail.png');%saveas(gcf,'DryCGOffsetSuccFail.fig')
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
    figure;hist(lateral_cg_dry_offset_success*1e3,20);grid on 
    title_string = 'Dry Lander CG Offset to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Dry Lander CG Offset (mm)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistDryCGOffsetSucc.png');%saveas(gcf,'HistDryCGOffsetSucc.fig')
end
if exist('lateral_cg_dry_offset_fail')==1
    figure;hist(lateral_cg_dry_offset_fail*1e3,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Dry Lander CG Offset to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Dry Lander CG Offset (mm)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistDryCGOffsetFail.png');%saveas(gcf,'HistDryCGOffsetFail.fig')
end

%%
figure;plot(lateral_cg_wet_offset*1e3,Success,'*');grid on
title_string = 'Landing Success vs Wet Lander CG Offset';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Lateral Offset (millimeters)','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'WetCGOffsetSuccFail.png');%saveas(gcf,'WetCGOffsetSuccFail.fig')
isuccess = 0;ifail = 0;clear lateral_cg_wet_offset_fail lateral_cg_wet_offset_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        lateral_cg_wet_offset_success(isuccess) = lateral_cg_wet_offset(itest);
    else
        ifail = ifail + 1;
        lateral_cg_wet_offset_fail(ifail) = lateral_cg_wet_offset(itest);
    end
end
if exist('lateral_cg_wet_offset_success')==1
    figure;hist(lateral_cg_wet_offset_success*1e3,20);grid on 
    title_string = 'Wet Lander CG Offset to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Wet Lander CG Offset (mm)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistWetCGOffsetSucc.png');%saveas(gcf,'HistWetCGOffsetSucc.fig')
end
if exist('lateral_cg_wet_offset_fail')==1
    figure;hist(lateral_cg_wet_offset_fail*1e3,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Wet Lander CG Offset to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Wet Lander CG Offset (mm)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistWetCGOffsetFail.png');%saveas(gcf,'HistWetCGOffsetFail.fig')
end

%%
if exist('acs_thruster_delay')
figure;plot(acs_thruster_delay,Success,'*');grid on
title_string = 'Landing Success vs ACS Thruster Fire Delay';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Delay Time (sec)','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'AcsThrDelaySuccFail.png');%saveas(gcf,'AcsThrDelaySuccFail.fig')
isuccess = 0;ifail = 0;clear acs_thruster_delay_fail acs_thruster_delay_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        acs_thruster_delay_success(isuccess) = acs_thruster_delay(itest);
    else
        ifail = ifail + 1;
        acs_thruster_delay_fail(ifail) = acs_thruster_delay(itest);
    end
end
if exist('acs_thruster_delay_success')==1
    figure;hist(acs_thruster_delay_success,20);grid on
    title_string = 'ACS Thruster Fire Delay to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Delay Time (sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'AcsThrDelaySucc.png');%saveas(gcf,'AcsThrDelaySucc.fig')
end
if exist('acs_thruster_delay_fail')==1
    figure;hist(acs_thruster_delay_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'ACS Thruster Fire Delay to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Delay Time (sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'AcsThrDelayFail.png');%saveas(gcf,'AcsThrDelayFail.fig')
end
end

%%
if exist('acs_thruster_bias')
figure;plot(acs_thruster_bias,Success,'*');grid on
title_string = 'Landing Success vs ACS Thruster Fire Time Bias';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Time (sec)','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'AcsThrBiasSuccFail.png');%saveas(gcf,'AcsThrBiasSuccFail.fig')
isuccess = 0;ifail = 0;clear acs_thruster_bias_fail acs_thruster_bias_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        acs_thruster_bias_success(isuccess) = acs_thruster_bias(itest);
    else
        ifail = ifail + 1;
        acs_thruster_bias_fail(ifail) = acs_thruster_bias(itest);
    end
end
if exist('acs_thruster_bias_success')==1
    figure;hist(acs_thruster_bias_success,20);grid on
    title_string = 'ACS Thruster Fire Time Bias to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Time (sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'AcsThrBiasSucc.png');%saveas(gcf,'AcsThrBiasSucc.fig')
end
if exist('acs_thruster_bias_fail')==1
    figure;hist(acs_thruster_bias_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'ACS Thruster Fire Time Bias to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Time (sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'AcsThrBiasFail.png');%saveas(gcf,'AcsThrBiasFail.fig')
end
end
%%
figure;plot(throttle_to_thrust,Success,'*');grid on
title_string = 'Landing Success vs EGC Throttle to Thrust';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('EGC Throttle to Thrust Gain','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'EgcThrottleThrustSuccFail.png')
isuccess = 0;ifail = 0;clear egc_throttle_thrust_fail egc_throttle_thrust_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        egc_throttle_thrust_success(isuccess) = throttle_to_thrust(itest);
    else
        ifail = ifail + 1;
        egc_throttle_thrust_fail(ifail) = throttle_to_thrust(itest);
    end
end
if exist('egc_throttle_thrust_success')==1
    figure;hist(egc_throttle_thrust_success,20);grid on
    title_string = 'EGC Throttle to Thrust Gain to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('EGC Throttle to Thrust Gain','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistEgcThrottleThrustSucc.png');%saveas(gcf,'HistEgcThrottleThrustSucc.fig')
end
if exist('egc_throttle_thrust_fail')==1
    figure;hist(egc_throttle_thrust_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'EGC Throttle to Thrust Gain to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('EGC Throttle to Thrust Gain','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistEgcThrottleThrustFail.png');%saveas(gcf,'HistEgcThrottleThrustFail.fig')
end

%%
figure;plot(throttle_to_mdot,Success,'*');grid on
title_string = 'Landing Success vs EGC Throttle to Mdot';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('EGC Throttle to Mdot Gain','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'EgcThrottleMdotSuccFail.png')
isuccess = 0;ifail = 0;clear egc_throttle_mdot_fail egc_throttle_mdot_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        egc_throttle_mdot_success(isuccess) = throttle_to_mdot(itest);
    else
        ifail = ifail + 1;
        egc_throttle_mdot_fail(ifail) = throttle_to_mdot(itest);
    end
end
if exist('egc_throttle_mdot_success')==1
    figure;hist(egc_throttle_mdot_success,20);grid on
    title_string = 'EGC Throttle to Mdot Gain to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('EGC Throttle to Mdot Gain','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistEgcThrottleMdotSucc.png');%saveas(gcf,'HistEgcThrottleMdotSucc.fig')
end
if exist('egc_throttle_mdot_fail')==1
    figure;hist(egc_throttle_mdot_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'EGC Throttle to Mdot Gain to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('EGC Throttle to Mdot Gain','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistEgcThrottleMdotFail.png');%saveas(gcf,'HistEgcThrottleMdotFail.fig')
end

%%
figure;plot(mass_estimate_bias,Success,'*');grid on
title_string = 'Landing Success vs Mass Estimate Bias';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Mass Estimate Bias (kg)','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'MassEstBiasSuccFail.png')
isuccess = 0;ifail = 0;clear mass_estimate_bias_fail mass_estimate_bias_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        mass_estimate_bias_success(isuccess) = mass_estimate_bias(itest);
    else
        ifail = ifail + 1;
        mass_estimate_bias_fail(ifail) = mass_estimate_bias(itest);
    end
end
if exist('mass_estimate_bias_success')==1
    figure;hist(mass_estimate_bias_success,20);grid on
    title_string = 'Mass Estimate Bias to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Mass Estimate Bias (kg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistMassEstBiasSucc.png');%saveas(gcf,'HistMassEstBiasSucc.fig')
end
if exist('mass_estimate_bias_fail')==1
    figure;hist(mass_estimate_bias_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Mass Estimate Bias to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Mass Estimate Bias (kg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistMassEstBiasFail.png');%saveas(gcf,'HistMassEstBiastFail.fig')
end

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
            plot(mc_traj_data.cg.Time,mc_traj_data.cg.Data(:,1)*1000,'b-');hold on
       else
            plot(mc_traj_data.cg.Time,mc_traj_data.cg.Data(:,1)*1000,'r-');hold on
       end          
    end
    hold on; grid on;
end
xlabel('Time (sec)','fontsize',14);
ylabel('Distance (mm)','fontsize',14);
title_string = 'CG X Position';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
saveas(gcf,'CgXPos.png');%saveas(gcf,'CgXPos.fig')

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
            plot(mc_traj_data.cg.Time,mc_traj_data.cg.Data(:,2)*1000,'b-');hold on
       else
            plot(mc_traj_data.cg.Time,mc_traj_data.cg.Data(:,2)*1000,'r-');hold on
       end          
    end
    hold on; grid on;
end
xlabel('Time (sec)','fontsize',14);
ylabel('Distance (mm)','fontsize',14);
title_string = 'CG Y Position';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
saveas(gcf,'CgYPos.png');%saveas(gcf,'CgYPos.fig')

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
            plot(mc_traj_data.cg.Time,mc_traj_data.cg.Data(:,3)*1000,'b-');hold on
       else
            plot(mc_traj_data.cg.Time,mc_traj_data.cg.Data(:,3)*1000,'r-');hold on
       end          
    end
    hold on; grid on;
end
xlabel('Time (sec)','fontsize',14);
ylabel('Distance (mm)','fontsize',14);
title_string = 'CG Z Position';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
saveas(gcf,'CgZPos.png');%saveas(gcf,'CgZPos.fig')
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
center = mean(mc_all_final(:,15:16),1);
standard_deviation_landing_error = std(rss_landing_err);
title_string = 'Touchdown Topocentric Position';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Topocentric X Position (meters)','fontsize',14)
ylabel('Topocentric Y Position (meters)','fontsize',14)
str_text_box = {sprintf('Center   = %7.3f, %7.3f m',center),sprintf('3 Sigma = %7.3f m',3*standard_deviation_landing_error)};
annotation('textbox',[.2 .8 .37 .1],'string',str_text_box) 
hold on;
circle_3_sigma_y = center(2)+3*standard_deviation_landing_error*sin(2*pi*0.01*[0:100]);
circle_3_sigma_x = center(1)+3*standard_deviation_landing_error*cos(2*pi*0.01*[0:100]);
plot(circle_3_sigma_x,circle_3_sigma_y,'r-','linewidth',2);
saveas(gcf,'LateralPosErr.png');%saveas(gcf,'LateralPosErr.fig')
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
title_string = 'Touchdown Topocentric Position Relative to Median';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Topocentric X Position (meters)','fontsize',14)
ylabel('Topocentric Y Position (meters)','fontsize',14)
str_text_box = {horzcat('Mean = ',num2str(mean_landing_error),' m'),horzcat('3 Sigma = ',num2str(3*standard_deviation_landing_error),' m')};
annotation('textbox',[.2 .8 .27 .1],'string',str_text_box) 
hold on;
circle_3_sigma_y = 3*standard_deviation_landing_error*sin(2*pi*0.01*[0:100]);
circle_3_sigma_x = 3*standard_deviation_landing_error*cos(2*pi*0.01*[0:100]);
plot(circle_3_sigma_x,circle_3_sigma_y,'r-','linewidth',2);
saveas(gcf,'LateralPosErrMedian.png');%saveas(gcf,'LateralPosErrMedian.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(lateral_gnc_vel_scalar(itest),abs(mc_all_final(itest,20)),'b*');
 elseif(mc_all_final(itest,39)==1)
     plot(lateral_gnc_vel_scalar(itest),abs(mc_all_final(itest,20)),'r*');
 end
end
title_string = 'Touchdown Lateral Velocity vs Vertical Velocity';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Topocentric Lateral Velocity (m/s)','fontsize',14)
ylabel('Topocentric Vertical Velocity (m/s)','fontsize',14)
saveas(gcf,'LateralVerticalVel.png');%saveas(gcf,'LateralVerticalVel.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(norm(mc_all_final(itest,21:22)),norm(mc_all_final(itest,24:25)),'b*');
 elseif(mc_all_final(itest,39)==1)
     plot(norm(mc_all_final(itest,21:22)),norm(mc_all_final(itest,24:25)),'r*');
 end
end
title_string = 'Touchdown Angle vs Body Rate';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Angle From Vertical (deg)','fontsize',14)
ylabel('Body Rate (deg/s)','fontsize',14)
saveas(gcf,'TDAngleVsRate.png');%saveas(gcf,'TDAngleVsRate.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(lateral_gnc_vel_scalar(itest),norm(mc_all_final(itest,21:22)),'b*');
 elseif(mc_all_final(itest,39)==1)
     plot(lateral_gnc_vel_scalar(itest),norm(mc_all_final(itest,21:22)),'r*');
 end
end
title_string = 'Touchdown Angle vs Lateral Velocity';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Topocentric Lateral Velocity (m/s)','fontsize',14)
ylabel('Angle From Vertical (deg)','fontsize',14)
saveas(gcf,'TDAngleandLateralVel.png');%saveas(gcf,'TDAngleandLateralVel.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(lateral_cg_wet_offset(itest)*1000,lateral_gnc_pos_scalar(itest),'b*');
 elseif(mc_all_final(itest,39)==1)
     plot(lateral_cg_wet_offset(itest)*1000,lateral_gnc_pos_scalar(itest),'r*');
 end
end
title_string = 'Lateral Center of Mass Offset vs Lateral Touchdown Error';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Lateral Center of Mass Offset (mm)','fontsize',14)
ylabel('Lateral Touchdown Position Error (m)','fontsize',14)
saveas(gcf,'LateralCMandPosErr.png');%saveas(gcf,'LateralCMandPosErr.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(cm_az_deg(itest),lateral_gnc_pos_scalar(itest),'b*');
 elseif(mc_all_final(itest,39)==1)
     plot(cm_az_deg(itest),lateral_gnc_pos_scalar(itest),'r*');
 end
end
title_string = 'Lateral Center of Mass Offset Azimuth vs Lateral Touchdown Error';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Lateral Center of Mass Offset Azimuth (deg)','fontsize',14)
ylabel('Lateral Touchdown Position Error (m)','fontsize',14)
saveas(gcf,'LateralCMAzimuthandPosErr.png');%saveas(gcf,'LateralCMAzimuthandPosErr.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(lateral_cg_wet_offset(itest)*1000,total_fuel_used_scalar(itest),'b*');
 elseif(mc_all_final(itest,39)==1)
     plot(lateral_cg_wet_offset(itest)*1000,total_fuel_used_scalar(itest),'r*');
 end
end
title_string = 'Lateral Center of Mass Offset vs Propellant Usage';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Lateral Center of Mass Offset (mm)','fontsize',14)
ylabel('Propellant Usage (kg)','fontsize',14)
saveas(gcf,'LateralCMandPropUsed.png');%saveas(gcf,'LateralCMandPropUsed.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(cm_az_deg(itest),total_fuel_used_scalar(itest),'b*');
 elseif(mc_all_final(itest,39)==1)
     plot(cm_az_deg(itest),total_fuel_used_scalar(itest),'r*');
 end
end
title_string = 'Lateral Center of Mass Offset Azimuth vs Propellant Usage';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Lateral Center of Mass Offset Azimuth (deg)','fontsize',14)
ylabel('Propellant Usage (kg)','fontsize',14)
saveas(gcf,'LateralCMAzimuthandPropUsed.png');%saveas(gcf,'LateralCMAzimuthandPropUsed.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(abs(mc_all_initial(itest,84)),lateral_gnc_pos_scalar(itest),'b*');
 elseif(mc_all_final(itest,39)==1)
     plot(abs(mc_all_initial(itest,84)),lateral_gnc_pos_scalar(itest),'r*');
 end
end
title_string = 'EGC Misaligment vs Lateral Touchdown Error';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('EGC Misaligment (deg)','fontsize',14)
ylabel('Lateral Touchdown Position Error (m)','fontsize',14)
saveas(gcf,'EgcMisalignandPosErr.png');%saveas(gcf,'EgcMisalignandPosErr.fig')%%
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(abs(mc_all_initial(itest,59)),lateral_gnc_pos_scalar(itest),'b*');
 elseif(mc_all_final(itest,39)==1)
     plot(abs(mc_all_initial(itest,59)),lateral_gnc_pos_scalar(itest),'r*');
 end
end
title_string = 'EGC Misaligment Azimuth vs Lateral Touchdown Error';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('EGC Misaligment Azimuth (deg)','fontsize',14)
ylabel('Lateral Touchdown Position Error (m)','fontsize',14)
saveas(gcf,'EgcMisalignAzandPosErr.png');%saveas(gcf,'EgcMisalignAzandPosErr.fig')%%

%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(abs(lateral_gnc_pos_scalar(itest)),final_est_pos_err(itest),'b*');
 elseif(mc_all_final(itest,39)==1)
     plot(abs(lateral_gnc_pos_scalar(itest)),final_est_pos_err(itest),'r*');
 end
end
title_string = 'Touchdown True Lateral Position Error vs Lateral Position Estimation Error';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('True Lateral Position Error (m)','fontsize',14)
ylabel('Lateral Position Estimation Error (m)','fontsize',14)
saveas(gcf,'LateralPosErrandPosEstErr.png');%saveas(gcf,'LateralPosErrandPosEstErr.fig')%%%%

%%
% figure;
% for itest=1:size(mc_all_final,1) 
%     if(mc_all_final(itest,39)==0)
%         plot3(mc_all_initial(itest,2),mc_all_initial(itest,3),mc_all_initial(itest,4),'b*');hold on
%     elseif(mc_all_final(itest,39)==1)
%         plot3(mc_all_initial(itest,2),mc_all_initial(itest,3),mc_all_initial(itest,4),'r*');hold on
%     end
% end
%     
% title_string = 'Initial Position Estimation Error';
% title(title_string,'fontsize',14);set(gcf,'Name',title_string)
% xlabel('X Position Error (meters)','fontsize',14);
% ylabel('Y Position Error (meters)','fontsize',14);
% zlabel('Z Position Error (meters)','fontsize',14);
% hold on; grid on;
% saveas(gcf,'InitialPosEstError.png');%saveas(gcf,'InitialPosEstError.fig')

%%
% figure;
% for itest=1:size(mc_all_final,1)
%     if(mc_all_final(itest,39)==0)
%         plot3(mc_all_initial(itest,5),mc_all_initial(itest,6),mc_all_initial(itest,7),'b*');hold on 
%     elseif(mc_all_final(itest,39)==1)
%         plot3(mc_all_initial(itest,5),mc_all_initial(itest,6),mc_all_initial(itest,7),'r*');hold on
%     end
% end
% title_string = 'Initial Velocity Estimation Error';
% title(title_string,'fontsize',14);set(gcf,'Name',title_string)
% xlabel('X Velocity Error (m/s)','fontsize',14);
% ylabel('Y Velocity Error (m/s)','fontsize',14);
% zlabel('Z Velocity Error (m/s)','fontsize',14);
% hold on; grid on;
% saveas(gcf,'InitialVelEstError.png');%saveas(gcf,'InitialVelEstError.fig')

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
    for imax=1:size(mc_traj_data.sim_pos.Data,1) 
        excursion(ipos,imax) = norm(mc_traj_data.sim_pos.Data(imax,1:2));
    end
    max_excursion(ipos) = max(excursion(ipos,:));
    hold on; grid on;
end
title_string = 'Top View - Landing Site Relative Position in Topocentric Frame';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Topocentric X Position (meters)','fontsize',14);
ylabel('Topocentric Y Position (meters)','fontsize',14);
saveas(gcf,'TruePosLateral.png');%saveas(gcf,'TruePosLateral.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(lateral_cg_wet_offset(itest)*1000,max_excursion(itest),'b*');
 elseif(mc_all_final(itest,39)==1)
     plot(lateral_cg_wet_offset(itest)*1000,max_excursion(itest),'r*');
 end
end
title_string = 'Lateral Center of Mass Offset vs Max Lateral Excursion';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Lateral Center of Mass Offset (mm)','fontsize',14)
ylabel('Max Lateral Excursion (m)','fontsize',14)
saveas(gcf,'LateralCMandMaxLatExcursion.png');%saveas(gcf,'LateralCMandMaxLatExcursion.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(cm_az_deg(itest),max_excursion(itest),'b*');
 elseif(mc_all_final(itest,39)==1)
     plot(cm_az_deg(itest),max_excursion(itest),'r*');
 end
end
title_string = 'Lateral Center of Mass Offset Azimuth vs Max Lateral Excursion';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Lateral Center of Mass Offset Azimuth (deg)','fontsize',14)
ylabel('Max Lateral Excursion (m)','fontsize',14)
saveas(gcf,'LateralCMAzimuthandMaxLatExcursion.png');%saveas(gcf,'LateralCMAzimuthandMaxLatExcursion.fig')
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
title_string = 'Landing Site Relative X-Position in Topocentric Frame';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Time (sec)','fontsize',14);
ylabel('Topocentric X Position (meters)','fontsize',14);
saveas(gcf,'TrueXPos.png');%saveas(gcf,'TrueXPos.fig')
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
title_string = 'Landing Site Relative Y-Position in Topocentric Frame';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Time (sec)','fontsize',14);
ylabel('Topocentric Y Position (meters)','fontsize',14);
saveas(gcf,'TrueYPos.png');%saveas(gcf,'TrueYPos.fig')
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
            plot(mc_traj_data.sim_pos.Time,mc_traj_data.sim_pos.Data(:,3),'b-');hold on
       else
            plot(mc_traj_data.sim_pos.Time,mc_traj_data.sim_pos.Data(:,3),'r-');hold on
       end           
    end
    hold on; grid on;
end
title_string = 'Landing Site Relative Z-Position in Topocentric Frame';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Time (sec)','fontsize',14);
ylabel('Topocentric Z Position (meters)','fontsize',14);
saveas(gcf,'TrueZPos.png');%saveas(gcf,'TrueZPos.fig')
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
            plot(mc_traj_data.sim_vel.Time,mc_traj_data.sim_vel.Data(:,1),'b-');hold on
       else
            plot(mc_traj_data.sim_vel.Time,mc_traj_data.sim_vel.Data(:,1),'r-');hold on
       end          
    end
    hold on; grid on;
end
title_string = 'Landing Site Relative X-Velocity in Topocentric Frame';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Time (sec)','fontsize',14);
ylabel('Topocentric X Velocity (meters/sec)','fontsize',14);
saveas(gcf,'TrueXVel.png');%saveas(gcf,'TrueXVel.fig')
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
            plot(mc_traj_data.sim_vel.Time,mc_traj_data.sim_vel.Data(:,2),'b-');hold on
       else
            plot(mc_traj_data.sim_vel.Time,mc_traj_data.sim_vel.Data(:,2),'r-');hold on
       end           
    end
    hold on; grid on;
end
title_string = 'Landing Site Relative Y-Velocity in Topocentric Frame';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Time (sec)','fontsize',14);
ylabel('Topocentric Y Velocity (meters/sec)','fontsize',14);
saveas(gcf,'TrueYVel.png');%saveas(gcf,'TrueYVel.fig')
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
            plot(mc_traj_data.sim_vel.Time,mc_traj_data.sim_vel.Data(:,3),'b-');hold on
       else
            plot(mc_traj_data.sim_vel.Time,mc_traj_data.sim_vel.Data(:,3),'r-');hold on
       end           
    end
    hold on; grid on;
end
title_string = 'Landing Site Relative Z-Velocity in Topocentric Frame';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Time (sec)','fontsize',14);
ylabel('Topocentric Z Velocity (meters/sec)','fontsize',14);
saveas(gcf,'TrueZVel.png');%saveas(gcf,'TrueZVel.fig')
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
            plot(sqrt(mc_traj_data.sim_pos.Data(:,1).^2+mc_traj_data.sim_pos.Data(:,2).^2),'b-');hold on
       else
            plot(sqrt(mc_traj_data.sim_pos.Data(:,1).^2+mc_traj_data.sim_pos.Data(:,2).^2),'r-');hold on
       end
    end
    hold on; grid on;
end
title_string = 'Landing Site Relative Lateral Distance in Topocentric Frame';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Time (sec)','fontsize',14);
ylabel('Distance (m)','fontsize',14);
saveas(gcf,'LateralvsTime.png');%saveas(gcf,'LateralvsTime.fig')

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
            plot(mc_traj_data.htp_used,'b-');hold on
       else
            plot(mc_traj_data.htp_used,'r-');hold on
       end
    end
    hold on; grid on;
end
title_string = 'HTP Mass Used';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Time (sec)','fontsize',14);
ylabel('Mass (kg)','fontsize',14);
saveas(gcf,'HtpUsed.png');%saveas(gcf,'HtpUsed.fig')
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
            plot(mc_traj_data.gn2_used,'b-');hold on
       else
            plot(mc_traj_data.gn2_used,'r-');hold on
       end
    end
    hold on; grid on;
end
title_string = 'GN2 Mass Used';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Time (sec)','fontsize',14);
ylabel('Mass (kg)','fontsize',14);
saveas(gcf,'Gn2Used.png');%saveas(gcf,'Gn2Used.fig')
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
            plot(mc_traj_data.egc_throttle,'b-');hold on
       else
            plot(mc_traj_data.egc_throttle,'r-');hold on
       end          
    end
    hold on; grid on;
end
title_string = 'EGC Throttle';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Time (sec)','fontsize',14);
saveas(gcf,'EgcThottle.png');%saveas(gcf,'EgcThottle.fig')
%%
% figure;
% for ipos = 1:mc_n
%     name_mc_pos=[ mc_prefix_s_pos num2str(ipos) ];
%     if exist(strcat(name_mc_pos,'.mat'),'file')
%         load( name_mc_pos );
%     else
%         warning(['no data for run' num2str(ipos)])
%         continue
%     end
%     if exist('mc_traj_data','var')
%        if(mc_all_final(ipos,39)==0)
%             plot(mc_traj_data.egc_desired_thrust,'b-');hold on
%        else
%             plot(mc_traj_data.egc_desired_thrust,'r-');hold on
%        end          
%     end
%     hold on; grid on;
% end
% title_string = 'EGC Desired Thrust';
% title(title_string,'fontsize',14);set(gcf,'Name',title_string)
% xlabel('Time (sec)','fontsize',14);
% ylabel('Force (Newtons)','fontsize',14);
% saveas(gcf,'EgcDesiredThrust.png');%saveas(gcf,'EgcDesiredThrust.fig')
%%
% figure;
% for ipos = 1:mc_n
%     name_mc_pos=[ mc_prefix_s_pos num2str(ipos) ];
%     if exist(strcat(name_mc_pos,'.mat'),'file')
%         load( name_mc_pos );
%     else
%         warning(['no data for run' num2str(ipos)])
%         continue
%     end
%     if exist('mc_traj_data','var')
%        if(mc_all_final(ipos,39)==0)
%             plot(mc_traj_data.egc_weight_offset,'b-');hold on
%        else
%             plot(mc_traj_data.egc_weight_offset,'r-');hold on
%        end          
%     end
%     hold on; grid on;
% end
% title_string = 'EGC Percent Weight Offset';
% title(title_string,'fontsize',14);set(gcf,'Name',title_string)
% xlabel('Time (sec)','fontsize',14);
% saveas(gcf,'EgcWeightOffset.png');%saveas(gcf,'EgcWeightOffset.fig')
%%
% figure;
% for ipos = 1:mc_n
%     name_mc_pos=[ mc_prefix_s_pos num2str(ipos) ];
%     if exist(strcat(name_mc_pos,'.mat'),'file')
%         load( name_mc_pos );
%     else
%         warning(['no data for run' num2str(ipos)])
%         continue
%     end
%     if exist('mc_traj_data','var')
%        if(mc_all_final(ipos,39)==0)
%             plot(mc_traj_data.sim_vel.Time,mc_traj_data.gdn_vel_cmd.Data(:,3)-mc_traj_data.sim_vel.Data(:,3),'b-');hold on
%        else
%             plot(mc_traj_data.sim_vel.Time,mc_traj_data.gdn_vel_cmd.Data(:,3)-mc_traj_data.sim_vel.Data(:,3),'r-');hold on
%        end          
%     end
%     hold on; grid on;
% end
% title_string = 'Commanded Z-Velocity Error';
% title(title_string,'fontsize',14);set(gcf,'Name',title_string)
% xlabel('Time (sec)','fontsize',14);
% ylabel('Velocity (meters/sec)','fontsize',14);
% saveas(gcf,'CmdZVelErr.png');%saveas(gcf,'CmdZVelErr.fig')
%%
% figure;
% for ipos = 1:mc_n
%     name_mc_pos=[ mc_prefix_s_pos num2str(ipos) ];
%     if exist(strcat(name_mc_pos,'.mat'),'file')
%         load( name_mc_pos );
%     else
%         warning(['no data for run' num2str(ipos)])
%         continue
%     end
%     if exist('mc_traj_data','var')
%        if(mc_all_final(ipos,39)==0)
%             plot(mc_traj_data.gdn_desired_thrust,'b-');hold on
%        else
%             plot(mc_traj_data.gdn_desired_thrust,'r-');hold on
%        end          
%     end
%     hold on; grid on;
% end
% title_string = 'Guidance Desired Thrust';
% title(title_string,'fontsize',14);set(gcf,'Name',title_string)
% xlabel('Time (sec)','fontsize',14);
% ylabel('Force (Newtons)','fontsize',14);
% saveas(gcf,'GdnDesiredThrust.png');%saveas(gcf,'GdnDesiredThrust.fig')
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
title_string = 'Velocity Magnitude vs. Altitude';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Altitude (meters)','fontsize',14);
ylabel('Velocity Magnitude (m/s)','fontsize',14);
saveas(gcf,'VelocityvsAltitude.png');%saveas(gcf,'VelocityvsAltitude.fig')
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
title_string = 'Velocity Magnitude vs. Time';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Time (sec)','fontsize',14);
ylabel('Velocity Magnitude (m/s)','fontsize',14);
saveas(gcf,'VelocityvsTime.png');%saveas(gcf,'VelocityvsTime.fig')

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
title_string = 'Landing Site Relative Position in Topocentric Frame';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel({'Landing Site Relative Topocentric','True X Position (meters)'},'fontsize',14);
ylabel({'Landing Site Relative Topocentric','True Y Position (meters)'},'fontsize',14);
zlabel({'Landing Site Relative Topocentric','True Z Position (meters)'},'fontsize',14);
saveas(gcf,'TruePos3D.png');%saveas(gcf,'TruePos3D.fig')
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
title_string = 'Landing Site Relative Estimated Position in Topocentric Frame';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel({'Landing Site Relative Topocentric','Estimated X Position (meters)'},'fontsize',14);
ylabel({'Landing Site Relative Topocentric','Estimated Y Position (meters)'},'fontsize',14);
zlabel({'Landing Site Relative Topocentric','Estimated Z Position (meters)'},'fontsize',14);
saveas(gcf,'EstPos3D.png');%saveas(gcf,'EstPos3D.fig')
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
% title_string = 'Final Position Error: median over 300 cases';
% title(title_string);set(gcf,'Name',title_string)
% xlabel('Altimeter Percent of Range Error')
% ylabel('Final Position Error (meters)')
% legend('Crossrange','Downrange','Altitude')
% 
% figure; plot(percent_errors*100, median_gnc_pos_all_max(1:end,1:2),'o--'); grid on; hold on;
% plot(percent_errors*100, median_est_vel_all_max(1:end,3),'ro--'); grid on; hold on;
% title_string = 'Final Velocity Error: median over 300 cases';
% title(title_string);set(gcf,'Name',title_string)
% xlabel('Altimeter Percent of Range Error')
% ylabel('Final Velocity Error (m/s)')
% legend('Crossrange','Downrange','Vertical')
% 
% figure; plot(percent_errors*100, median_gnc_pos_all_max(1:end,1:2)+3*std_gnc_pos_all_max(1:end,1:2),'o--'); grid on; 
% hold on; plot(percent_errors*100, median_est_pos_all_max(1:end,3)+3*std_est_pos_all_max(1:end,3),'ro--'); grid on; 
% title_string = 'Final Position Error: median+3std over 300 cases';
% title(title_string);set(gcf,'Name',title_string)
% xlabel('Altimeter Percent of Range Error')
% ylabel('Final Position Error (meters)')
% legend('Crossrange','Downrange','Altitude')
% 
% figure; plot(percent_errors*100, median_gnc_vel_all_max(1:end,1:2)+3*std_gnc_vel_all_max(1:end,1:2),'o--'); grid on; 
% hold on; plot(percent_errors*100, median_est_vel_all_max(1:end,3)+3*std_est_vel_all_max(1:end,3),'ro--'); grid on; 
% title_string = 'Final Velocity Error: median+3std over 300 cases';
% title(title_string);set(gcf,'Name',title_string)
% xlabel('Altimeter Percent of Range Error')
% ylabel('Final Velocity Error (m/s)')
% legend('Crossrange','Downrange','Vertical')
% 
% median_pos = sqrt(median_gnc_pos(:,:,1).^2 +median_gnc_pos(:,:,2).^2);
% std_pos = sqrt(std_gnc_pos(:,:,1).^2 +std_gnc_pos(:,:,2).^2);

% figure; contourf(max_ranges/1000,percent_errors*100, lateral_pos')
% xlabel('Maximum range return (km)')
% ylabel('Altimeter percent of range error (%)')
% title_string = 'GNC lateral landing position error (meters)';
% title(title_string);set(gcf,'Name',title_string)
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
% title_string = 'GNC lateral landing velocity in m/s';
% title(title_string);set(gcf,'Name',title_string)
% colorbar
% set(gcf,'Renderer','painters');
% print(gcf,'-depsc','gnc_vel_contour_2');
% 
% figure; contourf(max_ranges/1000,percent_errors'*100, vertical_pos)
% xlabel('Maximum range return (km)')
% ylabel('Altimeter percent of range error (%)')
% title_string = 'Estimated Altitude Error at Landing';
% title(title_string);set(gcf,'Name',title_string)
% colorbar
% set(gcf,'Renderer','painters');
% print(gcf,'-depsc','gnc_alt_contour_2');
% 
% figure; contourf(max_ranges/1000,percent_errors'*100, vertical_vel)
% xlabel('Maximum range return (km)')
% ylabel('Altimeter percent of range error (%)')
% title_string = 'Vertical Velocity at 1 m : median';
% title(title_string);set(gcf,'Name',title_string)
% colorbar
% set(gcf,'Renderer','painters');
% print(gcf,'-depsc','gnc_vert_vel_contour_2');
% 
% figure; contourf(max_ranges/1000,percent_errors'*100,total_fuel_used)
% xlabel('Maximum range return (km)')
% ylabel('Altimeter percent of range error (%)')
% title_string = 'Fuel Consumed at 1 m : median';
% title(title_string);set(gcf,'Name',title_string)
% colorbar

% set(gcf,'Renderer','painters');
% print(gcf,'-depsc','gnc_fuel_contour_2');

% figure; contourf(max_ranges/1000,percent_errors'*100, n_failure_strict,10)
% xlabel('Maximum range return (km)')
% ylabel('Altimeter percent of range error (%)')
% title_string = 'Number of Failed Runs (10 max)';
% title(title_string);set(gcf,'Name',title_string)
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
