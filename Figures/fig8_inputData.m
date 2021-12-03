clearvars, close all

% Load workspace
addpath('../')
load('../Models/211109_16_43_08') % includes model & input data for KB=0.31
cmap = get_cmap(); % colormap 

%% Plot maneuver
f1 = figure(1);
set(gcf,'defaultLineLineWidth',2)
set(gcf,'defaulttextinterpreter','latex');  
set(gcf, 'defaultAxesTickLabelInterpreter','latex');  
set(gcf, 'defaultLegendInterpreter','latex');
f1.Units =  'centimeters';
f1.Position= [8   8   19   9];

t_plot = 0.2;
t0 = 0.0051/dt;
tf = t_plot/dt;

m = 5; % number of subplot rows
n = 1;% number of subplot columns

% original signal
sc = subplot(m,n,1);
plot(time(t0:tf),CL(t0:tf),'Color',cmap(4,:))
ylabel('$C_L$')
set(gca,'Xticklabel',[])
set(gca,'Yticklabel',[])
xlim([0.005 t_plot])
ylim([-58 58])

sk = subplot(m,n,2);
plot(time(t0:tf),kappa(t0:tf),'Color',cmap(8,:))
ylabel('$\kappa$')
set(gca,'Xticklabel',[])
set(gca,'Yticklabel',[])
ylim([min(kappa(t0:tf))-0.005 max(kappa(t0:tf))+0.005])
xlim([0.005 t_plot])

sa = subplot(m,n,3);
plot(time(t0:tf),u(t0:tf),'k')
ylabel('$\alpha$')
set(gca,'Xticklabel',[])
set(gca,'Yticklabel',[])
xlim([0.005 t_plot])

sad = subplot(m,n,4);
plot(time(t0:tf),udot(t0:tf),'k')
ylabel('$\dot{\alpha}$')
set(gca,'Xticklabel',[])
set(gca,'Yticklabel',[])
xlim([0.005 t_plot])

sadd = subplot(m,n,5);
plot(time(t0:tf),uddot(t0:tf),'k')
xlabel('$\tau$')
ylabel('$\ddot{\alpha}$')
set(gca,'Xticklabel',[])
set(gca,'Yticklabel',[])
xlim([0.005 t_plot])

%%
set(findall(gcf,'-property','FontSize'),'FontSize',10)
spw = 0.9; % subplot width
sph1 = 0.24; % height (big)
sph2 = 0.12; % height (small)
sps = 0.05; % spacing (vertical)

set(sc,'position',[0.05 0.74 spw sph1]) % single column
set(sk,'position',[0.05 0.49 spw sph1])
set(sa,'position',[0.05 0.34 spw sph2])
set(sad,'position',[0.05 0.21 spw sph2])
set(sadd,'position',[0.05 0.08 spw sph2])