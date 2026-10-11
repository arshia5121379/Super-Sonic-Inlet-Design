% stage_16_finish.m - Pipeline stage. Run by run_inlet_design.m in the base workspace (shares its variables).
fprintf('\nDone. Results folder: %s\n', out_dir);
if save_log, diary off; end
