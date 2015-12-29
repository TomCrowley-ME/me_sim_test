% This script exports all figures to powerpoint
%

%% Define powerpoint output file name and properties
pptFile      = 'FEB_27_2015_Data_Review';
templateDir  = cat(2,getenv('NIMBUS_ROOT'),filesep,'telemetry_processing');
templateFile = 'template';
date         = '27 February 2015';
pptTitle     = sprintf('KSC 2nd Test Campaign\nTether Test Data Review');
author       = 'Moon Express, Inc.';
subject      = 'Tether Test';
comments     = 'Confidential and Proprietary - Do not copy, reproduce or distribute without permission.';

%% Define width and height of figures and text boxes 
title_width  = 8.8;  % inches
title_height = 2.0;
date_width   = 8.8;
date_height  = 0.5;

fig_width    = 5.0;
fig_height   = 4.0;
text_width   = 8.0;
text_height  = 1.0;

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
figs=get(0,'Children');
for i=1:length(figs)

    % get figure handle
    figH=figure(i);

    % add slide to presentation
    slideNum = exportToPPTX('addslide');
    fprintf('Adding Figure %d to slide %d\n',i,slideNum);

    % add figures to slide
    exportToPPTX('addpicture',figH,'Position',[3 1.2 fig_width fig_height]);
    % exportToPPTX('addpicture',figH,'Scale','maxfixed');

    % add subject to slide
    exportToPPTX('addtext',sprintf('%s, %s',date,subject), ...
                 'Position',[1.7 0.3 text_width text_height], ...
                 'Font','Calibri', ...
                 'FontSize',36,...
                 'FontWeight','bold', ...
                 'Shadow','on', ...
                 'VerticalAlignment','middle',...
                 'HorizontalAlignment','center');

    % add note to slide
    % exportToPPTX('addnote',sprintf('Notes: slide number %d',slideNum));
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

