function [CLFSI,CL_ERA, CL_IBPM, time_testing, u_testing,udot_testing,uddot_testing] = emp_theodorsen_testing(r,alpha0,KB,sys,path)
% run test case comparing rigid, flexible and empirical theodorsen model

%% load motion file testing
filename = [path,'/ibpm_php_motion.dat'];
fileID = fopen(filename);
fileData = textscan(fileID, '%f %f %f %f %f %f %f', 'HeaderLines', 1, 'CollectOutput', 1);
IBPM_testing_motion = cell2mat(fileData);
time_testing = IBPM_testing_motion(:,1);
dt_testing = IBPM_testing_motion(2,1) - IBPM_testing_motion(1,1);
u_testing = IBPM_testing_motion(:,4);
udot_testing = IBPM_testing_motion(:,7);
uddot_testing = [0; (udot_testing(3:end)-udot_testing(1:end-2))/(2*dt_testing); 0];


%% load CL data testing rigid rigid C++ code Rowley
filename = sprintf([path,'/ibpm_php_fm_a%ddeg_p-10deg_pa0_force.dat'],alpha0);
fileID = fopen(filename);
fileData = textscan(fileID, '%f %f %f %f', 'CollectOutput', 1);
IBPM_testing_data = cell2mat(fileData);
time_IBPMtest = IBPM_testing_data(:,2);
CX_IBPMtest = IBPM_testing_data(:,3);
CY_IBPMtest = IBPM_testing_data(:,4);
% alpha = alpha0 + 180/pi*interp1(time_testing,u_testing,time_IBPMtest);
alpha = alpha0; % alpha from maneuver is already considered in output -> OutputForce.cc, but not alpha0
CL_IBPM = -sind(alpha).*CX_IBPMtest + cosd(alpha).*CY_IBPMtest;

%% load CL data FSI Goza 
if KB >=3
    filename = sprintf([path,'/FSI_php_%ddeg_KB%d_force.dat'],alpha0,KB);
else
    filename = sprintf([path,'/FSI_php_%ddeg_KB3e-1_force.dat'],alpha0);
end
fileID = fopen(filename);
fileData = textscan(fileID, '%f %f %f %f %f', 'CollectOutput', 1);
ForceFSI = cell2mat(fileData);
dt = 0.001;
ts = ForceFSI(1,1); % number of time steps before restart
timeFSInew = (ForceFSI(:,1)-ts)*dt;
alpha = alpha0 + 180/pi*interp1(time_testing,u_testing,timeFSInew);
CLFSI = -sind(alpha).*ForceFSI(:,2) + cosd(alpha).*ForceFSI(:,3);

%% run empirical theodorsen model
[CL_ERAd,~] = lsim(sys,uddot_testing*180/pi,time_testing);

% get initial CL: ideally one would specify the actual alpha0 as initial condition in empirical theodorsen model, ...
% but the lift slope is not constant and therefore we would get large CL0 offset by taking CL0=C_alpha*alpha
CL0 = CLFSI(1); 
CL_ERA = CL0 + CL_ERAd;


end