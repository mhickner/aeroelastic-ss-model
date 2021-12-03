function [theo_ss,sys] = TheoModel(w,pp,rank)
a = -1+pp*2; % pitch location
k = w/2; % reduced frequency
C = besselh(1,2,k)./(besselh(1,2,k)+i*besselh(0,2,k)); % Theo transfer fcn

% Theodorsen's model for pure pitching
ARG = (-pi/4)*a*(-w.*w) + (pi/2)*(i*w) + 2*pi*C + pi*(.5-a)*(i*w).*C;
ARG = ARG./(-w.*w);
ARG = (ARG)*pi/180; % convert input from rad to deg

sys = frd(ARG,w);
theo_ss = fitfrd(sys,rank);
