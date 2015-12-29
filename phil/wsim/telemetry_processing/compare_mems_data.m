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
% compare_mems_data.m                                                     %
%                                                                         %
% compares raw HIL MEMS FSW telemetry to SIM truth                        %
% 10/21/14                                                                %
%-------------------------------------------------------------------------%

function compare_mems_data()
telem = evalin('base', 'telem');
truth = evalin('base', 'truth');

mem_length = length(telem.mem) * 10;
mem_time = truth.mem.Time(1:mem_length);

mem_data = tscollection(mem_time);

mem_data.mem1_accel = reshape_mems_data(telem.mem.mem1_accel_samples);
mem_data.mem1_gyro = reshape_mems_data(telem.mem.mem1_gyro_samples);
mem_data.mem2_accel = reshape_mems_data(telem.mem.mem2_accel_samples);
mem_data.mem2_gyro = reshape_mems_data(telem.mem.mem2_gyro_samples);
mem_data.mem3_accel = reshape_mems_data(telem.mem.mem3_accel_samples);
mem_data.mem3_gyro = reshape_mems_data(telem.mem.mem3_gyro_samples);

function newts = reshape_mems_data(ts)
    x = reshape(fliplr(ts.Data(:,1:10))', 1, mem_length);
    y = reshape(fliplr(ts.Data(:,11:20))', 1, mem_length);
    z = reshape(fliplr(ts.Data(:,21:30))', 1, mem_length);
    newts = timeseries([x; y; z], mem_time);
end

figure('Position', [0 200 640 640]);
subplot(2,1,1); plot(truth.mem.mem1_accel);
hold_colors; plot(mem_data.mem1_accel, 'o');
title('Mem1 Accel'); grid on;
subplot(2,1,2); plot(truth.mem.mem1_gyro);
hold_colors; plot(mem_data.mem1_gyro, 'o');
title('Mem1 Gyro'); grid on;
mem1_plots = gcf;
link_fig_axes(mem1_plots);

figure('Position', [640 200 640 640]); 
subplot(2,1,1); plot(truth.mem.mem2_accel);
hold_colors; plot(mem_data.mem2_accel, 'o');
title('Mem2 Accel'); grid on;
subplot(2,1,2); plot(truth.mem.mem2_gyro);
hold_colors; plot(mem_data.mem2_gyro, 'o');
title('Mem2 Gyro'); grid on;
mem2_plots = gcf;
link_fig_axes(mem2_plots);

figure('Position', [1280 200 640 640]); 
subplot(2,1,1); plot(truth.mem.mem3_accel);
hold_colors; plot(mem_data.mem3_accel, 'o');
title('Mem3 Accel'); grid on;
subplot(2,1,2); plot(truth.mem.mem3_gyro);
hold_colors; plot(mem_data.mem3_gyro, 'o');
title('Mem3 Gyro'); grid on;
mem3_plots = gcf;
link_fig_axes(mem3_plots);

link_fig_axes([mem1_plots mem2_plots mem3_plots]);

end