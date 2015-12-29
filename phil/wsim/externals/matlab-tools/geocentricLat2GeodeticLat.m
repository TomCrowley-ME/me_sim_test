function geodetic_a_r = geocentricLat2GeodeticLat( geocentric_a_r )

earth=earthModel;
geodetic_a_r=atan( (1-earth.f)^2*tan(geocentric_a_r) );
