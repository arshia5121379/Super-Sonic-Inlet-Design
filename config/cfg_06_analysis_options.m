% cfg_06_analysis_options.m - Configuration block (user inputs). Run by run_inlet_design.m in the base workspace.
%  Analysis options: flow stations / off-design / incidence / sweeps 
run_audit = true;         % true -> independent re-computation of p0, Mach, static pressure, mass flow and diffuser area
                          %         (printed after the design; every line is flagged OK / CHECK)
% The inlet geometry above is the DESIGN (alpha = 0, M1, altitude). Everything below re-uses that geometry
% as FIXED hardware and evaluates it at other flight conditions.

% --- 1) Flow-station map of the DESIGN point -----------------------------------------------------
station_map = true;       % true -> table + graphs of Mach number, static and total pressure in every region of
                          %         the inlet: freestream, after oblique shock 1..n [after internal shock 1..m],
                          %         diffuser inlet (behind the terminal shock) and diffuser outlet,
                          %         plus the inlet drawing annotated with the values of every region

% --- 2) Off-design operating point (flag) ---------------------------------------------------------
offdesign.enable = false; % true -> analyse the fixed inlet at the freestream below
offdesign.M      = 1.5;   % off-design freestream Mach number (> 1)
offdesign.altitude = 6000; % off-design flight altitude [m] (ISA, 0..71000)

% --- 3) Incidence / angle of attack (flag) --------------------------------------------------------
incidence.enable    = false; % true -> the off-design point AND the sweeps are evaluated with incidence
incidence.alpha_deg = 15;     % [deg] pitch angle in the plane of the drawing. POSITIVE = freestream turned towards
                             %   the first ramp facet (the first turn becomes theta_1 + alpha, more compression,
                             %   larger capture area); NEGATIVE = away from it (less compression, expansion if
                             %   theta_1 + alpha < 0).
                             %   ramp : planar flow in the pitch plane.
                             %   cone : windward (+|alpha|) and leeward (-|alpha|) meridian planes are both solved
                             %          with the planar relations; the captured / total-pressure values are the
                             %          capture-area weighted mean of the two planes (a first-order estimate).

% --- 4) Sweeps (flag) ----------------------------------------------------------------------------
sweep.enable      = false;            % master switch for all sweeps / maps below
sweep.mach        = true;             % sweep freestream Mach number
sweep.M_range     = [1.4 2.6 25];     %   [M_min M_max n_points]
sweep.altitude    = true;             % sweep flight altitude (ISA); only the absolute pressures change with altitude,
sweep.alt_range   = [4000 20000 9];   %   [h_min h_max n_points] in m   (ratios / recovery do not depend on altitude)
sweep.shock_plots = true;             % draw the shock pattern (foot, slope, terminal shock) of selected conditions of
sweep.shock_n     = 6;                %   the Mach / incidence sweeps (max. number of conditions shown, <= 9)
sweep.alpha       = true;             % sweep incidence (used only when incidence.enable = true)
sweep.alpha_range = [-6 6 13];        %   [alpha_min alpha_max n_points] in deg
sweep.map         = true;             % 2-D maps Mach x incidence (used only when incidence.enable = true)
sweep.map_n       = [21 13];          %   [n_Mach n_alpha] grid of the map (uses M_range and alpha_range limits)
sweep.export_csv  = true;             % write every sweep point to a CSV file
sweep.csv_file    = 'inlet_sweep_results.csv';
% Sweeps hold the other variables at the "base" condition: Mach / altitude of offdesign.* if offdesign.enable
% (else the design values) and alpha = incidence.alpha_deg if incidence.enable (else 0).
%
% Off-design model (first order, documented in the functions at the end of this file):
%   * ramp / cowl geometry is frozen; each facet turns the flow by its design angle (the first one by theta_1 + alpha)
%   * oblique shock angle from the theta-beta-M relation (weak branch); if the turn exceeds theta_max the shock is
%     detached (modelled as a normal shock, flagged)
%   * spillage: the freestream streamline that ends on the cowl lip is traced back through the actual shock
%     pattern -> mass-flow capture ratio A_c/A_cap
%   * terminal shock = normal shock at the Mach number reached in front of it (critical position)
%   * diffuser exit Mach from continuity with the (fixed) exit area, total pressure = total pressure behind the shock
