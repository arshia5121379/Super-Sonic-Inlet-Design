% cfg_04_diffuser_and_flight.m - Configuration block (user inputs). Run by run_inlet_design.m in the base workspace.
%  Diffuser (subsonic, after the terminal shock) 
M_exit          = 0.5;   % design Mach at the diffuser exit (engine face)
diffuser_length = 5.0;   % streamwise (x) length of the diffuser (arb. units)
diffuser_split  = 0.7;   % share of the area growth taken by the lower wall (0..1); rest by the cowl wall
% Diffuser wall curvature at the THROAT / diffuser inlet [1/design-length].
% Same signed convention used for the outer cowl: kappa = -y''/(1+y'^2)^(3/2).
%   0   = zero curvature at the throat (original geometry)
%   +   = positive curvature in the local +x/+y working frame
%   -   = opposite curvature
% The diffuser exit remains horizontal with ZERO curvature, so the exit join is unchanged.
% "lower" / "upper" refer to the wall as DRAWN in the 2-D graph (lower = smaller y, upper = larger y):
%   cone inlet : lower wall = ramp (cone) side,  upper wall = cowl side
%   ramp inlet : the cowl lies BELOW the ramp in the drawing, so lower wall = cowl side,  upper wall = ramp side
diffuser.lower_curvature = -0.1;  % curvature at the throat of the wall drawn LOWER in the graph [1/length]
diffuser.upper_curvature = 0.0;  % curvature at the throat of the wall drawn UPPER in the graph [1/length]
% Wall SLOPE right after the final ramp / cowl facet (start slope of the diffuser walls at the terminal-shock foot and head).
% Absolute angle from the x axis in deg, SAME sign convention as the ramp / cowl angles (positive = same sense as the ramp
% turning, e.g. cowl_upper_angle). NaN = automatic (original behaviour: wall continues tangent to the last facet; Mode 1:
% lower = last ramp facet, upper = lower cowl surface; Mode 2: both along the flow behind the last internal shock).
% A value different from the automatic one creates a corner (slope break) at the shoulder / cowl point; the wall then
% blends into the horizontal exit through the quintic, using the curvature inputs above. The automatic values are printed.
diffuser.lower_slope_deg = 10.0;  % start slope of the wall drawn LOWER in the graph [deg] (same drawn-side convention as above)
diffuser.upper_slope_deg = 8.0;  % start slope of the wall drawn UPPER in the graph [deg]
for fn_ = {'lower_slope_deg', 'upper_slope_deg'}
    v_ = diffuser.(fn_{1});
    if ~(isscalar(v_) && (isnan(v_) || (isfinite(v_) && abs(v_) < 90)))
        error('diffuser.%s must be NaN (automatic) or a finite angle with |angle| < 90 deg.', fn_{1});
    end
end
altitude        = 10500; % flight altitude [m] (ISA standard atmosphere, 0..71000 m). The freestream static pressure and
                         % temperature follow from it (they are NOT inputs); used for all absolute pressures
[p_inf, T_inf]  = isa_atmosphere(altitude);   % derived freestream static pressure [Pa] and temperature [K]
terminal_shock_model = 'normal';   % Mode 1 only. The terminal shock is DRAWN perpendicular to the lower cowl surface, i.e. tilted by
                         %   phi = (flow direction behind the ramp shocks) - (lower cowl angle) from the normal to the flow.
                         % 'normal' : Mach / total-pressure loss behind it are those of a NORMAL shock at M_b (original model)
                         % 'tilted' : oblique shock with the normal Mach component M_b*cos(phi) (consistent with the drawing)
                         % Mode 2: the terminal shock is exactly normal to the flow -> both choices give the same result.
if ~any(strcmpi(terminal_shock_model, {'normal', 'tilted'}))
    error('terminal_shock_model must be ''normal'' or ''tilted''.');
end
