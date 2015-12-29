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
% plot_all_datasets.m                                                     %
%                                                                         %
% plot signal from all collected datasets                                 %
% 02/14/15                                                               %
%-------------------------------------------------------------------------%


function plot_all_datasets(data_collection, signal_name)

if ~isa(signal_name, 'cell')
    signal_name_cell = cell(signal_name);
else
    signal_name_cell = signal_name;
end

try
    name_struct = evalin('base','name_struct');
catch
    error('Create name_strcut in base workspace and try again')
end

% extract struct names
set_names = fieldnames(data_collection);
n_sets = length(set_names);

fig = figure;
grid on
hold on


legend_cell = {};
title_string = '';

signals_plotted = 1;

for jj = 1 : length(signal_name_cell)
 
        [app, mnemonic] = strtok(signal_name{jj}, '.');   
        
    for ii = 1 : n_sets


        plot(data_collection.(set_names{ii}).(app).(mnemonic(2:end)))
        
        num_sig = min(size(squeeze(data_collection.(set_names{ii}).(app).(mnemonic(2:end)).Data)));
        
        for kk = 1 : num_sig
            if length(signal_name_cell) > 1
                legend_cell{signals_plotted} = [latex_prep(set_names{ii}) ' : ' latex_prep(signal_name{jj}) ' : signal ' num2str(kk)];
            else
                legend_cell{signals_plotted} = [latex_prep(set_names{ii}) ' : signal ' num2str(kk)];
            end
            signals_plotted = signals_plotted + 1;
        end
        
    end
    
    if jj == length(signal_name_cell)
        title_string = strcat(title_string, [signal_name{jj} ]);
    else
        title_string = strcat(title_string, [signal_name{jj} ' & ' ]);
    end
end


legend(legend_cell,'fontsize',11,'FontName','Courier')

title(['Compare: ' latex_prep(title_string)],'fontsize',14,'FontName','Courier')
xlabel('time (sec)','fontsize',14,'FontName','Courier')
% ylabel('','fontsize',14,'FontName','Courier')
