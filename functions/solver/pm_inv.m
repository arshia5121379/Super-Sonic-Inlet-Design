function M = pm_inv(v, gam)
% Inverse Prandtl-Meyer function.
    hi = 1e6;
    if v >= pm_nu(hi, gam), M = hi; return; end    % vacuum limit
    M = fzero(@(x) pm_nu(x, gam) - v, [1, hi]);
end
