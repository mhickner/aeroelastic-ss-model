%% load data
clearvars; close all
cmap = get_cmap2();

%case1: only CL tracking
constraintOn = 0; flexiROM = 1; Qkappa = 0;
c1 = load('../MPC/2109Results/simOut_A');

% case2: CL and kappa tracking
constraintOn = 0; flexiROM = 1; Qkappa = 1;
c2 = load('../MPC/2109Results/simOut_B');

% remove last data point 
c1.tHistory = c1.tHistory(1:end-1);
c2.tHistory = c2.tHistory(1:end-1);
c1.yHistory = c1.yHistory(:,1:end-1);
c2.yHistory = c2.yHistory(:,1:end-1);
c1.uHistory = c1.uHistory(:,1:end-1);
c2.uHistory = c2.uHistory(:,1:end-1);

close all
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
set(groot,'DefaultLineLineWidth',2)
set(groot, 'defaultLegendInterpreter','latex');

% mini plot for fig1, overview
f3 = figure(3);
f3.Units =  'centimeters';
f3.Position= [5   5   5.6   6];

nnz = 2; %number of plots
ntz= 25; %zoomed last time

sz1 = subplot(nnz,1,1);
plot(c1.tHistory,c1.CL_ref(1:c1.Nt-1),'-','Color',[0 0 0 0.4],'Linewidth',4); hold on %CL reference
plot(c1.tHistory,c1.yHistory(1,:),'Color',[cmap(8,:)]); hold on
plot(c1.tHistory,c2.yHistory(1,:),'Color',[cmap(3,:)]); hold on
% yline(10,':','Color',cmap(16,:),'LineWidth',2)
grid on
set(gca,'xticklabel',[])
ylabel('$C_L$')
ylim([min(c2.yHistory(1,:))-0.05 max(c1.yHistory(1,:))+0.05])
sz1.XLim = [0 ntz];
l1 = legend('reference','$C_L$ only tracking','$C_L$ \& $\kappa$ tracking');

sz2 = subplot(nnz,1,2);
lref = plot([1.5,c1.tHistory(end)],[0 0],'-','Color',[0 0 0 0.4],'Linewidth',4); hold on %kappa reference
plot(c1.tHistory,c1.yHistory(2,:),'Color',cmap(8,:));hold on
plot(c1.tHistory,c2.yHistory(2,:),'Color',cmap(3,:)); hold on
grid on
xlabel('convective time ($\tau$)')
ylabel('$\kappa$')
sz2.XLim = [0 ntz];
ylim([min(c1.yHistory(2,:))-0.01 max(c1.yHistory(2,:))+0.01])

set(findall(f3,'-property','FontSize'),'FontSize',10)
%
set(sz1,'position',[0.21 0.52 .76 .35]) % reduce whitespace
set(sz2,'position',[0.21 0.17 .76 .35])
set(l1,'position',[0.27    0.7036    0.7187    0.2908])
% print('f1_control','-depsc')