function [r, ok] = friction_find_r(fp, M_in, p01, T0, A1m, M_tar, gam, r0, wide)
% Exit/inlet area ratio r such that the marched exit Mach number equals M_tar (shooting; bracket scan + root solve).
    res = @(rr) fric_resid(fp, M_in, p01, T0, A1m, rr, M_tar, gam);
    r = NaN;  ok = false;
    for pass = 1:2
        if pass == 1 && ~wide
            g = r0*(1 + [-0.02 -0.005 0.005 0.02]);
        else
            g = r0*logspace(log10(0.15), log10(6), 36);
        end
        v = arrayfun(res, g);
        k = find(isfinite(v(1:end-1)) & isfinite(v(2:end)) & (v(1:end-1).*v(2:end) <= 0), 1, 'first');
        if isempty(k), continue; end
        try
            r = fzero(res, [g(k), g(k+1)], optimset('TolX', 1e-13));
        catch
            lo = g(k);  hi = g(k+1);  flo = v(k);              % bisection fallback (robust against NaN inside the bracket)
            for q = 1:80
                mid = 0.5*(lo + hi);  fm = res(mid);
                if ~isfinite(fm), hi = mid; continue; end
                if fm*flo <= 0, hi = mid; else, lo = mid; flo = fm; end
            end
            r = 0.5*(lo + hi);
        end
        ok = isfinite(r) && r > 0;
        if ok, return; end
    end
end
