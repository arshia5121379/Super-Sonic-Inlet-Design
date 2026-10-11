function [theta, M2, p02_p01, ok] = oblique_shock(M1, beta, gamma)
% oblique_shock
% Given upstream Mach M1 and shock angle beta (rad), compute:
%   theta      flow deflection angle (rad)
%   M2         downstream Mach
%   p02_p01    stagnation pressure ratio across the oblique shock


    ok = true;

    % Basic checks
    if ~(M1 > 1 && beta > 0 && beta < pi/2)
        theta = NaN; M2 = NaN; p02_p01 = NaN; ok = false; return;
    end

    Mn1 = M1 * sin(beta);
    if Mn1 <= 1
        theta = NaN; M2 = NaN; p02_p01 = NaN; ok = false; return;
    end

    % Theta-beta-M relation (weak shock branch assumed by our beta choice)
    num = 2 * cot(beta) * (M1^2 * sin(beta)^2 - 1);
    den = M1^2 * (gamma + cos(2*beta)) + 2;
    theta = atan(num / den);

    % If theta negative or too large, likely invalid
    if ~isfinite(theta) || theta <= 0
        theta = NaN; M2 = NaN; p02_p01 = NaN; ok = false; return;
    end

    % Downstream normal Mach from normal shock relation
    Mn2_sq = (1 + 0.5*(gamma-1)*Mn1^2) / (gamma*Mn1^2 - 0.5*(gamma-1));
    if Mn2_sq <= 0
        theta = NaN; M2 = NaN; p02_p01 = NaN; ok = false; return;
    end
    Mn2 = sqrt(Mn2_sq);

    % Convert back to full Mach using flow angle change across oblique shock
    denom = sin(beta - theta);
    if denom <= 0
        theta = NaN; M2 = NaN; p02_p01 = NaN; ok = false; return;
    end
    M2 = Mn2 / denom;

    % Stagnation pressure ratio equals that of a normal shock at Mn1
    [~, p02_p01] = normal_shock(Mn1, gamma);

    if ~isfinite(M2) || M2 <= 1
        % M2 can still be supersonic after oblique shocks; that's fine.
        % But if it becomes non-physical, flag it.
        ok = false;
    end
end
