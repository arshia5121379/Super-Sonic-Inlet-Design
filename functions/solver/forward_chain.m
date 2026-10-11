function [M, beta, theta, pi_obl] = forward_chain(Mn_star, M1, gamma, n_oblique)
% Computes stages given Mn_star.
% M(1)=M1, M(2)=M2, ... M(n_oblique+1)=M_last.
    M = nan(n_oblique+1, 1);
    beta = nan(n_oblique, 1);
    theta = nan(n_oblique, 1);
    pi_obl = nan(n_oblique, 1);
    M(1) = M1;
for i = 1:n_oblique
        Mi = M(i);
% Feasibility: Mn_star must be <= Mi and > 1
if ~(Mn_star > 1.0 && Mn_star < Mi)
            M(:) = NaN; beta(:)=NaN; theta(:)=NaN; pi_obl(:)=NaN;
return;
end
% Oswatitsch condition => beta from Mn_star = Mi*sin(beta)
        beta_i = asin(Mn_star / Mi);
% Compute oblique shock outcome
        [theta_i, Mip1, pi_i, ok] = oblique_shock(Mi, beta_i, gamma);
if ~ok
            M(:) = NaN; beta(:)=NaN; theta(:)=NaN; pi_obl(:)=NaN;
return;
end
        beta(i) = beta_i;
        theta(i) = theta_i;
        M(i+1) = Mip1;
        pi_obl(i) = pi_i;
end
end
