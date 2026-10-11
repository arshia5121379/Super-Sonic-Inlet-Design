function chk = terminal_turning_limit_check(sol_T, geo, mixed)
% terminal_turning_limit_check
% Checks whether the local wall turning associated with the two endpoints of the
% calculated terminal shock can be supported by an attached oblique shock.
%
% The comparison is made with theta_max from the theta-beta-M relation at the
% Mach number immediately upstream of the terminal shock.
%
% MODE 1:
%   upstream flow is parallel to the last ramp facet (terminal-shock foot), while
%   the terminal-shock head is on the lower inner cowl surface. Therefore the
%   potentially limiting turn is the flow-to-cowl-surface angle.
%
% MODE 2:
%   upstream flow behind the last internal shock is parallel to the last cowl
%   facet (terminal-shock head), while the terminal-shock foot is at the ramp
%   shoulder. Therefore the potentially limiting turn is the flow-to-ramp angle.
%
% The geometry is read from the already-solved terminal-shock position, so the
% check does not alter the existing design solution.
    chk = struct('valid', false, 'M_upstream', NaN, ...
                 'flow_slope_deg', NaN, 'head_surface_slope_deg', NaN, ...
                 'foot_surface_slope_deg', NaN, 'head_turn_deg', NaN, ...
                 'foot_turn_deg', NaN, 'turn_required_deg', NaN, ...
                 'foot_wall_slope_deg', NaN, 'head_wall_slope_deg', NaN, ...
                 'theta_max_deg', NaN, 'beta_at_theta_max_deg', NaN, ...
                 'exceeds_theta_max', false);

    Mup = sol_T.M(end);
    chk.M_upstream = Mup;
    if ~(isfinite(Mup) && Mup > 1)
        return;
    end

    [theta_max, beta_at_max] = max_deflection(Mup, sol_T.gamma);
    chk.theta_max_deg = rad2deg(theta_max);
    chk.beta_at_theta_max_deg = rad2deg(beta_at_max);

    % Work in the frame where the ramp lies below the cowl and positive angles turn the same way as the ramp
    % (sgn = -1 for a planar ramp, +1 for a cone; the sign of the lip height gives it directly).
    sgn_geo = sign(geo.X(2));
    if sgn_geo == 0, sgn_geo = 1; end

    % Actual local surface slopes from the solved geometry.
    vfoot = geo.P(end,:) - geo.P(end-1,:);
    foot_slope = rad2deg(atan2(vfoot(2), vfoot(1)));          % last ramp facet (terminal-shock foot side)

    if mixed
        % The final cowl facet terminates at the terminal-shock head T.
        if size(geo.Q,1) < 2
            return;
        end
        vhead = geo.Q(end,:) - geo.Q(end-1,:);
        head_slope = rad2deg(atan2(vhead(2), vhead(1)));
        % Behind the last internal shock the flow is parallel to the final cowl facet.
        flow_slope = head_slope;
    else
        % In Mode 1 the lower inner cowl is the prescribed straight line from the lip and the flow behind the
        % ramp shocks is parallel to the last ramp facet.
        flow_slope = foot_slope;
        head_slope = sgn_geo * geo.cowl_low_deg;
    end

    chk.flow_slope_deg = flow_slope;
    chk.head_surface_slope_deg = head_slope;
    chk.foot_surface_slope_deg = foot_slope;

    % The wall that continues right after the final ramp / cowl facet (diffuser start slope, user controllable) is also
    % a surface at the foot / head of the terminal shock. With the automatic start slopes it equals the facet slope
    % (Mode 1) or the flow direction (Mode 2).
    foot_wall = foot_slope;  head_wall = head_slope;
    if isfield(geo, 'lower_start_actual_deg'), foot_wall = geo.lower_start_actual_deg; end
    if isfield(geo, 'upper_start_actual_deg'), head_wall = geo.upper_start_actual_deg; end
    chk.foot_wall_slope_deg = foot_wall;
    chk.head_wall_slope_deg = head_wall;

    % SIGNED compressive turning of the flow by each surface (working frame: ramp below, cowl above):
    %   foot (lower) wall : compression when the wall is steeper than the flow  -> wall - flow
    %   head (upper) wall : compression when the wall is flatter than the flow -> flow - wall
    % A negative value means the wall diverges from the flow (expansion): no oblique shock is needed there and
    % theta_max does not apply. The largest compressive turn among the facet and the following wall is kept.
    fw = sgn_geo*flow_slope;
    chk.foot_turn_deg = max(sgn_geo*foot_slope - fw, sgn_geo*foot_wall - fw);
    chk.head_turn_deg = max(fw - sgn_geo*head_slope, fw - sgn_geo*head_wall);
    chk.turn_required_deg = max([chk.head_turn_deg, chk.foot_turn_deg, 0]);
    chk.exceeds_theta_max = chk.turn_required_deg > chk.theta_max_deg + 1e-10;
    chk.valid = true;
end
