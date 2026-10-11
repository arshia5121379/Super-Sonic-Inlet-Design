% stage_12_offdesign_point.m - Pipeline stage. Run by run_inlet_design.m in the base workspace (shares its variables).
% ---- base condition used by the off-design point and by the sweeps ------------------------------
base = struct('M', M1, 'h', altitude, 'p', p_inf, 'alpha', 0);
if offdesign.enable
    base.M = offdesign.M;  base.h = offdesign.altitude;  base.p = isa_atmosphere(base.h);
end
if incidence.enable,  base.alpha = incidence.alpha_deg;  end

% ---- 2) + 3) off-design point (with / without incidence) ----------------------------------------
if offdesign.enable || incidence.enable
    Rod = inlet_eval(ctx, base.M, base.h, base.alpha);
    print_offdesign_report(ctx, Rod);
    if save_stations
        for ip = 1:numel(Rod.st)
            write_stations_csv(fullfile(out_dir, sprintf('stations_offdesign_%d.csv', ip)), Rod.st{ip});
        end
    end
    plot_station_graph(st_d, Rod.st, 'Off-design vs design - Mach, static and total pressure through the inlet');
    draw_regions(gin, ctx, geo, Rod.st{1}, 'Off-design - inlet regions (dashed = off-design shocks)', Rod.Pl{1}, Rod);
end
