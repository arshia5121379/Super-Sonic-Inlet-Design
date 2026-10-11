function plot_maps(ctx, MP)
% Contour maps over (Mach number, incidence). Dots mark conditions with a detached shock.
    figure('Name', 'Maps - Mach number x incidence', 'Position', [80 60 1300 780]);
    [MM, AA] = meshgrid(MP.Mvec, MP.Avec);
    data   = {MP.pi_d, MP.MFR, MP.M_exit, MP.pr_exit};
    titles = {'Total-pressure recovery \pi_d', 'Mass-flow capture ratio A_c/A_{cap}', 'Diffuser-exit Mach number', 'Exit static pressure ratio p_{exit}/p_\infty'};
    for i = 1:4
        subplot(2,2,i);  hold on;
        contourf(MM, AA, data{i}, 14);  colorbar;
        plot(MM(MP.detached), AA(MP.detached), 'k.', 'MarkerSize', 6);
        plot(ctx.M1, 0, 'kd', 'MarkerFaceColor', 'y', 'MarkerSize', 8);
        xlabel('M_\infty');  ylabel('\alpha [deg]');  title(titles{i});
    end
    fig_title('Maps over Mach number and incidence  (diamond = design point, dots = detached shock)');
end
