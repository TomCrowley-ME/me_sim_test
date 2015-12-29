function Results=mci2lla(pmci,epoch);
% pmci         vehicle position in J2000 MCI frame
% epoch        time instance corresponding to vehicle position,
%              in either 3 or 6 element date string format

cb = CentralBodyMoon_init;

% constants
r2d   = 180/pi;         % radians to degrees conversion
if strcmp(cb.units,'METRIC')
  scale = 1000;         % kilometer to meter conversion
  units = strvcat('m','km');
else
  scale = 6076.115486;  % nautical mile to feet conversion
  units = strvcat('ft','nmi');
end

if size(pmci,2)==1,pmci=pmci';end
N=size(pmci,1);
Results.DeticLatitude   =zeros(N,1);
Results.CentricLatitude =zeros(N,1);
Results.Longitude       =zeros(N,1);
Results.Altitude        =zeros(N,1);

for i=1:N

  pmcf = dcm_j2000_to_mcmf(epoch(i,:))*[pmci(i,1) pmci(i,2) pmci(i,3)]';
  X = pmcf(1);
  Y = pmcf(2);
  Z = pmcf(3);

  r = sqrt( X*X + Y*Y );

  % compute detic latitude and altitude
  if (abs(r) <= 1e-6)
    dlat = sign(Z) * 90.0;
    alt  = abs(Z) - cb.b;

  else
    if (Z < 0)
        cb.b = -cb.b;
    end

    E = ((cb.b*Z) - (cb.a^2 - cb.b^2))/(cb.a*r);
    F = ((cb.b*Z) + (cb.a^2 - cb.b^2))/(cb.a*r);

    P = (4/3)*(E*F + 1);
    Q = 2*(E*E - F*F);

    D = P*P*P + Q*Q;
    if (D < 0)
        v = 2*(sqrt(-P))*cos( (1/2)*acos(Q/((-P)^(3/2))) );
    else
        v = (sqrt(D) - Q)^(1/3) - (sqrt(D) + Q)^(1/3);
    end

    G = (sqrt(E*E + v) + E)/2;
    t = sqrt( G*G + (F-v*G)/(2*G-E)) - G;
    if ~isreal(t)
      G = (-sqrt(E*E + v) + E)/2;
      t = sqrt( G*G + (F-v*G)/(2*G-E)) - G;
    end

    dlat = atan( cb.a*(1-t*t)/(2*cb.b*t) ) * r2d;
    alt  = (r-cb.a*t)*cosd(dlat) + (Z-cb.b)*sind(dlat);

  end

  % compute longitude
  lon = atan2( Y, X ) * r2d;

  % wrap longitude to be within +/- 180
  lon = mod(lon, 360.0);
  if lon > 180.0
    lon = lon - 360.0;
  end

  % compute centric latitude
  clat = atan((1 - cb.flatten)^2 * tand(dlat)) * r2d;

  %
  Results.DeticLatitude(i)   =dlat;   % deg
  Results.CentricLatitude(i) =clat;   % deg
  Results.Longitude(i)       =lon;    % deg
  Results.Altitude(i)        =alt;    % ft or m

  if (nargout==0)&&(N==1)
    fprintf('detic latitude   = %13.5f deg\n',dlat)
%     fprintf('centric latitude = %13.5f deg\n',clat)
    fprintf('longitude        = %13.5f deg\n',lon)
    fprintf('altitude         = %13.3f %s = %10.3f %s\n',alt,units(1,:),alt/scale,units(2,:))
  end
end