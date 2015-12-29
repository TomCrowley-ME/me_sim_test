%% Unit test for util_quat_hrn

%% Initialize

cmd_t=(0:12)';
eps=1e-9;
eps_prop=1e-5; % tolerance for the quaternion propagator
v_in=[cmd_t ones(size(cmd_t))*[0 0 1]];

%% Set up quaternions and expected results and simulate

%initialize the euler input and expected quaternion matrices
euler_in=zeros(13,4);
q_expected=zeros(13,4);
euler_in(:,1)=(0:12)';
euler_in_seq=[-2 -1 1 2]'*90*pi/180;  %increments of 90 degrees
q_v=[-1 -sqrt(2)/2 sqrt(2)/2 1]';     %expected q(i) at intervals of 90 degrees
q_m=[0 sqrt(2)/2 sqrt(2)/2 0]';       %expected q4 at intervals of 90 degrees

%set the euler input and expected quaternions along each axis
for i=1:3;
    j=4*i-3;
    euler_in(j:j+3,i+1)=euler_in_seq;
    q_expected(j:j+3,4)=q_m;
    q_expected(j:j+3,i)=q_v;
end

%fill in the last expected value for zero euler angles
q_expected(13,4)=1;

%set up quaternion inputs
q_in=[cmd_t q_expected];
euler_expected=euler_in(:,2:4);
euler_expected(5:8,1)=pi;  % these are equivalent to zero rotation and
euler_expected(5:8,3)=pi;  % expected artifacts of the computation
euler_expected(5,2)=0;     %
euler_expected(8,2)=0;     %
euler_expected(find(euler_expected==-pi))=pi; %

%Set up expected rotations of a [0,0,1] vector from the Reference to the Body frame,
%given a sequence of quaternion with intervals of 90 degrees
expected_rotation_r2b=[0 0 -1; 0 -1 0; 0 1 0; 0 0 -1;
    0 0 -1; 1 0 0; -1 0 0; 0 0 -1;
    0 0 1; 0 0 1; 0 0 1; 0 0 1;
    0 0 1];

%Set up expected rotations of a [0,0,1] vector from the Body to the Reference frame,
%given a sequence of quaternion with intervals of 90 degrees
expected_rotation_b2r=[0 0 -1; 0 1 0; 0 -1 0; 0 0 -1;
    0 0 -1; -1 0 0; 1 0 0; 0 0 -1;
    0 0 1; 0 0 1; 0 0 1; 0 0 1;
    0 0 1];

%Set up expected quaternion Conjugate
expected_quat_conj(:,1:3) = -q_in (:,2:4);
expected_quat_conj(:,4) = q_in(:,5);

%Set up expected quaternions Multiplication from "Quaternion and Rotation
%Sequences" by Jack Kuipers, page107.
p_in(:,1) = q_in(:,1);
p_in(:,2:5) = repmat([1 2 3 4],13,1);
for i=1:length(cmd_t)
    q1=q_in(i,2); q2=q_in(i,3); q3=q_in(i,4); q4=q_in(i,5);
    p1=p_in(i,2); p2=p_in(i,3); p3=p_in(i,4); p4=p_in(i,5);
    expected_multp(i,1) = p4*q1+p1*q4-p2*q3+p3*q2;
    expected_multp(i,2) = p4*q2+p1*q3+p2*q4-p3*q1;
    expected_multp(i,3) = p4*q3-p1*q2+p2*q1+p3*q4;
    expected_multp(i,4) = p4*q4-p1*q1-p2*q2-p3*q3;
end

%Run the "quat_prop_test.m" in order to calculate the error between the 
%Discrete and Continuous Quaternion Propagation
% quat_prop_test;


sim('util_quat_hrn');

%% check euler angles util_quat_0001
if(max(max(abs(q_expected-q_out)))>eps)
    unit_test_record('fail',1,'euler to quaternion conversion incorrect');
else
    unit_test_record('pass',1);
end

%% check euler angles util_quat_0002
if(max(max(abs(euler_expected-euler_out)))>eps)
    unit_test_record('fail',2,'quaternion to euler conversion incorrect');
else
    unit_test_record('pass',2);
end

%% check rotation using dcm matrix util_quat_0003
if(max(max(abs(expected_rotation_r2b - dcm_rotation)))>eps)
    unit_test_record('fail',3,'quaternion to dcm incorrect');
else
    unit_test_record('pass',3);
end

%% check rotation using quaternions util_quat_0004, util_quat_005
if(max(max(abs(v_in(:,2:4) - quat_rotation_r2b)))>eps)||...
        (max(max(abs(expected_rotation_b2r-quat_rotation_b2r)))>eps)
    unit_test_record('fail',4,'quaternion rotation r2b and b2r incorrect');
else
    unit_test_record('pass',4);
    unit_test_record('pass',5);
end

%% check *quaternion conjugate* util_quat_0006
if(max(max(abs(expected_quat_conj - quat_conj)))>eps)
    unit_test_record('fail',6,'quaternion derivative');
else
    unit_test_record('pass',6);
end

%% check *quaternion multiplication* util_quat_0007
if(max(max(abs(expected_multp - quat_multp)))>eps)
    unit_test_record('fail',7,'quaternion multiplication');
else
    unit_test_record('pass',7);
end

%% check *quaternion propagation* util_quat_0008
if(max(max(max(discrete_const_propagator_error)))>eps_prop)
    unit_test_record('fail',8,'quaternion discrete propapator');
else
    unit_test_record('pass',8);
end

%% end test
disp('Completed quat_common_test');








