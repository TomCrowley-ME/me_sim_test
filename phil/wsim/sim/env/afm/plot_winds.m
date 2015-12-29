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

i=find(Winds.Altitude==UnitTests.Winds.Case1.Alt.Data(end));

figure
subplot(211),plot(Winds.Speed(1:i),Winds.Altitude(1:i)),grid,ylabel('altitude, m')
xlabel('speed, m/s')
title('Wind Speed and Direction'),set(gcf,'Name','Wind Speed and Azimuth')
subplot(212),plot(Winds.Azimuth(1:i),Winds.Altitude(1:i)),grid,ylabel('altitude, m')
xlabel('azimuth, deg')

%% CASE 1: Vehicle Vehicle heading east, level flight, initial altitude=10m, forward velocity=10 m/s
figure
subplot(211),plot(UnitTests.Winds.Case1.Wind_i.Data,UnitTests.Winds.Case1.Alt.Data,'o'),grid
title('Case 1: Wind Velocity in Inertial Frame versus altitude'),set(gcf,'Name','Case 1 Wind_i & Wind_b')
subplot(212),plot(UnitTests.Winds.Case1.Wind_b.Data,UnitTests.Winds.Case1.Alt.Data,'o'),grid
title('Case 1: Wind Velocity in Body Frame versus altitude')
ylabel('altitude, m'),xlabel('speed, m/s')

figure
subplot(311),plot(UnitTests.Winds.Case1.Vrel_i.Data(:,1),UnitTests.Winds.Case1.Alt.Data,'o'),grid,ylabel('X')
title('Case 1: Relative Velocity in Inertial Frame versus altitude'),set(gcf,'Name','Case 1 Vrel_i')
subplot(312),plot(UnitTests.Winds.Case1.Vrel_i.Data(:,2),UnitTests.Winds.Case1.Alt.Data,'o'),grid,ylabel('Y')
subplot(313),plot(UnitTests.Winds.Case1.Vrel_i.Data(:,3),UnitTests.Winds.Case1.Alt.Data,'o'),grid,ylabel('Z')
xlabel('speed, m/s')

figure
subplot(311),plot(UnitTests.Winds.Case1.Vrel_b.Data(:,1),UnitTests.Winds.Case1.Alt.Data,'o'),grid,ylabel('X')
title('Case 1: Relative Velocity in Body Frame versus altitude'),set(gcf,'Name','Case 1 Vrel_b')
subplot(312),plot(UnitTests.Winds.Case1.Vrel_b.Data(:,2),UnitTests.Winds.Case1.Alt.Data,'o'),grid,ylabel('Y')
subplot(313),plot(UnitTests.Winds.Case1.Vrel_b.Data(:,3),UnitTests.Winds.Case1.Alt.Data,'o'),grid,ylabel('Z')
xlabel('speed, m/s')

%% CASE 2: Vehicle heading north, level flight, initial altitude=10m, forward velocity=10 m/s
figure
subplot(211),plot(UnitTests.Winds.Case2.Wind_i.Data,UnitTests.Winds.Case2.Alt.Data,'o'),grid
title('Case 2: Wind Velocity in Inertial Frame versus altitude'),set(gcf,'Name','Case 2 Wind_i & Wind_b')
subplot(212),plot(UnitTests.Winds.Case2.Wind_b.Data,UnitTests.Winds.Case2.Alt.Data,'o'),grid
title('Case 2: Wind Velocity in Body Frame versus altitude')
ylabel('altitude, m'),xlabel('speed, m/s')

figure
subplot(311),plot(UnitTests.Winds.Case2.Vrel_i.Data(:,1),UnitTests.Winds.Case2.Alt.Data,'o'),grid,ylabel('X')
title('Case 2: Relative Velocity in Inertial Frame versus altitude'),set(gcf,'Name','Case 2 Vrel_i')
subplot(312),plot(UnitTests.Winds.Case2.Vrel_i.Data(:,2),UnitTests.Winds.Case2.Alt.Data,'o'),grid,ylabel('Y')
subplot(313),plot(UnitTests.Winds.Case2.Vrel_i.Data(:,3),UnitTests.Winds.Case2.Alt.Data,'o'),grid,ylabel('Z')
xlabel('speed, m/s')

figure
subplot(311),plot(UnitTests.Winds.Case2.Vrel_b.Data(:,1),UnitTests.Winds.Case2.Alt.Data,'o'),grid,ylabel('X')
title('Case 2: Relative Velocity in Body Frame versus altitude'),set(gcf,'Name','Case 2 Vrel_b')
subplot(312),plot(UnitTests.Winds.Case2.Vrel_b.Data(:,2),UnitTests.Winds.Case2.Alt.Data,'o'),grid,ylabel('Y')
subplot(313),plot(UnitTests.Winds.Case2.Vrel_b.Data(:,3),UnitTests.Winds.Case2.Alt.Data,'o'),grid,ylabel('Z')
xlabel('speed, m/s')

%% CASE 3: Vehicle heading vertical, initial altitude=0m, forward velocity=10 m/s
figure
subplot(211),plot(UnitTests.Winds.Case3.Wind_i.Data,UnitTests.Winds.Case3.Alt.Data),grid
title('Case 3: Wind Velocity in Inertial Frame versus altitude'),set(gcf,'Name','Case 3 Wind_i & Wind_b')
ylabel('altitude, m'),xlabel('speed, m/s')
subplot(212),plot(UnitTests.Winds.Case3.Wind_b.Data,UnitTests.Winds.Case3.Alt.Data),grid
title('Case 3: Wind Velocity in Body Frame versus altitude')
ylabel('altitude, m'),xlabel('speed, m/s')

figure
subplot(311),plot(UnitTests.Winds.Case3.Vrel_i.Data(:,1),UnitTests.Winds.Case3.Alt.Data),grid,ylabel('X')
title('Case 3: Relative Velocity in Inertial Frame versus altitude'),set(gcf,'Name','Case 3 Vrel_i')
subplot(312),plot(UnitTests.Winds.Case3.Vrel_i.Data(:,2),UnitTests.Winds.Case3.Alt.Data),grid,ylabel('Y')
subplot(313),plot(UnitTests.Winds.Case3.Vrel_i.Data(:,3),UnitTests.Winds.Case3.Alt.Data),grid,ylabel('Z')
xlabel('speed, m/s')

figure
subplot(311),plot(UnitTests.Winds.Case3.Vrel_b.Data(:,1),UnitTests.Winds.Case3.Alt.Data),grid,ylabel('X')
title('Case 3: Relative Velocity in Body Frame versus altitude'),set(gcf,'Name','Case 3 Vrel_b')
subplot(312),plot(UnitTests.Winds.Case3.Vrel_b.Data(:,2),UnitTests.Winds.Case3.Alt.Data),grid,ylabel('Y')
subplot(313),plot(UnitTests.Winds.Case3.Vrel_b.Data(:,3),UnitTests.Winds.Case3.Alt.Data),grid,ylabel('Z')
xlabel('speed, m/s')

clear i Winds