% This script exports scenario figures to powerpoint
%
if exist('run_type','var')<1
    if exist('scenario_num')
        run_type = 'WSIM';
    else
        run_type = 'PHIL';
    end
end

D=dir;
date_num=datenum(D(3).date); 
if exist('scenario_num','var')<1
    for i=1:size(D,1)
      if strncmp(getfield(D(i),'name'),'scn',3)
        scenario_num=str2num(D(i).name(4:min(strfind(D(i).name,'_')-1)));
        date_num=datenum(getfield(dir(sprintf('scn%d_wsim_data',scenario_num)),'date'));
        break
      end
    end
end
%%
if exist('wsim_prefs.m','file')
    wsim_prefs;
else
    pref_plot_test_data       = 1;
    pref_plot_attitude_errors = 1;
    pref_plot_phase_plane     = 1;
    pref_plot_prop_data       = 1;
end

%% Define powerpoint output file name and properties
switch run_type
  case 'WSIM'
    pptFile  = sprintf('Scen%d_%s',scenario_num,datestr(date_num,'mmm_dd_yyyy'));
    pptTitle = sprintf('Scenario %d %s Data Review',scenario_num,run_type);
    subject  = sprintf('Scenario %d',scenario_num);
  case 'PHIL'
    pptFile  = sprintf('%s_Flight_Test',datestr(date_num,'mmm_dd_yyyy'));
    pptTitle = sprintf('Flight Test Data Review');
    subject  = sprintf('%s Flight Test',datestr(date_num,'dd mmmm yyyy'));
end

templateDir  = cat(2,getenv('NIMBUS_ROOT'),filesep,'telemetry_processing');
templateFile = 'template';
date         = datestr(date_num,'dd mmmm yyyy    HH:MM:SS');
author       = 'Moon Express, Inc.';
comments     = 'Confidential and Proprietary - Do not copy, reproduce or distribute without permission.';

%% Define width and height of figures and text boxes 
title_width  = 8.8;  % inches
title_height = 2.0;
date_width   = 8.8;
date_height  = 0.5;

text_width   = 8.0;
text_height  = 1.0;

%% Define figures to put on each page

num=0;
if pref_plot_test_data
  num=num+1;
  page(num).figs=strvcat('Position',...
                         'Velocity',...
                         'Acceleration',...
                         'Body Rates');
  num=num+1;
  page(num).figs=strvcat('Body Rates',...
                         'Euler 321');
end

if pref_plot_attitude_errors
  num=num+1;
  page(num).figs=strvcat('Total Attitude Pointing & Knowledge Errors');
end

if pref_plot_phase_plane
  num=num+1;
  page(num).figs=strvcat('True Phase Plane - X Axis',...
                         'True Phase Plane - Y Axis',...
                         'True Phase Plane - Z Axis',...
                         'Flight Phase Plane - X Axis',...
                         'Flight Phase Plane - Y Axis',...
                         'Flight Phase Plane - Z Axis');
  num=num+1;
  page(num).figs=strvcat('Phase Plane Errors',...
                         'Vertical Controller Performance');
end

if pref_plot_prop_data
  num=num+1;
  page(num).figs=strvcat('Thrust',...
                         'Pressure',...
                         'Forces',...
                         'Throttle Command and Position');
end
%% Start new presentation
isOpen  = exportToPPTX();

if ~isempty(isOpen),
    % If PowerPoint already started, then close first and then open a new one
    exportToPPTX('close');
end

%% Open existing template
exportToPPTX('open',cat(2,templateDir,filesep,templateFile));

%% Add title and date to first slide
exportToPPTX('addtext',sprintf('%s',pptTitle), ...
             'Position',[0.8 1.6 title_width title_height], ...
             'Font','Calibri', ...
             'FontSize',40,...
             'FontWeight','bold', ...
             'FontColor','w', ...
             'Shadow','on', ...
             'Outline','on', ...
             'HorizontalAlignment','center');

exportToPPTX('addtext',sprintf('%s',date), ...
             'Position',[0.8 3.5 date_width date_height], ...
             'Font','Calibri', ...
             'FontSize',24,...
             'FontWeight','bold', ...
             'FontColor','w', ...
             'Shadow','on', ...
             'HorizontalAlignment','center');
fprintf('Adding Title & Date to slide 1\n');

%% Create slides
h=get(0,'Children');
for i=1:length(page)
    n=size(page(i).figs,1);
    figH=[];

    % find figure handles
    for j=1:n
      for k=1:length(h)
        if strcmp(deblank(page(i).figs(j,:)),h(k).Name)
          figH=[figH; h(k)];
          break
        end
      end
    end

    % add slide to presentation
    slideNum = exportToPPTX('addslide');
    fprintf('Adding Figures to slide %d\n',slideNum);

    % add figures to slide
    exportToPPTX('addmulti',figH);

    % add subject to slide
    exportToPPTX('addtext',subject, ...
                 'Position',[1.6 0.1 text_width text_height], ...
                 'Font','Calibri', ...
                 'FontSize',36,...
                 'FontWeight','bold', ...
                 'Shadow','on', ...
                 'VerticalAlignment','middle',...
                 'HorizontalAlignment','center');
end

%% Check current presentation
% fileStats   = exportToPPTX('query');
% 
% if ~isempty(fileStats),
%     fprintf('Page size: %4.1f x %4.1f\n',fileStats.dimensions);
%     fprintf('Number of slides: %d\n',fileStats.numSlides);
% end

%% Save and close presentation -- overwrite file if it already exists
% Filename automatically checked for proper extension
exportToPPTX('save',pptFile);
exportToPPTX('close');

fprintf('New file has been saved: <a href="matlab:winopen(''%s'')">%s</a>\n',strcat(pptFile,'.pptx'),pptFile);

