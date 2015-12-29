function [Kp,Kd,Ki]=getPidFromResponse1( Wn, damping, inverse_Tint, varargin )
% for 1/( s2+2wn Zeta + wn^2) = ? 1/s2 + Kds + kp


Ka=optFill( varargin, 'Ka',1 );

Ki=Wn.^2 * inverse_Tint ./ Ka;
Kp=( Wn.^2 + 2.*damping.*Wn * inverse_Tint )./ Ka;
Kd=( 2.*damping.*Wn + inverse_Tint )./Ka;
