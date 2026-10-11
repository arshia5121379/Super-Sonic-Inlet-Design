function r = residual_Mlast(Mn_star, M1, Mn_target, gamma, n_oblique)
% Returns M_last - Mn_target for a trial Mn_star.
% If infeasible (detached shock, invalid angles), return NaN.
    [M, ~, theta, ~] = forward_chain(Mn_star, M1, gamma, n_oblique);
if any(~isfinite(M)) || any(~isfinite(theta))
        r = NaN;
return;
end
    M_last = M(end);
    r = M_last - Mn_target;
end
