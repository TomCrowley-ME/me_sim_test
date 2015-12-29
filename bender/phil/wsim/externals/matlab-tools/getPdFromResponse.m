function [Kp,Kd]=getPdFromResponse( Wn, damping, varargin )
% for 1/s2+2wn Zeta * wn2 = 1/s2 + Kds + kp


Ka=optFill( varargin, 'Ka',1 );

Kp=Wn.^2 ./ Ka;
Kd=2.*damping.*Wn ./Ka;
