%% generate aeroelastic model using CL and deformation data
% input data: CL and deformation time series from step in AoA (variable: u)
% impulse in AoA velocity (variable: udot)

clearvars
close all
clc

%% generate ROM

% path data
path = 'FSIalpha_results';

% model rank
r = 7;

% initial angle of attack 
alpha0 = 0;

% duration of perturbation
t_c = 0.01;

% stiffness of plate
KBi = [31 3 .31];

%%
for i = 1:3
    KB = KBi(i);
    
    % load force (CL) and deformation files
    [CL,kappa,time,dt,u,udot,uddot,M] = loadDataFSI(alpha0,KB,path);

    % get model coefficients
    [C_alpha, C_alpha_dot, C_alpha_ddot, H_i, Y_all] = get_coefficients_ad(CL,kappa,time,dt,u,udot,uddot,M,t_c);
            
    % run empirical theodorsen
    if KBi(i) == 31
        [sys_emp_7_high,sysdisc_7_high] = emp_theodorsen_ad(r,C_alpha, C_alpha_dot, C_alpha_ddot, H_i, t_c, M);
    elseif KBi(i) == 3
        [sys_emp_7_med,sysdisc_7_med] = emp_theodorsen_ad(r,C_alpha, C_alpha_dot, C_alpha_ddot, H_i, t_c, M);
    elseif KBi(i) == .31
        [sys_emp_7_low,sysdisc_7_low] = emp_theodorsen_ad(r,C_alpha, C_alpha_dot, C_alpha_ddot, H_i, t_c, M);
    end
    
end

%% Save workspace
filename = datestr(now,'yymmdd_HH_MM_SS');
matfile = fullfile('Models',filename);
save(matfile)

