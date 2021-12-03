function [xb,yb,codeb,xn,yn,un,vn,u0pn,v0pn,u0rn,v0rn,wn,sn,pn] = getdata(dir,it,lev,pressure,a0)

% Modified by Thibault Flinois on 23 Jan 2013

% Reads the data file at istep=it, and returns:
%    xb,yb :     The x,y coordinates of each body/actuator point
%    codeb :     A number identifying the body to which belongs each body/actuator point
%    xn,yn :     Coordinates of each grid point (Cartesian grid)
%    un,vn :     Velocity components at each grid point (based on fluxes from code, which are evaluated at cell faces)
%    wn :        Vorticity at grid point (based on circulation from code, which is evaluated at cell vertices)
%    sn :        Streamfunction at each grid point
%    pn :        Pressure at each grid point
%    filename :  Full name and path of the file read
%
% Input parameters:
%    dir :       Directory where the file is located
%    it :        Number of the time step of the file: this identifies which file should be read
%    lev :       Grid level where data is required
%    pressure :  1 if pressure data is required, 0 if not
%
% Note: The "*.var" files read here have been written to Fortran's 
% unformatted format so in order for these (binary) files to be read, one 
% needs to read several Fortran markers, which are of no interest here.
%
% -------------------------------------------------------------------------
% home_dir = pwd;

% cd(dir)
% ---- Open file ----------------------------------------------------------
filename = [dir,'/ib' num2str(it,'%7.7i') '.var'];
fid = fopen(filename,'r');

% ---- Read first line of file --------------------------------------------
temp = fread(fid, 1, 'float32');      % Fortran marker
    m = fread(fid,1,'int');           % cells in x direction
    n = fread(fid,1,'int');           % cells in y direction
    mg = fread(fid,1,'int');          % total number of grid levels
    nb = fread(fid,1,'int');          % total number of body points
temp = fread(fid, 1, 'float32');      % Fortran marker


% ---- Read second line of file -------------------------------------------
temp = fread(fid, 1, 'float32');      % Fortran marker
    rey = fread(fid,1,'real*8' );     % Reynolds number
    dt = fread(fid,1,'real*8' );      % Size of time step
    len = fread(fid,1,'real*8' );     % Size of the smallest grid in the x direction
% Note: 'len' sets the size in the y direction too since the grid spacing is uniform
    offsetx = fread(fid,1,'real*8' ); % x-distance from lower-right corner smallest grid to origin
    offsety = fread(fid,1,'real*8' ); % y-distance of lower-right corner of smallest grid to origin
temp = fread(fid, 1, 'float32');      % Fortran marker


% ---- Compute grid related parameters ------------------------------------

% If we are not considering the smallest grid level, we need to compute the
% grid spacing and x and y offsets for the current grid level. 
%
% Note:  the cells in each grid level are twice as large in both directions
% as the ones of the previous grid level

fac = 2^(lev-1);                                        
delta = len ./ m *fac;                                  % Grid spacing in both directions for current grid
offx = 2^(lev-1) * len/2 - len/2 + offsetx;             % Offset in x direction for current grid
offy = 2^(lev-1) * (n*len/m)/2 - (n*len/m)/2 + offsety; % Offset in y direction for current grid

% ---- Read third line of file --------------------------------------------

temp = fread(fid, 1, 'float32');        % Fortran marker

% --> Vorticity
    % Read circulation at grid vertices, for each grid level, and output in (m-1)-by-(n-1) arrays 
    for i = 1:mg   
         omega(:,:,i) = transpose(reshape(fread(fid, (m-1)*(n-1), 'real*8'), m-1,n-1));
         disp(i)
    end
    omega = omega / delta.^2;           % Get the vorticity by dividing the circulation by the cell area
    
% --> Body coordinates and body velocity relative to the grid   
    xyb = fread(fid, 2*nb, 'real*8');   % Read x and y coordinates of each body point
    xb = xyb(1:nb);                     % Create x coordinates vector for body points
    yb = xyb(nb+1:2*nb);                % Create y coordinates vector for body points    
    vb = fread(fid, 2*nb, 'real*8');    % Read x and y components of velocity of each body point
    fb = fread(fid, 2*nb, 'real*8');    % Read x and y components of forces of each body point
    codeb = fread(fid, nb, 'int');   % Read body number corresponding to each body point    
    
% --> Internal Data (probably not useful here)    
    for i = 1:mg
        rhs_old = transpose(reshape(fread(fid, (m-1)*(n-1), 'real*8'), m-1,n-1));
    end
    
% --> Fluxes due to vorticity generated by the body
    % Read x and y components of the fluxes at grid faces, for each grid level, and output in (m+1)-by-(n+1) arrays
    for i = 1:mg                        
        q = fread(fid, (m+1)*(n)+(n+1)*(m), 'real*8');                              % Read fluxes at cell faces        
        qx(:,:,i) = transpose(reshape(q(1:(m+1)*(n)),m+1,n));                       % Put x-comp of fluxes in array
        qy(:,:,i) = transpose(reshape(q((m+1)*(n)+1:(m+1)*(n)+(n+1)*(m)),m,n+1));   % Put y-comp of fluxes in array
    end
    
% --> Fluxes due to potential flow (due to motion of the grid)
    % Read x and y components of the fluxes at grid faces, for each grid level, and output in (m+1)-by-(n+1) arrays
    for i = 1:mg
        q0p = fread(fid, (m+1)*(n)+(n+1)*(m), 'real*8');                             % Read fluxes at cell faces
        qx0p(:,:,i) = transpose(reshape(q0p(1:(m+1)*(n)),m+1,n));                     % Put x-comp of fluxes in array
        qy0p(:,:,i) = transpose(reshape(q0p((m+1)*(n)+1:(m+1)*(n)+(n+1)*(m)),m,n+1)); % Put y-comp of fluxes in array
    end

% --> Fluxes due to rotational flow (due to motion of the grid)
	% Read x and y components of the fluxes at grid faces, for each grid level, and output in (m+1)-by-(n+1) arrays
	for i = 1:mg
		q0r = fread(fid, (m+1)*(n)+(n+1)*(m), 'real*8');                             % Read fluxes at cell faces
		qx0r(:,:,i) = transpose(reshape(q0r(1:(m+1)*(n)),m+1,n));                     % Put x-comp of fluxes in array
		qy0r(:,:,i) = transpose(reshape(q0r((m+1)*(n)+1:(m+1)*(n)+(n+1)*(m)),m,n+1)); % Put y-comp of fluxes in array
	end
temp = fread(fid, 1, 'float32');      % Fortran marker


% ---- Read fourth line of file -------------------------------------------
temp = fread(fid, 1, 'float32');      % Fortran marker

% --> Streamfunction
    % Read streamfunction at grid vertices, for each grid level, and output in (m-1)-by-(n-1) arrays
    for i = 1:mg
        stream(:,:,i) = transpose(reshape(fread(fid, (m-1)*(n-1), 'real*8'), m-1,n-1));
    end
temp = fread(fid, 1, 'float32');      % Fortran marker

% ---- Read fifth line of file -------------------------------------------
temp = fread(fid, 1, 'float32');      % Fortran marker
	theta = fread(fid,1,'real*8' );   % rotating angle of the frame
	rox = fread(fid,1,'real*8' );     % x-coordinate of the center of rotation
	roy = fread(fid,1,'real*8' );     % y-coordinate of the center of rotation
temp = fread(fid, 1, 'float32');      % Fortran marker

% ---- Read sixth line of file -------------------------------------------
temp = fread(fid, 1, 'float32');      % Fortran marker
	u_ib = fread(fid,3*nb,'real*8' );   % rotating angle of the frame
	ud_ib = fread(fid,3*nb,'real*8' );     % x-coordinate of the center of rotation
	udd_ib = fread(fid,3*nb,'real*8' );     % y-coordinate of the center of rotation
temp = fread(fid, 1, 'float32');      % Fortran marker

% ---- Read sixth line of file -------------------------------------------
temp = fread(fid, 1, 'float32');      % Fortran marker
    f_rdst = fread(fid,2*nb,'real*8' );   % rotating angle of the frame
temp = fread(fid, 1, 'float32');      % Fortran marker


% ---- Done reading file --------------------------------------------------
fclose(fid);

% ---- Pressure Computations ----------------------------------------------
if(pressure == 1)
    
    % Open file
    filename = [dir '/pressure' num2str(it,'%7.7i') '.var'];
    fid = fopen(filename);
    
    % Read Data 
    temp = fread(fid, 1, 'float32');      % Fortran marker
    
% --> Pressure    
    % Read pressure at grid cell centres, for each grid level, and output in m-by-n arrays
    for i = 1:mg
        p(:,:,i) = transpose(reshape(fread(fid, (m)*(n), 'real*8'), m,n));
    end
    temp = fread(fid, 1, 'float32');      % Fortran marker
	
    % Done reading
	fclose(fid);
end

% ---- Combine q and q0 and convert to velocity  --------------------------

% Note:
% Total flux is q+q0 (q0 = q0p + q0r)
% Need to divide by cell face length 'delta' to convert to velocity

for i = 1:mg                                    
    u(:,:,i) = qx(:,:,i)./ delta ;               % x-velocity relative to the body
    u0p(:,:,i) = qx0p(:,:,i)./ delta ;             % x-velocity due to potential flow (due to motion of the grid)
    u0r(:,:,i) = qx0r(:,:,i)./ delta ;             % x-velocity due to rotational flow (due to motion of the grid)
    v(:,:,i) = qy(:,:,i)./ delta ;               % y-velocity relative to the body
    v0p(:,:,i) = qy0p(:,:,i)./ delta ;             % y-velocity due to potential flow (due to motion of the grid)
	v0r(:,:,i) = qy0r(:,:,i)./ delta ;             % y-velocity due to rotational flow (due to motion of the grid)
end

u0 = u0p + u0r; v0 = v0p + v0r;

s0(1,1) = ( -v0(1,1,lev)+u0(1,2,lev) )*delta;    % Compute streamfunction component due to potential flow (due to motion of the grid)
for j = 3:n
    s0(j-1,1) = s0(j-2,1) + u0(j-1,2,lev)*delta; % x-direction
end
for i = 3:m
    s0(:,i-1) = s0(:,i-2) - v0(2:n,i-1,lev)*delta; % y-direction
end


% ---- Interpolate all variables to the same grid -------------------------

% Note: All variables are interpolated to the cell vertices

% Create the grid that will be used for all variables
[xn, yn] = meshgrid(delta:delta:(m-1)*delta, delta:delta:(n-1)*delta);
xn = xn - offx;
yn = yn - offy;


% % % % %Identify the columns to keep (we want x >= 0.5)
% % % % ind_keep = ceil( (2.5 + 1) /delta );
% % % % 
% % % % xn(m/2, ind_keep : end)
% % % % yn(m/2, ind_keep : end)
% % % % 

% Grid for x-velocities (vertical cell faces)
[xu, yu] = meshgrid(0:delta:m*delta, delta/2:delta:(n-0.5)*delta); 
xu = xu - offx;
yu = yu - offy;

% Grid for y-velocities (horizontal cell faces)
[xv, yv] = meshgrid(delta/2:delta:(m-0.5)*delta, 0:delta:n*delta);    
xv = xv - offx;
yv = yv - offy;

% Grid for vorticity and streamfunction (cell vertices)
[xw, yw] = meshgrid(delta:delta:(m-1)*delta, delta:delta:(n-1)*delta); 
xw = xw - offx;
yw = yw - offy;

% Grid for Pressure (cell centres)
[xp yp]=meshgrid(delta:delta:m*delta, delta:delta:n*delta);
xp = xp - offx;
yp = yp - offy;

% Interpolate all variables accordingly to xn, yn
un = interp2(xu,yu,u(:,:,lev),xn,yn);
vn = interp2(xv,yv,v(:,:,lev),xn,yn);
u0pn = interp2(xu,yu,u0p(:,:,lev),xn,yn);
v0pn = interp2(xv,yv,v0p(:,:,lev),xn,yn);
u0rn = interp2(xu,yu,u0r(:,:,lev),xn,yn);
v0rn = interp2(xv,yv,v0r(:,:,lev),xn,yn);
wn = interp2(xw,yw,omega(:,:,lev),xn,yn);
sn = interp2(xw,yw,s0(:,:)+stream(:,:,lev),xn,yn);

if(pressure == 1)
    pn = interp2(xp,yp,p(:,:,lev),xn,yn);
else
    pn=0;
end

% ---- Rotate the grid and the bodies to the lab-frame --------------------
theta = -a0*pi/180; 
xnp = rox + (xn-rox)*cos(theta) - (yn-roy)*sin(theta);
ynp = roy + (xn-rox)*sin(theta) + (yn-roy)*cos(theta); 
xbp = rox + (xb-rox)*cos(theta) - (yb-roy)*sin(theta);
ybp = roy + (xb-rox)*sin(theta) + (yb-roy)*cos(theta);
xn = xnp; yn = ynp; xb = xbp; yb = ybp;

unp = un*cos(theta) - vn*sin(theta);
vnp = un*sin(theta) + vn*cos(theta); 
u0pnp = u0pn*cos(theta) - v0pn*sin(theta);
v0pnp = u0pn*sin(theta) + v0pn*cos(theta); 
u0rnp = u0rn*cos(theta) - v0rn*sin(theta);
v0rnp = u0rn*sin(theta) + v0rn*cos(theta);
un = unp; vn = vnp;
u0pn = u0pnp;
v0pn = v0pnp;
u0rn = u0rnp;
v0rn = v0rnp;

% cd(home_dir)

end

