load MC_WORKSPACE
load doi_to_touchdown_mcall.mat
%close all

for kk = 1 : mc_n
    
    %percent_bin = [percent_errors(kk-1) percent_errors(kk)];
    indices{kk} = find(mc_all_initial(:,iin.flr_15k_percent_error) == percent_error); % & mc_all_initial(:,iin.ldr_2k_percent_error) < percent_bin(2));
    
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
   total_fuel_used_scalar(iter)  = total_fuel_used(iter,iter);
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
   altimeter_percent_err(iter) = norm(mc_all_initial(iter,15));
   monoprop_thrust(iter)         = norm(mc_all_initial(iter,83));
   monoprop_isp(iter)            = norm(mc_all_initial(iter,84));
   biprop_thrust(iter)           = norm(mc_all_initial(iter,85));
   biprop_isp(iter)              = norm(mc_all_initial(iter,86));
   mass_estimate_bias(iter)      = norm(mc_all_initial(iter,89));
   initial_htp_mass(iter)        = norm(mc_all_initial(iter,90));
   initial_gn2_mass(iter)        = norm(mc_all_initial(iter,91));
   initial_rp1_mass(iter)        = norm(mc_all_initial(iter,92));
   initial_prop_mass(iter)        = initial_htp_mass(iter) + initial_rp1_mass(iter)  + initial_gn2_mass(iter) ;
   lateral_est_vel_scalar(iter)  = norm(mc_all_final(iter,5:6),2);
   vertical_est_vel_scalar(iter) = abs(mc_all_final(iter,7));
   vertical_est_vel(iter)            = mc_all_final(iter,7);
   lateral_gnc_pos_scalar(iter)  = norm(mc_all_final(iter,15:16),2);
   lateral_gnc_vel_scalar(iter)  = norm(mc_all_final(iter,18:19),2);
   vertical_gnc_pos_scalar(iter) = mc_all_final(iter,17);
   vertical_gnc_vel_scalar(iter) = abs(mc_all_final(iter,20));
   vertical_gnc_vel(iter)          = mc_all_final(iter,20);
   final_est_vert_pos_err(iter)  = abs(mc_all_final(iter,14));
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
   htp_used(iter) = mc_all_final(iter,43);
   gn2_used(iter) = mc_all_final(iter,44);
   rp1_used(iter) = mc_all_final(iter,45);
   final_mass(iter) = mc_all_final(iter,46);
   max_misalignment_ang(iter) = max(abs(mc_all_initial(iter,80)));
   max_misalignment_az(iter) = max(abs(mc_all_initial(iter,50)));

   if mc_all_final(iter,39)==0 %% && total_fuel_used_scalar(iter) > mean_fuel_used - half_sigma_fuel_dispersion
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

lateral_gnc_pos_scalar_limit  = 15000.0;
lateral_gnc_vel_scalar_limit  = 5.0;
lateral_est_vel_scalar_limit  = 5.0;
final_est_vert_pos_err_limit  = 10.0;
final_gnc_vert_vel_err_limit  = 4.0;
vertical_est_vel_scalar_limit = 1.5;
final_gnc_ang_err_limit       = 15.0;
final_gnc_rate_err_limit      = 25.0;
htp_mass_initial = evalin('base','mpl_htp_mass_initial');
rp1_mass_initial = evalin('base','mpl_rp1_mass_initial');
gn2_mass_initial = evalin('base','mpl_gn2_mass_initial');

lateral_gnc_pos_scalar_limit_cases  = int2str( find(lateral_gnc_pos_scalar   > lateral_gnc_pos_scalar_limit  ));
lateral_gnc_vel_scalar_limit_cases  = int2str( find(lateral_gnc_vel_scalar   > lateral_gnc_vel_scalar_limit  ));
lateral_est_vel_scalar_limit_cases  = int2str( find(lateral_est_vel_scalar   > lateral_est_vel_scalar_limit  ));
final_est_vert_pos_err_limit_cases  = int2str( find(final_est_vert_pos_err   > final_est_vert_pos_err_limit  ));
final_gnc_vert_vel_err_limit_cases  = int2str( find(vertical_gnc_vel_scalar  > final_gnc_vert_vel_err_limit  ));
vertical_est_vel_scalar_limit_cases = int2str( find(vertical_est_vel_scalar  > vertical_est_vel_scalar_limit ));
final_gnc_ang_err_limit_cases       = int2str( find(final_gnc_ang_err        > final_gnc_ang_err_limit       ));
final_gnc_rate_err_limit_cases      = int2str( find(final_gnc_rate_err       > final_gnc_rate_err_limit      ));
htp_depletion_cases                 = int2str( find(mc_all_final(:,43)'     >= mc_all_initial(:,90)'         ));
gn2_depletion_cases                 = int2str( find(mc_all_final(:,44)'     >= mc_all_initial(:,91)'         ));
rp1_depletion_cases                 = int2str( find(mc_all_final(:,45)'     >= mc_all_initial(:,92)'         ));

%%
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
   fprintf('HTP depletion                       = %3d   ',length(find(mc_all_final(:,43)         >= mc_all_initial(:,90))) )
   if size(htp_depletion_cases,2)>0                ,fprintf('case numbers = %s\n',htp_depletion_cases(:))                ,else fprintf('\n'),end
   fprintf('GN2 depletion                       = %3d   ',length(find(mc_all_final(:,44)         >= mc_all_initial(:,91))) )
   if size(gn2_depletion_cases,2)>0                ,fprintf('case numbers = %s\n',gn2_depletion_cases(:))                ,else fprintf('\n'),end
   fprintf('RP1 depletion                       = %3d   ',length(find(mc_all_final(:,45)         >= mc_all_initial(:,92))) )
   if size(rp1_depletion_cases,2)>0                ,fprintf('case numbers = %s\n',rp1_depletion_cases(:))                ,else fprintf('\n'),end
end


%%
figure;plot(mc_all_final(:,1),Success,'*');grid on
title_string = 'Pass / Fail';
title(title_string);
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
xlabel('Touchdown Guidance and Control Horizontal Position Error')
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
figure;plot(initial_est_pos_err,Success,'*');grid on
title_string = 'Landing Success vs Initial Estimated Position Error';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(initial_est_pos_err_success,20);grid on
    title_string = 'Initial Estimated Position Error to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Initial Estimated Position Error (meters)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistInitEstPosErrSucc.png');%saveas(gcf,'HistInitEstPosErrSucc.fig')
end
if exist('initial_est_pos_err_fail')==1
    figure;hist(initial_est_pos_err_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Initial Estimated Position Error to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Initial Estimated Position Error (meters)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistInitEstPosErrFail.png');%saveas(gcf,'HistInitEstPosErrFail.fig')
end
%%
figure;plot(initial_est_vel_err,Success,'*');grid on
title_string = 'Landing Success vs Initial Estimated Velocity Error';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(initial_est_vel_err_success,20);grid on
    title_string = 'Initial Estimated Velocity Error to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Initial Estimated Velocity Error (m/s)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistInitEstVelErrSucc.png');%saveas(gcf,'HistInitEstVelErrSucc.fig')
end
if exist('initial_est_vel_err_fail')==1
    figure;hist(initial_est_vel_err_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Initial Estimated Velocity Error to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Initial Estimated Velocity Error (m/s)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistInitEstVelFail.png');%saveas(gcf,'HistInitEstVelFail.fig')
end
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
figure;plot(mc_all_initial(:,15)*100,Success,'*');grid on
title_string = 'Landing Success vs Altimeter Percent Error';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(altimeter_percent_err_success,20);grid on 
    title_string = 'Altimeter Percent Error to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Altimeter Percent Error (%)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistAltErrorSucc.png');%saveas(gcf,'HistAltErrorSucc.fig');
end
if exist('altimeter_percent_err_fail')==1
    figure;hist(altimeter_percent_err_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Altimeter Percent Error to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Altimeter Percent Error (%)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistAltErrorFail.png');%saveas(gcf,'HistAltErrorFail.fig')
end
%%
figure;plot(mc_all_initial(:,16),Success,'*');grid on
title_string = 'Landing Success vs Altimeter Maximum Range';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(altimeter_max_range_success,20);grid on 
    title_string = 'Altimeter Maximum Range to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Altimeter Maximum Range (meters)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistAltMaxRangeSucc.png');%saveas(gcf,'HistAltMaxRangeSucc.fig')
end
if exist('altimeter_max_range_fail')==1
    figure;hist(altimeter_max_range_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Altimeter Maximum Range to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Altimeter Maximum Range (meters)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistAltMaxRangeFail.png');%saveas(gcf,'HistAltMaxRangeFail.fig')
end
%%
figure;plot(mc_all_initial(:,17)*3600,Success,'*');grid on
title_string = 'Landing Success vs Star Tracker Noise';
title(title_string);set(gcf,'Name',title_string)
xlabel('Star Tracker Noise (arc-sec)')
ylabel('Success=1 Fail=0') 
axis([-1 +1 -1 +2]); axis('auto x') 
isuccess = 0;ifail = 0; clear star_tracker_noise_fail star_tracker_noise_success 
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        star_tracker_noise_success(isuccess) = mc_all_initial(itest,17)*(180/pi)*3600;
    else
        ifail = ifail + 1;
        star_tracker_noise_fail(ifail) = mc_all_initial(itest,17)*(180/pi)*3600;
    end
end
if exist('star_tracker_noise_success')==1
    figure;hist(star_tracker_noise_success,20);grid on 
    title_string = 'Star Tracker Noise to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Star Tracker Noise (arc-sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistTrkrNoiseSucc.png');%saveas(gcf,'HistTrkrNoiseSucc.fig')
end
if exist('star_tracker_noise_fail')==1
    figure;hist(star_tracker_noise_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Star Tracker Noise to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Star Tracker Noise (arc-sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistTrkrNoiseFail.png');%saveas(gcf,'HistTrkrNoiseFail.fig')
end
%%
figure;plot(mc_all_initial(:,18),Success,'*');grid on
title_string = 'Landing Success vs Camera Integration Time';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(camera_integration_time_success,20);grid on 
    title_string = 'Camera Integration Time to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Camera Integration Time (sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistCamDtSucc.png');%saveas(gcf,'HistCamDtSucc.fig')
end
if exist('camera_integration_time_fail')==1
    figure;hist(camera_integration_time_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Camera Integration Time to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Camera Integration Time (sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistCamDtFail.png');%saveas(gcf,'HistCamDtFail.fig')
end
%%
figure;plot(mc_all_initial(:,19),Success,'*');grid on
title_string = 'Landing Success vs Camera Focal Length';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(camera_focal_length_success,20);grid on
    title_string = 'Camera Focal Length to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Camera Focal Length (meters)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistFocalSucc.png');%saveas(gcf,'HistFocalSucc.fig')
end
if exist('camera_focal_length_fail')==1
    figure;hist(camera_focal_length_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Camera Focal Length to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Camera Focal Length (meters)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistFocalFail.png');%saveas(gcf,'HistFocalFail.fig')
end
%%
figure;plot(mc_all_initial(:,20)*180/pi,Success,'*');grid on
title_string = 'Landing Success vs Camera Angular Field of View';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(camera_aov_success,20);grid on 
    title_string = 'Camera Angular Field of View to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Camera Angular Field of View (deg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    %saveas(gcf,'HistCamAOVSucc.png');%saveas(gcf,'HistCamAOVSucc.fig')
end
if exist('camera_aov_fail')==1
    figure;hist(camera_aov_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Camera Angular Field of View to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Camera Angular Field of View (deg)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    %saveas(gcf,'HistCamAOVFail.png');%saveas(gcf,'HistCamAOVFail.fig')
end
%%
figure;plot(mc_all_initial(:,21),Success,'*');grid on
title_string = 'Landing Success vs Image Delta-T';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(camera_delta_t_success,20);grid on 
    title_string = 'Camera Delta-T to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Camera Delta-T (sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistProcDtSucc.png');%saveas(gcf,'HistProcDtSucc.fig')
end
if exist('camera_delta_t_fail')==1
    figure;hist(camera_delta_t_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Camera Delta-T to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Camera Delta-T (sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistProcDtFail.png');%saveas(gcf,'HistProcDtFail.fig')
end
%%
figure;plot(mc_all_initial(:,22)*1e6,Success,'*');grid on
title_string = 'Landing Success vs Camera Processing Delay';
title(title_string);set(gcf,'Name',title_string)
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
    figure;hist(camera_processing_delay_success,20);grid on 
    title_string = 'Camera Processing Delay to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Camera Processing Delay (sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistCamProcDelaySucc.png');%saveas(gcf,'HistCamProcDelaySucc.fig')
end
if exist('camera_processing_delay_fail')==1
    figure;hist(camera_processing_delay_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Camera Processing Delay to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Camera Processing Delay (sec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistCamProcDelayFail.png');%saveas(gcf,'HistCamProcDelayFail.fig')
end
%%
figure;plot(htp_mass,Success,'*');grid on
title_string = 'Landing Success vs Initial HTP Mass';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Initial HTP Mass','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
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
figure;plot(rp1_mass,Success,'*');grid on
title_string = 'Landing Success vs Initial RP1 Mass';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Initial RP1 Mass','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
isuccess = 0;ifail = 0;clear rp1_mass_fail rp1_mass_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        rp1_mass_success(isuccess) = rp1_mass(itest);
    else
        ifail = ifail + 1;
        rp1_mass_fail(ifail) = rp1_mass(itest);
    end
end
if exist('rp1_mass_success')==1
    figure;hist(rp1_mass_success,20);grid on
    title_string = 'Initial RP1 Mass to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Initial RP1 Mass','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistRp1MassSucc.png');%saveas(gcf,'HistRp1MassSucc.fig')
end
if exist('rp1_mass_fail')==1
    figure;hist(rp1_mass_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Initial RP1 Mass to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Initial RP1 Mass','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistRp1MassFail.png');%saveas(gcf,'HistRp1MassFail.fig')
end
%%
figure;plot(lateral_cg_dry_offset*1e3,Success,'*');grid on
title_string = 'Landing Success vs Dry Lander CG Offset';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
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
xlabel('Lateral Offset (millimeters)')
ylabel('Success=1 Fail=0')
axis([-1 +1 -1 +2]);axis('auto x')
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
% figure;plot(monoprop_thrust,Success,'*');grid on
% title_string = 'Landing Success vs Monoprop Thrust Performance';
% title(title_string,'fontsize',14);set(gcf,'Name',title_string)
% xlabel('Monoprop Thrust','fontsize',14)
% ylabel('Success=1 Fail=0','fontsize',14)
% axis([-1 +1 -1 +2]);axis('auto x')
% saveas(gcf,'MonoPropThrustSuccFail.png')
% isuccess = 0;ifail = 0;clear monoprop_thrust_fail monoprop_thrust_success
% for itest =1:size(mc_all_initial,1)
%     if Success(itest) == 1
%         isuccess = isuccess + 1;
%         monoprop_thrust_success(isuccess) = monoprop_thrust(itest);
%     else
%         ifail = ifail + 1;
%         monoprop_thrust_fail(ifail) = monoprop_thrust(itest);
%     end
% end
% if exist('monoprop_thrust_success')==1
%     figure;hist(monoprop_thrust_success,20);grid on
%     title_string = 'Monoprop Thrust Performance to Landing Success';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Monoprop Thrust','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     %saveas(gcf,'HistMonoPropThrustSucc.png');%saveas(gcf,'HistMonoPropThrustSucc.fig')
% end
% if exist('monoprop_thrust_fail')==1
%     figure;hist(monoprop_thrust_fail,20);grid on
%     h = findobj(gca,'Type','patch');
%     set(h,'FaceColor','r')
%     title_string = 'Monoprop Thrust Performance to Landing Failure';
%     title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
%     xlabel('Monoprop Thrust','fontsize',14)
%     ylabel('Number of Cases','fontsize',14)
%     %saveas(gcf,'HistMonoPropThrustFail.png');%saveas(gcf,'HistMonoPropThrustFail.fig')
% end
% 
%%
figure;plot(monoprop_isp,Success,'*');grid on
title_string = 'Landing Success vs Monoprop Isp Performance';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Monoprop Isp','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'MonoPropIspSuccFail.png')
isuccess = 0;ifail = 0;clear monoprop_isp_fail monoprop_isp_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        monoprop_isp_success(isuccess) = monoprop_isp(itest);
    else
        ifail = ifail + 1;
        monoprop_isp_fail(ifail) = monoprop_isp(itest);
    end
end
if exist('monoprop_isp_success')==1
    figure;hist(monoprop_isp_success,20);grid on
    title_string = 'Monoprop Isp Performance to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Monoprop Isp','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    %saveas(gcf,'HistMonoPropIspSucc.png');%saveas(gcf,'HistMonoPropIspSucc.fig')
end
if exist('monoprop_isp_fail')==1
    figure;hist(monoprop_isp_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Monoprop Isp Performance to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Monoprop Isp','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    %saveas(gcf,'HistMonoPropIspFail.png');%saveas(gcf,'HistMonoPropIspFail.fig')
end
%%
figure;plot(biprop_thrust,Success,'*');grid on
title_string = 'Landing Success vs Biprop Thrust Performance';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Biprop Thrust','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'BiPropThrustSuccFail.png')
isuccess = 0;ifail = 0;clear biprop_thrust_fail biprop_thrust_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        biprop_thrust_success(isuccess) = biprop_thrust(itest);
    else
        ifail = ifail + 1;
        biprop_thrust_fail(ifail) = biprop_thrust(itest);
    end
end
if exist('biprop_thrust_success')==1
    figure;hist(biprop_thrust_success,20);grid on
    title_string = 'Biprop Thrust Performance to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Biprop Thrust','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistBiPropThrustSucc.png');%saveas(gcf,'HistBiPropThrustSucc.fig')
end
if exist('biprop_thrust_fail')==1
    figure;hist(biprop_thrust_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Biprop Thrust Performance to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Biprop Thrust','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistBiPropThrustFail.png');%saveas(gcf,'HistBiPropThrustFail.fig')
end

%%
figure;plot(biprop_isp,Success,'*');grid on
title_string = 'Landing Success vs Biprop Isp Performance';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Biprop Isp','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'BiPropIspSuccFail.png')
isuccess = 0;ifail = 0;clear biprop_isp_fail biprop_isp_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        biprop_isp_success(isuccess) = biprop_isp(itest);
    else
        ifail = ifail + 1;
        biprop_isp_fail(ifail) = biprop_isp(itest);
    end
end
if exist('biprop_isp_success')==1
    figure;hist(biprop_isp_success,20);grid on
    title_string = 'Biprop Isp Performance to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Biprop Isp','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistBiPropIspSucc.png');%saveas(gcf,'HistBiPropIspSucc.fig')
end
if exist('biprop_isp_fail')==1
    figure;hist(biprop_isp_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Biprop Isp Performance to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Biprop Isp','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistBiPropIspFail.png');%saveas(gcf,'HistBiPropIspFail.fig')
end
%%
figure;plot(biprop_start_delay,Success,'*');grid on
title_string = 'Landing Success vs Main Engine Start Delay';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Main Engine Start Delay (msec)','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'MainStartDelaySuccFail.png')
isuccess = 0;ifail = 0;clear start_delay_fail start_delay_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        start_delay_success(isuccess) = biprop_start_delay(itest);
    else
        ifail = ifail + 1;
        start_delay_fail(ifail) = biprop_start_delay(itest);
    end
end
if exist('start_delay_success')==1
    figure;hist(start_delay_success,20);grid on
    title_string = 'Main Engine Start Delay to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Main Engine Start Delay (msec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistMainStartDelaySucc.png');%saveas(gcf,'HistMainStartDelaySucc.fig')
end
if exist('start_delay_fail')==1
    figure;hist(start_delay_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Main Engine Start Delay to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Main Engine Start Delay (msec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistMainStartDelayFail.png');%saveas(gcf,'HistMainStartDelayFail.fig')
end
%%
figure;plot(biprop_stop_delay,Success,'*');grid on
title_string = 'Landing Success vs Main Engine Stop Delay';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Main Engine Stop Delay (msec)','fontsize',14)
ylabel('Success=1 Fail=0','fontsize',14)
axis([-1 +1 -1 +2]);axis('auto x')
saveas(gcf,'MainStopDelaySuccFail.png')
isuccess = 0;ifail = 0;clear stop_delay_fail stop_delay_success
for itest =1:size(mc_all_initial,1)
    if Success(itest) == 1
        isuccess = isuccess + 1;
        stop_delay_success(isuccess) = biprop_stop_delay(itest);
    else
        ifail = ifail + 1;
        stop_delay_fail(ifail) = biprop_stop_delay(itest);
    end
end
if exist('stop_delay_success')==1
    figure;hist(stop_delay_success,20);grid on
    title_string = 'Main Engine Stop Delay to Landing Success';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Main Engine Fire Time Bias (msec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistMainStopDelaySucc.png');%saveas(gcf,'HistMainStopDelaySucc.fig')
end
if exist('stop_delay_fail')==1
    figure;hist(stop_delay_fail,20);grid on
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r')
    title_string = 'Main Engine Stop Delay to Landing Failure';
    title(title_string,'fontsize',14);set(gcf,'Name',sprintf('Histogram : %s',title_string))
    xlabel('Main Engine Stop Delay (msec)','fontsize',14)
    ylabel('Number of Cases','fontsize',14)
    saveas(gcf,'HistMainStopDelayFail.png');%saveas(gcf,'HistMainStopDelayFail.fig')
end
%%
% figure;grid on;hold on;
% for itest=1:size(mc_all_final,1)
%  if(mc_all_final(itest,39)==0)
%      plot(monoprop_thrust(itest),vertical_gnc_vel_scalar(itest),'b*');text(monoprop_thrust(itest),vertical_gnc_vel_scalar(itest),strcat('   ',num2str(itest)),'Color','b');
%  elseif(mc_all_final(itest,39)==1)
%      plot(monoprop_thrust(itest),vertical_gnc_vel_scalar(itest),'r*');text(monoprop_thrust(itest),vertical_gnc_vel_scalar(itest),strcat('   ',num2str(itest)),'Color','r');
%  end
% end
% title_string = 'Monoprop Thrust Performance vs Touchdown Vertical Velocity';
% title(title_string,'fontsize',14);set(gcf,'Name',title_string)
% xlabel('Monoprop Thrust','fontsize',14)
% ylabel('Topocentric Vertical Velocity (m/s)','fontsize',14)
% saveas(gcf,'VerticalVelandMonoPropThrust.png');saveas(gcf,'VerticalVelandMonoPropThrust.fig')

%%
% figure;grid on;hold on;
% for itest=1:size(mc_all_final,1)
%  if(mc_all_final(itest,39)==0)
%      plot(monoprop_isp(itest),vertical_gnc_vel_scalar(itest),'b*');text(monoprop_isp(itest),vertical_gnc_vel_scalar(itest),strcat('   ',num2str(itest)),'Color','b');
%  elseif(mc_all_final(itest,39)==1)
%      plot(monoprop_isp(itest),vertical_gnc_vel_scalar(itest),'r*');text(monoprop_isp(itest),vertical_gnc_vel_scalar(itest),strcat('   ',num2str(itest)),'Color','r');
%  end
% end
% title_string = 'Monoprop Isp Performance vs Touchdown Vertical Velocity';
% title(title_string,'fontsize',14);set(gcf,'Name',title_string)
% xlabel('Monoprop Isp','fontsize',14)
% ylabel('Topocentric Vertical Velocity (m/s)','fontsize',14)
% saveas(gcf,'VerticalVelandMonoPropIsp.png');saveas(gcf,'VerticalVelandMonoPropIsp.fig')

%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(lateral_gnc_vel_scalar(itest),abs(mc_all_final(itest,20)),'b*');text(lateral_gnc_vel_scalar(itest),abs(mc_all_final(itest,20)),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(lateral_gnc_vel_scalar(itest),abs(mc_all_final(itest,20)),'r*');text(lateral_gnc_vel_scalar(itest),abs(mc_all_final(itest,20)),strcat('   ',num2str(itest)),'Color','r');
 end
end
 hold on;
title_string = 'Touchdown Lateral Velocity vs Vertical Velocity';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Topocentric Lateral Velocity (m/s)','fontsize',14)
ylabel('Topocentric Vertical Velocity (m/s)','fontsize',14)
str_text_box = {sprintf('Lateral Velocity Error Spec= %9.2f m/s',lateral_gnc_vel_scalar_limit),sprintf('Vertical Velocity Error Spec = %9.2f m/s',final_gnc_vert_vel_err_limit)};
annotation('textbox',[.3 .8 .55 .10],'string',str_text_box) 
lateral_gnc_vel_scalar_limit_x = lateral_gnc_vel_scalar_limit*ones(1,100);
final_gnc_vert_vel_err_limit_y = final_gnc_vert_vel_err_limit*ones(1,100);
plot(lateral_gnc_vel_scalar_limit_x,0.01*[1:100].*final_gnc_vert_vel_err_limit_y,'r-','linewidth',2);
plot(0.01*[1:100].*lateral_gnc_vel_scalar_limit_x,final_gnc_vert_vel_err_limit_y,'r-','linewidth',2);
saveas(gcf,'LateralVelandVerticalVel.png');saveas(gcf,'LateralVelandVerticalVel.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(lateral_gnc_vel_scalar(itest),lateral_gnc_pos_scalar(itest),'b*');text(lateral_gnc_vel_scalar(itest),lateral_gnc_pos_scalar(itest),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(lateral_gnc_vel_scalar(itest),lateral_gnc_pos_scalar(itest),'r*');text(lateral_gnc_vel_scalar(itest),lateral_gnc_pos_scalar(itest),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Touchdown Lateral Velocity vs Lateral Position';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Topocentric Lateral Velocity (m/s)','fontsize',14)
ylabel('Topocentric Lateral Position (m)','fontsize',14)
str_text_box = {sprintf('Lateral Velocity Error Spec= %9.2f m/s',lateral_gnc_vel_scalar_limit),sprintf('Lateral Position Error Spec = %9.2f m/s',lateral_gnc_pos_scalar_limit)};
annotation('textbox',[.3 .8 .55 .10],'string',str_text_box) 
lateral_gnc_vel_scalar_limit_x = lateral_gnc_vel_scalar_limit*ones(1,100);
lateral_gnc_pos_scalar_limit_y = lateral_gnc_pos_scalar_limit*ones(1,100);
plot(lateral_gnc_vel_scalar_limit_x,0.01*[1:100].*lateral_gnc_pos_scalar_limit_y,'r-','linewidth',2);
plot(0.01*[1:100].*lateral_gnc_vel_scalar_limit_x,lateral_gnc_pos_scalar_limit_y,'r-','linewidth',2);
saveas(gcf,'LateralVelandPosErr.png');saveas(gcf,'LateralVelandPosErr.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(lateral_cg_wet_offset(itest)*1e3,lateral_gnc_vel_scalar(itest),'b*');text(lateral_cg_wet_offset(itest)*1e3,lateral_gnc_vel_scalar(itest),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(lateral_cg_wet_offset(itest)*1e3,lateral_gnc_vel_scalar(itest),'r*');text(lateral_cg_wet_offset(itest)*1e3,lateral_gnc_vel_scalar(itest),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Lateral Center of Mass Offset vs Touchdown Lateral Velocity';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Lateral Center of Mass Offset (mm)','fontsize',14)
ylabel('Topocentric Lateral Velocity (m/s)','fontsize',14)
str_text_box = {sprintf('Lateral Velocity Error Spec= %9.2f m/s',lateral_gnc_vel_scalar_limit)};
annotation('textbox',[.3 .8 .55 .10],'string',str_text_box) 
lateral_gnc_vel_scalar_limit_y = lateral_gnc_vel_scalar_limit*ones(1,100);
plot(0.01*[1:100]*max(lateral_cg_wet_offset)*1000,lateral_gnc_vel_scalar_limit_y,'r-','linewidth',2);
saveas(gcf,'LateralCMandLateralVel.png');saveas(gcf,'LateralCMandLateralVel.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(cm_az_deg(itest),lateral_gnc_vel_scalar(itest),'b*');text(cm_az_deg(itest),lateral_gnc_vel_scalar(itest),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(cm_az_deg(itest),lateral_gnc_vel_scalar(itest),'r*');text(cm_az_deg(itest),lateral_gnc_vel_scalar(itest),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Lateral Center of Mass Offset Azimuth vs Lateral Touchdown Velocity';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Lateral Center of Mass Offset Azimuth (deg)','fontsize',14)
ylabel('Topocentric Lateral Velocity (m/s)','fontsize',14)
str_text_box = {sprintf('Lateral Velocity Error Spec= %9.2f m/s',lateral_gnc_vel_scalar_limit)};
annotation('textbox',[.3 .8 .55 .10],'string',str_text_box) 
lateral_gnc_vel_scalar_limit_y = lateral_gnc_vel_scalar_limit*ones(1,100);
plot(0.01*[1:100]*max(cm_az_deg),lateral_gnc_vel_scalar_limit_y,'r-','linewidth',2);
saveas(gcf,'LateralCMAzimuthandLateralVel.png');saveas(gcf,'LateralCMAzimuthandLateralVel.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(norm(mc_all_final(itest,21:22)),norm(mc_all_final(itest,24:25)),'b*');text(norm(mc_all_final(itest,21:22)),norm(mc_all_final(itest,24:25)),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(norm(mc_all_final(itest,21:22)),norm(mc_all_final(itest,24:25)),'r*');text(norm(mc_all_final(itest,21:22)),norm(mc_all_final(itest,24:25)),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Touchdown Angle vs Body Rate';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Angle From Vertical (deg)','fontsize',14)
ylabel('Body Rate (deg/s)','fontsize',14)
str_text_box = {sprintf('Touchdown Angle Error Spec= %9.2f deg',final_gnc_ang_err_limit),sprintf('Touchdown Angular Rate Error Spec = %9.2f deg/sec',final_gnc_rate_err_limit)};
annotation('textbox',[.15, .8 .70 .10],'string',str_text_box) 
final_gnc_ang_err_limit_x = final_gnc_ang_err_limit*ones(1,100);
final_gnc_rate_err_limit_y = final_gnc_rate_err_limit*ones(1,100);
plot(final_gnc_ang_err_limit_x,0.01*[1:100].*final_gnc_rate_err_limit_y,'r-','linewidth',2);
plot(0.01*[1:100].*final_gnc_ang_err_limit_x,final_gnc_rate_err_limit_y,'r-','linewidth',2);
saveas(gcf,'TDAngleVsRate.png');saveas(gcf,'TDAngleVsRate.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(norm(mc_all_final(itest,21:22)),lateral_gnc_vel_scalar(itest),'b*');text(norm(mc_all_final(itest,21:22)),lateral_gnc_vel_scalar(itest),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(norm(mc_all_final(itest,21:22)),lateral_gnc_vel_scalar(itest),'r*');text(norm(mc_all_final(itest,21:22)),lateral_gnc_vel_scalar(itest),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Touchdown Angle vs Lateral Velocity';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Angle From Vertical (deg)','fontsize',14)
ylabel('Topocentric Lateral Velocity (m/s)','fontsize',14)
str_text_box = {sprintf('Touchdown Angle Error Spec= %9.2f deg',final_gnc_ang_err_limit),sprintf('Touchdown Lateral Velocity Error Spec = %9.2f m/s',lateral_gnc_vel_scalar_limit)};
annotation('textbox',[.15, .8 .70 .10],'string',str_text_box) 
final_gnc_ang_err_limit_x = final_gnc_ang_err_limit*ones(1,100);
lateral_gnc_vel_scalar_limit_y = lateral_gnc_vel_scalar_limit*ones(1,100);
plot(final_gnc_ang_err_limit_x,0.01*[1:100].*lateral_gnc_vel_scalar_limit_y,'r-','linewidth',2);
plot(0.01*[1:100].*final_gnc_ang_err_limit_x,lateral_gnc_vel_scalar_limit_y,'r-','linewidth',2);
saveas(gcf,'TDAngleandLateralVel.png');saveas(gcf,'TDAngleandLateralVel.fig')

%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(initial_htp_mass(itest),htp_used(itest),'b*');text(initial_htp_mass(itest),htp_used(itest),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(initial_htp_mass(itest),htp_used(itest),'r*');text(initial_htp_mass(itest),htp_used(itest),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Initial HTP vs. Used HTP';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('HTP Initial (kg)','fontsize',14)
ylabel('HTP Consumed (kg)','fontsize',14)
%str_text_box = {sprintf('Maximum Prop Available = %9.2f kg',(htp_mass_initial+rp1_mass_initial+gn2_mass_initial))};
%annotation('textbox',[.15, .8 .70 .10],'string',str_text_box) 
%lateral_gnc_pos_scalar_limit_y = lateral_gnc_pos_scalar_limit*ones(1,100);
%plot(0.01*[0:100].*max(lateral_cg_wet_offset)*1000,ones(1,101).*(htp_mass_initial+rp1_mass_initial+gn2_mass_initial),'r-','linewidth',2);
saveas(gcf,'HTPInitiaUsed.png');saveas(gcf,'HTPInitialUsed.fig')

%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(lateral_cg_wet_offset(itest)*1e3,lateral_gnc_pos_scalar(itest),'b*');text(lateral_cg_wet_offset(itest)*1e3,lateral_gnc_pos_scalar(itest),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(lateral_cg_wet_offset(itest)*1e3,lateral_gnc_pos_scalar(itest),'r*');text(lateral_cg_wet_offset(itest)*1e3,lateral_gnc_pos_scalar(itest),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Lateral Center of Mass Offset vs Lateral Position';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Lateral Center of Mass Offset (mm)','fontsize',14)
ylabel('Topocentric Lateral Position (m)','fontsize',14)
str_text_box = {sprintf('Touchdown Lateral Position Error Spec = %9.2f m',lateral_gnc_pos_scalar_limit)};
annotation('textbox',[.15, .8 .70 .10],'string',str_text_box) 
lateral_gnc_pos_scalar_limit_y = lateral_gnc_pos_scalar_limit*ones(1,100);
plot(0.01*[1:100].*max(lateral_cg_wet_offset)*1000,ones(1,100).*lateral_gnc_pos_scalar_limit_y,'r-','linewidth',2);
saveas(gcf,'LateralMassOffsetandPosErr.png');
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(cm_az_deg(itest),lateral_gnc_pos_scalar(itest),'b*');text(cm_az_deg(itest),lateral_gnc_pos_scalar(itest),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(cm_az_deg(itest),lateral_gnc_pos_scalar(itest),'r*');text(cm_az_deg(itest),lateral_gnc_pos_scalar(itest),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Lateral Center of Mass Offset Azimuth vs Touchdown Lateral Position';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Lateral Center of Mass Offset Azimuth (deg)','fontsize',14)
ylabel('Touchdown Lateral Position (m)','fontsize',14)
str_text_box = {sprintf('Touchdown Lateral Position Error Spec = %9.2f m',lateral_gnc_pos_scalar_limit)};
annotation('textbox',[.15, .8 .70 .10],'string',str_text_box) 
lateral_gnc_pos_scalar_limit_y = lateral_gnc_pos_scalar_limit*ones(1,100);
plot(0.01*[1:100].*max(cm_az_deg),ones(1,100).*lateral_gnc_pos_scalar_limit_y,'r-','linewidth',2);
saveas(gcf,'LateralCMAzimuthandPosErr.png');saveas(gcf,'LateralCMAzimuthandPosErr.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(lateral_cg_wet_offset(itest)*1e3,total_fuel_used_scalar(itest),'b*');text(lateral_cg_wet_offset(itest)*1e3,total_fuel_used_scalar(itest),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(lateral_cg_wet_offset(itest)*1e3,total_fuel_used_scalar(itest),'r*');text(lateral_cg_wet_offset(itest)*1e3,total_fuel_used_scalar(itest),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Lateral Center of Mass Offset vs Propellant Usage';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Lateral Center of Mass Offset (mm)','fontsize',14)
ylabel('Propellant Usage (kg)','fontsize',14)
str_text_box = {sprintf('Maximum Prop Available = %9.2f kg',(htp_mass_initial+rp1_mass_initial+gn2_mass_initial))};
annotation('textbox',[.15, .8 .70 .10],'string',str_text_box) 
lateral_gnc_pos_scalar_limit_y = lateral_gnc_pos_scalar_limit*ones(1,100);
plot(0.01*[0:100].*max(lateral_cg_wet_offset)*1000,ones(1,101).*(htp_mass_initial+rp1_mass_initial+gn2_mass_initial),'r-','linewidth',2);
saveas(gcf,'LateralCMandPropUsed.png');saveas(gcf,'LateralCMandPropUsed.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(cm_az_deg(itest),total_fuel_used_scalar(itest),'b*');text(cm_az_deg(itest),total_fuel_used_scalar(itest),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(cm_az_deg(itest),total_fuel_used_scalar(itest),'r*');text(cm_az_deg(itest),total_fuel_used_scalar(itest),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Lateral Center of Mass Offset Azimuth vs Propellant Usage';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Lateral Center of Mass Offset Azimuth (deg)','fontsize',14)
ylabel('Propellant Usage (kg)','fontsize',14)
str_text_box = {sprintf('Maximum Prop Available = %9.2f kg',(htp_mass_initial+rp1_mass_initial+gn2_mass_initial))};
annotation('textbox',[.15, .8 .70 .10],'string',str_text_box) 
plot(0.01*[0:100].*max(cm_az_deg),ones(1,101).*(htp_mass_initial+rp1_mass_initial+gn2_mass_initial),'r-','linewidth',2);
saveas(gcf,'LateralCMAzimuthandPropUsed.png');saveas(gcf,'LateralCMAzimuthandPropUsed.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(vertical_est_vel_scalar(itest),total_fuel_used_scalar(itest),'b*');text(vertical_est_vel_scalar(itest),total_fuel_used_scalar(itest),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(vertical_est_vel_scalar(itest),total_fuel_used_scalar(itest),'r*');text(vertical_est_vel_scalar(itest),total_fuel_used_scalar(itest),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Vertical Velocity Estimation Error vs Propellant Usage';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Vertical Velocity Estimation Error (m/s)','fontsize',14)
ylabel('Propellant Usage (kg)','fontsize',14)
str_text_box = {sprintf('Vertical Velocity Estimation Error Spec= %9.2f deg',vertical_est_vel_scalar_limit),sprintf('Maximum Prop Available = %9.2f kg',(htp_mass_initial+rp1_mass_initial+gn2_mass_initial))};
annotation('textbox',[.15, .8 .70 .10],'string',str_text_box) 
vertical_est_vel_scalar_limit_x = vertical_est_vel_scalar_limit*ones(1,100);
initial_mass_limit_y = (htp_mass_initial+rp1_mass_initial+gn2_mass_initial)*ones(1,100);
plot(vertical_est_vel_scalar_limit_x,0.01*[1:100].*initial_mass_limit_y,'r-','linewidth',2);
plot(0.01*[1:100].*vertical_est_vel_scalar_limit_x,initial_mass_limit_y,'r-','linewidth',2);
saveas(gcf,'VertVelEstErrandPropUsed.png');saveas(gcf,'VertVelEstErrandPropUsed.fig')

%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(vertical_est_vel_scalar(itest),altimeter_percent_err(itest)*max_range_mean,'b*');text(vertical_est_vel_scalar(itest),altimeter_percent_err(itest)*max_range_mean,strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(vertical_est_vel_scalar(itest),altimeter_percent_err(itest)*max_range_mean,'r*');text(vertical_est_vel_scalar(itest),altimeter_percent_err(itest)*max_range_mean,strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Vertical Velocity Estimation Error vs Altimeter Range Error';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Vertical Velocity Estimation Error (m/s)','fontsize',14)
ylabel('Altimeter Range Error (m)','fontsize',14)
str_text_box = {sprintf('Vertical Velocity Estimation Error Spec= %9.2f deg',vertical_est_vel_scalar_limit)};
annotation('textbox',[.15, .8 .70 .10],'string',str_text_box) 
vertical_est_vel_scalar_limit_x = vertical_est_vel_scalar_limit*ones(1,100);
altimeter_range_err_y = max(altimeter_percent_err)*max_range_mean;
plot(vertical_est_vel_scalar_limit_x,0.01*[1:100].*altimeter_range_err_y,'r-','linewidth',2);
% plot(0.01*[1:100].*vertical_est_vel_scalar_limit_x,altimeter_percent_err_y,'r-','linewidth',2);
saveas(gcf,'VertVelEstErrandAltRangeErr.png');saveas(gcf,'VertVelEstErrandAltRangeErr.fig')

%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(max(abs(mc_all_initial(itest,80))),lateral_gnc_pos_scalar(itest),'b*');text(max(abs(mc_all_initial(itest,80))),lateral_gnc_pos_scalar(itest),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(max(abs(mc_all_initial(itest,80))),lateral_gnc_pos_scalar(itest),'r*');text(max(abs(mc_all_initial(itest,80))),lateral_gnc_pos_scalar(itest),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Main Engine Misalignment vs Touchdown Lateral Position';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Main Engine Misaligment (deg)','fontsize',14)
ylabel('Touchdown Lateral Position (m)','fontsize',14)
str_text_box = {sprintf('Touchdown Lateral Position Error Spec = %9.2f m',lateral_gnc_pos_scalar_limit)};
annotation('textbox',[.15, .8 .70 .10],'string',str_text_box) 
max_misalignment_ang_x = max(max_misalignment_ang);
lateral_gnc_pos_scalar_limit_y = lateral_gnc_pos_scalar_limit*ones(1,100);
plot(0.01*[1:100].*max_misalignment_ang_x,ones(1,100).*lateral_gnc_pos_scalar_limit_y,'r-','linewidth',2);
saveas(gcf,'MainEngMisalignandPosErr.png');saveas(gcf,'MainEngMisalignandPosErr.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(abs(mc_all_initial(itest,53)),lateral_gnc_pos_scalar(itest),'b*');text(abs(mc_all_initial(itest,53)),lateral_gnc_pos_scalar(itest),strcat('   ',num2str(itest)),'Color','b');
     plot(abs(mc_all_initial(itest,54)),lateral_gnc_pos_scalar(itest),'b*');text(abs(mc_all_initial(itest,54)),lateral_gnc_pos_scalar(itest),strcat('   ',num2str(itest)),'Color','b');
     plot(abs(mc_all_initial(itest,55)),lateral_gnc_pos_scalar(itest),'b*');text(abs(mc_all_initial(itest,55)),lateral_gnc_pos_scalar(itest),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(abs(mc_all_initial(itest,53)),lateral_gnc_pos_scalar(itest),'r*');text(abs(mc_all_initial(itest,53)),lateral_gnc_pos_scalar(itest),strcat('   ',num2str(itest)),'Color','r');
     plot(abs(mc_all_initial(itest,54)),lateral_gnc_pos_scalar(itest),'r*');text(abs(mc_all_initial(itest,54)),lateral_gnc_pos_scalar(itest),strcat('   ',num2str(itest)),'Color','r');
     plot(abs(mc_all_initial(itest,55)),lateral_gnc_pos_scalar(itest),'r*');text(abs(mc_all_initial(itest,55)),lateral_gnc_pos_scalar(itest),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Main Engine Misalignment Azimuth vs Touchdown Lateral Position';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Main Engine Misaligment Azimuth (deg)','fontsize',14)
ylabel('Touchdown Lateral Position (m)','fontsize',14)
str_text_box = {sprintf('Touchdown Lateral Position Error Spec = %9.2f m',lateral_gnc_pos_scalar_limit)};
annotation('textbox',[.3 .8 .55 .10],'string',str_text_box) 
max_misalignment_az_x = max(max_misalignment_az);
lateral_gnc_pos_scalar_limit_y = lateral_gnc_pos_scalar_limit*ones(1,100);
plot(0.01*[1:100].*max_misalignment_az_x,lateral_gnc_pos_scalar_limit_y,'r-','linewidth',2);
saveas(gcf,'MainEngMisalignAzandPosErr.png');saveas(gcf,'MainEngMisalignAzandPosErr.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(max(abs(mc_all_initial(itest,80))),total_fuel_used_scalar(itest),'b*');text(max(abs(mc_all_initial(itest,80))),total_fuel_used_scalar(itest),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(max(abs(mc_all_initial(itest,80))),total_fuel_used_scalar(itest),'r*');text(max(abs(mc_all_initial(itest,80))),total_fuel_used_scalar(itest),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Main Engine Misaligment vs Propellant Usage';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Main Engine Misaligment (deg)','fontsize',14)
ylabel('Propellant Usage (kg)','fontsize',14)
str_text_box = {sprintf('Touchdown Lateral Position Error Spec = %9.2f m',lateral_gnc_pos_scalar_limit)};
annotation('textbox',[.3 .8 .55 .10],'string',str_text_box) 
max_misalignment_ang_x = max(max_misalignment_ang);
lateral_gnc_pos_scalar_limit_y = lateral_gnc_pos_scalar_limit*ones(1,100);
plot(0.01*[1:100].*max_misalignment_ang_x,ones(1,100).*(htp_mass_initial+rp1_mass_initial+gn2_mass_initial),'r-','linewidth',2);
saveas(gcf,'MainEngMisalignandPropUsed.png');saveas(gcf,'MainEngMisalignandPropUsed.fig')

%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
  azimuth_deg_1 = mc_all_initial(itest,53);azimuth_deg_2 = mc_all_initial(itest,54);azimuth_deg_3 = mc_all_initial(itest,55);
  misalgn_deg_1 = mc_all_initial(itest,80);misalgn_deg_2 = mc_all_initial(itest,81);misalgn_deg_3 = mc_all_initial(itest,82);
  biprop_thrust = mc_all_initial(itest,85);

  misalignment_roll_torque(itest,:) = biprop_thrust*(cross([sind(misalgn_deg_1)*[cosd(azimuth_deg_1) sind(azimuth_deg_1)] cosd(misalgn_deg_1)],tfl_thruster25_position) +...
                                                                                  cross([sind(misalgn_deg_2)*[cosd(azimuth_deg_1) sind(azimuth_deg_2)] cosd(misalgn_deg_2)],tfl_thruster26_position) +...
                                                                                  cross([sind(misalgn_deg_3)*[cosd(azimuth_deg_1) sind(azimuth_deg_3)] cosd(misalgn_deg_3)],tfl_thruster27_position));
  if(mc_all_final(itest,39)==0)
     plot(misalignment_roll_torque(itest,3),max(abs(mc_all_initial(itest,80))),'b*');text(misalignment_roll_torque(itest,3),max(abs(mc_all_initial(itest,80))),strcat('   ',num2str(itest)),'Color','b');
  elseif(mc_all_final(itest,39)==1)
     plot(misalignment_roll_torque(itest,3),max(abs(mc_all_initial(itest,80))),'r*');text(misalignment_roll_torque(itest,3),max(abs(mc_all_initial(itest,80))),strcat('   ',num2str(itest)),'Color','r');
  end
end
title_string = 'Main Engine Misaligment(s) Induced Roll Torque';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
ylabel('Maximum Main Engine Misaligment (deg)','fontsize',14)
xlabel('Roll Torque Induced By Misalignment(s) (N-m)','fontsize',14)
str_text_box = {sprintf('Vernier Roll Torque Authority = %9.2f N-m',2*abs(vac_thruster20_trq(3))*psp_vernier_acs_thrust)};
annotation('textbox',[.3 .8 .55 .10],'string',str_text_box) 
vernier_roll_trq_authority_x = 2*abs(vac_thruster20_trq(3))*psp_vernier_acs_thrust*ones(1,100);
max_misalignment_ang_y = max(max_misalignment_ang);
plot(vernier_roll_trq_authority_x,0.01*[1:100].*max_misalignment_ang_y,'r-','linewidth',2);
plot(-vernier_roll_trq_authority_x,0.01*[1:100].*max_misalignment_ang_y,'r-','linewidth',2);
saveas(gcf,'MainEngMisalignandRollTrq.png');saveas(gcf,'MainEngMisalignandRollTrq.fig')

%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(abs(lateral_gnc_vel_scalar(itest)),lateral_est_vel_scalar(itest),'b*');text(abs(lateral_gnc_vel_scalar(itest)),lateral_est_vel_scalar(itest),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(abs(lateral_gnc_vel_scalar(itest)),lateral_est_vel_scalar(itest),'r*');text(abs(lateral_gnc_vel_scalar(itest)),lateral_est_vel_scalar(itest),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Touchdown True Lateral Velocity Error vs Lateral Velocity Estimation Error';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('True Lateral Velocity Error (m/s)','fontsize',14)
ylabel('Lateral Velocity Estimation Error (m/s)','fontsize',14)
str_text_box = {sprintf('Touchdown Lateral Velocity Error Spec = %9.2f m',lateral_gnc_vel_scalar_limit),sprintf('Touchdown Lateral Velocity Estimation Error Spec = %9.2f m/s',lateral_est_vel_scalar_limit)};
annotation('textbox',[.15, .8 .80 .10],'string',str_text_box) 
lateral_gnc_vel_scalar_limit_x = lateral_gnc_vel_scalar_limit*ones(1,100);
lateral_est_vel_scalar_limit_y = lateral_est_vel_scalar_limit*ones(1,100);
plot(lateral_gnc_vel_scalar_limit_x,0.01*[1:100].*lateral_est_vel_scalar_limit_y,'r-','linewidth',2);
plot(0.01*[1:100].*lateral_gnc_vel_scalar_limit_x,lateral_est_vel_scalar_limit_y,'r-','linewidth',2);
saveas(gcf,'TrueLatVelErrandVelEstErr.png');saveas(gcf,'TrueLatVelErrandVelEstErr.fig')

%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(abs(vertical_gnc_vel_scalar(itest)),vertical_est_vel_scalar(itest),'b*');text(abs(vertical_gnc_vel_scalar(itest)),vertical_est_vel_scalar(itest),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(abs(vertical_gnc_vel_scalar(itest)),vertical_est_vel_scalar(itest),'r*');text(abs(vertical_gnc_vel_scalar(itest)),vertical_est_vel_scalar(itest),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Touchdown Magnitude True Vertical Velocity Error vs Magnitude Vertical Velocity Estimation Error';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('True Vertical Velocity Error (m/s)','fontsize',14)
ylabel('Vertical Velocity Estimation Error (m/s)','fontsize',14)
str_text_box = {sprintf('Touchdown Vertical Velocity Error Spec = %9.2f m/s',final_gnc_vert_vel_err_limit),sprintf('Touchdown Vertical Velocity Estimation Error Spec = %9.2f m/s',vertical_est_vel_scalar_limit)};
annotation('textbox',[.15, .8 .80 .10],'string',str_text_box) 
final_gnc_vert_vel_err_limit_x = final_gnc_vert_vel_err_limit*ones(1,100);
vertical_est_vel_scalar_limit_y = vertical_est_vel_scalar_limit*ones(1,100);
plot(final_gnc_vert_vel_err_limit_x,0.01*[1:100].*vertical_est_vel_scalar_limit_y,'r-','linewidth',2);
plot(0.01*[1:100].*final_gnc_vert_vel_err_limit_x,vertical_est_vel_scalar_limit_y,'r-','linewidth',2);
saveas(gcf,'AbsTrueVertVelErrandVelEstErr.png');saveas(gcf,'AbsTrueVertVelErrandVelEstErr.fig')

%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(vertical_gnc_vel(itest),vertical_est_vel(itest),'b*');text(vertical_gnc_vel(itest),vertical_est_vel(itest),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(vertical_gnc_vel(itest),vertical_est_vel(itest),'r*');text(vertical_gnc_vel(itest),vertical_est_vel(itest),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Touchdown True Vertical Velocity Error vs Vertical Velocity Estimation Error';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('True Vertical Velocity Error (m/s)','fontsize',14)
ylabel('Vertical Velocity Estimation Error (m/s)','fontsize',14)
str_text_box = {sprintf('Touchdown Vertical Velocity Error Spec = %9.2f m/s',final_gnc_vert_vel_err_limit),sprintf('Touchdown Vertical Velocity Estimation Error Spec = %9.2f m/s',vertical_est_vel_scalar_limit)};
annotation('textbox',[.15, .8 .80 .10],'string',str_text_box) 
final_gnc_vert_vel_err_limit_x = [min(-final_gnc_vert_vel_err_limit)*ones(1,50) max(final_gnc_vert_vel_err_limit)*ones(1,50)];
vertical_est_vel_scalar_limit_y = [min(-vertical_est_vel_scalar_limit)*ones(1,50) max(vertical_est_vel_scalar_limit)*ones(1,50)];
plot(final_gnc_vert_vel_err_limit_x(end)*ones(1,100),[0.02*[1:50].*vertical_est_vel_scalar_limit_y(1:50) 0.02*[1:50].*vertical_est_vel_scalar_limit_y(51:100)] ,'r-','linewidth',2);
plot(final_gnc_vert_vel_err_limit_x(1)*ones(1,100),[0.02*[1:50].*vertical_est_vel_scalar_limit_y(1:50) 0.02*[1:50].*vertical_est_vel_scalar_limit_y(51:100)] ,'r-','linewidth',2);
plot([0.02*[1:50].*final_gnc_vert_vel_err_limit_x(1:50) 0.02*[1:50].*final_gnc_vert_vel_err_limit_x(51:100)] ,vertical_est_vel_scalar_limit_y(1)*ones(1,100),'r-','linewidth',2);
plot([0.02*[1:50].*final_gnc_vert_vel_err_limit_x(1:50) 0.02*[1:50].*final_gnc_vert_vel_err_limit_x(51:100)] ,vertical_est_vel_scalar_limit_y(end)*ones(1,100),'r-','linewidth',2);
saveas(gcf,'TrueVertVelErrandVelEstErr.png');saveas(gcf,'TrueVertVelErrandVelEstErr.fig')

%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(vertical_gnc_vel(itest),initial_prop_mass(itest),'b*');text(vertical_gnc_vel(itest),initial_prop_mass(itest),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(vertical_gnc_vel(itest),initial_prop_mass(itest),'r*');text(vertical_gnc_vel(itest),initial_prop_mass(itest),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Touchdown True Vertical Velocity Error vs Initial Prop Mass';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('True Vertical Velocity Error (m/s)','fontsize',14)
ylabel('Initial Prop Mass (kg)','fontsize',14)
str_text_box = {sprintf('Touchdown Vertical Velocity Error Spec = %9.2f m/s',final_gnc_vert_vel_err_limit)};
annotation('textbox',[.15, .8 .80 .10],'string',str_text_box) 
% final_gnc_vert_vel_err_limit_x = [min(-final_gnc_vert_vel_err_limit)*ones(1,50) max(final_gnc_vert_vel_err_limit)*ones(1,50)];
% initial_prop_mass_limit_y = [min(-vertical_est_vel_scalar_limit)*ones(1,50) max(vertical_est_vel_scalar_limit)*ones(1,50)];
% plot(final_gnc_vert_vel_err_limit_x(end)*ones(1,100),[0.02*[1:50].*vertical_est_vel_scalar_limit_y(1:50) 0.02*[1:50].*vertical_est_vel_scalar_limit_y(51:100)] ,'r-','linewidth',2);
% plot(final_gnc_vert_vel_err_limit_x(1)*ones(1,100),[0.02*[1:50].*vertical_est_vel_scalar_limit_y(1:50) 0.02*[1:50].*vertical_est_vel_scalar_limit_y(51:100)] ,'r-','linewidth',2);
% plot([0.02*[1:50].*final_gnc_vert_vel_err_limit_x(1:50) 0.02*[1:50].*final_gnc_vert_vel_err_limit_x(51:100)] ,vertical_est_vel_scalar_limit_y(1)*ones(1,100),'r-','linewidth',2);
% plot([0.02*[1:50].*final_gnc_vert_vel_err_limit_x(1:50) 0.02*[1:50].*final_gnc_vert_vel_err_limit_x(51:100)] ,vertical_est_vel_scalar_limit_y(end)*ones(1,100),'r-','linewidth',2);
saveas(gcf,'TrueVertVelErrandInitPropMass.png');saveas(gcf,'TrueVertVelErrandInitPropMass.fig')

%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(abs(vertical_gnc_vel_scalar(itest)),mass_estimate_bias(itest),'b*');text(abs(vertical_gnc_vel_scalar(itest)),mass_estimate_bias(itest),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(abs(vertical_gnc_vel_scalar(itest)),mass_estimate_bias(itest),'r*');text(abs(vertical_gnc_vel_scalar(itest)),mass_estimate_bias(itest),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Touchdown True Vertical Velocity Error vs Mass Estimate Bias';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('True Vertical Velocity Error (m/s)','fontsize',14)
ylabel('Mass Estimate Bias (kg)','fontsize',14)
str_text_box = {sprintf('Touchdown Vertical Velocity Error Spec = %9.2f m/s',final_gnc_vert_vel_err_limit)};
annotation('textbox',[.15, .8 .80 .10],'string',str_text_box) 
final_gnc_vert_vel_err_limit_x = final_gnc_vert_vel_err_limit*ones(1,100);
pos_mass_estimate_bias_y = max(mass_estimate_bias)*ones(1,50);
neg_mass_estimate_bias_y = min(mass_estimate_bias)*ones(1,50);
plot(final_gnc_vert_vel_err_limit_x,[0.02*[1:50].*pos_mass_estimate_bias_y 0.02*[1:50].*neg_mass_estimate_bias_y],'r-','linewidth',2);
% plot(0.01*[1:100].*final_gnc_vert_vel_err_limit_x,vertical_est_vel_scalar_limit_y,'r-','linewidth',2);
saveas(gcf,'TrueVertVelErrandMassBias.png');saveas(gcf,'TrueVertVelErrandMassBias.fig')

%%
figure;
for itest=1:size(mc_all_final,1) 
    if(mc_all_final(itest,39)==0)
        plot3(mc_all_initial(itest,2),mc_all_initial(itest,3),mc_all_initial(itest,4),'b*');hold on
    elseif(mc_all_final(itest,39)==1)
        plot3(mc_all_initial(itest,2),mc_all_initial(itest,3),mc_all_initial(itest,4),'r*');hold on
    end
end
title_string = 'Initial Position Estimation Error';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('X Position Error (meters)','fontsize',14);
ylabel('Y Position Error (meters)','fontsize',14);
zlabel('Z Position Error (meters)','fontsize',14);
hold on; grid on;
saveas(gcf,'InitialPosEstError.png');saveas(gcf,'InitialPosEstError.fig')

%%
figure;
for itest=1:size(mc_all_final,1)
    if(mc_all_final(itest,39)==0)
        plot3(mc_all_initial(itest,5),mc_all_initial(itest,6),mc_all_initial(itest,7),'b*');hold on 
    elseif(mc_all_final(itest,39)==1)
        plot3(mc_all_initial(itest,5),mc_all_initial(itest,6),mc_all_initial(itest,7),'r*');hold on
    end
end
title_string = 'Initial Velocity Estimation Error';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('X Velocity Error (m/s)','fontsize',14);
ylabel('Y Velocity Error (m/s)','fontsize',14);
zlabel('Z Velocity Error (m/s)','fontsize',14);
hold on; grid on;
saveas(gcf,'InitialVelEstError.png');saveas(gcf,'InitialVelEstError.fig')

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
    n=find(mc_traj_data.sim_pos.Time==3700);
    if exist('mc_traj_data','var')
     if(mc_all_final(ipos,39)==0)
            plot3(mc_traj_data.sim_pos.Data(n:end,1),mc_traj_data.sim_pos.Data(n:end,2),mc_traj_data.altitude.Data(n:end),'b-');hold on   
     else
            plot3(mc_traj_data.sim_pos.Data(n:end,1),mc_traj_data.sim_pos.Data(n:end,2),mc_traj_data.altitude.Data(n:end),'r-');hold on 
     end
    end
    hold on; grid on;
end
zlim([0 15000]);
title_string = 'Landing Site Relative Position in Topocentric Frame';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Topocentric X Position (meters)','fontsize',14);
ylabel('Topocentric Y Position (meters)','fontsize',14);
zlabel('Altitude (meters)','fontsize',14);
saveas(gcf,'TruePos3D.png');saveas(gcf,'TruePos3D.fig')

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
    n=find(mc_traj_data.sim_pos.Time==3700);
    if exist('mc_traj_data','var')
     if(mc_all_final(ipos,39)==0)
            plot(mc_traj_data.sim_pos.Data(n:end,1),mc_traj_data.sim_pos.Data(n:end,2),'b-');hold on   
     else
            plot(mc_traj_data.sim_pos.Data(n:end,1),mc_traj_data.sim_pos.Data(n:end,2),'r-');hold on 
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
saveas(gcf,'TruePosLateral.png');saveas(gcf,'TruePosLateral.fig')

%%
% figure;grid on;hold on;
% for itest=1:size(mc_all_final,1)
%  if(mc_all_final(itest,39)==0)
%      plot(lateral_cg_wet_offset(itest)*1e3,max_excursion(itest),'b*');
%  elseif(mc_all_final(itest,39)==1)
%      plot(lateral_cg_wet_offset(itest)*1e3,max_excursion(itest),'r*');
%  end
% end
% title_string = 'Lateral Center of Mass Offset vs MTV Max Lateral Excursion';
% title(title_string,'fontsize',14);set(gcf,'Name',title_string)
% xlabel('Lateral Center of Mass Offset (mm)','fontsize',14)
% ylabel('Max Lateral Excursion (m)','fontsize',14)
% saveas(gcf,'LateralCMandMaxLatExcursion.png');saveas(gcf,'LateralCMandMaxLatExcursion.fig')
%%
% figure;grid on;hold on;
% for itest=1:size(mc_all_final,1)
%  if(mc_all_final(itest,39)==0)
%      plot(cm_az_deg(itest),max_excursion(itest),'b*');
%  elseif(mc_all_final(itest,39)==1)
%      plot(cm_az_deg(itest),max_excursion(itest),'r*');
%  end
% end
% title_string = 'Lateral Center of Mass Offset Azimuth vs MTV Max Lateral Excursion';
% title(title_string,'fontsize',14);set(gcf,'Name',title_string)
% xlabel('Lateral Center of Mass Offset Azimuth (deg)','fontsize',14)
% ylabel('Max Lateral Excursion (m)','fontsize',14)
% saveas(gcf,'LateralCMAzimuthandMaxLatExcursion.png');saveas(gcf,'LateralCMAzimuthandMaxLatExcursion.fig')

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
xlim([3700 4200])
title_string = 'Velocity Magnitude';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Time (sec)','fontsize',14);
ylabel('Velocity Magnitude (m/s)','fontsize',14);
saveas(gcf,'VelocityMag.png');saveas(gcf,'VelocityMag.fig')
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
            plot(mc_traj_data.altitude,'b-');hold on,text(3980,mc_traj_data.altitude.Data(find(mc_traj_data.sim_vel.Time > 3980 & mc_traj_data.sim_vel.Time<3990,1,'first'),1),strcat('Case',num2str(ipos)),'Color','b');
      else
            plot(mc_traj_data.altitude,'r-');hold on,text(3980,mc_traj_data.altitude.Data(find(mc_traj_data.sim_vel.Time > 3980 & mc_traj_data.sim_vel.Time<3990,1,'first'),1),strcat('Case',num2str(ipos)),'Color','r');
      end
    end
    hold on; grid on;
end
xlim([3700 4200])
title_string = 'Altitude';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Time (sec)','fontsize',14);
ylabel('Altitude (meters)','fontsize',14);
% saveas(gcf,'Altitude.png');saveas(gcf,'Altitude.fig')
%%
figure;
for ipos = 1:mc_n
    name_mc_pos=[ mc_prefix_s_pos num2str(ipos) ];
    if exist(strcat(name_mc_pos,'.mat'),'file')
        load( name_mc_pos );
    else
        continue
    end
        if isempty(find(mc_traj_data.altitude.Data > 6950 & mc_traj_data.altitude.Data<6990,1,'first'))
             if exist('mc_traj_data','var')
                  if(mc_all_final(ipos,39)==0)
                        plot(mc_traj_data.altitude.Data,normrows(mc_traj_data.sim_vel.Data(:,1:2)),'b-');
                  else
                        plot(mc_traj_data.altitude.Data,normrows(mc_traj_data.sim_vel.Data(:,1:2)),'r-');
                  end
             end
        else
            if exist('mc_traj_data','var')
                  if(mc_all_final(ipos,39)==0)
                        plot(mc_traj_data.altitude.Data,normrows(mc_traj_data.sim_vel.Data(:,1:2)),'b-');hold on,text(6950,normrows(mc_traj_data.sim_vel.Data(find(mc_traj_data.altitude.Data > 6950 & mc_traj_data.altitude.Data<6990,1,'first'),1:2)),strcat('Case',num2str(ipos)),'Color','b');
                  else
                        plot(mc_traj_data.altitude.Data,normrows(mc_traj_data.sim_vel.Data(:,1:2)),'r-');hold on,text(6950,normrows(mc_traj_data.sim_vel.Data(find(mc_traj_data.altitude.Data > 6950 & mc_traj_data.altitude.Data<6990,1,'first'),1:2)),strcat('Case',num2str(ipos)),'Color','r');
                 end
            end
        end
    hold on; grid on;
end
title_string = ' Lateral Velocity Magnitude vs. Altitude';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlim([0 1.5e4])
xlabel('Altitude (meters)','fontsize',14);
ylabel('LateralVelocity Magnitude (m/s)','fontsize',14);
saveas(gcf,'LatVelocityMagvsAltitude.png');saveas(gcf,'LatVelocityMagvsAltitude.fig')
%%
figure;
for ipos = 1:mc_n
    name_mc_pos=[ mc_prefix_s_pos num2str(ipos) ];
    if exist(strcat(name_mc_pos,'.mat'),'file')
        load( name_mc_pos );
    else
        continue
    end
    if isempty(find(mc_traj_data.altitude.Data > 980 & mc_traj_data.altitude.Data<1010,1,'first'))
        if exist('mc_traj_data','var')
          if(mc_all_final(ipos,39)==0)
                plot(mc_traj_data.altitude.Data,mc_traj_data.sim_vel.Data(:,3),'b-');
          else
                plot(mc_traj_data.altitude.Data,mc_traj_data.sim_vel.Data(:,3),'r-');
          end
        end
    else
        if exist('mc_traj_data','var')
          if(mc_all_final(ipos,39)==0)
                plot(mc_traj_data.altitude.Data,mc_traj_data.sim_vel.Data(:,3),'b-');hold on;text(1000,mc_traj_data.sim_vel.Data(find(mc_traj_data.altitude.Data > 980 & mc_traj_data.altitude.Data<1010,1,'first'),3),strcat('Case',num2str(ipos)),'Color','b');
          else
                plot(mc_traj_data.altitude.Data,mc_traj_data.sim_vel.Data(:,3),'r-');hold on;text(1000,mc_traj_data.sim_vel.Data(find(mc_traj_data.altitude.Data > 980 & mc_traj_data.altitude.Data<1010,1,'first'),3),strcat('Case',num2str(ipos)),'Color','r');
          end
        end
    end
    hold on; grid on;
end
title_string = 'Vertical Velocity vs. Altitude';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlim([0 1.5e4])
xlabel('Altitude (meters)','fontsize',14);
ylabel('Velocity (m/s)','fontsize',14);
saveas(gcf,'VerticalVelvsAltitude.png');saveas(gcf,'VerticalVelvsAltitude.fig')
%%
% figure;
% for ipos = 1:mc_n
%     name_mc_pos=[ mc_prefix_s_pos num2str(ipos) ];
%     if exist(strcat(name_mc_pos,'.mat'),'file')
%         load( name_mc_pos );
%     else
%         continue
%     end
%     if isempty(find(mc_traj_data.altitude.Data > 6950 & mc_traj_data.altitude.Data<6990,1,'first'))
%                 if exist('mc_traj_data','var')
%           if(mc_all_final(ipos,39)==0)
%                 plot(mc_traj_data.altitude.Data,normrows(mc_traj_data.sim_vel.Data(:,1:2)),'b-');
%           else
%                 plot(mc_traj_data.altitude.Data,normrows(mc_traj_data.sim_vel.Data(:,1:2)),'r-');
%           end
%                 end
%     else
%         if exist('mc_traj_data','var')
%           if(mc_all_final(ipos,39)==0)
%                 plot(mc_traj_data.altitude.Data,normrows(mc_traj_data.sim_vel.Data(:,1:2)),'b-');hold on;text(6950,normrows(mc_traj_data.sim_vel.Data(find(mc_traj_data.altitude.Data > 6950 & mc_traj_data.altitude.Data<6990,1,'first'),1:2)),strcat('Case',num2str(ipos)),'Color','b');
%           else
%                 plot(mc_traj_data.altitude.Data,normrows(mc_traj_data.sim_vel.Data(:,1:2)),'r-');hold on;text(6950,normrows(mc_traj_data.sim_vel.Data(find(mc_traj_data.altitude.Data > 6950 & mc_traj_data.altitude.Data<6990,1,'first'),1:2)),strcat('Case',num2str(ipos)),'Color','r');
%           end
%         end
%     end
%     hold on; grid on;clear t
% end
% title_string = 'Lateral Velocity vs. Altitude';
% title(title_string,'fontsize',14);set(gcf,'Name',title_string)
% xlim([0 1.5e4])
% xlabel('Altitude (meters)','fontsize',14);
% ylabel('Velocity (m/s)','fontsize',14);
% clear t
% saveas(gcf,'LateralVelvsAltitude.png');saveas(gcf,'LateralVelvsAltitude.fig')

%%
% figure;
% for ipos = 1:mc_n
%     name_mc_pos=[ mc_prefix_s_pos num2str(ipos) ];
%     if exist(strcat(name_mc_pos,'.mat'),'file')
%         load( name_mc_pos );
%     else
%         continue
%     end
%     if exist('mc_traj_data','var')
%       if(mc_all_final(ipos,39)==0)
%             plot3(mc_traj_data.sim_pos.Data(:,1), mc_traj_data.sim_pos.Data(:,2), mc_traj_data.sim_pos.Data(:,3),'b-' );hold on
%       else
%             plot3(mc_traj_data.sim_pos.Data(:,1), mc_traj_data.sim_pos.Data(:,2), mc_traj_data.sim_pos.Data(:,3),'r-' );hold on
%       end
%     end
% %    axis([-5000 5000 -5000 5000 0 10000])   
% %     axis([-55 -25 -22 -8 0 15])   
%     hold on; grid on;
% end
% title_string = 'Landing Site Relative Position in Topocentric Frame';
% title(title_string,'fontsize',14);set(gcf,'Name',title_string)
% xlabel({'Landing Site Relative Topocentric','True X Position (meters)'},'fontsize',14);
% ylabel({'Landing Site Relative Topocentric','True Y Position (meters)'},'fontsize',14);
% zlabel({'Landing Site Relative Topocentric','True Z Position (meters)'},'fontsize',14);
% saveas(gcf,'TruePos3D.png');saveas(gcf,'TruePos3D.fig')
%%
% figure;
% for ipos = 1:mc_n
%     name_mc_pos=[ mc_prefix_s_pos num2str(ipos) ];
%     if exist(strcat(name_mc_pos,'.mat'),'file')
%         load( name_mc_pos );
%     else
%         continue
%     end
%     if exist('mc_traj_data','var')
%         iTopo = find( telem.cmp.est_ref_frame.Data == 2);
%         est_topo_pos_only = getdatasamples(mc_traj_data.est_pos, iTopo);
%         est_topoalt = getdatasamples(mc_traj_data.est_alt, iTopo);
%         if(mc_all_final(ipos,39)==0)
%             plot3(est_topo_pos_only(:,1), est_topo_pos_only(:,2), est_topoalt,'b-');hold on
%         else
%             plot3(est_topo_pos_only(:,1), est_topo_pos_only(:,2), est_topoalt,'r-');hold on
%         end
%         
%         clear est_topo_pos_only
%     end
%     %axis([-30000 1000 -10000 10000 0 10000])   
%     hold on; grid on;
% end
% title_string = 'Landing Site Relative Estimated Position in Topocentric Frame';
% title(title_string,'fontsize',14);set(gcf,'Name',title_string)
% xlabel({'Landing Site Relative Topocentric','Estimated X Position (meters)'},'fontsize',14);
% ylabel({'Landing Site Relative Topocentric','Estimated Y Position (meters)'},'fontsize',14);
% zlabel({'Landing Site Relative Topocentric','Estimated Z Position (meters)'},'fontsize',14);
% saveas(gcf,'EstPos3D.png');saveas(gcf,'EstPos3D.fig')
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
            plot(mc_traj_data.htp_used_main,'b-');hold on
       else
            plot(mc_traj_data.htp_used_main,'r-');hold on
       end
    end
    hold on; grid on;
end
xlim([3700 4200])
title_string = 'HTP Mass Used Main';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Time (sec)','fontsize',14);
ylabel('Mass (kg)','fontsize',14);
saveas(gcf,'HtpUsedMain.png');%saveas(gcf,'HtpUsedMain.fig')
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
            plot(mc_traj_data.htp_used_acs,'b-');hold on
       else
            plot(mc_traj_data.htp_used_acs,'r-');hold on
       end
    end
    hold on; grid on;
end
xlim([3700 4200])
title_string = 'HTP Mass Used ACS';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Time (sec)','fontsize',14);
ylabel('Mass (kg)','fontsize',14);
saveas(gcf,'HtpUsedAcs.png');%saveas(gcf,'HtpUsedAcs.fig')
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
            plot(mc_traj_data.rp1_used,'b-');hold on
       else
            plot(mc_traj_data.rp1_used,'r-');hold on
       end
    end
    hold on; grid on;
end
xlim([3700 4200])
title_string = 'RP1 Mass Used';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Time (sec)','fontsize',14);
ylabel('Mass (kg)','fontsize',14);
saveas(gcf,'Rp1Used.png');%saveas(gcf,'Rp1Used.fig')
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
            plot(mc_traj_data.sim_vel.Time,mc_traj_data.gdn_vel_cmd.Data(:,3)-mc_traj_data.sim_vel.Data(:,3),'b-');hold on
       else
            plot(mc_traj_data.sim_vel.Time,mc_traj_data.gdn_vel_cmd.Data(:,3)-mc_traj_data.sim_vel.Data(:,3),'r-');hold on
       end          
    end
    hold on; grid on;
end
xlim([3700 4200])
title_string = 'Commanded Z-Velocity Error';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Time (sec)','fontsize',14);
ylabel('Velocity (meters/sec)','fontsize',14);
saveas(gcf,'CmdZVelErr.png');saveas(gcf,'CmdZVelErr.fig')%%
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
            plot(mc_traj_data.cg.Time,mc_traj_data.cg.Data(:,1)*1e3,'b-');hold on
       else
            plot(mc_traj_data.cg.Time,mc_traj_data.cg.Data(:,1)*1e3,'r-');hold on
       end          
    end
    hold on; grid on;
end
xlim([3700 4200])
xlabel('Time (sec)','fontsize',14);
ylabel('CG X Position (mm)','fontsize',14);
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
            plot(mc_traj_data.cg.Time,mc_traj_data.cg.Data(:,2)*1e3,'b-');hold on
       else
            plot(mc_traj_data.cg.Time,mc_traj_data.cg.Data(:,2)*1e3,'r-');hold on
       end          
    end
    hold on; grid on;
end
xlim([3700 4200])
xlabel('Time (sec)','fontsize',14);
ylabel('CG Y Position (mm)','fontsize',14);
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
            plot(mc_traj_data.cg.Time,mc_traj_data.cg.Data(:,3)*1e3,'b-');hold on
       else
            plot(mc_traj_data.cg.Time,mc_traj_data.cg.Data(:,3)*1e3,'r-');hold on
       end          
    end
    hold on; grid on;
end
xlim([3700 4200])
xlabel('Time (sec)','fontsize',14);
ylabel('CG Z Position (mm)','fontsize',14);
title_string = 'CG Z Position';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
saveas(gcf,'CgZPos.png');%saveas(gcf,'CgZPos.fig')
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
xlim([3700 4200])
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
xlim([3700 4200])
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
xlim([3700 4200])
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
xlim([3700 4200])
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
xlim([3700 4200])
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
xlim([3700 4200])
title_string = 'Landing Site Relative Z-Velocity in Topocentric Frame';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Time (sec)','fontsize',14);
ylabel('Topocentric Z Velocity (meters/sec)','fontsize',14);
saveas(gcf,'TrueZVel.png');%saveas(gcf,'TrueZVel.fig')%%
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
 if(mc_all_final(itest,39)==0)
     plot(mc_all_final(itest,15),mc_all_final(itest,16),'b*');text(mc_all_final(itest,15),mc_all_final(itest,16),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(mc_all_final(itest,15),mc_all_final(itest,16),'r*');text(mc_all_final(itest,15),mc_all_final(itest,16),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Touchdown Topocentric Position';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Topocentric X Position (meters)','fontsize',14)
ylabel('Topocentric Y Position (meters)','fontsize',14)
if size(mc_all_final(:,15:16),1)>1
  mean_landing_error = mean(mc_all_final(:,15:16),1);
  standard_deviation_landing_error = std(mc_all_final(:,15:16),1);
  str_text_box = {sprintf('Mean     = %9.2f, %9.2f m',mean_landing_error),sprintf('3 Sigma = %9.2f, %9.2f m',3*standard_deviation_landing_error),...
     sprintf('Lateral Position Spec = %9.2f  m',lateral_gnc_pos_scalar_limit)};
  annotation('textbox',[.3 .7 .47 .15],'string',str_text_box) 
  hold on;
  ellipse_3_sigma_y = mean_landing_error(2)+3*standard_deviation_landing_error(2)*sin(2*pi*0.01*[0:100]);
  ellipse_3_sigma_x = mean_landing_error(1)+3*standard_deviation_landing_error(1)*cos(2*pi*0.01*[0:100]);
  plot(ellipse_3_sigma_x,ellipse_3_sigma_y,'g-','linewidth',2);
  pos_landing_spec_x = lateral_gnc_pos_scalar_limit*sin(2*pi*0.01*[0:100]);
  pos_landing_spec_y = lateral_gnc_pos_scalar_limit*cos(2*pi*0.01*[0:100]);
  plot(pos_landing_spec_x,pos_landing_spec_y,'r-','linewidth',2);  
end
saveas(gcf,'LateralPosErr.png');%saveas(gcf,'LateralPosErr.fig')
%%
figure;grid on;hold on;
for itest=1:size(mc_all_final,1)
  if(mc_all_final(itest,39)==0)
     plot(mc_all_final(itest,15)-median(mc_all_final(:,15)),mc_all_final(itest,16)-median(mc_all_final(:,16)),'b*');text(mc_all_final(itest,15)-median(mc_all_final(:,15)),mc_all_final(itest,16)-median(mc_all_final(:,16)),strcat('   ',num2str(itest)),'Color','b');
 elseif(mc_all_final(itest,39)==1)
     plot(mc_all_final(itest,15)-median(mc_all_final(:,15)),mc_all_final(itest,16)-median(mc_all_final(:,16)),'r*');text(mc_all_final(itest,15)-median(mc_all_final(:,15)),mc_all_final(itest,16)-median(mc_all_final(:,16)),strcat('   ',num2str(itest)),'Color','r');
 end
end
title_string = 'Touchdown Topocentric Position Relative to Median';
title(title_string,'fontsize',14);set(gcf,'Name',title_string)
xlabel('Topocentric X Position (meters)','fontsize',14)
ylabel('Topocentric Y Position (meters)','fontsize',14)
if size(mc_all_final(:,15:16),1)>1
  mean_landing_error = mean(mc_all_final(:,15:16),1);
  standard_deviation_landing_error = std(mc_all_final(:,15:16),1);
  str_text_box = {sprintf('Mean     = %9.2f, %9.2f m',mean_landing_error),sprintf('3 Sigma = %9.2f, %9.2f m',3*standard_deviation_landing_error)};
  annotation('textbox',[.2 .8 .47 .1],'string',str_text_box) 
  hold on;
  ellipse_3_sigma_y = 3*standard_deviation_landing_error(2)*sin(2*pi*0.01*[0:100]);
  ellipse_3_sigma_x = 3*standard_deviation_landing_error(1)*cos(2*pi*0.01*[0:100]);
  plot(ellipse_3_sigma_x,ellipse_3_sigma_y,'g-','linewidth',2);
end
saveas(gcf,'LateralPosErrMedian.png');%saveas(gcf,'LateralPosErrMedian.fig')
