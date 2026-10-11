function print_stations(st, ttl)
% Table of Mach number, static and total pressure at every station.
    fprintf('\n%s\n', ttl);
    fprintf('  Freestream: M = %.4f, altitude = %.0f m, p = %.2f Pa, p0 = %.2f Pa\n', st.M0, st.alt_m, st.p_s, st.p0_inf);
    fprintf('  %-48s %8s %10s %10s %8s %12s %12s\n', 'Station', 'M', 'p0/p0inf', 'p/pinf', 'T/Tinf', 'p [Pa]', 'p0 [Pa]');
    for i = 1:numel(st.M)
        fprintf('  %-48s %8.4f %10.5f %10.5f %8.4f %12.2f %12.2f\n', st.names{i}, st.M(i), st.p0r(i), st.pr(i), ...
            st.Tr(i), st.p(i), st.p0(i));
    end
end
