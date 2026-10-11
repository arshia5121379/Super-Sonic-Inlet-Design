function f = mflow(M, gam)
% Mass-flow function  m*sqrt(T0)/(p0*A) ~ M (1+(g-1)/2 M^2)^(-(g+1)/(2(g-1))).
    f = M .* (1 + 0.5*(gam-1)*M.^2) .^ (-(gam+1)/(2*(gam-1)));
end
