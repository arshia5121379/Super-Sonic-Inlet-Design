function L = offdesign_shock_lines(ctx, P)
% Off-design shock lines in the DRAWING frame: foot (where the shock leaves the wall), tip (where it ends) and
% slope from the horizontal [deg], for every attached oblique shock (external, internal) and the terminal shock.
% The terminal shock is the normal shock at the critical position of the model: it stands on the throat plane of the
% fixed hardware (foot on the ramp end / shoulder, top on the cowl), its position does not move in this first-order model.
    sg = ctx.sgn;  n = ctx.n;  m = ctx.m;
    L = struct('name', {}, 'kind', {}, 'foot', {}, 'tip', {}, 'angle_deg', {}, 'beta_deg', {}, 'miss', {});
    a_inner = sg*deg2rad(ctx.cowl_low_deg);
    Xd = [ctx.Xu(1), sg*ctx.Xu(2)];
    Sd = [ctx.Su(1), sg*ctx.Su(2)];
    for k = 1:n
        if isfinite(P.psi_e(k))
            foot = [ctx.Pu(k,1), sg*ctx.Pu(k,2)];
            ang  = sg*P.psi_e(k);
            tip  = shock_end(foot, ang, Xd, a_inner);
            L(end+1) = struct('name', sprintf('OS%d', k), 'kind', 'ext', 'foot', foot, 'tip', tip, ...
                'angle_deg', mod(rad2deg(ang), 180), 'beta_deg', rad2deg(P.beta_e(k)), 'miss', P.miss_e(k));   %#ok<AGROW>
        end
    end
    for j = 1:m
        if isfinite(P.psi_i(j))
            foot = [ctx.Qu(j,1), sg*ctx.Qu(j,2)];
            ang  = sg*P.psi_i(j);
            tip  = shock_end(foot, ang, Sd, sg*ctx.Phi0(n+1));
            L(end+1) = struct('name', sprintf('IS%d', j), 'kind', 'int', 'foot', foot, 'tip', tip, ...
                'angle_deg', mod(rad2deg(ang), 180), 'beta_deg', rad2deg(P.beta_i(j)), 'miss', P.miss_i(j));   %#ok<AGROW>
        end
    end
    if P.alive
        foot = Sd;  tip = [ctx.Tu(1), sg*ctx.Tu(2)];
        v = tip - foot;
        L(end+1) = struct('name', 'Terminal shock', 'kind', 'term', 'foot', foot, 'tip', tip, ...
            'angle_deg', mod(rad2deg(atan2(v(2), v(1))), 180), 'beta_deg', NaN, 'miss', NaN);   %#ok<AGROW>
    end
end
