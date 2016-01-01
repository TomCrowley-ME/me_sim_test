%Gimbal Command Unit Test

c1 = 0.1
c2 = 0.2
lx1c = 0.3 % lx1c must always be greater than c1
lz1c = 0.4
Rmount = sqrt(c1^2 + c2^2)
alpha_deg = 2
alpha = alpha_deg*3.14159/180

Lcmd = sqrt((lx1c - Rmount*sqrt(1 - 1/(1+(tan(alpha) + c1/c2)^2)))^2 + (lz1c + Rmount/sqrt(1+(tan(alpha)+c1/c2)^2))^2)

Lo = sqrt((lx1c - c1)^2 + (lz1c + c2)^2)

Lerr = - ( Lcmd - Lo)

lxo = sqrt(Rmount^2 - Rmount^2/(1+(tan(alpha)+c1/c2)^2))

lzo = sqrt(Rmount^2 -lxo^2)

Lang = atand((lx1c - lxo)/(lz1c+lzo))

Ltest = sqrt((lx1c-lxo)^2+(lz1c+lzo)^2)

gim_y_act_c1 = 0.1;
gim_y_act_c2 = 0.2;
gim_y_act_lx1c = 0.3; % lx1c must always be greater than c1
gim_y_act_lz1c = 0.4;

gim_x_act_c1 = 0.1;
gim_x_act_c2 = 0.2;
gim_x_act_lx1c = 0.3; % lx1c must always be greater than c1
gim_x_act_lz1c = 0.4;

Kp = 0.1;
Ki = 0;
Kd = 1;
N = 15;

Km = 0.01;
Jm = 0.01;
Bm = 0.1;
Ke = 0.01;
Kt = 0.01;
Lm = 0.5;
Rm = 1;
nb = 2e-2/(2*pi);
Kl = 500;

rot_err_x_rad = -1*pi/180
rot_err_y_rad = 0.0
rot_err_z_rad = 1*pi/180

w_err_x_rad = 0.0
w_err_y_rad = 0.0
w_err_z_rad = 0.0

mass = 50

