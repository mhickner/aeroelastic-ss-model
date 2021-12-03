function [kFSI,kERA,time_testing,u_testing,udot_testing,uddot_testing] = emp_theodorsen_testingDeformation(r,alpha0,KB,sys,path)
% run test case comparing flexible with empirical theodorsen model

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

%% load data FSI Goza 
if KB >=3
    filename = sprintf([path,'/FSI_php_%ddeg_KB%d_deformation.dat'],alpha0,KB);
else
    filename = sprintf([path,'/FSI_php_%ddeg_KB3e-1_deformation.dat'],alpha0);
end
n = 2*66;
fmt=repmat('%f',1,n);
fileID = fopen(filename,'r');
fileData = textscan(fileID, fmt, 'HeaderLines', 1, 'CollectOutput', 1);
plateCoordinates = cell2mat(fileData);

x = plateCoordinates(:,1:n/2);
y = plateCoordinates(:,(n/2+1):n);

dt = 0.001;
time = dt:dt:dt*size(x,1);

angle = [zeros(size(x,1),1), atan((y(:,2:end)-y(:,1:end-1))./(x(:,2:end)-x(:,1:end-1)))];
dangle = [angle(:,2:end) - angle(:,1:end-1), zeros(size(x,1),1)];
dangle = dangle(:,2);

curvature = sin(dangle)/(2*(1/(n/2)));
kFSI = curvature;

%% run empirical theodorsen model
[out_ERAd,~] = lsim(sys,uddot_testing*180/pi,time_testing);

out0 = kFSI(1); % ideally one would specify alpha0 as initial condition in empirical theodorsen model, but the lift slope is not constant and therefore large CL0 and deformation offset 
kERA = out0 + out_ERAd;

end