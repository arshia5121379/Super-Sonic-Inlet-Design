function draw_regions(gin, ctx, geo, st, ttl, Pod, R)
% Redraws the inlet and labels every region with its Mach number, static and total pressure.
% Pod (optional, plane struct of inlet_eval): the design shocks are then NOT drawn; only the OFF-DESIGN shocks are shown,
% every oblique shock as a dashed line starting at its foot (ramp / cowl corner) with its true slope, plus the terminal shock. R (optional, the full
% inlet_eval result) supplies the terminal-shock regime for the label.
    if nargin < 7, R = []; end
    figure('Name', ttl, 'Position', [120 60 1250 640]);
    inlet_geometry(gin.sol, gin.flag, gin.cowl, gin.sol_int, gin.diffuser, gin.lengths, isempty(Pod));   % off-design: design shocks removed
    hold on;
    if ~isempty(Pod)
        [hk, lk] = overlay_shock_lines(ctx, Pod, R, 7, 'full');
        if ~isempty(hk), legend(hk, lk, 'Location', 'southwest'); end
        if Pod.detached
            text(0.02, 0.05, ['DETACHED SHOCK: ' strjoin(Pod.msgs, ' | ')], 'Units', 'normalized', 'Color', [0.8 0 0], ...
                'FontSize', 8, 'BackgroundColor', [1 1 1], 'VerticalAlignment', 'bottom');
        end
    end
    A = region_anchors(ctx, geo);
    for i = 1:size(A,1)
        lbl = sprintf('\\bf%s\\rm\nM = %.3f\np = %.1f kPa\np_0 = %.1f kPa', st.short{i}, st.M(i), st.p(i)/1e3, st.p0(i)/1e3);
        ha = 'center';
        if i == size(A,1), ha = 'left'; end
        plot(A(i,1), A(i,2), 'k.', 'MarkerSize', 10);
        text(A(i,1), A(i,2), lbl, 'FontSize', 8, 'HorizontalAlignment', ha, 'VerticalAlignment', 'middle', ...
            'BackgroundColor', [1 1 0.88], 'EdgeColor', [0.5 0.5 0.5], 'Margin', 2);
    end
    xs = geo.P_ult(1,1) - geo.P(1,1);
    xl = xlim;
    xlim([min(xl(1), geo.P(1,1) - 0.35*xs), max(xl(2), geo.P_ult(1,1) + 0.45*xs)]);
    title(sprintf('%s  (M_\\infty = %.3f, h = %.0f m, \\alpha = %+.2f^\\circ)', ttl, st.M0, st.alt_m, st.alpha_deg));
    hold off;
end
