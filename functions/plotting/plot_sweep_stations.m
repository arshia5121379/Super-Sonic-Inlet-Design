function plot_sweep_stations(S, kind)
% Mach number, static and total pressure at every region, one curve per condition of the sweep.
    nv = numel(S.R);  ns = min(nv, 8);
    idx = unique(round(linspace(1, nv, ns)));
    cols = parula(numel(idx));
    N = numel(S.short);  x = 1:N;
    if strcmp(kind, 'M'), nm = 'Mach sweep'; else, nm = 'Incidence sweep'; end
    figure('Name', [nm ' - flow stations per condition'], 'Position', [140 40 980 860]);
    leg = cell(1, numel(idx));
    for c = 1:numel(idx)
        R = S.R{idx(c)};
        if strcmp(kind, 'M'), leg{c} = sprintf('M_\\infty = %.3f', R.M0); else, leg{c} = sprintf('\\alpha = %+.2f^\\circ', R.alpha_deg); end
    end
    panels = {'Mach number M', S.stM, 1; 'Static pressure [kPa]', S.stP, 1e3; 'Total pressure [kPa]', S.stP0, 1e3};
    for pnl = 1:3
        subplot(3,1,pnl);  hold on;  grid on;
        hs = gobjects(1, numel(idx));
        for c = 1:numel(idx)
            hs(c) = plot(x, panels{pnl,2}(:, idx(c))/panels{pnl,3}, '-o', 'LineWidth', 1.5, 'Color', cols(c,:), 'MarkerSize', 4);
        end
        if pnl == 1, plot([0.5 N+0.5], [1 1], 'k:'); end
        set(gca, 'XTick', x, 'XTickLabel', S.short);  xlim([0.5 N+0.5]);
        ylabel(panels{pnl,1});
        if pnl == 1, title([nm ' - flow stations for each condition']); legend(hs, leg, 'Location', 'best'); end
        if pnl == 3, xlabel('Region of the inlet'); end
    end
end
