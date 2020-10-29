function D1 = ddz(z,endvalues)
%%  Generate a first derivative matrix for independent variable z using
%   second order centered differences.  z is assumed to be evenly spaced
%   for j=1,N.
%
%   If endvalues = 0, the function is assumed to vanish at j=0 and j=N+1.
%   If endvalues ~=0, the function is not assumed to vanish, and backward
%      and forward differences are calculated.
%
%   Jim Lerczak, 1 Feb 2011


%  check for even spacing
if abs(std(diff(z))/mean(diff(z))) > 1e-6
    disp(['ddz:  values of z not evenly spaced!'])
    D1 = NaN ;
    return
end

del = mean(diff(z)) ;
N = length(z) ;
D1 = zeros(N,N) ;
for ii = 2:N-1
    D1(ii,ii-1) = -1 ;
    D1(ii,ii+1) = 1 ;
end
if endvalues == 0
    D1(1,2) = 1 ;
    D1(N,N-1) = -1 ;
else
    D1(1,1) = -3 ;
    D1(1,2) = 4 ;
    D1(1,3) = -1 ;
    D1(N,N) = 3 ;
    D1(N,N-1) = -4 ;
    D1(N,N-2) = 1 ;
end
D1 = D1/(2*del) ;


return

