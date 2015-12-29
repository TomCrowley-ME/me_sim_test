function [ tmatrix ] = dcm_j2000_to_mcmf(epoch)
% Compute Direction Cosine Matrix for International Astronomical Union (IAU)
% transformation from EME2000 (J2000) to model rotation of the Moon.
% From "A Moon-Centered, Inertial Coordinate System for SPICE".

% load variables
util_frame_rotation_init;

% covert date string to Julian date
jdate=juliandate(epoch);

phat_moon         = zeros(3,1);
zhat              = zeros(3,1);
omega_moon_pa_mat = zeros(3);
tmatrix_tod       = zeros(3);

% Time Arguments
d = jdate - 2451545.0;  % days since J2000
t = d / 36525;          % centuries since J2000

% IAU J2000 Pole Orientation
e1 = 125.045 -  0.0529921 * d; 
e2 = 250.089 -  0.1059842 * d; 
e3 = 260.008 + 13.0120009 * d; 
e4 = 176.625 + 13.3407154 * d; 
e5 = 357.529 +  0.9856003 * d; 
e6 = 311.589 + 26.4057084 * d; 
e7 = 134.963 + 13.0649930 * d; 
e8 = 276.617 +  0.3287146 * d; 
e9 =  34.226 +  1.7484877 * d;
e10 = 15.134 -  0.1589763 * d;
e11 =119.743 +  0.0036096 * d;
e12 =239.961 +  0.1643573 * d;
e13 = 25.053 + 12.9590088 * d; 
rasc_pole = 269.9949 + 0.0031 * t... 
            - 3.8787 * sind(e1)... 
            - 0.1204 * sind(e2)... 
            + 0.0700 * sind(e3)... 
            - 0.0172 * sind(e4)... 
            + 0.0072 * sind(e6)... 
            - 0.0052 * sind(e10)... 
            + 0.0043 * sind(e13); 
decl_pole = 66.5392 + 0.0130 * t... 
           + 1.5419 * cosd(e1)... 
           + 0.0239 * cosd(e2)... 
           - 0.0278 * cosd(e3)... 
           + 0.0068 * cosd(e4)... 
           - 0.0029 * cosd(e6)... 
           + 0.0009 * cosd(e7)... 
           + 0.0008 * cosd(e10)... 
           - 0.0009 * cosd(e13); 
       
omega_dot_moon  = 13.17635815;     % moon rotation rate deg/day (1st order rate)
omega_p = 38.3213 + omega_dot_moon * d - 1.4e-12 * d^2;

omega_dot_moon  = 13.17635815;     % moon rotation rate deg/day (1st order rate)
omega_2dot_moon = -0.001867705875; % moon rotation rate change deg/day^2 (2nd order rate)
omega_p = 38.3213 + omega_dot_moon * d - 1.4e-12 * d^2;
omega_p = 38.3213 + omega_dot_moon * d + omega_2dot_moon * t;

omega_moon_iau = omega_p + 3.5610 * sind(e1)...
                         + 0.1208 * sind(e2)...
                         - 0.0642 * sind(e3)...
                         + 0.0158 * sind(e4)...
                         + 0.0252 * sind(e5)...
                         - 0.0066 * sind(e6)...
                         - 0.0047 * sind(e7)...
                         - 0.0046 * sind(e8)...
                         + 0.0028 * sind(e9)...
                         + 0.0052 * sind(e10)...
                         + 0.0040 * sind(e11)...
                         + 0.0019 * sind(e12)...
                         - 0.0044 * sind(e13);
                     
rasc_moon_pa  = rasc_pole + 0.0553 * cosd(omega_p) + 0.0034 * cosd(omega_p + e1);
decl_moon_pa  = decl_pole + 0.0220 * sind(omega_p) + 0.0007 * sind(omega_p + e1);
omega_moon_pa = omega_moon_iau + 0.01775 - 0.0507 * cosd(omega_p) - 0.0034 * cosd(omega_p + e1);

omega_moon_pa_mat(1, 1) =  cosd(omega_moon_pa);
omega_moon_pa_mat(1, 2) =  sind(omega_moon_pa);
omega_moon_pa_mat(1, 3) =  0;
omega_moon_pa_mat(2, 1) = -sind(omega_moon_pa);
omega_moon_pa_mat(2, 2) =  cosd(omega_moon_pa);
omega_moon_pa_mat(2, 3) =  0;
omega_moon_pa_mat(3, 1) =  0;
omega_moon_pa_mat(3, 2) =  0;
omega_moon_pa_mat(3, 3) =  1;

% Compute the unit vector in the direction of the moon's pole
phat_moon(1) = cosd(rasc_moon_pa) * cosd(decl_moon_pa); 
phat_moon(2) = sind(rasc_moon_pa) * cosd(decl_moon_pa); 
phat_moon(3) = sind(decl_moon_pa); 
phat_moon = phat_moon';

% Define EME2000 Z-Axis unit vector
zhat(1) = 0;
zhat(2) = 0;
zhat(3) = 1;

% Compute X-Axis unit vector
xvec = cross(zhat,phat_moon);
xhat = xvec/sqrt(xvec(1)^2 + xvec(2)^2 + xvec(3)^2);

% Compute Y-Axis direction
yvec = cross(phat_moon,xhat);
yhat = yvec/sqrt(yvec(1)^2 + yvec(2)^2 + yvec(3)^2);

% Load elements of transformation matrix
tmatrix_tod(1, 1) = xhat(1); 
tmatrix_tod(1, 2) = xhat(2); 
tmatrix_tod(1, 3) = xhat(3); 
tmatrix_tod(2, 1) = yhat(1); 
tmatrix_tod(2, 2) = yhat(2);
tmatrix_tod(2, 3) = yhat(3); 
tmatrix_tod(3, 1) = phat_moon(1); 
tmatrix_tod(3, 2) = phat_moon(2); 
tmatrix_tod(3, 3) = phat_moon(3);

tmatrix = (tmatrix_tod'*omega_moon_pa_mat')';

end
