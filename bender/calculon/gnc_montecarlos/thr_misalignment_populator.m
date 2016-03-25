% Thruster orientation dispersion - MX Vehicle
% Author: Jim Kaidy 09/28/2014
% 
% MX Thrusters including biprop

thruster_list = [   tfl_thruster1_orientation/norm(tfl_thruster1_orientation);...
                            tfl_thruster2_orientation/norm(tfl_thruster2_orientation);...
                            tfl_thruster3_orientation/norm(tfl_thruster3_orientation);...
                            tfl_thruster4_orientation/norm(tfl_thruster4_orientation);...
                            tfl_thruster5_orientation/norm(tfl_thruster5_orientation);...
                            tfl_thruster6_orientation/norm(tfl_thruster6_orientation);...
                            tfl_thruster7_orientation/norm(tfl_thruster7_orientation);...
                            tfl_thruster8_orientation/norm(tfl_thruster8_orientation);...
                            tfl_thruster9_orientation/norm(tfl_thruster9_orientation);...
                            tfl_thruster10_orientation/norm(tfl_thruster10_orientation);...
                            tfl_thruster11_orientation/norm(tfl_thruster11_orientation);...
                            tfl_thruster12_orientation/norm(tfl_thruster12_orientation);...
                            tfl_thruster13_orientation/norm(tfl_thruster13_orientation);...
                            tfl_thruster14_orientation/norm(tfl_thruster14_orientation);...
                            tfl_thruster15_orientation/norm(tfl_thruster15_orientation);...
                            tfl_thruster16_orientation/norm(tfl_thruster16_orientation);...
                            tfl_thruster17_orientation/norm(tfl_thruster17_orientation);...
                            tfl_thruster18_orientation/norm(tfl_thruster18_orientation);...
                            tfl_thruster19_orientation/norm(tfl_thruster19_orientation);...
                            tfl_thruster20_orientation/norm(tfl_thruster20_orientation);...
                            tfl_thruster21_orientation/norm(tfl_thruster21_orientation);...
                            tfl_thruster22_orientation/norm(tfl_thruster22_orientation);...
                            tfl_thruster23_orientation/norm(tfl_thruster23_orientation);...
                            tfl_thruster24_orientation/norm(tfl_thruster24_orientation);...
                            tfl_thruster25_orientation/norm(tfl_thruster25_orientation);...
                            tfl_thruster26_orientation/norm(tfl_thruster26_orientation);...
                            tfl_thruster27_orientation/norm(tfl_thruster27_orientation)];

thruster_list_baseline = thruster_list;
                
if exist('tfl_thruster_egc_orientation')
    thruster_list(25,:) = tfl_thruster_egc_orientation;
end
                    
for i=1:27
    
    % Use uniform distribution to vary individual thruster alignment angles and
    % vary about nominal thrust vector

    thr_unit = thruster_list(i,:);
    zhat = [0 0 1]';
    xvec = cross(thr_unit,zhat)';
    xhat = xvec/sqrt(xvec(1)^2 + xvec(2)^2 + xvec(3)^2);
    yvec = cross(thr_unit,xhat)';
    yhat = yvec/sqrt(yvec(1)^2 + yvec(2)^2 + yvec(3)^2);
    if thr_unit(3) == zhat(3);
        xhat = [1 0 0];
        yhat = [0 1 0];
    end
    if thr_unit(3) == -zhat(3)
        xhat = [-1 0 0];
        yhat = [ 0 1 0];
    end
   
    Tmat(1,1) = xhat(1);
    Tmat(1,2) = xhat(2);
    Tmat(1,3) = xhat(3);
    Tmat(2,1) = yhat(1);
    Tmat(2,2) = yhat(2);
    Tmat(2,3) = yhat(3);
    Tmat(3,1) = thr_unit(1);
    Tmat(3,2) = thr_unit(2);
    Tmat(3,3) = thr_unit(3);

    q_thr_to_zthr = dcm_to_quat(Tmat);

    az_ang = az_ang_per_case(i);
    qzrot = [0 0 sind(az_ang/2) cosd(az_ang/2)];
    misalignment_ang_deg = misalignments_per_case(i);
    qxrot = [sind(misalignment_ang_deg/2) 0 0 cosd(misalignment_ang_deg/2)];

    sim('compute_thruster_misalignment_mc')
    
    thruster_list(i,:) = thr_misaligned.Data(1,:);
end
tfl_thruster1_orientation = thruster_list(1,:);
tfl_thruster2_orientation = thruster_list(2,:);
tfl_thruster3_orientation = thruster_list(3,:);
tfl_thruster4_orientation = thruster_list(4,:);
tfl_thruster5_orientation = thruster_list(5,:);
tfl_thruster6_orientation = thruster_list(6,:);
tfl_thruster7_orientation = thruster_list(7,:);
tfl_thruster8_orientation = thruster_list(8,:);
tfl_thruster9_orientation = thruster_list(9,:);
tfl_thruster10_orientation = thruster_list(10,:);
tfl_thruster11_orientation = thruster_list(11,:);
tfl_thruster12_orientation = thruster_list(12,:);
tfl_thruster13_orientation = thruster_list(13,:);
tfl_thruster14_orientation = thruster_list(14,:);
tfl_thruster15_orientation = thruster_list(15,:);
tfl_thruster16_orientation = thruster_list(16,:);
tfl_thruster17_orientation = thruster_list(17,:);
tfl_thruster18_orientation = thruster_list(18,:);
tfl_thruster19_orientation = thruster_list(19,:);
tfl_thruster20_orientation = thruster_list(20,:);
tfl_thruster21_orientation = thruster_list(21,:);
tfl_thruster22_orientation = thruster_list(22,:);
tfl_thruster23_orientation = thruster_list(23,:);
tfl_thruster24_orientation = thruster_list(24,:);

if exist('tfl_thruster_egc_orientation')
    tfl_thruster_egc_orientation =thruster_list(25,:);
else
    tfl_thruster25_orientation = thruster_list(25,:);
    tfl_thruster26_orientation = thruster_list(26,:);
    tfl_thruster27_orientation = thruster_list(27,:);
end
 
for i=1:27
    misalign_ang_deg(i) = acosd(dot(thruster_list_baseline(i,:),thruster_list(i,:)));
end

    