clearvars, close all

% load models & data
load('../Models/210729_11_50_59') 

cmap = get_cmap();
alpha0 = 0;
KB = 3;
r = [1:10]; % max r=16 (models available)

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

%%
f1 = figure;
set(gcf,'defaultLineLineWidth',2)
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');

f1.Units =  'centimeters';
f1.Position= [3   3   19   9.2];

C = {[0.6157    0.0078    0.0314],...
    [0    0.4470    0.7410 0.6],...
    [0.9290, 0.6940, 0.1250, 0.9]}; % colormap

s2 = subplot(2,2,2);
title('Coefficient of Lift')
r_plot = [2 4 6];
nt = 9999;
for i = 1:3
plot(tk(1:nt),testdata.r(r_plot(i)).CLERA(1:nt,1),'Color',C{i})
hold on
end
plot(tk(1:nt),testdata.FSI.CLFSI(1:nt),'k:','LineWidth',1)
legend('rank 4','rank 6','rank 8','DNS')
ylabel('$C_L$')
set(gca,'Xticklabel',[])
hold off

s4 = subplot(2,2,4);
title('Curvature')
r_plot = [2 4 6];
for i = 1:3
plot(tk(1:nt),testdata.r(r_plot(i)).kERA(1:nt,2),'Color',C{i})
hold on
end
plot(tk(1:nt),testdata.FSI.kFSI(1:nt),'k:','LineWidth',1)
xlabel('convective time, ($\tau = tU/c$)')
ylabel('$\kappa$')
hold off

% calculate error
% global relative error
n = 9999;
CLFSI = testdata.FSI.CLFSI(1:n);
kFSI = testdata.FSI.kFSI(1:n);

for j = r
CLERA = testdata.r(j).CLERA(1:n,1);
kERA = testdata.r(j).kERA(1:n,2);

eCL(j) = 100*sqrt(sum((CLFSI-CLERA).^2))/sqrt(sum(CLFSI.^2));
ek(j) = 100*sqrt(sum((kFSI-kERA).^2))/sqrt(sum(kFSI.^2));
end

s1 = subplot(2,2,1);
plot(r+2,eCL(r),'ko-','LineWidth',1)
set(gca,'Xticklabel',[])
ylabel('$C_L$ error')

s3 = subplot(2,2,3);
plot(r+2,ek(r),'ko-','LineWidth',1)
xlabel('model rank')
ylabel('$\kappa$ error')

set(findall(f1,'-property','FontSize'),'FontSize',10)

set(s1,'position',[0.1 0.56 .2 .4]) % reduce whitespace
set(s3,'position',[0.1 0.1111 .2 .4])

set(s2,'position',[0.4 0.56 .55 .4])
set(s4,'position',[0.4 0.1111 .55 .4])
