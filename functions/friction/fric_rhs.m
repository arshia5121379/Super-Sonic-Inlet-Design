function dy = fric_rhs(x, y, fp, A1m, r, T0, gam)
% dM/dx = F(x,M) = [0.5 g M^2 f/D - (1/A)dA/dx] * M [2+(g-1)M^2] / (2 (1-M^2));   d(ln p0)/dx = -0.5 g M^2 f/D
    M = y(1);
    if ~(isfinite(M) && isfinite(y(2))) || M <= 0
        error('fric:state', 'non-physical state');
    end
    d = 1 - M^2;
    if abs(d) < 1e-4
        error('fric:sonic', 'Mach number reached 1');
    end
    s  = fric_local(x, M, y(2), fp, A1m, r, T0, gam);
    fD = s.f/s.Dh;
    dy = [(0.5*gam*M^2*fD - s.dA/s.A)*M*(2 + (gam-1)*M^2)/(2*d);
          -0.5*gam*M^2*fD];
end
