function [M_end, lnp0_end, prof, ok] = fric_march(fp, M1, p01, T0, A1m, r, gam, want_prof)
% Space march of y = [M; ln p0] over the diffuser (uniform grid, dx = L/(n-1)) with the method chosen in fp.method.
% ok = false if the Mach number reaches 1 (sonic singularity / choking), crosses 1, or the state becomes non-physical.
    n  = fp.n;  Lm = fp.L*fp.lu;  dx = Lm/(n-1);
    rhs = @(x, y) fric_rhs(x, y, fp, A1m, r, T0, gam);
    y   = [M1; log(p01)];
    sup = M1 > 1;
    ok  = true;  prof = [];  M_end = NaN;  lnp0_end = NaN;
    Y = zeros(2, n);  Y(:,1) = y;
    try
        for i = 1:n-1
            x = (i-1)*dx;
            switch fp.method
                case 'euler'
                    y = y + dx*rhs(x, y);
                case 'heun'
                    k1 = rhs(x, y);
                    yp = y + dx*k1;                                    % predictor
                    y  = y + 0.5*dx*(k1 + rhs(x + dx, yp));            % corrector
                case 'rk4'
                    k1 = rhs(x, y);
                    k2 = rhs(x + dx/2, y + k1*dx/2);
                    k3 = rhs(x + dx/2, y + k2*dx/2);
                    k4 = rhs(x + dx, y + k3*dx);
                    y  = y + (k1 + 2*k2 + 2*k3 + k4)/6*dx;
                case 'implicit'
                    y = fric_implicit_step(rhs, x, y, dx);
                otherwise
                    error('fric:method', 'unknown friction.method');
            end
            if ~all(isfinite(y)) || y(1) <= 0 || ((y(1) > 1) ~= sup) || abs(1 - y(1)^2) < 1e-4
                error('fric:cross', 'Mach number reached or crossed 1');
            end
            Y(:,i+1) = y;
        end
    catch
        ok = false;  return;
    end
    M_end = y(1);  lnp0_end = y(2);
    if want_prof
        prof = struct('x', ((0:n-1)*dx)', 'M', Y(1,:)', 'p0', exp(Y(2,:))');
        prof.p = zeros(n,1);  prof.T = prof.p;  prof.Re = prof.p;  prof.f = prof.p;  prof.A = prof.p;  prof.Dh = prof.p;
        for i = 1:n
            s = fric_local((i-1)*dx, Y(1,i), Y(2,i), fp, A1m, r, T0, gam);
            prof.p(i) = s.p;  prof.T(i) = s.T;  prof.Re(i) = s.Re;  prof.f(i) = s.f;  prof.A(i) = s.A;  prof.Dh(i) = s.Dh;
        end
    end
end
