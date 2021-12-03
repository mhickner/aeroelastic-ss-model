function [cmap_rgb] = get_cmap()

% reds, then blue/greens, then grays
cmap_hex = ["000000","d1a54d","f66928","b80046","000000","00e01e","00ADFF","4A44FF",...
"191716","191716","191716", "B492B2",...
"588979","acc892","a43d42","ff9d00"];

%   https://www.mathworks.com/matlabcentral/fileexchange/46289-rgb2hex-and-hex2rgb                      
addpath('/Applications/Matlab_Packages/hex_and_rgb_v1.1.1')

% convert to RGB
cmap_hex = reshape(cmap_hex,[],1);  % reshape to Nx1 color array
cmap_hex = convertStringsToChars(cmap_hex);  % convert string array to character array
cmap_rgb = hex2rgb(cmap_hex);  % convert hex colors to rgb colors


