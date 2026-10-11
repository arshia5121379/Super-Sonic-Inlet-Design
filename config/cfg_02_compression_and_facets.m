% cfg_02_compression_and_facets.m - Configuration block (user inputs). Run by run_inlet_design.m in the base workspace.
%  Compression type 
% mixed = false : MODE 1 - external compression only. External oblique shocks are
%                 focused on the cowl lip, terminal shock runs from the lip to the
%                 ramp (foot position set by the cowl angle), then the diffuser.
% mixed = true  : MODE 2 - mixed compression. Lower (ramp) configuration focuses its
%                 shocks on the cowl lip; from the lip a second, upper (cowl-side)
%                 configuration of internal oblique shocks is focused on the ramp
%                 shoulder; a second terminal shock stands at the shoulder, then
%                 the diffuser (like Fig. 6.11, Seddon & Goldsmith).
mixed      = true;
M_int_in   = 1.5;  % (mixed) Mach entering the internal compression (after external shocks).
                   %   Must satisfy  M1 > M_int_in > Mn_target > 1  (M_int_in = Mn_target leaves nothing to compress internally).
                   %   Tip: the flow behind the internal shocks is parallel to the x axis when the external and internal
                   %   turning angles are equal; the design summary prints that flow direction so you can tune M_int_in.
n_internal = 2;    % (mixed) number of internal oblique shocks generated on the cowl

%  Facet lengths (optional, user specified) 
% Ramp facet lengths L(1..n_oblique), measured along each facet starting at the ramp tip (arb. units).
%   NaN = automatic: L(1) = 1 is the reference and the other facets are solved so that the shocks
%   focus (all external shocks on the cowl lip; Mode 1 also the terminal shock on the lip; Mode 2
%   the internal shocks on the ramp shoulder).
%   A number = fixed by you. Each fixed length (other than L(1)) removes one focusing condition:
%   the shock generated at the next corner then no longer hits its target point; the miss distance is
%   printed and the shock is drawn at its true angle.
%   Mode 1: the terminal shock always stands on the cowl lip, so the LAST ramp facet is re-located
%   automatically (trimmed or extended to the terminal shock foot) and ramp_lengths(end) is ignored.
%   Mode 2: the last ramp facet can be fixed (the first internal shock then misses the shoulder).
ramp_lengths = nan(1, n_oblique);        % e.g. [1.0 0.8 1.2] for n_oblique = 3
% (mixed only) internal cowl facet lengths, from the lip downstream. The last cowl facet ends on the
% terminal shock, so there are n_internal-1 entries. NaN = automatic (internal shocks focus on the shoulder).
cowl_lengths = nan(1, max(n_internal-1, 0));   % e.g. [0.5 0.6] for n_internal = 3

if numel(ramp_lengths) ~= n_oblique
    error('ramp_lengths must have n_oblique = %d entries (use NaN for automatic).', n_oblique);
end
if any(~isnan(ramp_lengths) & ramp_lengths <= 0)
    error('ramp_lengths entries must be positive (or NaN for automatic).');
end
if mixed
    if numel(cowl_lengths) ~= n_internal-1
        error('cowl_lengths must have n_internal-1 = %d entries (use NaN for automatic).', n_internal-1);
    end
    if any(~isnan(cowl_lengths) & cowl_lengths <= 0)
        error('cowl_lengths entries must be positive (or NaN for automatic).');
    end
elseif any(~isnan(cowl_lengths))
    warning('cowl_lengths is only used in mixed compression (Mode 2) and is ignored in Mode 1.');
end
