offset(1:500)=0;
misalign(1:500)=0;

for i=1:499
offset(i+1) = 1.6/499 + offset(i);
for j=1:499
misalign(j+1) = 1.9/499 + misalign(j);
end
end
inside_limit = [0 0 0; 0 0 0];

for i=1:500
for j=1:500
combined_roll_torque(i,j) = 1112*(sind(misalign(j)*offset(i)));
end
end

%figure;surf(offset(1:500),misalign(1:500),combined_roll_torque,'linewidth',2);title('Biprop Main Engine Offset and Orthogonal Misalignment Angle');xlabel('Offset (meters)');ylabel('Orthogonal Misalignment Angle (deg)');zlabel('Roll Torque (N-m)');grid on
figure
hold on
for i=1:500
for j=1:500
if combined_roll_torque(i,j) > 0.0000 && combined_roll_torque(i,j) < 0.1346


plot3(offset(i),misalign(j),combined_roll_torque(i,j),'*');
inside_limit = [inside_limit;[offset(i),misalign(j),combined_roll_torque(i,j)]];
end
end
end
title('Biprop Main Engine Offset and Orthogonal Misalignment Angle');xlabel('Offset (meters)');ylabel('Orthogonal Misalignment Angle (deg)');zlabel('Roll Torque (N-m)');grid on
%figure;surf(inside_limit(:,1),inside_limit(:,2),combined_roll_torque(i,j),'linewidth',2);title('Non-Saturation Biprop Main Engine Offset and Orthogonal Misalignment Angle');xlabel('Offset (meters)');ylabel('Orthogonal Misalignment Angle (deg)');zlabel('Roll Torque (N-m)');grid on
