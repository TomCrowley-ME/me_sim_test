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
% plot_angular_errors.m                                                   %
%                                                                         %
% plots attitude errors by mode                                           %
% 04/14/14                                                                %
%-------------------------------------------------------------------------%

function plot_angular_errors(varargin)

% look for error structure argument
if nargin > 0
    mode_of_interest = varargin{1};
else
    fprintf(2,'Warning: no mode of interest argument can be found. Assuming ''all''.\n')
    mode_of_interest = 'all';
end

% look for error structure argument
if nargin > 1
    fig_num = varargin{2};
end
    
% look for analysis structure argument
if nargin > 2
    error = varargin{3};
else
    try
    error = evalin('base','error');
    catch
        fprintf(2,'Error: no error structure argument can be found\n')
        error = [];
    end
end

% look for figure number
if nargin > 3
    analysis = varargin{4};
else
    try
    analysis = evalin('base','analysis');
    catch
        fprintf(2,'Error: no analysis structure argument can be found\n')
        analysis = [];
    end
end

if isempty(error) || isempty(analysis)
    fprintf(2,'Do not have appropriate input values. Cannot plot. Exiting...\n')
    return
end


% put this at figure 100 if no fig number is input
if exist('fig_num','var')
    figure(fig_num); clf
else
    fig_num = 100;
    figure(100); clf
end
set(gcf,'Position',[1017 142 633 844])
set(gcf,'Name','Total Attitude Pointing & Knowledge Errors')


% pointing in first subplot
subplot(2,1,1)
plot(error.pointing.total.angle.Time, error.pointing.total.angle.Data,'k');
grid on; hold on;
pointing_legend = {'Pointing Error'};

% knowledge in second subplot
subplot(2,1,2)
plot(error.knowledge.total.angle.Time, error.knowledge.total.angle.Data,'k');
grid on; hold on;
knowledge_legend = {'Knowledge Error'};

% what modes are in the analysis structs?
mode_structs = fieldnames(analysis);


if strcmp(mode_of_interest,'all')
    mode_id = find( strcmp(mode_structs,mode_structs) );
else
    % find the mode of interest if given specifically
    mode_id = find( strcmp(mode_of_interest,mode_structs) );
end

if isempty(mode_id)
    fprintf(2,'Bad mode string argument. Do better.\n')
    return
end


% map submodes to colors for conistency across runs
[~, submode_name] = enumeration('enum_submode');
submode_color = { rgb('blue')  , ... % none
                  rgb('red')   , ... % active
                  rgb('green') , ... % coast
                  rgb('orange') , ... % hold
                  rgb('purple') , ... % targeting
                  rgb('deeppink') , ... % terminal
                  };

for qq = 1 : length(mode_id)

  which_mode = mode_id(qq);

  if strcmp( mode_structs{which_mode}, 'startup') || strcmp( mode_structs{which_mode}, 'surface')
      % don't bother with pointing during these modes
      continue
  else

      % look for submode structures within this mode
      submode_structs = fieldnames( analysis.(mode_structs{which_mode}) );
      n_submodes = length(submode_structs);

      for kk = 1 : n_submodes

          if analysis.(mode_structs{which_mode}).(submode_structs{kk}).exhibited == 1

              colorid = find( strcmp(submode_structs{kk}, submode_name) );

              % pointing
              subplot(2,1,1)
              [t x] = insert_nan_breaks_for_plot(analysis.(mode_structs{which_mode}).(submode_structs{kk}).pointing.total_angle_deg);
%               plot(analysis.(mode_structs{which_mode}).(submode_structs{kk}).pointing.total_angle_deg,'Marker','o','Color',submode_color{colorid},'Line','-')
              plot(t, x,'Marker','o','Color', submode_color{colorid},'LineStyle','-')
              pointing_legend = cat(1, pointing_legend,[mode_structs{which_mode} ' : ' submode_structs{kk}]);

              % knowledge
              subplot(2,1,2)
              [t x] = insert_nan_breaks_for_plot(analysis.(mode_structs{which_mode}).(submode_structs{kk}).knowledge.total_angle_deg);
              plot(t, x, 'Marker','s','Color',submode_color{colorid},'LineStyle','-')
              knowledge_legend = cat(1, knowledge_legend,[mode_structs{which_mode} ' : ' submode_structs{kk}]);

          end

      end
  end

end

subplot(2,1,1)
legend(latex_prep(pointing_legend),'Location','NorthWest')
ylabel('degrees','FontName','Courier','FontSize',14)
xlabel('time (sec)','FontName','Courier','FontSize',14)
title('Total Attitude Pointing Error','FontName','Courier','FontSize',16)

subplot(2,1,2)
legend(latex_prep(knowledge_legend),'Location','NorthWest')
ylabel('degrees','FontName','Courier','FontSize',14)
title('Total Attitude Knowledge Error','FontName','Courier','FontSize',16)
xlabel('time (sec)','FontName','Courier','FontSize',14)

link_fig_axes(fig_num)

function [t x] = insert_nan_breaks_for_plot(ts_data)

break_index = find(diff(ts_data.Time)>0.11)+1;
if isempty(break_index)
    t = ts_data.Time;
    x = ts_data.Data;
    return
end
break_index = [1 ; break_index; length(ts_data.Time)];
t = [];
x = [];
n_cols = size(ts_data.Data,2);

for kk = 2 : length(break_index)
    t = cat(1, t, [ ts_data.Time(break_index(kk-1):break_index(kk)-1) ]);
    t = cat(1, t, NaN);
    
    x = cat(1, x, [ ts_data.Data(break_index(kk-1):break_index(kk)-1,:) ]);
    x = cat(1, x, NaN(1, n_cols));
    
end

   
