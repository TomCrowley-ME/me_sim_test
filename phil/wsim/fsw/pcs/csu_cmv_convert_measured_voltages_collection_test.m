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
% csu_cmv_convert_measured_voltages_collection_test.m                     %
%                                                                         %
% 06/04/14                                                                %
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% % Call test init files 

mtv_bus_all;
gbl_global_parameters_init;


	% call init files for block in question

	% call supporting init files which are also required

	% define time step parameters (if applicable)
	sim_time_step_size = 0.01; % (seconds)
    fsw_dt = 0.1;
    
    csu_cfe_cfe_time_init
    cfe_initial_utc_time = 0;

%-------------------------------------------------------------------------%
% % Call test prep files

	% call prep files for block in question (if applicable)

	% call supporting prep files which are also required
	
load hil_adio_telemetry_101014.mat

%-------------------------------------------------------------------------%
% % Set test parameters

	sim_dt = fsw_dt;

	t0 = 0;
	tFinal = (length(adio_telemetry.Time)-1)*fsw_dt;

	% create time vector for comparison/plotting
	t = [t0 : sim_dt : tFinal]';
	n = length(t);
    
    
%-------------------------------------------------------------------------%
% % load in test data to use as input

    csu_cmv_adio_test_initialization

%-------------------------------------------------------------------------%
% % assign values to test inputs

	% % use struct input specification
	% variable_structure_in.time = t;
	% variable_structure_in.signals.values = typecast( rand(n,4), [0 255]);
	% variable_structure_in.signals.dimensions = [ 4 ];

	% % ESC: checkout typed/nonfinite inputs
    
    
%-------------------------------------------------------------------------%
% % create test comparison outputs


%-------------------------------------------------------------------------%
% run test harness

sim('csu_cmv_convert_measured_voltages_collection_hrn')


%-------------------------------------------------------------------------%
% % parse output data

% figure(1); clf;  plot(thrust,'b'); grid on; 
% xlabel('time (s)')
% ylabel('thrust(N)')
% 
% figure(2); clf; plot(t, cumsum(thrust.Data)*sim_time_step_size,'b')
% grid on; hold on;
% plot(t_expected_thrust, cumsum(expected_impulse),'ro') %delay plot due to thruster lag
% xlabel('time (s)')
% ylabel('cumulative impulse (Ns)')
% legend('cumulative impulse produced','cumulative impulse expected','Location','NorthWest')
% 
% link_fig_axes([1 2])

%-------------------------------------------------------------------------%
% % apply tests


%-------------------------------------------------------------------------%
% % report test results


