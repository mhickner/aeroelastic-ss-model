clearvars; close all

% -------- General Parameters ---------------------------------------------
dir = '../FSI_php_20deg_KB3e-1/output';
a0 = 20; %starting angle of attack (alpha)

tplot = [55000 59000 61000 63000 65000 55000];

% Contour maximum values and number of contour levels
% Vorticity
cmax_w = 16;
clev_w = 64; %use even #
clevs = linspace( -cmax_w, cmax_w, clev_w );
cmap = build_cmap( length(clevs) );

% Range for plots
range = [-0.5 4.5 -1 1];

% Plot the pressure field?
pressure=0;

f1 = figure(1);
tiledlayout(length(tplot),1,'TileSpacing','none')

for it = tplot

        j = 3;
        
        % Get data from specified file (see getdata for details)
        [xb,yb,codeb,xn,yn,un,vn,u0pn,v0pn,u0rn,v0rn,wn,sn,pn] ...
            = getdata(dir,it,j,pressure,a0);
        
        colormap(cmap);
        
        wn( wn > cmax_w ) = cmax_w;
        wn( wn < -cmax_w ) = -cmax_w;
        
        %plot vorticity
        nexttile
        contourf(xn,yn,wn, clevs, 'edgecolor','none'); shading flat;
        hold on
        
%         plot(xb(find(codeb==1)),yb(find(codeb==1)),'k','linewidth',4); % Plot body
        hold off

    axis equal
    box off
    xlim([-0.1 3])
    ylim([-0.5 0.5]) 
    set(gca, 'XTickLabel', [])
    set(gca, 'YTickLabel', [])

    set(gcf, 'Units', 'centimeters' )
    set(gcf, 'Position', [16.8628    6.2794    4.4097    8.18])
    
    print('-depsc',['f_flowfield.png'])
  
end



