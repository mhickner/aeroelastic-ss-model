%% load data
clearvars
cmap = get_cmap2();
cmap = horzcat(cmap,0.7*ones(size(cmap,1),1)); % add transparency
basepath = '../MPC/Results_211117_17_03_27' ; % DNS w/ constraint
c1 = load([basepath '/simOutFinalDNSflexiControl_3.mat']);
c3 = load([basepath '/simOutFinalDNSflexiControl_5.mat']);
c5 = load([basepath '/simOutFinalDNSflexiControl_7.mat']);

%% plot
close all
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
set(groot,'DefaultLineLineWidth',2)
set(groot, 'defaultLegendInterpreter','latex');
f1 = figure;
f1.Units =  'centimeters';
f1.Position= [3   3   9.2   10.5];

nn = 8; %number of plots
t_end = 4;
subt = downsample(c1.tHistory,10);
subCLref = downsample(c1.CL_ref(1:c1.Nt),10);

s1 = subplot(nn,1,1);
plot(c1.tHistory,c1.CL_ref(1:c1.Nt),'-','Color',[0 0 0 0.3],'Linewidth',2); hold on %CL reference
plot(c3.tHistory,c3.CL_ref(1:c1.Nt),'-','Color',[0 0 0 0.4],'Linewidth',2);
plot(c5.tHistory,c5.CL_ref(1:c1.Nt),'-','Color',[0 0 0 0.6],'Linewidth',2);

plot(c1.tHistory,c1.yHistory(1,:),'Color',[cmap(1,:)]); hold on
plot(c3.tHistory,c3.yHistory(1,:),'Color',[cmap(5,:)]); hold on
plot(c5.tHistory,c5.yHistory(1,:),'Color',[cmap(8,:)]); hold on

grid on
set(gca,'xticklabel',[])
ylabel('$C_L$')
xlim([0 t_end])
ylim([min(c3.yHistory(1,:))-0.05 max(c1.yHistory(1,:))+0.05])
%
s2 = subplot(nn,1,2);

plot(c1.tHistory,c1.yHistory(2,:),'Color',[cmap(1,:)]); hold on
plot(c3.tHistory,c3.yHistory(2,:),'Color',[cmap(5,:)]); hold on
plot(c5.tHistory,c5.yHistory(2,:),'Color',[cmap(8,:)]); hold on
plot([c1.tHistory(1),c1.tHistory(end)],[c3.UBo c3.UBo],':','Color',[0 0 0 0.3]); hold on %kappa constraint
grid on
set(gca,'xticklabel',[])
ylabel('$\kappa$')
xlim([0 t_end])
ylim([-0.1 0.2])

s3 = subplot(nn,1,3);
plot(c1.tHistory,c1.yHistory(3,:),'Color',[cmap(1,:)]); hold on
plot(c3.tHistory,c3.yHistory(3,:),'Color',[cmap(5,:)]); hold on
plot(c5.tHistory,c5.yHistory(3,:),'Color',[cmap(8,:)]); hold on
grid on
set(gca,'xticklabel',[])
ylabel('$\alpha$')
xlim([0 t_end])
ylim([-3 15])


s4 = subplot(nn,1,4);
plot(c1.tHistory,c1.uHistory(1,:),'Color',[cmap(1,:)]); hold on
plot(c3.tHistory,c3.uHistory(1,:),'Color',[cmap(5,:)]); hold on
plot(c5.tHistory,c5.uHistory(1,:),'Color',[cmap(8,:)]); hold on

ref_line = yline(100,'-','Color',[0.4 0.4 0.4],'Linewidth',2); % dummy line for legend
bound_line =  yline(100,':','Color',[0.3 0.3 0.3],'Linewidth',2); % dummy line for legend
l = legend([ref_line bound_line], {'$C_L$ reference','$\kappa$ constraint'});

grid on
ylabel('$\ddot{\alpha}$')
xlabel('convective time ($\tau$)')
xlim([0 t_end])
ylim([-27 28])

set(findall(f1,'-property','FontSize'),'FontSize',10)
set(s1,'position',[0.13 0.78 .85 .189]) % reduce whitespace
set(s2,'position',[0.13 0.58 .85 .189])
set(s3,'position',[0.13 0.31 .85 .19])
set(s4,'position',[0.13 0.11 .85 .19])

% position legends
set(l,'Position',[0.1510    0.4624    0.3656    0.1376])
% print('f_MPC_constraint12','-depsc')

