function [tmax, btm] = max_deflection(M, gam)
% Maximum flow deflection of an attached oblique shock at Mach M, and the shock angle where it occurs.
    mu = asin(1/M);
    [btm, fv] = fminbnd(@(b) -theta_of_beta(M, b, gam), mu, pi/2, optimset('TolX', 1e-12));
    tmax = -fv;
end
