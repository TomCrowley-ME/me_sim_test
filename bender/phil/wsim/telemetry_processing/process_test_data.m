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
% process_test_data.m                                                     %
%                                                                         %
% processes data from either wsim or phil (more?) for analysis/plots      %
% Inputs: 1. relative or absolute path to dir containing test csv file    %
% **if no input argument provided, current directory is attempted         %
%                                                                         %
% Output: 1. telem : structure containing fsw telemetry data              %
%         2. truth : structure containing sim telemetry data              %
% **if no output argument provided, telem & truth assigned in base        %
%                                                                         %
% 05/30/13                                                                %
% eleanorcrane@moonexpress.com                                            %
%-------------------------------------------------------------------------%

function varargout = process_test_data( varargin )

if nargin > 0
    directory = varargin{1};
else
    directory = pwd;
    D=dir;
    for i=1:size(D,1)
      if strncmp(getfield(D(i),'name'),'scn',3)
        scnNum=D(i).name(1:min(strfind(D(i).name,'_')-1));
        directory=strcat(scnNum,'_wsim_data',filesep);
        break
      end
    end
end

nominal_exit = 0;
error_flag = 0;

% use this flag to load in pixels/camera bus/etc
load_image_data_flag = 0;

while error_flag == 0 && nominal_exit == 0
    
    %-------------------------------------------------------------------------%
    % determine scenario number (if applicable)
    scn_number_tokens = regexpi(directory, 'scn(\d+)', 'tokens');
    if isempty(scn_number_tokens)
        fprintf(1,'Scenario number not assigned for this run\n');
        scn_number = 0;
    else
        scn_number = str2double(scn_number_tokens{end}{1});
    end

    
    % look for scenario (sim proc) data in the workspace
    test_for_sim_parameters_in_workspace = evalin( 'base', 'exist(''ini_epoch_seconds'',''var'')');
    
    % if no scenario data, load sim proc for scenario
    if ~test_for_sim_parameters_in_workspace
        try
        load_scenario_information(['scenario_' num2str(scn_number)]);
        catch
            fprintf(1,'no load_scenario')
        end
    end


    %-------------------------------------------------------------------------%
    % load test data

    [ scenario_data, run_type , error_flag ] = load_test_data( directory, load_image_data_flag );

    
    %-------------------------------------------------------------------------%
    % extract data

    [ telem, error_flag ] = extract_all_telem( scenario_data, 'fsw' );

    [ truth, error_flag ] = extract_all_telem( scenario_data, 'sim' );


    %-------------------------------------------------------------------------%
    % sync time on message
    
    switch run_type
        case 'WSIM'
            [telem, truth] = wsim_telemetry_synchronization(telem, truth);
            
        case 'PHIL'
            [telem, truth] = hil_telemetry_synchronization(telem, truth, directory);
            
        otherwise
            error_flag = 1;
    end
    
    %-------------------------------------------------------------------------%
    % print out event log if it's there
    load_event_log(directory);

    %-------------------------------------------------------------------------%
    % derive values
    
    % create flag for MTV vs MX data
    if any(ismember(fieldnames(scenario_data),'cmp_mtv_msg'))
        earth_vehicle_flag = 1;
    else
        earth_vehicle_flag = 0;
    end

    [ telem, truth, error ] = derive_values(telem, truth, earth_vehicle_flag);

    %-------------------------------------------------------------------------%
    % do analysis
    
    if ~isempty( error )
        [ analysis ] = gnc_requirements_analysis(telem, truth, error);
    else
        analysis = [];
    end

    try
        touchdown_evaluation(telem, truth)
    catch
        fprintf(1, 'some sort of problem with touchdown_evaluation\n')
    end

    %-------------------------------------------------------------------------%
    % return data to workspace and/or save

    if nargout > 0
        varargout{1} = telem;
        varargout{2} = truth;
    else
        assignin('base','telem', telem)
        assignin('base','truth', truth)
        assignin('base','error', error)
        if exist('analysis','var')
            assignin('base','analysis', analysis)
        end
    end
    nominal_exit = 1;

end

if error_flag
    fprintf(2,'Could not complete successfully.\n')
    return
end

%-------------------------------------------------------------------------%
% plot

% load in all of the plotting preferences
if exist('wsim_prefs.m','file')
    wsim_prefs;
else
    pref_plot_test_data       = 1;
    pref_plot_attitude_errors = 0;
    pref_plot_phase_plane_c   = 0;
    pref_plot_phase_plane_v   = 1;
    pref_plot_prop_data       = 0;
    pref_export_to_ppt        = 0;
end

if pref_plot_test_data
    plot_test_data(telem, truth, error, run_type)
end

if pref_plot_attitude_errors
    plot_angular_errors('all', figure(100), error, analysis)
end

if pref_plot_phase_plane_c
    plot_phase_planes_coarse
end

if pref_plot_phase_plane_v
    plot_phase_planes_vernier
end

if pref_plot_prop_data && earth_vehicle_flag
    plot_prop_data(telem, run_type)
end

%-------------------------------------------------------------------------%
% export figures to powerpoint
if pref_export_to_ppt
    scenario_to_ppt
end



