function s = fric_local(x, M, lnp0, fp, A1m, r, T0, gam)
% Local flow state at path position x [m]: area, static T / p, Reynolds number and Darcy friction factor.
    Rg = 287.05287;
    Lm = fp.L*fp.lu;
    xq = min(max(x/Lm, 0), 1);
    sh  = interp1(fp.xi, fp.sh,  xq);
    dsh = interp1(fp.xi, fp.dsh, xq)/Lm;
    A   = A1m*(1 + (r-1)*sh);                         % flow area [m^2]
    dA  = A1m*(r-1)*dsh;                              % dA/dx [m]
    if ~(A > 0), error('fric:area', 'non-positive flow area'); end
    fM  = 1 + 0.5*(gam-1)*M^2;
    T   = T0/fM;
    p0  = exp(lnp0);
    p   = p0/fM^(gam/(gam-1));
    rho = p/(Rg*T);
    V   = M*sqrt(gam*Rg*T);
    mu  = 1.716e-5*(T/273.15)^1.5*(273.15 + 110.4)/(T + 110.4);       % Sutherland
    Dl  = fric_dh(A, fp);
    if strcmp(fp.re_dh, 'inlet'), Dre = fp.Dre; else, Dre = Dl; end
    Re  = rho*V*Dre/mu;
    f   = darcy_friction(Re, fp.eps/Dl, fp.model);
    if fp.corr, f = f*fM^(-0.47); end                 % compressibility correction
    s = struct('A', A, 'dA', dA, 'T', T, 'p0', p0, 'p', p, 'rho', rho, 'V', V, 'Dh', Dl, 'Re', Re, 'f', f);
end
