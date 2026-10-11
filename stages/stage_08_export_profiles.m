% stage_08_export_profiles.m - Pipeline stage. Run by run_inlet_design.m in the base workspace (shares its variables).
%  Export 
% Profile polylines (X Y Z, Z = 0) are ALWAYS written to the .txt files, in both 2D and 3D mode
export_profile_txt(fullfile(out_dir, ramp_file), scale_factor*geo.ramp_profile);
export_profile_txt(fullfile(out_dir, cowl_file), scale_factor*geo.cowl_profile);
export_profile_txt(fullfile(out_dir, diffuser_file), scale_factor*geo.diffuser_profile);
fprintf('\nExported profiles (X Y Z, Z = 0, scale factor = %g) to %s:\n  %s (%d pts), %s (%d pts), %s (%d pts)\n', ...
    scale_factor, out_dir, ramp_file, size(geo.ramp_profile,1), cowl_file, size(geo.cowl_profile,1), ...
    diffuser_file, size(geo.diffuser_profile,1));
