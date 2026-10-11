% cfg_03_cowl.m - Configuration block (user inputs). Run by run_inlet_design.m in the base workspace.
%  Cowl lip (sharp 2D wedge whose tip sits at the focus point) 
cowl_upper_angle = 20;   % deg: upper (outer) cowl surface, measured from horizontal (+ = up, same sense as ramp)
cowl_angle       = 8;    % deg: included wedge angle between upper and lower cowl surfaces (Mode 1 only)
% Outer (exterior / upper) cowl wall: ONE smooth curve running from the lip (tangent to the upper cowl angle)
% to the diffuser exit plane. It is shaped by two user inputs:
cowl_outer_curvature = 0.15;  % [1/length] curvature of the outer wall AT THE LIP.
                              %   0 = straight at the lip, > 0 = convex (wall bends back towards the flow path /
                              %   axial direction, like a nacelle shoulder), < 0 = concave (bends away from it).
                              %   1/curvature is the local radius, e.g. 0.15 -> radius of about 6.7 units.
cowl_mean_thickness  = 0.15;  % [length] MEAN cowl wall thickness: average vertical distance between the outer
                              %   wall and the inner cowl wall (inner cowl surface + cowl-side diffuser wall),
                              %   averaged over x from the lip to the diffuser exit plane.
% How the two inputs are met: the wall is a quintic in x that leaves the lip along cowl_upper_angle with the
%   curvature cowl_outer_curvature, and arrives at the diffuser exit plane horizontal with zero curvature (so it
%   can join a straight nacelle). Its three free coefficients are solved so that the mean thickness is exactly
%   cowl_mean_thickness. The exit-plane thickness (a result, not an input), min/max thickness are printed.
%   The lip thickness is always zero (sharp lip). Very strong curvature with a very small mean thickness may
%   be infeasible: the wall would cross the inner wall and a warning is issued.
% Thin lip: the lower (inner) surface angle = cowl_upper_angle - cowl_angle = 20 deg is unchanged, so the
%           terminal shock and the aerodynamic design do not move; only the outer surface is brought closer.
% Mode 1: lower (inner) cowl surface angle from horizontal = cowl_upper_angle - cowl_angle, and the
%         terminal shock is perpendicular to it (throat plane); its foot on the ramp is where that
%         line meets the last ramp facet.
% Mode 2: the lower cowl surface is the first internal facet (set by the internal shock design), so
%         cowl_angle is not used - the resulting wedge angle is printed instead.

if ~(isscalar(cowl_outer_curvature) && isfinite(cowl_outer_curvature))
    error('cowl_outer_curvature must be a finite scalar (1/length; 0 = straight).');
end
if ~(isscalar(cowl_mean_thickness) && cowl_mean_thickness > 0)
    error('cowl_mean_thickness must be a positive scalar.');
end
