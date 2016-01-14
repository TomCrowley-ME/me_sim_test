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
% touchdown_evaluation.m                                                  %
%                                                                         %
% evaluates touchdown conditions for first cut success/failure            %
% 05/30/13                                                                %
%-------------------------------------------------------------------------%

function [ telem truth error] = derive_values(telem, truth, earth_vehicle_flag)

if isfield(telem,'est') && ~any(ismember(telem.est.fieldnames,'mean_rate'))
    telem.est.mean_rate = telem.est.rate;
    telem.est.mean_accel = telem.est.accel;
end


%-------------------------------------------------------------------------%
% EST

if isfield(telem, 'est')
    est_surface_rel_pos   = telem.est.pos;
    
    if isfield(telem, 'cmp')
        iTopo = find( telem.cmp.est_ref_frame.Data == 2);
        iMCI  = find( telem.cmp.est_ref_frame.Data ~= 2); 
         if any( diff(iTopo) ~= 1 ) || any( diff(iMCI) ~= 1 )
             warning('Multiple transitions between frames. Sim structure will be incorrect')
         end
         
        telem.est.local_pos   = append( getsamples(telem.est.pos, iMCI), getsamples(telem.est.pos, iTopo) );
    end

    % convert estimated quaternion into zyx euler angles
    [ lander_euler_xyz ] = quat2euler(telem.est.q.Data);

    est_euler_xyz = telem.est.q;
    set(est_euler_xyz,'Name','euler_xyz') ;
    est_euler_xyz.Data = lander_euler_xyz*180/pi;
    telem.est.euler_xyz = est_euler_xyz;


    if earth_vehicle_flag
        % create plotting-friendly version of EST position
        pos_ts = telem.est.pos;

        % find takeoff signal
        i_takeoff = find(telem.cmp.takeoff_enable.Data == 1,1);

        if isempty(i_takeoff)
            i_takeoff = 1;
            i_land = length(telem.est.pos.Data);
        else
            i_takeoff = i_takeoff - 50;
            i_land = min(i_takeoff + 25*10, length(telem.est.pos.Data));
        end

        pos_ts.Data = NaN(size(pos_ts.Data));
        pos_ts.Data(i_takeoff:i_land,:) = telem.est.pos.Data(i_takeoff:i_land,:);

        telem.est.pos_plot = pos_ts;
        
        % create pos/vel signal from only believable data
         pos_ts = telem.est.pos;
         
         good_gps = filter((1/5)*ones(1,5),1, double(telem.est.gps_meas_valid.Data)) > 0;
         pos_ts.Data = NaN(size(pos_ts.Data));
         pos_ts.Data(good_gps ,:) = telem.est.pos.Data(good_gps ,:);
         set(pos_ts,'Name','pos_good_gps_only') ;
         telem.est.pos_good_gps_only = pos_ts;
         
         vel_ts = telem.est.vel;
         vel_ts.Data = NaN(size(vel_ts.Data));
         vel_ts.Data(good_gps ,:) = telem.est.vel.Data(good_gps ,:);
         set(vel_ts,'Name','vel_good_gps_only') ;
         telem.est.vel_good_gps_only = vel_ts;
         
         % create angle/rate data when haz bus on && ~SAFE
         % % % FIX % % %
         not_safed = telem.pcs.volts_28v_haz.Data & telem.cmp.mode.Data ~= enum_mode.safe;
         
         ang_ts = telem.est.angle_off_vertical;
         ang_ts.Data = NaN(size(ang_ts.Data));
         ang_ts.Data(not_safed ,:) = telem.est.angle_off_vertical.Data(not_safed ,:);
         set(ang_ts,'Name','angle_while_controlled') ;
         telem.est.angle_while_controlled = ang_ts;
         
         rate_ts = telem.est.mean_rate;
         rate_ts.Data = NaN(size(rate_ts.Data));
         rate_ts.Data(not_safed ,:) = telem.est.mean_rate.Data(not_safed ,:);
         set(rate_ts,'Name','rate_while_controlled') ;
         telem.est.angle_while_controlled = rate_ts;
         
    end
end

if isfield(telem, 'gps')
    % create raw GPS pos/vel signals

    gps_pos_ts = telem.gps.n;
    gps_pos_ts.Data = double([telem.gps.n.Data telem.gps.e.Data telem.gps.d.Data])/1000;
    set(gps_pos_ts,'Name','ned_pos_meters') ;
    telem.gps.ned_pos_meters = gps_pos_ts;

    if any(ismember(telem.gps.fieldnames,'n_vel'))
        gps_vel_ts = telem.gps.n;
        gps_vel_ts.Data = double([telem.gps.n_vel.Data telem.gps.e_vel.Data telem.gps.d_vel.Data])/1000;
        set(gps_vel_ts,'Name','ned_vel_ms') ;
        telem.gps.ned_vel_ms = gps_vel_ts;
    end
end

%-------------------------------------------------------------------------%
% CNT

if isfield(telem, 'cnt')
    coarse_acs_cmds = cat(2, telem.cnt.coarse1_time.Data, telem.cnt.coarse2_time.Data, telem.cnt.coarse3_time.Data, ...
                             telem.cnt.coarse4_time.Data, telem.cnt.coarse5_time.Data, telem.cnt.coarse6_time.Data, ...
                             telem.cnt.coarse7_time.Data, telem.cnt.coarse8_time.Data, telem.cnt.coarse9_time.Data, ...
                             telem.cnt.coarse10_time.Data, telem.cnt.coarse11_time.Data, telem.cnt.coarse12_time.Data );

    cnt_coarse_acs_cmds = telem.cnt.coarse1_time;
    set(cnt_coarse_acs_cmds,'Name','cnt_coarse_acs_cmds') ;
    cnt_coarse_acs_cmds.Data = coarse_acs_cmds;
    telem.cnt.coarse_acs_cmds = cnt_coarse_acs_cmds;


    fine_acs_cmds   = cat(2, telem.cnt.fine1_time.Data, telem.cnt.fine2_time.Data, telem.cnt.fine3_time.Data, ...
                             telem.cnt.fine4_time.Data, telem.cnt.fine5_time.Data, telem.cnt.fine6_time.Data, ...
                             telem.cnt.fine7_time.Data, telem.cnt.fine8_time.Data, telem.cnt.fine9_time.Data, ...
                             telem.cnt.fine10_time.Data, telem.cnt.fine11_time.Data, telem.cnt.fine12_time.Data );

    cnt_fine_acs_cmds = telem.cnt.fine1_time;
    set(cnt_fine_acs_cmds,'Name','cnt_fine_acs_cmds') ;
    cnt_fine_acs_cmds.Data = fine_acs_cmds;
    telem.cnt.fine_acs_cmds = cnt_fine_acs_cmds;
end

%-------------------------------------------------------------------------%
% ACT

if isfield(telem, 'act')
    coarse_acs_cmds = cat(2, telem.act.coarse1_time.Data, telem.act.coarse2_time.Data, telem.act.coarse3_time.Data, ...
                             telem.act.coarse4_time.Data, telem.act.coarse5_time.Data, telem.act.coarse6_time.Data, ...
                             telem.act.coarse7_time.Data, telem.act.coarse8_time.Data, telem.act.coarse9_time.Data, ...
                             telem.act.coarse10_time.Data, telem.act.coarse11_time.Data, telem.act.coarse12_time.Data );

    act_coarse_acs_cmds = telem.act.coarse1_time;
    set(act_coarse_acs_cmds,'Name','act_coarse_acs_cmds') ;
    act_coarse_acs_cmds.Data = coarse_acs_cmds;
    telem.act.coarse_acs_cmds = act_coarse_acs_cmds;

    if isfield(telem.act,'fine1_time')
        fine_acs_cmds   = cat(2, telem.act.fine1_time.Data, telem.act.fine2_time.Data, telem.act.fine3_time.Data, ...
                                 telem.act.fine4_time.Data, telem.act.fine5_time.Data, telem.act.fine6_time.Data, ...
                                 telem.act.fine7_time.Data, telem.act.fine8_time.Data, telem.act.fine9_time.Data, ...
                                 telem.act.fine10_time.Data, telem.act.fine11_time.Data, telem.act.fine12_time.Data );

        act_fine_acs_cmds = telem.act.fine1_time;
        set(act_fine_acs_cmds,'Name','act_fine_acs_cmds') ;
        act_fine_acs_cmds.Data = fine_acs_cmds;
        telem.act.fine_acs_cmds = act_fine_acs_cmds;
    end
end


%-------------------------------------------------------------------------%
% CNT

if isfield(telem, 'est') && isfield(telem, 'cnt')
    % reconstruct euler angle errors in attitude controller
    % put EST quaternion into topocentric frame, regardless of native frame
    est_inertial_in_topo    = quat_positive( quat_mult( quat_mult( quat_inv( quat_positive(telem.est.q) ), telem.est.q_mci_to_mcmf ) , telem.est.q_mcmf_to_topo ) );

    iTopo = find( telem.cmp.est_ref_frame.Data == 2);
    iMCI  = find( telem.cmp.est_ref_frame.Data ~= 2);
    est_quat_topo = quat_positive(  append( getsamples( est_inertial_in_topo, iMCI), quat_inv( getsamples(telem.est.q, iTopo) ) )  );

    % put CMD quaternion into topocentric frame, from inertial
    cmd_quat_topo           = quat_positive( quat_mult( quat_mult( quat_inv( telem.cnt.quat_des ), telem.est.q_mci_to_mcmf ) , telem.est.q_mcmf_to_topo ));

    % create quaternion error
    cnt_error_quat = quat_positive( quat_mult( quat_inv( est_quat_topo), cmd_quat_topo ) );

    % convert to euler angles in radians
    error_eul_xyz = quat2euler( cnt_error_quat );
    telem.cnt.error_eul_xyz = timeseries( error_eul_xyz.Data, telem.cnt.Time, 'Name', 'error_eul_xyz' );
end
    
%-------------------------------------------------------------------------%
% PROP

% prop scripting currently only supports MTV vehicles, not MX
if earth_vehicle_flag && (isfield(telem, 'cnt') || isfield(telem, 'act') || isfield(telem, 'egc'))
    
    warning('off', 'MATLAB:timeseries:set:noinplaceset')
    
    telem.prop = tscollection;
    
    % nitrogen model math here?
    
    % load in mtv parameters--come up wiht way to switch vehicles here
    csu_psp_propulstion_system_parameters_mtv_init
    csc_emp_est_mass_props_mtv_init
    csc_emp_est_mass_props_prep
    
    if isfield(telem, 'cnt')
        telem.prop.Time = telem.cnt.Time;
    elseif isfield(telem, 'act')
        telem.prop.Time = telem.act.Time;
    elseif isfield(telem, 'egc')
        telem.prop.Time = telem.egc.Time;
    end
    
    if isfield(telem, 'cnt') && isfield(telem, 'tcs')
        % thrust from chamber pressure
        pc_thrust_data = (1.32839171615 * telem.tcs.press_chamber.Data(:,1) - 37.1976248356) * 4.44822162;
        telem.prop.thrust_from_pc = timeseries(pc_thrust_data, telem.prop.Time, 'Name', 'thrust_from_pc');
    end
    
    if isfield(telem, 'act')
        % Mass expelled: N2 (using simple constant isp)
        acs_firing_time = double(min(telem.act.coarse_acs_cmds.Data,100));
        acs_total_fire_cmd = sum(double(acs_firing_time),2);

        acs_total_burn_time = cumsum(acs_total_fire_cmd/100);

        telem.prop.acs_prop_used = timeseries(acs_total_burn_time/(9.80665*psp_coarse_acs_isp), telem.prop.Time, 'Name', 'acs_prop_used');
        
            
        % resolve ACS thruster firings into body frame 
        n_telem = length(acs_total_fire_cmd);
        force_direction = psp_coarse_acs_thrust * [ psp_thruster1_orientation;  psp_thruster2_orientation;  psp_thruster3_orientation; ...
                                                    psp_thruster4_orientation;  psp_thruster5_orientation;  psp_thruster6_orientation; ...
                                                    psp_thruster7_orientation;  psp_thruster8_orientation;  psp_thruster9_orientation; ...
                                                    psp_thruster10_orientation; psp_thruster11_orientation; psp_thruster12_orientation ];

        force_direction_time = repmat(force_direction, 1, 1, n_telem);

        thrust_cmd_time = reshape(acs_firing_time', 12, 1, n_telem);
        thrust_cmd_time = repmat(thrust_cmd_time, 1, 3, 1);

        vector_force_time = thrust_cmd_time/100 .* force_direction_time;
        vector_force_total_time = sum(vector_force_time,1);
        vector_force_total = squeeze(vector_force_total_time)';

        telem.prop.acs_body_force = timeseries(vector_force_total, telem.prop.Time, 'Name', 'acs_body_force');

        % determine total torque on vehicle due to ACS
        % torque = r x F

        thruster_position = [ psp_thruster1_position;  psp_thruster2_position;  psp_thruster3_position; ...
                              psp_thruster4_position;  psp_thruster5_position;  psp_thruster6_position; ...
                              psp_thruster7_position;  psp_thruster8_position;  psp_thruster9_position; ...
                              psp_thruster10_position; psp_thruster11_position; psp_thruster12_position ];

        thruster_position_time = repmat(thruster_position, 1, 1, n_telem);

        % using approximate value from simulation, varies over time, natch
        cg_location_time = repmat(repmat([0 0 0.1], 12, 1), 1, 1, n_telem);

        torque_time = cross( thruster_position_time - cg_location_time, vector_force_time);

        torque_total_time = sum(torque_time,1);

        torque_total = squeeze(torque_total_time)';
        torque_total_temp = torque_total;
        torque_total_temp( abs(torque_total_temp) < 0.75 ) = 0;
        torque_total_sign = sign(torque_total_temp);

        telem.prop.acs_body_torque = timeseries(torque_total, telem.prop.Time, 'Name', 'acs_body_torque');
        telem.prop.acs_body_torque_sign = timeseries(torque_total_sign, telem.prop.Time, 'Name', 'torque_total_sign');
    end

    if isfield(telem, 'egc')
        % thrust based on throttle map
        if ~any(ismember(telem.egc.fieldnames,'position'))
            telem.egc.position = telem.egc.throttle*(2.7027);
        end
        throttle_scaled = double(telem.egc.position.Data./(44*4000));
        throttle_scaled( throttle_scaled < 3277 ) = 0;
        throttle_scaled = throttle_scaled ./ 65535;
        throttle_ideal = 2829.5*throttle_scaled.^3 - 6397.8*throttle_scaled.^2 + 5357.9.*throttle_scaled + 290.57;

        telem.prop.thrust_from_throttle = timeseries(throttle_ideal, telem.prop.Time, 'Name', 'thrust_from_throttle');
    end
    
    if isfield(telem, 'egc') && isfield(telem, 'prop')
        num_pc_meas = size(telem.prop.thrust_from_pc.Data,2);
        total_thrust = telem.prop.thrust_from_pc.Data + telem.prop.acs_body_force.Data(:,3)*ones(1,num_pc_meas);
        telem.prop.total_thrust_produced = timeseries(total_thrust, telem.prop.Time, 'Name', 'total_thrust_produced');

    end
    
    if isfield(telem, 'est') && isfield(telem, 'prop')
        num_pc_meas = size(telem.prop.thrust_from_pc.Data,2);
        prop_total_mass = resample(telem.est.mass, telem.prop.Time);
        telem.prop.total_thrust_to_weight = timeseries(telem.prop.total_thrust_produced.Data./(prop_total_mass.Data*9.80665*ones(1,num_pc_meas)), telem.prop.Time, 'Name', 'total_thrust_to_weight');

    end


    clear force_direction force_direction_time thrust_cmd_time vector_force_time vector_force_total_time torque_total_time torque_time thruster_position_time

    warning('on', 'MATLAB:timeseries:set:noinplaceset')
    
end

%-------------------------------------------------------------------------%
% SIM

if ~isempty(truth)
    
    true_altitude = truth.sim.altitude.Data;
    truth.altitude = timeseries(true_altitude, truth.sim.altitude.Time, 'name','derived_altitude');
    
    if isnan(telem.est.accel.TimeInfo.Increment) || (truth.sim.acc_topo.TimeInfo.Increment)
        nFSW = max( round( mean(diff(telem.est.accel.Time))/mean(diff(truth.sim.acc_topo.Time)) ) , 1);
    else
        nFSW = max( floor(telem.est.accel.TimeInfo.Increment/ truth.sim.acc_topo.TimeInfo.Increment), 1);
    end
    
    topo_true_acc_10hz = timeseries( filter(ones(1,nFSW)/nFSW,1, truth.sim.acc_topo.Data) , truth.sim.acc_topo.Time, 'name','filtered_acc');
    topo_true_vel_10hz = timeseries( filter(ones(1,nFSW)/nFSW,1, truth.sim.vel_topo.Data) , truth.sim.vel_topo.Time, 'name','filtered_vel');
    topo_true_rate_10hz = timeseries( filter(ones(1,nFSW)/nFSW,1, truth.sim.rate_body.Data) , truth.sim.rate_body.Time, 'name','filtered_rate');
    
    mci_true_acc_10hz = timeseries( filter(ones(1,nFSW)/nFSW,1, truth.sim.rtd_acc_body_in_eci.Data) , truth.sim.rtd_acc_body_in_eci.Time, 'name','filtered_acc');
    mci_true_vel_10hz = timeseries( filter(ones(1,nFSW)/nFSW,1, truth.sim.rtk_vel_eci.Data) , truth.sim.rtk_vel_eci.Time, 'name','filtered_vel');
    mci_true_rate_10hz = timeseries( filter(ones(1,nFSW)/nFSW,1, truth.sim.rrk_rate_body_eci_body.Data) , truth.sim.rrk_rate_body_eci_body.Time, 'name','filtered_rate');
    
    topo_true_acc_10hz.Data(1:nFSW,:) = repmat( topo_true_acc_10hz.Data(nFSW,:), nFSW,1 );
    topo_true_vel_10hz.Data(1:nFSW,:) = repmat( topo_true_vel_10hz.Data(nFSW,:), nFSW,1 );
    topo_true_rate_10hz.Data(1:nFSW,:) = repmat( topo_true_rate_10hz.Data(nFSW,:), nFSW,1 );
    
    mci_true_acc_10hz.Data(1:nFSW,:) = repmat( mci_true_acc_10hz.Data(nFSW,:), nFSW,1 );
    mci_true_vel_10hz.Data(1:nFSW,:) = repmat( mci_true_vel_10hz.Data(nFSW,:), nFSW,1 );
    mci_true_rate_10hz.Data(1:nFSW,:) = repmat( mci_true_rate_10hz.Data(nFSW,:), nFSW,1 );
    
    
    
    
    % create truth data at the FSW rate for direct comparison
    truth.fsw_rate.topo.sim_pos      = resample(truth.sim.pos_topo,       telem.est.local_pos.Time);
    truth.fsw_rate.topo.sim_vel      = resample(topo_true_vel_10hz,       telem.est.vel.Time);
    truth.fsw_rate.topo.sim_acc      = resample(topo_true_acc_10hz,       telem.est.accel.Time);
    truth.fsw_rate.topo.sim_rate     = resample(topo_true_rate_10hz,      telem.est.rate.Time);
    truth.fsw_rate.topo.sim_euler    = resample(truth.sim.euler_zyx,      telem.est.euler_xyz.Time);
    truth.fsw_rate.topo.sim_quat     = resample(truth.sim.q_topo_to_body, telem.est.euler_xyz.Time);
    truth.fsw_rate.topo.sim_altitude = resample(truth.altitude,           telem.est.altitude.Time);
    
    % create truth data at the FSW rate for direct comparison
    truth.fsw_rate.mci.sim_pos      = resample(truth.sim.rtk_pos_eci,           telem.est.local_pos.Time);
    truth.fsw_rate.mci.sim_vel      = resample(mci_true_vel_10hz,               telem.est.vel.Time);
    truth.fsw_rate.mci.sim_acc      = resample(mci_true_acc_10hz,               telem.est.accel.Time);
    truth.fsw_rate.mci.sim_rate     = resample(mci_true_rate_10hz,              telem.est.rate.Time);
    truth.fsw_rate.mci.sim_euler    = resample(truth.sim.rrk_euler_zyx_rot_deg, telem.est.euler_xyz.Time);
    truth.fsw_rate.mci.sim_quat     = resample(truth.sim.rrk_q_body_from_eci,   telem.est.euler_xyz.Time);
    truth.fsw_rate.mci.sim_altitude = resample(truth.sim.altitude,              telem.est.altitude.Time);
    
    % nadir_cam_angle_off_vertical = 180 - acosd( nadir_cam_2_opt_axis_topo(:,3) );
    % side_cam_angle_off_vertical = 180 - acosd( side_cam_2_opt_axis_topo(:,3) );
    
    % create total sim structure
    iTopo = find( telem.cmp.est_ref_frame.Data == 2);
    iMCI  = find( telem.cmp.est_ref_frame.Data ~= 2);
    
    if any( diff(iTopo) ~= 1 ) || any( diff(iMCI) ~= 1 )
        warning('Multiple transitions between frames. Sim structure will be incorrect')
    else
        
        truth.fsw_rate.total.sim_pos   = append( getsamples(truth.fsw_rate.mci.sim_pos, iMCI), getsamples(truth.fsw_rate.topo.sim_pos, iTopo) );
        truth.fsw_rate.total.sim_vel   = append( getsamples(truth.fsw_rate.mci.sim_vel, iMCI), getsamples(truth.fsw_rate.topo.sim_vel, iTopo) );
        truth.fsw_rate.total.sim_acc   = append( getsamples(truth.fsw_rate.mci.sim_acc, iMCI), getsamples(truth.fsw_rate.topo.sim_acc, iTopo) );
        truth.fsw_rate.total.sim_euler = append( getsamples(truth.fsw_rate.mci.sim_euler, iMCI), getsamples(truth.fsw_rate.topo.sim_euler, iTopo) );
        truth.fsw_rate.total.sim_rate  = append( getsamples(truth.fsw_rate.mci.sim_rate, iMCI), getsamples(truth.fsw_rate.topo.sim_rate, iTopo) );
        truth.fsw_rate.total.sim_altitude  = append( getsamples(truth.fsw_rate.mci.sim_altitude, iMCI), getsamples(truth.fsw_rate.topo.sim_altitude, iTopo) );
        
    end
    
    %-------------------------------------------------------------------------%
    % ERROR
    
    % create error structure for topocentric representation
    error.knowledge.topo.pos      = truth.fsw_rate.topo.sim_pos - telem.est.local_pos;
    error.knowledge.topo.vel      = truth.fsw_rate.topo.sim_vel - telem.est.vel;
    error.knowledge.topo.acc      = truth.fsw_rate.topo.sim_acc - telem.est.accel;
    error.knowledge.topo.euler    = truth.fsw_rate.topo.sim_euler - telem.est.euler_xyz;
    error.knowledge.topo.angle    = total_error_from_quat( truth.fsw_rate.topo.sim_quat, telem.est.q);
    error.knowledge.topo.altitude = truth.fsw_rate.topo.sim_altitude - telem.est.altitude;
    error.knowledge.topo.rate     = truth.fsw_rate.topo.sim_rate - telem.est.mean_rate;
    
    % create error structure for MCI representation
    error.knowledge.mci.pos      = truth.fsw_rate.mci.sim_pos - telem.est.pos;
    error.knowledge.mci.vel      = truth.fsw_rate.mci.sim_vel - telem.est.vel;
    error.knowledge.mci.acc      = truth.fsw_rate.mci.sim_acc - telem.est.accel;
    error.knowledge.mci.euler    = truth.fsw_rate.mci.sim_euler - telem.est.euler_xyz;
    error.knowledge.mci.angle    = total_error_from_quat( truth.fsw_rate.mci.sim_quat, telem.est.q);
    error.knowledge.mci.rate     = truth.fsw_rate.mci.sim_rate - telem.est.mean_rate;
    
    % create error structure for total representation
    error.knowledge.total.pos      = append( getsamples(error.knowledge.mci.pos, iMCI), getsamples(error.knowledge.topo.pos, iTopo) );
    error.knowledge.total.vel      = truth.fsw_rate.total.sim_vel - telem.est.vel;
    error.knowledge.total.acc      = truth.fsw_rate.total.sim_acc - telem.est.accel;
    error.knowledge.total.euler    = truth.fsw_rate.total.sim_euler - telem.est.euler_xyz;
    error.knowledge.total.angle    = append( getsamples(error.knowledge.mci.angle, iMCI), getsamples(error.knowledge.topo.angle, iTopo) );
    error.knowledge.total.rate     = truth.fsw_rate.total.sim_rate - telem.est.mean_rate;
    
    % create error structure for total representation
    error.pointing.total.angle          = total_error_from_quat( truth.fsw_rate.mci.sim_quat, telem.gdn.cmd_quat_inertial_to_body);
    error.pointing.components_error_deg = components_error_from_quat( truth.fsw_rate.mci.sim_quat, telem.gdn.cmd_quat_inertial_to_body);
    error.pointing.flight_components_error_deg = flight_components_error_from_quat( telem.cnt.quat_err);
  
else
    
    % assign null outputs
    error = [];
    
end
