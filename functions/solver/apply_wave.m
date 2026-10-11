function [Mn, pn, beta, st, tmax] = apply_wave(M, p0r, delta, gam)
% Flow turning by delta [rad] at a corner, starting from Mach M and total-pressure ratio p0r.
%   delta > 0 : compression -> oblique shock, weak branch
%   delta < 0 : expansion   -> Prandtl-Meyer fan (isentropic)
% st =  0 attached oblique shock | 1 expansion fan | 2 no wave
%      -1 detached: the turn exceeds theta_max (bow shock modelled as a normal shock at M)
%      -2 attached shock but the flow behind it is subsonic
    beta = NaN;  tmax = NaN;
    if abs(delta) < 1e-9
        Mn = M;  pn = p0r;  st = 2;  return;
    end
    if delta < 0
        Mn = pm_inv(pm_nu(M, gam) + abs(delta), gam);
        pn = p0r;  st = 1;  return;
    end
    [b, ok, tmax] = beta_weak(M, delta, gam);
    if ~ok
        [Mn, pi_n] = normal_shock(M, gam);
        pn = p0r*pi_n;  st = -1;  return;
    end
    [~, M2, pi_o] = oblique_shock(M, b, gam);
    if ~isfinite(M2) || ~isfinite(pi_o)
        [Mn, pi_n] = normal_shock(M, gam);
        pn = p0r*pi_n;  st = -1;  return;
    end
    Mn = M2;  pn = p0r*pi_o;  beta = b;
    if M2 <= 1 + 1e-6, st = -2; else, st = 0; end
end
