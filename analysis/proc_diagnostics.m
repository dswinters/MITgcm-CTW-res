clear all, close all
base_dir = '../runs/';
addpath('../setup');
params = gendata_params();

f = params.f;
k = params.k;
om = params.om;

nk = length(k);
nf = length(om);

ke_end = nan(length(om),length(k));
nt_end = zeros(length(om),length(k));
t_end = zeros(length(om),length(k));

for i = 1:nf
    for j = 1:nk
        stdout = fullfile(base_dir,sprintf('run_om%0.8f_k%0.8f',om(i),k(j)),'STDOUT.0000');
        fprintf('\r%s [%0.2f%%]',stdout,100 * (nk * (i-1) + j) / (nf*nk))
        if exist(stdout,'file')
            ftxt = fileread(stdout);

            % Parse ke_mean
            rx = 'ke_mean\s*=\s*(-?\d+\.\d+)E([-+]?\d+)';
            [flds, start] = regexp(ftxt,rx,'tokens','start');
            if length(start) > 0
                flds = cat(1,flds{:});
                n = reshape(sscanf(sprintf('%s*',flds{:}),'%f*'),size(flds));
                ke_mean = n(:,1) .* 10.^n(:,2);
                ke_end(i,j) = ke_mean(end);
                nt_end(i,j) = length(ke_mean);
            end
        end
    end
end
fprintf('\n')
save('ke_end.mat','ke_end','nt_end','k','om');
