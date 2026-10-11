function R = inlet_eval(ctx, M0, h_m, alpha_deg)
% Evaluates the FIXED inlet at freestream Mach M0, flight altitude h_m [m, ISA] and incidence alpha_deg.
% Returns every station (Mach, static / total pressure), recovery, capture ratio, exit Mach and diagnostics.
    gam = ctx.gamma;
    [p_s, T_s] = isa_atmosphere(h_m);              % freestream static pressure [Pa] and temperature [K] at the altitude
    a   = deg2rad(alpha_deg);
    if ctx.cone && abs(a) > 1e-12
        a_list = [abs(a), -abs(a)];
        pnames = {'windward meridian', 'leeward meridian'};
    elseif ctx.cone
        a_list = 0;   pnames = {'axisymmetric (meridian plane)'};
    else
        a_list = a;   pnames = {'ramp (pitch plane)'};
    end
    np = numel(a_list);
    Pl = cell(1, np);
    hc = zeros(1, np);
    for i = 1:np
        Pl{i} = plane_chain(ctx, M0, a_list(i));
        hc(i) = Pl{i}.hc;
    end
    if ctx.cone, wgt = max(hc, 0).^2 + 1e-12; else, wgt = 1; end
    wn  = wgt/sum(wgt);
    MFR = mfr_from_hc(ctx, hc);
    p0t = sum(wn .* cellfun(@(q) q.p0_t, Pl));     % total-pressure ratio behind the terminal shock = pi_d
    p0b = sum(wn .* cellfun(@(q) q.p0_b, Pl));     % total-pressure ratio ahead of the terminal shock
    Mb  = sum(wn .* cellfun(@(q) q.M_b,  Pl));     % Mach number ahead of the terminal shock
    detached  = any(cellfun(@(q) q.detached, Pl));
    alive_all = all(cellfun(@(q) q.alive, Pl));
    interact  = any(cellfun(@(q) q.interact, Pl));

    % ---- diffuser exit: continuity with the fixed exit area; friction lowers p0 along the diffuser ----
    pi_front = p0t;                                % total-pressure ratio behind the terminal shock (diffuser inlet)
    fr_ratio = 1;  fr_fail = false;
    MFreq0   = MFR*mflow(M0, gam)/(pi_front*ctx.AeAc);
    if ctx.fric_on && alive_all && Mb > 1 && MFreq0 < mflow(1, gam)*(1 - 1e-9)
        Mt_avg = sum(wn .* cellfun(@(q) q.M_t, Pl));
        Fr = friction_offdesign(ctx, M0, p_s, T_s, MFR, Mt_avg, pi_front);
        if Fr.ok, fr_ratio = Fr.ratio; else, fr_fail = true; end
    end
    pi_d  = pi_front*fr_ratio;
    MFreq = MFR*mflow(M0, gam)/(pi_d*ctx.AeAc);    % required mass-flow function at the exit
    choked = ~(MFreq < mflow(1, gam)*(1 - 1e-9));
    if choked, M_e = 1; else, M_e = mach_from_mflow(MFreq, gam); end

    % ---- terminal-shock position indicator (flow area ahead of the shock vs. area of the throat plane) ----
    if alive_all && Mb > 1
        xi = (MFR*mflow(M0, gam)/(p0b*mflow(Mb, gam)))/ctx.AtAc;
        if abs(xi - 1) < 0.01
            regime = 'critical (shock at the throat plane)';  regime_short = 'critical';
        elseif xi < 1
            regime = 'supercritical (shock swallowed into the diffuser, higher shock Mach)';  regime_short = 'supercritical';
        else
            regime = 'subcritical (shock expelled, additional spillage)';  regime_short = 'subcritical';
        end
    else
        xi = NaN;  regime = 'n/a (detached shock / subsonic flow ahead of the terminal shock)';  regime_short = 'n/a';
    end

    % ---- mixed compression: can the internal contraction swallow a normal shock at its entry? (Kantrowitz-type check) ----
    % Mass flow the choked throat (fixed area ctx.AtAc, relative to the capture area) can pass behind a normal shock at the
    % internal entry (Mach Me, total pressure p0e after the external shocks), divided by the captured mass flow.
    % margin >= 1: the shock can be swallowed (inlet starts by itself); margin < 1: it needs overspeed, bleed or variable geometry.
    start_margin = NaN;
    if ctx.mixed && alive_all
        Me  = sum(wn .* cellfun(@(q) q.M(ctx.n+1),   Pl));     % Mach number entering the internal passage
        p0e = sum(wn .* cellfun(@(q) q.p0r(ctx.n+1), Pl));     % total-pressure ratio there
        if Me > 1
            [~, pin_e] = normal_shock(Me, gam);
            start_margin = ctx.AtAc*mflow(1, gam)*p0e*pin_e/(MFR*mflow(M0, gam));
        end
    end

    % ---- cowl lip: outer-surface shock attachment ----
    if ctx.cone, a_lip = abs(a); else, a_lip = a; end
    delta_lip = deg2rad(ctx.cowl_upper_deg) + a_lip;
    [~, lip_ok, lip_tmax] = beta_weak(M0, delta_lip, gam);

    % ---- stations ----
    [names, short] = station_names(ctx);
    R.st = cell(1, np);
    for i = 1:np
        Mv = [Pl{i}.M,   Pl{i}.M_t,  M_e];
        pv = [Pl{i}.p0r, Pl{i}.p0_t, pi_d];
        R.st{i} = make_station_struct(names, short, Mv, pv, M0, p_s, gam);
        R.st{i}.title     = pnames{i};
        R.st{i}.alpha_deg = alpha_deg;
        R.st{i}.alt_m     = h_m;
    end
    R.Pl = Pl;  R.pnames = pnames;
    R.M0 = M0;  R.p_s = p_s;  R.alpha_deg = alpha_deg;  R.alt = h_m;  R.T_s = T_s;
    R.pi_d = pi_d;  R.MFR = MFR;  R.M_b = Mb;  R.p0_b = p0b;
    R.pi_front = pi_front;  R.fric_ratio = fr_ratio;  R.fric_fail = fr_fail;
    R.M_exit = M_e;  R.choked = choked;  R.MFreq = MFreq;
    R.pr_exit = R.st{1}.pr(end);
    R.p_exit  = R.st{1}.p(end);
    R.p0_exit = R.st{1}.p0(end);
    R.detached = detached;  R.interact = interact;
    R.xi = xi;  R.regime = regime;  R.regime_short = regime_short;
    R.start_margin = start_margin;
    R.lip_delta = delta_lip;  R.lip_tmax = lip_tmax;  R.lip_ok = lip_ok;
    R.beta_all = Pl{1}.beta_all;                   % shock angles of the first plane [rad]
    R.beta1    = Pl{1}.beta_all(1);
end
