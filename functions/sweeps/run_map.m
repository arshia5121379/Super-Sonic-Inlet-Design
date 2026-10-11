function MP = run_map(ctx, Mvec, Avec, base)
% Mach x incidence map (altitude fixed at base.h; ratios do not depend on it).
    nM = numel(Mvec);  nA = numel(Avec);
    MP.kind = 'map';  MP.Mvec = Mvec;  MP.Avec = Avec;
    MP.R = cell(1, nM*nA);
    MP.pi_d = nan(nA, nM);  MP.MFR = nan(nA, nM);  MP.M_exit = nan(nA, nM);  MP.pr_exit = nan(nA, nM);
    MP.detached = false(nA, nM);
    c = 0;
    for ia = 1:nA
        for im = 1:nM
            c = c + 1;
            R = inlet_eval(ctx, Mvec(im), base.h, Avec(ia));
            MP.R{c} = R;
            MP.pi_d(ia,im) = R.pi_d;  MP.MFR(ia,im) = R.MFR;  MP.M_exit(ia,im) = R.M_exit;
            MP.pr_exit(ia,im) = R.pr_exit;  MP.detached(ia,im) = R.detached;
        end
    end
end
