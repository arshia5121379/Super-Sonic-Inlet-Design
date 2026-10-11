% stage_01_output_directory.m - Pipeline stage. Run by run_inlet_design.m in the base workspace (shares its variables).
%  Create the output directory 
if ~((ischar(output_dir) || (isstring(output_dir) && isscalar(output_dir))) && strlength(string(output_dir)) > 0)
    error('output_dir must be a non-empty folder name.');
end
out_dir = char(output_dir);
if output_timestamp
    out_dir = fullfile(out_dir, datestr(now, 'yyyymmdd_HHMMSS'));
end
if ~exist(out_dir, 'dir')
    [ok_dir, msg_dir] = mkdir(out_dir);
    if ~ok_dir, error('Could not create the output directory %s: %s', out_dir, msg_dir); end
end
[~, finfo] = fileattrib(out_dir);
out_dir = finfo.Name;                                  % absolute path
if save_log
    log_file = fullfile(out_dir, 'run_log.txt');
    if exist(log_file, 'file'), delete(log_file); end
    diary(log_file);  diary on;
end
sweep.csv_file = fullfile(out_dir, sweep.csv_file);    % sweep CSV goes to the output directory too
fprintf('\nAll output files are written to: %s\n', out_dir);
if save_script_copy
    try
        % keep a copy of the whole code tree (driver + config + stages + functions) with the results
        code_dir = fullfile(out_dir, 'code_used');
        copyfile(fullfile(project_root, 'run_inlet_design.m'), fullfile(out_dir, 'run_inlet_design_used.m'));
        for d_ = {'config', 'stages', 'functions'}
            copyfile(fullfile(project_root, d_{1}), fullfile(code_dir, d_{1}));
        end
    catch
        warning('Could not copy the script into the output directory.');
    end
end
