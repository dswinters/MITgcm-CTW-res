clear all, close all
base_dir = '../runs/';
addpath('../../../MITgcm/utils/matlab/');

oldpath = path();
addpath('../setup');
params = gendata_params();
f = params.f;
k = params.k;
om = params.om;
path(oldpath);
sum(sum(abs(dat.UVEL(:,yind,:)),3),2);
nk = length(k);
nf = length(om);

ke_end = nan(length(om),length(k));
for i = 1:nf
    for j = 1:nk

        froot = fullfile(base_dir,sprintf('run_om%0.8f_k%0.8f',om(i),k(j)));
        disp(froot)
        gridfile = fullfile(froot,'grid*');
        gridm = rdmnc(gridfile);
        xc2d = gridm.XC; xc = squeeze(xc2d(:,1)); nx = length(xc);
        xg2d = gridm.XG; xg = squeeze(xg2d(:,1)); Lx = max(xg);
        dxc2d = gridm.dxC; dxc = squeeze(dxc2d(:,1));
        dxg2d = gridm.dxG;  dxg = squeeze(dxg2d(:,1));
        yc2d = gridm.YC; yc = squeeze(yc2d(1,:)); ny = length(yc);
        yg2d = gridm.YG; yg = squeeze(yg2d(1,:)); Ly = max(yg);
        dyc2d = gridm.dyC; dyc = squeeze(dyc2d(1,:));
        dyg2d = gridm.dyG; dyg = squeeze(dyg2d(1,:));
        rc = gridm.RC; nz = length(rc);
        rf = gridm.RF;
        drc = gridm.drC;
        drf = gridm.drF;
        hfacc = squeeze(gridm.HFacC);
        hfacs = squeeze(gridm.HFacS);
        hfacw = squeeze(gridm.HFacW);
        raw = gridm.rAw;
        ras = gridm.rAs;
        rac = gridm.rA;
        raz = gridm.rAz;
        dpth = gridm.Depth;

        datT = rdmnc(fullfile(froot,'outs_sn.*'),'T','iter');
        datv = rdmnc(fullfile(froot,'outs_sn.*'),'VVEL',datT.iter(end));
        datu = rdmnc(fullfile(froot,'outs_sn.*'),'UVEL',datT.iter(end));
        %datw = rdmnc([froot 'outs_sn.*'],'VVEL',datT.iter(end)); % I don't think we write this! It's
        %probably not important though... and infact omitting w from the hydrostatic KE is consistent.

        % center u and v
        uC = 0.5*(datu.UVEL(2:end,:,:)+datu.UVEL(1:end-1,:,:));
        vC = 0.5*(datv.VVEL(:,2:end,:)+datv.VVEL(:,1:end-1,:));

        rho0 = 1000;

        ke = 0.5*rho0*(uC.^2 +  vC.^2);

        % you probably only need this once to figure out y0
        % figure;
        % set(gcf,'paperpositionmode','auto','color','w')
        % pcolor(xc,yc,dep); shading flat;
        % colorbar

        y0 = 3e5; % offshore distance to do the integral over [m]
        [~,indy] = min(abs(yc-y0));

        % initialize these
        vol = nan(size(hfacc));
        keA = nan(size(hfacc));

        for ii = 1:nz
            vol(:,:,ii) = rac.*drf(ii).*hfacc(:,:,ii);
            keA(:,:,ii) = ke(:,:,ii).*rac.*drf(ii).*hfacc(:,:,ii);
        end

        V = sum(sum(sum(vol(:,1:indy,:)))); % I integrated this
        keInt = sum(sum(sum(keA(:,1:indy,:))))/V/rho0;
        ke_end(i,j) = keInt;
    end
end

save('ke_end.mat','ke_end','k','om');
