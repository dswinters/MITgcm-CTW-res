clear all, close all

% First get parameters
params = gendata_params();
f = params.f;
deltaT = params.deltaT;
p0 = params.p0;
p_yc = params.p_yc;
p_yl = params.p_yl;
n_periods = params.n_periods;
k = params.k;
om = params.om;
dx = params.dx;
dy = params.dy;

flags.write_k_dependent = true;
flags.write_om_dependent = true;

for i = 1:length(om) % forcing frequency index
    om_prefix = sprintf('om%0.8f_',om(i)); % File prefix for om
    flags.write_om_dependent = true;

    for j = 1:length(k) % k index
        k_prefix = sprintf('k%0.8f_',k(j)); % File prefix for k

        % Set up run and analysis directories for every run
        rname = sprintf('run_om%0.8f_k%0.8f',om(i),k(j));
        disp(rname)
        rdir = fullfile('..','runs',rname);
        if ~exist(rdir,'dir'); mkdir(rdir); end

        % Generate run data
        params = gendata(om(i), k(j), rdir, dx, dy, flags);

        % Template files have been set up with FIELD = PLACEHOLDER for fields that need
        % to be written. Make a cell array of substitutions with entries that
        % look like: {filename, {field1, string; ... fieldN, string}, prefix}
        other_subs = {};
        om_subs = {};
        k_subs = {};

        % Things we need to write once per domain length
        if flags.write_k_dependent
            k_subs = {
                '../code/templates/SIZE.h',...
                {'sNx', sprintf('%d', params.nxc);
                 'sNy', sprintf('%d', params.nyc);
                 'Nr', sprintf('%d', params.nzc)},...
                k_prefix;
                '../input/templates/data.obcs',...
                {'OB_Ieast', sprintf('%d*-1', params.nyc);
                 'OB_Iwest', sprintf('%d*1', params.nyc);
                 'OB_Jnorth', sprintf('%d*-1', params.nxc);
                 'OB_Jsouth', sprintf('%d*1', params.nxc)},...
                k_prefix
                     };
        end

        % Things we need to write once per forcing frequency
        if flags.write_om_dependent
            om_subs = {'../input/templates/data',...
                       {'deltaT', sprintf('%.1f',deltaT);
                        'nTimeSteps',  sprintf('%d',ceil(n_periods*2*pi/om(i)/deltaT));
                        'monitorFreq', sprintf('%.1f',2*pi/om(i)/4)},...
                       om_prefix;
                       '../input/templates/data.diagnostics',...
                       {'frequency(3)', sprintf('%.1f',2*pi/om(i)/4);
                        'timePhase(3)', sprintf('%.1f',2*pi/om(i)/4);
                        'frequency(4)', sprintf('%.1f',2*pi/om(i)/4);
                        'timePhase(4)', sprintf('%.1f',2*pi/om(i)/4)},...
                       om_prefix};
        end

        % Things we need to write per-simulation
        other_subs = {
            '../code/templates/exf_getffields.F',...
            {'om', sprintf('%0.8f',om(i));
             'p_k', sprintf('%0.8f',k(j));
             'p0', sprintf('%0.2f',10);
             'p_yc', sprintf('%0.2f',p_yc);
             'p_yl', sprintf('%0.2f',p_yl);
            },...
            [om_prefix, k_prefix]};

        substitutions = cat(1,k_subs,om_subs,other_subs);

        for nf = 1:size(substitutions,1)
            ftxt = fileread(substitutions{nf,1}); % load template file text
            for ns = 1:size(substitutions{nf,2},1)
                expr = sprintf('%s *= *PLACEHOLDER',substitutions{nf,2}{ns,1}); % create regexp

                % Need to escape parenthesis for regexp function
                expr = strrep(expr,'(','\(');
                expr = strrep(expr,')','\)');
                [i1,i2] = regexp(ftxt,expr,'start','end'); % find placeholder

                % update placeholder text with substitution text
                ftxt = cat(2, ...
                           ftxt(1:i1-1), ...
                           strrep(ftxt(i1:i2),'PLACEHOLDER',substitutions{nf,2}{ns,2}),...
                           ftxt(i2+1:end));
            end
            % Write new text to file named with prefix
            [fdir,fname,fext] = fileparts(substitutions{nf,1});
            dir_out = strrep(fdir,'templates','generated');
            newfile = fullfile(dir_out,sprintf('%s%s%s',substitutions{nf,3},fname,fext));
            fid = fopen(newfile,'w');
            fprintf(fid,'%s\n',ftxt);
            fclose(fid);
        end % substitutions in template files

        % run shell script to link files
        cmd=sprintf('./ctw_setup.sh %s %s %s',om_prefix,k_prefix,'--build');
        system(cmd);

        flags.write_om_dependent = false; % We've written data for this om
    end % loop over k

    flags.write_k_dependent = false; % We've looped over all k's once
end % loop over om
