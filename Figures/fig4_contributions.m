clearvars, close all
addpath('../')

cmap = get_cmap();

% load model
% check that sys loaded matches alpha0,r, & KB for DNS
load('../Models/all_models','sys_0deg_KB3_r7')
sysOrig = sys_0deg_KB3_r7;

alpha0 = 0;
KB = 3;
r = length(sysOrig.A)-2;

if KB == 0.3
    colCL = 4; % colormap index for CL
    colk = 8; % colormap index for kappa
elseif KB == 3
    colCL = 3; % colormap index for CL
    colk = 7; % colormap index for kappa
elseif KB == 31
    colCL = 2; % colormap index for CL
    colk = 6; % colormap index for kappa
end

A = sysOrig.A;
B = sysOrig.B;

C = [sysOrig.C(1,1:end-2) zeros(1,2);
    zeros(1,r) sysOrig.C(1,end-1) zeros(1,1);
    zeros(1,r+1) sysOrig.C(1,end);
    zeros(1,r+2);
    sysOrig.C(2,1:end-2) zeros(1,2);
    zeros(1,r) sysOrig.C(2,end-1) zeros(1,1);
    zeros(1,r+1) sysOrig.C(2,end);
    zeros(1,r+2)];

D = [zeros(3,1);
    sysOrig.D(1,:);
    zeros(3,1);
    sysOrig.D(2,:)];

sys = ss(A,B,C,D);

%% load DNS test 
addpath('../')
path = '../FSIalpha_results';

[CLFSI,~, ~,tCL,~,~,~] = ...
    emp_theodorsen_testing(r,alpha0,KB,sysOrig,path); %lift

[kFSI,yOrig,time,alpha,alpha_dot,alpha_ddot] = ...
    emp_theodorsen_testingDeformation(r,alpha0,KB,sysOrig,path);% kappa, curvature

%% linear simulation
[y,tOut,x] = lsim(sys,alpha_ddot*180/pi,time);

%% plot
n = 8000; % number of points to plot

close all
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
set(groot,'DefaultLineLineWidth',2)
set(0, 'DefaultAxesFontSize', 18)
set(groot, 'defaultLegendInterpreter','latex');
f1 = figure(1);
colororder(cmap(9:12,:))
f1.Units =  'centimeters';
f1.Position= [3   3   19   10];

% plot CL ROM & DNS
s1 = subplot(3,2,1); % total CL
plot(time(1:n),yOrig(1:n,1),'Color',cmap(colCL,:),'LineWidth',2)
hold on
plot(tCL(1:n),CLFSI(1:n),'k','LineWidth',2,'LineStyle','--')
grid on
xticklabels([])
ylim([min(CLFSI,[],'all')-0.05 max(CLFSI,[],'all')+0.05])
ylabel('$C_L$')

% CL contributions
s3 = subplot(3,2,3); 
nC = size(y,2)/2;
plot(tOut(1:n),y(1:n,2),'LineStyle','-.')
hold on
plot(tOut(1:n),y(1:n,3),'LineStyle',':')
plot(tOut(1:n),y(1:n,4))
plot(tOut(1:n),y(1:n,1)) % transients
grid on
xticklabels([])
ylim([min(y(1:n,1:nC),[],'all')-0.05 max(y(1:n,1:nC),[],'all')+0.05])
ylabel('$C_L$')

% plot curvature ROM & DNS
s2 = subplot(3,2,2); % total curvature
yline(100,'Color',cmap(colCL,:),'LineWidth',2)
hold on
plot(time(1:n),yOrig(1:n,2),'Color',cmap(colk,:),'LineWidth',2)
plot(time(1:n),kFSI(1:n),'k','LineWidth',2,'LineStyle','--')

l2 = legend('$C_L$ ROM','$\kappa$ ROM','FOM');
ylabel('$\kappa$')
xticklabels([])
ylim([min(kFSI,[],'all')-0.001 max(kFSI,[],'all')+0.001])
s2.YAxis.Exponent = 0;
grid on
box on

% curvature contributions
s4 = subplot(3,2,4); 
nC = size(y,2)/2;
plot(tOut(1:n),y(1:n,nC+2),'LineStyle','-.')
hold on
plot(tOut(1:n),y(1:n,nC+3),'LineStyle',':')
plot(tOut(1:n),y(1:n,nC+4))
plot(tOut(1:n),y(1:n,nC+1))
grid on
xticklabels([])
ylabel('$\kappa$')
ylim([min(y(1:n,nC+1:end),[],'all')-0.001 max(y(1:n,nC+1:end),[],'all')+0.001])
l4 = legend('$C_{\alpha} \alpha$','$C_{\dot{\alpha}} \dot{\alpha}$','$C_{\ddot{\alpha}} \ddot{\alpha}$','transients');

% maneuver (2 identical plots)
s5 = subplot(3,2,5);
plot(time(1:n),alpha(1:n)*180/pi,'Color',cmap(9,:),'LineStyle','-.')
hold on
plot(time(1:n),alpha_dot(1:n)*180/pi,'Color',cmap(10,:),'LineStyle',':')
plot(time(1:n),alpha_ddot(1:n)*180/pi,'Color',cmap(11,:))
ylim([(min(alpha_dot(1:n))*180/pi)-1 (max(alpha(1:n)*180/pi))+1])
ylim([-((max(alpha(1:n)*180/pi))+1) (max(alpha(1:n)*180/pi))+1])
xlabel('convective time ($\tau$)')
grid on

s6 = subplot(3,2,6);
plot(time(1:n),alpha(1:n)*180/pi,'Color',cmap(9,:),'LineStyle','-.')
hold on
plot(time(1:n),alpha_dot(1:n)*180/pi,'Color',cmap(10,:),'LineStyle',':')
ylim([-((max(alpha(1:n)*180/pi))+1) (max(alpha(1:n)*180/pi))+1])
plot(time(1:n),alpha_ddot(1:n)*180/pi,'Color',cmap(11,:))
xlabel('convective time ($\tau$)')
l6 = legend('$\alpha$ (deg)','$\dot{\alpha}$ (deg/$\tau$)','$\ddot{\alpha}$ (deg/$\tau^2$)');
grid on

% reduce whitespace
set(s1,'position',[0.07 0.68 .32 .3]) 
set(s3,'position',[0.07 0.37 .32 .3])

set(s2,'position',[0.5 0.68 .32 .3])
set(s4,'position',[0.5 0.37 .32 .3])

set(s5,'position',[0.07 0.11 .32 .2])
set(s6,'position',[0.5 0.11 .32 .2])

set(l2,'position',[0.8260    0.834    0.1499    0.1444])
set(l4,'position',[0.826    0.4827    0.1552    0.1884])
set(l6,'position',[0.827    0.1663    0.1634    0.1444])

set(findall(f1,'-property','FontSize'),'FontSize',10)
% print(f1,'f_contributions','-dpng')