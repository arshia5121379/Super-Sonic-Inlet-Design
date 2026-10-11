% cfg_07_output_options.m - Configuration block (user inputs). Run by run_inlet_design.m in the base workspace.
%  Export files 
ramp_file = 'inlet_ramp_profile.txt';       % polylines (X Y Z, Z = 0), written in both modes
cowl_file = 'inlet_cowl_profile.txt';
diffuser_file = 'inlet_diffuser_profile.txt';   % closed diffuser outline (lower wall, exit plane, cowl wall, terminal shock)
stl_files = {'inlet_ramp_body.stl', 'inlet_cowl_body.stl', 'inlet_diffuser_body.stl'};   % 3D mode

%  Output directory (ALL result files are written here) 
output_dir       = 'inlet_results';   % folder for every output file (created if missing). Relative paths are taken
                                      %   from the current folder; absolute paths are accepted as well.
output_timestamp = true;             % true -> create a new sub-folder <output_dir>/<yyyymmdd_HHMMSS> for every run
                                      %         (nothing is overwritten); false -> reuse / overwrite <output_dir>
save_figures     = true;              % save every figure that was drawn
figure_formats   = {'png', 'fig'};    %   any of 'png' 'fig' 'pdf' 'jpg'
save_stations    = true;              % write the flow-station tables (Mach, static / total pressure) to CSV
save_log         = true;              % write the whole console output to run_log.txt
save_script_copy = true;              % keep a copy of this script with the results (reproducibility)
