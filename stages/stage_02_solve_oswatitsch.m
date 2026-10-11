% stage_02_solve_oswatitsch.m - Pipeline stage. Run by run_inlet_design.m in the base workspace (shares its variables).
%  Solve Oswatitsch inlet 
if mixed
    if ~(isscalar(n_internal) && n_internal >= 1 && n_internal == round(n_internal))
        error('n_internal must be a positive integer for mixed compression.');
    end
    if ~(M1 > M_int_in && M_int_in > Mn_target && Mn_target > 1)
        error(['Mixed compression needs M1 > M_int_in > Mn_target > 1 (now M1 = %.3f, M_int_in = %.3f, Mn_target = %.3f). ', ...
               'The external shocks take M1 down to M_int_in, the internal shocks take M_int_in down to Mn_target.'], ...
               M1, M_int_in, Mn_target);
    end
end
if ~mixed
    sol     = oswatitsch_solver(M1, Mn_target, gamma, n_oblique);
    sol_int = [];
else
    sol     = oswatitsch_solver(M1, M_int_in, gamma, n_oblique);          % external stage
    sol_int = oswatitsch_solver(M_int_in, Mn_target, gamma, n_internal);  % internal stage
end

%  Terminal-shock model (Mode 1) 
term_phi = 0;                                  % tilt of the terminal shock from the normal-to-flow direction [rad]
if ~mixed
    term_phi = abs(sum(sol.theta) - deg2rad(cowl_upper_angle - cowl_angle));
    if strcmpi(terminal_shock_model, 'tilted')
        [Mt_new, pi_new, ~, ok_new] = terminal_shock_relation(sol.M(end), term_phi, gamma);
        if ok_new
            sol.M_after_normal = Mt_new;
            sol.pi_normal      = pi_new;
            sol.pi_d           = prod(sol.pi_obl) * pi_new;
        else
            warning('Tilted terminal shock: normal Mach component <= 1, falling back to the normal-shock model.');
            term_phi = 0;
        end
    end
end
