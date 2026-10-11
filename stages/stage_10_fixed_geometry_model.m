% stage_10_fixed_geometry_model.m - Pipeline stage. Run by run_inlet_design.m in the base workspace (shares its variables).
%  ==========================================================================================
%  FLOW STATIONS, OFF-DESIGN, INCIDENCE AND SWEEPS (fixed geometry computed above)
%  ==========================================================================================
chk_analysis_inputs(offdesign, incidence, sweep);
ctx  = make_ctx(geo, sol, sol_int, mixed, flag, inlet_type, gamma, M1, M_exit, p_inf, cowl_upper_angle);
ctx.alt = altitude;
ctx.phi_t = 0;
if ~mixed && strcmpi(terminal_shock_model, 'tilted'), ctx.phi_t = term_phi; end
diffuser_fixed = diffuser;  diffuser_fixed.h_exit_fixed = geo.h_exit;   % redraws re-use the already sized diffuser (no new friction solve)
gin  = struct('sol', sol, 'flag', flag, 'cowl', cowl, 'sol_int', sol_int, 'diffuser', diffuser_fixed, 'lengths', lengths);
st_d = design_stations(ctx, sol, sol_int, mixed, M1, p_inf, M_exit, geo.pi_d_total);
st_d.alt_m = altitude;

fprintf('\n=== Fixed-geometry flow model (flow stations, off-design, incidence, sweeps) ===\n');
fprintf('  Design mass-flow capture ratio A_c/A_cap = %.6f  (1 when every external shock focuses on the lip)\n', ctx.MFR_d);
fprintf('  Diffuser-exit / capture area ratio, continuity-consistent = %.5f   (geometric h_exit/H_inf = %.5f)\n', ctx.AeAc, ctx.AeAc_geom);
fprintf('  Terminal-shock plane / capture area ratio                = %.5f\n', ctx.AtAc);
Rchk = inlet_eval(ctx, M1, altitude, 0);
fprintf('  Self-check (solver at the design condition): max|dM| = %.2e, max|d(p0/p0inf)| = %.2e\n', ...
    max(abs(Rchk.st{1}.M - st_d.M)), max(abs(Rchk.st{1}.p0r - st_d.p0r)));
if max(abs(Rchk.st{1}.M - st_d.M)) > 1e-6
    warning('Off-design solver does not reproduce the design point (check theta/beta feasibility).');
end
if mixed && isfinite(Rchk.start_margin)
    fprintf('  Start check (mixed compression): throat capacity behind a normal shock at the internal entry / captured flow = %.4f\n', Rchk.start_margin);
    if Rchk.start_margin >= 1
        fprintf('    >= 1: the internal contraction can swallow the shock (self-starting).\n');
    else
        fprintf('    < 1: the inlet does not self-start; it needs overspeed, bleed or variable geometry to reach the designed started state.\n');
    end
end
if run_audit
    print_audit(ctx, geo, st_d, sol, sol_int, mixed, inlet_type);
end
