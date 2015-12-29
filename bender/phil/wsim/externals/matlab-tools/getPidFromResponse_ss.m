function [k,kd,ki]=getPidFromResponse( w0, zeta, alpha,  num,den )
% Where the plant transfer function is described by:
%
%              s b1 + b2
% G(s)  =   ---------------
%           s^2 + s a1 + a2
% and  
%  num = [b1 b2], den = [1 a1 a2]

% grr, what's the book? ian, dammit put darn references next

b1=num(1);
b2=num(2);
a1=den(2);
a2=den(3);
if den(1)~=1
    error('den(1) must be 1');
end
gden = b2^3 - b1*b2^2*(alpha+2*zeta)*w0 + b1^2*b2*(1+2*alpha*zeta)*w0^2 - alpha*b1^3 * w0^3 ;

% book has an errata in k, it should be negative and the last term should also be negative (as it is now)
k=1/gden*-( a2*b2^2 - a2*b1*b2*(alpha + 2*zeta)*w0-(b2-a1*b1)*(b2*(1+2*alpha*zeta)*w0^2-alpha*b1*w0^3) );
ki=1/gden*( (-a1*b1*b2+a2*b1^2+b2^2)*alpha*w0^3 );
kd=1/gden*( -a1*b2^2+a2*b1*b2+b2^2*(alpha+2*zeta)*w0-b1*b2*w0^2*(1+2*alpha*zeta)+b1^2*alpha*w0^3);

% using wolfram with:
% solve a1 + b2*x + b1*z = (alpha*w0 + 2*w0*zeta)*(1+b1*x),
% a2 + b2*z + b1*y = (1+2*alpha*zeta)*w0^2*(1+b1*x),
% b2*y=alpha*w0^3*(1+b1*x) 
% for x,y,z

% kd = (-a1*b2^2+a2*b1*b2+alpha*b1^2*w0^3-2*alpha*b1*b2*zeta*w0^2-b1*b2*w0^2+alpha*b2^2*w0+2*b2^2*zeta*w0)...
%     / -((alpha*b1*w0-b2)*(b1^2*w0^2-2*b1*b2*zeta*w0+b2^2));
% ki = ((a2*b1^2-a1*b2*b1+b2^2)*w0^3*alpha)...
%     /((b2-b1*w0*alpha)*(b2^2-2*b1*w0*zeta*b2+b1^2*w0^2));
% k = (alpha*a1*b1^2*w0^3 - 2*alpha*a1*b1*b2*zeta*w0^2 - a1*b1*b2*w0^2+alpha*a2*b1*b2*w0+2*a2*b1*b2*zeta*w0-a2*b2^2-alpha*b1*b2*w0^3+2*alpha*b2^2*zeta*w0^2+b2^2*w0^2) ...
%     /-((alpha*b1*w0-b2)*(b1^2*w0^2-2*b1*b2*zeta*w0+b2^2));


% solve a1+b2*d+b1*k=(alpha*w0+2*zeta*w0)*(1+b1*d),a2+b2*k+b1*y=(1+2*alpha*zeta)*w0^2*(1+b1*d),b2*y=alpha*w0^3*(1+b1*d) for d,y,k
