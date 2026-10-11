function print_friction_summary(geo)
% Console summary of the diffuser friction solution (total / static pressure drop and exit pressures p_ext).
    F = geo.fric;
    fprintf('\n=== Diffuser friction (adiabatic flow with friction and area change) ===\n');
    if ~F.enable
        fprintf('  friction.enable = false: the diffuser is treated as isentropic (total pressure constant).\n');
        return;
    end
    if ~F.ok
        fprintf('  WARNING: the friction solution failed; the diffuser was treated as isentropic.\n');
        return;
    end
    fp = F.fp;
    fprintf('  Method: %s (%d grid points), friction factor: %s%s, roughness = %.3g m\n', fp.method, fp.n, fp.model, ...
        ternary_text(fp.corr, ' + compressibility correction', ''), fp.eps);
    fprintf('  Reynolds number based on the %s hydraulic diameter (capture-face D_h = %.5f m)\n', fp.re_dh, fp.Dre);
    fprintf('  Flow path length = %.5f m,  A_exit/A_in = %.5f  (exit height solved in %d iteration(s))\n', F.L_m, F.r, F.iter);
    fprintf('  Mach number : inlet = %.5f, exit = %.5f (given %.5f)\n', F.M_in, F.M_out, F.M_exit_given);
    fprintf('  Re : inlet = %.4g, exit = %.4g;   Darcy f : inlet = %.5f, exit = %.5f\n', F.Re_in, F.Re_out, F.f_in, F.f_out);
    fprintf('  TOTAL  pressure: p0_in = %.2f Pa, p0_ext = %.2f Pa, drop = %.2f Pa (%.4f %%),  p0_ext/p0_in = %.6f\n', ...
        F.p0_in, F.p0_out, F.p0_in - F.p0_out, 100*(1 - F.p0_ratio), F.p0_ratio);
    fprintf('  STATIC pressure: p_in = %.2f Pa, p_ext = %.2f Pa, drop (p_in - p_ext) = %+.2f Pa  (negative = static pressure rise)\n', ...
        F.p_in, F.p_out, F.p_in - F.p_out);
    fprintf('  Frictionless diffuser (same M_in, M_exit) would give p_ext = %.2f Pa -> friction costs %.2f Pa of static pressure\n', ...
        F.p_out_isen, F.p_out_isen - F.p_out);
    fprintf('  Total-pressure recovery of the whole inlet incl. diffuser friction: pi_d = %.8f (before friction: %.8f)\n', ...
        geo.pi_d_total, geo.pi_front);
end
