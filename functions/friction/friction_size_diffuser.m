function [h_e, F] = friction_size_diffuser(fo, gd, h_e0, h_flow, M_t, pi_front, H_inf, gam, M1, flag, M_exit)
% Sizes the diffuser exit height so that the friction ODE, marched along the diffuser, goes from the Mach number M_t behind
% the terminal shock to the given M_exit. The area distribution A(x) follows the drawn quintic walls (shape function), which in
% turn depend on h_e -> fixed-point iteration (converges in a few passes).
%   ramp (flag = 2): A = W*h,  inlet area A_in = W*h_flow (flow-normal throat height behind the terminal shock)
%   cone (flag = 1): circular relation; A_in from continuity of the captured flow (A_cap = pi*H_inf^2)
% Returns h_e and the friction solution F (F.ok = false -> fall back to the isentropic sizing h_e0).
    kk = gam/(gam-1);  fM = @(x) 1 + 0.5*(gam-1)*x.^2;
    lu = fo.length_unit_m;
    F  = struct('enable', true, 'ok', false, 'p0_ratio', 1);
    h_e = h_e0;
    if ~(M_t < 1 && M_exit < 1)
        warning('Diffuser friction skipped: the Mach number behind the terminal shock (%.3f) and the exit Mach (%.3f) must be subsonic.', M_t, M_exit);
        return;
    end
    p01 = fo.p_inf*fM(M1)^kk*pi_front;                % total pressure at the diffuser inlet [Pa]
    T0  = fo.T_inf*fM(M1);                            % total temperature [K] (adiabatic: constant)
    if flag == 2
        W = fo.W;  A_cap = W*H_inf;  A1 = W*h_flow;  Dre = 2*W*H_inf/(W + H_inf);
    else
        W = NaN;   A_cap = pi*H_inf^2;  A1 = A_cap*mflow(M1, gam)/(pi_front*mflow(M_t, gam));  Dre = 2*H_inf;
    end
    r = h_e0/h_flow;                                  % first guess: isentropic area ratio
    ok = false;  it = 0;
    for it = 1:15
        [xi, sh, Lp] = diffuser_shape(gd, h_e);
        fp = make_fric_params(fo, flag, W, xi, sh, Lp, Dre*lu);
        [r_new, ok] = friction_find_r(fp, M_t, p01, T0, A1*lu^2, M_exit, gam, r, it == 1);
        if ~ok, break; end
        h_new = r_new*h_flow;
        dh = abs(h_new - h_e)/abs(h_e);
        h_e = h_new;  r = r_new;
        if dh < 1e-10, break; end
    end
    if ~ok
        warning(['Diffuser friction: no exit area gives M_exit = %.3f from M = %.3f with this diffuser length / friction ', ...
                 '(flow would choke first). The diffuser is treated as isentropic.'], M_exit, M_t);
        h_e = h_e0;  return;
    end
    [Me, lnp, prof, ok] = fric_march(fp, M_t, p01, T0, A1*lu^2, r, gam, true);
    if ~ok, h_e = h_e0; return; end
    F.ok = true;  F.fp = fp;  F.A_cap = A_cap;  F.A1 = A1;  F.r = r;  F.iter = it;  F.L_m = fp.L*lu;
    F.p0_in = p01;  F.p0_out = exp(lnp);  F.p0_ratio = exp(lnp)/p01;
    F.M_in = M_t;  F.M_out = Me;  F.M_exit_given = M_exit;
    F.p_in = prof.p(1);  F.p_out = prof.p(end);
    F.p_out_isen = p01/fM(Me)^kk;                     % exit static pressure without friction at the same exit Mach number
    F.Re_in = prof.Re(1);  F.Re_out = prof.Re(end);  F.f_in = prof.f(1);  F.f_out = prof.f(end);
    F.prof = prof;
end
