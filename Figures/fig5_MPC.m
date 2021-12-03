%% load data
clearvars; close all
cmap = get_cmap2();

%case1: only CL tracking
c1 = load('../MPC/2109Results/simOut_A');

% case2: CL and kappa tracking
c2 = load('../MPC/2109Results/simOut_B');

% remove last data point 
c1.tHistory = c1.tHistory(1:end-1);
c2.tHistory = c2.tHistory(1:end-1);
c1.yHistory = c1.yHistory(:,1:end-1);
c2.yHistory = c2.yHistory(:,1:end-1);
c1.uHistory = c1.uHistory(:,1:end-1);
c2.uHistory = c2.uHistory(:,1:end-1);

%% fig 5, MPC with and without deformation control
close all
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
set(groot,'DefaultLineLineWidth',2)
set(groot, 'defaultLegendInterpreter','latex');
f1 = figure;
f1.Units =  'centimeters';
f1.Position= [3   3   19   10.5];

nn = 4; %number of plots
t_end = 30;
subt = downsample(c1.tHistory,10);
subCLref = downsample(c1.CL_ref(1:c1.Nt-1),10);

s1 = subplot(nn,1,1);
plot(c1.tHistory,c1.CL_ref(1:c1.Nt-1),'-','Color',[0 0 0 0.4],'Linewidth',4); hold on %CL reference
plot(c1.tHistory,c1.yHistory(1,:),'Color',[cmap(8,:)]); hold on
plot(c1.tHistory,c2.yHistory(1,:),'Color',[cmap(3,:)]); hold on
grid on
set(gca,'xticklabel',[])
ylabel('$C_L$')
xlim([0 t_end])
ylim([min(c2.yHistory(1,:))-0.05 max(c1.yHistory(1,:))+0.05])

s2 = subplot(nn,1,2);
lref = plot([1.5,c1.tHistory(end)],[0 0],'-','Color',[0 0 0 0.4],'Linewidth',4); hold on %kappa reference
plot(c1.tHistory,c1.yHistory(2,:),'Color',cmap(8,:));hold on
plot(c1.tHistory,c2.yHistory(2,:),'Color',cmap(3,:)); hold on
grid on
set(gca,'xticklabel',[])
ylabel('$\kappa$')
xlim([0 t_end])
ylim([min(c1.yHistory(2,:))-0.01 max(c1.yHistory(2,:))+0.01])
l2 = legend('reference','$C_L$ only reference tracking','$C_L$ \& $\kappa$ tracking');

s3 = subplot(nn,1,3);
plot(c1.tHistory,c1.yHistory(3,:),'Color',cmap(8,:)); hold on
plot(c1.tHistory,c2.yHistory(3,:),'Color',cmap(3,:)); hold on
grid on
set(gca,'xticklabel',[])
set(gca,'ytick',[0 4 8])
ylabel('$\alpha$')
xlim([0 t_end])
ylim([min(c1.yHistory(3,:))-0.5 max(c1.yHistory(3,:))+0.5])

s4 = subplot(nn,1,4);
plot(c1.tHistory,c1.uHistory(1,:),'Color',cmap(8,:)); hold on
plot(c1.tHistory,c2.uHistory(1,:),'Color',cmap(3,:)); hold on
grid on
ylabel('$\ddot{\alpha}$')
xlabel('convective time ($\tau$)')
xlim([0 t_end])
ylim([min(c1.uHistory)-1 max(c1.uHistory)+1])

set(findall(f1,'-property','FontSize'),'FontSize',10)
%
set(s1,'position',[0.12 0.78 .85 .189]) % reduce whitespace
set(s2,'position',[0.12 0.58 .85 .189])
set(s3,'position',[0.12 0.31 .85 .19])
set(s4,'position',[0.12 0.11 .85 .19])

% position legends
set(l2,'Position',[0.6701    0.8589    0.2982    0.1376])
% print('f_control1','-dpng')

