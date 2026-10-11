% stage_15_terminal_shock_check.m - Pipeline stage. Run by run_inlet_design.m in the base workspace (shares its variables).
% Terminal-shock attached-oblique feasibility is checked after the terminal
% position has been solved (stage_04). The warning itself is printed here, at the end
% of the calculation, so it never interrupts the design workflow.
fprintf('\n=== Terminal shock attached-oblique feasibility check ===\n');
fprintf('  Mach immediately upstream of terminal shock = %.6f\n', terminal_check.M_upstream);
fprintf('  Terminal head surface slope = %+.6f deg; compressive flow turning = %+.6f deg (negative = diverging wall)\n', ...
    terminal_check.head_surface_slope_deg, terminal_check.head_turn_deg);
fprintf('  Terminal foot surface slope = %+.6f deg; compressive flow turning = %+.6f deg (negative = diverging wall)\n', ...
    terminal_check.foot_surface_slope_deg, terminal_check.foot_turn_deg);
fprintf('  Wall slope right after the final ramp: foot side (lower) = %+.6f deg, head side (upper) = %+.6f deg  (flow slope = %+.6f deg)\n', ...
    terminal_check.foot_wall_slope_deg, terminal_check.head_wall_slope_deg, terminal_check.flow_slope_deg);
fprintf('  Required terminal turning angle (max head/foot) = %.6f deg\n', terminal_check.turn_required_deg);
fprintf('  Theta_max for an attached oblique shock = %.6f deg (beta at theta_max = %.6f deg)\n', ...
    terminal_check.theta_max_deg, terminal_check.beta_at_theta_max_deg);
if terminal_check.valid
    if terminal_check.exceeds_theta_max
        if terminal_check.head_turn_deg > terminal_check.theta_max_deg && terminal_check.foot_turn_deg > terminal_check.theta_max_deg
            bad_location = 'both terminal-shock head and foot';
        elseif terminal_check.head_turn_deg > terminal_check.theta_max_deg
            bad_location = 'terminal-shock head';
        else
            bad_location = 'terminal-shock foot';
        end
        warning('terminalShock:thetaExceedsMax', ...
            ['The required wall turning at the %s is %.6f deg, exceeding the attached ', ...
             'oblique-shock limit theta_max = %.6f deg at M = %.6f. ', ...
             'An attached oblique terminal shock is therefore not possible at that surface slope; ', ...
             'a detached/lambda-type shock structure is possible.'], ...
            bad_location, terminal_check.turn_required_deg, terminal_check.theta_max_deg, terminal_check.M_upstream);
        fprintf('  WARNING: the required terminal turning exceeds theta_max at the %s; an attached oblique terminal shock is not possible there.\n', bad_location);
    else
        fprintf('  Result: required terminal turning is within the attached-oblique limit.\n');
    end
else
    warning('terminalShock:thetaCheckUnavailable', ...
        'Terminal-shock attached-oblique feasibility check could not be evaluated because the upstream terminal Mach number is not supersonic.');
    fprintf('  WARNING: theta_max check was not available because the upstream terminal Mach number is not supersonic.\n');
end
