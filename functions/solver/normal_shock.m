function [M2, p02_p01] = normal_shock(M1, gamma)
% normal_shock
% Returns downstream Mach M2 and stagnation pressure ratio p02/p01
% across a normal shock.

    if M1 <= 1
        M2 = NaN; p02_p01 = NaN; return;
    end

    % Downstream Mach
    M2_sq = (1 + 0.5*(gamma-1)*M1^2) / (gamma*M1^2 - 0.5*(gamma-1));
    M2 = sqrt(M2_sq);

    % Stagnation pressure ratio p02/p01
    term1 = ((gamma+1)*M1^2) / ((gamma-1)*M1^2 + 2);
    term2 = (gamma+1) / (2*gamma*M1^2 - (gamma-1));

    p02_p01 = term1^(gamma/(gamma-1)) * term2^(1/(gamma-1));
end
