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
% csu_lak_linear_accel_kinematics_test.m                                  %
%                                                                         %
% 08/01/14                                                                %
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% % Call test init files 

nimbus_bus_all;
gbl_global_parameters_init;


	% call init files for block in question
    
    
	% call supporting init files which are also required

	% define time step parameters (if applicable)
	sim_time_step_size = 0.01; % (seconds)
    fsw_dt = 0.1;
    

%-------------------------------------------------------------------------%
% % Call test prep files

	% call prep files for block in question (if applicable)

	% call supporting prep files which are also required
	

%-------------------------------------------------------------------------%
% % Set test parameters

	sim_dt = sim_time_step_size;

	t0 = 0;
	tFinal = 10;

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
    
    eulers_in.time                   = t;
	eulers_in.signals.values         = repmat( [0 90 0]*pi/180, n, 1);
	eulers_in.signals.dimensions     = [ 3 ];

	omega_in.time                   = t;
	omega_in.signals.values         = double(zeros(n,3));
	omega_in.signals.dimensions     = [ 3 ];
    
    alpha_in.time                   = t;
	alpha_in.signals.values         = double(zeros(n,3));
	alpha_in.signals.dimensions     = [ 3 ];
    
    accel_in.time                   = t;
	accel_in.signals.values         = double(zeros(n,3));
	accel_in.signals.dimensions     = [ 3 ];
    
    gravity_in.time                   = t;
	gravity_in.signals.values         = repmat([ 0 0 -9.8], n, 1);
	gravity_in.signals.dimensions     = [ 3 ];

    %heater_state_in.signals.values( :, test_heater_idx ) = uint8( heater_cmd );

    
%-------------------------------------------------------------------------%
% % create test comparison outputs


%-------------------------------------------------------------------------%
% run test harness

sim('csu_lak_linear_accel_kinematics_hrn')

%-------------------------------------------------------------------------%
% % parse output data

figure; plot(accel_out)


%-------------------------------------------------------------------------%
% % apply tests


%-------------------------------------------------------------------------%
% % report test results


