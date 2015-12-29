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
% load_multiple_datasets.m                                                %
%                                                                         %
% loads data from directory, either phil or wsim                          %
% 02/14/15                                                                %
%-------------------------------------------------------------------------%

function load_multiple_datasets

% load in as many data sets as you want

while 1

    % get scenario directory for test set
    data_dir = uigetdir(pwd,'Select folder to load data. Click cancel when all datasets loaded,');
    
    if isa(data_dir,'double')
        break
    end
    
    data_name = inputdlg('Enter variable name to describe first data set','Data 1 Name');
    data_name = data_name{1};
    
    % load in those data set into the default variable names
    telem_struct = process_test_data(data_dir);
    
    eval(['data.' data_name ' = telem_struct;'])
    
    clear telem_struct
    
end
%%
% find signal to sync all data sets to

dataset_names = fieldnames(data);
n_datasets = length(dataset_names);

for jj = 1 : n_datasets
    
    telem_struct = data.(dataset_names{jj});
    
    % find index for the start of landing mode
%     landing_index = find(telem_struct.cmp.mode.Data == enum_mode.landing,1);
    landing_index = find(telem_struct.egc.throttle.Data > 0, 1) - 50;

    
    if isempty(landing_index)
        fprintf(2, 'Cannot find sync pattern in data. Moving on\n')
        break
    end
    
    telem_struct = resize_telem_struct(telem_struct, landing_index);
    
    data.(dataset_names{jj}) = telem_struct;
    
end

% create name structure to reference signals
name_struct = create_telem_name_struct(telem_struct);


% assign structures out to base
assignin('base','data',data)
assignin('base','name_struct',name_struct)
