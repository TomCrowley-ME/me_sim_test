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

cml_current_mode_init = uint8(1);
cml_prev_mode_init = uint8(1);

cml_valid_modes  = uint8([ ... % [   NONE  ACTIVE  COAST   HOLD    TARGETING   TERMINAL
                                       1     0       0       0        0           0   ; ... % STARTUP
                                       1     0       0       0        0           0   ; ... % SAFE
                                       1     0       0       0        0           0   ; ... % POINTING
                                       0     1       1       0        0           0   ; ... % DELTAV
                                       0     1       1       0        0           0   ; ... % DEORBIT
                                       0     1       1       0        0           0   ; ... % BRAKING
                                       0     0       0       1        1           1   ; ... % LANDING
                                       1     0       0       0        0           0   ; ... % SURFACE
                                       1     0       0       0        0           0   ; ... % SAFESURFACE
               ]);

cml_mode_ids = zeros(size(cml_valid_modes));

[w, h] = size(cml_mode_ids);
n = 0;

% Assign each valid mode a unique ID
for i=1:w
    for j=1:h
        if cml_valid_modes(i, j)
            n = n + 1;
            cml_mode_ids(i, j) = n;
        end
    end
end

cml_valid_mode_transitions = zeros(n, 'uint8');


% valid to transition to any mode from startup (for now...)
cml_valid_mode_transitions(cml_mode_ids(enum_mode.startup,enum_submode.none),:) = uint8(1);

% SAFE -> POINTING
cml_valid_mode_transitions(cml_mode_ids(enum_mode.safe,enum_submode.none), ...
                       cml_mode_ids(enum_mode.pointing,enum_submode.none)) = uint8(1);

% POINTING -> SAFE
cml_valid_mode_transitions(cml_mode_ids(enum_mode.pointing,enum_submode.none), ...
                       cml_mode_ids(enum_mode.safe,enum_submode.none)) = uint8(1);
% POINTING -> DELTAV:COAST
cml_valid_mode_transitions(cml_mode_ids(enum_mode.pointing,enum_submode.none), ...
                       cml_mode_ids(enum_mode.deltav,enum_submode.coast)) = uint8(1);
% POINTING -> DELTAV:ACTIVE
cml_valid_mode_transitions(cml_mode_ids(enum_mode.pointing,enum_submode.none), ...
                       cml_mode_ids(enum_mode.deltav,enum_submode.active)) = uint8(1);
% POINTING -> DEORBIT:ACTIVE
cml_valid_mode_transitions(cml_mode_ids(enum_mode.pointing,enum_submode.none), ...
                       cml_mode_ids(enum_mode.deorbit,enum_submode.active)) = uint8(1);
% POINTING -> BRAKING:ACTIVE
cml_valid_mode_transitions(cml_mode_ids(enum_mode.pointing,enum_submode.none), ...
                       cml_mode_ids(enum_mode.braking,enum_submode.active)) = uint8(1);

% DELTAV:COAST -> SAFE
cml_valid_mode_transitions(cml_mode_ids(enum_mode.deltav,enum_submode.coast), ...
                       cml_mode_ids(enum_mode.safe,enum_submode.none)) = uint8(1);
% DELTAV:ACTIVE -> SAFE
cml_valid_mode_transitions(cml_mode_ids(enum_mode.deltav,enum_submode.active), ...
                       cml_mode_ids(enum_mode.safe,enum_submode.none)) = uint8(1);
% DELTAV:COAST -> DELTAV:ACTIVE
cml_valid_mode_transitions(cml_mode_ids(enum_mode.deltav,enum_submode.coast), ...
                       cml_mode_ids(enum_mode.deltav,enum_submode.active)) = uint8(1);
% DELTAV:ACTIVE -> DELTAV:COAST
cml_valid_mode_transitions(cml_mode_ids(enum_mode.deltav,enum_submode.active), ...
                       cml_mode_ids(enum_mode.deltav,enum_submode.coast)) = uint8(1);
% DELTAV:COAST -> POINTING
cml_valid_mode_transitions(cml_mode_ids(enum_mode.deltav,enum_submode.coast), ...
                       cml_mode_ids(enum_mode.pointing,enum_submode.none)) = uint8(1);
% DELTAV:ACTIVE -> POINTING
cml_valid_mode_transitions(cml_mode_ids(enum_mode.deltav,enum_submode.active), ...
                       cml_mode_ids(enum_mode.pointing,enum_submode.none)) = uint8(1);

% DEORBIT:ACTIVE -> DEORBIT:COAST
cml_valid_mode_transitions(cml_mode_ids(enum_mode.deorbit,enum_submode.active), ...
                       cml_mode_ids(enum_mode.deorbit,enum_submode.coast)) = uint8(1);
% DEORBIT:COAST -> BRAKING:ACTIVE
cml_valid_mode_transitions(cml_mode_ids(enum_mode.deorbit,enum_submode.coast), ...
                       cml_mode_ids(enum_mode.braking,enum_submode.active)) = uint8(1);

% BRAKING:ACTIVE -> BRAKING:COAST
cml_valid_mode_transitions(cml_mode_ids(enum_mode.braking,enum_submode.active), ...
                       cml_mode_ids(enum_mode.braking,enum_submode.coast)) = uint8(1);
% BRAKING:COAST -> LANDING:HOLD
cml_valid_mode_transitions(cml_mode_ids(enum_mode.braking,enum_submode.coast), ...
                       cml_mode_ids(enum_mode.landing,enum_submode.landing_hold)) = uint8(1);
% BRAKING:ACTIVE -> LANDING:HOLD
cml_valid_mode_transitions(cml_mode_ids(enum_mode.braking,enum_submode.active), ...
                       cml_mode_ids(enum_mode.landing,enum_submode.landing_hold)) = uint8(1);
% BRAKING:ACTIVE -> LANDING:TERMINAL
cml_valid_mode_transitions(cml_mode_ids(enum_mode.braking,enum_submode.active), ...
                       cml_mode_ids(enum_mode.landing,enum_submode.landing_terminal)) = uint8(1);

% LANDING:HOLD -> LANDING:TARGETING
cml_valid_mode_transitions(cml_mode_ids(enum_mode.landing,enum_submode.landing_hold), ...
                       cml_mode_ids(enum_mode.landing,enum_submode.landing_targeting)) = uint8(1);
% LANDING:TARGETING ->  LANDING:TERMINAL
cml_valid_mode_transitions(cml_mode_ids(enum_mode.landing,enum_submode.landing_targeting), ...
                       cml_mode_ids(enum_mode.landing,enum_submode.landing_terminal)) = uint8(1);
% LANDING:TERMINAL -> SURFACE
cml_valid_mode_transitions(cml_mode_ids(enum_mode.landing,enum_submode.landing_terminal), ...
                       cml_mode_ids(enum_mode.surface,enum_submode.none)) = uint8(1);

% SURFACE -> SAFESURFACE
cml_valid_mode_transitions(cml_mode_ids(enum_mode.surface,enum_submode.none), ...
                       cml_mode_ids(enum_mode.safesurface,enum_submode.none)) = uint8(1);
% SURFACE -> LANDING:TERMINAL
cml_valid_mode_transitions(cml_mode_ids(enum_mode.surface,enum_submode.none), ...
                       cml_mode_ids(enum_mode.landing,enum_submode.landing_terminal)) = uint8(1);

% SAFESURFACE -> SURFACE
cml_valid_mode_transitions(cml_mode_ids(enum_mode.safesurface,enum_submode.none), ...
                       cml_mode_ids(enum_mode.surface,enum_submode.none)) = uint8(1);


clear n i j w h

% create initial values for all cmp_bus_msg parameters
cml_initial_value.cfe_tlm_header_align              = zeros(4,1,'uint8');
cml_initial_value.mode                              = uint8( enum_mode.startup );
cml_initial_value.submode                           = uint8( enum_submode.none );
cml_initial_value.hover_enable                      = uint8( enum_boolean.false );
cml_initial_value.takeoff_enable                    = uint8( enum_boolean.false );
cml_initial_value.inertial_primary_pointing_cmd     = double(zeros(3,1));
cml_initial_value.inertial_secondary_pointing_cmd   = double(zeros(3,1));
cml_initial_value.body_secondary_pointing_vector    = double(zeros(3,1));
cml_initial_value.body_primary_pointing_vector      = double(zeros(3,1));
cml_initial_value.peg_position_target               = double(zeros(3,1));
cml_initial_value.peg_velocity_target               = double(zeros(3,1));
cml_initial_value.vnc_primary_pointing_cmd          = double(zeros(2,1));
cml_initial_value.thruster_dv_cmd                   = double(0);
cml_initial_value.thruster_dur_cmd                  = single(0);
cml_initial_value.mode_change_counter               = uint16(0);
cml_initial_value.mode_change_errors                = uint16(0);
cml_initial_value.process_cmds_counter              = uint16(0);
cml_initial_value.process_cmds_errors               = uint16(0);
cml_initial_value.burn_type_cmd                     = uint8(0); % default to null value
cml_initial_value.start_burn                        = uint8(0);
cml_initial_value.est_ref_frame                     = uint8(  enum_reference_frame.inertial);
cml_initial_value.peg_target_ref_frame              = uint8(  enum_reference_frame.inertial);
cml_initial_value.acs_thruster_set                  = uint8(  enum_thruster_type.fine) ; % default to fine
cml_initial_value.cnt_active_controller_disable     = uint32(0);
cml_initial_value.act_manual_thruster_firing        = uint32(zeros(26,1));
cml_initial_value.act_arm_thruster_set_durations    = uint32(zeros(4,1));
cml_initial_value.act_reset_accumulated_ontime      = uint8(0);
cml_initial_value.command_id                        = uint8(0);
