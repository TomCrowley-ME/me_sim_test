
%%%%%
%%%
%%% Unit test for util_common_hrn
%%%
%%%%%

%%%
%%% Initialize Inputs and Answers
%%%

%%% General Constants and Inputs

eps = 1e-9;         % allowable tolerance on answers
tvec = [0:.1:1]';


%%% Test 1 "cross_product" Inputs

cross_inputs_a = tvec;
cross_inputs_a(:,2:4) = repmat([2 3 4], size(tvec,1), 1);

cross_inputs_b = tvec;
cross_inputs_b(:,2:4) = repmat([4 5 6], size(tvec,1), 1);

cross_inputs_a(2,2:4) = [0 0 0];
cross_inputs_b(2,2:4) = [4 5 6];

cross_inputs_a(3,2:4) = [0 0 0];
cross_inputs_b(3,2:4) = [0 0 0];

cross_inputs_a(4,2:4) = [1 1 1];
cross_inputs_b(4,2:4) = [0 0 0];

cross_inputs_a(5,2:4) = [.01 .01 .01];
cross_inputs_b(5,2:4) = [1 1 1];

cross_inputs_a(6,2:4) = cross_inputs_a(5,2:4);
cross_inputs_b(6,2:4) = -cross_inputs_b(5,2:4);

%%% Test 1 Answers

cross_answer = cross(cross_inputs_a(:,2:4), cross_inputs_b(:,2:4));


%%% Test 2 & 3 "vector_magnitude" & "unit_vector" Inputs

vector_inputs = tvec;
vector_inputs(:,2:4) = repmat([2 3 6], size(tvec,1), 1);

vector_inputs(2,2:4) = [0 0 0];
vector_inputs(3,2:4) = [1 1 1];
vector_inputs(4,2:4) = [.001 .004 -.0001];
vector_inputs(5,2:4) = [0 0 1];
vector_inputs(6,2:4) = [-1 1 -1];
vector_inputs(7,2:4) = -[0 0 1];

%%% Test 2 & 3 Answers

vm_answer = [];
uv_answer = [];

for curi = 1:size(tvec,1)
    curvec = vector_inputs(curi,2:4);
    
    vm_answer(curi,1) = sqrt(curvec * curvec');         % vector_magnitude answers
    
    if vm_answer(curi,1) ~= 0
        uv_answer(curi,1:3) = curvec/vm_answer(curi,1); % unit_vector answers
    else
        uv_answer(curi,1:3) = [0 0 0];                  % unit_vector answers (for zero vector)
    end
end


%%% Test 4 "latch" & "simple_latch" Inputs

latch_Initial_Output_Value = 0;

latch_inputs = [tvec ones(size(tvec))*2];
latch_inputs(6:end,2) = 5;

trigger_inputs = [tvec zeros(size(tvec))];
trigger_inputs(3,2) = 1;
trigger_inputs(8,2) = 1;

%%% Test 4 Answers

trigger_diffs = [0; diff(trigger_inputs(:,2))];

latch_answer = latch_Initial_Output_Value*ones(size(tvec));

latchActivationRows = find(trigger_diffs == 1);

for activation_num = 1:(size(latchActivationRows,1) - 1)
    curRangeStart = latchActivationRows(activation_num,1);
    curRangeEnd   = latchActivationRows(activation_num+1,1) - 1;
    latch_answer(curRangeStart:curRangeEnd,1) = latch_inputs(latchActivationRows(activation_num,1),2);
end
latch_answer(latchActivationRows(end,1):end,1) = latch_inputs(latchActivationRows(end,1),2);


%%% Test 5 "step_safe" Inputs

step_Step_Time = 0.3;
step_Initial_Value = 0;
step_Final_Value = 5;

step_clock_inputs = [tvec tvec];

%%% Test 5 Answers

step_answer = zeros(size(tvec,1),1);
step_answer(step_clock_inputs(:,2)>step_Step_Time,1) = 5;


%%% Test 6 "ramp_safe" Inputs

ramp_clock_inputs = [tvec tvec];

ramp_Slope = 1;
ramp_Start_Time = 0.35;
ramp_Initial_Output = 0;

%%% Test 6 Answers

ramp_answer = zeros(size(tvec,1),1);
ramp_vals = ramp_Initial_Output + ramp_Slope*(tvec - ramp_Start_Time);
ramp_answer(ramp_clock_inputs(:,2)>0.35,1) = ramp_vals(ramp_clock_inputs(:,2)>ramp_Start_Time,1);


%%% Test 7 "quantize_and_saturate" Inputs

quantize_and_saturate_Resolution = 1;
quantize_and_saturate_Output_Minimum = -3*quantize_and_saturate_Resolution;
quantize_and_saturate_Output_Maximum = 3*quantize_and_saturate_Resolution;

quantize_inputs=[tvec tvec*10-4.4];

%%% Test 7 Answers
%%% Four outputs: ceil, floor, truncate, round

quantize_answers = [quantize_inputs(:,2) quantize_inputs(:,2) ...
    quantize_inputs(:,2) quantize_inputs(:,2)];

quantize_answers = quantize_answers./quantize_and_saturate_Resolution;

quantize_answers(:,1) = ceil(quantize_answers(:,1));
quantize_answers(:,2) = floor(quantize_answers(:,2));
quantize_answers(:,3) = fix(quantize_answers(:,3));
quantize_answers(:,4) = round(quantize_answers(:,4));

quantize_answers = quantize_answers.*quantize_and_saturate_Resolution;

for curCol = 1:4

    quantize_answers(quantize_answers(:,curCol) > quantize_and_saturate_Output_Maximum,curCol) ...
        = quantize_and_saturate_Output_Maximum;
    quantize_answers(quantize_answers(:,curCol) < quantize_and_saturate_Output_Minimum,curCol) ...
        = quantize_and_saturate_Output_Minimum;

end


%%% Test 8 "invert_3x3_matrix" Inputs

invert_matrix_input = [1 2 3; 0 4 2; 1 3 0];
invert_3x3_matrix_inputs.time = tvec;
invert_3x3_matrix_inputs.signals.dimensions = [3 3];
invert_3x3_matrix_inputs.signals.values = repmat(invert_matrix_input, [1 1 size(tvec,1)]);

invert_3x3_matrix_inputs.signals.values(:,:,2) = [1 0 0; 0 1 0; 0 0 1];
invert_3x3_matrix_inputs.signals.values(:,:,3) = [1 2 3; 4 5 6; 7 8 13];
invert_3x3_matrix_inputs.signals.values(:,:,4) = [-12 57 49; 88 1 -400; 3 2 800];

%%% Test 8 Answers

for curIter = 1:size(tvec,1)
    invert_matrix_answer(:,:,curIter) = inv(invert_matrix_input);
end


%%% Test 9 "noise_generator" Inputs

noise_generator_std_deviation = [5 5 5];
noise_generator_bias = [10 10 10];
noise_generator_seed = [50 51 49];
noise_generator_on_flag = 1;
noise_generator_sample_time = 0.1;

%%% Test 9 Answers

% Matlab random number generator in hrn file uses same Inputs
% noise_answers is generated by that block


%%% Test 10 & 11 "deg_to_rad" & "rad_to_deg" Inputs

deg_to_rad_input = tvec;
stepsize = 360*2.2/(size(tvec,1)-1);
deg_to_rad_input(:,2) = [0:stepsize:360*2.2]-360*1.1';

rad_to_deg_input = tvec;
stepsize = 2*pi*2.2/(size(tvec,1)-1);
rad_to_deg_input(:,2) = [0:stepsize:2*pi*2.2]-2*pi*1.1';

%%% Test 10 & 11 Answers

deg_to_rad_sf = 1/180*pi;
rad_to_deg_sf = 1/pi*180;

deg_to_rad_answers = deg_to_rad_input(:,2) * deg_to_rad_sf;
rad_to_deg_answers = rad_to_deg_input(:,2) * rad_to_deg_sf;


%%%
%%% Simulate test harness
%%%

sim('util_common_hrn');


%%%
%%% Compare simulation outputs with expected answers
%%%

%%% Test 1 "cross_product" Check: util_common_0001

if max(max(abs(cross_outputs - cross_answer))) ~= 0
    unit_test_record('fail', 1, 'cross product failed');
else
    unit_test_record('pass', 1);
end


%%% Test 2 "vector_magnitude" Check: util_common_0002

if max(max(abs(vm_outputs - vm_answer))) > eps
    unit_test_record('fail', 2, 'vector magnitude failed');
else
    unit_test_record('pass', 2);
end

%%% Test 3 "unit_vector" Check: util_common_0003

if max(max(abs(uv_outputs - uv_answer))) > eps
    unit_test_record('fail', 3, 'unit vector failed');
else
    unit_test_record('pass', 3);
end


%%% Test 4 "latch" & "simple_latch" Check: util_common_0004

if max(max(abs(latch_outputs.signals.values - [latch_answer latch_answer]))) ~= 0
    unit_test_record('fail', 4, 'latch checks failed');
else
    unit_test_record('pass', 4);
end

%%% Test 5 "step_safe" Check: util_common_0005

if max(max(abs(step_answer - step_output))) ~= 0
    unit_test_record('fail', 5, 'safe step failed');
else
    unit_test_record('pass', 5);
end

%%% Test 6 "ramp_safe" Check: util_common_0006

if max(max(abs(ramp_answer - ramp_output))) > eps
    unit_test_record('fail', 6, 'safe ramp failed');
else
    unit_test_record('pass', 6);
end


%%% %%% Test 7 "quantize_and_saturate" Check: util_common_0007

if max(max(abs(quantize_answers - quantize_output))) ~= 0
    unit_test_record('fail', 7, 'quantize and saturate failed');
else
    unit_test_record('pass', 7);
end


%%% Test 8 "invert_3x3_matrix" Check: util_common_0008

if max(max(abs(invert_matrix_answer - inverse_output))) > eps
    unit_test_record('fail', 8, 'matrix 3x3 inverse failed');
else
    unit_test_record('pass', 8);
end


%%% Test 9 "noise_generator" Check: util_common_0009

if max(max(abs(noise_output - noise_answers))) > 0
    unit_test_record('fail', 9, 'noise generator failed');
else
    unit_test_record('pass', 9);
end


%%% Test 10 "deg_to_rad" Check: util_common_0010

if max(max(abs(deg_to_rad_output - deg_to_rad_answers))) > eps
    unit_test_record('fail', 1, 'degrees to radians failed');
else
    unit_test_record('pass', 10);
end

%%% Test 11 "rad_to_deg" Check: util_common_0011

if max(max(abs(rad_to_deg_output - rad_to_deg_answers))) > eps
    unit_test_record('fail', 1, 'radians to degrees failed');
else
    unit_test_record('pass', 11);
end

%%% End Of Test
disp(sprintf('\nCompleted util_common_test\n\n'));






