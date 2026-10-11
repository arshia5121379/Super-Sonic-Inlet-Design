% stage_07_report_diffuser.m - Pipeline stage. Run by run_inlet_design.m in the base workspace (shares its variables).
%  Diffuser summary 
fprintf('\n=== Diffuser ===\n');
fprintf('  Throat height h_t (terminal shock length)    = %.6f\n', geo.h_throat);
fprintf('  Flow-normal throat height behind the shock   = %.6f   (shock %.3f deg off the normal to the flow)\n', geo.h_throat_flow, geo.phi_term_deg);
fprintf('  Mach after terminal shock = %.4f  ->  A/A* = %.5f\n', geo.M_throat, geo.AR_throat);
fprintf('  Exit Mach = %.4f  ->  A/A* = %.5f\n', M_exit, geo.AR_exit);
fprintf('  Exit height h_exit = %.6f  (A_exit/A_throat = %.5f)\n', geo.h_exit, geo.h_exit/geo.h_throat_flow);
fprintf('  P_ultimate (diffuser end): lower wall (%.6f, %.6f), cowl wall (%.6f, %.6f)\n', ...
    geo.P_ult(1,1), geo.P_ult(1,2), geo.P_ult(2,1), geo.P_ult(2,2));
if strcmpi(inlet_type, 'ramp'), thick_dir = 'downward (ramp: cowl lies below the ramp)';
else,                           thick_dir = 'upward (cone: cowl lies above the axis)'; end
fprintf('  Outer cowl wall: curvature at lip = %.5f (radius %s), angle at lip = %.3f deg, horizontal at exit plane\n', ...
    cowl_outer_curvature, radius_text(cowl_outer_curvature), cowl_upper_angle);
fprintf('  Diffuser wall curvature at throat: lower = %.5f (radius %s), upper = %.5f (radius %s); both reach zero at exit\n', ...
    diffuser.lower_curvature, radius_text(diffuser.lower_curvature), diffuser.upper_curvature, radius_text(diffuser.upper_curvature));
fprintf('  Diffuser wall start slope: ramp-side wall = %+.4f deg (%s; automatic %+.4f deg), cowl-side wall = %+.4f deg (%s; automatic %+.4f deg)\n', ...
    geo.lower_start_deg, ternary_text(geo.lower_start_user, 'user', 'automatic'), geo.lower_start_auto_deg, ...
    geo.upper_start_deg, ternary_text(geo.upper_start_user, 'user', 'automatic'), geo.upper_start_auto_deg);
fprintf('  Diffuser wall throat curvature: ramp-side wall = %.5f, cowl-side wall = %.5f  (inputs refer to the wall as drawn: lower = %s side)\n', ...
    geo.kR, geo.kC, ternary_text(strcmpi(inlet_type, 'ramp'), 'cowl', 'ramp'));
fprintf('  Cowl wall thickness: mean = %.6f (requested %.6f), at exit plane = %.6f, min = %.6f, max = %.6f\n', ...
    geo.t_mean, cowl_mean_thickness, geo.t_exit, geo.t_min, geo.t_max);
fprintf('    thickness grows %s\n', thick_dir);
fprintf('    inner end (%.6f, %.6f) -> outer end (%.6f, %.6f)\n', ...
    geo.P_ult(2,1), geo.P_ult(2,2), geo.P_outer(1), geo.P_outer(2));
fprintf('  Exit static pressure p_exit/p_inf = %.5f  (total pressure recovery %.5f)\n', ...
    geo.p_exit_ratio, geo.pi_d_total);
p0_inf   = p_inf * (1 + 0.5*(gamma-1)*M1^2)^(gamma/(gamma-1));      % freestream total pressure
p_exit   = geo.p_exit_ratio * p_inf;                                % static pressure at the diffuser end
p0_exit  = geo.pi_d_total * p0_inf;                                 % total pressure at the diffuser end
fprintf('  Flight altitude h = %.0f m (ISA): freestream p_inf = %.2f Pa, T_inf = %.2f K\n', altitude, p_inf, T_inf);
fprintf('  >>> Static pressure at diffuser exit  p_exit  = %.2f Pa  (%.4f bar)\n', p_exit, p_exit/1e5);
fprintf('      Total pressure at diffuser exit   p0_exit = %.2f Pa  (%.4f bar)\n', p0_exit, p0_exit/1e5);
print_friction_summary(geo);
