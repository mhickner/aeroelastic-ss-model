%% load data
clearvars
cmap = get_cmap2();
cmap = horzcat(cmap,0.7*ones(size(cmap,1),1)); % add transparency
basepath = '../MPC/Results_211118_15_25_08'; % DNS

c1 = load([basepath '/simOutFinalDNSflexiControl_10.mat']);
c2 = load([basepath '/simOutFinalDNSflexiControl_11.mat']);
c3 = load([basepath '/simOutFinalDNSflexiControl_12.mat']);
c4 = load([basepath '/simOutFinalDNSflexiControl_13.mat']);
c5 = load([basepath '/simOutFinalDNSflexiControl_14.mat']);

%% plot
close all
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
set(groot,'DefaultLineLineWidth',2)
set(groot, 'defaultLegendInterpreter','latex');
f1 = figure;
% colororder(cmap(13:16,:))
f1.Units =  'centimeters';
f1.Position= [3   3   19   10.5];

nn = 4; %number of plots
t_end = 4;
subt = downsample(c1.tHistory,10);
subCLref = downsample(c1.CL_ref(1:c1.Nt),10);

s1 = subplot(nn,1,1);
lref = plot(c1.tHistory,c1.CL_ref(1:c1.Nt),'-','Color',[0 0 0 0.4],'Linewidth',3); hold on %CL reference

plot(c1.tHistory,c1.yHistory(1,:),'Color',[cmap(1,:)]); hold on
plot(c2.tHistory,c2.yHistory(1,:),'Color',[cmap(3,:)]); 
plot(c3.tHistory,c3.yHistory(1,:),'Color',[cmap(5,:)]); hold on
plot(c4.tHistory,c4.yHistory(1,:),'Color',[cmap(7,:)]); hold on
plot(c5.tHistory,c5.yHistory(1,:),'Color',[cmap(9,:)]); hold on
l = legend([lref], {'$C_L$ reference'});
grid on
set(gca,'xticklabel',[])
ylabel('$C_L$')
xlim([0 t_end])
ylim([min(c2.yHistory(1,:))-0.05 max(c1.yHistory(1,:))+0.05])

s2 = subplot(nn,1,2);
plot(c1.tHistory,c1.yHistory(2,:),'Color',[cmap(1,:)]); hold on
plot(c2.tHistory,c2.yHistory(2,:),'Color',[cmap(3,:)]); 
plot(c3.tHistory,c3.yHistory(2,:),'Color',[cmap(5,:)]); hold on
plot(c4.tHistory,c4.yHistory(2,:),'Color',[cmap(7,:)]); hold on
plot(c5.tHistory,c5.yHistory(2,:),'Color',[cmap(9,:)]); hold on
grid on
set(gca,'xticklabel',[])
ylabel('$\kappa$')
xlim([0 t_end])
ylim([min(c2.yHistory(2,:))-0.02 c1.UBo+0.04])

s3 = subplot(nn,1,3);
plot(c1.tHistory,c1.yHistory(3,:),'Color',[cmap(1,:)]); hold on
plot(c2.tHistory,c2.yHistory(3,:),'Color',[cmap(3,:)]); 
plot(c3.tHistory,c3.yHistory(3,:),'Color',[cmap(5,:)]); hold on
plot(c4.tHistory,c4.yHistory(3,:),'Color',[cmap(7,:)]); hold on
plot(c5.tHistory,c5.yHistory(3,:),'Color',[cmap(9,:)]); hold on
grid on
set(gca,'xticklabel',[])
ylabel('$\alpha$')
xlim([0 t_end])
ylim([min(c1.yHistory(3,:))-1 max(c1.yHistory(3,:))+1])

s4 = subplot(nn,1,4);
yline(100,'Color',[1 1 1 0]); hold on% dummy line to make space in legend
plot(c1.tHistory,c1.uHistory(1,:),'Color',[cmap(1,:)]); hold on
plot(c2.tHistory,c2.uHistory(1,:),'Color',[cmap(3,:)]); 
plot(c3.tHistory,c3.uHistory(1,:),'Color',[cmap(5,:)]); hold on
plot(c4.tHistory,c4.uHistory(1,:),'Color',[cmap(7,:)]); hold on
plot(c5.tHistory,c5.uHistory(1,:),'Color',[cmap(9,:)]); hold on
grid on
ylabel('$\ddot{\alpha}$')
xlabel('convective time ($\tau$)')
xlim([0 t_end])
ylim([min(c5.uHistory)-2 max(c5.uHistory)+2])

l2 = legend('',num2str(c1.UBo),num2str(c2.UBo),num2str(c3.UBo),num2str(c4.UBo),num2str(c5.UBo));

set(findall(f1,'-property','FontSize'),'FontSize',10)

set(s1,'position',[0.08 0.78 .89 .189]) % reduce whitespace
set(s2,'position',[0.08 0.58 .89 .189])
set(s3,'position',[0.08 0.31 .89 .19])
set(s4,'position',[0.08 0.11 .89 .19])

% position legend
set(l2,'Position',[0.1087    0.3385    0.1090    0.2634]) % full width fig
% print('f_MPC_constraint2','-depsc')


