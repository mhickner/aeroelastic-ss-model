function [sys_deg, tf_deg] = model_rad2deg(sys_rad)
% converts empirical theodorsen models that were generated in radians to
% degrees

% input: sys_rad, state space model with theodorsen coefficients

% don't touch A matrix

% convert top of B
B_deg = [sys_rad.B(1:end-2).*pi/180; sys_rad.B(end-1:end)];

% convert right two entries of C
C_deg = [sys_rad.C(:,1:end-2) sys_rad.C(:,end-1:end).*pi/180];

% convert D matrix
D_deg = (sys_rad.D).*pi/180;

sys_deg = ss(sys_rad.A,B_deg,C_deg,D_deg);
tf_deg = tf(sys_deg);

end