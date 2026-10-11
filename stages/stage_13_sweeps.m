% stage_13_sweeps.m - Pipeline stage. Run by run_inlet_design.m in the base workspace (shares its variables).
% ---- sweeps ---------------------------------------------------------------------------------------
if sweep.enable
    run_sweeps(ctx, sweep, incidence, base, gin);
end
