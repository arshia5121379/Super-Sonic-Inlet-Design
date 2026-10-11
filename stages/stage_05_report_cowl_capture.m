% stage_05_report_cowl_capture.m - Pipeline stage. Run by run_inlet_design.m in the base workspace (shares its variables).
%  Cowl / capture summary 
fprintf('\n=== Cowl lip & capture geometry ===\n');
fprintf('  Cowl lip (focus point)      : X = (%.6f, %.6f)\n', geo.X(1), geo.X(2));
fprintf('  H_inf (axis y=0 -> cowl lip): %.6f\n', geo.H_inf);
switch lower(inlet_type)
    case 'ramp'
        A_inlet = W * geo.H_inf;                   % rectangular capture area W x H_inf
        fprintf('  Ramp inlet (rectangular): W = %.6f, H = %.6f  ->  inlet area A = W*H = %.6f\n', ...
            W, geo.H_inf, A_inlet);
    case 'cone'
        A_inlet = pi * geo.H_inf^2;                % circular capture area, radius = axis -> lip
        fprintf('  Cone inlet (circular): R = %.6f (D = %.6f)  ->  inlet area A = pi*R^2 = %.6f\n', ...
            geo.H_inf, 2*geo.H_inf, A_inlet);
end
fprintf('  Cowl upper angle = %.3f deg, lower surface = %.3f deg, wedge angle = %.3f deg\n', ...
    cowl_upper_angle, geo.cowl_low_deg, geo.cowl_wedge_deg);
fprintf('  Terminal shock foot on ramp (shoulder) : (%.6f, %.6f)\n', geo.foot(1), geo.foot(2));
fprintf('  Terminal shock top on cowl             : (%.6f, %.6f)\n', geo.term_top(1), geo.term_top(2));
fprintf('  Last ramp facet length L_n  : %.6f\n', geo.L(end));
fprintf('  Terminal shock angle (from horizontal) = %.3f deg, length = %.6f\n', ...
    geo.term_angle_deg, geo.term_len);
fprintf('  Effective normal Mach at terminal shock = %.4f (design Mn = %.4f)\n', ...
    geo.Mn_eff, sol_T.Mn_target);
