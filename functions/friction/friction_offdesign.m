function F = friction_offdesign(ctx, M0, p_s, T_s, MFR, Mt, p0t)
% Diffuser friction for the FIXED hardware at any flight condition. The flow area entering the diffuser follows from
% continuity of the captured flow, the exit area is the fixed one (ctx.AeAc*A_cap) -> area ratio r; the same wall-shape
% function as in the design is marched from the Mach number behind the terminal shock. Returns the total-pressure ratio.
    gam = ctx.gamma;  kk = gam/(gam-1);
    fM  = @(x) 1 + 0.5*(gam-1)*x^2;
    F   = struct('ok', false, 'ratio', 1, 'M_end', NaN);
    p0_inf = p_s*fM(M0)^kk;  T0 = T_s*fM(M0);
    A1  = ctx.A_cap*MFR*mflow(M0, gam)/(p0t*mflow(Mt, gam));      % flow area behind the terminal shock [design units^2]
    if ~(isfinite(A1) && A1 > 0 && Mt < 1), return; end
    r   = ctx.AeAc*ctx.A_cap/A1;
    if ~(isfinite(r) && r > 0), return; end
    p01 = p0_inf*p0t;
    [Me, lnp, ~, ok] = fric_march(ctx.fp, Mt, p01, T0, A1*ctx.fp.lu^2, r, gam, false);
    if ok
        F.ok = true;  F.ratio = exp(lnp)/p01;  F.M_end = Me;
    end
end
