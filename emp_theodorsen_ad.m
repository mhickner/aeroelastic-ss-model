function [syscont,sysdisc] = emp_theodorsen_ad(r,C_alpha, C_alpha_dot, C_alpha_ddot, H_i, t_c, M)
% for impulse in AoA velocity (u_dot, or ddt(alpha))

%% ERA
YYY = H_i(2:end,:)*t_c/M;
YY = reshape(YYY',[size(YYY,2),1,size(YYY,1)]);
mco   = floor((length(YY)-1)/2);
[Ar,Br,Cr] = ERA(YY,mco,mco,1,size(YY,1),r);
Ad = [Ar  zeros(r,1) Br; zeros(1,r) 1 t_c; zeros(1,r) 0 1];
Bd = [zeros(r,1);0;t_c];
Cd = horzcat(Cr, C_alpha', C_alpha_dot');
Dd = C_alpha_ddot';
sysdisc_rad = ss(Ad,Bd,Cd,Dd,t_c);
[sysdisc] = model_rad2deg_ad(sysdisc_rad);

%% convert to continous time model
syscont      = d2c(sysdisc,'zoh');

