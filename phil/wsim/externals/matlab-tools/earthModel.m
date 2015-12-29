function earth=earthModel
% flattening
earth.flattening  = 1/298.257223563;

% equatorial radius
earth.equatorialRadius_r_m =  6378137;

% rotation rate
earth.wIrps = [ 0 0 7.292115e-5 ]';
