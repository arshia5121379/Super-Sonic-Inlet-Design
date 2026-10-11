% stage_14_save_figures.m - Pipeline stage. Run by run_inlet_design.m in the base workspace (shares its variables).
%  ==========================================================================================
%  SAVE FIGURES AND CLOSE THE LOG
%  ==========================================================================================
if save_figures
    drawnow;
    save_all_figures(out_dir, figure_formats);
end
