csc_peg_update_dt            = 2.0;     % [sec]     time between PEG updates

gdn_peg_max_iterations       = 10;      %           maximum iterations
gdn_peg_thrust_gain          = 1.0;     %           thrust gain used in PEG iterations

gdn_peg_Rmiss_tolerance      = 1e-0;    % [m]       position error tolerance
gdn_peg_Vmiss_tolerance      = 1e-2;    % [m/s]     velocity error tolerance

gdn_peg_pointing_hold_tgo    = 10.0;    % [sec]     hold burn direction when tgo less than value
gdn_peg_burn_cutoff_tgo      =  1.0;    % [sec]     stop main engine firing when tgo less than value

gdn_peg_bus_initial = struct('lambda'    ,[0 0 0],...
                             'lambdaDot' ,[0 0 0],...
                             'K'         ,0,...
                             'tgo'       ,0,...
                             'Vgo'       ,[0 0 0],...
                             'Rgo'       ,[0 0 0],...
                             'n'         ,0);