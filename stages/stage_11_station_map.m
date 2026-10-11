% stage_11_station_map.m - Pipeline stage. Run by run_inlet_design.m in the base workspace (shares its variables).
% ---- 1) design-point flow stations -------------------------------------------------------------
if station_map
    print_stations(st_d, 'Design-point flow stations (alpha = 0)');
    if save_stations, write_stations_csv(fullfile(out_dir, 'stations_design.csv'), st_d); end
    plot_station_graph(st_d, {}, 'Design point - Mach, static and total pressure through the inlet');
    draw_regions(gin, ctx, geo, st_d, 'Design point - inlet regions', []);
end
