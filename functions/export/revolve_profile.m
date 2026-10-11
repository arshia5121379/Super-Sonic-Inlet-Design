function [F, V] = revolve_profile(pts, n_theta)
% Revolves an N-by-2 [X R] profile 360 deg about the x axis (y = 0).
    N  = size(pts, 1);
    th = 2*pi*(0:n_theta-1)/n_theta;
    V  = zeros(N*n_theta, 3);
    for j = 1:n_theta
        idx = (j-1)*N + (1:N);
        V(idx,:) = [pts(:,1), pts(:,2)*cos(th(j)), pts(:,2)*sin(th(j))];
    end
    [K, J] = ndgrid(1:N-1, 1:n_theta);
    Jn = mod(J, n_theta) + 1;                 % next angular station (wraps around)
    a = (J-1)*N + K;   b = a + 1;
    d = (Jn-1)*N + K;  e = d + 1;
    F = [a(:), b(:), e(:);
         a(:), e(:), d(:)];
    F = drop_degenerate(F, V);                % removes the zero-area triangles at the axis
end
