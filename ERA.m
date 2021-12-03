function [Ar,Br,Cr] = ERA(Y,m,n,nin,nout,r)
% ERA for use with empirical theodorson 

% Y(i,j,k)::
% i refers to i-th output
% j refers to j-th input
% k refers to k-th timestep

% nin,nout number of inputs and outputs
% m,n dimensions of Hankel matrix
% r, dimensions of reduced model
 
assert(length(Y(:,1,1))==nout);
assert(length(Y(1,:,1))==nin);
assert(length(Y(1,1,:))>=m+n);

% Generate Hankel matrices
H = zeros(nout*m,nin*n);
H2 = zeros(nout*m,nin*n);
for i=1:m
    for j=1:n
        for Q=1:nout
            for P=1:nin
                H(nout*i-nout+Q,nin*j-nin+P) = Y(Q,P,i+j-1);
                H2(nout*i-nout+Q,nin*j-nin+P) = Y(Q,P,i+j);
            end
        end
    end
end

[U,S,V] = svd(H,'econ');
Sigma = S(1:r,1:r);
Ur = U(:,1:r);
Vr = V(:,1:r);

Ar = Sigma^(-.5)*Ur'*H2*Vr*Sigma^(-.5);
Br = Sigma^(.5)*Vr'*[eye(nin); zeros(m-nin,nin)];
Cr = [eye(nout) zeros(nout,n*nout-nout)]*Ur*Sigma^(.5);
% HSVs = diag(S);