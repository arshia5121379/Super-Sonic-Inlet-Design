function plot_station_graph(st_d, st_o, ttl)
% Mach number, total and static pressure at every region of the inlet (design, optionally with off-design).
    N = numel(st_d.M);  x = 1:N;
    figure('Name', ttl, 'Position', [100 40 980 860]);
    cb = [0.00 0.45 0.74];  cr = [0.85 0.15 0.10];
    cod = [0.10 0.60 0.20; 0.60 0.20 0.70];

    % ---- Mach number ----
    subplot(3,1,1);  hold on;  grid on;
    hs = plot(x, st_d.M, '-o', 'LineWidth', 2, 'Color', cb, 'MarkerFaceColor', cb);
    leg = {sprintf('Design  (M_\\infty = %.3f)', st_d.M0)};
    for i = 1:numel(st_o)
        ho = plot(x, st_o{i}.M, '--s', 'LineWidth', 1.8, 'Color', cod(mod(i-1,2)+1,:), 'MarkerFaceColor', 'w');
        hs(end+1) = ho;   %#ok<AGROW>
        leg{end+1} = off_label(st_o{i});   %#ok<AGROW>
    end
    plot([0.5 N+0.5], [1 1], 'k:');
    text(x, st_d.M, arrayfun(@(v) sprintf('%.3f', v), st_d.M, 'UniformOutput', false), ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 8, 'Color', cb);
    set(gca, 'XTick', x, 'XTickLabel', st_d.short);  xlim([0.5 N+0.5]);
    ylabel('Mach number M');  title(ttl);  legend(hs, leg, 'Location', 'northeast');

    % ---- static and total pressure ----
    subplot(3,1,2);  hold on;  grid on;
    h1 = plot(x, st_d.p0/1e3, '-s', 'LineWidth', 2, 'Color', cb, 'MarkerFaceColor', cb);
    h2 = plot(x, st_d.p /1e3, '-o', 'LineWidth', 2, 'Color', cr, 'MarkerFaceColor', cr);
    hs = [h1 h2];  leg = {'Total p_0 (design)', 'Static p (design)'};
    for i = 1:numel(st_o)
        h3 = plot(x, st_o{i}.p0/1e3, '--s', 'LineWidth', 1.6, 'Color', cb, 'MarkerFaceColor', 'w');
        h4 = plot(x, st_o{i}.p /1e3, '--o', 'LineWidth', 1.6, 'Color', cr, 'MarkerFaceColor', 'w');
        hs = [hs h3 h4];   %#ok<AGROW>
        leg = [leg, {['Total p_0 (' off_short(st_o{i}) ')'], ['Static p (' off_short(st_o{i}) ')']}];   %#ok<AGROW>
    end
    text(x, st_d.p0/1e3, arrayfun(@(v) sprintf('%.1f', v/1e3), st_d.p0, 'UniformOutput', false), ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 8, 'Color', cb);
    text(x, st_d.p/1e3, arrayfun(@(v) sprintf('%.1f', v/1e3), st_d.p, 'UniformOutput', false), ...
        'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 8, 'Color', cr);
    set(gca, 'XTick', x, 'XTickLabel', st_d.short);  xlim([0.5 N+0.5]);
    ylabel('Pressure [kPa]');  legend(hs, leg, 'Location', 'best');

    % ---- total-pressure recovery along the inlet ----
    subplot(3,1,3);  hold on;  grid on;
    hs = plot(x, st_d.p0r, '-s', 'LineWidth', 2, 'Color', cb, 'MarkerFaceColor', cb);
    leg = {'Design'};
    for i = 1:numel(st_o)
        ho = plot(x, st_o{i}.p0r, '--s', 'LineWidth', 1.8, 'Color', cod(mod(i-1,2)+1,:), 'MarkerFaceColor', 'w');
        hs(end+1) = ho;   %#ok<AGROW>
        leg{end+1} = off_short(st_o{i});   %#ok<AGROW>
    end
    text(x, st_d.p0r, arrayfun(@(v) sprintf('%.4f', v), st_d.p0r, 'UniformOutput', false), ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 8, 'Color', cb);
    set(gca, 'XTick', x, 'XTickLabel', st_d.short, 'XTickLabelRotation', 0);  xlim([0.5 N+0.5]);
    ylabel('p_0 / p_{0,\infty}');  xlabel('Region of the inlet');  legend(hs, leg, 'Location', 'southwest');
end
