function write_sweep_csv(file, list)
% Writes every sweep / map point to one CSV file.
    fid = fopen(file, 'wt');
    if fid < 0
        warning('Could not open %s for writing.', file);
        return;
    end
    fprintf(fid, 'sweep,M_inf,altitude_m,p_inf_Pa,alpha_deg,pi_d,MFR,M_ahead_of_terminal_shock,M_exit,p_exit_over_p_inf,p_exit_Pa,p0_exit_Pa,detached,exit_choked,cowl_lip_shock_attached,terminal_shock_regime\n');
    cnt = 0;
    for s = 1:numel(list)
        S = list{s};
        if isempty(S), continue; end
        for i = 1:numel(S.R)
            R = S.R{i};
            fprintf(fid, '%s,%.6f,%.2f,%.4f,%.4f,%.8f,%.8f,%.6f,%.6f,%.8f,%.4f,%.4f,%d,%d,%d,%s\n', S.kind, R.M0, R.alt, R.p_s, R.alpha_deg, ...
                R.pi_d, R.MFR, R.M_b, R.M_exit, R.pr_exit, R.p_exit, R.p0_exit, R.detached, R.choked, R.lip_ok, R.regime_short);
            cnt = cnt + 1;
        end
    end
    fclose(fid);
    fprintf('\nSweep results (%d points) written to %s\n', cnt, file);
end
