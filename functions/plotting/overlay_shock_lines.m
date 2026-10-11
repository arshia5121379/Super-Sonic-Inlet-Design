function [hk, lk] = overlay_shock_lines(ctx, P, R, fs, mode)
% Draws the shocks of one flow plane P (from inlet_eval) on the current axes: dashed line from the foot of every
% oblique shock to its end, with a triangle at the foot, plus the terminal shock. mode: 'full' (beta, slope, regime
% in the labels) or 'short' (slope only). Returns one handle / legend text per kind of shock.
    Ls = offdesign_shock_lines(ctx, P);
    col = {[0.10 0.60 0.20], [0.00 0.60 0.60], [0.85 0.00 0.50]};
    kinds = {'ext', 'int', 'term'};
    ltxt  = {'off-design external shocks', 'off-design internal shocks', 'off-design terminal shock'};
    hh = gobjects(1, 3);
    for q = 1:numel(Ls)
        ki = find(strcmp(Ls(q).kind, kinds));
        c  = col{ki};  lw = 1.8;  if ki == 3, lw = 3.0; end
        h = plot([Ls(q).foot(1) Ls(q).tip(1)], [Ls(q).foot(2) Ls(q).tip(2)], '--', 'LineWidth', lw, 'Color', c);
        plot(Ls(q).foot(1), Ls(q).foot(2), 'v', 'MarkerSize', 6, 'MarkerFaceColor', c, 'MarkerEdgeColor', 'k');
        if ~isgraphics(hh(ki)), hh(ki) = h; end
        if strcmp(mode, 'short')
            nm = Ls(q).name;  if ki == 3, nm = 'TS'; end
            lbl = sprintf('%s %.1f^\\circ', nm, Ls(q).angle_deg);
        elseif ki == 3
            lbl = sprintf('%s: M_b = %.3f, slope %.1f^\\circ', Ls(q).name, P.M_b, Ls(q).angle_deg);
            if ~isempty(R), lbl = sprintf('%s\n(%s)', lbl, R.regime_short); end
        else
            lbl = sprintf('%s: \\beta = %.2f^\\circ, slope %.1f^\\circ', Ls(q).name, Ls(q).beta_deg, Ls(q).angle_deg);
        end
        text(mean([Ls(q).foot(1) Ls(q).tip(1)]), mean([Ls(q).foot(2) Ls(q).tip(2)]), lbl, 'FontSize', fs, ...
            'Color', c*0.7, 'FontWeight', 'bold', 'BackgroundColor', [1 1 1], 'Margin', 1);
    end
    ok = isgraphics(hh);
    hk = hh(ok);  lk = ltxt(ok);
end
