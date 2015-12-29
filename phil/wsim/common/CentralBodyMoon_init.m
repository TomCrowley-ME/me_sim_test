function moon = CentralBodyMoon_init;
%% Build Moon Structure:
moon.title      = 'Lunar Moon Model';
moon.units      = 'METRIC';
moon.a          = 1738140.0;            % [m]       Semi-major Axis 
                                        %            (Equatorial Radius)
moon.b          = 1735970.0;            % [m]       Semi-minor Axis 
                                        %            (Polar Radius)
moon.e          = sqrt(1 - (moon.b*moon.b)/(moon.a*moon.a));
                                        % [ND]      First Eccentricity
moon.gm         = 4.902801076e12;       % [m^3/s^2] Gravitational Constant
moon.rate       = (2*pi)/(655.72 * 3600); % [rad/s]   Angular Velocity
moon.flatten    = 1 - moon.b/moon.a;    % [ND]      Flattening Parameter
moon.e2         = moon.e * moon.e;      % [ND]      First Eccentricity Squared
moon.ep         = sqrt( (moon.a^2)/(moon.b^2) - 1 );
                                        % [ND]      Second Eccentricity
                                        %           (e-prime, e')
moon.ep2        = moon.ep^2;            % [ND]      Second Eccentricity
                                        %           (e-prime) Squared
moon.El         = moon.e * moon.a;      % [m]       Linear Eccentricity
moon.E2l        = moon.El^2;            % [m^2]     Linear Eccentricity
                                        %            Squared
moon.eta        = (moon.a^2 - moon.b^2)/moon.a^2;  % [ND]
moon.j2         = 202.7e-6;             % [ND]      J2 Perturbation
                                        %            Coefficient
moon.gamma_e    = 1.62;                 % [m/s^2]   Theoretical (Normal)
                                        %            Gravity at the Equator
                                        %             (on the Ellipsoid)
moon.gamma_p    = 1.62;                 % [m/s^2]   Theoretical (Normal)
                                        %            Gravity at Pole
                                        %            (on the Ellipsoid)                                       
moon.g0         =  moon.gm / (moon.a^2 * (1 + 1.5*moon.j2));  
                                        % [m/s^2]   OLD Gravity Computation
                                        %            (Unknown Origin)
moon.m          = (moon.rate^2) * (moon.a^2) * moon.b / moon.gm;
                                        % [ND]      Gravity Ratio  
moon.k          = (moon.b*moon.gamma_p)/(moon.a*moon.gamma_e) - 1;
                                        % [ND]      Theoretical (Normal)
                                        %            Gravity Formula
                                        %            Constant (Somigliana's
                                        %            Constant)
