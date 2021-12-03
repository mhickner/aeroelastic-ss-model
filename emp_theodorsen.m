function [sys] = emp_theodorsen(r,C_alpha, C_alpha_dot, C_alpha_ddot, H_i, t_c, M)
% for impulse in AoA acceleration (u_ddot or ddt(alpha))

%% ERA
YYY = H_i(2:end,:)*t_c/M;
YY = reshape(YYY',[size(YYY,2),1,size(YYY,1)]);
mco   = floor((length(YY)-1)/2);
[Ar_d,Br_d,Cr_d] = ERA(YY,mco,mco,1,size(YY,1),r);
sysdisc            = ss(Ar_d,Br_d,Cr_d,C_alpha_ddot',t_c);   % discrete-time system

%% Calculate continous time model
syscont      = d2c(sysdisc,'zoh');
[Ar_c,Br_c,Cr_c,~]=ssdata(syscont); % continuous system
A            = [Ar_c  zeros(r,1) zeros(r,1); zeros(1,r) 0 1 ;zeros(1,r) 0 0];
B            = [Br_c;0;1];
C = horzcat(Cr_c, C_alpha', C_alpha_dot');
D = C_alpha_ddot';
sys_emp      = ss(A,B,C,D);
[sys, ~] = model_rad2deg(sys_emp);
