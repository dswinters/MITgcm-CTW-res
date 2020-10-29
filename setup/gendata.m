function params = gendata(om, k, rdir, dx, dy, flags)

prec='real*4';
ieee='b';
fs = 14; fn = 'times';

% sponge cells on north boundary
nsponge = 15;

% Domain dimensions (m)
Lx = 2*pi/k;
Ly = 800e3;
Lz = 4e3;

% vertical grid, exponential high res near surface
nzc = 30;
mindz = 25; maxdz = 500;
dz = smooth([ones(1,floor(700/mindz))*mindz logspace(log10(mindz),log10(maxdz),nzc)],5)';
dz = smooth(dz,5)';
tmp = [cumsum(dz)];
ind = find(tmp<Lz);
dze = Lz-max(abs(tmp(ind)));  % make sure that depth is Lz (I am not totally sure this is ok)
dz = [dz(ind) dze];
zf = -[0 cumsum(dz)]; % this is RF
z = 0.5*(zf(1:end-1)+zf(2:end));
nzc = length(dz);

%% now stratification - from Jim's linear code
rho0 = 999.8; g = 9.81; alpha = 2e-4;

r1 = 992; r2 = 995;
r0 = (r1+r2)/2; dr = r2-r1;
N2back = (2*pi/(0.5*3600))^2;
mupyc = 400;
Zpyc = -400;
r = r2 - 0.5*dr*(1+tanh((z-Zpyc)/mupyc)) - z*N2back*r0/g;
n2 = 0.5*(dr/r0)*(g/mupyc)*sech((z-Zpyc)/mupyc).^2 + N2back;

t = (1-r/rho0)/alpha+5;

% x
nx = ceil(Lx/dx); % Approx how many dx fit into the domain
dx = Lx/nx; % scale dx so we have this many cells, but perfectly periodic


dx = dx*ones(1,floor(Lx/dx));
xg = [0 cumsum(dx)];
xc = 0.5*(xg(2:end)+xg(1:end-1));

% y
dy = dy*ones(1,floor(Ly/dy));
dy(end-nsponge+1:end) = dy(end-nsponge+1:end).*linspace(1,3,nsponge);
yg = [0 cumsum(dy)];
yc = 0.5*(yg(2:end)+yg(1:end-1));

nxc = length(xc); nyc = length(yc);
Lx = max(xc); Ly = max(yc);

% make topo, again from  Jim's linear code
hsh = 250; ysh = 75e3; dysl = 25e3;
prof = -hsh -0.5*(Lz-hsh)*(1+tanh((yc-ysh)/dysl));
prof(1) = 0; % vertical wall
PROF = repmat(prof,nxc,1);

%% strat done, grids done, topo done

% initial fields
T = permute(repmat(t',[1 nxc nyc]),[2 3 1]);

U = 0*T;
V = 0*T;

% boundary sponge region fields
Uzonal = zeros(nyc,nzc,2); % [ny nz nt]
Vzonal = zeros(nyc,nzc,2);
Tzonal = repmat(squeeze(T(1,:,:)),[1 1 2]);

Umerid = zeros(nxc,nzc,2); % [nz nx nt]
Vmerid = zeros(nxc,nzc,2);
Tmerid = repmat(squeeze(T(:,end,:)),[1 1 2]);

P = zeros(nxc,nyc,2);

% Written once (i.e. static across every simulation)
if flags.write_k_dependent & flags.write_om_dependent
    openfile =@(name) fopen(sprintf('../input/shared/%s.bin',name),'w',ieee);

    % dz and dy are independent of forcing frequency and alongshore length
    fid=openfile('delY');
    fwrite(fid,dy,prec);
    fclose(fid);

    fid=openfile('delZ');
    fwrite(fid,dz,prec);
    fclose(fid);

    % % zonal files only depend on Y
    % fid=openfile('Uzonal');
    % fwrite(fid,Uzonal,prec);
    % fclose(fid);

    % fid=openfile('Vzonal');
    % fwrite(fid,Vzonal,prec);
    % fclose(fid);

    % fid=openfile('Tzonal');
    % fwrite(fid,Tzonal,prec);
    % fclose(fid);

end

if flags.write_om_dependent
    openfile =@(name) fopen(sprintf('../input/generated/om%0.8f_%s.bin',om,name),'w',ieee);
end

if flags.write_k_dependent
    % Written once per om per k (i.e. depends on k, but not om)
    openfile =@(name) fopen(sprintf('../input/generated/k%0.8f_%s.bin',k,name),'w',ieee);

    % Anything depending on X depends on k
    fid=openfile('Uinit');
    fwrite(fid,U,prec);
    fclose(fid);

    fid=openfile('Vinit');
    fwrite(fid,V,prec);
    fclose(fid);

    fid=openfile('Tinit');
    fwrite(fid,T,prec);
    fclose(fid);

    fid=openfile('Umerid');
    fwrite(fid,Umerid,prec);
    fclose(fid);

    fid=openfile('Vmerid');
    fwrite(fid,Vmerid,prec);
    fclose(fid);

    fid=openfile('Tmerid');
    fwrite(fid,Tmerid,prec);
    fclose(fid);

    fid=openfile('delX');
    fwrite(fid,dx,prec);
    fclose(fid);

    fid=openfile('topog');
    fwrite(fid,PROF,prec);
    fclose(fid);

    fid=openfile('P');
    fwrite(fid,P,prec);
    fclose(fid);

end

% Everything else is specific to each run
openfile =@(name) fopen(sprintf('../runs/run_%k0.8f_om%0.8f/%s.bin',nTheta,nTopo,name),'w',ieee);
% nothing here

params.nxc = nxc;
params.nyc = nyc;
params.nzc = nzc;

return
% Make setup figure
fout = fullfile('figures',sprintf('setup_%s.png',rname));
print('-dpng',fout);
disp(['Saved ' fout])
