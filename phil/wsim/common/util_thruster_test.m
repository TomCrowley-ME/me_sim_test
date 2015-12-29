%% Unit test for util_common_hrn

%% Initialize inputs

% set up command time vector and specify angle range to be tested
% (spherical angles)
cmd_t=(0:1)'; 
angle=(-180:30:180)*pi/180;

% for each set of spherical angles, calculate the unit vector
k=1;
uv=zeros(length(angle)^2,3);
for a1=angle;
    for a2=angle;
        uv(k,:)=[cos(a1)*cos(a2), cos(a1)*sin(a2), sin(a1)];
        k=k+1;
    end
end

% input the force magnitude input to be tested
forceMagP=5;
forceMag=[cmd_t, ones(size(cmd_t))*forceMagP];

% input the cg to be tested
cgP=[3 2 1];
cg=[cmd_t,ones(size(cmd_t))*cgP];

%input the position of the thruster to be tested
positionP=[4 5 6];
position=[cmd_t,ones(size(cmd_t))*positionP];

%input allowable tolerance on answers
eps=1e-6;

%initialize failure variables
failed_thruster=false;
failed_thruster_with_orientation=false;
failed_thruster_with_orientation_and_position=false;
failed_thruster_force=false;
failed_thruster_force_with_orientation=false;
failed_thruster_torque=false;
failed_thruster_torque_with_position=false;

%% Run simulations for each input vector and test each requirement

for(i=1:size(uv,1))
    % setup the thruster orientation
    orientationP=uv(i,:);
    orientation=[cmd_t,ones(size(cmd_t))*orientationP];
    
    %based on the inputs, calculate the expected force and torque
    expectedForce=forceMagP*orientationP;
    expectedTorque=cross(positionP-cgP,expectedForce);
    
    %calculate the input force for the blocks that only compute torque
    %based on the expected force.
    forceBodyP=expectedForce;
    forceBody=[cmd_t,ones(size(cmd_t))*forceBodyP];
    
    %simulate
    sim('util_thruster_hrn');

    %Check the outputs of each of the blocks
    if(max(abs(thruster_out(2,:)-[expectedForce expectedTorque]))>eps)
        failed_thruster=true;
    end
    
    if(max(abs(thruster_with_orientation_out(2,:)-[expectedForce expectedTorque]))>eps)
        failed_thruster_with_orientation=true;
    end
    
    if(max(abs(thruster_with_orientation_and_position_out(2,:)-[expectedForce expectedTorque]))>eps)
        failed_thruster_with_orientation_and_position=true;
    end

    if(max(abs(thruster_force_out(2,:)-expectedForce))>eps)
        failed_thruster_force_out=true;
    end
    
    if(max(abs(thruster_force_with_orientation_out(2,:)-expectedForce))>eps)
        failed_thruster_force_with_orientation_out=true;
    end
    
    if(max(abs(thruster_torque_out(2,:)-expectedTorque))>eps)
        failed_thruster_torque_out=true;
    end
    
    if(max(abs(thruster_torque_with_position_out(2,:)-expectedTorque))>eps)
        failed_thruster_torque_with_position_out=true;
    end
end


%% Display failure results

if(failed_thruster==true)
    unit_test_record('fail',1,'thruster failed');
else
    unit_test_record('pass',1);
end

if(failed_thruster_with_orientation==true)
    unit_test_record('fail',2,'thruster with orientation failed');
else
    unit_test_record('pass',2);
end
if(failed_thruster_with_orientation_and_position==true)
    unit_test_record('fail',3,'thruster with orientation and position failed');
else
    unit_test_record('pass',3);
end
if(failed_thruster_force==true)
    unit_test_record('fail',4,'thruster force failed');
else
    unit_test_record('pass',4);
end
if(failed_thruster_force_with_orientation==true);
    unit_test_record('fail',5,'thruster force with orientation failed');
else
    unit_test_record('pass',5);
end
if(failed_thruster_torque==true)
    unit_test_record('fail',6,'thruster torque failed');
else
    unit_test_record('pass',6);
end
if(failed_thruster_torque_with_position==true)
    unit_test_record('fail',7,'thruster torque with position failed');
else
    unit_test_record('pass',7);
end

%% end test
disp('Completed util_thruster_test');





