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
% compare_scenario_results.m                                              %
%                                                                         %
% brings in two data sets into workspace for line by line comparison      %
% 05/01/14                                                                %
%-------------------------------------------------------------------------%

% get scenario directory for first test set
data_1_dir = uigetdir(pwd);
data_1_name = inputdlg('Enter variable name to describe first data set','Data 1 Name');
data_1_name = data_1_name{1};

% get scenario directory for second test set
data_2_dir = uigetdir(pwd);
data_2_name = inputdlg('Enter variable name to describe second data set','Data 1 Name');
data_2_name = data_2_name{1};

%%
% load in those data set into the default variable names
process_test_data(data_1_dir);

% change all the names to use the user specified name
eval([data_1_name '_telem = telem;'])
eval([data_1_name '_truth = truth;'])
eval([data_1_name '_error = error;'])
eval([data_1_name '_analysis = analysis;'])

clear telem truth error analysis

% load in those data set into the default variable names
process_test_data(data_2_dir);

% change all the names to use the user specified name
eval([data_2_name '_telem = telem;'])
eval([data_2_name '_truth = truth;'])
eval([data_2_name '_error = error;'])
eval([data_2_name '_analysis = analysis;'])

clear telem truth error analysis
%%
% create the standard plots and link them all together
eval( ['plot_test_data(' data_1_name '_telem,' data_1_name '_truth, ' data_1_name '_error, ''WSIM'', ''' data_1_name  ''');'] )

eval( ['plot_test_data(' data_2_name '_telem,' data_2_name '_truth, ' data_2_name '_error, ''PHIL'',''' data_2_name ''');'] )

% link all the standard figs
link_fig_axes([1 2 3 4 5 6 11 12 13 14 15 16])

% kill the attitude error plot
try
    close(100)
catch
end

% bring back attitude error plots for both
data_1_fig_handle = figure(90);
eval( ['plot_angular_errors(''all'',data_1_fig_handle, '  data_1_name '_error, '  data_1_name '_analysis)'])
figure(90); subplot(2,1,1); title(latex_prep([data_1_name ' : Total Attitude Pointing Error']),'FontName','Courier','FontSize',16)
ylim_90_pointing = ylim;
figure(90); subplot(2,1,2); title(latex_prep([data_1_name ' : Total Attitude Knowledge Error']),'FontName','Courier','FontSize',16)
ylim_90_knowledge = ylim;

data_2_fig_handle = figure(91);
eval( ['plot_angular_errors(''all'',data_2_fig_handle, '  data_2_name '_error, '  data_2_name '_analysis)'])
figure(91); subplot(2,1,1); title(latex_prep([data_2_name ' : Total Attitude Pointing Error']),'FontName','Courier','FontSize',16)
ylim_91_pointing = ylim;
figure(91); subplot(2,1,2); title(latex_prep([data_2_name ' : Total Attitude Knowledge Error']),'FontName','Courier','FontSize',16)
ylim_91_knowledge = ylim;

% get vertical axes the same between data sets
% pointing
ymin = min([ylim_90_pointing ylim_91_pointing]);
ymax = max([ylim_90_pointing ylim_91_pointing]);
figure(90); subplot(2,1,1); ylim([ymin ymax])
figure(91); subplot(2,1,1); ylim([ymin ymax])

% knowledge
ymin = min([ylim_90_knowledge ylim_91_knowledge]);
ymax = max([ylim_90_knowledge ylim_91_knowledge]);
figure(90); subplot(2,1,2); ylim([ymin ymax])
figure(91); subplot(2,1,2); ylim([ymin ymax])


link_fig_axes([90 91])