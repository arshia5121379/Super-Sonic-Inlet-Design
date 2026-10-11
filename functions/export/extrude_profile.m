function [F, V] = extrude_profile(pts, W)
% Sweeps an N-by-2 [X Y] profile along +z from 0 to W (surface mesh, no end caps).
    N = size(pts, 1);
    V = [pts(:,1), pts(:,2), zeros(N,1);
         pts(:,1), pts(:,2), W*ones(N,1)];
    k = (1:N-1)';
    F = [k, k+1, N+k+1;
         k, N+k+1, N+k];
    F = drop_degenerate(F, V);
end
