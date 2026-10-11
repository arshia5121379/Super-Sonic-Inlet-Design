function print_offdesign_report(ctx, R)
% Console report of the off-design (and/or incidence) point.
    fprintf('\n=== Off-design analysis of the fixed inlet ===\n');
    fprintf('  Freestream: M = %.4f (design %.4f), altitude = %.0f m (design %.0f m), alpha = %+.3f deg\n', ...
        R.M0, ctx.M1, R.alt, ctx.alt, R.alpha_deg);
    fprintf('              p = %.2f Pa (design %.2f Pa), T = %.2f K\n', R.p_s, ctx.p_inf, R.T_s);
    for i = 1:numel(R.st)
        print_stations(R.st{i}, sprintf('Flow stations - %s', R.st{i}.title));
    end
    fprintf('\n  Performance                                        off-design      design\n');
    fprintf('    Total-pressure recovery  pi_d = p0_exit/p0_inf   : %10.5f  %10.5f\n', R.pi_d, ctx.pi_d_design);
    fprintf('    Mass-flow capture ratio  A_c/A_cap               : %10.5f  %10.5f\n', R.MFR, ctx.MFR_d);
    if ctx.fric_on
        fprintf('    Diffuser friction  p0_exit/p0_diffuser-inlet     : %10.5f  %10.5f\n', R.fric_ratio, ctx.fr_ratio_d);
    end
    fprintf('    Mach number ahead of the terminal shock          : %10.4f  %10.4f\n', R.M_b, ctx.Mb_d);
    fprintf('    Diffuser-exit Mach number (continuity)           : %10.4f  %10.4f\n', R.M_exit, ctx.M_exit);
    fprintf('    Exit static-pressure ratio p_exit/p_inf          : %10.5f  %10.5f\n', R.pr_exit, ctx.pr_exit_d);
    fprintf('    Exit static pressure p_exit  [Pa]                : %10.2f  %10.2f\n', R.p_exit, ctx.pr_exit_d*ctx.p_inf);
    fprintf('    Exit total  pressure p0_exit [Pa]                : %10.2f  %10.2f\n', R.p0_exit, ...
        ctx.pi_d_design*ctx.p_inf*(1 + 0.5*(ctx.gamma-1)*ctx.M1^2)^(ctx.gamma/(ctx.gamma-1)));
    fprintf('    Terminal-shock operation: %s', R.regime);
    if isfinite(R.xi), fprintf('   [flow area / throat-plane area = %.4f]', R.xi); end
    fprintf('\n');
    if ctx.mixed && isfinite(R.start_margin)
        fprintf('    Internal-contraction start margin (throat capacity / captured flow) : %.4f   (>= 1 self-starting, < 1 needs overspeed / bleed / variable geometry)\n', R.start_margin);
    end
    for i = 1:numel(R.Pl)
        P = R.Pl{i};
        if numel(R.Pl) > 1, fprintf('  --- %s ---\n', R.st{i}.title); end
        for k = 1:ctx.n
            if isfinite(P.miss_e(k))
                fprintf('    External shock %d: beta = %7.3f deg, miss vs cowl lip = %+.6f  (%s)\n', k, rad2deg(P.beta_e(k)), ...
                    P.miss_e(k), focus_text(P.miss_e(k), 'ext'));
            else
                fprintf('    External facet %d: no attached oblique shock\n', k);
            end
        end
        for j = 1:ctx.m
            if isfinite(P.miss_i(j))
                fprintf('    Internal shock %d: beta = %7.3f deg, miss vs shoulder = %+.6f  (%s)\n', j, rad2deg(P.beta_i(j)), ...
                    P.miss_i(j), focus_text(P.miss_i(j), 'int'));
            end
        end
        if P.r == 0
            fprintf('    The cowl lip sees the undisturbed freestream; capture height h_c = %.6f (design H_inf = %.6f)\n', P.hc, ctx.H_inf);
        else
            fprintf('    The cowl lip sits behind external shock %d; capture height h_c = %.6f (design H_inf = %.6f)\n', P.r, P.hc, ctx.H_inf);
        end
        if isfinite(P.Mn_eff) && ~ctx.mixed
            fprintf('    Effective normal Mach number of the (tilted) terminal shock = %.4f\n', P.Mn_eff);
        end
        if P.interact
            fprintf('    NOTE: a downstream shock passes outside the lip while an upstream one does not -> shocks merge ahead of the lip; capture ratio is a first-order estimate.\n');
        end
        if ctx.mixed && any(P.miss_e > ctx.tol)
            fprintf('    NOTE (mixed compression): an external shock passes inside the cowl lip and enters the internal passage, where it hits the cowl and interacts with the internal shocks; the internal-shock chain is then only a first-order estimate.\n');
        end
        if ~P.trace_ok
            fprintf('    NOTE: lip-streamline trace left the valid shock range; capture ratio is only approximate.\n');
        end
        Ls = offdesign_shock_lines(ctx, P);
        fprintf('    Off-design shock locations (drawing frame; foot = wall point the shock leaves, slope from horizontal):\n');
        for q = 1:numel(Ls)
            fprintf('      %-15s foot (%9.5f, %9.5f)  end (%9.5f, %9.5f)  slope = %7.3f deg\n', Ls(q).name, ...
                Ls(q).foot(1), Ls(q).foot(2), Ls(q).tip(1), Ls(q).tip(2), Ls(q).angle_deg);
        end
        if P.alive
            fprintf('      (terminal shock: critical position = throat plane of the fixed hardware; see the regime line above for where it would actually stand)\n');
        end
        for q = 1:numel(P.msgs), fprintf('    WARNING: %s\n', P.msgs{q}); end
    end
    if R.lip_ok
        fprintf('    Outer cowl-lip surface: flow turn %.2f deg <= theta_max = %.2f deg -> attached lip shock\n', ...
            rad2deg(R.lip_delta), rad2deg(R.lip_tmax));
    else
        fprintf('    WARNING: outer cowl-lip surface: flow turn %.2f deg > theta_max = %.2f deg -> detached shock on the cowl (spillage drag)\n', ...
            rad2deg(R.lip_delta), rad2deg(R.lip_tmax));
    end
    if R.choked
        fprintf('    WARNING: the fixed exit area cannot pass the captured flow (required mass-flow function %.4f > %.4f): exit choked, M_exit limited to 1.\n', ...
            R.MFreq, mflow(1, ctx.gamma));
    end
end
