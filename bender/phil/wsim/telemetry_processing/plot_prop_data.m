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
% plot_prop_data.m                                                        %
%                                                                         %
% plots data                                                              %
% 05/30/13                                                                %
%-------------------------------------------------------------------------%

function plot_prop_data(varargin)

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
    run_type = varargin{2};
else
    try
        run_type = evalin('base','run_type');
    catch
        fprintf(2,'Warning: no error argument can be found. Assume WSIM.\n')
        run_type = 'WSIM';
    end
end

if nargin > 2
    data_label = [varargin{3} ' : '];
else
    data_label = '';
end


switch run_type
    case 'PHIL'
        fig_numbers = [51 52 53 54 56 60 55];
    case 'WSIM'
        fig_numbers = [51 52 53 54 56 60 55];
    otherwise
        fig_numbers = [51 52 53 54 56 60 55];
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
    %-----                          THRUST                               -----%
    fnum = fig_numbers(1);
    RowNum = 1;
    ColNum = 1;
    row = maxrow - (RowNum-1)*(height+4*border) ;
    col = (ColNum-1)*(width+border) + mincol;
    %-------------------------------------------------------------------------%
    
    figure(fnum); clf; set(fnum,'Position',[col row-50 width height])

    plot(telem.prop.thrust_from_pc)
    grid on; hold on
    plot(telem.prop.thrust_from_throttle)
    plot(telem.egc.desired_thrust)
    
    plot(telem.est.mass*9.8065,'k')
    
    legend_cell = {'Chamber Pressure Calculation','Throttle Map Calculation','FSW Desired Thrust','Vehicle Weight'};
    
    legend(legend_cell,'Location','NorthWest','fontsize',11,'FontName','Courier')
    title([data_label 'Thrust'],'fontsize',14,'FontName','Courier')
    xlabel('time (sec)','fontsize',14,'FontName','Courier')
    ylabel('Newtons (N)','fontsize',14,'FontName','Courier')
    set(gcf,'Name','Thrust')
    
    %saveas(gcf,'Position.png');%saveas(gcf,'Position.fig')
    
    %-------------------------------------------------------------------------%
    %-----                        PRESSURE                               -----%
    fnum = fig_numbers(2);
    RowNum = 1;
    ColNum = 2;
    row = maxrow - (RowNum-1)*(height+4*border) ;
    col = (ColNum-1)*(width+border) + mincol;
    %-------------------------------------------------------------------------%
    
    figure(fnum); clf; set(fnum,'Position',[col row-50 width height])
    

    plot(telem.tcs.press_chamber)
    grid on; hold on
    plot(telem.tcs.press_acs)
    plot(telem.tcs.press_h2o2_tank)
    
    if size(telem.tcs.press_chamber.Data,2)>1
      legend_cell = {'Chamber Pressure 1','Chamber Pressure 2','ACS Pressure','Tank Pressure'};
    else
      legend_cell = {'Chamber Pressure','ACS Pressure','Tank Pressure'};
    end
    
    legend(legend_cell,'Location','NorthWest','fontsize',11,'FontName','Courier')
    title([data_label 'Pressure'],'fontsize',14,'FontName','Courier')
    xlabel('time (sec)','fontsize',14,'FontName','Courier')
    ylabel('Gauge Pressure','fontsize',14,'FontName','Courier')
    set(gcf,'Name','Pressure')
    %saveas(gcf,'Velocity.png');%saveas(gcf,'Velocity.fig')
    
    %-------------------------------------------------------------------------%
    %-----                        TOTAL FORCE                            -----%
    fnum = fig_numbers(3);
    RowNum = 1;
    ColNum = 3;
    row = maxrow - (RowNum-1)*(height+4*border) ;
    col = (ColNum-1)*(width+border) + mincol;
    %-------------------------------------------------------------------------%
    
    figure(fnum); clf; set(fnum,'Position',[col row-50 width height])
    
    legend_cell = {'EGC Body X','EGC Body Y','EGC Body Z','EGC + ACS Body X','EGC + ACS Body Y','EGC + ACS Body Z','Vehicle Weight'};

    egc_force = telem.prop.thrust_from_pc;
    egc_force.Data = [zeros(size(egc_force.Data,1),2) egc_force.Data];

    % determine number of chamber pressure measurements,
    % vehicle has two, but wsim has one
    if size(telem.prop.thrust_from_pc.Data,2)>1
        telem.prop.acs_body_force.Data = [telem.prop.acs_body_force.Data telem.prop.acs_body_force.Data(:,3)];
        legend_cell = {'EGC Body X','EGC Body Y','EGC1 Body Z','EGC2 Body Z','EGC + ACS Body X','EGC + ACS Body Y','EGC1 + ACS Body Z','EGC2 + ACS Body Z','Vehicle Weight'};
    end
    
    plot(egc_force)
    grid on; hold_colors
    plot(egc_force + telem.prop.acs_body_force,'LineWidth',2)
    plot(telem.est.mass*9.8065,'k')
    
    legend(legend_cell,'Location','NorthWest','fontsize',11,'FontName','Courier')
    
    title([data_label 'Body Frame Thruster Forces'],'fontsize',14,'FontName','Courier')
    xlabel('time (sec)','fontsize',14,'FontName','Courier')
    ylabel('m/s^2','fontsize',14,'FontName','Courier')
    set(gcf,'Name','Forces')
    %saveas(gcf,'Acceleration.png');%saveas(gcf,'Acceleration.fig')
    
    %-------------------------------------------------------------------------%
    %-----                         TORQUE                                -----%
    fnum = fig_numbers(4);
    RowNum = 2;
    ColNum = 1;
    row = maxrow - (RowNum-1)*(height+4*border) ;
    col = (ColNum-1)*(width+border) + mincol;
    %-------------------------------------------------------------------------%
    
    figure(fnum); clf; set(fnum,'Position',[col row-50 width height])
    
    legend_cell = {'ACS Body Troque X','ACS Body Torque Y','ACS Body Torque Z'};
    
    plot(telem.prop.acs_body_torque);
    grid on
    
    legend(legend_cell,'Location','NorthWest','fontsize',10,'FontName','Courier')
    
    title([data_label 'Body Torque'],'fontsize',14,'FontName','Courier')
    xlabel('time (sec)','fontsize',14,'FontName','Courier')
    ylabel('Nm','fontsize',14,'FontName','Courier')
    set(gcf,'Name','Body Torque')

    %saveas(gcf,'BodyRate.png');%saveas(gcf,'BodyRate.fig')
    
    %-------------------------------------------------------------------------%
    %-----                     ACS ACTIVITY                              -----%
    fnum = fig_numbers(5);
    RowNum = 2;
    ColNum = 2;
    row = maxrow - (RowNum-1)*(height+4*border) ;
    col = (ColNum-1)*(width+border) + mincol;
    %-------------------------------------------------------------------------%
    
    figure(fnum); clf; set(fnum,'Position', [431    18   864   482])
    legend_cell = {};
    
        i_begin = find(telem.egc.throttle.Data > 0,1)-10;
        i_end = find(telem.egc.throttle.Data > 0, 1,'Last');
        
        acsArray = min(telem.act.coarse_acs_cmds.Data(i_begin:i_end,:),100)/100;
        acsArray = [acsArray  5*(telem.egc.throttle.Data(i_begin:i_end)/65535)];
        h = bar3(telem.act.Time(i_begin:i_end), acsArray);
        
        axis equal;
        for i=1:numel(h)
            %# get the ZData matrix of the current group
            Z = get(h(i), 'ZData');
            %# row-indices of Z matrix. Columns correspond to each rectangular bar
            rowsInd = reshape(1:size(Z,1), 6,[]);
            %# find bars with zero height
            barsIdx = all([Z(2:6:end,2:3) Z(3:6:end,2:3)]==0, 2);
            %# replace their values with NaN for those bars
            Z(rowsInd(:,barsIdx),:) = NaN;
            %# update the ZData
            set(h(i), 'ZData',Z)
        end
    
    %legend(legend_cell,'Location','SouthWest','fontsize',10)
    
    axis tight
    view(-55, 25)
    
    title([data_label 'ACS Activity'],'fontsize',14)
    xlabel('Thruster ID','fontsize',14)
    ylabel('Time (sec)','fontsize',14)
    set(gcf,'Name','ACS Activity')
    
    
    %-------------------------------------------------------------------------%
    %-----                  PHASE PLANE TRQ ALLOCATION                   -----%
    fnum = fig_numbers(6);
    RowNum = 2;
    ColNum = 3;
    row = maxrow - (RowNum-1)*(height+4*border) ;
    col = (ColNum-1)*(width+border) + mincol;
    %-------------------------------------------------------------------------%
    figure(fnum); clf; set(fnum,'Position',[col row-150 width 2*height])
    grid on;box on; hold_colors; 
   
        subplot(2,1,1)
        
        plot(telem.cnt.error_eul_xyz*180/pi,'LineWidth',2)
        grid on; hold on;
        plot(telem.cnt.error_eul_xyz.Time, 0.5*ones(size(telem.cnt.error_eul_xyz.Data,1),1),'k--')
        plot(telem.cnt.error_eul_xyz.Time, -0.5*ones(size(telem.cnt.error_eul_xyz.Data,1),1),'k--')
        legend_cell = {'Body X Error','Body Y Error','Body Z Error','Angle Deadbands'};

        legend(legend_cell,'Location','NorthWest','fontsize',11,'FontName','Courier')
    
        title([data_label 'Controller Attitude Error: Body Frame'],'fontsize',14,'FontName','Courier')
        xlabel('time (sec)','fontsize',14,'FontName','Courier')
        ylabel('deg','fontsize',14,'FontName','Courier')
        
        subplot(2,1,2)
        
        plot(telem.cnt.coarse_acs_trq,'LineWidth',2)
        hold_colors
        plot(telem.prop.acs_body_torque_sign.Time, telem.prop.acs_body_torque_sign.Data(:,1),'o','MarkerSize',10)
        plot(telem.prop.acs_body_torque_sign.Time, telem.prop.acs_body_torque_sign.Data(:,2),'x','MarkerSize',10)
        plot(telem.prop.acs_body_torque_sign.Time, telem.prop.acs_body_torque_sign.Data(:,3),'+','MarkerSize', 8)

        grid on
        legend_cell = {'Body X Torque Cmd','Body Y Torque Cmd','Body Z Torque Cmd','Body X Torque Actual','Body Y Torque Actual','Body Z Torque Actual'};

        legend(legend_cell,'Location','NorthWest','fontsize',11,'FontName','Courier')
    
        title([data_label 'Phase Plane Controller Torque Allocation: Body Frame'],'fontsize',14,'FontName','Courier')
        xlabel('time (sec)','fontsize',14,'FontName','Courier')
        ylabel('deg','fontsize',14,'FontName','Courier')
        
        
        set(gcf,'Name','Phase Plane Errors')
        
    %-------------------------------------------------------------------------%
    %-----                VERTICAL CONTROLLER PERFORMANCE                -----%
    fnum = fig_numbers(7);
    RowNum = 2;
    ColNum = 3;
    row = maxrow - (RowNum-1)*(height+4*border) ;
    col = (ColNum-1)*(width+border) + mincol;
    %-------------------------------------------------------------------------%
    figure(fnum); clf; set(fnum,'Position',[col row-150 width 2*height])
    grid on;box on; hold_colors; 
   
        subplot(3,1,1)
        plot(telem.gdn.Time, [telem.gdn.commanded_position.Data(:,3) telem.gdn.commanded_velocity.Data(:,3)],'LineWidth',2);
        grid on; hold_colors;
        plot(telem.est.Time, [telem.est.pos.Data(:,3) telem.est.vel.Data(:,3)]);
        
        legend_cell = {'Pos Cmd','Vel Cmd', 'Pos Est', 'Vel Est'};
        legend(legend_cell,'Location','NorthWest','fontsize',11,'FontName','Courier')
    
        title([data_label 'Velocity Profiles'],'fontsize',14,'FontName','Courier')
        xlabel('time (sec)','fontsize',14,'FontName','Courier')
        ylabel('Command','fontsize',14,'FontName','Courier')
        
        subplot(3,1,2)
        pos_gdn = resample(telem.est.pos, telem.gdn.Time);
        vel_gdn = resample(telem.est.vel, telem.gdn.Time);
        pos_err = telem.gdn.commanded_position-pos_gdn;
        vel_err = telem.gdn.commanded_velocity-vel_gdn;
    
        plot(pos_err.Time, [pos_err.Data(:,3) vel_err.Data(:,3)]);
        grid on; hold on;
        
        legend_cell = {'Pos Error','Vel Error'};
        legend(legend_cell,'Location','NorthWest','fontsize',11,'FontName','Courier')
    
        title([data_label 'Guidance Error Z'],'fontsize',14,'FontName','Courier')
        xlabel('time (sec)','fontsize',14,'FontName','Courier')
        ylabel('Error','fontsize',14,'FontName','Courier')
        
        subplot(3,1,3)
        plot(egc_force.Time, egc_force.Data(:,3))
        grid on; hold_colors
        plot(egc_force.Time, egc_force.Data(:,3) + telem.prop.acs_body_force.Data(:,3),'LineWidth',2)
        plot(telem.gdn.desired_thrust,'m')
        
        legend_cell = {'EGC Body Z','EGC + ACS Body Z','Desired Thrust'};
        legend(legend_cell,'Location','NorthWest','fontsize',11,'FontName','Courier')
    
        title([data_label 'Axial Force'],'fontsize',14,'FontName','Courier')
        xlabel('time (sec)','fontsize',14,'FontName','Courier')
        ylabel('Newtons','fontsize',14,'FontName','Courier')
        

        
        
        set(gcf,'Name','Vertical Controller Performance')
        
        
        
        figure; plot(telem.egc.throttle); grid on; hold on; plot(telem.egc.position*0.37); 
         legend_cell = {'Throttle Command','Reported Throttle Position'};
        legend(legend_cell,'Location','NorthWest','fontsize',11,'FontName','Courier')
         title([data_label 'Throttle Command and Position'],'fontsize',14,'FontName','Courier')
        xlabel('time (sec)','fontsize',14,'FontName','Courier')
        ylabel('Counts (max 65535)','fontsize',14,'FontName','Courier')
        set(gcf,'Name','Throttle Command and Position')

fig_numbers_used = fig_numbers;
fig_numbers_used( fig_numbers_used == 0 ) = [];

link_fig_axes(fig_numbers_used([1:4 6 7]))




