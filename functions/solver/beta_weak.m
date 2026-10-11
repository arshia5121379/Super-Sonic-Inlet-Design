function [beta, ok, tmax] = beta_weak(M, theta, gam)
% Weak-branch shock angle for the flow deflection theta [rad]; ok = false if the shock is detached.
    beta = NaN;  ok = false;  tmax = NaN;
    if ~(M > 1), return; end
    mu = asin(1/M);
    [tmax, btm] = max_deflection(M, gam);
    if theta <= 0
        beta = mu;  ok = true;  return;            % no turning: Mach wave
    end
    if theta > tmax*(1 - 1e-12), return; end
    beta = fzero(@(b) theta_of_beta(M, b, gam) - theta, [mu, btm]);
    ok = true;
end
