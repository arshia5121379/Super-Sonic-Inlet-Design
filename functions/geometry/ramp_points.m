function P = ramp_points(L1, Lrest, n, Phi0, sgn)
% Ramp corner points for facet lengths [L1, Lrest]
    Lv = [L1, Lrest(:)'];
    P = zeros(n+1, 2);
    for kk = 1:n
        angk = sgn*Phi0(kk+1);
        P(kk+1,:) = P(kk,:) + Lv(kk)*[cos(angk), sin(angk)];
    end
end
