function [C_alpha, C_alpha_dot, C_alpha_ddot, H_i, Y_all] = get_coefficients(CL,kappa,t_it,dt,u,udot,uddot,M, t_c) %, C_alpha)
% get_coefficients: Finds Theodorsen coefficients and Markov parameters
% from time-series of lift and airfoil deformation
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

% First step (subtract initial lift and deformation)
Y1 = Y - Y(1,:);

% Second step (calculate C_alpha)
C_alpha = Y1(end,:)./M;
Y2      = Y1 - u*C_alpha; % subtract out steady-state contribution

% Third step (calculate C_alpha_dot)
if abs(max(u_dot)) > abs(min(u_dot))
    ind         = find(u_dot == max(u_dot));% step of maximum impulse
else
    ind         = find(u_dot == min(u_dot));% step of maximum impulse
end
C_alpha_dot = Y2(ind,:)./u_dot(ind);
Y3          = Y2 - (u_dot)*C_alpha_dot; % subtract alpha_dot contribution

% Fourth step  (integrate)
Y4 = cumsum(Y3)*dt; % get impulse response in u_ddot instead of u_dot

% Fifth step  (Markov parameters)
H_i = Y4(ind:nstep:nt,:); % use coarse time scale

% Sixth step  (Calculate C_alpha_ddot)
C_alpha_ddot = H_i(1,:)*t_c/M;
Y6 = Y3 - u_ddot*C_alpha_ddot;

% Save Y at each step
Y_all = horzcat(Y, Y1, Y2, Y3, Y4, Y6);
end

