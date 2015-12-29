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
% compare_imu_data.m                                                      %
%                                                                         %
% compares raw HIL IMU FSW telemetry to SIM truth                         %
% 10/21/14                                                                %
%-------------------------------------------------------------------------%

function compare_imu_data()
telem = evalin('base', 'telem');
truth = evalin('base', 'truth');

accel = serialize_100hz_sensor_data(telem.imu.accel);
gyro = serialize_100hz_sensor_data(telem.imu.gyro);
incline = serialize_100hz_sensor_data(telem.imu.incline);

figure; plot(truth.imu.accel);
hold_colors; plot(accel, 'o');
title('Accel'); grid on;
accel_plot = gcf;

figure; plot(truth.imu.gyro);
hold_colors; plot(gyro, 'o');
title('Gyro'); grid on;
gyro_plot = gcf;

figure; plot(truth.imu.incline);
hold_colors; plot(incline, 'o');
title('Incline'); grid on;
incline_plot = gcf;

link_fig_axes([accel_plot gyro_plot incline_plot]);

end