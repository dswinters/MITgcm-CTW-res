clear all, close all

oldpath = path();
addpath('../setup');
params = gendata_params();
r_k = params.k;
r_om = params.om;
path(oldpath);

figure('position',[131 68 1020 560])
cm = cmocean('balance',101);

for r = 1:length(r_om)

    om = r_om(r);
    k = r_k(r);

    rname = sprintf('run_om%0.8f_k%0.8f',om,k);
    froot = fullfile('..','runs',rname);

    gridm = rdmnc(fullfile(froot, 'grid*'));

    datt = rdmnc(fullfile(froot,'outs_sn.*'),'T','iter');

    for i = length(datt.iter) % only read last timestep
        dat = rdmnc(fullfile(froot,'outs_sn.*'),'UVEL','VVEL','PHIHYD',datt.iter(i));
        yind = gridm.Y <= 2e5;
        ushelf = dat.UVEL(:,yind,:);
        vshelf = dat.VVEL(:,yind,:);
        uclim = 3.5*nanstd(ushelf(:));
        vclim = 3.5*nanstd(vshelf(:));
        [~,nx] = max(sum(sum(abs(ushelf),3),2));
        x0 = gridm.Xp1(nx);
        clf
        subplot(221)
        pcolor(gridm.Xp1,gridm.Y,squeeze(dat.UVEL(:,:,1))'); hold on
        colorbar
        shading flat
        colormap(gca,cm)
        plot(x0*[1 1],ylim,'k--')

        title('u (m/s)')
        caxis([-1 1]*uclim)
        xlabel('x (km)')
        set(gca,'xticklabel',get(gca,'xtick')/1000)
        ylabel('y (km)')
        set(gca,'yticklabel',get(gca,'ytick')/1000)

        subplot(222)
        pcolor(gridm.X,gridm.Yp1,squeeze(dat.VVEL(:,:,1))'); hold on
        colorbar
        shading flat
        colormap(gca,cm)
        plot(x0*[1 1],ylim,'k--')
        title('v (m/s)')
        caxis([-1 1]*vclim)
        xlabel('x (km)')
        set(gca,'xticklabel',get(gca,'xtick')/1000)
        ylabel('y (km)')
        set(gca,'yticklabel',get(gca,'ytick')/1000)

        subplot(223)
        pcolor(gridm.Y,gridm.Z,squeeze(dat.UVEL(nx,:,:))'); hold on
        colorbar
        shading flat
        colormap(gca,cm)
        plot(gridm.Y,-gridm.Depth(end,:),'k-');
        title('u (m/s)')
        caxis([-1 1]*uclim)
        xlabel('y (km)')
        set(gca,'xticklabel',get(gca,'xtick')/1000)
        ylabel('z (km)')
        set(gca,'yticklabel',get(gca,'ytick')/1000)

        subplot(224)
        pcolor(gridm.Yp1,gridm.Z,squeeze(dat.VVEL(nx,:,:))'); hold on
        colorbar
        shading flat
        colormap(gca,cm)
        plot(gridm.Y,-gridm.Depth(end,:),'k-');
        title('v (m/s)')
        caxis([-1 1]*vclim)
        xlabel('y (km)')
        set(gca,'xticklabel',get(gca,'xtick')/1000)
        ylabel('z (km)')
        set(gca,'yticklabel',get(gca,'ytick')/1000)

        ttxt = sprintf('om=%.4e, k=%.4e | T=%.1f cycles | [nx ny nz]=[%d %d %d]',...
                       om,k,datt.T(end)/(2*pi/om(r)),...
                       length(gridm.X),length(gridm.Y),length(gridm.Z));
        hax = axes('visible','off','position',[0 0 1 1]);
        xlim(hax,[-1 1]); ylim(hax,[-1 1]);
        text(hax,0,1,ttxt,...
             'fontweight','bold',...
             'verticalalignment','top',...
             'horizontalalignment','center');


        fout=sprintf('vel_final/vel_run_om%0.8f_k%0.8f.jpg',om,k);
        print('-djpeg90','-r300',fout)
        disp(['Saved ' fout])
    end
end
