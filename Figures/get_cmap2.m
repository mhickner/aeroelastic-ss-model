function [cmap_rgb] = get_cmap2()

cmap_hex = ["6a040f","9d0208","b70104","d00000","dc2f02","e85d04","f48c06","faa307","ffba08"]; % reds
% cmap_hex = ["18554c","1f734d","258a47","299843","3aab55","4bbe66","7fd291","a9e2b6"]; % greens

%   https://www.mathworks.com/matlabcentral/fileexchange/46289-rgb2hex-and-hex2rgb                      
addpath('/Applications/Matlab_Packages/hex_and_rgb_v1.1.1')

% convert to RGB
cmap_hex = reshape(cmap_hex,[],1);  % reshape to Nx1 color array
cmap_hex = convertStringsToChars(cmap_hex);  % convert string array to character array
cmap_rgb = hex2rgb(cmap_hex);  % convert hex colors to rgb colors


