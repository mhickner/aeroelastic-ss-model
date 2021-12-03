function [CLFSI,CL_IBPMtest, x,y,kappa, time_test,dt,u_test,udot_test,uddot_test]=loadData_phpTest(alpha0,KB,path)
% run test case comparing rigid, flexible and empirical theodorsen model

%% load motion file testing
filename = [path,'/ibpm_php_motion.dat'];
fileID = fopen(filename);
fileData = textscan(fileID, '%f %f %f %f %f %f %f', 'HeaderLines', 1, 'CollectOutput', 1);
IBPM_test_motion = cell2mat(fileData);
time_test = IBPM_test_motion(:,1);
dt_test = IBPM_test_motion(2,1) - IBPM_test_motion(1,1);
u_test = IBPM_test_motion(:,4);
udot_test = IBPM_test_motion(:,7);
uddot_test = [0; (udot_test(3:end)-udot_test(1:end-2))/(2*dt_test); 0];


%% load CL data testing rigid C++ code Rowley
filename = sprintf([path,'/ibpm_php_fm_a%ddeg_p-10deg_pa0_force.dat'],alpha0);
fileID = fopen(filename);
fileData = textscan(fileID, '%f %f %f %f', 'CollectOutput', 1);
IBPM_test_data = cell2mat(fileData);
time_IBPMtest = IBPM_test_data(:,2);
CX_IBPMtest = IBPM_test_data(:,3);
CY_IBPMtest = IBPM_test_data(:,4);
% alpha = alpha0 + 180/pi*interp1(time_test,u_test,time_IBPMtest);
alpha = alpha0; % alpha from maneuver is already considered in output -> OutputForce.cc, but not alpha0
CL_IBPMtest = -sind(alpha).*CX_IBPMtest + cosd(alpha).*CY_IBPMtest;

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
alpha = alpha0 + 180/pi*interp1(time_test,u_test,timeFSInew);
CLFSI = -sind(alpha).*ForceFSI(:,2) + cosd(alpha).*ForceFSI(:,3);

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

kappa = sin(dangle)/(2*(1/(n/2))); %curvature at leading edge
%% run empirical theodorsen model
% [CL_ERAd,~] = lsim(sys_emp_11_med_rigid,uddot_test,time_test,[zeros(r,1);0;0]);
% 
% % get initial CL: ideally one would specify the actual alpha0 as initial condition in empirical theodorsen model, ...
% % but the lift slope is not constant and therefore we would get large CL0 offset by taking CL0=C_alpha*alpha
% CL0 = CLFSI(1); 
% CL_ERA = CL0 + CL_ERAd;


% %% plot
% 
% figure
% plot(time_IBPMtest,CL_IBPMtest,'k-.');hold on
% plot(timeFSInew,CLFSI,'b');hold on
% plot(time_test,CL_ERA,'r--');hold on 
% ylim([-0.25 1.75])
% xlabel('time')
% ylabel('CL')
% legend({'rigid (C++ Rowley)','flexible (Goza)',sprintf('ERA r=%d',r)})
% title(sprintf('Pitch-up, hold, pitch-down, alpha=%ddeg, KB=%0.3g',alpha0,KB))
% grid on

end