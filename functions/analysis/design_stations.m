function st = design_stations(ctx, sol, sol_int, mixed, M1, p_inf, M_exit, pi_tot)
% Flow stations of the design point, straight from the Oswatitsch solutions.
    gam = ctx.gamma;
    M   = sol.M(:)';
    p0r = [1, cumprod(sol.pi_obl(:)')];
    if mixed
        M   = [M, sol_int.M(2:end)'];
        p0r = [p0r, p0r(end)*cumprod(sol_int.pi_obl(:)')];
        solT = sol_int;
    else
        solT = sol;
    end
    Mt  = solT.M_after_normal;
    p0t = p0r(end)*solT.pi_normal;
    [names, short] = station_names(ctx);
    st = make_station_struct(names, short, [M, Mt, M_exit], [p0r, p0t, pi_tot], M1, p_inf, gam);
    st.title = 'Design point';
end
