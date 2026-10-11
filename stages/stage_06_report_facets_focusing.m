% stage_06_report_facets_focusing.m - Pipeline stage. Run by run_inlet_design.m in the base workspace (shares its variables).
%  Facet lengths & shock focusing 
fprintf('\n=== Facet lengths & shock focusing ===\n');
for i = 1:n_oblique
    if geo.ramp_user(i),        tag = 'user';
    elseif i == 1,              tag = 'reference';
    elseif ~mixed && i == n_oblique, tag = 'solved: terminal shock foot on the cowl lip';
    else,                       tag = 'solved'; end
    fprintf('  Ramp facet %d length = %.6f  (%s)\n', i, geo.L(i), tag);
end
if mixed
    for j = 1:n_internal-1
        if geo.cowl_user(j), tag = 'user'; else, tag = 'solved'; end
        fprintf('  Cowl facet %d length = %.6f  (%s)\n', j, geo.Lc(j), tag);
    end
end
for i = 1:n_oblique
    fprintf('  External shock %d vs cowl lip : miss = %+.6f  (%s)\n', i, geo.miss_ext(i), focus_text(geo.miss_ext(i), 'ext'));
end
if mixed
    for j = 1:n_internal
        fprintf('  Internal shock %d vs shoulder : miss = %+.6f  (%s)\n', j, geo.miss_int(j), focus_text(geo.miss_int(j), 'int'));
    end
    delta_ext_deg = rad2deg(sum(sol.theta));
    delta_int_deg = delta_ext_deg - rad2deg(sum(sol_int.theta));
    fprintf('  Flow direction behind the external shocks = %.3f deg; behind the internal shocks (diffuser entry) = %.3f deg (0 = parallel to the x axis)\n', ...
        delta_ext_deg, delta_int_deg);
end
