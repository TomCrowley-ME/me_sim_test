%% Create initial data

% ode run params
tmax=2*3600;
%reltol=1e-5;
reltol=1e-6;
%tmax=48*3600;

rgm0=[38 -118 100e3]; v=8500; az=-90 *pi/180; el=0;

rem0=lla2ecef( rgm0 );
vemps0=(dcmecef2ned( rgm0(1), rgm0(2) )'*angle2dcm( az,el,0 ) * [v 0 0]')';

%% Integrate
[t,y]=ode45(@sphe_deriv, [0 tmax], [rem0 vemps0]',odeset('RelTol',reltol));

%% Now print
y_rgm=ecef2lla(y(:,1:3));
ezglobe;plot3m(y_rgm(:,1),y_rgm(:,2),y_rgm(:,3)/6378e3,'r-')

