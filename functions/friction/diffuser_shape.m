function [xi, sh, Lp] = diffuser_shape(gd, h_e)
% Normalised area distribution of the drawn diffuser: sh(0) = 0 (inlet), sh(1) = 1 (exit), xi = path coordinate along the
% centre line (0..1), Lp = centre-line length [design units]. A(xi) = A_in*(1 + (r-1)*sh(xi)).
    Nf = 241;
    extra  = h_e - (gd.yu_base - gd.yl_base);
    yl_end = gd.yl_base - gd.split*extra;
    yu_end = gd.yu_base + (1 - gd.split)*extra;
    [xl, yl] = smooth_wall(gd.Sp(1), gd.Sp(2), gd.mL, gd.x_e, yl_end, 0, gd.kL0, 0, Nf);
    [xu, yu] = smooth_wall(gd.Tp(1), gd.Tp(2), gd.mU, gd.x_e, yu_end, 0, gd.kU0, 0, Nf);
    xs  = linspace(max(gd.Sp(1), gd.Tp(1)), gd.x_e, Nf)';
    ylx = interp1(xl, yl, xs);  yux = interp1(xu, yu, xs);
    gap = yux - ylx;  yc = 0.5*(yux + ylx);
    ell = [0; cumsum(hypot(diff(xs), diff(yc)))];
    Lp  = ell(end);  xi = ell/Lp;
    dg  = gap(end) - gap(1);
    if abs(dg) < 1e-12*max(1, abs(gap(end)))
        sh = xi;                                      % degenerate (constant-area) walls: linear shape
    else
        sh = (gap - gap(1))/dg;
    end
end
