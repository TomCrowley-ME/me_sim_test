g = -1.624 % lunar gravity
a = 0.3*(2.5 + g) - 0.32*0.4% must be calculated from nominal thrust minus ACS off pulse divided by current estimated mass
ho = 1200.0% measured at the end of Targeting Burn
tf = (-a/g + sqrt(a^2/g^2 + 2*(a-a^2/g)*(1/(2*g) + ho)))/(a-a^2/g)
tc = -(a*tf+1)/g

Hdot = -1 - a * (-a/g + sqrt(a^2/g^2 + 2*(a-a^2/g)*(1/(2*g) + ho)))/(a-a^2/g)

% Altitude to follow -10*Hdot descent profile
ht = ho + Hdot*10

% Altitude to thrust full on (with ACS off pulsing factored in
ht = 0.5*g*tc^2 + ho

