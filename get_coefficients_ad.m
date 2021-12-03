function [C_alpha, C_alpha_dot, C_alpha_ddot, H_i, Y_all] = get_coefficients_ad(CL,kappa,t_it,dt,u,udot,uddot,M, t_c) %, C_alpha)
% get_coefficients1: Finds Theodorsen coefficients and Markov parameters
% from time-series of lift and airfoil deformation
% from impulse in AoA velocity (variable: u_dot)
%
% Inputs:
% CL: time series of coefficient of lift 
%
% Outputs:
% C_alpha, C_alpha_dot, C_alpha_ddot: Theodorsen coefficients
% H_i:  Markov paramters (input to ERA)
% Y_all: are data matrix, including intermediate steps
% t_c: duration of perturbation
% M: perturbation amplitude in radians


%% Perturbation parameters
nstep   = floor((t_c)/dt);  % number of steps of perturbation
nt      = length(t_it);     % length of time vector

%% Set up data
if length(kappa)>1 
    Y = [CL' kappa']; % observables
else
    Y = CL';
end
u = u';
u_dot = udot';
u_ddot = uddot';

%% Construct Empirical model

Y1 = Y - Y(1,:); % subtract initial lift and deformation

C_alpha = Y1(end,:)./M; % calculate C_alpha
Y2 = Y1 - u*C_alpha; % subtract out steady-state contribution

% find portion of signal where added mass forces dominate (during step maneuver)
[pks1,loc1,w1,~] = findpeaks(u_ddot);
[pks2,loc2,w2,~] = findpeaks(-u_ddot);
[~,i1] = max(pks1);
[~,i2] = max(pks2);
ind1 = loc1(i1)-round(w1(i1));
ind2 = loc2(i1)+round(w2(i2));

U = u_ddot(ind1:ind2);
C_alpha_ddot = pinv(U)*Y2(ind1:ind2,:); % calculate C_alpha_ddot 
Y3 = Y2 - u_ddot*C_alpha_ddot; % subtract out pitch acceleration contribution

% find max impulse
if abs(max(u_dot)) > abs(min(u_dot))
    ind         = find(u_dot == max(u_dot));% step of maximum impulse
else
    ind         = find(u_dot == min(u_dot));% step of maximum impulse
end

% Markov parameters
H_i = Y3(ind:nstep:nt,:); % use coarse time scale

% Sixth step  (Calculate C_alpha_dot)
C_alpha_dot = H_i(1,:)*t_c/M;
Y4 = Y3 - u_dot*C_alpha_dot;

% Save Y at each step
Y_all = horzcat(Y, Y1, Y2, Y3, Y4);
end

