function run_sweeps(ctx, sweep, incidence, base, gin)
% Runs every requested sweep, prints the tables, draws the graphs and writes the CSV file.
    fprintf('\n=== Sweeps (base condition: M = %.4f, altitude = %.0f m (p = %.2f Pa), alpha = %+.3f deg) ===\n', base.M, base.h, base.p, base.alpha);
    SM = [];  SP = [];  SA = [];  MP = [];
    if sweep.mach || sweep.altitude
        Mvec = linspace(sweep.M_range(1), sweep.M_range(2), sweep.M_range(3));
        SM   = run_sweep(ctx, 'M', Mvec, base);
    end
    if sweep.mach
        print_sweep_table(SM, sprintf('Mach-number sweep (altitude = %.0f m, alpha = %+.2f deg)', base.h, base.alpha));
        plot_sweep_perf(ctx, SM, 'M', base);
        plot_sweep_stations(SM, 'M');
        if sweep.shock_plots, plot_sweep_shocks(ctx, gin, SM, 'M', sweep.shock_n); end
    end
    if sweep.altitude
        hvec = linspace(sweep.alt_range(1), sweep.alt_range(2), sweep.alt_range(3));
        SP   = run_sweep(ctx, 'h', hvec, base);
        print_sweep_table(SP, sprintf('Altitude sweep (M = %.3f, alpha = %+.2f deg)', base.M, base.alpha));
        if ctx.fric_on
            fprintf('  Note: A_c/A_cap and the shock pattern are independent of altitude; the diffuser friction (Reynolds number) makes pi_d and M_exit depend weakly on it.\n');
        else
            fprintf('  Note: pi_d, A_c/A_cap, shock pattern and all Mach numbers are independent of altitude; only the absolute pressures change with it.\n');
        end
        plot_sweep_pressure(ctx, SP, SM, base);
    end
    if sweep.alpha
        if incidence.enable
            avec = linspace(sweep.alpha_range(1), sweep.alpha_range(2), sweep.alpha_range(3));
            SA   = run_sweep(ctx, 'alpha', avec, base);
            print_sweep_table(SA, sprintf('Incidence sweep (M = %.3f, altitude = %.0f m)', base.M, base.h));
            plot_sweep_perf(ctx, SA, 'alpha', base);
            plot_sweep_stations(SA, 'alpha');
            if sweep.shock_plots, plot_sweep_shocks(ctx, gin, SA, 'alpha', sweep.shock_n); end
        else
            fprintf('  Incidence sweep skipped: incidence.enable = false.\n');
        end
    end
    if sweep.map && incidence.enable
        Mv = linspace(sweep.M_range(1),     sweep.M_range(2),     sweep.map_n(1));
        Av = linspace(sweep.alpha_range(1), sweep.alpha_range(2), sweep.map_n(2));
        MP = run_map(ctx, Mv, Av, base);
        plot_maps(ctx, MP);
    end
    if sweep.export_csv
        write_sweep_csv(sweep.csv_file, {SM, SP, SA, MP});
    end
end
