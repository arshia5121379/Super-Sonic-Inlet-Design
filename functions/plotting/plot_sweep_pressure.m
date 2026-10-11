function plot_sweep_pressure(ctx, SP, SM, base)
% Absolute pressures versus flight altitude (ISA) and exit-pressure maps in the (M, altitude) plane.
    N = size(SP.stP, 1);  x = SP.alt/1e3;
    cmap = lines(N);
    figure('Name', 'Altitude sweep - absolute pressures', 'Position', [60 60 1400 780]);
    subplot(2,2,1);  hold on;  grid on;
    hs = gobjects(1, N);
    for i = 1:N, hs(i) = plot(x, SP.stP(i,:)/1e3, '-o', 'LineWidth', 1.5, 'Color', cmap(i,:), 'MarkerSize', 4); end
    xlabel('Flight altitude h [km]');  ylabel('Static pressure [kPa]');
    title(sprintf('Static pressure in every region (M_\\infty = %.3f, \\alpha = %+.2f^\\circ)', base.M, base.alpha));
    legend(hs, SP.short, 'Location', 'northeast');
    subplot(2,2,2);  hold on;  grid on;
    hs = gobjects(1, N);
    for i = 1:N, hs(i) = plot(x, SP.stP0(i,:)/1e3, '-o', 'LineWidth', 1.5, 'Color', cmap(i,:), 'MarkerSize', 4); end
    xlabel('Flight altitude h [km]');  ylabel('Total pressure [kPa]');
    title(sprintf('Total pressure in every region  (\\pi_d = %.4f ... %.4f over the altitudes)', min(SP.pi_d), max(SP.pi_d)));
    legend(hs, SP.short, 'Location', 'northeast');
    if ~isempty(SM)
        hg = linspace(SP.alt(1), SP.alt(end), 40);
        pg = isa_atmosphere(hg);                       % ISA static pressure on the altitude grid [Pa]
        Z1 = pg(:) * SM.pr_exit;                       % p_exit(M, h) = (p_exit/p_inf)(M) * p_inf(h)   [Pa]
        Z2 = pg(:) * (SM.p0_exit ./ SM.p_s);           % p0_exit(M, h)
        subplot(2,2,3);  hold on;
        contourf(SM.M0, hg/1e3, Z1/1e3, 14);  colorbar;
        plot(ctx.M1, ctx.alt/1e3, 'kd', 'MarkerFaceColor', 'y', 'MarkerSize', 8);
        xlabel('M_\\infty');  ylabel('Flight altitude h [km]');  title(sprintf('Diffuser-exit static pressure [kPa]  (\\alpha = %+.2f^\\circ)', base.alpha));
        subplot(2,2,4);  hold on;
        contourf(SM.M0, hg/1e3, Z2/1e3, 14);  colorbar;
        plot(ctx.M1, ctx.alt/1e3, 'kd', 'MarkerFaceColor', 'y', 'MarkerSize', 8);
        xlabel('M_\\infty');  ylabel('Flight altitude h [km]');  title('Diffuser-exit total pressure [kPa]  (diamond = design point)');
    end
end
