function cmap = build_cmap( len_c )

cmap1 = pink(round(len_c/2));
cmap2 = bone(round(len_c/2));
cmap = vertcat(cmap1, flipud(cmap2));
