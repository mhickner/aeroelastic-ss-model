addpath('../')
%% Load workspace
clearvars, close all
load('../Models/all_models','sys_0deg_KB03_r7','sys_0deg_KB3_r7','sys_0deg_KB31_r7')

sys03 = sys_0deg_KB03_r7;
sys3 = sys_0deg_KB3_r7;
sys31 = sys_0deg_KB31_r7;

wmin = -1; % 10^(w)
wmax = 3; % 10^(w)
% generate theodorsen frd model
W = logspace(wmin,wmax,1000); % frequencies
pp = 0; % pitch point?
rank = 11;
[sys_theo,frd_theo] = TheoModel(W,pp,rank);

load('../Models/modes') %bending modes
cmap = get_cmap(); % colormap

%% Flexible Bode 

[mag03,phase03] = bode(sys03,W);
[mag3,phase3] = bode(sys3,W);
[mag31,phase31] = bode(sys31,W);

%convert magnitude to dB
mag03 = mag2db(mag03);
mag3 = mag2db(mag3);
mag31 = mag2db(mag31);

%unwrap phase
phase31(2,:) = (phase31(2,:)-360);
phase3(2,:) = (phase3(2,:)-360);
phase03(2,:) = (phase03(2,:)-360);

% Theodorsen
[magT,phaseT] = bode(frd_theo,W); % pitch point around leading edge
magT = mag2db(magT);
phaseT = (phaseT-360);

%% Bode plot for multiple KB (rigidity) cases
close all
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
set(groot,'DefaultLineLineWidth',2)
set(0, 'DefaultAxesFontSize', 18)
set(groot, 'defaultLegendInterpreter','latex');
f1 = figure(1);
set(gcf,'defaultLineLineWidth',2)
colororder(cmap(9:12,:))
f1.Units =  'centimeters';
f1.Position= [3   3   19   11];

% CL magnitude
s1 = subplot(2,2,1);
ph = semilogx(W,mag31(1,:) , 'Color',cmap(2,:), 'LineWidth',2);
hold on;
pm = semilogx(W,mag3(1,:) , 'Color',cmap(3,:), 'LineWidth',2);
pl = semilogx(W,mag03(1,:) , 'Color',cmap(4,:), 'LineWidth',2);

% analytical resonant frequency vertical lines
xline(modes.omega(2,1),':','Color',cmap(3,:), 'LineWidth',1.5);
xline(modes.omega(2,2),'--','Color',cmap(3,:), 'LineWidth',1.5);
xline(modes.omega(1,1),':','Color',cmap(4,:), 'LineWidth',1.5);
xline(modes.omega(1,2),'--','Color',cmap(4,:), 'LineWidth',1.5);
xline(modes.omega(3,1),':','Color',cmap(2,:), 'LineWidth',1.5);
xline(modes.omega(3,2),'--','Color',cmap(2,:), 'LineWidth',1.5);
pT = semilogx(W,magT(1,:) , 'k:', 'LineWidth',2);
grid on;
title('Coefficient of Lift')
xlim([10^wmin 10^wmax]);
ylim([-150 20]);
set(gca,'xticklabel',[])
ylabel('Magnitude (dB)');
l1 = legend([ph pm pl pT], {'Stiff, $K_B = 31$','Medium, $K_B = 3.1$',...
    'Flexible, $K_B = 0.31$','Theodorsen model'});

% CL phase
s3 = subplot(2,2,3);
ph = semilogx(W,phase31 (1,:) , 'Color',cmap(2,:), 'LineWidth',2);
hold on;
pm = semilogx(W,phase3(1,:) , 'Color',cmap(3,:), 'LineWidth',2);
pl = semilogx(W,phase03(1,:) , 'Color',cmap(4,:), 'LineWidth',2);
grid on;
xlim([10^wmin 10^wmax]);
ylim([-220 45]);
xlabel('Freq (rad/s c/U)'); ylabel('Phase (degree)');

% analytical resonant frequencies
xline(modes.omega(2,1),':','Color',cmap(3,:),'LineWidth',1.5);
xline(modes.omega(2,2),'--','Color',cmap(3,:),'LineWidth',1.5);
xline(modes.omega(1,1),':','Color',cmap(4,:),'LineWidth',1.5);
xline(modes.omega(1,2),'--','Color',cmap(4,:),'LineWidth',1.5);
xline(modes.omega(3,1),':','Color',cmap(2,:),'LineWidth',1.5);
xline(modes.omega(3,2),'--','Color',cmap(2,:),'LineWidth',1.5);
pT = semilogx(W,phaseT(1,:) , 'k:', 'LineWidth',2);

% Curvature magnitude
s2 = subplot(2,2,2);
ph = semilogx(W,mag31(2,:) , 'Color',cmap(6,:), 'LineWidth',2);
hold on;
pm = semilogx(W,mag3(2,:) , 'Color',cmap(7,:), 'LineWidth',2);
pl = semilogx(W,mag03(2,:) , 'Color',cmap(8,:), 'LineWidth',2);

% analytical resonant frequencies
xline(modes.omega(1,1),':','Color',cmap(8,:), 'LineWidth',1.5);
xline(modes.omega(1,2),'--','Color',cmap(8,:), 'LineWidth',1.5);
m1 = xline(modes.omega(2,1),':','Color',cmap(7,:), 'LineWidth',1.5);
m2 = xline(modes.omega(2,2),'--','Color',cmap(7,:), 'LineWidth',1.5);
xline(modes.omega(3,1),':','Color',cmap(6,:), 'LineWidth',1.5);
xline(modes.omega(3,2),'--','Color',cmap(6,:), 'LineWidth',1.5);

grid on; 
title('Curvature near leading edge')
xlim([10^wmin 10^wmax]);
ylim([-150 20]);
set(gca,'xticklabel',[])
ylabel('Magnitude (dB)');
l3 = legend([ph pm pl], {'$K_B = 31$','$K_B = 3.1$','$K_B = 0.31$'});

% Curvature phase
s4 = subplot(2,2,4);
semilogx(W(1:640),(phase31(2,1:640)-360), 'Color',cmap(6,:), 'LineWidth',2);
hold on;
ph = semilogx(W(642:end),phase31 (2,642:end) , 'Color',cmap(6,:), 'LineWidth',2); % phase wrapped
pm = semilogx(W,phase3(2,:) , 'Color',cmap(7,:), 'LineWidth',2);
pl = semilogx(W,phase03(2,:) , 'Color',cmap(8,:), 'LineWidth',2);
grid on; 
xlim([10^wmin 10^wmax]);
ylim([-220 45]);
xlabel('Freq (rad/s c/U)');
ylabel('Phase (deg)');

% analytical resonant frequencies
xline(modes.omega(1,1),':','Color',cmap(8,:), 'LineWidth',1.5);
xline(modes.omega(1,2),'--','Color',cmap(8,:), 'LineWidth',1.5);
xline(modes.omega(2,1),':','Color',cmap(7,:), 'LineWidth',1.5);
xline(modes.omega(2,2),'--','Color',cmap(7,:), 'LineWidth',1.5);
xline(modes.omega(3,1),':','Color',cmap(6,:), 'LineWidth',1.5);
xline(modes.omega(3,2),'--','Color',cmap(6,:), 'LineWidth',1.5);

m1 = yline(400,':','Color',[0.4 0.4 0.4], 'LineWidth',1.5); % for legend, outside of plot area
m2 = yline(400,'--','Color',[0.4 0.4 0.4], 'LineWidth',1.5);
l4 = legend([m1 m2],{'$\omega_{N1}$, first bending mode','$\omega_{N2}$, second bending mode'});
set(findall(f1,'-property','FontSize'),'FontSize',10)

% reduce whitespace
set(s1,'position',[0.1 0.56 .38 .385]) 
set(s3,'position',[0.1 0.1111 .38 .385])
set(s2,'position',[0.6 0.56 .38 .385])
set(s4,'position',[0.6 0.1111 .38 .385])

% position legends
set(l1,'Position', [0.1000    0.5625    0.2365    0.1884])
set(l3,'Position',[0.6000    0.5625    0.1610    0.1444])
set(l4,'Position', [0.1000    0.4465    0.2925    0.1004])


