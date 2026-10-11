function M = mach_from_mflow(f, gam)
% Subsonic Mach number for a given mass-flow function value (bisection; mflow increases on 0 < M < 1).
    lo = 1e-9;  hi = 1;
    for it = 1:100
        mid = 0.5*(lo + hi);
        if mflow(mid, gam) < f, lo = mid; else, hi = mid; end
    end
    M = 0.5*(lo + hi);
end
