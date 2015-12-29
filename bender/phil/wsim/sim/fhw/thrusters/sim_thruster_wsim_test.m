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
% sim_thruster_wsim_test.m                                                %
%                                                                         %
% 06/04/14                                                                %
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% % Call test init files 

nimbus_bus_all;
gbl_global_parameters_init;


	% call init files for block in question
	csu_tdl_thruster_dynamics_lander_init;

	% call supporting init files which are also required

	% define time step parameters (if applicable)
	sim_time_step_size = 0.01; % (seconds)
    fsw_dt = 0.1;
    
    csu_cfe_cfe_time_init
    cfe_initial_utc_time = 0;

%-------------------------------------------------------------------------%
% % Call test prep files

	% call prep files for block in question (if applicable)
	csu_tdl_thruster_dynamics_lander_prep;

	% call supporting prep files which are also required
	

%-------------------------------------------------------------------------%
% % Set test parameters

	sim_dt = sim_time_step_size;

	t0 = 0;
	tFinal = 0.4;

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
    
    test_thruster_id = 1;
    
    cnt_cmd_fsw_rate = zeros(n_fsw,1);
    cnt_cmd_fsw_rate(:) = [100 50 48 35]';
    cnt_cmd_sim_rate = repmat(cnt_cmd_fsw_rate,1, 10)';
    cnt_cmd_sim_rate = reshape(cnt_cmd_sim_rate,10*length(cnt_cmd_fsw_rate),1);
    cnt_cmd_sim_rate = [cnt_cmd_sim_rate; cnt_cmd_sim_rate(end)];

	cnt_cmd_in.time               = t;
	cnt_cmd_in.signals.values     = uint8(zeros(n,26));
	cnt_cmd_in.signals.dimensions = [ 26 ];

    cnt_cmd_in.signals.values( :, test_thruster_id ) = uint8( cnt_cmd_sim_rate );

    cnt_delay_fsw_rate = zeros(n_fsw,1);
    cnt_delay_fsw_rate(:) = [0 0 5 0]';
    cnt_delay_sim_rate = repmat(cnt_delay_fsw_rate,1, 10)';
    cnt_delay_sim_rate = reshape(cnt_delay_sim_rate,10*length(cnt_delay_fsw_rate),1);
    cnt_delay_sim_rate = [cnt_delay_sim_rate; cnt_delay_sim_rate(end)];
    
    cnt_delay_in.time               = t;
	cnt_delay_in.signals.values     = uint8(zeros(n,26));
	cnt_delay_in.signals.dimensions = [ 26 ];
    
    cnt_delay_in.signals.values( :, test_thruster_id ) = uint8( cnt_delay_sim_rate );

    
%-------------------------------------------------------------------------%
% % create test comparison outputs

	% % as necessary
    expected_impulse = cnt_cmd_fsw_rate/1000 * tdl_coarse_acs_thrust;
    
    expected_delay_time = 0.02; %seconds

    t_expected_thrust = t(11:10:end);
    t_expected_thrust( cnt_cmd_fsw_rate >= 100 ) = t_expected_thrust( cnt_cmd_fsw_rate >= 100 ) + expected_delay_time;
    t_expected_thrust = t_expected_thrust + cnt_delay_fsw_rate/1000;

%-------------------------------------------------------------------------%
% run test harness

sim('sim_thruster_wsim_hrn')


%-------------------------------------------------------------------------%
% % parse output data

figure(1); clf;  plot(thrust,'b'); grid on; 
xlabel('time (s)')
ylabel('thrust(N)')

figure(2); clf; plot(t, cumsum(thrust.Data)*sim_time_step_size,'b')
grid on; hold on;
plot(t_expected_thrust, cumsum(expected_impulse),'ro') %delay plot due to thruster lag
xlabel('time (s)')
ylabel('cumulative impulse (Ns)')
legend('cumulative impulse produced','cumulative impulse expected','Location','NorthWest')

link_fig_axes([1 2])

%-------------------------------------------------------------------------%
% % apply tests


%-------------------------------------------------------------------------%
% % report test results


