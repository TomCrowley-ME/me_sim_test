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

figure
subplot(311),plot(UnitTests.Aero.Case1.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case1.AeroForces.Data(:,1),'o'),grid,ylabel('Fx')
title('Case 1: Aerodynamic Forces in Body Frame, N'),set(gcf,'Name','Case 1 AeroForces')
subplot(312),plot(UnitTests.Aero.Case1.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case1.AeroForces.Data(:,2),'o'),grid,ylabel('Fy')
subplot(313),plot(UnitTests.Aero.Case1.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case1.AeroForces.Data(:,3),'o'),grid,ylabel('Fz')
xlabel('forward velocity, m/s')

figure
subplot(311),plot(UnitTests.Aero.Case1.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case1.WindFrame.Data(:,1),'o'),grid,ylabel('Drag')
title('Case 1: Aerodynamic Forces in Wind Frame, N'),set(gcf,'Name','Case 1 WindFrame')
subplot(312),plot(UnitTests.Aero.Case1.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case1.WindFrame.Data(:,2),'o'),grid,ylabel('Side')
subplot(313),plot(UnitTests.Aero.Case1.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case1.WindFrame.Data(:,3),'o'),grid,ylabel('Lift')
xlabel('forward velocity, m/s')

% figure
% subplot(311),plot(UnitTests.Aero.Case1.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case1.AeroMoments.Data(:,1),'o'),grid,ylabel('Mx')
% title('Case 1: Aerodynamic Moments about CG in Body Frame, Nm'),set(gcf,'Name','Case 1 AeroMoments')
% subplot(312),plot(UnitTests.Aero.Case1.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case1.AeroMoments.Data(:,2),'o'),grid,ylabel('My')
% subplot(313),plot(UnitTests.Aero.Case1.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case1.AeroMoments.Data(:,3),'o'),grid,ylabel('Mz')
% xlabel('forward velocity, m/s')

figure
subplot(311),plot(UnitTests.Aero.Case2.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case2.AeroForces.Data(:,1),'o'),grid,ylabel('Fx')
title('Case 2: Aerodynamic Forces in Body Frame, N'),set(gcf,'Name','Case 2 AeroForces')
subplot(312),plot(UnitTests.Aero.Case2.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case2.AeroForces.Data(:,2),'o'),grid,ylabel('Fy')
subplot(313),plot(UnitTests.Aero.Case2.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case2.AeroForces.Data(:,3),'o'),grid,ylabel('Fz')
xlabel('forward velocity, m/s')

figure
subplot(311),plot(UnitTests.Aero.Case2.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case2.WindFrame.Data(:,1),'o'),grid,ylabel('Drag')
title('Case 2: Aerodynamic Forces in Wind Frame, N'),set(gcf,'Name','Case 2 WindFrame')
subplot(312),plot(UnitTests.Aero.Case2.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case2.WindFrame.Data(:,2),'o'),grid,ylabel('Side')
subplot(313),plot(UnitTests.Aero.Case2.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case2.WindFrame.Data(:,3),'o'),grid,ylabel('Lift')
xlabel('forward velocity, m/s')

% figure
% subplot(311),plot(UnitTests.Aero.Case2.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case2.AeroMoments.Data(:,1),'o'),grid,ylabel('Mx')
% title('Case 2: Aerodynamic Moments about CG in Body Frame, Nm'),set(gcf,'Name','Case 2 AeroMoments')
% subplot(312),plot(UnitTests.Aero.Case2.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case2.AeroMoments.Data(:,2),'o'),grid,ylabel('My')
% subplot(313),plot(UnitTests.Aero.Case2.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case2.AeroMoments.Data(:,3),'o'),grid,ylabel('Mz')
% xlabel('forward velocity, m/s')

figure
subplot(311),plot(UnitTests.Aero.Case3.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case3.AeroForces.Data(:,1)),grid,ylabel('Fx')
title('Case 3: Aerodynamic Forces in Body Frame, N'),set(gcf,'Name','Case 3 AeroForces')
subplot(312),plot(UnitTests.Aero.Case3.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case3.AeroForces.Data(:,2)),grid,ylabel('Fy')
subplot(313),plot(UnitTests.Aero.Case3.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case3.AeroForces.Data(:,3)),grid,ylabel('Fz')
xlabel('forward velocity, m/s')

figure
subplot(311),plot(UnitTests.Aero.Case3.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case3.WindFrame.Data(:,1)),grid,ylabel('Drag')
title('Case 3: Aerodynamic Forces in Wind Frame, N'),set(gcf,'Name','Case 3 WindFrame')
subplot(312),plot(UnitTests.Aero.Case3.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case3.WindFrame.Data(:,2)),grid,ylabel('Side')
subplot(313),plot(UnitTests.Aero.Case3.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case3.WindFrame.Data(:,3)),grid,ylabel('Lift')
xlabel('forward velocity, m/s')

% figure
% subplot(311),plot(UnitTests.Aero.Case3.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case3.AeroMoments.Data(:,1)),grid,ylabel('Mx')
% title('Case 3: Aerodynamic Moments about CG in Body Frame, Nm'),set(gcf,'Name','Case 3 AeroMoments')
% subplot(312),plot(UnitTests.Aero.Case3.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case3.AeroMoments.Data(:,2)),grid,ylabel('My')
% subplot(313),plot(UnitTests.Aero.Case3.FlightPath.Vrel_b.Ub.Data,UnitTests.Aero.Case3.AeroMoments.Data(:,3)),grid,ylabel('Mz')
% xlabel('forward velocity, m/s')

figure
subplot(311),plot(UnitTests.Aero.Case4.FlightPath.Alpha.Data*180/pi,UnitTests.Aero.Case4.AeroForces.Data(:,1)),grid,ylabel('Fx')
title('Case 4: Aerodynamic Forces in Body Frame, N'),set(gcf,'Name','Case 4 AeroForces vs Alpha')
subplot(312),plot(UnitTests.Aero.Case4.FlightPath.Alpha.Data*180/pi,UnitTests.Aero.Case4.AeroForces.Data(:,2)),grid,ylabel('Fy')
subplot(313),plot(UnitTests.Aero.Case4.FlightPath.Alpha.Data*180/pi,UnitTests.Aero.Case4.AeroForces.Data(:,3)),grid,ylabel('Fz')
xlabel('angle of attack, deg')

figure
subplot(311),plot(UnitTests.Aero.Case4.FlightPath.Alpha.Data*180/pi,UnitTests.Aero.Case4.WindFrame.Data(:,1)),grid,ylabel('Drag')
title('Case 4: Aerodynamic Forces in Wind Frame, N'),set(gcf,'Name','Case 4 WindFrame vs Alpha')
subplot(312),plot(UnitTests.Aero.Case4.FlightPath.Alpha.Data*180/pi,UnitTests.Aero.Case4.WindFrame.Data(:,2)),grid,ylabel('Side')
subplot(313),plot(UnitTests.Aero.Case4.FlightPath.Alpha.Data*180/pi,UnitTests.Aero.Case4.WindFrame.Data(:,3)),grid,ylabel('Lift')
xlabel('angle of attack, deg')

% figure
% subplot(311),plot(UnitTests.Aero.Case4.FlightPath.Alpha.Data*180/pi,UnitTests.Aero.Case4.AeroMoments.Data(:,1)),grid,ylabel('Mx')
% title('Case 4: Aerodynamic Moments about CG in Body Frame, Nm'),set(gcf,'Name','Case 4 AeroMoments vs Alpha')
% subplot(312),plot(UnitTests.Aero.Case4.FlightPath.Alpha.Data*180/pi,UnitTests.Aero.Case4.AeroMoments.Data(:,2)),grid,ylabel('My')
% subplot(313),plot(UnitTests.Aero.Case4.FlightPath.Alpha.Data*180/pi,UnitTests.Aero.Case4.AeroMoments.Data(:,3)),grid,ylabel('Mz')
% xlabel('angle of attack, deg')

figure
subplot(311),plot(UnitTests.Aero.Case5.FlightPath.Beta.Data*180/pi,UnitTests.Aero.Case5.AeroForces.Data(:,1)),grid,ylabel('Fx')
title('Case 5: Aerodynamic Forces in Body Frame, N'),set(gcf,'Name','Case 5 AeroForces vs Beta')
subplot(312),plot(UnitTests.Aero.Case5.FlightPath.Beta.Data*180/pi,UnitTests.Aero.Case5.AeroForces.Data(:,2)),grid,ylabel('Fy')
subplot(313),plot(UnitTests.Aero.Case5.FlightPath.Beta.Data*180/pi,UnitTests.Aero.Case5.AeroForces.Data(:,3)),grid,ylabel('Fz')
xlabel('sideslip angle, deg')

figure
subplot(311),plot(UnitTests.Aero.Case5.FlightPath.Beta.Data*180/pi,UnitTests.Aero.Case5.WindFrame.Data(:,1)),grid,ylabel('Drag')
title('Case 5: Aerodynamic Forces in Wind Frame, N'),set(gcf,'Name','Case 5 WindFrame vs Beta')
subplot(312),plot(UnitTests.Aero.Case5.FlightPath.Beta.Data*180/pi,UnitTests.Aero.Case5.WindFrame.Data(:,2)),grid,ylabel('Side')
subplot(313),plot(UnitTests.Aero.Case5.FlightPath.Beta.Data*180/pi,UnitTests.Aero.Case5.WindFrame.Data(:,3)),grid,ylabel('Lift')
xlabel('sideslip angle, deg')

% figure
% subplot(311),plot(UnitTests.Aero.Case5.FlightPath.Beta.Data*180/pi,UnitTests.Aero.Case5.AeroMoments.Data(:,1)),grid,ylabel('Mx')
% title('Case 5: Aerodynamic Moments about CG in Body Frame, Nm'),set(gcf,'Name','Case 5 AeroMoments vs Beta')
% subplot(312),plot(UnitTests.Aero.Case5.FlightPath.Beta.Data*180/pi,UnitTests.Aero.Case5.AeroMoments.Data(:,2)),grid,ylabel('My')
% subplot(313),plot(UnitTests.Aero.Case5.FlightPath.Beta.Data*180/pi,UnitTests.Aero.Case5.AeroMoments.Data(:,3)),grid,ylabel('Mz')
% xlabel('sideslip angle, deg')
