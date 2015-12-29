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
% load_test_data.m                                                        %
%                                                                         %
% loads data from directory, either phil or wsim                          %
% 05/30/13                                                                %
%-------------------------------------------------------------------------%

function [ scenario_data run_type error_flag ] = load_test_data( directory,load_image_data, varargin )

error_flag = 0;
scenario_data = [];
run_type = [];


%-------------------------------------------------------------------------%
% determine if chewing on PHIL or WSIM data

listing = dir(directory);

% list only those files which are .mat
mat_listing = listing(~cellfun(@isempty,regexpi({listing(:).name},'\.mat$')));

% list only those files which are .csv
csv_listing = listing(~cellfun(@isempty,regexpi({listing(:).name},'\.csv$')));

% ESC: this logic is hacky, should be improved as we get a better idea of what files will actually be around
if isempty( mat_listing ) && ~isempty( csv_listing )
    run_type = 'PHIL';
    listing = csv_listing;
elseif ~isempty( mat_listing ) && isempty( csv_listing )
    run_type = 'WSIM';
    listing = mat_listing;
else
    error_flag = 1;
    error('Ambiguous files in directory listing. Looking for either .mat or .csv files')
end

image_file_list = {'cfp_msg','cma_camera_msg','cmb_camera_msg'};

if nargin > 2
    file_whitelist = varargin{1};
else
    file_whitelist = { 'cmp_bus_msg', 'est_bus_msg', 'est_mtv_msg', 'gdn_bus_msg', 'cnt_bus_msg', 'cnt_tlm_msg', 'act_bus_msg', ...
                       'pcs_bus_msg','tcs_bus_msg', ...
                       'adio_msg', 'sta_msg','ldr_msg', 'mem_msg','gps_msg', 'imu_msg', ...
                       'cmp_mtv_msg','act_mtv_msg', 'egc_bus_msg', 'egcio_msg', ...
                       'sim_tlm_msg', 'sim_data_bus_msg', 'sim_data_mtv_msg', 'egc_veh_msg', 'thr_sim_msg', 'mem_veh_msg', 'imu_veh_msg', 'adio_veh_msg'};
end
%-------------------------------------------------------------------------%
% load in all files (of the appropriate type) in the directory

% structure is scenario_data.bus_name = whatever

switch run_type
    
    case 'WSIM'
        
        %- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -%
        for jj = 1 : length( listing )
            
            bus_name = listing(jj).name(1:end-4); %get rid of .mat
            
            if strcmp(bus_name, 'event_plot_data')
                continue;
            end
            
            if (load_image_data) || ( ~load_image_data && ~any( strcmp(bus_name,image_file_list) ) )
                
                fprintf(1,'Loading file for %s\n',bus_name);
                
                load( [directory filesep listing(jj).name] )
                
                scenario_data.(bus_name) = data;
            end

            
            
            
        end
        
    case 'PHIL'
        %- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -%
        for jj = 1 : length( listing )
            
            bus_name = listing(jj).name(1:end-4); %get rid of .csv
            if ~any(strcmp(bus_name, file_whitelist))
                continue;
            end
            
            fprintf(1,'Loading file for %s\n',bus_name);
                       
            loaded_data = importdata( [directory filesep listing(jj).name] );
            
            % sort out textdata if its borked
            n_cell = length(loaded_data.textdata);
            
            if n_cell == 1
                name_cell = regexp(loaded_data.textdata{1}, '[^\w\d]+', 'split');
            else
                name_cell = regexprep(loaded_data.textdata','^\s+','');
            end
            
            
            % Pull out the names of the messages (ignoring the first column
            % since it's time) and strip off the bus name
            names = cellfun(@(name) {strrep(name, [bus_name '_'], '')}, name_cell);
            
      
            % Grab the start time of the CSV and subtract it from the whole
            % time column to give a nice 0-based time
            %start_time = loaded_data.data(1,1);
            %time = (loaded_data.data(:, 1) - start_time)/100;
            
            time = loaded_data.data(:, 1);
            
            % ESC : pass through raw ccsds times for now, figure out if
            % this is right strategy in general
            
            % Tell matlab that we're making a struct in scenario_data
            scenario_data.(bus_name) = struct;
            
            for kk = 1 : length(names)
                % Figure out the base name of the signal, and if we haven't
                % already processed it, make a new timeseries
                base_name = regexprep(names{kk}, '_\d+$', '');
                if ~isfield(scenario_data.(bus_name), base_name)
                    named_data = extract_named_data(base_name, name_cell, loaded_data.data);
                    scenario_data.(bus_name).(base_name) = timeseries(named_data, time);
                end
            end
        end

end