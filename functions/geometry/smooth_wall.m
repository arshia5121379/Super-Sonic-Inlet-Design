function [xs, ys] = smooth_wall(x0, y0, m0, x1, y1, m1, kappa0, kappa1, npts)
% Quintic curve y(x) from (x0,y0) to (x1,y1) with specified end slopes and
% specified signed curvatures kappa0/kappa1. Curvature convention:
%   kappa = -y''/(1+y'^2)^(3/2)
% This gives a C2-continuous wall when kappa is chosen to match the neighboring
% surface curvature. Setting kappa0 = kappa1 = 0 reproduces the original wall.
    D = x1 - x0;
    if ~(isfinite(D) && D > 0)
        error('smooth_wall requires x1 > x0.');
    end

    % Convert geometric curvature to y'' at each endpoint.
    ypp0 = -kappa0 * (1 + m0^2)^1.5;
    ypp1 = -kappa1 * (1 + m1^2)^1.5;

    % y = y0 + m0*s + 0.5*ypp0*s^2 + c3*s^3 + c4*s^4 + c5*s^5
    % Solve for c3..c5 from y, y', y'' at the downstream end.
    d = y1 - y0 - m0*D - 0.5*ypp0*D^2;
    e = m1 - m0 - ypp0*D;
    f = ypp1 - ypp0;
    A = [D^3,   D^4,    D^5;
         3*D^2, 4*D^3,  5*D^4;
         6*D,   12*D^2, 20*D^3];
    c = A \ [d; e; f];

    xs = linspace(x0, x1, npts)';
    s  = xs - x0;
    ys = y0 + m0*s + 0.5*ypp0*s.^2 + c(1)*s.^3 + c(2)*s.^4 + c(3)*s.^5;
end
