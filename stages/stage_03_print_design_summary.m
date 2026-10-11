% stage_03_print_design_summary.m - Pipeline stage. Run by run_inlet_design.m in the base workspace (shares its variables).
%  Print summary 
fprintf('\n=== Oswatitsch Supersonic Inlet Design ===\n');
if ~mixed
    fprintf('Mode 1: external compression (ramp + cowl lip + terminal shock + diffuser)\n');
    fprintf('Inputs: M1 = %.4f, gamma = %.4f, # oblique shocks = %d, Mn(target) = %.4f\n', ...
        M1, gamma, n_oblique, Mn_target);
    print_stage(sol, 'External oblique shocks');
    sol_T      = sol;                 % stage that feeds the terminal normal shock
    pi_d_total = sol.pi_d;
else
    fprintf('Mode 2: mixed compression (external ramps + internal cowl ramps + diffuser)\n');
    fprintf('Inputs: M1 = %.4f, gamma = %.4f, # external = %d, M(internal entry) = %.4f, # internal = %d, Mn(target) = %.4f\n', ...
        M1, gamma, n_oblique, M_int_in, n_internal, Mn_target);
    print_stage(sol,     'External oblique shocks');
    print_stage(sol_int, 'Internal oblique shocks (cowl side)');
    sol_T      = sol_int;
    pi_d_total = prod(sol.pi_obl) * sol_int.pi_d;
end

fprintf('\nTerminal normal shock:\n');
fprintf('  Mn (upstream) = %.6f\n', sol_T.Mn_target);
fprintf('  M_after_normal = %.6f\n', sol_T.M_after_normal);
fprintf('  pi_normal = %.8f\n', sol_T.pi_normal);
if ~mixed
    if strcmpi(terminal_shock_model, 'tilted') && term_phi > 0, Mn_comp = sol.M(end)*cos(term_phi); else, Mn_comp = sol.M(end); end
    fprintf('  Model: %s; the drawn shock is %.3f deg off the normal to the flow (normal Mach component %.4f)\n', ...
        terminal_shock_model, rad2deg(term_phi), Mn_comp);
end

fprintf('\nTotal inlet pressure recovery:\n');
fprintf('  pi_d = %.10f\n', pi_d_total);
