function [hs, ll] = add_flags(x, y, S)
% Red crosses on detached-shock points, magenta triangles on choked-exit points.
    hs = gobjects(0);  ll = {};
    if any(S.detached)
        hs(end+1) = plot(x(S.detached), y(S.detached), 'rx', 'MarkerSize', 9, 'LineWidth', 2);   %#ok<AGROW>
        ll{end+1} = 'Detached shock';   %#ok<AGROW>
    end
    k = S.choked & ~S.detached;
    if any(k)
        hs(end+1) = plot(x(k), y(k), 'm^', 'MarkerSize', 7, 'LineWidth', 1.5);   %#ok<AGROW>
        ll{end+1} = 'Exit choked';   %#ok<AGROW>
    end
end
