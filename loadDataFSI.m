function [CL,kappa,time,dt1,u,udot,uddot,M] = loadDataFSI(alpha0,KB,path)

%% inputs u, udot, uddot
b       = 1000;       % slope of impulse
t_1     = 0.01;       % start time perturbation
t_2     = 0.02;      % end time perturbation
dt1 = 0.0001;        % time step simulation 1: smooth step function 
dt2 = 0.005;        % time step simulation 2: run until convergence
time = dt1:dt1:100;
nt      = length(time);           % length of time vector
M       = 0.1*pi/180;  % perturbation amplitude (0.1deg)
n = 2*66; % 2*number of plate elements

G = zeros(nt,1);
ncosh = 2*t_2/dt1; % careful: values get to large for large t_it
G(1:ncosh) = log((cosh(b*(time(1:ncosh) - t_1))*cosh(b*t_2))./(cosh(b*(time(1:ncosh) - t_2))*cosh(b*t_1)));
G((ncosh+1):end) = G(ncosh);
u       = M*G/max(G);
udot   = M*b*(tanh(b*(time - t_1)) - tanh(b*(time - t_2)))/max(G);
uddot  = M*b*(b*(1-(tanh(b*(time - t_1))).^2) - ...
    (b*(1-(tanh(b*(time - t_2))).^2)))/max(G);

u = u';
alpha = alpha0 + u*180/pi;

%% load force (CL) files
if KB >= 3
    filename = sprintf([path,'/FSI_ssf_%ddeg_KB%d_force.dat'],alpha0,KB);
else
    filename = sprintf([path,'/FSI_ssf_%ddeg_KB3e-1_force.dat'],alpha0);
end
fileID = fopen(filename);
fileData = textscan(fileID, '%f %f %f %f %f', 'CollectOutput', 1);
ForceFSI = cell2mat(fileData);
dt1 = 0.0001;
ts1 = ForceFSI(1,1); % number of time steps before restart
timeFSI1 = (ForceFSI(:,1)-ts1)*dt1;
CXFSI1a = ForceFSI(:,2); 
CYFSI1a = ForceFSI(:,3);


% load second force file: restart from first force file with large dt to run simulation until convergence
if KB >= 3
    filename = sprintf([path,'/FSI_conv_%ddeg_KB%d_force.dat'],alpha0,KB);
else
    filename = sprintf([path,'/FSI_conv_%ddeg_KB3e-1_force.dat'],alpha0);
end
fileID = fopen(filename);
fileData = textscan(fileID, '%f %f %f %f %f', 'CollectOutput', 1);
ForceFSI2 = cell2mat(fileData);
ts2 = ForceFSI2(1,1); % number of time steps before restart
timeFSI2 = (ForceFSI2(:,1)-ts2)*dt2 + timeFSI1(ts2-ts1);
CXFSI2a = ForceFSI2(:,2);
CYFSI2a = ForceFSI2(:,3);

% merge force files and refine and interpolate to get constant time step
timeTraining = [timeFSI1;timeFSI2(2:end)];
CXa = [CXFSI1a;CXFSI2a(2:end)];
CYa = [CYFSI1a;CYFSI2a(2:end)];
CXina = interp1(timeTraining,CXa,time);
CYina = interp1(timeTraining,CYa,time);
CL = -sind(alpha).*CXina + cosd(alpha).*CYina;

%% load deformation files

% load data smoothed step function
if KB >=3
    filename = sprintf([path,'/FSI_ssf_%ddeg_KB%d_deformation.dat'],alpha0,KB);
else
    filename = sprintf([path,'/FSI_ssf_%ddeg_KB3e-1_deformation.dat'],alpha0);
end
fmt=repmat('%f',1,n);
fileID = fopen(filename,'r');
fileData = textscan(fileID, fmt, 'HeaderLines', 1, 'CollectOutput', 1);
plateCoordinates = cell2mat(fileData);

x1 = plateCoordinates(:,1:n/2);
y1 = plateCoordinates(:,(n/2+1):n);
t1 = dt1:dt1:(dt1*size(x1,1));

% load data sim 2 convergene
if KB >=3
    filename = sprintf([path,'/FSI_conv_%ddeg_KB%d_deformation.dat'],alpha0,KB);
else
    filename = sprintf([path,'/FSI_conv_%ddeg_KB3e-1_deformation.dat'],alpha0);
end
fmt=repmat('%f',1,n);
fileID = fopen(filename,'r');
fileData = textscan(fileID, fmt, 'HeaderLines', 1, 'CollectOutput', 1);
plateCoordinates = cell2mat(fileData);

x2 = plateCoordinates(:,1:n/2);
y2 = plateCoordinates(:,(n/2+1):n);
t2 = t1(end) + (dt2:dt2:(dt2*size(x2,1)));

x = interp1([t1,t2],[x1; x2],time);
y = interp1([t1,t2],[y1; y2],time);

angle = [zeros(size(x,1),1), atan((y(:,2:end)-y(:,1:end-1))./(x(:,2:end)-x(:,1:end-1)))];
dangle = [angle(:,2:end) - angle(:,1:end-1), zeros(size(x,1),1)];

% wing root deformation angle, which is related to the plate strain
dangle = dangle(:,2)';

kappa = sin(dangle)/(2*(1/(n/2))); %curvature
end