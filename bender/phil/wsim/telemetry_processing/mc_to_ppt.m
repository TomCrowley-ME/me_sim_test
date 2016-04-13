% This script exports selected .png files to powerpoint
%

%% Get date and time when MC was completed
D=dir;
for i=1:size(D,1)
  if ~isempty(strfind(D(i).name,'MC_WORKSPACE.mat'))
    date_num=datenum(D(i).date);
    break
  end
end

%% Define powerpoint output file name and properties
pptFile      = 'MTV EGC Vertical Control Monte Carlo';
pptFile      = 'MX-Single Stage Micro 50 lbf Main Biprop Monte Carlo';
pptTitle     = sprintf('MX-Single Stage Micro 50 lbf Main Biprop Monte Carlo');
subject      = sprintf('DOI to Landing Scenario Monte Carlo\n');

templateDir  = cat(2,getenv('NIMBUS_ROOT'),filesep,'telemetry_processing');
templateFile = 'template';
date         = datestr(date_num,'dd mmmm yyyy    HH:MM:SS');
author       = 'Moon Express, Inc.';
comments     = 'Confidential and Proprietary - Do not copy, reproduce or distribute without permission.';

%% Define width and height of text boxes 
title_width  = 8.8;  % inches
title_height = 2.0;
date_width   = 8.8;
date_height  = 0.5;

text_width   = 8.0;
text_height  = 1.0;

%% Define figures to put on each page

page(1).pics=strvcat(...
                     'TrueXPos.png',...
                     'TrueYPos.png',...
                     'TrueZPos.png'...
                     );
page(2).pics=strvcat(...
                     'TrueXVel.png',....
                     'TrueYVel.png',...
                     'TrueZVel.png'...
                     );
page(3).pics=strvcat(...
                     'LateralPosErr.png',...
                     'TruePosLateral.png'...
                     );
page(4).pics=strvcat(...
                     'TrueLatVelErrandVelEstErr.png',...
                     'TrueVertVelErrandVelEstErr.png',...
                     'VertVelEstErrandAltRangeErr.png'...
                     );
page(5).pics=strvcat(...
                     'LatVelocityMagvsAltitude.png',...
                     'VerticalVelvsAltitude.png',...
                     'VertVelEstErrandPropUsed.png',...
                     'CmdZVelErr.png'...
                     );
page(6).pics=strvcat(...
                     'HtpUsedMain.png',...
                     'HtpUsedAcs.png',...
                     'Rp1Used.png',...
                     'Gn2Used.png'...
                     );
page(7).pics=strvcat(...
                     'CgXPos.png',...
                     'CgYPos.png',...
                     'CgZPos.png'...
                     );
page(8).pics=strvcat(...
                     'MainEngMisalignandPosErr.png',...
                     'MainEngMisalignandPropUsed.png',...
                     'MainEngMisalignandRollTrq.png'...
                     );
page(9).pics=strvcat(...
                     'LateralMassOffsetandPosErr.png',...
                     'LateralCMAzimuthandPosErr.png',...
                     'LateralCMandPropUsed.png'...
                     );
page(10).pics=strvcat(...
                     'LateralCMandPropUsed.png',...
                     'LateralCMandLateralVel.png'...
                     );
page(11).pics=strvcat(...
                     'LateralVelandVerticalVel.png',...
                     'TrueLatVelErrandVelEstErr.png',...
                     'TDAngleandLateralVel.png',...
                     'TDAngleVsRate.png'...
                     );
% page(9).pics=strvcat('MassEstBiasSuccFail.png',...
%                      'EgcThrottleMdotSuccFail.png',...
%                      'EgcThrottleThrustSuccFail.png',...
%                      'EgcDesiredThrust.png',...
%                      'EgcWeightOffset.png',...
%                      'EgcThottle.png',...
%                      'EgcMisalignandPosErr.png',...
%                      'EgcMisalignAzandPosErr.png');

%% Start new presentation
isOpen  = exportToPPTX();
if ~isempty(isOpen),
    % If PowerPoint already started, then close first and then open a new one
    exportToPPTX('close');
end

%% Open template
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
for i=1:length(page)

    % add slide to presentation
    slideNum = exportToPPTX('addslide');
    fprintf('Adding Figures to slide %d\n',slideNum);

    % add figures to slide
    exportToPPTX('addmulti',page(i).pics);

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

