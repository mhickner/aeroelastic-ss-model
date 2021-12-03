function [cmap_red,cmap_blue] = get_cmap_matrix()

cmap_red_hex = ["690728","9b0310","bf3311","d14b12","da5712","e36212","ef771b","f5811f","f9963f","fcab5f"];
cmap_blue_hex = ["1f125c","101c7e","0c2b7f","07397f","0d559d","1271ba","16758d","358b8c","64a996"];

%   https://www.mathworks.com/matlabcentral/fileexchange/46289-rgb2hex-and-hex2rgb                      
addpath('/Applications/Matlab_Packages/hex_and_rgb_v1.1.1')

% convert to RGB
cmap_red_hex = reshape(cmap_red_hex,[],1);  % reshape to Nx1 color array
cmap_blue_hex = reshape(cmap_blue_hex,[],1);
cmap_red_hex = convertStringsToChars(cmap_red_hex);
cmap_blue_hex = convertStringsToChars(cmap_blue_hex);  % convert string array to character array
cmap_red = hex2rgb(cmap_red_hex);  % convert hex colors to rgb colors
cmap_blue = hex2rgb(cmap_blue_hex);


