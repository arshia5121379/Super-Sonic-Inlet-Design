function [p, T, rho, a] = isa_atmosphere(h)
% International Standard Atmosphere, geopotential altitude h [m] (scalar or array, -2000 ... 71000 m).
% Returns static pressure p [Pa], temperature T [K], density rho [kg/m^3] and speed of sound a [m/s].
    if ~(isnumeric(h) && all(isfinite(h(:))) && all(h(:) >= -2000) && all(h(:) <= 71000))
        error('Altitude must be numeric and between -2000 and 71000 m (ISA layers implemented up to 71 km).');
    end
    g0 = 9.80665;  Rg = 287.05287;
    hb = [0 11000 20000 32000 47000 51000 71000];                 % layer base altitudes [m]
    Lb = [-0.0065 0 0.0010 0.0028 0 -0.0028 -0.0020];            % lapse rates [K/m]
    Tb = zeros(1, 7);  pb = zeros(1, 7);  Tb(1) = 288.15;  pb(1) = 101325;
    for i = 2:7
        dh = hb(i) - hb(i-1);
        Tb(i) = Tb(i-1) + Lb(i-1)*dh;
        if abs(Lb(i-1)) < 1e-12
            pb(i) = pb(i-1)*exp(-g0*dh/(Rg*Tb(i-1)));
        else
            pb(i) = pb(i-1)*(Tb(i)/Tb(i-1))^(-g0/(Lb(i-1)*Rg));
        end
    end
    p = zeros(size(h));  T = zeros(size(h));
    for q = 1:numel(h)
        i = find(h(q) >= hb, 1, 'last');  if isempty(i), i = 1; end
        dh = h(q) - hb(i);
        T(q) = Tb(i) + Lb(i)*dh;
        if abs(Lb(i)) < 1e-12
            p(q) = pb(i)*exp(-g0*dh/(Rg*Tb(i)));
        else
            p(q) = pb(i)*(T(q)/Tb(i))^(-g0/(Lb(i)*Rg));
        end
    end
    rho = p./(Rg*T);
    a   = sqrt(1.4*Rg*T);
end
