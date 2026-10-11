function S = run_sweep(ctx, kind, vals, base)
% kind: 'M' (Mach), 'h' (altitude [m]) or 'alpha' (incidence [deg]); other variables at the base values.
    nv = numel(vals);
    S.kind = kind;  S.vals = vals(:)';
    S.R = cell(1, nv);
    for i = 1:nv
        M0 = base.M;  h = base.h;  al = base.alpha;
        switch kind
            case 'M',     M0 = vals(i);
            case 'h',     h  = vals(i);
            case 'alpha', al = vals(i);
        end
        S.R{i} = inlet_eval(ctx, M0, h, al);
    end
    f = @(name) cellfun(@(r) r.(name), S.R);
    S.M0 = f('M0');  S.alt = f('alt');  S.p_s = f('p_s');  S.alpha = f('alpha_deg');
    S.pi_d = f('pi_d');  S.MFR = f('MFR');  S.M_b = f('M_b');  S.M_exit = f('M_exit');
    S.pr_exit = f('pr_exit');  S.p_exit = f('p_exit');  S.p0_exit = f('p0_exit');
    S.detached = logical(f('detached'));  S.choked = logical(f('choked'));  S.lip_ok = logical(f('lip_ok'));
    S.xi = f('xi');  S.lip_delta = f('lip_delta');  S.lip_tmax = f('lip_tmax');
    col = @(fun) cell2mat(cellfun(fun, S.R, 'UniformOutput', false));
    S.stM   = col(@(r) r.st{1}.M(:));        % [stations x points]
    S.stP   = col(@(r) r.st{1}.p(:));        % static pressure [Pa]
    S.stP0  = col(@(r) r.st{1}.p0(:));       % total pressure [Pa]
    S.stP0r = col(@(r) r.st{1}.p0r(:));      % p0/p0_inf
    S.beta  = col(@(r) r.beta_all(:));       % shock angles [rad]
    S.short = S.R{1}.st{1}.short;
end
