clearvars, close all
addpath('../')

cmap = get_cmap();

% load model
% check that sys loaded matches alpha0,r, & KB for DNS
load('../Models/all_models','sys_0deg_KB3_r7')
sysOrig = sys_0deg_KB3_r7;

alpha0 = 0;
KB = 3;
% r = 7;
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

%% load DNS test
addpath('../')
path = '../FSIalpha_results';

[CLFSI,~, ~,tCL,~,~,~] = ...
    emp_theodorsen_testing(r,alpha0,KB,sysOrig,path); %lift

[kFSI,yOrig,time,alpha,alpha_dot,alpha_ddot] = ...
    emp_theodorsen_testingDeformation(r,alpha0,KB,sysOrig,path);% kappa, curvature

%% color matrix
close all
t = [55000 59000 61000 63000 65000 55000]./10;
CL = CLFSI(t)
k = kFSI(t)

f1 = figure(1);
f1.Units =  'centimeters';
f1.Position= [23.1069    4.7272    2.8222   14.8167];
[cmap_red cmap_blue] = get_cmap_matrix();
colormap(cmap_red)
imagesc(CL)
box off
set(gca, 'XTickLabel', [])
set(gca, 'YTickLabel', [])
yticks([])
print('-depsc',['f1_matrix1.eps'])

f2 = figure(2);
f2.Units =  'centimeters';
f2.Position= [27.1069    4.7272    2.8222   14.8167];
imagesc(k)
colormap(cmap_blue)
box off
set(gca, 'XTickLabel', [])
set(gca, 'YTickLabel', [])
yticks([])

% print('-depsc',['f1_matrix2.eps'])