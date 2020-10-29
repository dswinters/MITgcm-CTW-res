function [modes, k, wt] = vmodes_w(z,n2,om,f)

% Function [modes, k, wt] = vmodes_w(z,n2,om,f) computes the orthonormal
% vertical modes associated with wave frequency om, planetary frequency f
% and stratification profile n2 (the squared brunt-vaisla frequency). Output
% is a matrix 'modes' (mxm) where columns are the vertical velocities
% associated with each mode, vector 'k' which are the eigenvalues
% (horizontal wavenumbers) for each mode, and the Sturm-Liouville weight
% function associated with the modes to ensure orthogonailty.
% 
% z and n2 should be 1 d arrays, and they should have the deepest value in the 
% first element.
%
% the code will give garbage if n2 becomes very small or zero

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Solves
% (-1/k^2)[w(k+1) - 2w(k) + w(k-1)] = [dz^2 (N(z)^2-om^2)/(om^2-f^2) w(k)]
% which is the discretized version of
% w(z)'' + k^2(N^2-om^2)/(om^2 - f^2) w = 0
% which arises for internal waves in variable stratification when
% solutions of the form
% [u,v,w] = [u'(z),v'(z),w'(z)] e^i(kx + ly - om*t)

% RM, March 2010
% RCM Sep 2018, fixed some niggling issues

% code wants things dimensioned like this
z = z(:)'; n2 = n2(:)'; 

Lz = max(abs(z));
dz = abs(z(2) - z(1));
nz = length(z);

a = diag(ones(nz-3,1),+1);
b = diag(-2*ones(nz-2,1),0);
c = diag(ones(nz-3,1),-1);
A = a+b+c;

d = diag(dz^2*(n2(2:end-1) - om^2)/(om^2 - f^2),0);
B = d;


[V,D] = eig(A,B);
%[V,D] = eig(A\B); % this gets the modes better,
% but the following code needs tweaking to get k

V = fliplr(V); % flip matricies so mode 1 is first mode
V = [zeros(1,nz-2); V; zeros(1,nz-2)];

wt = (n2 - om^2)/(om^2 - f^2); % sturm-liouville weight function for modes
WT = repmat(wt',1,nz-2);

A = repmat(trapz(z,WT.*V.^2,1),nz,1);
V = V./sqrt(A); % normalise modes to they're orthonormal

evals = diag(D);
evals = flipud(evals);
k = sqrt(-evals);

modes = V;
