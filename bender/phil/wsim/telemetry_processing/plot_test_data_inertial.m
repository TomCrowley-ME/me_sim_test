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
% plot_test_data_inertial.m                                               %
%                                                                         %
% plots data in inertial frame                                            %
% 05/30/13                                                                %
%-------------------------------------------------------------------------%

function plot_test_data_inertial(varargin)

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

if ~isempty(telem.est_vel.Data) % add future test for estimation frame
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
        fig_numbers = [11 12 13 14 15 16];
    case 'WSIM'
        fig_numbers = [1 2 3 4 5 6];
    otherwise
        fig_numbers = [1 2 3 4 5 6];
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

grid on;

if plot_est 
     hold on;
     plot(telem.est_local_pos);
    legend_cell = cat(1,legend_cell,'EST X','EST Y','EST Z');
end
legend(legend_cell,'Location','SouthEast','fontsize',14)
title('position','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('meters','fontsize',14)

% set ylimit automatically based on data
iTopo = find( telem.cmp_est_ref_frame.Data == 2);
iMCI  = find( telem.cmp_est_ref_frame.Data ~= 2);

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
    legend_cell = cat(1,legend_cell,'X','Y','MCI');
end
grid on;
if plot_est 
     hold on;
     plot(telem.est_vel);
    legend_cell = cat(1,legend_cell,'EST X','EST Y','EST Z');
end
legend(legend_cell,'Location','SouthEast','fontsize',14)
title('velocity','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('meters/sec','fontsize',14)
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
grid on;
if plot_est 
    hold on;
    plot(telem.est_accel);
    legend_cell = cat(1,legend_cell,'EST X','EST Y','EST Z');
end
legend(legend_cell,'Location','SouthEast','fontsize',14)

title('acceleration in Inertial frame','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('m/s^2','fontsize',14)
%saveas(gcf,'Acceleration_mci.png');%saveas(gcf,'Acceleration_mci.fig')

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
    legend_cell = cat(1,legend_cell,'Body X','Body Y','Body Z');
end
grid on;
if plot_est 
    hold on;
    plot(telem.est_rate*180/pi);
    legend_cell = cat(1,legend_cell,'EST Body X','EST Body Y','EST Body Z');
end
legend(legend_cell,'Location','SouthEast','fontsize',14)

title('Body Rates','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('degrees/sec','fontsize',14)
%saveas(gcf,'BodyRate.png');%saveas(gcf,'BodyRate.fig')

%-------------------------------------------------------------------------%
%-----                          EUL                                 -----%
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
    legend_cell = cat(1,legend_cell,'Body X','Body Y','Body Z');
end

grid on; 

if plot_est 
    hold on;
    plot(telem.est_euler_xyz);
    legend_cell = cat(1,legend_cell,'EST Body X','EST Body Y','EST Body Z');
end
legend(legend_cell,'Location','SouthEast','fontsize',14)

title('euler 321','fontsize',14)
xlabel('time (sec)','fontsize',14)
ylabel('degrees','fontsize',14)
%saveas(gcf,'EulerAngles.png');%saveas(gcf,'EulerAngles.fig')

%-------------------------------------------------------------------------%
%-----                          Pos and Vel Err                                 -----%
fnum = fig_numbers(6);
RowNum = 2;
ColNum = 3;
row = maxrow - (RowNum-1)*(height+4*border) ;
col = (ColNum-1)*(width+border) + mincol;
%-------------------------------------------------------------------------%
figure(fnum); clf; set(fnum,'Position',[col row-150 width 2*height])
grid on; hold on;
legend_cell = {};

if plot_truth && plot_est
    subplot(2,1,1)
    plot(error.knowledge.total.pos)
    grid on; hold on;
    
    ylabel('External Position Estimator Error (m)','fontsize',14)
    title('mci: External Position Estimator Error (m)','fontsize',14)
    legend_cell = cat(1,legend_cell,'X','Y','Z');
    legend(legend_cell,'Location','SouthEast','fontsize',14)
end

legend_cell = {};
if plot_truth && plot_est
    subplot(2,1,2)
    plot(error.knowledge.total.vel)
    grid on; hold on;

    ylabel('External Velocity Estimator Error (m/s)','fontsize',14)
    xlabel('Time (sec)','fontsize',14)
    title('mci: External Velocity Estimator Error (m/s)','fontsize',14)
    legend_cell = cat(1,legend_cell,'X','Y','Z');
    legend(legend_cell,'Location','SouthEast','fontsize',14)
end




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
%     plot(telem.cnt_error_eul_xyz*180/pi ,'LineWidth',2); grid on; hold on;
%     Mrate = {'Body X','Body Y','Body Z'};
%     
%     title('Euler 123 Attitude Command Error Relative to Topo Frame','fontsize',14)
%     legend(Mrate,'Location','SouthEast','fontsize',14)
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
%     plot(error.vel_topo); grid on;
%     
%     ylabel('External Velocity Estimator Error (m/s)','fontsize',14)
%     xlabel('Time (sec)','fontsize',14)
%     title('Topo: External Velocity Estimator Error (m/s)','fontsize',14)
% end
% %saveas(gcf,'VelEstErr.png');%saveas(gcf,'VelEstErr.fig')
% 
% %-------------------------------------------------------------------------%
% %-----                          EUL EST ERR                              -----%
% fnum = 9;
% RowNum = 2;
% ColNum = 4;
% row = maxrow - (RowNum-1)*(height+4*border) ;
% col = (ColNum-1)*(width+border) + mincol;
% %-------------------------------------------------------------------------%
% 
% figure(fnum); clf; set(fnum,'Position',[col row-50 width height])
% if plot_truth && plot_est
%     plot(error.euler.Time, mod(360,error.euler.Data) ,'LineWidth',2); grid on; hold on;
%     Mrate = {'Body X','Body Y','Body Z'};
%     
%     title('Euler 123 Attitude Estimation Error Relative to Topo Frame','fontsize',14)
%     legend(Mrate,'Location','SouthEast','fontsize',14)
%     xlabel('time (sec)','fontsize',14)
%     ylabel('degrees','fontsize',14)
% end
% %saveas(gcf,'EulerEstErrors.png');%saveas(gcf,'EulerEstErrors.fig')
% 




