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
% csu_stm_simplified_temperature_model_test.m                             %
%                                                                         %
% 07/18/14                                                                %
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% % Call test init files 

nimbus_bus_all;
gbl_global_parameters_init;


	% call init files for block in question
    csc_stm_simplified_temperature_model_init
	% call supporting init files which are also required

	% define time step parameters (if applicable)
	sim_time_step_size = 1; % (seconds)
    fsw_dt = 0.1;
    

%-------------------------------------------------------------------------%
% % Call test prep files

	% call prep files for block in question (if applicable)

	% call supporting prep files which are also required
	

%-------------------------------------------------------------------------%
% % Set test parameters

	sim_dt = sim_time_step_size;

	t0 = 0;
	tFinal = 60*60;

	% create time vector for comparison/plotting
	t = [t0 : sim_dt : tFinal]';
	n = length(t);
    
    fsw_chunk = fsw_dt/sim_time_step_size;
    n_fsw = (n-1)/fsw_chunk;

    
%-------------------------------------------------------------------------%
% % load in test data to use as input

%-------------------------------------------------------------------------%
% % assign values to test inputs

	% % use struct input specification
	% variable_structure_in.time = t;
	% variable_structure_in.signals.values = typecast( rand(n,4), [0 255]);
	% variable_structure_in.signals.dimensions = [ 4 ];

	% % ESC: checkout typed/nonfinite inputs
    
    test_heater_idx = 1;
    
%     cnt_cmd_fsw_rate = zeros(n_fsw,1);
%     cnt_cmd_fsw_rate(:) = [100 50 48 35]';
%     cnt_cmd_sim_rate = repmat(cnt_cmd_fsw_rate,1, 10)';
%     cnt_cmd_sim_rate = reshape(cnt_cmd_sim_rate,10*length(cnt_cmd_fsw_rate),1);
%     cnt_cmd_sim_rate = [cnt_cmd_sim_rate; cnt_cmd_sim_rate(end)];

    heater_cmd = zeros(n,1);
    heater_cmd([1000:floor(n/3)]) = 1;
    heater_cmd([floor(3*n/4):end]) = 1;

	heater_state_in.time               = t;
	heater_state_in.signals.values     = uint8(zeros(n,4));
	heater_state_in.signals.dimensions = [ 4 ];

    %heater_state_in.signals.values( :, test_heater_idx ) = uint8( heater_cmd );

    
%-------------------------------------------------------------------------%
% % create test comparison outputs


%-------------------------------------------------------------------------%
% run test harness

sim('csu_stm_simplified_temperature_model_hrn')

%-------------------------------------------------------------------------%
% % parse output data

figure; plot(temperature_out)


%-------------------------------------------------------------------------%
% % apply tests


%-------------------------------------------------------------------------%
% % report test results


