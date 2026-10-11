function plot_sweep_perf(ctx, S, kind, base)
% Performance versus Mach number or incidence: recovery, capture, exit Mach, exit pressure, Mach / total
% pressure at every region, shock angles and cowl-lip attachment.
    if strcmp(kind, 'M')
        x = S.M0;  xl = 'Freestream Mach number M_\infty';  nm = 'Mach sweep';
        xd = ctx.M1;  show_des = abs(base.alpha) < 1e-12;
        sub = sprintf('h = %.0f m, \\alpha = %+.2f^\\circ', base.h, base.alpha);
    else
        x = S.alpha;  xl = 'Incidence \alpha [deg]';  nm = 'Incidence sweep';
        xd = 0;  show_des = abs(base.M - ctx.M1) < 1e-9;
        sub = sprintf('M_\\infty = %.3f, h = %.0f m', base.M, base.h);
    end
    N = size(S.stM, 1);
    figure('Name', [nm ' - performance'], 'Position', [40 60 1560 820]);
    cmap = lines(N);

    subplot(2,4,1);  hold on;  grid on;
    hs = plot(x, S.pi_d, 'b-o', 'LineWidth', 1.6, 'MarkerSize', 4);  leg = {'Inlet (fixed geometry)'};
    if strcmp(kind, 'M')
        mil = ones(size(x));  k = x > 1;  mil(k) = 1 - 0.075*(x(k) - 1).^1.35;
        hs(end+1) = plot(x, mil, 'k--', 'LineWidth', 1.2);  leg{end+1} = 'MIL-E-5008B';
    end
    if show_des
        hs(end+1) = plot(xd, ctx.pi_d_design, 'kd', 'MarkerFaceColor', 'y', 'MarkerSize', 8);  leg{end+1} = 'Design point';
    end
    [hf, lf] = add_flags(x, S.pi_d, S);  hs = [hs hf];  leg = [leg lf];
    xlabel(xl);  ylabel('\pi_d = p_{0,exit}/p_{0,\infty}');  title('Total-pressure recovery');  legend(hs, leg, 'Location', 'best');

    subplot(2,4,2);  hold on;  grid on;
    hs = plot(x, S.MFR, 'b-o', 'LineWidth', 1.6, 'MarkerSize', 4);  leg = {'A_c/A_{cap}'};
    if show_des
        hs(end+1) = plot(xd, ctx.MFR_d, 'kd', 'MarkerFaceColor', 'y', 'MarkerSize', 8);  leg{end+1} = 'Design point';
    end
    [hf, lf] = add_flags(x, S.MFR, S);  hs = [hs hf];  leg = [leg lf];
    xlabel(xl);  ylabel('Mass-flow capture ratio A_c/A_{cap}');  title('Capture / spillage');  legend(hs, leg, 'Location', 'best');

    subplot(2,4,3);  hold on;  grid on;
    hs = plot(x, S.M_exit, 'b-o', 'LineWidth', 1.6, 'MarkerSize', 4);  leg = {'Diffuser-exit Mach (continuity)'};
    if show_des
        hs(end+1) = plot(xd, ctx.M_exit, 'kd', 'MarkerFaceColor', 'y', 'MarkerSize', 8);  leg{end+1} = 'Design point';
    end
    [hf, lf] = add_flags(x, S.M_exit, S);  hs = [hs hf];  leg = [leg lf];
    xlabel(xl);  ylabel('M_{exit}');  title('Diffuser-exit Mach number');  legend(hs, leg, 'Location', 'best');

    subplot(2,4,4);  hold on;  grid on;
    hs = plot(x, S.pr_exit, 'b-o', 'LineWidth', 1.6, 'MarkerSize', 4);  leg = {'p_{exit}/p_\infty'};
    if show_des
        hs(end+1) = plot(xd, ctx.pr_exit_d, 'kd', 'MarkerFaceColor', 'y', 'MarkerSize', 8);  leg{end+1} = 'Design point';
    end
    [hf, lf] = add_flags(x, S.pr_exit, S);  hs = [hs hf];  leg = [leg lf];
    xlabel(xl);  ylabel('p_{exit}/p_\infty');  title('Diffuser-exit static pressure ratio');  legend(hs, leg, 'Location', 'best');

    subplot(2,4,5);  hold on;  grid on;
    hs = gobjects(1, N-1);
    for i = 2:N, hs(i-1) = plot(x, S.stM(i,:), '-', 'LineWidth', 1.5, 'Color', cmap(i,:)); end
    xlabel(xl);  ylabel('Mach number');  title('Mach number in every region');  legend(hs, S.short(2:N), 'Location', 'best');

    subplot(2,4,6);  hold on;  grid on;
    hs = gobjects(1, N-1);
    for i = 2:N, hs(i-1) = plot(x, S.stP0r(i,:), '-', 'LineWidth', 1.5, 'Color', cmap(i,:)); end
    xlabel(xl);  ylabel('p_0 / p_{0,\infty}');  title('Total-pressure ratio in every region');  legend(hs, S.short(2:N), 'Location', 'best');

    subplot(2,4,7);  hold on;  grid on;
    nb = size(S.beta, 1);  hs = gobjects(1, nb);  leg = cell(1, nb);
    for k = 1:nb
        hs(k) = plot(x, rad2deg(S.beta(k,:)), '-o', 'LineWidth', 1.4, 'MarkerSize', 3);
        if k <= ctx.n, leg{k} = sprintf('external shock %d', k); else, leg{k} = sprintf('internal shock %d', k - ctx.n); end
    end
    xlabel(xl);  ylabel('Shock angle \beta [deg]');  title('Oblique-shock angles (gaps = detached)');  legend(hs, leg, 'Location', 'best');

    subplot(2,4,8);  hold on;  grid on;
    h1 = plot(x, rad2deg(S.lip_delta), 'r-', 'LineWidth', 1.6);
    h2 = plot(x, rad2deg(S.lip_tmax),  'k--', 'LineWidth', 1.6);
    xlabel(xl);  ylabel('Turn [deg]');  title('Outer cowl-lip surface');
    legend([h1 h2], {'Flow turn (upper cowl angle + \alpha)', '\theta_{max} (attached limit)'}, 'Location', 'best');

    fig_title(sprintf('%s  -  %s', nm, sub));
end
