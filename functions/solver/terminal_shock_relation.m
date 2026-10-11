function [Mt, pin, defl, ok] = terminal_shock_relation(Mb, phi, gam)
% Terminal shock at Mach Mb, tilted by phi [rad] from the normal to the flow (phi = 0: normal shock).
% Returns the Mach number behind it, the total-pressure ratio across it and the flow deflection [rad].
% ok = false (and the normal-shock result is returned) if the normal Mach component Mb*cos(phi) is <= 1.
    ok = true;  defl = 0;
    phi = abs(phi);
    if phi < 1e-12 || Mb*cos(phi) <= 1 + 1e-9
        ok = (phi < 1e-12);
        [Mt, pin] = normal_shock(Mb, gam);
        return;
    end
    beta = pi/2 - phi;                                % shock angle measured from the flow direction
    [defl, Mt, pin] = oblique_shock(Mb, beta, gam);   % oblique relations (the subsonic exit flag is irrelevant here)
    if ~(isfinite(Mt) && isfinite(pin))
        ok = false;
        [Mt, pin] = normal_shock(Mb, gam);  defl = 0;
    end
end
