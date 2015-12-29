%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2010 - 2015 Moon Express, Inc.
% All Rights Reserved.
%
% PROPRIETARY DATA NOTICE:
% The data herein include Proprietary Data and are restricted under the
% Data Rights provisions of Lunar CATALYST Space Act Agreement
% No. SAAM ID# 18251 and Reimbursable Space Act Agreement No.SAA2-402930.
% All information contained herein is and remains proprietary to and the
% property of Moon Express, Inc. Dissemination of this information or
% reproduction of this material is strictly forbidden unless prior
% written permission is obtained from Moon Express, Inc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-------------------------------------------------------------------------%
% plot_test_data.m                                                        %
%                                                                         %
% plots data                                                              %
% 05/30/13                                                                %
%-------------------------------------------------------------------------%

function plot_test_data(varargin)

if nargin > 0
    telem = varargin{1};
else
    try
        telem = evalin('base','telem');
    catch
        fprintf(2,'Error: no telem argument can be found.\n')
        telem = [];
        
    end
end

if nargin > 1
    truth = varargin{2};
else
    try
        truth = evalin('base','truth');
    catch
        fprintf(2,'Error: no truth argument can be found--no truth plot will be made\n')
        truth = [];
    end
end

if nargin > 2
    error = varargin{3};
else
    try
        error = evalin('base','error');
    catch
        fprintf(2,'Error: no error argument can be found\n')
        error = [];
    end
end

if nargin > 3
    run_type = varargin{4};
else
    try
        run_type = evalin('base','run_type');
    catch
        fprintf(2,'Error: no error argument can be found. Assume WSIM.\n')
        run_type = 'WSIM';
    end
end

if nargin > 4
    data_label = [varargin{5} ' : '];
else
    data_label = '';
end

if ~isempty(telem.est.vel.Data) % add future test for estimation frame
    plot_est = 1;
else
    plot_est = 0;
end

if ~isempty(truth)
    plot_truth = 1;
else
    plot_truth = 0;
end


if (isempty(telem) && isempty(truth)) || (plot_est == 0 && plot_truth == 0)
    fprintf(2,'Nothing to plot. Call again with nontrivial input arguments.\n')
    return
end

switch run_type
    case 'PHIL'
        fig_numbers = [11 12 13 14 15 16 17];
    case 'WSIM'
        fig_numbers = [1 2 3 4 5 6 7];
    otherwise
        fig_numbers = [1 2 3 4 5 6 7];
end

% set ylimit automatically based on data
iTopo = find( telem.cmp.est_ref_frame.Data == 2);
iMCI  = find( telem.cmp.est_ref_frame.Data ~= 2);

tMax = telem.cmp.est_ref_frame.Time(end)+30;

if isempty(iTopo)
    iTopo = length(telem.cmp.est_ref_frame.Data);
    tTopo = tMax + 100;
else
    tTopo = telem.cmp.est_ref_frame.Time(iTopo(1));
end

%-------------------------------------------------------------------------%
% set up topo colors
if exist('wsim_prefs.m','file')
    wsim_prefs;
else
    pref_topo_plot_bg_color = 'g';
    pref_topo_plot_bg_alpha = 0.05;
    pref_plot_traj_values = 1;
    pref_plot_pos_vel_errors = 1;
    pref_plot_attitude_errors = 1;
    pref_plot_phase_plane = 1;
    pref_plot_lla = 1;
end

%-------------------------------------------------------------------------%
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

if pref_plot_traj_values
    
    %-------------------------------------------------------------------------%
    %-----                          POS                                  -----%
    fnum = fig_numbers(1);
    RowNum = 1;
    ColNum = 1;
    row = maxrow - (RowNum-1)*(height+4*border) ;
    col = (ColNum-1)*(width+border) + mincol;
    %-------------------------------------------------------------------------%
    
    figure(fnum); clf; set(fnum,'Position',[col row-50 width height])
    
    legend_cell = {};
    
    if plot_truth
        plot(truth.fsw_rate.total.sim_pos,'LineWidth',2);
        legend_cell = cat(1,legend_cell,'X','Y','Z');
    end
    
    grid on;box on
    
    if plot_est
        hold_colors;
        plot(telem.est.local_pos);
        legend_cell = cat(1,legend_cell,'EST X','EST Y','EST Z');
    end
    legend(legend_cell,'Location','NorthWest','fontsize',10)
    title([data_label 'position'],'fontsize',14)
    xlabel('time (sec)','fontsize',14)
    ylabel('meters','fontsize',14)
    set(gcf,'Name','Position')
    bgfill([tTopo tMax], pref_topo_plot_bg_color, pref_topo_plot_bg_alpha)
    
    percent_inertial = iMCI / ( length(iMCI) + length(iTopo) );
    if percent_inertial < 0.05
        ymax = ceil( max(max( truth.fsw_rate.topo.sim_pos.Data )/1000 )) * 1000;
        ymin = floor( min(min( truth.fsw_rate.topo.sim_pos.Data )/1000 )) * 1000;
        ylim([ymin ymax])
    end
    %saveas(gcf,'Position.png');%saveas(gcf,'Position.fig')
    
    %-------------------------------------------------------------------------%
    %-----                          VEL                                  -----%
    fnum = fig_numbers(2);
    RowNum = 1;
    ColNum = 2;
    row = maxrow - (RowNum-1)*(height+4*border) ;
    col = (ColNum-1)*(width+border) + mincol;
    %-------------------------------------------------------------------------%
    
    figure(fnum); clf; set(fnum,'Position',[col row-50 width height])
    
    legend_cell = {};
    
    if plot_truth
        plot(truth.fsw_rate.total.sim_vel,'LineWidth',2);
        legend_cell = cat(1,legend_cell,'X','Y','Z');
    end
    grid on;box on;
    if plot_est
        hold_colors;
        plot(telem.est.vel);
        legend_cell = cat(1,legend_cell,'EST X','EST Y','EST Z');
    end
    
    legend(legend_cell,'Location','SouthWest','fontsize',10)
    title([data_label 'velocity'],'fontsize',14)
    xlabel('time (sec)','fontsize',14)
    ylabel('meters/sec','fontsize',14)
    set(gcf,'Name','Velocity')
    bgfill([tTopo tMax], pref_topo_plot_bg_color, pref_topo_plot_bg_alpha)
    %saveas(gcf,'Velocity.png');%saveas(gcf,'Velocity.fig')
    
    %-------------------------------------------------------------------------%
    %-----                          ACC                                  -----%
    fnum = fig_numbers(3);
    RowNum = 1;
    ColNum = 3;
    row = maxrow - (RowNum-1)*(height+4*border) ;
    col = (ColNum-1)*(width+border) + mincol;
    %-------------------------------------------------------------------------%
    
    figure(fnum); clf; set(fnum,'Position',[col row-50 width height])
    
    legend_cell = {};
    
    if plot_truth
        plot(truth.fsw_rate.total.sim_acc,'LineWidth',2);
        legend_cell = cat(1,legend_cell,'X','Y','Z');
    end
    grid on;box on;
    if plot_est
        hold_colors;
        plot(telem.est.mean_accel);
        legend_cell = cat(1,legend_cell,'EST X','EST Y','EST Z');
    end
    
    legend(legend_cell,'Location','NorthWest','fontsize',10)
    
    title([data_label 'acceleration in Inertial frame'],'fontsize',14)
    xlabel('time (sec)','fontsize',14)
    ylabel('m/s^2','fontsize',14)
    set(gcf,'Name','Acceleration')
    bgfill([tTopo tMax], pref_topo_plot_bg_color, pref_topo_plot_bg_alpha)
    %saveas(gcf,'Acceleration.png');%saveas(gcf,'Acceleration.fig')
    
    %-------------------------------------------------------------------------%
    %-----                          RATE                                 -----%
    fnum = fig_numbers(4);
    RowNum = 2;
    ColNum = 1;
    row = maxrow - (RowNum-1)*(height+4*border) ;
    col = (ColNum-1)*(width+border) + mincol;
    %-------------------------------------------------------------------------%
    
    figure(fnum); clf; set(fnum,'Position',[col row-50 width height])
    
    legend_cell = {};
    
    if plot_truth
        plot(truth.fsw_rate.total.sim_rate*180/pi,'LineWidth',2);
        legend_cell = cat(1,legend_cell,'X','Y','Z');
    end
    grid on;box on;
    if plot_est
        hold_colors;
        plot(telem.est.mean_rate*180/pi);
        legend_cell = cat(1,legend_cell,'EST X','EST Y','EST Z');
    end
    
    legend(legend_cell,'Location','NorthWest','fontsize',10)
    
    title([data_label 'Body Rates'],'fontsize',14)
    xlabel('time (sec)','fontsize',14)
    ylabel('degrees/sec','fontsize',14)
    set(gcf,'Name','Body Rates')
    bgfill([tTopo tMax], pref_topo_plot_bg_color, pref_topo_plot_bg_alpha)
    %saveas(gcf,'BodyRate.png');%saveas(gcf,'BodyRate.fig')
    
    %-------------------------------------------------------------------------%
    %-----                          EUL                                  -----%
    fnum = fig_numbers(5);
    RowNum = 2;
    ColNum = 2;
    row = maxrow - (RowNum-1)*(height+4*border) ;
    col = (ColNum-1)*(width+border) + mincol;
    %-------------------------------------------------------------------------%
    
    figure(fnum); clf; set(fnum,'Position',[col row-50 width height])
    legend_cell = {};
    
    if plot_truth
        plot(truth.fsw_rate.total.sim_euler,'LineWidth',2);
        legend_cell = cat(1,legend_cell,'X','Y','Z');
    end
    
    grid on;box on;
    
    if plot_est
        hold_colors;
        plot(telem.est.euler_xyz);
        legend_cell = cat(1,legend_cell,'EST X','EST Y','EST Z');
    end
    
    legend(legend_cell,'Location','SouthWest','fontsize',10)
    
    title([data_label 'euler 321'],'fontsize',14)
    xlabel('time (sec)','fontsize',14)
    ylabel('degrees','fontsize',14)
    set(gcf,'Name','Euler 321')
    bgfill([tTopo tMax], pref_topo_plot_bg_color, pref_topo_plot_bg_alpha)
    %saveas(gcf,'EulerAngles.png');%saveas(gcf,'EulerAngles.fig')
    
end

if pref_plot_pos_vel_errors
    
    %-------------------------------------------------------------------------%
    %-----                          Pos and Vel Err                      -----%
    fnum = fig_numbers(6);
    RowNum = 2;
    ColNum = 3;
    row = maxrow - (RowNum-1)*(height+4*border) ;
    col = (ColNum-1)*(width+border) + mincol;
    %-------------------------------------------------------------------------%
    figure(fnum); clf; set(fnum,'Position',[col row-158 width 2*height])
    grid on;box on; hold_colors;
    legend_cell = {};
    
    if plot_truth && plot_est
        subplot(2,1,1)
        plot(error.knowledge.total.pos)
        grid on;box on; hold_colors;
        
        ylabel('External Position Estimator Error (m)','fontsize',14)
        title(latex_prep([data_label 'External Position Estimator Error (m)']),'fontsize',14)
        legend_cell = cat(1,legend_cell,'X','Y','Z');
        legend(legend_cell,'Location','NorthEast','fontsize',10)
        set(gcf,'Name','Estimator Errors')
        bgfill([tTopo tMax], pref_topo_plot_bg_color, pref_topo_plot_bg_alpha)
        
        
    end
    
    legend_cell = {};
    if plot_truth && plot_est
        subplot(2,1,2)
        plot(error.knowledge.total.vel)
        grid on;box on; hold_colors;
        
        ylabel('External Velocity Estimator Error (m/s)','fontsize',14)
        xlabel('Time (sec)','fontsize',14)
        title(latex_prep([data_label 'External Velocity Estimator Error (m/s)']),'fontsize',14)
        legend_cell = cat(1,legend_cell,'X','Y','Z');
        legend(legend_cell,'Location','NorthEast','fontsize',10)
        bgfill([tTopo tMax], pref_topo_plot_bg_color, pref_topo_plot_bg_alpha)
        
        %     if percent_inertial < 0.05
        %         ymax = ceil( max(max( error.knowledge.topo.vel.Data ))) ;
        %         ymin = ceil( min(min( error.knowledge.topo.vel.Data ) )) ;
        %         ylim([ymin ymax])
        %     end
    end
    
end

if pref_plot_lla

    %-------------------------------------------------------------------------%
    %-----                          Lat, Lon, Alt                        -----%
    fnum = fig_numbers(7);
    RowNum = 2;
    ColNum = 3;
    row = maxrow - (RowNum-1)*(height+4*border) ;
    col = (ColNum-1)*(width+border) + mincol;
    %-------------------------------------------------------------------------%
    figure(fnum); clf; set(fnum,'Position',[col+280 row-158 width 2*height])
    legend_cell = {};

    subplot(2,1,1)
    plot(truth.sim.detic_latitude,'LineWidth',2)
    hold on
    plot(truth.sim.longitude,'LineWidth',2)
    grid on;

    ylabel('degrees','fontsize',14)
    title([data_label 'Detic Latitude and Longitude'],'fontsize',14)
    legend_cell = cat(1,legend_cell,'Lat','Lon');
    legend(legend_cell,'Location','SouthEast','fontsize',10)

    legend_cell = {};
    subplot(2,1,2)
    if plot_truth
      plot(truth.sim.altitude,'LineWidth',2,'Color',[0.929 0.694 0.125]),grid on
      legend_cell = cat(1,legend_cell,'Truth');
    end
    if plot_est
      hold on;
      plot(telem.est.altitude,'Color',[0.929 0.694 0.125]),grid on
      legend_cell = cat(1,legend_cell,'Estimate');
    end
    legend(legend_cell,'Location','NorthEast','fontsize',10)

    ylabel('meters','fontsize',14)
    xlabel('Time (sec)','fontsize',14)
    title([data_label 'Altitude'],'fontsize',14)

    set(gcf,'Name','Lat,Lon,Alt')
    %saveas(gcf,'LLA.png');%saveas(gcf,'LLA.fig')

end

fig_numbers_used = [fig_numbers(1:5)*pref_plot_traj_values fig_numbers(6)*pref_plot_pos_vel_errors fig_numbers(7)*pref_plot_lla];
fig_numbers_used( fig_numbers_used == 0 ) = [];

link_fig_axes(fig_numbers_used)


%% Determine takeoff/landing, and adjust displayed time span
if ~isfield(telem,'ldr')
  if strcmp(run_type,'WSIM')
    dt=truth.sim.vel_topo.Time(2)-truth.sim.vel_topo.Time(1);
    dn=500;
    touchdown=max(find(truth.sim.vel_topo.Data(:,3)>eps));
    takeoff=min(find(truth.sim.vel_topo.Data(:,3)>eps));
  else
    dt=telem.est.vel.Time(2)-telem.est.vel.Time(1);
    dn=50;
    touchdown=max(find(telem.est.vel.Data(:,3)>eps));
    takeoff=min(find(telem.est.vel.Data(:,3)>eps));
  end
  
  if ~isempty(takeoff)
    xlim([floor(dt*(takeoff-dn)/5)*5   ceil(dt*(touchdown+dn)/5)*5]);
    figure(fig_numbers(3));ylim([-2 2])
  else
    clear dt touchdown takeoff
  end
end


%%
% %-------------------------------------------------------------------------%
% %-----                      CNT EUL ERR                              -----%
% fnum = 7;
% RowNum = 2;
% ColNum = 4;
% row = maxrow - (RowNum-1)*(height+4*border) ;
% col = (ColNum-1)*(width+border) + mincol;
% %-------------------------------------------------------------------------%
%
% figure(fnum); clf; set(fnum,'Position',[col row-50 width height])
%
% if plot_truth && plot_est
%     plot(telem.cnt_error_eul_xyz*180/pi ,'LineWidth',2); grid on;box on; hold on;
%     Mrate = {'Body X','Body Y','Body Z'};
%
%     title('Euler 123 Attitude Command Error Relative to Topo Frame','fontsize',14)
%     legend(Mrate,'Location','NorthEast','fontsize',10)
%     xlabel('time (sec)','fontsize',14)
%     ylabel('degrees','fontsize',14)
% end
% %saveas(gcf,'EulerErrors.png');%saveas(gcf,'EulerErrors.fig')
%
%
% %-------------------------------------------------------------------------%
% %-----                      EST VEL ERR                              -----%
% fnum = 8;
% RowNum = 2;
% ColNum = 5;
% row = maxrow - (RowNum-1)*(height+4*border) ;
% col = (ColNum-1)*(width+border) + mincol;
% %-------------------------------------------------------------------------%
%
% figure(fnum);clf;set(fnum,'Position',[col row-50 width height]);
% if plot_truth && plot_est
%     plot(error.vel_topo); grid on;box on;
%
%     ylabel('External Velocity Estimator Error (m/s)','fontsize',14)
%     xlabel('Time (sec)','fontsize',14)
%     title('Topo: External Velocity Estimator Error (m/s)','fontsize',14)
% end
% %saveas(gcf,'VelEstErr.png');%saveas(gcf,'VelEstErr.fig')
%
% %-------------------------------------------------------------------------%
% %-----                          EUL EST ERR                          -----%
% fnum = 9;
% RowNum = 2;
% ColNum = 4;
% row = maxrow - (RowNum-1)*(height+4*border) ;
% col = (ColNum-1)*(width+border) + mincol;
% %-------------------------------------------------------------------------%
%
% figure(fnum); clf; set(fnum,'Position',[col row-50 width height])
% if plot_truth && plot_est
%     plot(error.euler.Time, mod(360,error.euler.Data) ,'LineWidth',2); grid on;box on; hold on;
%     Mrate = {'Body X','Body Y','Body Z'};
%
%     title('Euler 123 Attitude Estimation Error Relative to Topo Frame','fontsize',14)
%     legend(Mrate,'Location','NorthEast','fontsize',10)
%     xlabel('time (sec)','fontsize',14)
%     ylabel('degrees','fontsize',14)
% end
% %saveas(gcf,'EulerEstErrors.png');%saveas(gcf,'EulerEstErrors.fig')
%




