clear all, close all

figure('position',[2436 875 1120 600])
% subplot(211)
dc = load('~/Work/MITgcm/Downloads/dispersionCurve.mat');
load('ke_end.mat')
leg = cell(length(om),1);
hline = [];

cols = [0 1 0; 1 0 0];

desc = fileread('../description.txt');
subplot(211)
pcolor(dc.L,dc.sigs,log10(dc.P0P)');
shading flat
colormap(cmocean('thermal'))
caxis([8 17])
% xlim([0 3.5]*1e-5)
hold on
% ylim([0 3]*dc.f)
xlabel('Wavenumber (m^{-1})')
ylabel('Frequency (rad s^{-1})')
title(desc)


% Plot slice on dispersion figure
subplot(211)
plot(k(:),om(:),'g.');
cols = get(gca,'colororder');

subplot(212)
yyaxis left

hline(1) = semilogy(k,ke_end(1,:),'-','linewidth',2,'color',cols(1,:));
ylabel('Final Domain-Averaged Kinetic Energy (J)')
hold on
yyaxis right
[~,idx] = min(abs(om-dc.sigs));
semilogy(dc.L,dc.P0P(:,idx),'--')
xlim(k([1 end]))
xlabel('Alongshelf Wavenumber (m^{-1})')

% hline(1) = semilogy(om,ke_end(:,1),'-','linewidth',2,'color',cols(1,:));
% ylabel('Final Domain-Averaged Kinetic Energy (J)')
% hold on
% yyaxis right
% [~,idx] = min(abs(k-dc.L));
% semilogy(dc.sigs,dc.P0P(idx,:),'--')
% xlim(om([1 end]))
% xlabel('Forcing Frequency (rad s^{-1})')

set(gca,'yscale','log')
grid on


print('-djpeg90','-r300','ke_final.jpg')
print('-djpeg90','-r300','~/Work/MITgcm/projects/ctw_res_forcing_ramp.jpg')
