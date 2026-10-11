function ctx = make_ctx(geo, sol, sol_int, mixed, flag, inlet_type, gam, M1, M_exit, p_inf, cowl_upper_deg)
% Collects what the fixed-geometry flow model needs. Works in the frame where the ramp rises ("unsigned"
% frame, y -> sgn*y of the drawing), in which the flow is turned counter-clockwise by the ramp.
    ctx = struct();
    ctx.gamma = gam;
    ctx.n     = numel(sol.theta);
    ctx.theta = sol.theta(:)';                     % design turning angle of every ramp facet [rad]
    ctx.mixed = mixed;
    if mixed
        ctx.m      = numel(sol_int.theta);
        ctx.theta2 = sol_int.theta(:)';            % design turning angle of every internal (cowl) facet [rad]
        solT       = sol_int;
    else
        ctx.m      = 0;
        ctx.theta2 = zeros(1, 0);
        solT       = sol;
    end
    ctx.cone = strcmpi(inlet_type, 'cone');
    ctx.sgn  = 1;
    if flag == 2, ctx.sgn = -1; end
    sg = ctx.sgn;
    ctx.Phi0 = [0, cumsum(ctx.theta)];             % Phi0(k+1) = direction of ramp facet k (flow direction behind shock k)
    ctx.Pu = [geo.P(:,1), sg*geo.P(:,2)];          % ramp corners
    ctx.Xu = [geo.X(1),   sg*geo.X(2)];            % cowl lip
    ctx.Su = [geo.foot(1), sg*geo.foot(2)];        % ramp end (terminal shock foot / shoulder)
    ctx.Tu = [geo.term_top(1), sg*geo.term_top(2)];% cowl end of the terminal shock (lip in Mode 1)
    if mixed
        ctx.Qu = [geo.Q(1:ctx.m,1), sg*geo.Q(1:ctx.m,2)];   % cowl corners that generate the internal shocks
    else
        ctx.Qu = zeros(0, 2);
    end
    ctx.H_inf          = geo.H_inf;
    ctx.cowl_low_deg   = geo.cowl_low_deg;
    ctx.cowl_upper_deg = cowl_upper_deg;
    ctx.phi_dev        = ctx.Phi0(end) - deg2rad(geo.cowl_low_deg);   % flow direction vs lower cowl surface (Mode 1)
    ctx.M1             = M1;
    ctx.M_exit         = M_exit;
    ctx.p_inf          = p_inf;
    ctx.pi_d_design    = geo.pi_d_total;
    ctx.pr_exit_d      = geo.p_exit_ratio;
    ctx.Mb_d           = solT.M(end);
    ctx.tol            = 1e-7;
    ctx.phi_t          = 0;                        % terminal-shock tilt used by plane_chain (set in the main script)
    ctx.alt            = NaN;                      % design altitude [m] (set in the main script)
    ctx.AeAc = NaN;  ctx.AtAc = NaN;
    ctx.fric_on = isfield(geo, 'fric') && geo.fric.enable && geo.fric.ok;   % diffuser friction active (see friction_offdesign)
    ctx.fp = [];  ctx.A_cap = NaN;  ctx.fr_ratio_d = 1;
    if ctx.fric_on
        ctx.fp = geo.fric.fp;  ctx.A_cap = geo.fric.A_cap;  ctx.fr_ratio_d = geo.fric.p0_ratio;
    end
    % ---- design capture and continuity calibration of the fixed areas ----
    % At the design condition the solver must give back the design exit Mach number and a terminal shock that
    % exactly fills its plane, so the two areas (relative to the capture area) are fixed from continuity there.
    Pd = plane_chain(ctx, M1, 0);
    ctx.MFR_d = mfr_from_hc(ctx, Pd.hc);
    MF1   = mflow(M1, gam);
    ctx.AeAc = ctx.MFR_d*MF1/(geo.pi_d_total*mflow(M_exit, gam));              % A_exit / A_capture
    pib_d    = geo.pi_front/solT.pi_normal;                                  % total-pressure ratio ahead of the terminal shock
    ctx.AtAc = ctx.MFR_d*MF1/(pib_d*mflow(ctx.Mb_d, gam));                     % A_terminal-shock-plane / A_capture
    ctx.AeAc_geom = geo.h_exit/geo.H_inf;                                      % purely geometric 2-D ratio (info only)
end
