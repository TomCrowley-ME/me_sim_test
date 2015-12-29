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
% csu_tdl_thruster_dynamics_lander_test.m                                 %
%                                                                         %
% 05/30/14                                                                %
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% % Call test init files 


	% call init files for block in question
	csu_tdl_thruster_dynamics_lander_init;

	% call supporting init files which are also required

	% define time step parameters (if applicable)
	sim_time_step_size = 0.01; % (seconds)

%-------------------------------------------------------------------------%
% % Call test prep files

	% call prep files for block in question (if applicable)
	csu_tdl_thruster_dynamics_lander_prep;

	% call supporting prep files which are also required
	

%-------------------------------------------------------------------------%
% % Set test parameters

	sim_dt = sim_time_step_size;

	t0 = 0;
	tFinal = 300;

	% create time vector for comparison/plotting
	t = [t0 : sim_dt : tFinal]';
	n = length(t);

    
%-------------------------------------------------------------------------%
% % load in test data to use as input

if exist('scn98_dhil_data.mat','file')
    load scn98_dhil_data
else
    % meaningless, but I don't want to check in this giant file 
    % talk to Eleanor if you want to get data for this test
    truth.thr.transition = timeseries( zeros(n,1), t);
    truth.thr.transition_time_in = timeseries( zeros(n,1), t);
    truth.sim.thrusts = timeseries( zeros(n,1), t);
end


%-------------------------------------------------------------------------%
% % assign values to test inputs

	% % use struct input specification
	% variable_structure_in.time = t;
	% variable_structure_in.signals.values = typecast( rand(n,4), [0 255]);
	% variable_structure_in.signals.dimensions = [ 4 ];

	% % ESC: checkout typed/nonfinite inputs
    
    test_thruster_id = 10;

	transition_in.time               = t;
	transition_in.signals.values     = uint8([truth.thr.transition.Data(1:n,:) ]);
	transition_in.signals.dimensions = [ 26 ];
    
    transition_time_in.time               = t;
	transition_time_in.signals.values     = [truth.thr.transition_time.Data(1:n,:) ];
	transition_time_in.signals.dimensions = [ 26 ];
       
    cfe_time_in.time               = t;
	cfe_time_in.signals.values     = truth.sim.Time(1:n);
	cfe_time_in.signals.dimensions = [ 1 ];
    
%-------------------------------------------------------------------------%
% % create test comparison outputs

	% % as necessary
    dhil_thrust = truth.sim.thrusts.Data(1:n,test_thruster_id);

%-------------------------------------------------------------------------%
% run test harness

sim('csu_tdl_thruster_dynamics_lander_hrn')


%-------------------------------------------------------------------------%
% % parse output data

figure(1); clf;  plot(thrust); grid on; hold on; stairs(t, dhil_thrust,'r')

figure(2); clf; plot(t, cumtrapz(t, thrust.Data))
grid on; hold on;
plot(t, cumtrapz(t, dhil_thrust),'ro') %delay plot due to thruster lag
xlabel('time (s)')
ylabel('cumulative impulse (Ns)')
legend('cumulative impulse produced','cumulative impulse expected')

%-------------------------------------------------------------------------%
% % apply tests


%-------------------------------------------------------------------------%
% % report test results


