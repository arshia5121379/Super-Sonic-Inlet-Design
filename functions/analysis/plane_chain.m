function P = plane_chain(ctx, M0, a_eff)
% One flow plane through the fixed inlet: waves of the ramp (and internal cowl facets), terminal shock,
% shock-lip geometry and capture height.
%   a_eff : extra turning of the FIRST facet caused by incidence [rad] (freestream direction = -a_eff
%           in the frame in which the ramp rises)
    gam = ctx.gamma;  n = ctx.n;  m = ctx.m;  N = 1 + n + m;
    M = nan(1, N);  p0r = nan(1, N);
    M(1) = M0;  p0r(1) = 1;
    deltas = [ctx.theta, ctx.theta2];
    deltas(1) = deltas(1) + a_eff;
    beta_all = nan(1, n+m);
    st_all   = zeros(1, n+m);
    msgs = {};  alive = true;  detached = false;
    Mc = M0;  pc = 1;
    for k = 1:(n+m)
        if alive
            [Mn, pn, b, st, tmax] = apply_wave(Mc, pc, deltas(k), gam);
            st_all(k) = st;  beta_all(k) = b;
            if st == -1
                detached = true;  alive = false;
                msgs{end+1} = sprintf('%s: required turn %.2f deg > max attached turn %.2f deg at M = %.3f -> detached (bow) shock, modelled as a normal shock', ...
                    corner_label(k, n), rad2deg(deltas(k)), rad2deg(tmax), Mc);   %#ok<AGROW>
            elseif st == -2
                alive = false;
                msgs{end+1} = sprintf('%s: flow is subsonic behind the oblique shock (M = %.3f)', corner_label(k, n), Mn);   %#ok<AGROW>
            end
            Mc = Mn;  pc = pn;
        end
        M(k+1) = Mc;  p0r(k+1) = pc;
    end
    beta_e = beta_all(1:n);
    beta_i = beta_all(n+1:end);
    Mb = Mc;  pb = pc;
    % ---- terminal normal shock (critical position) ----
    if alive && Mb > 1
        [Mt, pin] = terminal_shock_relation(Mb, ctx.phi_t, gam);
    else
        Mt = Mb;  pin = 1;
    end
    pt = pb*pin;
    if ~alive
        Mn_eff = NaN;
    elseif ctx.mixed
        Mn_eff = Mb;
    else
        Mn_eff = Mb*cos(ctx.phi_dev);
    end

    % ---- absolute shock directions (frame in which the ramp rises) ----
    psi_e = nan(1, n);
    for k = 1:n
        if k == 1, ahead = -a_eff; else, ahead = ctx.Phi0(k); end
        psi_e(k) = ahead + beta_e(k);
    end
    delta_ext = ctx.Phi0(n+1);
    psi_i = nan(1, m);
    cum = 0;
    for j = 1:m
        psi_i(j) = delta_ext - cum - beta_i(j);
        cum = cum + ctx.theta2(j);
    end

    % ---- signed misses (same convention as the design: ext. > 0 shock passes on the flow-path side of the lip,
    %      < 0 on the outer side = spillage; int. > 0 reaches the ramp upstream of the shoulder) ----
    miss_e = nan(1, n);
    for k = 1:n
        if isfinite(psi_e(k))
            miss_e(k) = cross2([cos(psi_e(k)), sin(psi_e(k))], ctx.Xu - ctx.Pu(k,:));
        end
    end
    miss_i = nan(1, m);
    for j = 1:m
        if isfinite(psi_i(j))
            miss_i(j) = cross2([cos(psi_i(j)), sin(psi_i(j))], ctx.Su - ctx.Qu(j,:));
        end
    end
    % region the cowl lip sits in: lip is downstream of the first r shocks (r = 0: lip sees the freestream)
    r = 0;
    for k = 1:n
        if isfinite(miss_e(k)) && miss_e(k) < -ctx.tol, r = k; else, break; end
    end
    interact = false;                              % a later shock passes outside the lip while an earlier one does not
    if r+2 <= n
        interact = any(miss_e(r+2:n) < -ctx.tol);
    end

    % ---- capture height: trace the streamline that ends on the lip back to the freestream ----
    C = ctx.Xu;
    trace_ok = true;
    for q = r:-1:1
        dfl = [cos(ctx.Phi0(q+1)), sin(ctx.Phi0(q+1))];     % flow direction in the region behind shock q
        e   = [cos(psi_e(q)), sin(psi_e(q))];
        den = cross2(dfl, e);
        if abs(den) < 1e-12, trace_ok = false; break; end
        t = cross2(C - ctx.Pu(q,:), e)/den;
        if ~(t > 0), trace_ok = false; end
        C = C - t*dfl;
    end
    uinf = [cos(-a_eff), sin(-a_eff)];
    nrm  = [-uinf(2), uinf(1)];                    % normal to the freestream direction
    hc   = (C - ctx.Pu(1,:))*nrm';                 % height of the captured freestream tube (from the ramp-tip streamline)

    P = struct('M', M, 'p0r', p0r, 'beta_all', beta_all, 'beta_e', beta_e, 'beta_i', beta_i, 'st_all', st_all, ...
               'alive', alive, 'detached', detached, 'msgs', {msgs}, 'M_b', Mb, 'p0_b', pb, ...
               'M_t', Mt, 'p0_t', pt, 'Mn_eff', Mn_eff, 'psi_e', psi_e, 'psi_i', psi_i, ...
               'miss_e', miss_e, 'miss_i', miss_i, 'r', r, 'interact', interact, 'hc', hc, 'trace_ok', trace_ok);
end
