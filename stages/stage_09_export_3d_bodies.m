% stage_09_export_3d_bodies.m - Pipeline stage. Run by run_inlet_design.m in the base workspace (shares its variables).
if strcmpi(output_mode, '2D')
    % 2D mode: nothing more to export (polylines already written above)
else
    % 3D: ramp -> extrude the profiles along z (0..W); cone -> revolve them about the x axis
    profiles = {scale_factor*geo.ramp_profile, scale_factor*geo.cowl_profile, scale_factor*geo.diffuser_profile};
    W_out    = scale_factor * W;              % scaled spanwise extrusion length (ramp)
    bodies   = cell(1, 3);
    for k = 1:3
        if strcmpi(inlet_type, 'ramp')
            [Fk, Vk] = extrude_profile(profiles{k}, W_out);
        else
            [Fk, Vk] = revolve_profile(profiles{k}, n_revolve);
        end
        bodies{k} = struct('F', Fk, 'V', Vk);
        write_stl(fullfile(out_dir, stl_files{k}), Fk, Vk, sprintf('inlet_body_%d', k));
    end
    if strcmpi(inlet_type, 'ramp')
        fprintf('\n3D export (ramp extruded in z, 0..%.4f, scale factor = %g):\n', W_out, scale_factor);
    else
        fprintf('\n3D export (cone revolved 360 deg about the x axis, %d segments, scale factor = %g):\n', ...
            n_revolve, scale_factor);
    end
    for k = 1:3
        fprintf('  %s (%d triangles)\n', stl_files{k}, size(bodies{k}.F, 1));
    end
    % 3D view: ramp (with lower diffuser wall) and cowl (with cowl-side diffuser wall)
    plot_inlet_3d(bodies(1:2), {[0.20 0.45 0.80], [0.55 0.55 0.55]}, [1.0 0.55], ...
        sprintf('%s inlet - 3D view', [upper(inlet_type(1)) lower(inlet_type(2:end))]));
end
