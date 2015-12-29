function positionToCrDrAngles( cX2R, reference_rXm, rXm )
rRm=cX2R*rXm;

downrange=atan2(rRm(3,:),rRm(1,:));
