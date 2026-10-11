function sol = oswatitsch_solver(M1, Mn_target, gamma, n_oblique)
% oswatitsch_solver
% This solver designs a multi-shock inlet using Oswatitsch equal-strength principle:
%   Mi sin(beta_i) = Mn*  for all oblique shocks
% with n_oblique oblique shocks followed by a terminal normal shock whose
% upstream Mach is specified as Mn_target.

if n_oblique < 1 || floor(n_oblique) ~= n_oblique
    error('n_oblique must be a positive integer.');
end

% ---- Find Mn* by 1D root solve on residual(M_last - Mn_target) ----
    resfun = @(Mn_star) residual_Mlast(Mn_star, M1, Mn_target, gamma, n_oblique);

% Bracket the root by scanning (robust, avoids bad initial guesses)
    Mn_min = 1.001;             % must be >1 for a shock
    Mn_max = min(2.5, M1-1e-3); % Mn* <= Mi; this is conservative upper
    grid = linspace(Mn_min, Mn_max, 400);
    rvals = nan(size(grid));
for k = 1:numel(grid)
        rvals(k) = resfun(grid(k));
end

% Find sign change for fzero
    idx = find(isfinite(rvals(1:end-1)) & isfinite(rvals(2:end)) & (rvals(1:end-1).*rvals(2:end) < 0), 1, 'first');
if ~isempty(idx)
        a = grid(idx);
        b = grid(idx+1);
        Mn_star = fzero(resfun, [a, b]);
else
% No sign change: the requested final Mach number cannot be reached with this many equal-strength
% shocks. The old fminsearch fallback returned an inconsistent (often NaN) system that crashed later in
% inlet_geometry, so stop here with an explanation of what IS reachable.
        Mlast_ok = rvals(isfinite(rvals)) + Mn_target;
        if isempty(Mlast_ok)
            error('oswatitsch_solver:infeasible', ...
                ['No attached oblique-shock system exists from M = %.4f with %d shock(s) (every trial Mn* is detached or ', ...
                 'subsonic behind the shock). Reduce the number of shocks or raise the entry Mach number.'], M1, n_oblique);
        end
        error('oswatitsch_solver:infeasible', ...
            ['Cannot reach M = %.4f from M = %.4f with %d equal-strength oblique shock(s): the final Mach number can only lie ', ...
             'between %.4f and %.4f. Change the target Mach number, the entry Mach number or the number of shocks.'], ...
            Mn_target, M1, n_oblique, min(Mlast_ok), max(Mlast_ok));
end

% ---- With Mn* found, compute full stage-by-stage solution ----
    [M, beta, theta, pi_obl] = forward_chain(Mn_star, M1, gamma, n_oblique);

% Terminal normal shock (given upstream Mach Mn_target)
    [M_after_normal, pi_normal] = normal_shock(Mn_target, gamma);

% Total inlet pressure recovery
    pi_d = prod(pi_obl) * pi_normal;

% Pack output
    sol = struct();
    sol.gamma = gamma;
    sol.M1 = M1;
    sol.n_oblique = n_oblique;
    sol.Mn_star = Mn_star;
    sol.Mn_target = Mn_target;
    sol.M = M;                % size n_oblique+1 : M1..M_last (before normal shock)
    sol.beta = beta;          % 1..n_oblique
    sol.theta = theta;        % 1..n_oblique
    sol.pi_obl = pi_obl;      % 1..n_oblique
    sol.M_after_normal = M_after_normal;
    sol.pi_normal = pi_normal;
    sol.pi_d = pi_d;
end
