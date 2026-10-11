function print_audit(ctx, geo, st, sol, sol_int, mixed, inlet_type)
% Independent re-computation of the numbers behind the station map, using DIFFERENT formulas than the solver:
%   1) p0 ratio of every shock from the Rankine-Hugoniot static-pressure jump + isentropic relation
%   2) static pressure of every station from the cumulative static-pressure jumps (not from p0 and M)
%   3) mass-flow balance: captured flow (H_inf, M_inf) = flow ahead of the terminal shock (p0, M, flow-normal height)
%   4) diffuser exit: geometric exit height versus the continuity-consistent exit area, and p_exit
    gam = ctx.gamma;  kk = gam/(gam-1);  f = @(x) 1 + 0.5*(gam-1)*x.^2;
    if mixed, solT = sol_int; else, solT = sol; end
    tol = 1e-8;
    tag = @(e, t) ternary_text(e < t, 'OK', 'CHECK');
    fprintf('\n=== Calculation audit (independent re-computation) ===\n');

    Mi = sol.M(1:end-1)';  Mo = sol.M(2:end)';  be = sol.beta(:)';  pio = sol.pi_obl(:)';
    if mixed
        Mi = [Mi, sol_int.M(1:end-1)'];  Mo = [Mo, sol_int.M(2:end)'];
        be = [be, sol_int.beta(:)'];     pio = [pio, sol_int.pi_obl(:)'];
    end
    pj  = 1 + 2*gam/(gam+1)*((Mi.*sin(be)).^2 - 1);          % static-pressure jump of every oblique shock
    e1  = max(abs(pj.*(f(Mo)./f(Mi)).^kk - pio));
    fprintf('  1) p0 ratio of the %d oblique shock(s): max|difference| = %.2e   [%s]\n', numel(pio), e1, tag(e1, tol));

    Mb = solT.M(end);  Mt = solT.M_after_normal;
    if mixed || ctx.phi_t == 0, Mnt = Mb; else, Mnt = Mb*cos(ctx.phi_t); end
    pjt = 1 + 2*gam/(gam+1)*(Mnt^2 - 1);
    e2  = abs(pjt*(f(Mt)/f(Mb))^kk - solT.pi_normal);
    fprintf('     p0 ratio of the terminal shock (M_b = %.4f -> %.4f): |difference| = %.2e   [%s]\n', Mb, Mt, e2, tag(e2, tol));

    prc = cumprod([1, pj, pjt]);                             % p/p_inf of every station up to behind the terminal shock
    e3  = max(abs(prc - st.pr(1:end-1))./prc);
    fprintf('  2) static pressure of every station (jump route vs p0/M route): max rel. difference = %.2e   [%s]\n', e3, tag(e3, tol));

    foc = all(abs(geo.miss_ext) < 1e-6) && (~mixed || all(abs(geo.miss_int) < 1e-6));
    if strcmpi(inlet_type, 'ramp') && foc
        p0b    = st.p0r(end-2);                              % p0/p0_inf ahead of the terminal shock
        A_cont = geo.H_inf*mflow(ctx.M1, gam)/(p0b*mflow(Mb, gam));
        if mixed
            A_geo = geo.h_throat;                            % terminal shock exactly normal to the flow
        else
            d     = [cos(ctx.Phi0(end)), sin(ctx.Phi0(end))];
            r     = ctx.Xu - ctx.Pu(ctx.n,:);
            A_geo = abs(r(1)*d(2) - r(2)*d(1));              % lip -> last ramp facet line (flow-normal height)
        end
        e4 = abs(A_geo - A_cont)/A_cont;
        fprintf('  3) mass flow: flow-normal height ahead of the terminal shock, geometry %.6f vs continuity %.6f: rel. diff %.2e   [%s]\n', ...
            A_geo, A_cont, e4, tag(e4, 1e-6));
    else
        fprintf('  3) mass-flow balance skipped (needs a ramp inlet with all shocks focused; cone: the model uses planar shock relations).\n');
    end

    if strcmpi(inlet_type, 'ramp')
        e5 = abs(geo.h_exit/geo.H_inf - ctx.AeAc)/ctx.AeAc;
        fprintf('  4) diffuser exit: geometric h_exit/H_inf = %.6f vs continuity A_exit/A_cap = %.6f: rel. diff %.2e   [%s]\n', ...
            geo.h_exit/geo.H_inf, ctx.AeAc, e5, tag(e5, 1e-6));
    else
        fprintf('  4) diffuser exit: cone inlet - the drawn diffuser uses a 2-D height ratio, the annulus area is NOT matched;\n');
        fprintf('     the off-design solver uses the continuity area A_exit/A_cap = %.6f.\n', ctx.AeAc);
    end
    e6 = abs(st.pr(end) - geo.p_exit_ratio)/geo.p_exit_ratio;
    fprintf('     exit static pressure ratio, station table %.6f vs geometry routine %.6f: rel. diff %.2e   [%s]\n', ...
        st.pr(end), geo.p_exit_ratio, e6, tag(e6, tol));
    if ctx.fric_on
        fprintf('     (diffuser friction included: p0_exit/p0_diffuser-inlet = %.6f, see the friction summary)\n', ctx.fr_ratio_d);
    else
        fprintf('     (total pressure is constant through the diffuser: isentropic, no friction losses)\n');
    end
    if ~mixed && ctx.phi_t == 0 && geo.phi_term_deg > 0.05
        fprintf('  NOTE: the drawn terminal shock is %.2f deg off the normal to the flow, but the normal-shock model is used.\n', geo.phi_term_deg);
        [Mt2, pi2] = terminal_shock_relation(Mb, deg2rad(geo.phi_term_deg), gam);
        fprintf('        With terminal_shock_model = ''tilted'': M behind = %.4f (now %.4f), pi_d = %.6f (now %.6f).\n', ...
            Mt2, Mt, geo.pi_d_total*pi2/solT.pi_normal, geo.pi_d_total);
    end
end
