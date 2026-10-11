function sol_out = inlet_geometry(sol, flag, cowl, sol_int, diffuser, lengths, show_shocks)
% inlet_geometry
% Draws the faceted ramp (theta_1..theta_n), its oblique shocks (beta_1..beta_n), the
% cowl lip, the terminal shock and the subsonic diffuser walls.
%
% Ramp facet lengths L(2..n) (L(1) = 1 is the reference) are solved ITERATIVELY so that
% all external oblique shocks are concurrent at the cowl lip (focus point X).
%
% MODE 1 (sol_int empty): external compression.
%   The terminal shock runs from the lip X, perpendicular to the lower cowl surface
%   (angle = upper_angle_deg - angle_deg), down to the ramp; the ramp ends at its foot.
%
% MODE 2 (sol_int given): mixed compression.
%   Internal oblique shocks (Oswatitsch, stage sol_int) are generated at cowl corners
%   Q_1 = X (lip), Q_2, ... and are all focused on the ramp end S (shoulder). Cowl
%   facets turn the flow back towards the ramp; the terminal shock stands at S,
%   perpendicular to the flow behind the internal shocks, and ends on the last cowl facet.
%
% lengths (struct, optional): .ramp (1-by-n ramp facet lengths, NaN = solved), .cowl ((m-1) internal
%   cowl facet lengths, Mode 2 only, NaN = solved). Each user length (except ramp(1), which sets the
%   scale) removes one focusing equation: ramp(k), k >= 2, frees shock k+1; cowl(j) frees internal
%   shock j+1. Mode 1: ramp(n) is ignored, the terminal shock foot stays on the lip and the last facet
%   is re-located to it. Outputs .miss_ext / .miss_int give the signed miss distances.
%
% cowl (struct): .upper_angle_deg, .angle_deg (Mode 1 only),
%                .curvature (outer wall curvature at the lip, 1/length; > 0 convex, 0 straight),
%                .mean_thickness (mean vertical cowl wall thickness, lip -> diffuser exit plane)
% diffuser (struct): .M_exit, .length, .split
%
% Diffuser: throat height h_t = length of the terminal shock (final ramp point to cowl
% point); exit height from A/A* at the Mach behind the terminal shock and at M_exit:
%   h_exit = h_t * (A/A*)(M_exit) / (A/A*)(M_after_terminal_shock)
% Both walls are quintic curves that start tangent to the ramp / cowl surface, use the
% user-selected throat curvatures diffuser.lower_curvature / diffuser.upper_curvature,
% and end horizontal with zero curvature at the exit plane. The end points are P_ultimate.
%
% Outer cowl: a single quintic curve from the lip to the diffuser exit plane, tangent to the upper
% cowl angle at the lip with user-specified curvature cowl.curvature there, and horizontal with zero
% curvature at the exit plane. Its coefficients are solved so that the MEAN vertical distance to the
% inner cowl wall (inner cowl surface + cowl-side diffuser wall) equals cowl.mean_thickness.

    n = numel(sol.theta);
    if n < 1
        error('Expected at least 1 deflection angle.');
    end
    if numel(sol.beta) ~= n
        error('sol.beta must have the same length as sol.theta.');
    end
    if nargin < 2 || isempty(flag), flag = 1; end
    if nargin < 3 || isempty(cowl)
        cowl = struct('upper_angle_deg', 30, 'angle_deg', 10, 'curvature', 0.1, 'mean_thickness', 0.1);
    end
    if ~isfield(cowl, 'curvature'),      cowl.curvature = 0;         end
    if ~isfield(cowl, 'mean_thickness'), cowl.mean_thickness = 0.1;  end
    if ~(isscalar(cowl.mean_thickness) && cowl.mean_thickness > 0)
        error('cowl.mean_thickness must be a positive scalar.');
    end
    if ~(isscalar(cowl.curvature) && isfinite(cowl.curvature))
        error('cowl.curvature must be a finite scalar.');
    end
    if nargin < 4, sol_int = []; end
    if nargin < 7 || isempty(show_shocks), show_shocks = true; end   % false -> draw the hardware only (no design shocks)
    if nargin < 5 || isempty(diffuser)
        diffuser = struct('M_exit', 0.5, 'length', 4, 'split', 0.5);
    end
    if ~isfield(diffuser, 'lower_curvature'), diffuser.lower_curvature = 0; end
    if ~isfield(diffuser, 'upper_curvature'), diffuser.upper_curvature = 0; end
    if ~(isscalar(diffuser.lower_curvature) && isfinite(diffuser.lower_curvature))
        error('diffuser.lower_curvature must be a finite scalar [1/length].');
    end
    if ~(isscalar(diffuser.upper_curvature) && isfinite(diffuser.upper_curvature))
        error('diffuser.upper_curvature must be a finite scalar [1/length].');
    end
    if ~isfield(diffuser, 'lower_slope_deg'), diffuser.lower_slope_deg = NaN; end   % NaN = automatic (tangent to the last facet)
    if ~isfield(diffuser, 'upper_slope_deg'), diffuser.upper_slope_deg = NaN; end
    for fn_ = {'lower_slope_deg', 'upper_slope_deg'}
        v_ = diffuser.(fn_{1});
        if ~(isscalar(v_) && (isnan(v_) || (isfinite(v_) && abs(v_) < 90)))
            error('diffuser.%s must be NaN (automatic) or a finite angle with |angle| < 90 deg.', fn_{1});
        end
    end
    if diffuser.M_exit >= 1
        error('diffuser.M_exit must be subsonic (< 1).');
    end
    mixed = ~isempty(sol_int);
    sgn = 1; if flag == 2, sgn = -1; end
    npts = 60;
    % The user's lower/upper inputs refer to the wall as DRAWN. Cone: lower = ramp side. Ramp inlet: the cowl is drawn below
    % the ramp, so lower = cowl side. kR/sR = ramp-side wall, kC/sC = cowl-side wall (used internally).
    if flag == 2
        kR = diffuser.upper_curvature;   kC = diffuser.lower_curvature;
        sR = diffuser.upper_slope_deg;   sC = diffuser.lower_slope_deg;
    else
        kR = diffuser.lower_curvature;   kC = diffuser.upper_curvature;
        sR = diffuser.lower_slope_deg;   sC = diffuser.upper_slope_deg;
    end                                % points per diffuser wall

    theta = sol.theta(:)';
    beta  = sol.beta(:)';
    Phi0  = [0, cumsum(theta)];               % Phi0(k+1) = sum(theta(1:k))
    delta_ext = Phi0(n+1);                    % flow direction behind the external shocks (unsigned)

    % Absolute direction of external oblique shock k = flow direction AHEAD of shock k
    % (sum of previous deflections, Phi0(k)) + beta_k.
    psi_obl = sgn*(Phi0(1:n) + beta);

    % ---- mode dependent directions ----
    psi_norm  = 0;  psi_int = [];  dirC = [];  m = 0;
    delta_int = delta_ext;                    % flow direction behind the last oblique shock (unsigned)
    if ~mixed
        cowl_low_deg = cowl.upper_angle_deg - cowl.angle_deg;
        a_low    = sgn*deg2rad(cowl_low_deg);
        psi_norm = a_low + pi/2;              % terminal shock perpendicular to lower cowl surface
    else
        m      = numel(sol_int.theta);
        theta2 = sol_int.theta(:)';
        beta2  = sol_int.beta(:)';
        Th     = [0, cumsum(theta2)];         % cumulative internal turning (towards the ramp)
        delta_int    = delta_ext - Th(m+1);
        psi_int      = sgn*(delta_ext - Th(1:m) - beta2);   % internal shock directions
        dirC         = sgn*(delta_ext - Th(2:m+1));         % cowl facet directions
        cowl_low_deg = rad2deg(delta_ext - Th(2));          % first (lip) facet, unsigned
    end

    % ---- user-specified facet lengths ----
    if nargin < 6 || isempty(lengths), lengths = struct(); end
    if ~isfield(lengths, 'ramp') || isempty(lengths.ramp), lengths.ramp = nan(1, n); end
    if numel(lengths.ramp) ~= n
        error('lengths.ramp must have %d entries (one per ramp facet).', n);
    end
    Lr_user = lengths.ramp(:)';
    Lc_user = [];
    if mixed
        if ~isfield(lengths, 'cowl') || isempty(lengths.cowl), lengths.cowl = nan(1, m-1); end
        if numel(lengths.cowl) ~= m-1
            error('lengths.cowl must have %d entries (one per internal cowl facet).', m-1);
        end
        Lc_user = lengths.cowl(:)';
    end
    if ~mixed && n >= 2 && ~isnan(Lr_user(n))
        warning(['Mode 1: the last ramp facet is re-located by the terminal shock (its foot stays on the ', ...
                 'cowl lip), so ramp_lengths(%d) is ignored.'], n);
        Lr_user(n) = NaN;
    end
    L1 = 1;                                   % reference length of the first ramp facet
    if ~isnan(Lr_user(1)), L1 = Lr_user(1); end
    if mixed, neq = n + m; else, neq = n + 1; end
    keep = true(neq, 1);                      % equations that are enforced
    keep(3:n+1) = isnan(Lr_user(2:end));      % fixed L(k) frees equation k+1 (shock k+1, or terminal shock for k = n)
    if mixed && m > 1
        keep(n+2:n+m) = isnan(Lc_user);       % fixed Lc(j) frees internal shock j+1
    end
    nfL  = nnz(isnan(Lr_user(2:end)));        % unknown ramp facets
    nfLc = nnz(isnan(Lc_user));               % unknown cowl facets

    % ---- concurrency solve ----
    ctx = struct('n', n, 'm', m, 'Phi0', Phi0, 'sgn', sgn, 'mixed', mixed, ...
                 'psi_obl', psi_obl, 'psi_norm', psi_norm, 'psi_int', psi_int, 'dirC', dirC, ...
                 'L1', L1, 'Lfix', Lr_user(2:end), 'Lcfix', Lc_user, 'keep', keep, 'neq', neq);
    if ~mixed
        P0g = ramp_points(L1, ones(1, n-1), n, Phi0, sgn);
        Xg  = P0g(end,:) + 2*[cos(psi_norm), sin(psi_norm)];
    else
        Xg  = 2*[cos(psi_obl(1)), sin(psi_obl(1))];
    end
    u0 = [Xg, ones(1, nfL), ones(1, nfLc)];

    opts = optimoptions('fsolve', 'Display', 'off', ...
        'FunctionTolerance', 1e-12, 'StepTolerance', 1e-12);
    [usol, ~, exitflag] = fsolve(@(u) geometry_residual(u, ctx), u0, opts);
    if exitflag <= 0
        warning('fsolve did not converge cleanly (exitflag=%d). Check theta/beta feasibility.', exitflag);
    end

    X  = usol(1:2);
    [~, Ffull, Lr, Lcfull] = geometry_residual(usol, ctx);   % full facet lengths, all residuals
    L  = [L1, Lr];
    P  = ramp_points(L1, Lr, n, Phi0, sgn);
    S  = P(n+1,:);                            % ramp end: terminal shock foot / shoulder

    % signed miss distances (frame with the ramp below the cowl); zero for enforced conditions
    %   external shock k vs lip:  > 0 shock passes on the flow-path side of the lip, < 0 on the outer side
    %   internal shock j vs S  :  > 0 shock reaches the ramp upstream of the shoulder, < 0 downstream
    miss     = sgn*Ffull(:)';
    miss_ext = miss(1:n);
    miss_int = [];
    if mixed, miss_int = miss(n+1:n+m); end

    % ---- cowl corners and top of the terminal shock ----
    if ~mixed
        Q = X;                                % only the lip
        T = X;                                % terminal shock foot stays on the lip
        a_inner = a_low;                      % inner cowl surface direction (from the lip)
        cowl_wedge_deg = cowl.angle_deg;
        dlow0 = delta_ext;                    % lower diffuser wall starts along the last ramp facet
        dup0  = deg2rad(cowl_low_deg);        % cowl wall starts along the lower cowl surface
        phi_dev = delta_ext - deg2rad(cowl_low_deg);
        Mn_eff  = sol.M(end) * cos(phi_dev);  % normal Mach seen by the tilted terminal shock
    else
        Lc = Lcfull;
        a_inner = dirC(1);                    % inner cowl surface direction (from the lip)
        Q  = zeros(m+1, 2);
        Q(1,:) = X;
        for jj = 1:m-1
            Q(jj+1,:) = Q(jj,:) + Lc(jj)*[cos(dirC(jj)), sin(dirC(jj))];
        end
        psiT = sgn*delta_int + pi/2;          % terminal shock normal to the flow behind the internal shocks
        dC   = [cos(dirC(m)), sin(dirC(m))];
        sT   = [cos(psiT), sin(psiT)];
        tlast = cross2(S - Q(m,:), sT) / cross2(dC, sT);
        Q(m+1,:) = Q(m,:) + tlast*dC;
        T = Q(m+1,:);
        if tlast <= 0
            warning('Terminal shock does not meet the last cowl facet downstream of its start. Adjust internal design.');
        end
        cowl_wedge_deg = cowl.upper_angle_deg - cowl_low_deg;
        if cowl_wedge_deg <= 0
            warning('Cowl upper angle (%.2f deg) must exceed the lip facet angle (%.2f deg) for a sharp wedge.', ...
                cowl.upper_angle_deg, cowl_low_deg);
        end
        dlow0 = delta_int;                    % lower wall starts along the flow behind the terminal shock
        dup0  = delta_int;                    % cowl wall starts along the last cowl facet
        Mn_eff = sol_int.M(end);              % terminal shock is exactly normal to the flow
    end

    H_inf = abs(X(2));                        % capture height: axis (y=0) -> cowl lip
    tvec  = T - S;
    h_t   = norm(tvec);                       % throat height = terminal shock length
    term_angle_deg = mod(rad2deg(atan2(tvec(2), tvec(1))), 180);

    if L(end) <= 0
        warning('Last ramp facet length is <= 0: the terminal shock foot lies upstream of the last corner. Change cowl / internal design.');
    end
    if Mn_eff <= 1
        warning('Effective normal Mach at terminal shock = %.3f <= 1: no shock possible at this inclination.', Mn_eff);
    end

    % ---- diffuser sizing (A/A* relation) ----
    if mixed, solT = sol_int; else, solT = sol; end
    gam  = sol.gamma;
    M_th = solT.M_after_normal;                       % subsonic Mach right behind the terminal shock
    AR_th = area_ratio(M_th, gam);
    AR_ex = area_ratio(diffuser.M_exit, gam);
    % The terminal shock is drawn perpendicular to the lower cowl surface (Mode 1), i.e. tilted by phi_geo from the
    % normal to the flow, so its LENGTH h_t is larger than the flow-normal height ahead of it: h_t*cos(phi_geo).
    % Continuity across the shock (mass-flow function, total-pressure loss pi_normal) gives the flow-normal height
    % behind it, which equals the height ahead for a normal shock. The A/A* relation then gives the exit height.
    if mixed, phi_geo = 0; else, phi_geo = phi_dev; end
    h_flow_ahead  = h_t * cos(phi_geo);
    h_flow_behind = h_flow_ahead * mflow(solT.M(end), gam) / (solT.pi_normal * mflow(M_th, gam));
    h_e   = h_flow_behind * AR_ex / AR_th;            % exit height (2-D: area per unit span)

    % ---- diffuser walls (work in a frame where the ramp is below the cowl) ----
    Sp = [S(1), sgn*S(2)];
    Tp = [T(1), sgn*T(2)];
    x_e = max(S(1), T(1)) + diffuser.length;
    dlow0_auto = dlow0;  dup0_auto = dup0;            % automatic start slopes (tangent to the last facet / flow)
    if ~isnan(sR), dlow0 = deg2rad(sR); end           % user-set slope of the ramp-side wall right after the final ramp
    if ~isnan(sC), dup0  = deg2rad(sC); end           % user-set slope of the cowl-side wall right after the final cowl facet
    mL  = tan(dlow0);                                 % lower wall start slope
    mU  = tan(dup0);                                  % cowl wall start slope
    yl_base = Sp(2) + mL*(x_e - Sp(1))/2;             % reference end heights without area growth
    yu_base = Tp(2) + mU*(x_e - Tp(1))/2;
    % ---- diffuser friction: the exit height follows from the friction ODE (given M_th behind the terminal shock and M_exit) ----
    if mixed, pi_front = prod(sol.pi_obl) * sol_int.pi_d; else, pi_front = sol.pi_d; end   % total-pressure ratio behind the terminal shock
    fric_ratio = 1;                                   % p0_exit / p0_diffuser_inlet
    fr_out = struct('enable', false, 'ok', false, 'p0_ratio', 1);
    if isfield(diffuser, 'h_exit_fixed')
        h_e = diffuser.h_exit_fixed;                  % redraw of a diffuser that was already sized
    elseif isfield(diffuser, 'fric') && diffuser.fric.enable
        gd = struct('Sp', Sp, 'Tp', Tp, 'mL', mL, 'mU', mU, 'x_e', x_e, 'yl_base', yl_base, 'yu_base', yu_base, ...
                    'split', diffuser.split, 'kL0', kR, 'kU0', kC);
        [h_e, fr_out] = friction_size_diffuser(diffuser.fric, gd, h_e, h_flow_behind, M_th, pi_front, H_inf, gam, ...
                                               sol.M1, flag, diffuser.M_exit);
        fric_ratio = fr_out.p0_ratio;
    end
    extra   = h_e - (yu_base - yl_base);              % area growth to distribute
    yl_end  = yl_base - diffuser.split*extra;
    yu_end  = yu_base + (1 - diffuser.split)*extra;
    [xl, yl] = smooth_wall(Sp(1), Sp(2), mL, x_e, yl_end, 0, kR, 0, npts);
    [xu, yu] = smooth_wall(Tp(1), Tp(2), mU, x_e, yu_end, 0, kC, 0, npts);
    lowerW = [xl, sgn*yl];
    upperW = [xu, sgn*yu];
    P_ult  = [x_e, sgn*yl_end; x_e, sgn*yu_end];      % [lower wall end; cowl wall end]

    % ---- outer (upper) cowl surface: one quintic curve, lip -> diffuser exit plane ----
    % (work in the frame where the cowl lies above the ramp, like the diffuser walls)
    %   y_o(s) = y0 + m0*s + 0.5*ypp0*s^2 + c3*s^3 + c4*s^4 + c5*s^5,   s = x - x_lip
    %   m0   : tangent of the upper cowl angle (the outer wall leaves the lip along it)
    %   ypp0 : set by the requested curvature at the lip, kappa = -y''/(1+y'^2)^1.5  (kappa > 0 = convex)
    %   c3..c5 : solved (3x3 linear system) so that the wall ends HORIZONTAL with ZERO curvature at the exit
    %            plane (joins a straight nacelle) and the mean vertical distance to the inner cowl wall
    %            equals cowl.mean_thickness
    x0   = X(1);
    y0   = sgn*X(2);
    m0   = tan(deg2rad(cowl.upper_angle_deg));
    ypp0 = -cowl.curvature * (1 + m0^2)^1.5;
    D    = x_e - x0;
    if D <= 0
        error('Diffuser exit plane lies upstream of the cowl lip. Increase diffuser_length.');
    end
    % inner cowl wall as a function of x: inner cowl facets (lip -> terminal shock top) + cowl-side diffuser wall
    Qp   = [Q(1:end-1,1), sgn*Q(1:end-1,2)];          % cowl corners before the diffuser wall (empty in Mode 1)
    xin  = [Qp(:,1); xu];
    yin  = [Qp(:,2); yu];
    xo   = linspace(x0, x_e, 2*npts)';
    so   = xo - x0;
    yin_o = interp1(xin, yin, xo, 'linear', 'extrap');
    yo0  = y0 + m0*so + 0.5*ypp0*so.^2;               % curve without the s^3..s^5 terms
    Aq = [3*D^2,  4*D^3,   5*D^4;                     % end slope      y'(D)  = 0
          6*D,    12*D^2,  20*D^3;                    % end curvature  y''(D) = 0
          trapz(xo,so.^3)/D, trapz(xo,so.^4)/D, trapz(xo,so.^5)/D];   % mean of the added terms
    bq = [-(m0 + ypp0*D);
          -ypp0;
          cowl.mean_thickness - trapz(xo, yo0 - yin_o)/D];
    cq = Aq \ bq;
    yo   = yo0 + cq(1)*so.^3 + cq(2)*so.^4 + cq(3)*so.^5;
    gap_o = yo - yin_o;                               % vertical cowl wall thickness along x
    t_mean = trapz(xo, gap_o)/D;
    t_exit = gap_o(end);
    t_min  = min(gap_o);
    t_max  = max(gap_o);
    outerW  = [xo, sgn*yo];                           % starts exactly at the lip, ends at the outer end point
    P_outer = [x_e, sgn*yo(end)];
    if t_min < -1e-9
        warning(['Outer cowl wall crosses the inner cowl wall (min thickness = %.4g). Reduce |cowl_outer_curvature|, ', ...
                 'increase cowl_mean_thickness, or adjust cowl_upper_angle / cowl_angle.'], t_min);
    end
    if t_exit <= 0
        warning('Cowl wall thickness at the exit plane is <= 0. Adjust cowl_outer_curvature or cowl_mean_thickness.');
    end

    xs  = linspace(max(Sp(1), Tp(1)), x_e, npts);
    gap = interp1(xu, yu, xs) - interp1(xl, yl, xs);
    if any(gap <= 0)
        warning('Diffuser walls cross each other. Increase diffuser_length or adjust the cowl / split.');
    end

    % ---- exit static pressure (isentropic diffuser, total pressure = inlet recovery) ----
    pi_tot = pi_front * fric_ratio;                   % total-pressure recovery at the diffuser exit, INCLUDING diffuser friction
    p_exit_ratio = pi_tot * ((1 + 0.5*(gam-1)*sol.M1^2) / (1 + 0.5*(gam-1)*diffuser.M_exit^2))^(gam/(gam-1));

    % ---- profiles for export ----
    ramp_profile = [P; lowerW(2:end,:)];
    % closed cowl outline: outer end point -> back along the outer wall -> lip (outerW(1,:) = X)
    % -> inner cowl surface -> cowl-side diffuser wall -> inner end point -> (exit face) outer end point
    cowl_profile = [flipud(outerW(2:end,:)); X; Q(2:end,:); upperW(2:end,:); outerW(end,:)];
    % closed diffuser outline: lower wall -> exit plane -> cowl wall (back) -> terminal shock -> start
    diffuser_profile = [lowerW; flipud(upperW); lowerW(1,:)];

    % ---- plot ----
    hold on
    if show_shocks
    for k = 1:n                               % external shock k: true angle, from its corner to the inner cowl surface line
        Ek = shock_end(P(k,:), psi_obl(k), X, a_inner);
        plot([P(k,1), Ek(1)], [P(k,2), Ek(2)], '-', 'LineWidth', 1.2, 'Color', [0.85 0.33 0.10]);
    end
    if mixed
        for j = 1:m                           % internal shock j: true angle, from its cowl corner to the last ramp facet line
            Ej = shock_end(Q(j,:), psi_int(j), S, sgn*Phi0(n+1));
            plot([Q(j,1), Ej(1)], [Q(j,2), Ej(2)], '-', 'LineWidth', 1.2, 'Color', [0.00 0.45 0.74]);
        end
    end
    plot([S(1), T(1)], [S(2), T(2)], '-', 'LineWidth', 2, 'Color', [0.49 0.18 0.56]);   % terminal shock
    end
    plot(X(1), X(2), 'k*', 'MarkerSize', 10, 'LineWidth', 1.5);
    text(X(1), X(2), '  focus point / cowl lip', 'FontSize', 9);

    plot(P(:,1), P(:,2), '-o', 'LineWidth', 2);                                        % ramp
    plot(lowerW(:,1), lowerW(:,2), 'r-', 'LineWidth', 2);                              % lower diffuser wall
    plot([P(1,1), x_e + 0.5], [0, 0], '--', 'LineWidth', 1.5);                         % axis line

    plot(outerW(:,1), outerW(:,2), 'k-', 'LineWidth', 2.5);                            % outer cowl wall, lip -> diffuser end
    plot([P_outer(1), P_ult(2,1)], [P_outer(2), P_ult(2,2)], 'k-', 'LineWidth', 2.5);  % cowl exit face (thickness)
    plot([Q(:,1); upperW(2:end,1)], [Q(:,2); upperW(2:end,2)], 'k-', 'LineWidth', 2.5);% inner cowl + diffuser wall
    plot([x_e, x_e], P_ult(:,2)', 'k:', 'LineWidth', 1.2);                             % exit plane
    plot(P_ult(:,1), P_ult(:,2), 'ks', 'MarkerFaceColor', 'y', 'MarkerSize', 7);
    text(x_e, mean(P_ult(:,2)), sprintf('  P_{ult}, h_{exit}=%.3f', h_e), 'FontSize', 9);

    % H_inf: axis -> cowl lip
    plot([X(1), X(1)], [0, X(2)], 'b--', 'LineWidth', 1.2);
    text(X(1), X(2)/2, sprintf('  H_\\infty = %.4f', H_inf), 'Color', 'b', 'FontSize', 9);

    xlabel('x (arb. units)');
    ylabel('y (arb. units)');
    theta_deg = rad2deg(theta); beta_deg = rad2deg(beta);
    abs_deg = rad2deg(Phi0(1:n) + beta);   % absolute shock angles as drawn
    labels = arrayfun(@(i) sprintf('\\theta_%d=%.2f^\\circ, \\beta_%d=%.2f^\\circ (abs %.2f^\\circ)', ...
        i, theta_deg(i), i, beta_deg(i), abs_deg(i)), 1:n, 'UniformOutput', false);
    if mixed
        abs_int = rad2deg(delta_ext - Th(1:m) - beta2);
        labels_int = arrayfun(@(i) sprintf('int %d: \\theta=%.2f^\\circ, \\beta=%.2f^\\circ (abs %.2f^\\circ)', ...
            i, rad2deg(theta2(i)), rad2deg(beta2(i)), abs_int(i)), 1:m, 'UniformOutput', false);
        labels = [labels, labels_int];
    end
    if show_shocks
        text(0.02, 0.95, strjoin(labels, newline), 'Units', 'normalized', ...
            'VerticalAlignment', 'top');
    end
    axis equal; grid on; hold off;

    % ---- outputs ----
    sol_out = sol;
    sol_out.L = L; sol_out.P = P; sol_out.X = X;
    sol_out.Lc = Lcfull;
    sol_out.miss_ext = miss_ext;
    sol_out.miss_int = miss_int;
    sol_out.ramp_user = ~isnan(Lr_user);
    sol_out.cowl_user = ~isnan(Lc_user);
    sol_out.H_inf = H_inf;
    sol_out.foot = S;
    sol_out.term_top = T;
    sol_out.term_len = h_t;
    sol_out.term_angle_deg = term_angle_deg;
    sol_out.Mn_eff = Mn_eff;
    sol_out.Q = Q;
    sol_out.cowl_low_deg = cowl_low_deg;
    sol_out.cowl_wedge_deg = cowl_wedge_deg;
    sol_out.h_throat = h_t;
    sol_out.h_throat_flow = h_flow_behind;
    sol_out.phi_term_deg = rad2deg(phi_geo);
    sol_out.h_exit = h_e;
    sol_out.M_throat = M_th;
    sol_out.AR_throat = AR_th;
    sol_out.AR_exit = AR_ex;
    sol_out.lower_wall = lowerW;
    sol_out.upper_wall = upperW;
    sol_out.lower_curvature = diffuser.lower_curvature;
    sol_out.upper_curvature = diffuser.upper_curvature;
    sol_out.lower_start_deg      = rad2deg(dlow0);       % diffuser wall start slopes (working frame, same sense as the ramp angles)
    sol_out.upper_start_deg      = rad2deg(dup0);
    sol_out.lower_start_auto_deg = rad2deg(dlow0_auto);
    sol_out.upper_start_auto_deg = rad2deg(dup0_auto);
    sol_out.lower_start_user     = ~isnan(sR);           % NOTE: lower_* / upper_* here = RAMP-side / COWL-side wall (working frame)
    sol_out.upper_start_user     = ~isnan(sC);
    sol_out.kR = kR;  sol_out.kC = kC;
    sol_out.lower_start_actual_deg = sgn*rad2deg(dlow0); % same slopes in the drawn (actual) coordinates
    sol_out.upper_start_actual_deg = sgn*rad2deg(dup0);
    sol_out.P_ult = P_ult;
    sol_out.p_exit_ratio = p_exit_ratio;
    sol_out.pi_d_total = pi_tot;
    sol_out.pi_front = pi_front;                      % total-pressure ratio behind the terminal shock (diffuser inlet)
    sol_out.fric = fr_out;                            % diffuser friction solution (see friction_size_diffuser)
    sol_out.ramp_profile = ramp_profile;
    sol_out.cowl_profile = cowl_profile;
    sol_out.diffuser_profile = diffuser_profile;
    sol_out.outer_wall = outerW;
    sol_out.P_outer = P_outer;
    sol_out.t_mean = t_mean;
    sol_out.t_exit = t_exit;
    sol_out.t_min  = t_min;
    sol_out.t_max  = t_max;
end
