% stage_04_build_geometry.m - Pipeline stage. Run by run_inlet_design.m in the base workspace (shares its variables).
%  Plot inlet geometry (ramp + shocks + cowl + diffuser) 
figure('Name','Inlet Geometry');
cowl     = struct('upper_angle_deg', cowl_upper_angle, ...
                  'angle_deg',       cowl_angle, ...
                  'curvature',       cowl_outer_curvature, ...
                  'mean_thickness',  cowl_mean_thickness);
diffuser = struct('M_exit', M_exit, 'length', diffuser_length, 'split', diffuser_split, ...
                  'lower_curvature', diffuser.lower_curvature, 'upper_curvature', diffuser.upper_curvature, ...
                  'lower_slope_deg', diffuser.lower_slope_deg, 'upper_slope_deg', diffuser.upper_slope_deg);
fric_in  = friction;  fric_in.p_inf = p_inf;  fric_in.T_inf = T_inf;  fric_in.W = W;
fric_in.model = lower(fric_in.model);  fric_in.method = lower(fric_in.method);  fric_in.re_dh = lower(fric_in.re_dh);
diffuser.fric = fric_in;               % friction inputs + design freestream (needed for Re) travel with the diffuser
lengths  = struct('ramp', ramp_lengths, 'cowl', cowl_lengths);
geo = inlet_geometry(sol, flag, cowl, sol_int, diffuser, lengths);
terminal_check = terminal_turning_limit_check(sol_T, geo, mixed);
if strcmpi(inlet_type, 'ramp'), inlet_label = 'Ramp'; else, inlet_label = 'Cone (meridian profile)'; end
if ~mixed
    title([inlet_label ' Inlet Geometry - Mode 1: external compression']);
else
    title([inlet_label ' Inlet Geometry - Mode 2: mixed compression']);
end
axis equal; grid on;
