
dt = 0.1; %time-step
time_digit = [0:dt:20];
l = length(time_digit);
sine = sin(time_digit);
clear omega_in reset_in

%input the RESET with few impulses.
reset_in(:,1) = time_digit;
reset_in(:,2) = zeros(size(time_digit));
for i=1:3
    reset_in(fix(length(time_digit)*i/4),2) = 1;
end

%input the INITIAL_q values.
q_init(:,1) = time_digit;
q_init(:,2:5) = zeros(l,4);
q_init(1:fix(l/2),2:5) = repmat([0 0 0 1],fix(l/2),1);
q_init(fix(l/2)+1:l,2:5) = repmat([0.7071 0 0 0.7071],fix(l/2)+1,1);

%input a sine-wave for OMEGA_IN alternating for each axis.
omega_in(:,1) = time_digit;
omega_in(:,2:4) = 0;

for i=2:5
    % sine-wave for all three axis together
    if i==5
        omega_in(:,2) = sine;
        omega_in(:,3) = sine;
        omega_in(:,4) = sine;
    % alternating sine-wave for each of the three axis for omega_in    
    else
        omega_in(:,i) = sine;
    end
    sim('quat_prop_hrn');
    
    % Calculate the error between the discrete and continious quat propagation:
    error(i-1,:,:) = abs(q_discrete - q_const.signals.values);%(idxd1,j) (idxc1,j)  /q.signals.values(idxc1,1)*100;

    %reset omega_in
    omega_in(:,i) = 0;
end

% Store the error in order to be evaluated in the "util_quat_test.m" file
discrete_const_propagator_error = error;

