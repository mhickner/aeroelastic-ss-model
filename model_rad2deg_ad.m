function [sys_deg] = model_rad2deg1d(sys_rad)
% converts empirical theodorsen models that were generated in radians to
% degrees

% input: sys_rad, state space model with theodorsen coefficients

% don't touch A & B matrix

% convert C matrix
C_deg = (sys_rad.C).*pi/180;

% convert D matrix
D_deg = (sys_rad.D).*pi/180;

sys_deg = ss(sys_rad.A,sys_rad.B,C_deg,D_deg, 0.01);

end