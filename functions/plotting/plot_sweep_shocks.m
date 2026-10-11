function plot_sweep_shocks(ctx, gin, S, kind, nmax)
% Shock pattern of selected conditions of a sweep. Every panel shows the fixed inlet hardware with the shocks of THAT
% condition only (foot, slope, terminal shock); the design shocks are not drawn.
    nv  = numel(S.R);
    idx = unique(round(linspace(1, nv, min(nv, nmax))));
    nc  = min(numel(idx), 3);  nr = ceil(numel(idx)/nc);
    if strcmp(kind, 'M'), nm = 'Mach sweep'; else, nm = 'Incidence sweep'; end
    figure('Name', [nm ' - shock patterns'], 'Position', [40 40 1500 330*nr + 80]);
    for c = 1:numel(idx)
        R = S.R{idx(c)};
        subplot(nr, nc, c);
        inlet_geometry(gin.sol, gin.flag, gin.cowl, gin.sol_int, gin.diffuser, gin.lengths, false);
        hold on;
        overlay_shock_lines(ctx, R.Pl{1}, R, 6, 'short');
        title(sprintf('M_\\infty = %.3f, h = %.0f m, \\alpha = %+.2f^\\circ\n\\pi_d = %.4f  (%s)', ...
            R.M0, R.alt, R.alpha_deg, R.pi_d, status_text(R)), 'FontSize', 9);
        hold off;
    end
    fig_title([nm ' - shock pattern of each condition (dashed: oblique shocks from their feet, thick: terminal shock)']);
end
